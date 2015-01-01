From: kan.liang@intel.com
Subject: [RFC V2 PATCH 20/25] net/netpolicy: introduce per task net policy
Date: Wed, 31 Dec 2014 20:39:09 -0500
Message-ID: <1420076354-4861-21-git-send-email-kan.liang@intel.com>
References: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28525 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965509AbcHDTNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 15:13:05 -0400
In-Reply-To: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
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
 include/linux/init_task.h  |  9 +++++++++
 include/linux/sched.h      |  5 +++++
 include/net/sock.h         | 12 +++++++++++-
 include/uapi/linux/prctl.h |  4 ++++
 kernel/exit.c              |  4 ++++
 kernel/fork.c              |  6 ++++++
 kernel/sys.c               | 31 +++++++++++++++++++++++++++++++
 net/core/netpolicy.c       | 35 +++++++++++++++++++++++++++++++++++
 net/core/sock.c            | 10 +++++++++-
 net/ipv4/af_inet.c         |  7 +++++--
 10 files changed, 119 insertions(+), 4 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index f8834f8..133d1cb 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -183,6 +183,14 @@ extern struct task_group root_task_group;
 # define INIT_KASAN(tsk)
 #endif
 
+#ifdef CONFIG_NETPOLICY
+#define INIT_NETPOLICY(tsk)						\
+	.task_netpolicy.policy = NET_POLICY_INVALID,			\
+	.task_netpolicy.dev = NULL,					\
+	.task_netpolicy.ptr = (void *)&tsk,
+#else
+#define INIT_NETPOLICY(tsk)
+#endif
 /*
  *  INIT_TASK is used to set up the first task table, touch at
  * your own risk!. Base=0, limit=0x1fffff (=2MB)
@@ -260,6 +268,7 @@ extern struct task_group root_task_group;
 	INIT_VTIME(tsk)							\
 	INIT_NUMA_BALANCING(tsk)					\
 	INIT_KASAN(tsk)							\
+	INIT_NETPOLICY(tsk)						\
 }
 
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index d99218a..2cfcdbd 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -62,6 +62,8 @@ struct sched_param {
 
 #include <asm/processor.h>
 
+#include <linux/netpolicy.h>
+
 #define SCHED_ATTR_SIZE_VER0	48	/* sizeof first published struct */
 
 /*
@@ -1919,6 +1921,9 @@ struct task_struct {
 #ifdef CONFIG_MMU
 	struct task_struct *oom_reaper_list;
 #endif
+#ifdef CONFIG_NETPOLICY
+	struct netpolicy_instance task_netpolicy;
+#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/include/net/sock.h b/include/net/sock.h
index 6219434..e4f023c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1477,6 +1477,7 @@ void sock_edemux(struct sk_buff *skb);
 #define sock_edemux(skb) sock_efree(skb)
 #endif
 
+void sock_setnetpolicy(struct socket *sock);
 int sock_setsockopt(struct socket *sock, int level, int op,
 		    char __user *optval, unsigned int optlen);
 
@@ -2273,10 +2274,19 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
-/* Return netpolicy instance information from socket. */
+/* Return netpolicy instance information from either task or socket.
+ * If both task and socket have netpolicy instance information,
+ * using task's and unregistering socket's. Because task policy is
+ * dominant policy
+ */
 static inline struct netpolicy_instance *netpolicy_find_instance(struct sock *sk)
 {
 #ifdef CONFIG_NETPOLICY
+	if (is_net_policy_valid(current->task_netpolicy.policy)) {
+		if (is_net_policy_valid(sk->sk_netpolicy.policy))
+			netpolicy_unregister(&sk->sk_netpolicy);
+		return &current->task_netpolicy;
+	}
 	if (is_net_policy_valid(sk->sk_netpolicy.policy))
 		return &sk->sk_netpolicy;
 #endif
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
index 84ae830..4abd921 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -858,6 +858,10 @@ void do_exit(long code)
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
index de21f25..03754ae 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1453,6 +1453,12 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->sequential_io_avg	= 0;
 #endif
 
+#ifdef CONFIG_NETPOLICY
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
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 89c65d9..4b844d8 100644
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
@@ -399,6 +428,12 @@ static inline bool policy_validate(struct netpolicy_instance *instance)
 			policy_name[instance->policy]);
 		return false;
 	}
+
+	/* task policy is dominant policy */
+	if (is_net_policy_valid(current->task_netpolicy.policy) &&
+	    (current->task_netpolicy.policy != instance->policy))
+		return false;
+
 	return true;
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 77f226b..117cff7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1006,7 +1006,13 @@ set_rcvbuf:
 
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
@@ -1621,6 +1627,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 
 #ifdef CONFIG_NETPOLICY
 		newsk->sk_netpolicy.ptr = (void *)newsk;
+		if (is_net_policy_valid(current->task_netpolicy.policy))
+			newsk->sk_netpolicy.policy = NET_POLICY_INVALID;
 		if (is_net_policy_valid(newsk->sk_netpolicy.policy))
 			netpolicy_register(&newsk->sk_netpolicy, newsk->sk_netpolicy.policy);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f536da3..b26e606 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -771,8 +771,11 @@ static void sock_netpolicy_manage_flow(struct sock *sk, struct msghdr *msg)
 	if (!instance)
 		return;
 
-	if (!instance->dev)
-		return;
+	if (!instance->dev) {
+		if (!sk->sk_netpolicy.dev)
+			return;
+		instance->dev = sk->sk_netpolicy.dev;
+	}
 
 	flow = &instance->flow;
 	/* TODO: need to change here and add more protocol support */
-- 
2.5.5
