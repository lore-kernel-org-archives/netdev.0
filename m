From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] LSM networking: ipv4 hooks for 2.5.59 (5/8)
Date: Fri, 31 Jan 2003 10:06:09 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301311001440.31382-100000@blackbird.intercode.com.au>
References: <Pine.LNX.4.44.0301310956530.31382-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-security-module@wirex.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
In-Reply-To: <Pine.LNX.4.44.0301310956530.31382-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 include/linux/ip.h       |    1 
 include/linux/security.h |  108 ++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/ah.c            |    2 
 net/ipv4/ip_fragment.c   |    7 ++-
 net/ipv4/ip_gre.c        |    3 +
 net/ipv4/ip_options.c    |    5 ++
 net/ipv4/ip_output.c     |    3 +
 net/ipv4/ipip.c          |    4 +
 net/ipv4/ipmr.c          |    4 +
 security/capability.c    |   13 +++++
 security/dummy.c         |   36 +++++++++++++++
 11 files changed, 183 insertions(+), 3 deletions(-)

diff -urN -X dontdiff linux-2.5.59.w0/include/linux/ip.h linux-2.5.59.w1/include/linux/ip.h
--- linux-2.5.59.w0/include/linux/ip.h	Thu Oct 31 16:01:08 2002
+++ linux-2.5.59.w1/include/linux/ip.h	Thu Jan 30 21:33:32 2003
@@ -58,6 +58,7 @@
 #define IPOPT_SEC	(2 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_LSRR	(3 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_TIMESTAMP	(4 |IPOPT_MEASUREMENT)
+#define IPOPT_CIPSO	(6 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_RR	(7 |IPOPT_CONTROL)
 #define IPOPT_SID	(8 |IPOPT_CONTROL|IPOPT_COPY)
 #define IPOPT_SSRR	(9 |IPOPT_CONTROL|IPOPT_COPY)
diff -urN -X dontdiff linux-2.5.59.w0/include/linux/security.h linux-2.5.59.w1/include/linux/security.h
--- linux-2.5.59.w0/include/linux/security.h	Thu Jan 30 21:33:15 2003
+++ linux-2.5.59.w1/include/linux/security.h	Thu Jan 30 21:33:32 2003
@@ -38,6 +38,9 @@
  * as the default capabilities functions
  */
 extern int cap_capable (struct task_struct *tsk, int cap);
+struct sk_buff;
+extern int cap_ip_decode_options (struct sk_buff *skb, const char *optptr,
+				  unsigned char **pp_ptr);
 extern int cap_ptrace (struct task_struct *parent, struct task_struct *child);
 extern int cap_capget (struct task_struct *target, kernel_cap_t *effective, kernel_cap_t *inheritable, kernel_cap_t *permitted);
 extern int cap_capset_check (struct task_struct *target, kernel_cap_t *effective, kernel_cap_t *inheritable, kernel_cap_t *permitted);
@@ -68,7 +71,6 @@
 struct socket;
 struct sockaddr;
 struct msghdr;
-struct sk_buff;
 struct net_device;
 struct nfsctl_arg;
 struct sched_param;
@@ -710,6 +712,48 @@
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
  * Lifecycle hooks for network buffers.
  *
  * @skb_alloc_security:
@@ -987,6 +1031,9 @@
 	int (*quotactl) (int cmds, int type, int id, struct super_block * sb);
 	int (*quota_on) (struct file * f);
 
+	int (*ip_decode_options) (struct sk_buff * skb,
+				  const char *optptr, unsigned char **pp_ptr);
+
 	int (*bprm_alloc_security) (struct linux_binprm * bprm);
 	void (*bprm_free_security) (struct linux_binprm * bprm);
 	void (*bprm_compute_creds) (struct linux_binprm * bprm);
@@ -1159,6 +1206,12 @@
 	void (*socket_sock_free_security) (struct sock * sk);
 	int (*socket_sock_rcv_skb) (struct sock * sk, struct sk_buff * skb);
 
