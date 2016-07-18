From: kan.liang@intel.com
Subject: [RFC PATCH 25/30] net/netpolicy: introduce per task net policy
Date: Sun, 17 Jul 2016 23:56:19 -0700
Message-ID: <1468824984-65318-26-git-send-email-kan.liang@intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org, Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:18996 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042AbcGROXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 10:23:32 -0400
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Usually, application as a whole has specific requirement. Applying the
net policy to all sockets one by one in the application is too complex.
This patch introduces per task net policy to address this case.
Once the per task net policy is applied, all the sockets in the
application will apply the same net policy. Also, per task net policy
can be inherited by all children.

The usage of PR_SET_NETPOLICY option is as below.
prctl(PR_SET_NETPOLICY, POLICY_NAME, NULL, NULL, NULL).
It applies per task policy. The policy name must be valid and compatible
with current device policy. Othrewise, it will error out. The task
policy will be set to NET_POLICY_INVALID.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/init_task.h  | 11 +++++++++++
 include/linux/sched.h      |  5 +++++
 include/net/sock.h         |  1 +
 include/uapi/linux/prctl.h |  4 ++++
 kernel/exit.c              |  4 ++++
 kernel/fork.c              |  8 ++++++++
 kernel/sys.c               | 31 +++++++++++++++++++++++++++++++
 net/core/dev.c             | 26 +++++++++++++++++++-------
 net/core/netpolicy.c       | 34 ++++++++++++++++++++++++++++++++++
 net/core/sock.c            | 10 +++++++++-
 net/ipv4/af_inet.c         | 38 +++++++++++++++++++++++++++++---------
 11 files changed, 155 insertions(+), 17 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index f8834f8..eda7ffc 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -183,6 +183,16 @@ extern struct task_group root_task_group;
 # define INIT_KASAN(tsk)
 #endif
 
+#ifdef CONFIG_NETPOLICY
+#define INIT_NETPOLICY(tsk)						\
+	.task_netpolicy.policy = NET_POLICY_INVALID,			\
+	.task_netpolicy.dev = NULL,					\
+	.task_netpolicy.location = ~0,					\
+	.task_netpolicy.rule_queue = ~0,				\
+	.task_netpolicy.ptr = (void *)&tsk,
+#else
+#define INIT_NETPOLICY(tsk)
+#endif
 /*
  *  INIT_TASK is used to set up the first task table, touch at
  * your own risk!. Base=0, limit=0x1fffff (=2MB)
@@ -260,6 +270,7 @@ extern struct task_group root_task_group;
 	INIT_VTIME(tsk)							\
 	INIT_NUMA_BALANCING(tsk)					\
 	INIT_KASAN(tsk)							\
+	INIT_NETPOLICY(tsk)						\
 }
 
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 253538f..2f37989 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -62,6 +62,8 @@ struct sched_param {
 
 #include <asm/processor.h>
 
+#include <linux/netpolicy.h>
+
 #define SCHED_ATTR_SIZE_VER0	48	/* sizeof first published struct */
 
 /*
@@ -1918,6 +1920,9 @@ struct task_struct {
 #ifdef CONFIG_MMU
 	struct task_struct *oom_reaper_list;
 #endif
+#ifdef CONFIG_NETPOLICY
+	struct netpolicy_reg task_netpolicy;
+#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/include/net/sock.h b/include/net/sock.h
index e4721de..c7cc055 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1477,6 +1477,7 @@ void sock_edemux(struct sk_buff *skb);
 #define sock_edemux(skb) sock_efree(skb)
 #endif
 
+void sock_setnetpolicy(struct socket *sock);
 int sock_setsockopt(struct socket *sock, int level, int op,
 		    char __user *optval, unsigned int optlen);
 
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index a8d0759..bc182d2 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -197,4 +197,8 @@ struct prctl_mm_map {
 # define PR_CAP_AMBIENT_LOWER		3
 # define PR_CAP_AMBIENT_CLEAR_ALL	4
 
+/* Control net policy */
+#define PR_SET_NETPOLICY		48
+#define PR_GET_NETPOLICY		49
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/exit.c b/kernel/exit.c
index 9e6e135..8995ec7 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -778,6 +778,10 @@ void do_exit(long code)
 	if (unlikely(current->pi_state_cache))
 		kfree(current->pi_state_cache);
 #endif
+#ifdef CONFIG_NETPOLICY
+	if (is_net_policy_valid(current->task_netpolicy.policy))
+		netpolicy_unregister(&current->task_netpolicy);
+#endif
 	/*
 	 * Make sure we are holding no locks:
 	 */
