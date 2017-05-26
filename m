From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] MIPS: Add support for eBPF JIT.
Date: Fri, 26 May 2017 11:29:24 -0400 (EDT)
Message-ID: <20170526.112924.2288900171993979942.davem@davemloft.net>
References: <20170526003826.10834-1-david.daney@cavium.com>
        <20170526003826.10834-6-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org, markos.chandras@imgtec.com
To: david.daney@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41438 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030511AbdEZP30 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 11:29:26 -0400
In-Reply-To: <20170526003826.10834-6-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>
Date: Thu, 25 May 2017 17:38:26 -0700

> +static int gen_int_prologue(struct jit_ctx *ctx)
> +{
> +	int stack_adjust = 0;
> +	int store_offset;
> +	int locals_size;
> +
> +	if (ctx->flags & EBPF_SAVE_RA)
> +		/*
> +		 * If RA we are doing a function call and may need
> +		 * extra 8-byte tmp area.
> +		 */
> +		stack_adjust += 16;
> +	if (ctx->flags & EBPF_SAVE_S0)
> +		stack_adjust += 8;
> +	if (ctx->flags & EBPF_SAVE_S1)
> +		stack_adjust += 8;
> +	if (ctx->flags & EBPF_SAVE_S2)
> +		stack_adjust += 8;
> +	if (ctx->flags & EBPF_SAVE_S3)
> +		stack_adjust += 8;
> +
> +	BUILD_BUG_ON(MAX_BPF_STACK & 7);
> +	locals_size = (ctx->flags & EBPF_SEEN_FP) ? MAX_BPF_STACK : 0;

You will also need to use MAX_BPF_STACK here when you see a tail call,
but it appears you haven't implemented tail call support yet.

Which also several of the eBPF samples won't JIT and thus be tested
under this new MIPS JIT, since they make use of tail calls.

> +/*
> + * Track the value range (i.e. 32-bit vs. 64-bit) of each register at
> + * each eBPF insn.  This allows unneeded sign and zero extension
> + * operations to be omitted.
> + *
> + * Doesn't handle yet confluence of control paths with conflicting
> + * ranges, but it is good enough for most sane code.
> + */
> +static int reg_val_propagate(struct jit_ctx *ctx)

Very interesting technique.  I may adopt this for Sparc as well :-)

Perhaps at a some point, when the BPF verifier has real data flow
analysis, it can compute this for the JIT.
