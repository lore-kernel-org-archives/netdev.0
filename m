From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] LSM networking update: netlink hooks (5/5)
Date: Fri, 7 Feb 2003 02:23:58 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302070221120.2174-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0302070218060.2174-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@wirex.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0302070218060.2174-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 include/linux/security.h       |   65 +++++++++++++++++++++++++++++++++++++----
 net/core/rtnetlink.c           |    3 +
 net/ipv4/netfilter/ip_queue.c  |    3 +
 net/ipv4/xfrm_user.c           |    3 +
 net/ipv6/netfilter/ip6_queue.c |    6 +--
 net/netlink/af_netlink.c       |    8 ++++-
 security/capability.c          |    2 +
 security/dummy.c               |   18 +++++++++++
 8 files changed, 95 insertions(+), 13 deletions(-)

diff -urN -X dontdiff linux-2.5.59.w0/include/linux/security.h linux-2.5.59.w1/include/linux/security.h
--- linux-2.5.59.w0/include/linux/security.h	Fri Feb  7 01:34:42 2003
+++ linux-2.5.59.w1/include/linux/security.h	Fri Feb  7 01:34:49 2003
@@ -31,7 +31,8 @@
 #include <linux/shm.h>
 #include <linux/msg.h>
 #include <linux/sched.h>
-
+#include <linux/skbuff.h>
+#include <linux/netlink.h>
 
 /*
  * These functions are in security/capability.c and are used
@@ -48,6 +49,20 @@
 extern void cap_task_kmod_set_label (void);
 extern void cap_task_reparent_to_init (struct task_struct *p);
 
+static inline int cap_netlink_send (struct sk_buff *skb)
+{
+	NETLINK_CB (skb).eff_cap = current->cap_effective;
+	return 0;
+}
+
+static inline int cap_netlink_recv (struct sk_buff *skb)
+{
+	if (!cap_raised (NETLINK_CB (skb).eff_cap, CAP_NET_ADMIN))
+		return -EPERM;
+	return 0;
+}
+
+
 /*
  * Values used in the task_security_ops calls
  */
@@ -64,11 +79,6 @@
 #define LSM_SETID_FS	8
 
 /* forward declares to avoid warnings */
-struct sock;
-struct socket;
-struct sockaddr;
-struct msghdr;
-struct sk_buff;
 struct nfsctl_arg;
 struct sched_param;
 struct swap_info_struct;
@@ -588,6 +598,21 @@
  * 	is being reparented to the init task.
  *	@p contains the task_struct for the kernel thread.
  *
+ * Security hooks for Netlink messaging.
+ *
+ * @netlink_send:
+ *	Save security information for a netlink message so that permission
+ *	checking can be performed when the message is processed.  The security
+ *	information can be saved using the eff_cap field of the
+ *      netlink_skb_parms structure.
+ *	@skb contains the sk_buff structure for the netlink message.
+ *	Return 0 if the information was successfully saved.
+ * @netlink_recv:
+ *	Check permission before processing the received netlink message in
+ *	@skb.
+ *	@skb contains the sk_buff structure for the netlink message.
+ *	Return 0 if permission is granted.
+ *
  * Security hooks for Unix domain networking.
  *
  * @unix_stream_connect:
@@ -1077,6 +1102,9 @@
 	int (*sem_semop) (struct sem_array * sma, 
 			  struct sembuf * sops, unsigned nsops, int alter);
 
+	int (*netlink_send) (struct sk_buff * skb);
+	int (*netlink_recv) (struct sk_buff * skb);
+
 	/* allow module stacking */
 	int (*register_security) (const char *name,
 	                          struct security_operations *ops);
@@ -1701,6 +1729,16 @@
 	return security_ops->sem_semop(sma, sops, nsops, alter);
 }
 
+static inline int security_netlink_send(struct sk_buff * skb)
+{
+	return security_ops->netlink_send(skb);
+}
+
+static inline int security_netlink_recv(struct sk_buff * skb)
+{
+	return security_ops->netlink_recv(skb);
+}
+
 /* prototypes */
 extern int security_scaffolding_startup	(void);
 extern int register_security	(struct security_operations *ops);
@@ -2262,6 +2300,21 @@
 	return 0;
 }
 
+/*
+ * The netlink capability defaults need to be used inline by default
+ * (rather than hooking into the capability module) to reduce overhead
+ * in the networking code.
+ */
+static inline int security_netlink_send (struct sk_buff *skb)
+{
+	return cap_netlink_send (skb);
+}
+
+static inline int security_netlink_recv (struct sk_buff *skb)
+{
+	return cap_netlink_recv (skb);
+}
+
 #endif	/* CONFIG_SECURITY */
 
 #ifdef CONFIG_SECURITY_NETWORK
diff -urN -X dontdiff linux-2.5.59.w0/net/core/rtnetlink.c linux-2.5.59.w1/net/core/rtnetlink.c
--- linux-2.5.59.w0/net/core/rtnetlink.c	Fri Jan 17 19:46:08 2003
+++ linux-2.5.59.w1/net/core/rtnetlink.c	Fri Feb  7 01:34:49 2003
@@ -34,6 +34,7 @@
 #include <linux/capability.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
+#include <linux/security.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -363,7 +364,7 @@
 	sz_idx = type>>2;
 	kind = type&3;
 
