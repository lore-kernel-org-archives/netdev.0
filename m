From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFCv2 16/16] nfp: bpf: add offload of TC direct action mode
Date: Mon, 29 Aug 2016 23:09:35 +0200
Message-ID: <57C4A48F.6080403@iogearbox.net>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com> <1472234775-29453-17-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50245 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbcH2VJi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 17:09:38 -0400
In-Reply-To: <1472234775-29453-17-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2016 08:06 PM, Jakub Kicinski wrote:
> Add offload of TC in direct action mode.  We just need
> to provide appropriate checks in the verifier and
> a new outro block to translate the exit codes to what
> data path expects
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
[...]
> +static void nfp_outro_tc_da(struct nfp_prog *nfp_prog)
> +{
> +	/* TC direct-action mode:

Would have made this the only supported mode, but I understand you
want to have the legacy drop/redir actions, fair enough.

> +	 *   0,1   ok        NOT SUPPORTED[1]
> +	 *   2   drop  0x22 -> drop,  count as stat1
> +	 *   4,5 nuke  0x02 -> drop
> +	 *   7  redir  0x44 -> redir, count as stat2
> +	 *   * unspec  0x11 -> pass,  count as stat0
> +	 *
> +	 * [1] We can't support OK and RECLASSIFY because we can't tell TC
> +	 *     the exact decision made.  We are forced to support UNSPEC
> +	 *     to handle aborts so that's the only one we handle for passing
> +	 *     packets up the stack.

In da mode, RECLASSIFY is not supported, so this one could be scratched.
For the OK and UNSPEC part, couldn't both be treated the same (as in: OK /
pass to stack roughly equivalent as in sch_handle_ingress())? Or is the
issue that you cannot populate skb->tc_index when passing to stack (maybe
just fine to leave it at 0 for now)?
Just curious, does TC_ACT_REDIRECT work in this scenario?

> +	 */
> +	/* Target for aborts */
> +	nfp_prog->tgt_abort = nfp_prog_current_offset(nfp_prog);
> +
> +	emit_br_def(nfp_prog, nfp_prog->tgt_done, 2);
> +
> +	emit_alu(nfp_prog, reg_a(0),
> +		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
> +	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_imm(0x11), SHF_SC_L_SHF, 16);
> +
> +	/* Target for normal exits */
> +	nfp_prog->tgt_out = nfp_prog_current_offset(nfp_prog);
> +
> +	/* if R0 > 7 jump to abort */
> +	emit_alu(nfp_prog, reg_none(), reg_imm(7), ALU_OP_SUB, reg_b(0));
> +	emit_br(nfp_prog, BR_BLO, nfp_prog->tgt_abort, 0);
> +	emit_alu(nfp_prog, reg_a(0),
> +		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
> +
> +	wrp_immed(nfp_prog, reg_b(2), 0x41221211);
> +	wrp_immed(nfp_prog, reg_b(3), 0x41001211);
> +
> +	emit_shf(nfp_prog, reg_a(1),
> +		 reg_none(), SHF_OP_NONE, reg_b(0), SHF_SC_L_SHF, 2);
> +
> +	emit_alu(nfp_prog, reg_none(), reg_a(1), ALU_OP_OR, reg_imm(0));
> +	emit_shf(nfp_prog, reg_a(2),
> +		 reg_imm(0xf), SHF_OP_AND, reg_b(2), SHF_SC_R_SHF, 0);
> +
> +	emit_alu(nfp_prog, reg_none(), reg_a(1), ALU_OP_OR, reg_imm(0));
> +	emit_shf(nfp_prog, reg_b(2),
> +		 reg_imm(0xf), SHF_OP_AND, reg_b(3), SHF_SC_R_SHF, 0);
> +
> +	emit_br_def(nfp_prog, nfp_prog->tgt_done, 2);
> +
> +	emit_shf(nfp_prog, reg_b(2),
> +		 reg_a(2), SHF_OP_OR, reg_b(2), SHF_SC_L_SHF, 4);
> +	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_b(2), SHF_SC_L_SHF, 16);
> +}
