From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 3/3] netprio_cgroup: fix wrong memory access when NETPRIO_CGROUP=m
Date: Fri, 10 Feb 2012 10:43:38 -0500
Message-ID: <1328888618-16208-4-git-send-email-nhorman@tuxdriver.com>
References: <1328888618-16208-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56706 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758071Ab2BJPps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 10:45:48 -0500
In-Reply-To: <1328888618-16208-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the netprio_cgroup module is not loaded, net_prio_subsys_id
is -1, and so sock_update_prioidx() accesses cgroup_subsys array
with negative index subsys[-1].

Make the code resembles cls_cgroup code, which is bug free.

Origionally-authored-by: Li Zefan <lizf@cn.fujitsu.com>
Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 include/net/netprio_cgroup.h |   48 +++++++++++++++++++++++++++++++++++-------
 net/core/sock.c              |    7 +----
 2 files changed, 42 insertions(+), 13 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 7b2d431..d58fdec 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -37,19 +37,51 @@ extern int net_prio_subsys_id;
 
 extern void sock_update_netprioidx(struct sock *sk);
 
-static inline struct cgroup_netprio_state
-		*task_netprio_state(struct task_struct *p)
+#if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
+
+static inline u32 task_netprioidx(struct task_struct *p)
 {
-#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
-	return container_of(task_subsys_state(p, net_prio_subsys_id),
-			    struct cgroup_netprio_state, css);
-#else
-	return NULL;
-#endif
+	struct cgroup_netprio_state *state;
+	u32 idx;
+
+	rcu_read_lock();
+	state = container_of(task_subsys_state(p, net_prio_subsys_id),
+			     struct cgroup_netprio_state, css);
+	idx = state->prioidx;
+	rcu_read_unlock();
+	return idx;
+}
+
+#elif IS_MODULE(CONFIG_NETPRIO_CGROUP)
+
+static inline u32 task_netprioidx(struct task_struct *p)
+{
+	struct cgroup_netprio_state *state;
+	int subsys_id;
+	u32 idx = 0;
+
+	rcu_read_lock();
+	subsys_id = rcu_dereference_index_check(net_prio_subsys_id,
+						rcu_read_lock_held());
+	if (subsys_id >= 0) {
+		state = container_of(task_subsys_state(p, subsys_id),
+				     struct cgroup_netprio_state, css);
+		idx = state->prioidx;
+	}
+	rcu_read_unlock();
+	return idx;
 }
 
 #else
 
+static inline u32 task_netprioidx(struct task_struct *p)
+{
+	return 0;
+}
+
+#endif /* CONFIG_NETPRIO_CGROUP */
+
+#else
 #define sock_update_netprioidx(sk)
 #endif
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 3e81fd2..02f8dfe 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1171,13 +1171,10 @@ EXPORT_SYMBOL(sock_update_classid);
 
 void sock_update_netprioidx(struct sock *sk)
 {
-	struct cgroup_netprio_state *state;
 	if (in_interrupt())
 		return;
-	rcu_read_lock();
-	state = task_netprio_state(current);
-	sk->sk_cgrp_prioidx = state ? state->prioidx : 0;
-	rcu_read_unlock();
+
+	sk->sk_cgrp_prioidx = task_netprioidx(current);
 }
 EXPORT_SYMBOL_GPL(sock_update_netprioidx);
 #endif
-- 
1.7.7.6
