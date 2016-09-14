From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv3 net-next 05/15] bpf: enable non-core use of the verfier
Date: Wed, 14 Sep 2016 16:05:51 -0700
Message-ID: <20160914230549.GB60248@ast-mbp.thefacebook.com>
References: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
 <1473879623-15382-6-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        jiri@resnulli.us, john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34983 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbcINXFx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 19:05:53 -0400
Received: by mail-pf0-f196.google.com with SMTP id z84so1359293pfi.2
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 16:05:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473879623-15382-6-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 08:00:13PM +0100, Jakub Kicinski wrote:
> Advanced JIT compilers and translators may want to use
> eBPF verifier as a base for parsers or to perform custom
> checks and validations.
> 
> Add ability for external users to invoke the verifier
> and provide callbacks to be invoked for every intruction
> checked.  For now only add most basic callback for
> per-instruction pre-interpretation checks is added.  More
> advanced users may also like to have per-instruction post
> callback and state comparison callback.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  include/linux/bpf_parser.h |  89 ++++++++++++++++++++++++++++++
>  kernel/bpf/verifier.c      | 134 +++++++++++++++++++++++----------------------
>  2 files changed, 158 insertions(+), 65 deletions(-)
>  create mode 100644 include/linux/bpf_parser.h
> 
> diff --git a/include/linux/bpf_parser.h b/include/linux/bpf_parser.h
> new file mode 100644
> index 000000000000..daa53b204f4d
> --- /dev/null
> +++ b/include/linux/bpf_parser.h

'bpf parser' is a bit misleading name, since it can be interpreted
as parser written in bpf.
Also the header file containes verifier bits, therefore I think
the better name would be bpf_verifier.h ?

> @@ -0,0 +1,89 @@
> +/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + */
> +#ifndef _LINUX_BPF_PARSER_H
> +#define _LINUX_BPF_PARSER_H 1
> +
> +#include <linux/bpf.h> /* for enum bpf_reg_type */
> +#include <linux/filter.h> /* for MAX_BPF_STACK */
> +
> +struct reg_state {
> +	enum bpf_reg_type type;
> +	union {
> +		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
> +		s64 imm;
> +
> +		/* valid when type == PTR_TO_PACKET* */
> +		struct {
> +			u32 id;
> +			u16 off;
> +			u16 range;
> +		};
> +
> +		/* valid when type == CONST_PTR_TO_MAP | PTR_TO_MAP_VALUE |
> +		 *   PTR_TO_MAP_VALUE_OR_NULL
> +		 */
> +		struct bpf_map *map_ptr;
> +	};
> +};
> +
> +enum bpf_stack_slot_type {
> +	STACK_INVALID,    /* nothing was stored in this stack slot */
> +	STACK_SPILL,      /* register spilled into stack */
> +	STACK_MISC	  /* BPF program wrote some data into this slot */
> +};
> +
> +#define BPF_REG_SIZE 8	/* size of eBPF register in bytes */
> +
> +/* state of the program:
> + * type of all registers and stack info
> + */
> +struct verifier_state {
> +	struct reg_state regs[MAX_BPF_REG];
> +	u8 stack_slot_type[MAX_BPF_STACK];
> +	struct reg_state spilled_regs[MAX_BPF_STACK / BPF_REG_SIZE];
> +};
> +
> +/* linked list of verifier states used to prune search */
> +struct verifier_state_list {
> +	struct verifier_state state;
> +	struct verifier_state_list *next;
> +};
> +
> +struct bpf_insn_aux_data {
> +	enum bpf_reg_type ptr_type;	/* pointer type for load/store insns */
> +};
> +
> +#define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
> +
> +struct verifier_env;
> +struct bpf_ext_parser_ops {
> +	int (*insn_hook)(struct verifier_env *env,
> +			 int insn_idx, int prev_insn_idx);
> +};

How about calling this bpf_ext_analyzer_ops
and main entry bpf_analyzer() ?
I think it will better convey what it's doing.

> +
> +/* single container for all structs
> + * one verifier_env per bpf_check() call
> + */
> +struct verifier_env {
> +	struct bpf_prog *prog;		/* eBPF program being verified */
> +	struct verifier_stack_elem *head; /* stack of verifier states to be processed */
> +	int stack_size;			/* number of states to be processed */
> +	struct verifier_state cur_state; /* current verifier state */
> +	struct verifier_state_list **explored_states; /* search pruning optimization */
> +	const struct bpf_ext_parser_ops *pops; /* external parser ops */
> +	void *ppriv; /* pointer to external parser's private data */

a bit hard to review, since move and addition is in one patch.
I think ppriv and pops are too obscure names.
May be analyzer_ops and analyzer_priv ?

Conceptually looks good.
