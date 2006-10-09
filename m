From: paul.moore@hp.com
Subject: [PATCH 10/11] secid reconciliation: various fixes
Date: Mon, 09 Oct 2006 15:42:33 -0400
Message-ID: <20061009195852.914941000@hp.com>
References: <20061009194223.402695000@hp.com>
Cc: vyekkirala@TrustedCS.com, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:51615 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S964793AbWJIT6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 15:58:55 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=secid-fix_1
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@TrustedCS.com>

This fixes the secid reconciliation code in the following ways:

1. Null-out secmark on an outgoing packet after we are done with all
   the checks. This has been necessitated by the fact that some packets
   sent to a multicast address could arrive back on a non-loopback
   interface but with the secmark intact. This would result in the
   current flow_out control logic to use it as a security point context
   when no explicit security points have been defined for the inbound
   packet.

2. Label udp/raw packets with the label of the socket.

3. Label igmp traffic with the igmp_packet initial context.

4. Limit flow-controlling of loopback traffic to the socket.recv permission
   check. This means that packet.flow_in/flow_out checks are no longer
   applicable to loopback traffic. This is because of current implementation
   constraints.


DOCUMENTATION OF SECID RECONCILIATION AND FLOW CONTROL FOR POLICY WRITERS:

ON INBOUND:

1. PACKETS ENTERING SYSTEM FROM A NON-LOOPBACK DEVICE:

   Can a packet "carrying" external domain label x_t "flow_in" thru the
   security point with the peer domain label p_d_t?

	NOTE:
	a. x_t defaults to unlabeled_t, if no external label.
	b. p_d_t defaults to network_t in the absence of any applicable
	   [conn]secmark rules for the packet. If there are multiple
	   secmark rules applicable to a packet, the context on the LAST
	   rule will apply.

   NO: Drop packet.
   YES: If no external label, let packet "carry" p_d_t.

2. INPUT ONLY: Can a socket "recv" a packet from domain p_d_t?

   NO: Drop packet.
   YES: If setting up a tcp connection, set peer context to p_d_t.

ON OUTBOUND:

1. Let packet "carry" the originating socket domain label.

2. IPSEC Handling:

   LABELED IPSEC: If packet "polmatch"es to an otherwise applicable and
   labeled SPD entry, choose a Security Association (SA) with the SAME context
   as the domain label being carried by packet.
	NOTE: If no such SA present, call into IKE with context on packet.

   NON-LABELED (PLAIN/TRADITIONAL) IPSEC: If there's an applicable SPD entry
   that does NOT have an explicit context associated with it, an applicable SA
   that does NOT have an explicit context associated with it is chosen.
	NOTE: If no such SA present, call into IKE, but with NO context.

3. PACKETS DESTINED FOR NON-LOOPBACK DEVICE:

   a. IPTABLES Processing:
      As EACH applicable iptables [CONN]SECMARK rule with domain p_d_t is
      encountered, do the following:
   
      Can a packet carrying domain label a_t "flow_out" of the security point
      with the domain label p_d_t?
   
         NO: Drop packet.
         YES: Replace the domain label a_t on the packet with the security point
              label p_d_t.

   b. Before a packet is let out of the system:

      Can a packet with domain label p_d_t "flow_out" into the network domain
      network_t?

      NO: Drop packet.
      YES: Let packet out.

      NOTE: Ideally this check should be applicable only to packets that
            didn't go thru [conn]secmark checks for outbound, but there's
            currently no way to know this due to implementation constrains.
            Hence a blanket check for ALL packets leaving the system.

FORWARDED TRAFFIC:

Forwarded Traffic will undergo the following:

1. Step 1 under ON INBOUND.

2. Steps 2 and 3 under ON OUTBOUND.


Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h       |   24 +++++++++-------
 include/net/ip.h               |   13 ++++++++
 include/net/request_sock.h     |   11 +++++++
 net/ipv4/igmp.c                |    4 ++
 net/ipv4/raw.c                 |    2 +
 net/ipv4/udp.c                 |    2 +
 net/netfilter/xt_CONNSECMARK.c |   21 ++++++++++----
 net/netfilter/xt_SECMARK.c     |   16 ++++++++--
 security/dummy.c               |    8 ++---
 security/selinux/hooks.c       |   61 +++++++++++++++++++++++++++++++++--------
 10 files changed, 129 insertions(+), 33 deletions(-)