+	void (*ip_fragment) (struct sk_buff * newskb,
+			     const struct sk_buff * oldskb);
+	int (*ip_defragment) (struct sk_buff * skb);
+	void (*ip_encapsulate) (struct sk_buff * skb);
+	void (*ip_decapsulate) (struct sk_buff * skb);
+
 	int (*skb_alloc_security) (struct sk_buff * skb, int gfp_mask);
 	int (*skb_clone) (struct sk_buff * newskb,
 			  const struct sk_buff * oldskb);
@@ -1222,6 +1275,13 @@
 	return security_ops->quota_on (file);
 }
 
+static inline int security_ip_decode_options(struct sk_buff * skb, 
+					     const char *optptr, 
+					     unsigned char **pp_ptr)
+{
+	return security_ops->ip_decode_options(skb, optptr, pp_ptr);
+}
+
 static inline int security_bprm_alloc (struct linux_binprm *bprm)
 {
 	return security_ops->bprm_alloc_security (bprm);
@@ -1827,6 +1887,13 @@
 	return 0;
 }
 
+static inline int security_ip_decode_options(struct sk_buff * skb, 
+					     const char *optptr, 
+					     unsigned char **pp_ptr)
+{
+	return cap_ip_decode_options(skb,optptr,pp_ptr);
+}
+
 static inline int security_bprm_alloc (struct linux_binprm *bprm)
 {
 	return 0;
@@ -2428,6 +2495,27 @@
 	return security_ops->socket_sock_rcv_skb (sk, skb);
 }
 
+static inline void security_ip_fragment(struct sk_buff * newskb, 
+					const struct sk_buff * oldskb)
+{
+	security_ops->ip_fragment(newskb, oldskb);
+}
+
+static inline int security_ip_defragment(struct sk_buff * skb)
+{
+	return security_ops->ip_defragment(skb);
+}
+
+static inline void security_ip_encapsulate(struct sk_buff * skb)
+{
+	security_ops->ip_encapsulate(skb);
+}
+
+static inline void security_ip_decapsulate(struct sk_buff * skb)
+{
+	security_ops->ip_decapsulate(skb);
+}
+
 static inline int security_skb_alloc(struct sk_buff * skb, int gfp_mask)
 {
 	return security_ops->skb_alloc_security(skb, gfp_mask);
@@ -2567,6 +2655,24 @@
 	return 0;
 }
 
