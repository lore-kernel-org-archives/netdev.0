From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: fix ri->map prog pointer on bpf_prog_realloc
Date: Mon, 18 Sep 2017 18:43:28 -0700
Message-ID: <20170919014326.r4x5ymz33zecayas@ast-mbp>
References: <b797841607c3327007a787af3418cb0a60b868c0.1505783562.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, john.fastabend@gmail.com, ast@kernel.org,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37342 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdISBnm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 21:43:42 -0400
Received: by mail-pg0-f67.google.com with SMTP id v5so1173926pgn.4
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 18:43:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <b797841607c3327007a787af3418cb0a60b868c0.1505783562.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 03:16:44AM +0200, Daniel Borkmann wrote:
> Commit 109980b894e9 ("bpf: don't select potentially stale
> ri->map from buggy xdp progs") passed the pointer to the prog
> itself to be loaded into r4 prior on bpf_redirect_map() helper
> call, so that we can store the owner into ri->map_owner out of
> the helper.
> 
> Issue with that is that the actual address of the prog is still
> subject to change when subsequent rewrites occur, e.g. through
> patching other helper functions or constant blinding. Thus, we
> really need to take prog->aux as the address we're holding, and
> then during runtime fetch the actual pointer via aux->prog. This
> also works with prog clones as they share the same aux and fixup
> pointer to self after blinding finished.
> 
> Fixes: 109980b894e9 ("bpf: don't select potentially stale ri->map from buggy xdp progs")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  kernel/bpf/verifier.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 799b245..243c09f 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -4205,9 +4205,17 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
>  		}
>  
>  		if (insn->imm == BPF_FUNC_redirect_map) {
> -			u64 addr = (unsigned long)prog;
> +			/* Note, we cannot use prog directly as imm as subsequent
> +			 * rewrites would still change the prog pointer. The only
> +			 * stable address we can use is aux, which also works with
> +			 * prog clones during blinding.
> +			 */

good catch. extra load at runtime sucks, but I don't see better solution.

> +			u64 addr = (unsigned long)prog->aux;
> +			const int r4 = BPF_REG_4;
>  			struct bpf_insn r4_ld[] = {
> -				BPF_LD_IMM64(BPF_REG_4, addr),
> +				BPF_LD_IMM64(r4, addr),
> +				BPF_LDX_MEM(BPF_DW, r4, r4,
> +					    offsetof(struct bpf_prog_aux, prog)),

needs to be BPF_FIELD_SIZEOF(struct bpf_prog_aux, prog) to work on 32-bit