Index: net-2.6_secidfinal/include/linux/security.h
===================================================================
--- net-2.6_secidfinal.orig/include/linux/security.h
+++ net-2.6_secidfinal/include/linux/security.h
@@ -67,6 +67,7 @@ struct xfrm_selector;
 struct xfrm_policy;
 struct xfrm_state;
 struct xfrm_user_sec_ctx;
+struct net_device;
 
 extern int cap_netlink_send(struct sock *sk, struct sk_buff *skb);
 extern int cap_netlink_recv(struct sk_buff *skb, int cap);
@@ -828,8 +829,8 @@ struct request_sock;
  *	Sets the new child socket's sid to the openreq sid.
  * @inet_conn_established:
  *	Sets the connection's peersid to the secmark on skb.
- * @req_classify_flow:
- *	Sets the flow's sid to the openreq sid.
+ * @igmp_classify_skb:
+ *	Classifies an skb representing an igmp packet.
  * @skb_flow_in:
  *	Checks to see if security policy would allow skb into the system
  *	while also reconciling the xfrm secid, cipso, etc, if any, and
@@ -1383,9 +1384,10 @@ struct security_operations {
 					struct request_sock *req);
 	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
 	void (*inet_conn_established)(struct sock *sk, struct sk_buff *skb);
-	void (*req_classify_flow)(const struct request_sock *req, struct flowi *fl);
+	void (*igmp_classify_skb)(struct sk_buff *skb);
 	int (*skb_flow_in)(struct sk_buff *skb, unsigned short family);
-	int (*skb_flow_out)(struct sk_buff *skb, u32 nf_secid);
+	int (*skb_flow_out)(struct sk_buff *skb, u32 nf_secid,
+			const struct net_device *out, unsigned short family);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2956,9 +2958,9 @@ static inline void security_sk_classify_
 	security_ops->sk_getsecid(sk, &fl->secid);
 }
 
-static inline void security_req_classify_flow(const struct request_sock *req, struct flowi *fl)
+static inline void security_igmp_classify_skb(struct sk_buff *skb)
 {
-	security_ops->req_classify_flow(req, fl);
+	security_ops->igmp_classify_skb(skb);
 }
 
 static inline int security_skb_flow_in(struct sk_buff *skb,
@@ -2968,9 +2970,10 @@ static inline int security_skb_flow_in(s
 }
 
 static inline int security_skb_flow_out(struct sk_buff *skb,
-					u32 nf_secid)
+			u32 nf_secid, const struct net_device *out,
+			unsigned short family)
 {
-	return security_ops->skb_flow_out(skb, nf_secid);
+	return security_ops->skb_flow_out(skb, nf_secid, out, family);
 }
 
 static inline void security_sock_graft(struct sock* sk, struct socket *parent)
@@ -3126,7 +3129,7 @@ static inline void security_sk_classify_
 {
 }
 
-static inline void security_req_classify_flow(const struct request_sock *req, struct flowi *fl)
+static inline void security_igmp_classify_skb(struct sk_buff *skb)
 {
 }
 
@@ -3137,7 +3140,8 @@ static inline int security_skb_flow_in(s
 }
 
 static inline int security_skb_flow_out(struct sk_buff *skb,
-					u32 nf_secid)
+			u32 nf_secid, const struct net_device *out,
+			unsigned short family)
 {
 	return -ENOENT;
 }
Index: net-2.6_secidfinal/include/net/ip.h
===================================================================
--- net-2.6_secidfinal.orig/include/net/ip.h
+++ net-2.6_secidfinal/include/net/ip.h
@@ -388,6 +388,14 @@ extern struct ctl_table ipv4_table[];
 
 #ifdef CONFIG_SECURITY_NETWORK
 
