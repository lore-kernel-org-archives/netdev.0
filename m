From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC PATCH net-next 1/2] bpf: Save original ebpf instructions
Date: Fri,  3 Feb 2017 12:38:22 -0800
Message-ID: <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com>
References: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34303 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752293AbdBCUia (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 15:38:30 -0500
Received: by mail-pf0-f181.google.com with SMTP id e4so8232496pfg.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 12:38:30 -0800 (PST)
In-Reply-To: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to classic bpf, support saving original ebpf instructions

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/filter.h |  5 ++++-
 kernel/bpf/syscall.c   | 36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 1 deletion(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index e4eb2546339a..86b1e3624463 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -391,7 +391,10 @@ struct compat_sock_fprog {
 
 struct sock_fprog_kern {
 	u16			len;
-	struct sock_filter	*filter;
+	union {
+		struct sock_filter	*filter;
+		struct bpf_insn		*insn;
+	};
 };
 
 struct bpf_binary_header {
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 08a4d287226b..95e640a3ed99 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -694,11 +694,43 @@ static void bpf_prog_uncharge_memlock(struct bpf_prog *prog)
 	free_uid(user);
 }
 
+static int bpf_prog_store_orig_insn(struct bpf_prog *prog)
+{
+	u32 isize = bpf_prog_insn_size(prog);
+	struct sock_fprog_kern *fkprog;
+
+	prog->orig_prog = kmalloc(sizeof(*fkprog), GFP_KERNEL);
+	if (!prog->orig_prog)
+		return -ENOMEM;
+
+	fkprog = prog->orig_prog;
+	fkprog->len = prog->len;
+
+	fkprog->insn = kmemdup(prog->insnsi, isize, GFP_KERNEL | __GFP_NOWARN);
+	if (!fkprog->insn) {
+		kfree(prog->orig_prog);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void bpf_release_orig_insn(struct bpf_prog *fp)
+{
+	struct sock_fprog_kern *fprog = fp->orig_prog;
+
+	if (fprog) {
+		kfree(fprog->insn);
+		kfree(fprog);
+	}
+}
+
 static void __bpf_prog_put_rcu(struct rcu_head *rcu)
 {
 	struct bpf_prog_aux *aux = container_of(rcu, struct bpf_prog_aux, rcu);
 
 	free_used_maps(aux);
+	bpf_release_orig_insn(aux->prog);
 	bpf_prog_uncharge_memlock(aux->prog);
 	bpf_prog_free(aux->prog);
 }
@@ -885,6 +917,10 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (err < 0)
 		goto free_prog;
 
+	err = bpf_prog_store_orig_insn(prog);
+	if (err < 0)
+		goto free_prog;
+
 	/* run eBPF verifier */
 	err = bpf_check(&prog, attr);
 	if (err < 0)
-- 
2.1.4
