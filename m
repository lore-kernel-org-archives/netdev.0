From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: ipv4 hooks for 2.5.42 (4/7)
Date: Wed, 16 Oct 2002 00:38:21 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210160028290.27676-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN -X dontdiff linux-2.5.42.w0/include/linux/ip.h linux-2.5.42.w1/include/linux/ip.h
--- linux-2.5.42.w0/include/linux/ip.h	Fri Aug  2 07:16:17 2002
+++ linux-2.5.42.w1/include/linux/ip.h	Tue Oct 15 20:58:32 2002
@@ -58,6 +58,7 @@
 #define IPOPT_SEC	(2 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_LSRR	(3 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_TIMESTAMP	(4 |IPOPT_MEASUREMENT)
+#define IPOPT_CIPSO	(6 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_RR	(7 |IPOPT_CONTROL)
 #define IPOPT_SID	(8 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_SSRR	(9 |IPOPT_CONTROL|IPOPT_COPY)
diff -urN -X dontdiff linux-2.5.42.w0/include/linux/security.h linux-2.5.42.w1/include/linux/security.h
--- linux-2.5.42.w0/include/linux/security.h	Tue Oct 15 20:58:10 2002
+++ linux-2.5.42.w1/include/linux/security.h	Tue Oct 15 20:58:32 2002
@@ -794,6 +794,48 @@
  *	@skb contains the incoming network data.
  * 	Return 0 if permission is granted.
  *
+ * IPv4 networking hooks.
+ *
+ * @ip_fragment:
+ *	This is called for each fragment generated when an outgoing packet is
+ *	being fragmented, and may be used to copy security attributes from the
+ *	original packet to each fragment.
+ *	@newskb contains the newly created fragment.
+ *	@oldskb contains the original packet being fragmented.
+ * @ip_defragment:
+ *	This hook is called when an incoming fragment is about to be inserted
+ *	into a reassembly queue.  It's purpose is to enable the validation of
+ *	security attributes for each fragment.  An LSM module using this hook
+ *	will likely need to maintain its own fragment queue information, handle
+ *	fragment expiration and implement DoS countermeasures.
+ *	@skb contains the incoming fragment.
+ *	Returns 0 on success.
+ * @ip_encapsulate:
+ *	This hook is called when an IP packet is encapsulated, and may be used
+ *	to update security attributes prior to reprocessing via the local_out
+ *	or forward hooks.
+ *	@skb contains the encapsulated packet.
+ * @ip_decapsulate:
+ *	This hook is called when a packet is decapsulated, and may be used to
+ *	process security attributes at each level of encapsulation.  An example
+ *	of this would be keeping track of nested security associations for an
+ *	incoming packet.
+ *	@skb contains the decapsulated packet.
+ * @ip_decode_options:
+ *	This hook is used for processing IP security options at the network
+ *	layer when labeled networking (e.g. CIPSO) is implemented.
+ *	For outgoing packets, IP options passed down from the application or
+ *	transport layers may be verified here prior the packet being built.
+ *	For incoming packets, IP options may be verified and their values
+ *	recorded via the &sk_buff security blob for later processing.
+ *	@skb contains the &sk_buff containing IP packet (usually NULL for outgoing).
+ *	@optptr contains the &ip_options structure.
+ *	@pp_ptr contains the parameter problem pointer.
+ *	Returns 0 on success.
+ *	A non-zero return value will cause an ICMP parameter problem message to
+ *	be generated and transmitted to the sender.  The @pp_ptr parameter may
+ *	be used to point to the offending option parameter.
+ *
  * @ptrace:
  *	Check permission before allowing the @parent process to trace the
  *	@child process.
@@ -1044,6 +1086,14 @@
 	void (*socket_sock_free_security) (struct sock * sk);
 	int (*socket_sock_rcv_skb) (struct sock * sk, struct sk_buff * skb);
 