+extern struct security_operations *security_ops;
+
+static inline void security_sk_classify_ipcm(struct sock *sk,
+				struct ipcm_cookie *ipc)
+{
+	security_ops->sk_getsecid(sk, &ipc->secid);
+}
+
 static inline void security_skb_classify_ipcm(struct sk_buff *skb,
 					struct ipcm_cookie *ipc)
 {
@@ -402,6 +410,11 @@ static inline void security_ipcm_classif
 
 #else
 
+static inline void security_sk_classify_ipcm(struct sock *sk,
+				struct ipcm_cookie *ipc)
+{
+}
+
 static inline void security_skb_classify_ipcm(struct sk_buff *skb,
 					struct ipcm_cookie *ipc)
 {
Index: net-2.6_secidfinal/include/net/request_sock.h
===================================================================
--- net-2.6_secidfinal.orig/include/net/request_sock.h
+++ net-2.6_secidfinal/include/net/request_sock.h
@@ -262,6 +262,12 @@ static inline void reqsk_queue_hash_req(
 
 #ifdef CONFIG_SECURITY_NETWORK
 
+static inline void security_req_classify_flow(const struct request_sock *req,
+					struct flowi *fl)
+{
+	fl->secid = req->secid;
+}
+
 static inline void security_req_classify_skb(struct request_sock *req,
 					struct sk_buff *skb)
 {
@@ -270,6 +276,11 @@ static inline void security_req_classify
 
 #else
 
+static inline void security_req_classify_flow(const struct request_sock *req,
+					struct flowi *fl)
+{
+}
+
 static inline void security_req_classify_skb(struct request_sock *req,
 					struct sk_buff *skb)
 {
Index: net-2.6_secidfinal/net/ipv4/igmp.c
===================================================================
--- net-2.6_secidfinal.orig/net/ipv4/igmp.c
+++ net-2.6_secidfinal/net/ipv4/igmp.c
@@ -293,6 +293,8 @@ static struct sk_buff *igmpv3_newpack(st
 	if (skb == NULL)
 		return NULL;
 
+	security_igmp_classify_skb(skb);
+
 	{
 		struct flowi fl = { .oif = dev->ifindex,
 				    .nl_u = { .ip4_u = {
@@ -658,6 +660,8 @@ static int igmp_send_report(struct in_de
 		return -1;
 	}
 
+	security_igmp_classify_skb(skb);
+
 	skb->dst = &rt->u.dst;
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
Index: net-2.6_secidfinal/net/ipv4/raw.c
===================================================================
--- net-2.6_secidfinal.orig/net/ipv4/raw.c
+++ net-2.6_secidfinal/net/ipv4/raw.c
@@ -433,6 +433,8 @@ static int raw_sendmsg(struct kiocb *ioc
 	ipc.opt = NULL;
 	ipc.oif = sk->sk_bound_dev_if;
 
+	security_sk_classify_ipcm(sk, &ipc);
+
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(msg, &ipc);
 		if (err)
Index: net-2.6_secidfinal/net/ipv4/udp.c
===================================================================
--- net-2.6_secidfinal.orig/net/ipv4/udp.c
+++ net-2.6_secidfinal/net/ipv4/udp.c
@@ -588,6 +588,8 @@ int udp_sendmsg(struct kiocb *iocb, stru
 	if (!ipc.opt)
 		ipc.opt = inet->opt;
 
+	security_sk_classify_ipcm(sk, &ipc);
+
 	saddr = ipc.addr;
 	ipc.addr = faddr = daddr;
 
Index: net-2.6_secidfinal/net/netfilter/xt_CONNSECMARK.c
===================================================================
--- net-2.6_secidfinal.orig/net/netfilter/xt_CONNSECMARK.c
+++ net-2.6_secidfinal/net/netfilter/xt_CONNSECMARK.c
@@ -68,7 +68,8 @@ static void secmark_save(struct sk_buff 
  * On the outbound, filter based on the current secmark.
  */
 static unsigned int secmark_restore(struct sk_buff *skb, unsigned int hooknum,
-		   const struct net_device *in, unsigned short family)
+		   const struct net_device *in, const struct net_device *out,
+		   unsigned short family)
 {
 	u32 *psecmark;
 	enum ip_conntrack_info ctinfo;
@@ -81,14 +82,24 @@ static unsigned int secmark_restore(stru
 		if (outbound(family, hooknum)) {
 			int err;
 
-			err = security_skb_flow_out(skb, *psecmark);
+			/*
+			 * We can't currently flow-control loopback traffic
+			 * very well since we want to retain the secmark of
+			 * the originating socket and if we do retain it,
+			 * it will cause connsecmark save & restore to use this
+			 * socket label and mess up the semantics of the "peer
+			 * security point".
+			 */
+			if (out == &loopback_dev)
+				goto out;
+
+			err = security_skb_flow_out(skb, *psecmark, out, family);
 			if (!err)
 				return NF_DROP;
 		} else
 			/* 
 			 * inbound:
-			 * loopback traffic should already be labeled
-			 * and any filtering on outbound should suffice
+			 * No filtering of loopback traffic.
 			 */
 			if (in == &loopback_dev)
 				goto out;
@@ -119,7 +130,7 @@ static unsigned int target(struct sk_buf
 		break;
 
 	case CONNSECMARK_RESTORE:
-		return secmark_restore(skb, hooknum, in, target->family);
+		return secmark_restore(skb, hooknum, in, out, target->family);
 		break;
 
 	default:
Index: net-2.6_secidfinal/net/netfilter/xt_SECMARK.c
===================================================================
--- net-2.6_secidfinal.orig/net/netfilter/xt_SECMARK.c
+++ net-2.6_secidfinal/net/netfilter/xt_SECMARK.c
@@ -70,14 +70,24 @@ static unsigned int target(struct sk_buf
 		if (outbound(target->family, hooknum)) {
 			int err;
 
-			err = security_skb_flow_out(*pskb, secmark);
+			/*
+			 * We can't currently flow-control loopback traffic
+			 * very well since we want to retain the secmark of
+			 * the originating socket and if we do retain it,
+			 * it will cause connsecmark save & restore to use this
+			 * socket label and mess up the semantics of the "peer
+			 * security point".
+			 */
+			if (out == &loopback_dev)
+				goto out;
+
+			err = security_skb_flow_out(*pskb, secmark, out, target->family);
 			if (!err)
 				return NF_DROP;
 		} else
 			/*
 			 * inbound:
-			 * loopback traffic should already be labeled
-			 * and any filtering on outbound should suffice
+			 * No filtering of loopback traffic.
 			 */
 			if (in == &loopback_dev)
 				goto out;
Index: net-2.6_secidfinal/security/dummy.c
===================================================================
--- net-2.6_secidfinal.orig/security/dummy.c
+++ net-2.6_secidfinal/security/dummy.c
@@ -833,8 +833,7 @@ static inline void dummy_inet_conn_estab
 {
 }
 
-static inline void dummy_req_classify_flow(const struct request_sock *req,
-			struct flowi *fl)
+static inline void dummy_igmp_classify_skb(struct sk_buff *skb)
 {
 }
 
@@ -844,7 +843,8 @@ static inline int dummy_skb_flow_in(stru
 	return -ENOENT;
 }
 
-static inline int dummy_skb_flow_out(struct sk_buff *skb, u32 nf_secid)
+static inline int dummy_skb_flow_out(struct sk_buff *skb, u32 nf_secid,
+			const struct net_device *out, unsigned short family)
 {
 	return -ENOENT;
 }
@@ -1124,7 +1124,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, inet_conn_request);
 	set_to_dummy_if_null(ops, inet_csk_clone);
 	set_to_dummy_if_null(ops, inet_conn_established);
-	set_to_dummy_if_null(ops, req_classify_flow);
+	set_to_dummy_if_null(ops, igmp_classify_skb);
 	set_to_dummy_if_null(ops, skb_flow_in);
 	set_to_dummy_if_null(ops, skb_flow_out);
  #endif	/* CONFIG_SECURITY_NETWORK */
Index: net-2.6_secidfinal/security/selinux/hooks.c
===================================================================
--- net-2.6_secidfinal.orig/security/selinux/hooks.c
+++ net-2.6_secidfinal/security/selinux/hooks.c
@@ -3691,35 +3691,42 @@ static void selinux_inet_conn_establishe
 	sksec->peer_sid = skb->secmark;
 }
 
-static void selinux_req_classify_flow(const struct request_sock *req,
-				      struct flowi *fl)
+static void selinux_igmp_classify_skb(struct sk_buff *skb)
 {
-	fl->secid = req->secid;
+	skb->secmark = SECINITSID_IGMP_PACKET;
 }
 
 static int selinux_skb_flow_in(struct sk_buff *skb, unsigned short family)
 {
 	u32 xfrm_sid;
 	int err;
+	struct avc_audit_data ad;
+	char *addrp;
+	int len;
 
 	if (selinux_compat_net)
 		return 1;
 
 	/*
-	 * loopback traffic already labeled and
-	 * flow-controlled on outbound. We may
-	 * need to flow-control on the inbound
-	 * as well if there's ever a use-case for it.
+	 * loopback traffic should already be labeled with
+	 * the originating socket label.
 	 */
 	if (skb->dev == &loopback_dev)
 		return 1;
 
+	AVC_AUDIT_DATA_INIT(&ad, NET);
+	ad.u.net.netif = skb->dev ? skb->dev->name : "[unknown]";
+	ad.u.net.family = family;
+	err = selinux_parse_skb(skb, &ad, &addrp, &len, 1);
+	if (err)
+		goto out;
+
 	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
 	BUG_ON(err);
 
 	err = avc_has_perm(xfrm_sid, skb->secmark? : SECINITSID_NETMSG,
 					SECCLASS_PACKET,
-					PACKET__FLOW_IN, NULL);
+					PACKET__FLOW_IN, &ad);
 	if (err)
 		goto out;
 
@@ -3732,9 +3739,14 @@ out:
 	return err ? 0 : 1;
 };
 
-static int selinux_skb_flow_out(struct sk_buff *skb, u32 nf_secid)
+static int selinux_skb_flow_out(struct sk_buff *skb, u32 nf_secid,
+			const struct net_device *out, unsigned short family)
 {
 	int err;
+	char *addrp;
+	int len;
+	struct net_device *dev = (struct net_device *)out;
+	struct avc_audit_data ad;
 
 	if (selinux_compat_net)
 		return 1;
@@ -3752,9 +3764,17 @@ static int selinux_skb_flow_out(struct s
 		}
 	}
 
+	AVC_AUDIT_DATA_INIT(&ad, NET);
+	ad.u.net.netif = dev->name;
+	ad.u.net.family = family;
+	err = selinux_parse_skb(skb, &ad, &addrp, &len, 0);
+	if (err)
+		goto out;
+
 	err = avc_has_perm(skb->secmark, nf_secid, SECCLASS_PACKET,
-				PACKET__FLOW_OUT, NULL);
+				PACKET__FLOW_OUT, &ad);
 
+out:
 	return err ? 0 : 1;
 }
 
@@ -3915,8 +3935,27 @@ static unsigned int selinux_ip_postroute
 				skb->secmark = sksec->sid;
 			}
 		}
+		if (out == &loopback_dev)
+			return NF_ACCEPT;
+
 		err = avc_has_perm(skb->secmark, SECINITSID_NETMSG,
 				   SECCLASS_PACKET, PACKET__FLOW_OUT, &ad);
+
+		if (skb->secmark)
+			/*
+			 * Our multicast packets could get copied back
+			 * to us, arriving on a non-loopback device.
+			 * Leaving the secmark intact here will cause it
+			 * to be used as a security point context in
+			 * the flow_in hook above while it's not in fact
+			 * a security point context.
+			 *
+			 * We may be able to retain this marking if
+			 * we can reliably determine that it was a local
+			 * packet although it arrived on a non-loopback
+			 * device, in the flow_in hook above.
+			 */
+			skb->secmark = SECSID_NULL;
 	}
 out:
 	return err ? NF_DROP : NF_ACCEPT;
@@ -4824,7 +4863,7 @@ static struct security_operations selinu
 	.inet_conn_request =		selinux_inet_conn_request,
 	.inet_csk_clone =		selinux_inet_csk_clone,
 	.inet_conn_established =	selinux_inet_conn_established,
-	.req_classify_flow =		selinux_req_classify_flow,
+	.igmp_classify_skb =		selinux_igmp_classify_skb,
 	.skb_flow_in =			selinux_skb_flow_in,
 	.skb_flow_out =			selinux_skb_flow_out,
 

--
paul moore
linux security @ hp
