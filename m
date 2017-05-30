From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 5/9] bpf: track stack depth of classic bpf programs
Date: Tue, 30 May 2017 13:31:31 -0700
Message-ID: <20170530203135.3642768-6-ast@fb.com>
References: <20170530203135.3642768-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55379 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751000AbdE3Ubj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:31:39 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4UKS521012371
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2as8hwsg4m-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:31:38 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 fa416866457611e7a7fe0002c99331b0-951348f0 for <netdev@vger.kernel.org>;        Tue,
 30 May 2017 13:31:36 -0700
In-Reply-To: <20170530203135.3642768-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To track stack depth of classic bpf programs we only need
to analyze ST|STX instructions, since check_load_and_stores()
verifies that programs can load from stack only after write.

We also need to change the way cBPF stack slots map to eBPF stack,
since typical classic programs are using slots 0 and 1, so they
need to map to stack offsets -4 and -8 respectively in order
to take advantage of small stack interpreter and JITs.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/filter.c | 36 ++++++++++++++++++++++--------------
 1 file changed, 22 insertions(+), 14 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index a6bb95fa87b2..946f758d44f2 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -352,7 +352,7 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
  *	bpf_convert_filter - convert filter program
  *	@prog: the user passed filter program
  *	@len: the length of the user passed filter program
- *	@new_prog: buffer where converted program will be stored
+ *	@new_prog: allocated 'struct bpf_prog' or NULL
  *	@new_len: pointer to store length of converted program
  *
  * Remap 'sock_filter' style classic BPF (cBPF) instruction set to 'bpf_insn'
@@ -364,14 +364,13 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
  *
  * 2) 2nd pass to remap in two passes: 1st pass finds new
  *    jump offsets, 2nd pass remapping:
- *   new_prog = kmalloc(sizeof(struct bpf_insn) * new_len);
  *   bpf_convert_filter(old_prog, old_len, new_prog, &new_len);
  */
 static int bpf_convert_filter(struct sock_filter *prog, int len,
-			      struct bpf_insn *new_prog, int *new_len)
+			      struct bpf_prog *new_prog, int *new_len)
 {
-	int new_flen = 0, pass = 0, target, i;
-	struct bpf_insn *new_insn;
+	int new_flen = 0, pass = 0, target, i, stack_off;
+	struct bpf_insn *new_insn, *first_insn = NULL;
 	struct sock_filter *fp;
 	int *addrs = NULL;
 	u8 bpf_src;
@@ -383,6 +382,7 @@ static int bpf_convert_filter(struct sock_filter *prog, int len,
 		return -EINVAL;
 
 	if (new_prog) {
+		first_insn = new_prog->insnsi;
 		addrs = kcalloc(len, sizeof(*addrs),
 				GFP_KERNEL | __GFP_NOWARN);
 		if (!addrs)
@@ -390,11 +390,11 @@ static int bpf_convert_filter(struct sock_filter *prog, int len,
 	}
 
 do_pass:
-	new_insn = new_prog;
+	new_insn = first_insn;
 	fp = prog;
 
 	/* Classic BPF related prologue emission. */
-	if (new_insn) {
+	if (new_prog) {
 		/* Classic BPF expects A and X to be reset first. These need
 		 * to be guaranteed to be the first two instructions.
 		 */
@@ -415,7 +415,7 @@ static int bpf_convert_filter(struct sock_filter *prog, int len,
 		struct bpf_insn *insn = tmp_insns;
 
 		if (addrs)
-			addrs[i] = new_insn - new_prog;
+			addrs[i] = new_insn - first_insn;
 
 		switch (fp->code) {
 		/* All arithmetic insns and skb loads map as-is. */
@@ -561,17 +561,25 @@ static int bpf_convert_filter(struct sock_filter *prog, int len,
 		/* Store to stack. */
 		case BPF_ST:
 		case BPF_STX:
+			stack_off = fp->k * 4  + 4;
 			*insn = BPF_STX_MEM(BPF_W, BPF_REG_FP, BPF_CLASS(fp->code) ==
 					    BPF_ST ? BPF_REG_A : BPF_REG_X,
-					    -(BPF_MEMWORDS - fp->k) * 4);
+					    -stack_off);
+			/* check_load_and_stores() verifies that classic BPF can
+			 * load from stack only after write, so tracking
+			 * stack_depth for ST|STX insns is enough
+			 */
+			if (new_prog && new_prog->aux->stack_depth < stack_off)
+				new_prog->aux->stack_depth = stack_off;
 			break;
 
 		/* Load from stack. */
 		case BPF_LD | BPF_MEM:
 		case BPF_LDX | BPF_MEM:
+			stack_off = fp->k * 4  + 4;
 			*insn = BPF_LDX_MEM(BPF_W, BPF_CLASS(fp->code) == BPF_LD  ?
 					    BPF_REG_A : BPF_REG_X, BPF_REG_FP,
-					    -(BPF_MEMWORDS - fp->k) * 4);
+					    -stack_off);
 			break;
 
 		/* A = K or X = K */
@@ -619,13 +627,13 @@ static int bpf_convert_filter(struct sock_filter *prog, int len,
 
 	if (!new_prog) {
 		/* Only calculating new length. */
-		*new_len = new_insn - new_prog;
+		*new_len = new_insn - first_insn;
 		return 0;
 	}
 
 	pass++;
-	if (new_flen != new_insn - new_prog) {
-		new_flen = new_insn - new_prog;
+	if (new_flen != new_insn - first_insn) {
+		new_flen = new_insn - first_insn;
 		if (pass > 2)
 			goto err;
 		goto do_pass;
@@ -1017,7 +1025,7 @@ static struct bpf_prog *bpf_migrate_filter(struct bpf_prog *fp)
 	fp->len = new_len;
 
 	/* 2nd pass: remap sock_filter insns into bpf_insn insns. */
-	err = bpf_convert_filter(old_prog, old_len, fp->insnsi, &new_len);
+	err = bpf_convert_filter(old_prog, old_len, fp, &new_len);
 	if (err)
 		/* 2nd bpf_convert_filter() can fail only if it fails
 		 * to allocate memory, remapping must succeed. Note,
-- 
2.9.3
