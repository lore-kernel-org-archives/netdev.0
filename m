From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v5 1/3] bpf: Refactor cgroups code in prep for new type
Date: Tue, 29 Nov 2016 07:53:31 -0800
Message-ID: <1480434813-3141-2-git-send-email-dsa@cumulusnetworks.com>
References: <1480434813-3141-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34716 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755045AbcK2Pxl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:53:41 -0500
Received: by mail-pf0-f174.google.com with SMTP id c4so32680573pfb.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 07:53:41 -0800 (PST)
In-Reply-To: <1480434813-3141-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code move and rename only; no functional change intended.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v5
- no change

v4
- dropped refactor of __cgroup_bpf_run_filter and renamed it
  to __cgroup_bpf_run_filter_skb

v3
- dropped the rename

v2
- fix bpf_prog_run_clear_cb to bpf_prog_run_save_cb as caught by Daniel

- rename BPF_PROG_TYPE_CGROUP_SKB and its cg_skb functions to
  BPF_PROG_TYPE_CGROUP and cgroup

 include/linux/bpf-cgroup.h | 46 +++++++++++++++++++++++-----------------------
 kernel/bpf/cgroup.c        | 10 +++++-----
 kernel/bpf/syscall.c       | 28 +++++++++++++++-------------
 3 files changed, 43 insertions(+), 41 deletions(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index ec80d0c0953e..7f0fc635b13e 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -37,31 +37,31 @@ void cgroup_bpf_update(struct cgroup *cgrp,
 		       struct bpf_prog *prog,
 		       enum bpf_attach_type type);
 
-int __cgroup_bpf_run_filter(struct sock *sk,
-			    struct sk_buff *skb,
-			    enum bpf_attach_type type);
-
-/* Wrappers for __cgroup_bpf_run_filter() guarded by cgroup_bpf_enabled. */
-#define BPF_CGROUP_RUN_PROG_INET_INGRESS(sk,skb)			\
-({									\
-	int __ret = 0;							\
-	if (cgroup_bpf_enabled)						\
-		__ret = __cgroup_bpf_run_filter(sk, skb,		\
-						BPF_CGROUP_INET_INGRESS); \
-									\
-	__ret;								\
+int __cgroup_bpf_run_filter_skb(struct sock *sk,
+				struct sk_buff *skb,
+				enum bpf_attach_type type);
+
+/* Wrappers for __cgroup_bpf_run_filter_skb() guarded by cgroup_bpf_enabled. */
+#define BPF_CGROUP_RUN_PROG_INET_INGRESS(sk, skb)			      \
+({									      \
+	int __ret = 0;							      \
+	if (cgroup_bpf_enabled)						      \
+		__ret = __cgroup_bpf_run_filter_skb(sk, skb,		      \
+						    BPF_CGROUP_INET_INGRESS); \
+									      \
+	__ret;								      \
 })
 
-#define BPF_CGROUP_RUN_PROG_INET_EGRESS(sk,skb)				\
-({									\
-	int __ret = 0;							\
-	if (cgroup_bpf_enabled && sk && sk == skb->sk) {		\
-		typeof(sk) __sk = sk_to_full_sk(sk);			\
-		if (sk_fullsock(__sk))					\
-			__ret = __cgroup_bpf_run_filter(__sk, skb,	\
-						BPF_CGROUP_INET_EGRESS); \
-	}								\
-	__ret;								\
+#define BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb)			       \
+({									       \
+	int __ret = 0;							       \
+	if (cgroup_bpf_enabled && sk && sk == skb->sk) {		       \
+		typeof(sk) __sk = sk_to_full_sk(sk);			       \
+		if (sk_fullsock(__sk))					       \
+			__ret = __cgroup_bpf_run_filter_skb(__sk, skb,	       \
+						      BPF_CGROUP_INET_EGRESS); \
+	}								       \
+	__ret;								       \
 })
 
 #else
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index a0ab43f264b0..19892973a78a 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -118,7 +118,7 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
 }
 
 /**
- * __cgroup_bpf_run_filter() - Run a program for packet filtering
+ * __cgroup_bpf_run_filter_skb() - Run a program for packet filtering
  * @sk: The socken sending or receiving traffic
  * @skb: The skb that is being sent or received
  * @type: The type of program to be exectuted
@@ -132,9 +132,9 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
  * This function will return %-EPERM if any if an attached program was found
  * and if it returned != 1 during execution. In all other cases, 0 is returned.
  */
-int __cgroup_bpf_run_filter(struct sock *sk,
-			    struct sk_buff *skb,
-			    enum bpf_attach_type type)
+int __cgroup_bpf_run_filter_skb(struct sock *sk,
+				struct sk_buff *skb,
+				enum bpf_attach_type type)
 {
 	struct bpf_prog *prog;
 	struct cgroup *cgrp;
@@ -164,4 +164,4 @@ int __cgroup_bpf_run_filter(struct sock *sk,
 
 	return ret;
 }
-EXPORT_SYMBOL(__cgroup_bpf_run_filter);
+EXPORT_SYMBOL(__cgroup_bpf_run_filter_skb);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 4caa18e6860a..5518a6839ab1 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -856,6 +856,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 {
 	struct bpf_prog *prog;
 	struct cgroup *cgrp;
+	enum bpf_prog_type ptype;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -866,25 +867,26 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	switch (attr->attach_type) {
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
-		prog = bpf_prog_get_type(attr->attach_bpf_fd,
-					 BPF_PROG_TYPE_CGROUP_SKB);
-		if (IS_ERR(prog))
-			return PTR_ERR(prog);
-
-		cgrp = cgroup_get_from_fd(attr->target_fd);
-		if (IS_ERR(cgrp)) {
-			bpf_prog_put(prog);
-			return PTR_ERR(cgrp);
-		}
-
-		cgroup_bpf_update(cgrp, prog, attr->attach_type);
-		cgroup_put(cgrp);
+		ptype = BPF_PROG_TYPE_CGROUP_SKB;
 		break;
 
 	default:
 		return -EINVAL;
 	}
 
+	prog = bpf_prog_get_type(attr->attach_bpf_fd, ptype);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	cgrp = cgroup_get_from_fd(attr->target_fd);
+	if (IS_ERR(cgrp)) {
+		bpf_prog_put(prog);
+		return PTR_ERR(cgrp);
+	}
+
+	cgroup_bpf_update(cgrp, prog, attr->attach_type);
+	cgroup_put(cgrp);
+
 	return 0;
 }
 
-- 
2.1.4
