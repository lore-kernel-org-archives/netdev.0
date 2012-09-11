From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v3 2/8] cgroup: net_cls: Do not define task_cls_classid() when not selected
Date: Tue, 11 Sep 2012 18:26:08 +0200
Message-ID: <1347380774-9546-3-git-send-email-wagi@monom.org>
References: <1347380774-9546-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:60257 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757329Ab2IKQ0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 12:26:21 -0400
In-Reply-To: <1347380774-9546-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

task_cls_classid() should not be defined in case the configuration is
CONFIG_NET_CLS_CGROUP=n. The reason is that in a following patch the
net_cls_subsys_id will only be defined if CONFIG_NET_CLS_CGROUP!=n.
When net_cls is not built at all a callee should only get an empty
task_cls_classid() without any references to net_cls_subsys_id.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 include/net/cls_cgroup.h | 11 ++++++-----
 net/core/sock.c          |  2 ++
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index e88527a..9bd5db9 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -17,7 +17,7 @@
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
 
-#ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 struct cgroup_cls_state
 {
 	struct cgroup_subsys_state css;
@@ -26,7 +26,7 @@ struct cgroup_cls_state
 
 extern void sock_update_classid(struct sock *sk);
 
-#ifdef CONFIG_NET_CLS_CGROUP
+#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	int classid;
@@ -41,7 +41,8 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 	return classid;
 }
-#else
+#elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
+
 extern int net_cls_subsys_id;
 
 static inline u32 task_cls_classid(struct task_struct *p)
@@ -63,7 +64,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	return classid;
 }
 #endif
-#else
+#else /* !CGROUP_NET_CLS_CGROUP */
 static inline void sock_update_classid(struct sock *sk)
 {
 }
@@ -72,5 +73,5 @@ static inline u32 task_cls_classid(struct task_struct *p)
 {
 	return 0;
 }
-#endif
+#endif /* CGROUP_NET_CLS_CGROUP */
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index d765156..a2af5ef 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1223,6 +1223,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 }
 
 #ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 void sock_update_classid(struct sock *sk)
 {
 	u32 classid;
@@ -1234,6 +1235,7 @@ void sock_update_classid(struct sock *sk)
 		sk->sk_classid = classid;
 }
 EXPORT_SYMBOL(sock_update_classid);
+#endif
 
 void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
 {
-- 
1.7.12.315.g682ce8b