+	void (*ip_fragment) (struct sk_buff * newskb,
+			     const struct sk_buff * oldskb);
+	int (*ip_defragment) (struct sk_buff * skb);
+	void (*ip_encapsulate) (struct sk_buff * skb);
+	void (*ip_decapsulate) (struct sk_buff * skb);
+	int (*ip_decode_options) (struct sk_buff * skb,
+				  const char *optptr, unsigned char **pp_ptr);
+
 	int (*ipc_permission) (struct kern_ipc_perm * ipcp, short flag);
 
 	int (*msg_queue_alloc_security) (struct msg_queue * msq);
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/ip_fragment.c linux-2.5.42.w1/net/ipv4/ip_fragment.c
--- linux-2.5.42.w0/net/ipv4/ip_fragment.c	Fri Aug  2 07:16:16 2002
+++ linux-2.5.42.w1/net/ipv4/ip_fragment.c	Tue Oct 15 20:58:32 2002
@@ -37,6 +37,7 @@
 #include <linux/udp.h>
 #include <linux/inet.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/security.h>
 
 /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
  * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
@@ -372,7 +373,11 @@
 {
 	struct sk_buff *prev, *next;
 	int flags, offset;
-	int ihl, end;
+	int ihl, end, ret;
+
+	ret = security_ops->ip_defragment(skb);
+	if (ret)
+		goto err;
 
 	if (qp->last_in & COMPLETE)
 		goto err;
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/ip_gre.c linux-2.5.42.w1/net/ipv4/ip_gre.c
--- linux-2.5.42.w0/net/ipv4/ip_gre.c	Sat Oct 12 15:09:44 2002
+++ linux-2.5.42.w1/net/ipv4/ip_gre.c	Tue Oct 15 20:58:32 2002
@@ -653,6 +653,7 @@
 		skb->nf_debug = 0;
 #endif
 #endif
+		security_ops->ip_decapsulate(skb);
 		ipgre_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
 		read_unlock(&ipgre_lock);
@@ -885,6 +886,7 @@
 	skb->nf_debug = 0;
 #endif
 #endif
+	security_ops->ip_encapsulate(skb);
 
 	IPTUNNEL_XMIT();
 	tunnel->recursion--;
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/ip_options.c linux-2.5.42.w1/net/ipv4/ip_options.c
--- linux-2.5.42.w0/net/ipv4/ip_options.c	Tue Sep 24 19:22:50 2002
+++ linux-2.5.42.w1/net/ipv4/ip_options.c	Tue Oct 15 20:58:32 2002
@@ -433,7 +433,11 @@
 				opt->router_alert = optptr - iph;
 			break;
 		      case IPOPT_SEC:
+		      case IPOPT_CIPSO:
 		      case IPOPT_SID:
+		      	if (security_ops->ip_decode_options(skb, optptr, &pp_ptr))
+				goto error;
+			break;
 		      default:
 			if (!skb && !capable(CAP_NET_RAW)) {
 				pp_ptr = optptr;
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/ip_output.c linux-2.5.42.w1/net/ipv4/ip_output.c
--- linux-2.5.42.w0/net/ipv4/ip_output.c	Wed Oct  9 22:39:39 2002
+++ linux-2.5.42.w1/net/ipv4/ip_output.c	Tue Oct 15 20:58:32 2002
@@ -898,6 +898,7 @@
 		skb2->nf_debug = skb->nf_debug;
 #endif
 #endif
+		security_ops->ip_fragment(skb2, skb);
 
 		/*
 		 *	Put this fragment into the sending queue.
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/ipip.c linux-2.5.42.w1/net/ipv4/ipip.c
--- linux-2.5.42.w0/net/ipv4/ipip.c	Sat Oct 12 15:09:44 2002
+++ linux-2.5.42.w1/net/ipv4/ipip.c	Tue Oct 15 20:58:32 2002
@@ -500,6 +500,7 @@
 		skb->nf_debug = 0;
 #endif
 #endif
+		security_ops->ip_decapsulate(skb);
 		ipip_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
 		read_unlock(&ipip_lock);
@@ -652,6 +653,8 @@
 #endif
 #endif
 
+	security_ops->ip_encapsulate(skb);
+
 	IPTUNNEL_XMIT();
 	tunnel->recursion--;
 	return 0;
diff -urN -X dontdiff linux-2.5.42.w0/net/ipv4/ipmr.c linux-2.5.42.w1/net/ipv4/ipmr.c
--- linux-2.5.42.w0/net/ipv4/ipmr.c	Sat Oct 12 15:09:44 2002
+++ linux-2.5.42.w1/net/ipv4/ipmr.c	Tue Oct 15 20:58:32 2002
@@ -1105,6 +1105,7 @@
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
 #endif
+	security_ops->ip_encapsulate(skb);
 }
 
 static inline int ipmr_forward_finish(struct sk_buff *skb)
@@ -1450,6 +1451,7 @@
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
 #endif
+	security_ops->ip_decapsulate(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);
 	return 0;
@@ -1517,6 +1519,7 @@
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
 #endif
+	security_ops->ip_decapsulate(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);
 	return 0;
diff -urN -X dontdiff linux-2.5.42.w0/security/capability.c linux-2.5.42.w1/security/capability.c
--- linux-2.5.42.w0/security/capability.c	Tue Oct 15 20:58:10 2002
+++ linux-2.5.42.w1/security/capability.c	Tue Oct 15 20:58:32 2002
@@ -841,6 +841,37 @@
 	return 0;
 }
 
+static void cap_ip_fragment (struct sk_buff *newskb,
+			     const struct sk_buff *oldskb)
+{
+	return;
+}
+
+static int cap_ip_defragment (struct sk_buff *skb)
+{
+	return 0;
+}
+
+static void cap_ip_encapsulate (struct sk_buff *skb)
+{
+	return;
+}
+
+static void cap_ip_decapsulate (struct sk_buff *skb)
+{
+	return;
+}
+
+static int cap_ip_decode_options (struct sk_buff *skb, const char *optptr,
+				  unsigned char **pp_ptr)
+{
+	if (!skb && !capable (CAP_NET_RAW)) {
+		(const unsigned char *) *pp_ptr = optptr;
+		return -EPERM;
+	}
+	return 0;
+}
+
 static int cap_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -969,6 +1000,12 @@
 	.socket_sock_free_security =	cap_socket_sock_free_security,
 	.socket_sock_rcv_skb =		cap_socket_sock_rcv_skb,
 
+	.ip_fragment =			cap_ip_fragment,
+	.ip_defragment =		cap_ip_defragment,
+	.ip_encapsulate =		cap_ip_encapsulate,
+	.ip_decapsulate =		cap_ip_decapsulate,
+	.ip_decode_options =		cap_ip_decode_options,
+
 	.ipc_permission =		cap_ipc_permission,
 
 	.msg_queue_alloc_security =	cap_msg_queue_alloc_security,
diff -urN -X dontdiff linux-2.5.42.w0/security/dummy.c linux-2.5.42.w1/security/dummy.c
--- linux-2.5.42.w0/security/dummy.c	Tue Oct 15 20:58:10 2002
+++ linux-2.5.42.w1/security/dummy.c	Tue Oct 15 20:58:32 2002
@@ -658,6 +658,37 @@
 	return 0;
 }
 
+static void dummy_ip_fragment (struct sk_buff *newskb,
+			       const struct sk_buff *oldskb)
+{
+	return;
+}
+
+static int dummy_ip_defragment (struct sk_buff *skb)
+{
+	return 0;
+}
+
+static void dummy_ip_decapsulate (struct sk_buff *skb)
+{
+	return;
+}
+
+static void dummy_ip_encapsulate (struct sk_buff *skb)
+{
+	return;
+}
+
+static int dummy_ip_decode_options (struct sk_buff *skb, const char *optptr,
+				    unsigned char **pp_ptr)
+{
+	if (!skb && !capable (CAP_NET_RAW)) {
+		(const unsigned char *) *pp_ptr = optptr;
+		return -EPERM;
+	}
+	return 0;
+}
+
 static int dummy_register (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -786,6 +817,12 @@
 	.socket_sock_free_security =	dummy_socket_sock_free_security,
 	.socket_sock_rcv_skb =		dummy_socket_sock_rcv_skb,
 
+	.ip_fragment =			dummy_ip_fragment,
+	.ip_defragment =		dummy_ip_defragment,
+	.ip_encapsulate =		dummy_ip_encapsulate,
+	.ip_decapsulate =		dummy_ip_decapsulate,
+	.ip_decode_options =		dummy_ip_decode_options,
+
 	.ipc_permission =		dummy_ipc_permission,
 	
 	.msg_queue_alloc_security =	dummy_msg_queue_alloc_security,
