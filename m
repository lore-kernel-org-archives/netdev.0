From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv4 net-next 07/15] bpf: recognize 64bit immediate loads as
 consts
Date: Thu, 15 Sep 2016 13:12:15 -0700
Message-ID: <20160915201214.GC74433@ast-mbp.thefacebook.com>
References: <1473966755-30106-1-git-send-email-jakub.kicinski@netronome.com>
 <1473966755-30106-8-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        jiri@resnulli.us, john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34456 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbcIOUMU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:12:20 -0400
Received: by mail-pa0-f67.google.com with SMTP id vz6so2524080pab.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:12:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473966755-30106-8-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 08:12:27PM +0100, Jakub Kicinski wrote:
> When running as parser interpret BPF_LD | BPF_IMM | BPF_DW
> instructions as loading CONST_IMM with the value stored
> in imm.  The verifier will continue not recognizing those
> due to concerns about search space/program complexity
> increase.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> v3:
>  - limit to parsers.
> ---
>  kernel/bpf/verifier.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index d93e78331b90..f5bed7cce08d 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1766,9 +1766,19 @@ static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
>  	if (err)
>  		return err;
>  
> -	if (insn->src_reg == 0)
> -		/* generic move 64-bit immediate into a register */
> +	if (insn->src_reg == 0) {
> +		/* generic move 64-bit immediate into a register,
> +		 * only analyzer needs to collect the ld_imm value.
> +		 */
> +		u64 imm = ((u64)(insn + 1)->imm << 32) | (u32)insn->imm;
> +
> +		if (!env->analyzer_ops)
> +			return 0;

the check makes sense. thanks.
Acked-by: Alexei Starovoitov <ast@kernel.org>
