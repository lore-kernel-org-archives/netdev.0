From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCHv6 net-next 04/15] bpf: don't (ab)use instructions to
 store state
Date: Mon, 19 Sep 2016 22:36:21 +0100
Message-ID: <20160919223621.363c8ac5@jkicinski-Precision-T1700>
References: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
        <1474211365-20088-5-git-send-email-jakub.kicinski@netronome.com>
        <57E05295.4010904@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, kubakici@wp.pl
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35433 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932762AbcISVg0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 17:36:26 -0400
Received: by mail-wm0-f42.google.com with SMTP id l132so174641517wmf.0
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 14:36:25 -0700 (PDT)
In-Reply-To: <57E05295.4010904@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 23:03:17 +0200, Daniel Borkmann wrote:
> Hi Jakub,
> 
> On 09/18/2016 05:09 PM, Jakub Kicinski wrote:
> > Storing state in reserved fields of instructions makes
> > it impossible to run verifier on programs already
> > marked as read-only. Allocate and use an array of
> > per-instruction state instead.
> >
> > While touching the error path rename and move existing
> > jump target.
> >
> > Suggested-by: Alexei Starovoitov <ast@kernel.org>
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > Acked-by: Alexei Starovoitov <ast@kernel.org>
> > Acked-by: Daniel Borkmann <daniel@iogearbox.net>  
> 
> I believe there's still an issue here. Could you please double check
> and confirm?
> 
> I rebased my locally pending stuff on top of your set and suddenly my
> test case breaks. So I did a bisect and it pointed me to this commit
> eventually.
> 
> [...]
> > @@ -2697,11 +2706,8 @@ static int convert_ctx_accesses(struct verifier_env *env)
> >   		else
> >   			continue;
> >
> > -		if (insn->imm != PTR_TO_CTX) {
> > -			/* clear internal mark */
> > -			insn->imm = 0;
> > +		if (env->insn_aux_data[i].ptr_type != PTR_TO_CTX)
> >   			continue;
> > -		}
> >
> >   		cnt = env->prog->aux->ops->
> >   			convert_ctx_access(type, insn->dst_reg, insn->src_reg,  
> 
> Looking at the code, I believe the issue is in above snippet. In the
> convert_ctx_accesses() rewrite loop, each time we bpf_patch_insn_single()
> a program, the program can grow in size (due to __sk_buff access rewrite,
> for example). After rewrite, we do 'i += insn_delta' for adjustment to
> process next insn.
> 
> However, env->insn_aux_data is alloced under the assumption that the
> very initial, pre-verification prog->len doesn't change, right? So in
> the above conversion access to env->insn_aux_data[i].ptr_type is off,
> since after rewrites, corresponding mappings to ptr_type might not be
> related anymore.
> 
> I noticed this with direct packet access where suddenly the data vs
> data_end test failed and contained some "semi-random" value always
> bailing out for me.

You are correct.  Should I respin or would you like to post your set? :)
