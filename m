From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCHv6 net-next 04/15] bpf: don't (ab)use instructions to
 store state
Date: Mon, 19 Sep 2016 22:48:12 +0100
Message-ID: <20160919224812.7a4b90b8@jkicinski-Precision-T1700>
References: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
        <1474211365-20088-5-git-send-email-jakub.kicinski@netronome.com>
        <57E05295.4010904@iogearbox.net>
        <20160919223621.363c8ac5@jkicinski-Precision-T1700>
        <57E05C52.4060208@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, kubakici@wp.pl
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38426 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932403AbcISVsR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 17:48:17 -0400
Received: by mail-wm0-f50.google.com with SMTP id l132so2401077wmf.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 14:48:16 -0700 (PDT)
In-Reply-To: <57E05C52.4060208@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 23:44:50 +0200, Daniel Borkmann wrote:
> On 09/19/2016 11:36 PM, Jakub Kicinski wrote:
> > On Mon, 19 Sep 2016 23:03:17 +0200, Daniel Borkmann wrote:  
> >> On 09/18/2016 05:09 PM, Jakub Kicinski wrote:  
> >>> Storing state in reserved fields of instructions makes
> >>> it impossible to run verifier on programs already
> >>> marked as read-only. Allocate and use an array of
> >>> per-instruction state instead.
> >>>
> >>> While touching the error path rename and move existing
> >>> jump target.
> >>>
> >>> Suggested-by: Alexei Starovoitov <ast@kernel.org>
> >>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> >>> Acked-by: Alexei Starovoitov <ast@kernel.org>
> >>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>  
> >>
> >> I believe there's still an issue here. Could you please double check
> >> and confirm?
> >>
> >> I rebased my locally pending stuff on top of your set and suddenly my
> >> test case breaks. So I did a bisect and it pointed me to this commit
> >> eventually.
> >>
> >> [...]  
> >>> @@ -2697,11 +2706,8 @@ static int convert_ctx_accesses(struct verifier_env *env)
> >>>    		else
> >>>    			continue;
> >>>
> >>> -		if (insn->imm != PTR_TO_CTX) {
> >>> -			/* clear internal mark */
> >>> -			insn->imm = 0;
> >>> +		if (env->insn_aux_data[i].ptr_type != PTR_TO_CTX)
> >>>    			continue;
> >>> -		}
> >>>
> >>>    		cnt = env->prog->aux->ops->
> >>>    			convert_ctx_access(type, insn->dst_reg, insn->src_reg,  
> >>
> >> Looking at the code, I believe the issue is in above snippet. In the
> >> convert_ctx_accesses() rewrite loop, each time we bpf_patch_insn_single()
> >> a program, the program can grow in size (due to __sk_buff access rewrite,
> >> for example). After rewrite, we do 'i += insn_delta' for adjustment to
> >> process next insn.
> >>
> >> However, env->insn_aux_data is alloced under the assumption that the
> >> very initial, pre-verification prog->len doesn't change, right? So in
> >> the above conversion access to env->insn_aux_data[i].ptr_type is off,
> >> since after rewrites, corresponding mappings to ptr_type might not be
> >> related anymore.
> >>
> >> I noticed this with direct packet access where suddenly the data vs
> >> data_end test failed and contained some "semi-random" value always
> >> bailing out for me.  
> >
> > You are correct.  Should I respin or would you like to post your set? :)  
> 
> Heh, if you don't mind I would go ahead tonight, the conflict at two spots
> when exposing verifier is really minor turns out. Are you okay with this?

Yes, please go ahead :)
 
> What's the plan wrt env->insn_aux_data? Realloc plus rewrite of the array,
> or do you see a more straight forward solution?

I was thinking about something like this: (untested)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1612f7364c42..5c4cae046251 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2657,13 +2657,13 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 	struct bpf_insn insn_buf[16];
 	struct bpf_prog *new_prog;
 	enum bpf_access_type type;
-	int i;
+	int i, delta = 0;
 
 	if (!env->prog->aux->ops->convert_ctx_access)
 		return 0;
 
 	for (i = 0; i < insn_cnt; i++, insn++) {
-		u32 insn_delta, cnt;
+		u32 cnt;
 
 		if (insn->code == (BPF_LDX | BPF_MEM | BPF_W) ||
 		    insn->code == (BPF_LDX | BPF_MEM | BPF_DW))
@@ -2685,18 +2685,16 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 			return -EINVAL;
 		}
 
-		new_prog = bpf_patch_insn_single(env->prog, i, insn_buf, cnt);
+		new_prog = bpf_patch_insn_single(env->prog, i + delta, insn_buf,
+						 cnt);
 		if (!new_prog)
 			return -ENOMEM;
 
-		insn_delta = cnt - 1;
+		delta += cnt - 1;
 
 		/* keep walking new program and skip insns we just inserted */
 		env->prog = new_prog;
-		insn      = new_prog->insnsi + i + insn_delta;
-
-		insn_cnt += insn_delta;
-		i        += insn_delta;
+		insn      = new_prog->insnsi + i + delta;
 	}
 
 	return 0;
