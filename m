From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: netlink hooks for 2.5.59 (6/8)
Date: Fri, 31 Jan 2003 10:10:41 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301311006230.31382-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0301311001440.31382-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0301311001440.31382-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 include/linux/security.h      |   39 +++++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c          |    3 ++-
 net/ipv4/netfilter/ip_queue.c |    3 ++-
 net/netlink/af_netlink.c      |    8 +++++++-
 security/capability.c         |   17 +++++++++++++++++
 security/dummy.c              |   18 ++++++++++++++++++
 6 files changed, 85 insertions(+), 3 deletions(-)

diff -urN -X dontdiff linux-2.5.59.w0/include/linux/security.h linux-2.5.59.w1/include/linux/security.h
--- linux-2.5.59.w0/include/linux/security.h	Thu Jan 30 21:36:34 2003
+++ linux-2.5.59.w1/include/linux/security.h	Thu Jan 30 21:36:14 2003
@@ -39,6 +39,8 @@
  */
 extern int cap_capable (struct task_struct *tsk, int cap);
 struct sk_buff;
+extern int cap_netlink_send (struct sk_buff *skb);
+extern int cap_netlink_recv (struct sk_buff *skb);
 extern int cap_ip_decode_options (struct sk_buff *skb, const char *optptr,
 				  unsigned char **pp_ptr);
 extern int cap_ptrace (struct task_struct *parent, struct task_struct *child);
@@ -1002,6 +1004,20 @@
  *	@cap contains the capability <include/linux/capability.h>.
  *	Return 0 if the capability is granted for @tsk.
  *
+ * @netlink_send:
+ *	Save security information for a netlink message so that permission
+ *	checking can be performed when the message is processed.  The security
+ *	information can either be saved using the existing eff_cap field of the
+ *	netlink_skb_parms structure or it can be saved using the skbuff
+ *	lsm_security field.
+ *	@skb contains the sk_buff structure for the netlink message.
+ *	Return 0 if the information was successfully saved.
+ * @netlink_recv:
+ *	Check permission before processing the received netlink message in
+ *	@skb.
+ *	@skb contains the sk_buff structure for the netlink message.
+ *	Return 0 if permission is granted.
+ *
  * @register_security:
  * 	allow module stacking.
  * 	@name contains the name of the security module being stacked.
@@ -1031,6 +1047,9 @@
 	int (*quotactl) (int cmds, int type, int id, struct super_block * sb);
 	int (*quota_on) (struct file * f);
 
+	int (*netlink_send) (struct sk_buff * skb);
+	int (*netlink_recv) (struct sk_buff * skb);
+
 	int (*ip_decode_options) (struct sk_buff * skb,
 				  const char *optptr, unsigned char **pp_ptr);
 
@@ -1275,6 +1294,16 @@
 	return security_ops->quota_on (file);
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
 static inline int security_ip_decode_options(struct sk_buff * skb, 
 					     const char *optptr, 
 					     unsigned char **pp_ptr)
@@ -1887,6 +1916,16 @@
 	return 0;
 }
 
+static inline int security_netlink_send(struct sk_buff * skb)
+{
+	return cap_netlink_send(skb);
+}
+
+static inline int security_netlink_recv(struct sk_buff * skb)
+{
+	return cap_netlink_recv(skb);
+}
+
 static inline int security_ip_decode_options(struct sk_buff * skb, 
 					     const char *optptr, 
 					     unsigned char **pp_ptr)
diff -urN -X dontdiff linux-2.5.59.w0/net/core/rtnetlink.c linux-2.5.59.w1/net/core/rtnetlink.c
--- linux-2.5.59.w0/net/core/rtnetlink.c	Fri Jan 17 19:46:08 2003
+++ linux-2.5.59.w1/net/core/rtnetlink.c	Thu Jan 30 21:36:14 2003
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
+++ linux-2.5.59.w1/net/ipv4/netfilter/ip_queue.c	Thu Jan 30 21:36:14 2003
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
diff -urN -X dontdiff linux-2.5.59.w0/net/netlink/af_netlink.c linux-2.5.59.w1/net/netlink/af_netlink.c
--- linux-2.5.59.w0/net/netlink/af_netlink.c	Tue Dec 10 15:02:03 2002
+++ linux-2.5.59.w1/net/netlink/af_netlink.c	Thu Jan 30 21:36:14 2003
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
--- linux-2.5.59.w0/security/capability.c	Thu Jan 30 21:36:34 2003
+++ linux-2.5.59.w1/security/capability.c	Thu Jan 30 21:36:14 2003
@@ -28,6 +28,19 @@
 		return -EPERM;
 }
 
+int cap_netlink_send (struct sk_buff *skb)
+{
+	NETLINK_CB (skb).eff_cap = current->cap_effective;
+	return 0;
+}
+
+int cap_netlink_recv (struct sk_buff *skb)
+{
+	if (!cap_raised (NETLINK_CB (skb).eff_cap, CAP_NET_ADMIN))
+		return -EPERM;
+	return 0;
+}
+
 int cap_ptrace (struct task_struct *parent, struct task_struct *child)
 {
 	/* Derived from arch/i386/kernel/ptrace.c:sys_ptrace. */
@@ -286,6 +299,8 @@
 EXPORT_SYMBOL(cap_task_post_setuid);
 EXPORT_SYMBOL(cap_task_kmod_set_label);
 EXPORT_SYMBOL(cap_task_reparent_to_init);
+EXPORT_SYMBOL(cap_netlink_send);
+EXPORT_SYMBOL(cap_netlink_recv);
 EXPORT_SYMBOL(cap_ip_decode_options);
 
 #ifdef CONFIG_SECURITY
@@ -297,6 +312,8 @@
 	.capset_check =			cap_capset_check,
 	.capset_set =			cap_capset_set,
 	.capable =			cap_capable,
+	.netlink_send =			cap_netlink_send,
+	.netlink_recv =			cap_netlink_recv,
 
 	.bprm_compute_creds =		cap_bprm_compute_creds,
 	.bprm_set_security =		cap_bprm_set_security,
diff -urN -X dontdiff linux-2.5.59.w0/security/dummy.c linux-2.5.59.w1/security/dummy.c
--- linux-2.5.59.w0/security/dummy.c	Thu Jan 30 21:36:34 2003
+++ linux-2.5.59.w1/security/dummy.c	Thu Jan 30 21:36:14 2003
@@ -85,6 +85,22 @@
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
 static int dummy_bprm_alloc_security (struct linux_binprm *bprm)
 {
 	return 0;
@@ -890,6 +906,8 @@
 	set_to_dummy_if_null(ops, sem_semop);
 	set_to_dummy_if_null(ops, register_security);
 	set_to_dummy_if_null(ops, unregister_security);
+	set_to_dummy_if_null(ops, netlink_send);
+	set_to_dummy_if_null(ops, netlink_recv);	
 	set_to_dummy_if_null(ops, ip_decode_options);
 #ifdef CONFIG_SECURITY_NETWORK
 	set_to_dummy_if_null(ops, socket_create);