diff --git a/kernel/fork.c b/kernel/fork.c
index 4a7ec0c..31262d2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1453,6 +1453,14 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->sequential_io_avg	= 0;
 #endif
 
+#ifdef CONFIG_NETPOLICY
+	p->task_netpolicy.location = ~0;
+	p->task_netpolicy.rule_queue = ~0;
+	p->task_netpolicy.ptr = (void *)p;
+	if (is_net_policy_valid(p->task_netpolicy.policy))
+		netpolicy_register(&p->task_netpolicy, p->task_netpolicy.policy);
+#endif
+
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	retval = sched_fork(clone_flags, p);
 	if (retval)
diff --git a/kernel/sys.c b/kernel/sys.c
index 89d5be4..b481a64 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2072,6 +2072,31 @@ static int prctl_get_tid_address(struct task_struct *me, int __user **tid_addr)
 }
 #endif
 
+#ifdef CONFIG_NETPOLICY
+static int prctl_set_netpolicy(struct task_struct *me, int policy)
+{
+	return netpolicy_register(&me->task_netpolicy, policy);
+}
+
+static int prctl_get_netpolicy(struct task_struct *me, unsigned long adr)
+{
+	return put_user(me->task_netpolicy.policy, (int __user *)adr);
+}
+
+#else /* CONFIG_NETPOLICY */
+
+static int prctl_set_netpolicy(struct task_struct *me, int policy)
+{
+	return -EINVAL;
+}
+
+static int prctl_get_netpolicy(struct task_struct *me, unsigned long adr)
+{
+	return -EINVAL;
+}
+
+#endif /* CONFIG_NETPOLICY */
+
 SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
@@ -2270,6 +2295,12 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_GET_FP_MODE:
 		error = GET_FP_MODE(me);
 		break;
+	case PR_SET_NETPOLICY:
+		error = prctl_set_netpolicy(me, arg2);
+		break;
+	case PR_GET_NETPOLICY:
+		error = prctl_get_netpolicy(me, arg2);
+		break;
 	default:
 		error = -EINVAL;
 		break;
diff --git a/net/core/dev.c b/net/core/dev.c
index 6108e3b..f8213d2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3283,13 +3283,25 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 		else {
 #ifdef CONFIG_NETPOLICY
 			queue_index = -1;
-			if (sk && (sk->sk_netpolicy.policy > NET_POLICY_NONE)) {
-				/* There is no device bind to socket when setting policy
-				 * Assign the dev now.
-				 */
-				if (!sk->sk_netpolicy.dev)
-					sk->sk_netpolicy.dev = dev;
-				queue_index = netpolicy_pick_queue(&sk->sk_netpolicy, false);
+			if (dev->netpolicy && sk) {
+				if (is_net_policy_valid(current->task_netpolicy.policy)) {
+					if (!current->task_netpolicy.dev)
+						current->task_netpolicy.dev = dev;
+					if (is_net_policy_valid(sk->sk_netpolicy.policy))
+						netpolicy_unregister(&sk->sk_netpolicy);
+
+					if (current->task_netpolicy.policy > NET_POLICY_NONE)
+						queue_index = netpolicy_pick_queue(&current->task_netpolicy, false);
+				} else {
+					if (sk->sk_netpolicy.policy > NET_POLICY_NONE) {
+						/* There is no device bind to socket when setting policy
+						 * Assign the dev now.
+						 */
+						if (!sk->sk_netpolicy.dev)
+							sk->sk_netpolicy.dev = dev;
+						queue_index = netpolicy_pick_queue(&sk->sk_netpolicy, false);
+					}
+				}
 			}
 			if (queue_index < 0)
 #endif
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 0ed3080..9e14137 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -24,6 +24,35 @@
  *	  is too difficult for users.
  * 	So, it is a big challenge to get good network performance.
  *
+ * NET policy supports four policies per device, and three policies per task
+ * and per socket. For using NET policy, the device policy must be set in
+ * advance. The task policy or socket policy must be compatible with device
+ * policy.
+ *
+ * BULK policy		This policy is designed for high throughput. It can be
+ *			applied to either device policy or task/socket policy.
+ *			If it is applied to device policy, the only compatible
+ *			task/socket policy is BULK policy itself.
+ * CPU policy		This policy is designed for high throughput and lower
+ *			CPU utilization. It can be applied to either device
+ *			policy or task/socket policy. If it is applied to
+ *			device policy, the only compatible task/socket policy
+ *			is CPU policy itself.
+ * LATENCY policy	This policy is designed for low latency. It can be
+ *			applied to either device policy or task/socket policy.
+ *			If it is applied to device policy, the only compatible
+ *			task/socket policy is LATENCY policy itself.
+ * MIX policy		This policy can only be applied to device policy. It
+ *			is compatible with BULK and LATENCY policy. This
+ *			policy is designed for the case which miscellaneous
+ *			types of workload running on the device.
+ *
+ * The device policy changes the system configuration and reorganize the
+ * resource on the device, but it does not change the packets behavior.
+ * The task policy and socket policy redirect the packets to get good
+ * performance. If both task policy and socket policy are set in the same
+ * task, task policy will be applied. The task policy can also be inherited by
+ * children.
  */
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -360,6 +389,11 @@ int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx)
 		goto err;
 	}
 
