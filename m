From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv6 net-next 04/15] bpf: don't (ab)use instructions to store
 state
Date: Mon, 19 Sep 2016 23:03:17 +0200
Message-ID: <57E05295.4010904@iogearbox.net>
References: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com> <1474211365-20088-5-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42778 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbcISVDT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 17:03:19 -0400
In-Reply-To: <1474211365-20088-5-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jakub,

On 09/18/2016 05:09 PM, Jakub Kicinski wrote:
> Storing state in reserved fields of instructions makes
> it impossible to run verifier on programs already
> marked as read-only. Allocate and use an array of
> per-instruction state instead.
>
> While touching the error path rename and move existing
> jump target.
>
> Suggested-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

I believe there's still an issue here. Could you please double check
and confirm?

I rebased my locally pending stuff on top of your set and suddenly my
test case breaks. So I did a bisect and it pointed me to this commit
eventually.

[...]
> @@ -2697,11 +2706,8 @@ static int convert_ctx_accesses(struct verifier_env *env)
>   		else
>   			continue;
>
> -		if (insn->imm != PTR_TO_CTX) {
> -			/* clear internal mark */
> -			insn->imm = 0;
> +		if (env->insn_aux_data[i].ptr_type != PTR_TO_CTX)
>   			continue;
> -		}
>
>   		cnt = env->prog->aux->ops->
>   			convert_ctx_access(type, insn->dst_reg, insn->src_reg,

Looking at the code, I believe the issue is in above snippet. In the
convert_ctx_accesses() rewrite loop, each time we bpf_patch_insn_single()
a program, the program can grow in size (due to __sk_buff access rewrite,
for example). After rewrite, we do 'i += insn_delta' for adjustment to
process next insn.

However, env->insn_aux_data is alloced under the assumption that the
very initial, pre-verification prog->len doesn't change, right? So in
the above conversion access to env->insn_aux_data[i].ptr_type is off,
since after rewrites, corresponding mappings to ptr_type might not be
related anymore.

I noticed this with direct packet access where suddenly the data vs
data_end test failed and contained some "semi-random" value always
bailing out for me.

Thanks,
Daniel