-	if (kind != 2 && !cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN)) {
+	if (kind != 2 && security_netlink_recv(skb)) {
 		*errp = -EPERM;
 		return -1;
 	}
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/netfilter/ip_queue.c linux-2.5.59.w1/net/ipv4/netfilter/ip_queue.c
--- linux-2.5.59.w0/net/ipv4/netfilter/ip_queue.c	Sun Aug 11 12:20:40 2002
+++ linux-2.5.59.w1/net/ipv4/netfilter/ip_queue.c	Fri Feb  7 01:34:49 2003
@@ -26,6 +26,7 @@
 #include <linux/brlock.h>
 #include <linux/sysctl.h>
 #include <linux/proc_fs.h>
+#include <linux/security.h>
 #include <net/sock.h>
 #include <net/route.h>
 
@@ -496,7 +497,7 @@
 	if (type <= IPQM_BASE)
 		return;
 		
-	if(!cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN))
+	if (security_netlink_recv(skb))
 		RCV_SKB_FAIL(-EPERM);
 	
 	write_lock_bh(&queue_lock);
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/xfrm_user.c linux-2.5.59.w1/net/ipv4/xfrm_user.c
--- linux-2.5.59.w0/net/ipv4/xfrm_user.c	Sun Nov 24 12:27:57 2002
+++ linux-2.5.59.w1/net/ipv4/xfrm_user.c	Fri Feb  7 01:34:49 2003
@@ -16,6 +16,7 @@
 #include <linux/pfkeyv2.h>
 #include <linux/ipsec.h>
 #include <linux/init.h>
+#include <linux/security.h>
 #include <net/sock.h>
 #include <net/xfrm.h>
 
@@ -772,7 +773,7 @@
 	link = &xfrm_dispatch[type];
 
 	/* All operations require privileges, even GET */
-	if (!cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN)) {
+	if (security_netlink_recv(skb)) {
 		*errp = -EPERM;
 		return -1;
 	}
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv6/netfilter/ip6_queue.c linux-2.5.59.w1/net/ipv6/netfilter/ip6_queue.c
--- linux-2.5.59.w0/net/ipv6/netfilter/ip6_queue.c	Wed Oct  9 22:39:39 2002
+++ linux-2.5.59.w1/net/ipv6/netfilter/ip6_queue.c	Fri Feb  7 01:34:49 2003
@@ -538,10 +538,10 @@
 		
 	if (type <= IPQM_BASE)
 		return;
-		
-	if(!cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN))
-		RCV_SKB_FAIL(-EPERM);
 	
+	if (security_netlink_recv(skb))
+		RCV_SKB_FAIL(-EPERM);	
+
 	write_lock_bh(&queue_lock);
 	
 	if (peer_pid) {
diff -urN -X dontdiff linux-2.5.59.w0/net/netlink/af_netlink.c linux-2.5.59.w1/net/netlink/af_netlink.c
--- linux-2.5.59.w0/net/netlink/af_netlink.c	Tue Dec 10 15:02:03 2002
+++ linux-2.5.59.w1/net/netlink/af_netlink.c	Fri Feb  7 01:34:49 2003
@@ -42,6 +42,7 @@
 #include <linux/proc_fs.h>
 #include <linux/smp_lock.h>
 #include <linux/notifier.h>
+#include <linux/security.h>
 #include <net/sock.h>
 #include <net/scm.h>
 
@@ -636,7 +637,12 @@
 	   check them, when this message will be delivered
 	   to corresponding kernel module.   --ANK (980802)
 	 */
-	NETLINK_CB(skb).eff_cap = current->cap_effective;
+
+	err = security_netlink_send(skb);
+	if (err) {
+		kfree_skb(skb);
+		goto out;
+	}
 
 	err = -EFAULT;
 	if (memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len)) {
diff -urN -X dontdiff linux-2.5.59.w0/security/capability.c linux-2.5.59.w1/security/capability.c
--- linux-2.5.59.w0/security/capability.c	Tue Dec 10 15:02:03 2002
+++ linux-2.5.59.w1/security/capability.c	Fri Feb  7 01:34:49 2003
@@ -286,6 +286,8 @@
 	.capset_check =			cap_capset_check,
 	.capset_set =			cap_capset_set,
 	.capable =			cap_capable,
+	.netlink_send =			cap_netlink_send,
+	.netlink_recv =			cap_netlink_recv,
 
 	.bprm_compute_creds =		cap_bprm_compute_creds,
 	.bprm_set_security =		cap_bprm_set_security,
diff -urN -X dontdiff linux-2.5.59.w0/security/dummy.c linux-2.5.59.w1/security/dummy.c
--- linux-2.5.59.w0/security/dummy.c	Fri Feb  7 01:34:42 2003
+++ linux-2.5.59.w1/security/dummy.c	Fri Feb  7 01:34:49 2003
@@ -597,6 +597,22 @@
 	return 0;
 }
 
+static int dummy_netlink_send (struct sk_buff *skb)
+{
+	if (current->euid == 0)
+		cap_raise (NETLINK_CB (skb).eff_cap, CAP_NET_ADMIN);
+	else
+		NETLINK_CB (skb).eff_cap = 0;
+	return 0;
+}
+
+static int dummy_netlink_recv (struct sk_buff *skb)
+{
+	if (!cap_raised (NETLINK_CB (skb).eff_cap, CAP_NET_ADMIN))
+		return -EPERM;
+	return 0;
+}
+
 #ifdef CONFIG_SECURITY_NETWORK
 static int dummy_unix_stream_connect (struct socket *sock,
 				      struct socket *other,
@@ -819,6 +835,8 @@
 	set_to_dummy_if_null(ops, sem_associate);
 	set_to_dummy_if_null(ops, sem_semctl);
 	set_to_dummy_if_null(ops, sem_semop);
+	set_to_dummy_if_null(ops, netlink_send);
+	set_to_dummy_if_null(ops, netlink_recv);
 	set_to_dummy_if_null(ops, register_security);
 	set_to_dummy_if_null(ops, unregister_security);
 #ifdef CONFIG_SECURITY_NETWORK