+	/* task policy should be the same as socket policy */
+	if (is_net_policy_valid(current->task_netpolicy.policy) &&
+	    (current->task_netpolicy.policy != reg->policy))
+		return -EINVAL;
+
 	old_record = netpolicy_record_search(ptr_id);
 	if (!old_record) {
 		pr_warn("NETPOLICY: doesn't registered. Remove net policy settings!\n");
diff --git a/net/core/sock.c b/net/core/sock.c
index 849274a..4d47a89 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1005,7 +1005,13 @@ set_rcvbuf:
 
 #ifdef CONFIG_NETPOLICY
 	case SO_NETPOLICY:
-		ret = netpolicy_register(&sk->sk_netpolicy, val);
+		if (is_net_policy_valid(current->task_netpolicy.policy) &&
+		    (current->task_netpolicy.policy != val)) {
+			printk_ratelimited(KERN_WARNING "NETPOLICY: new policy is not compatible with task netpolicy\n");
+			ret = -EINVAL;
+		} else {
+			ret = netpolicy_register(&sk->sk_netpolicy, val);
+		}
 		break;
 #endif
 	default:
@@ -1624,6 +1630,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_netpolicy.ptr = (void *)newsk;
 		newsk->sk_netpolicy.location = ~0;
 		newsk->sk_netpolicy.rule_queue = ~0;
+		if (is_net_policy_valid(current->task_netpolicy.policy))
+			newsk->sk_netpolicy.policy = NET_POLICY_INVALID;
 		if (is_net_policy_valid(newsk->sk_netpolicy.policy))
 			netpolicy_register(&newsk->sk_netpolicy, newsk->sk_netpolicy.policy);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 889ffdc..3727240 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -765,16 +765,33 @@ static void sock_netpolicy_manage_flow(struct sock *sk, struct msghdr *msg)
 	int queue_index;
 	struct netpolicy_flow_spec flow;
 
-	if (!sk->sk_netpolicy.dev)
-		return;
+	if (is_net_policy_valid(current->task_netpolicy.policy)) {
+		if (current->task_netpolicy.policy == NET_POLICY_NONE)
+			return;
 
-	if (sk->sk_netpolicy.policy <= NET_POLICY_NONE)
-		return;
+		if ((!sk->sk_netpolicy.dev) && (!current->task_netpolicy.dev))
+			return;
 
-	queue_index = netpolicy_pick_queue(&sk->sk_netpolicy, true);
-	if ((queue_index < 0) ||
-	    (queue_index == sk->sk_netpolicy.rule_queue))
-		return;
+		if (!current->task_netpolicy.dev)
+			current->task_netpolicy.dev = sk->sk_netpolicy.dev;
+		if (is_net_policy_valid(sk->sk_netpolicy.policy))
+			netpolicy_unregister(&sk->sk_netpolicy);
+		queue_index = netpolicy_pick_queue(&current->task_netpolicy, true);
+		if ((queue_index < 0) ||
+		    (queue_index == current->task_netpolicy.rule_queue))
+			return;
+	} else {
+		if (!sk->sk_netpolicy.dev)
+			return;
+
+		if (sk->sk_netpolicy.policy <= NET_POLICY_NONE)
+			return;
+
+		queue_index = netpolicy_pick_queue(&sk->sk_netpolicy, true);
+		if ((queue_index < 0) ||
+		    (queue_index == sk->sk_netpolicy.rule_queue))
+			return;
+	}
 
 	memset(&flow, 0, sizeof(flow));
 	/* TODO: need to change here and add more protocol support */
@@ -803,7 +820,10 @@ static void sock_netpolicy_manage_flow(struct sock *sk, struct msghdr *msg)
 	} else {
 		return;
 	}
-	netpolicy_set_rules(&sk->sk_netpolicy, queue_index, &flow);
+	if (current->task_netpolicy.policy > NET_POLICY_NONE)
+		netpolicy_set_rules(&current->task_netpolicy, queue_index, &flow);
+	else
+		netpolicy_set_rules(&sk->sk_netpolicy, queue_index, &flow);
 
 #endif
 }
-- 
2.5.5
