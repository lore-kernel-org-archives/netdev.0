From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 3/6] bpf: adjust insn_aux_data when patching insns
Date: Wed, 15 Mar 2017 18:26:41 -0700
Message-ID: <1489627604-2288703-4-git-send-email-ast@fb.com>
References: <1489627604-2288703-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Fengguang Wu <fengguang.wu@intel.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56547 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750858AbdCPB0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 21:26:46 -0400
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2G1JC0T011531
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 297cdv17dk-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:45 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 9dca410e09e711e794090002c9dfb610-b64e49a0 for <netdev@vger.kernel.org>;        Wed,
 15 Mar 2017 18:26:44 -0700
In-Reply-To: <1489627604-2288703-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

convert_ctx_accesses() replaces single bpf instruction with a set of
instructions. Adjust corresponding insn_aux_data while patching.
It's needed to make sure subsequent 'for(all insn)' loops
have matching insn and insn_aux_data.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 44 +++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 39 insertions(+), 5 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 5dfa9b8111da..2990fda1c6a5 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3162,6 +3162,41 @@ static void convert_pseudo_ld_imm64(struct bpf_verifier_env *env)
 			insn->src_reg = 0;
 }
 
+/* single env->prog->insni[off] instruction was replaced with the range
+ * insni[off, off + cnt).  Adjust corresponding insn_aux_data by copying
+ * [0, off) and [off, end) to new locations, so the patched range stays zero
+ */
+static int adjust_insn_aux_data(struct bpf_verifier_env *env, u32 prog_len,
+				u32 off, u32 cnt)
+{
+	struct bpf_insn_aux_data *new_data, *old_data = env->insn_aux_data;
+
+	if (cnt == 1)
+		return 0;
+	new_data = vzalloc(sizeof(struct bpf_insn_aux_data) * prog_len);
+	if (!new_data)
+		return -ENOMEM;
+	memcpy(new_data, old_data, sizeof(struct bpf_insn_aux_data) * off);
+	memcpy(new_data + off + cnt - 1, old_data + off,
+	       sizeof(struct bpf_insn_aux_data) * (prog_len - off - cnt + 1));
+	env->insn_aux_data = new_data;
+	vfree(old_data);
+	return 0;
+}
+
+static struct bpf_prog *bpf_patch_insn_data(struct bpf_verifier_env *env, u32 off,
+					    const struct bpf_insn *patch, u32 len)
+{
+	struct bpf_prog *new_prog;
+
+	new_prog = bpf_patch_insn_single(env->prog, off, patch, len);
+	if (!new_prog)
+		return NULL;
+	if (adjust_insn_aux_data(env, new_prog->len, off, len))
+		return NULL;
+	return new_prog;
+}
+
 /* convert load instructions that access fields of 'struct __sk_buff'
  * into sequence of instructions that access fields of 'struct sk_buff'
  */
@@ -3181,10 +3216,10 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 			verbose("bpf verifier is misconfigured\n");
 			return -EINVAL;
 		} else if (cnt) {
-			new_prog = bpf_patch_insn_single(env->prog, 0,
-							 insn_buf, cnt);
+			new_prog = bpf_patch_insn_data(env, 0, insn_buf, cnt);
 			if (!new_prog)
 				return -ENOMEM;
+
 			env->prog = new_prog;
 			delta += cnt - 1;
 		}
@@ -3209,7 +3244,7 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 		else
 			continue;
 
-		if (env->insn_aux_data[i].ptr_type != PTR_TO_CTX)
+		if (env->insn_aux_data[i + delta].ptr_type != PTR_TO_CTX)
 			continue;
 
 		cnt = ops->convert_ctx_access(type, insn, insn_buf, env->prog);
@@ -3218,8 +3253,7 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 			return -EINVAL;
 		}
 
-		new_prog = bpf_patch_insn_single(env->prog, i + delta, insn_buf,
-						 cnt);
+		new_prog = bpf_patch_insn_data(env, i + delta, insn_buf, cnt);
 		if (!new_prog)
 			return -ENOMEM;
 
-- 
2.8.0