+static inline void security_ip_fragment(struct sk_buff * newskb, 
+					const struct sk_buff * oldskb)
+{
+}
+
+static inline int security_ip_defragment(struct sk_buff * skb)
+{
+	return 0;
+}
+
+static inline void security_ip_encapsulate(struct sk_buff * skb)
+{
+}
+
+static inline void security_ip_decapsulate(struct sk_buff * skb)
+{
+}
+
 static inline int security_skb_alloc(struct sk_buff * skb, int gfp_mask)
 {
 	return 0;
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/ah.c linux-2.5.59.w1/net/ipv4/ah.c
--- linux-2.5.59.w0/net/ipv4/ah.c	Sat Jan 11 10:47:20 2003
+++ linux-2.5.59.w1/net/ipv4/ah.c	Thu Jan 30 21:33:32 2003
@@ -52,7 +52,7 @@
 		switch (*optptr) {
 		case IPOPT_SEC:
 		case 0x85:	/* Some "Extended Security" crap. */
-		case 0x86:	/* Another "Commercial Security" crap. */
+		case IPOPT_CIPSO:	/* Another "Commercial Security" crap. */
 		case IPOPT_RA:
 		case 0x80|21:	/* RFC1770 */
 			break;
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/ip_fragment.c linux-2.5.59.w1/net/ipv4/ip_fragment.c
--- linux-2.5.59.w0/net/ipv4/ip_fragment.c	Sat Jan 11 10:47:20 2003
+++ linux-2.5.59.w1/net/ipv4/ip_fragment.c	Thu Jan 30 21:33:32 2003
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
+	ret = security_ip_defragment(skb);
+	if (ret)
+		goto err;
 
 	if (qp->last_in & COMPLETE)
 		goto err;
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/ip_gre.c linux-2.5.59.w1/net/ipv4/ip_gre.c
--- linux-2.5.59.w0/net/ipv4/ip_gre.c	Tue Nov 12 00:12:06 2002
+++ linux-2.5.59.w1/net/ipv4/ip_gre.c	Thu Jan 30 21:33:32 2003
@@ -28,6 +28,7 @@
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/security.h>
 
 #include <net/sock.h>
 #include <net/ip.h>
@@ -661,6 +662,7 @@
 		skb->nf_debug = 0;
 #endif
 #endif
+		security_ip_decapsulate(skb);
 		ipgre_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
 		read_unlock(&ipgre_lock);
@@ -898,6 +900,7 @@
 	skb->nf_debug = 0;
 #endif
 #endif
+	security_ip_encapsulate(skb);
 
 	IPTUNNEL_XMIT();
 	tunnel->recursion--;
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/ip_options.c linux-2.5.59.w1/net/ipv4/ip_options.c
--- linux-2.5.59.w0/net/ipv4/ip_options.c	Tue Sep 24 19:22:50 2002
+++ linux-2.5.59.w1/net/ipv4/ip_options.c	Thu Jan 30 21:33:32 2003
@@ -18,6 +18,7 @@
 #include <linux/icmp.h>
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
+#include <linux/security.h>
 #include <net/sock.h>
 #include <net/ip.h>
 #include <net/icmp.h>
@@ -433,7 +434,11 @@
 				opt->router_alert = optptr - iph;
 			break;
 		      case IPOPT_SEC:
+		      case IPOPT_CIPSO:
 		      case IPOPT_SID:
+		      	if (security_ip_decode_options(skb, optptr, &pp_ptr))
+				goto error;
+			break;
 		      default:
 			if (!skb && !capable(CAP_NET_RAW)) {
 				pp_ptr = optptr;
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/ip_output.c linux-2.5.59.w1/net/ipv4/ip_output.c
--- linux-2.5.59.w0/net/ipv4/ip_output.c	Sat Jan 11 10:47:20 2003
+++ linux-2.5.59.w1/net/ipv4/ip_output.c	Thu Jan 30 21:33:32 2003
@@ -81,6 +81,7 @@
 #include <linux/netfilter_ipv4.h>
 #include <linux/mroute.h>
 #include <linux/netlink.h>
+#include <linux/security.h>
 
 /*
  *      Shall we try to damage output packets if routing dev changes?
@@ -633,6 +634,8 @@
 		ptr += len;
 		offset += len;
 
+		security_ip_fragment(skb2, skb);
+
 		/*
 		 *	Put this fragment into the sending queue.
 		 */
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/ipip.c linux-2.5.59.w1/net/ipv4/ipip.c
--- linux-2.5.59.w0/net/ipv4/ipip.c	Tue Nov 12 00:12:07 2002
+++ linux-2.5.59.w1/net/ipv4/ipip.c	Thu Jan 30 21:33:32 2003
@@ -108,6 +108,7 @@
 #include <linux/mroute.h>
 #include <linux/init.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/security.h>
 
 #include <net/sock.h>
 #include <net/ip.h>
@@ -508,6 +509,7 @@
 		skb->nf_debug = 0;
 #endif
 #endif
+		security_ip_decapsulate(skb);
 		ipip_ecn_decapsulate(iph, skb);
 		netif_rx(skb);
 		read_unlock(&ipip_lock);
@@ -662,6 +664,8 @@
 #endif
 #endif
 
+	security_ip_encapsulate(skb);
+
 	IPTUNNEL_XMIT();
 	tunnel->recursion--;
 	return 0;
diff -urN -X dontdiff linux-2.5.59.w0/net/ipv4/ipmr.c linux-2.5.59.w1/net/ipv4/ipmr.c
--- linux-2.5.59.w0/net/ipv4/ipmr.c	Tue Nov 12 00:12:07 2002
+++ linux-2.5.59.w1/net/ipv4/ipmr.c	Thu Jan 30 21:33:32 2003
@@ -60,6 +60,7 @@
 #include <linux/netfilter_ipv4.h>
 #include <net/ipip.h>
 #include <net/checksum.h>
+#include <linux/security.h>
 
 #if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
 #define CONFIG_IP_PIMSM	1
@@ -1105,6 +1106,7 @@
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
 #endif
+	security_ip_encapsulate(skb);
 }
 
 static inline int ipmr_forward_finish(struct sk_buff *skb)
@@ -1461,6 +1463,7 @@
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
 #endif
+	security_ip_decapsulate(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);
 	return 0;
@@ -1528,6 +1531,7 @@
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
 #endif
+	security_ip_decapsulate(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);
 	return 0;
diff -urN -X dontdiff linux-2.5.59.w0/security/capability.c linux-2.5.59.w1/security/capability.c
--- linux-2.5.59.w0/security/capability.c	Tue Dec 10 15:02:03 2002
+++ linux-2.5.59.w1/security/capability.c	Thu Jan 30 21:33:32 2003
@@ -266,6 +266,16 @@
 	return;
 }
 
+int cap_ip_decode_options (struct sk_buff *skb, const char *optptr,
+			   unsigned char **pp_ptr)
+{
+	if (!skb && !capable (CAP_NET_RAW)) {
+		(const unsigned char *) *pp_ptr = optptr;
+		return -EPERM;
+	}
+	return 0;
+}
+
 EXPORT_SYMBOL(cap_capable);
 EXPORT_SYMBOL(cap_ptrace);
 EXPORT_SYMBOL(cap_capget);
@@ -276,6 +286,7 @@
 EXPORT_SYMBOL(cap_task_post_setuid);
 EXPORT_SYMBOL(cap_task_kmod_set_label);
 EXPORT_SYMBOL(cap_task_reparent_to_init);
+EXPORT_SYMBOL(cap_ip_decode_options);
 
 #ifdef CONFIG_SECURITY
 
@@ -293,6 +304,8 @@
 	.task_post_setuid =		cap_task_post_setuid,
 	.task_kmod_set_label =		cap_task_kmod_set_label,
 	.task_reparent_to_init =	cap_task_reparent_to_init,
+	
+	.ip_decode_options =		cap_ip_decode_options,
 };
 
 #if defined(CONFIG_SECURITY_CAPABILITIES_MODULE)
