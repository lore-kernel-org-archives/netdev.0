From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: netlink hooks for 2.5.42 (5/7)
Date: Wed, 16 Oct 2002 00:39:34 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210160028000.27676-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN -X dontdiff linux-2.5.42.w0/include/linux/security.h linux-2.5.42.w1/include/linux/security.h
--- linux-2.5.42.w0/include/linux/security.h	Tue Oct 15 21:03:06 2002
+++ linux-2.5.42.w1/include/linux/security.h	Tue Oct 15 21:03:31 2002
@@ -836,6 +836,20 @@
  *	be generated and transmitted to the sender.  The @pp_ptr parameter may
  *	be used to point to the offending option parameter.
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
  * @ptrace:
  *	Check permission before allowing the @parent process to trace the
  *	@child process.
@@ -1094,6 +1108,9 @@
 	int (*ip_decode_options) (struct sk_buff * skb,
 				  const char *optptr, unsigned char **pp_ptr);
 
+	int (*netlink_send) (struct sk_buff * skb);
+	int (*netlink_recv) (struct sk_buff * skb);
+
 	int (*ipc_permission) (struct kern_ipc_perm * ipcp, short flag);
 
 	int (*msg_queue_alloc_security) (struct msg_queue * msq);
diff -urN -X dontdiff linux-2.5.42.w0/net/core/rtnetlink.c linux-2.5.42.w1/net/core/rtnetlink.c
--- linux-2.5.42.w0/net/core/rtnetlink.c	Fri Aug  2 07:17:32 2002
+++ linux-2.5.42.w1/net/core/rtnetlink.c	Tue Oct 15 21:03:31 2002
@@ -316,7 +316,7 @@
 	sz_idx = type>>2;
 	kind = type&3;
 
-	if (kind != 2 && !cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN)) {
+	if (kind != 2 && security_ops->netlink_recv(skb)) {
 		*errp = -EPERM;
 		return -1;
 	}
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/netfilter/ip_queue.c linux-2.5.42.w1/net/ipv4/netfilter/ip_queue.c
--- linux-2.5.42.w0/net/ipv4/netfilter/ip_queue.c	Sun Aug 11 12:20:40 2002
+++ linux-2.5.42.w1/net/ipv4/netfilter/ip_queue.c	Tue Oct 15 21:03:31 2002
@@ -496,7 +496,7 @@
 	if (type <= IPQM_BASE)
 		return;
 		
-	if(!cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN))
+	if (security_ops->netlink_recv(skb))
 		RCV_SKB_FAIL(-EPERM);
 	
 	write_lock_bh(&queue_lock);
diff -urN -X dontdiff linux-2.5.42.w0/net/netlink/af_netlink.c linux-2.5.42.w1/net/netlink/af_netlink.c
--- linux-2.5.42.w0/net/netlink/af_netlink.c	Sun Aug 11 12:20:40 2002
+++ linux-2.5.42.w1/net/netlink/af_netlink.c	Tue Oct 15 21:03:31 2002
@@ -621,7 +621,12 @@
 	   check them, when this message will be delivered
 	   to corresponding kernel module.   --ANK (980802)
 	 */
-	NETLINK_CB(skb).eff_cap = current->cap_effective;
+
+	err = security_ops->netlink_send(skb);
+	if (err) {
+		kfree_skb(skb);
+		goto out;
+	}
 
 	err = -EFAULT;
 	if (memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len)) {
diff -urN -X dontdiff linux-2.5.42.w0/security/capability.c linux-2.5.42.w1/security/capability.c
--- linux-2.5.42.w0/security/capability.c	Tue Oct 15 21:03:06 2002
+++ linux-2.5.42.w1/security/capability.c	Tue Oct 15 21:03:31 2002
@@ -872,6 +872,19 @@
 	return 0;
 }
 
+static int cap_netlink_send (struct sk_buff *skb)
+{
+	NETLINK_CB (skb).eff_cap = current->cap_effective;
+	return 0;
+}
+
+static int cap_netlink_recv (struct sk_buff *skb)
+{
+	if (!cap_raised (NETLINK_CB (skb).eff_cap, CAP_NET_ADMIN))
+		return -EPERM;
+	return 0;
+}
+
 static int cap_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -1006,6 +1019,9 @@
 	.ip_decapsulate =		cap_ip_decapsulate,
 	.ip_decode_options =		cap_ip_decode_options,
 
+	.netlink_send =			cap_netlink_send,
+	.netlink_recv =			cap_netlink_recv,
+
 	.ipc_permission =		cap_ipc_permission,
 
 	.msg_queue_alloc_security =	cap_msg_queue_alloc_security,
diff -urN -X dontdiff linux-2.5.42.w0/security/dummy.c linux-2.5.42.w1/security/dummy.c
--- linux-2.5.42.w0/security/dummy.c	Tue Oct 15 21:03:06 2002
+++ linux-2.5.42.w1/security/dummy.c	Tue Oct 15 21:03:31 2002
@@ -689,6 +689,22 @@
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
 static int dummy_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -823,6 +839,9 @@
 	.ip_decapsulate =		dummy_ip_decapsulate,
 	.ip_decode_options =		dummy_ip_decode_options,
 
+	.netlink_send =			dummy_netlink_send,
+	.netlink_recv =			dummy_netlink_recv,
+
 	.ipc_permission =		dummy_ipc_permission,
 	
 	.msg_queue_alloc_security =	dummy_msg_queue_alloc_security,
