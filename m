From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 1/8] bpf: Recursively apply cgroup sock filters
Date: Tue, 22 Aug 2017 17:20:14 -0700
Message-ID: <1503447621-27997-2-git-send-email-dsahern@gmail.com>
References: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33122 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752779AbdHWAU3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 20:20:29 -0400
Received: by mail-pf0-f194.google.com with SMTP id x137so211765pfd.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 17:20:29 -0700 (PDT)
In-Reply-To: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recursively apply sock filters attached to a cgroup. For now, start
with the inner cgroup attached to the socket and work back to the
root. If desired the inverse can be done use an attach flag (start
with parent cgroup and go in).

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/bpf-cgroup.h |  5 +++--
 kernel/bpf/cgroup.c        |  4 +---
 kernel/cgroup/cgroup.c     | 18 ++++++++++++++++++
 3 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index d41d40ac3efd..d95e44ccd549 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -40,8 +40,9 @@ int __cgroup_bpf_run_filter_skb(struct sock *sk,
 				struct sk_buff *skb,
 				enum bpf_attach_type type);
 
-int __cgroup_bpf_run_filter_sk(struct sock *sk,
+int __cgroup_bpf_run_filter_sk(struct cgroup *cgrp, struct sock *sk,
 			       enum bpf_attach_type type);
+int cgroup_bpf_run_filter_sk(struct sock *sk, enum bpf_attach_type type);
 
 int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
 				     struct bpf_sock_ops_kern *sock_ops,
@@ -74,7 +75,7 @@ int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
 ({									       \
 	int __ret = 0;							       \
 	if (cgroup_bpf_enabled && sk) {					       \
-		__ret = __cgroup_bpf_run_filter_sk(sk,			       \
+		__ret = cgroup_bpf_run_filter_sk(sk,			       \
 						 BPF_CGROUP_INET_SOCK_CREATE); \
 	}								       \
 	__ret;								       \
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index 546113430049..0480610bda83 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -217,14 +217,12 @@ EXPORT_SYMBOL(__cgroup_bpf_run_filter_skb);
  * This function will return %-EPERM if any if an attached program was found
  * and if it returned != 1 during execution. In all other cases, 0 is returned.
  */
-int __cgroup_bpf_run_filter_sk(struct sock *sk,
+int __cgroup_bpf_run_filter_sk(struct cgroup *cgrp, struct sock *sk,
 			       enum bpf_attach_type type)
 {
-	struct cgroup *cgrp = sock_cgroup_ptr(&sk->sk_cgrp_data);
 	struct bpf_prog *prog;
 	int ret = 0;
 
-
 	rcu_read_lock();
 
 	prog = rcu_dereference(cgrp->bpf.effective[type]);
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index df2e0f14a95d..7480cebab073 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -5186,4 +5186,22 @@ int cgroup_bpf_update(struct cgroup *cgrp, struct bpf_prog *prog,
 	mutex_unlock(&cgroup_mutex);
 	return ret;
 }
+
+int cgroup_bpf_run_filter_sk(struct sock *sk,
+			     enum bpf_attach_type type)
+{
+	struct cgroup *cgrp = sock_cgroup_ptr(&sk->sk_cgrp_data);
+	int ret = 0;
+
+	while (cgrp) {
+		ret = __cgroup_bpf_run_filter_sk(cgrp, sk, type);
+		if (ret < 0)
+			break;
+
+		cgrp = cgroup_parent(cgrp);
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(cgroup_bpf_run_filter_sk);
 #endif /* CONFIG_CGROUP_BPF */
-- 
2.1.4