diff -urN -X dontdiff linux-2.5.59.w0/security/dummy.c linux-2.5.59.w1/security/dummy.c
--- linux-2.5.59.w0/security/dummy.c	Thu Jan 30 21:33:15 2003
+++ linux-2.5.59.w1/security/dummy.c	Thu Jan 30 21:33:32 2003
@@ -597,6 +597,16 @@
 	return 0;
 }
 
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
 #ifdef CONFIG_SECURITY_NETWORK
 
 static int dummy_socket_create (int family, int type, int protocol)
@@ -686,6 +696,27 @@
 	return;
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
 static int dummy_socket_sock_rcv_skb (struct sock *sk, struct sk_buff *skb)
 {
 	return 0;
@@ -859,6 +890,7 @@
 	set_to_dummy_if_null(ops, sem_semop);
 	set_to_dummy_if_null(ops, register_security);
 	set_to_dummy_if_null(ops, unregister_security);
+	set_to_dummy_if_null(ops, ip_decode_options);
 #ifdef CONFIG_SECURITY_NETWORK
 	set_to_dummy_if_null(ops, socket_create);
 	set_to_dummy_if_null(ops, socket_post_create);
@@ -877,6 +909,10 @@
 	set_to_dummy_if_null(ops, socket_sock_alloc_security);
 	set_to_dummy_if_null(ops, socket_sock_free_security);
 	set_to_dummy_if_null(ops, socket_sock_rcv_skb);
+	set_to_dummy_if_null(ops, ip_fragment);
+	set_to_dummy_if_null(ops, ip_defragment);
+	set_to_dummy_if_null(ops, ip_decapsulate);
+	set_to_dummy_if_null(ops, ip_encapsulate);
 	set_to_dummy_if_null(ops, skb_alloc_security);
 	set_to_dummy_if_null(ops, skb_clone);
 	set_to_dummy_if_null(ops, skb_copy);
