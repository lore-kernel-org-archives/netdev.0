From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v2 04/10] cgroup: net_prio: Protect access to task_netprioidx() when built as module
Date: Fri, 24 Aug 2012 16:01:38 +0200
Message-ID: <1345816904-21745-5-git-send-email-wagi@monom.org>
References: <1345816904-21745-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1345816904-21745-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

The module version of task_netprioidex() checks if net_prio_subsys_id
is valid to indentify when it is okay to access the controller.

Instead relying on the net_prio_subsys_id to be set, make it explicit
with a jump label.

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/net/netprio_cgroup.h | 8 +++++++-
 net/core/netprio_cgroup.c    | 9 +++++++++
 net/core/sock.c              | 4 ++++
 3 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 2719dec..9ff58e4 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -16,7 +16,7 @@
 #include <linux/cgroup.h>
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
-
+#include <linux/jump_label.h>
 
 struct netprio_map {
 	struct rcu_head rcu;
@@ -54,12 +54,18 @@ static inline u32 task_netprioidx(struct task_struct *p)
 
 #elif IS_MODULE(CONFIG_NETPRIO_CGROUP)
 
+extern struct static_key cgroup_netprio_enabled;
+#define netpriocg_enabled static_key_false(&cgroup_netprio_enabled)
+
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	struct cgroup_netprio_state *state;
 	int subsys_id;
 	u32 idx = 0;
 
+	if (!netpriocg_enabled)
+		return 0;
+
 	rcu_read_lock();
 	subsys_id = rcu_dereference_index_check(net_prio_subsys_id,
 						rcu_read_lock_held());
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index c75e3f9..400ab94 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -371,6 +371,10 @@ static int __init init_cgroup_netprio(void)
 	net_prio_subsys_id = net_prio_subsys.subsys_id;
 #endif
 
+#if IS_MODULE(CONFIG_NETPRIO_CGROUP)
+	static_key_slow_inc(&cgroup_netprio_enabled);
+#endif
+
 	register_netdevice_notifier(&netprio_device_notifier);
 
 out:
@@ -391,6 +395,11 @@ static void __exit exit_cgroup_netprio(void)
 	synchronize_rcu();
 #endif
 
+#if IS_MODULE(CONFIG_NETPRIO_CGROUP)
+	static_key_slow_dec(&cgroup_netprio_enabled);
+	rcu_barrier();
+#endif
+
 	rtnl_lock();
 	for_each_netdev(&init_net, dev) {
 		old = rtnl_dereference(dev->priomap);
diff --git a/net/core/sock.c b/net/core/sock.c
index 8106e77..1f119d2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -331,6 +331,10 @@ EXPORT_SYMBOL(__sk_backlog_rcv);
 struct static_key cgroup_cls_enabled = STATIC_KEY_INIT_FALSE;
 EXPORT_SYMBOL_GPL(cgroup_cls_enabled);
 #endif
+#if IS_MODULE(CONFIG_NETPRIO_CGROUP)
+struct static_key cgroup_netprio_enabled = STATIC_KEY_INIT_FALSE;
+EXPORT_SYMBOL_GPL(cgroup_netprio_enabled);
+#endif
 
 #if !defined(CONFIG_NET_CLS_CGROUP)
 int net_cls_subsys_id = -1;
-- 
1.7.12.rc1.16.g05a20c8
