From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 14/16] net: Add sk_bind_dev_if to task_struct
Date: Mon, 27 Jul 2015 12:31:07 -0600
Message-ID: <1438021869-49186-15-git-send-email-dsa@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37908 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012AbbG0SdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:33:15 -0400
Received: by iggf3 with SMTP id f3so89056447igg.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:33:14 -0700 (PDT)
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow tasks to have a default device index for binding sockets. If set
the value is passed to all AF_INET/AF_INET6 sockets when they are created.

The task setting is passed parent to child on fork, but can be set or
changed after task creation using prctl (if task has CAP_NET_ADMIN
permissions). The setting for a socket can be retrieved using prctl().
This option allows an administrator to restrict a task to only send/receive
packets through the specified device. In the case of VRF devices this
option restricts tasks to a specific VRF.

Correlation of the device index to a specific VRF, ie.,
   ifindex --> VRF device --> VRF id
is left to userspace.

Example using VRF devices:
1. vrf1 is created and assigned to table 5
2. eth2 is enslaved to vrf1
3. eth2 is given the address 1.1.1.1/24

$ ip route ls table 5
prohibit default
1.1.1.0/24 dev eth2  scope link
local 1.1.1.1 dev eth2  proto kernel  scope host  src 1.1.1.1

With out setting a VRF context ping, tcp and udp attempts fail. e.g,
$ ping 1.1.1.254
connect: Network is unreachable

After binding the task to the vrf device ping succeeds:
$ ./chvrf -v 1 ping -c1 1.1.1.254
PING 1.1.1.254 (1.1.1.254) 56(84) bytes of data.
64 bytes from 1.1.1.254: icmp_seq=1 ttl=64 time=2.32 ms

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/sched.h      |  3 +++
 include/uapi/linux/prctl.h |  4 ++++
 kernel/fork.c              |  2 ++
 kernel/sys.c               | 35 +++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c         |  1 +
 net/ipv4/route.c           |  4 +++-
 net/ipv6/af_inet6.c        |  1 +
 net/ipv6/route.c           |  2 +-
 8 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 04b5ada460b4..29b336b8a466 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1528,6 +1528,9 @@ struct task_struct {
 	struct files_struct *files;
 /* namespaces */
 	struct nsproxy *nsproxy;
+/* network */
+	/* if set INET/INET6 sockets are bound to given dev index on create */
+	int sk_bind_dev_if;
 /* signal handlers */
 	struct signal_struct *signal;
 	struct sighand_struct *sighand;
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index 31891d9535e2..1ef45195d146 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -190,4 +190,8 @@ struct prctl_mm_map {
 # define PR_FP_MODE_FR		(1 << 0)	/* 64b FP registers */
 # define PR_FP_MODE_FRE		(1 << 1)	/* 32b compatibility */
 
+/* get/set network interface sockets are bound to by default */
+#define PR_SET_SK_BIND_DEV_IF   47
+#define PR_GET_SK_BIND_DEV_IF   48
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index dbd9b8d7b7cc..8b396e77d2bf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -380,6 +380,8 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 	tsk->splice_pipe = NULL;
 	tsk->task_frag.page = NULL;
 
+	tsk->sk_bind_dev_if = orig->sk_bind_dev_if;
+
 	account_kernel_stack(ti, 1);
 
 	return tsk;
diff --git a/kernel/sys.c b/kernel/sys.c
index 259fda25eb6b..59119ac0a0bd 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -52,6 +52,7 @@
 #include <linux/rcupdate.h>
 #include <linux/uidgid.h>
 #include <linux/cred.h>
+#include <linux/netdevice.h>
 
 #include <linux/kmsg_dump.h>
 /* Move somewhere else to avoid recompiling? */
@@ -2267,6 +2268,40 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_GET_FP_MODE:
 		error = GET_FP_MODE(me);
 		break;
+#ifdef CONFIG_NET
+	case PR_SET_SK_BIND_DEV_IF:
+	{
+		struct net_device *dev;
+		int idx = (int) arg2;
+
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (idx) {
+			dev = dev_get_by_index(me->nsproxy->net_ns, idx);
+			if (!dev)
+				return -EINVAL;
+			dev_put(dev);
+		}
+		me->sk_bind_dev_if = idx;
+		break;
+	}
+	case PR_GET_SK_BIND_DEV_IF:
+	{
+		struct task_struct *tsk;
+		int sk_bind_dev_if = -EINVAL;
+
+		rcu_read_lock();
+		tsk = find_task_by_vpid(arg2);
+		if (tsk)
+			sk_bind_dev_if = tsk->sk_bind_dev_if;
+		rcu_read_unlock();
+		if (tsk != me && !capable(CAP_NET_ADMIN))
+			return -EPERM;
+		error = sk_bind_dev_if;
+		break;
+	}
+#endif
 	default:
 		error = -EINVAL;
 		break;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 09c7c1ee307e..0651efa18d39 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -352,6 +352,7 @@ static int inet_create(struct net *net, struct socket *sock, int protocol,
 	sk->sk_destruct	   = inet_sock_destruct;
 	sk->sk_protocol	   = protocol;
 	sk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
+	sk->sk_bound_dev_if = current->sk_bind_dev_if;
 
 	inet->uc_ttl	= -1;
 	inet->mc_loop	= 1;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 47dae001a000..99e7ff5c56ac 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2480,7 +2480,9 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	fl4.daddr = dst;
 	fl4.saddr = src;
 	fl4.flowi4_tos = rtm->rtm_tos;
-	fl4.flowi4_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0;
+	fl4.flowi4_oif = current->sk_bind_dev_if;
+	if (tb[RTA_OIF])
+		fl4.flowi4_oif = nla_get_u32(tb[RTA_OIF]);
 	fl4.flowi4_mark = mark;
 
 	if (iif) {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7bc92ea4ae8f..7728be810982 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -189,6 +189,7 @@ static int inet6_create(struct net *net, struct socket *sock, int protocol,
 	sk->sk_destruct		= inet_sock_destruct;
 	sk->sk_family		= PF_INET6;
 	sk->sk_protocol		= protocol;
+	sk->sk_bound_dev_if	= current->sk_bind_dev_if;
 
 	sk->sk_backlog_rcv	= answer->prot->backlog_rcv;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 54fccf0d705d..8b7fd9eaceb4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3007,7 +3007,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	struct sk_buff *skb;
 	struct rtmsg *rtm;
 	struct flowi6 fl6;
-	int err, iif = 0, oif = 0;
+	int err, iif = 0, oif = current->sk_bind_dev_if;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy);
 	if (err < 0)
-- 
2.3.2 (Apple Git-55)
