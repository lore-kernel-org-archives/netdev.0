From: paul.moore@hp.com
Subject: [PATCH 06/11] secid reconciliation: Label locally generated IPv4 traffic
Date: Mon, 09 Oct 2006 15:42:29 -0400
Message-ID: <20061009195849.699362000@hp.com>
References: <20061009194223.402695000@hp.com>
Cc: vyekkirala@TrustedCS.com, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:5048 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S933019AbWJIT6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 15:58:52 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=secid-6
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@TrustedCS.com>

This labels the skb(s) for locally generated IPv4 traffic. This will
be used in pertinent flow control checks on the outbound later in the
LSM hook.

This is not as pretty as it is for IPv6, but what to do?
Note that skb(s) that derive the secmark from the originating socket
do so in the outbound hook.

NOTE: Forwarded traffic is already labeled with the reconciled
secmark on the inbound.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/net/ip.h           |   31 +++++++++++++++++++++++++++++++
 include/net/request_sock.h |   18 ++++++++++++++++++
 net/dccp/ipv4.c            |    5 +++++
 net/ipv4/icmp.c            |    4 ++++
 net/ipv4/ip_output.c       |    6 ++++++
 net/ipv4/tcp_ipv4.c        |    1 +
 6 files changed, 65 insertions(+)

Index: net-2.6_secidfinal/include/net/ip.h
===================================================================
--- net-2.6_secidfinal.orig/include/net/ip.h
+++ net-2.6_secidfinal/include/net/ip.h
@@ -48,6 +48,9 @@ struct ipcm_cookie
 	__be32			addr;
 	int			oif;
 	struct ip_options	*opt;
+#ifdef CONFIG_SECURITY_NETWORK
+	u32			secid;
+#endif /* CONFIG_SECURITY_NETWORK */
 };
 
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
@@ -383,4 +386,32 @@ extern int ip_misc_proc_init(void);
 
 extern struct ctl_table ipv4_table[];
 
+#ifdef CONFIG_SECURITY_NETWORK
+
+static inline void security_skb_classify_ipcm(struct sk_buff *skb,
+					struct ipcm_cookie *ipc)
+{
+	ipc->secid = skb->secmark;
+}
+
+static inline void security_ipcm_classify_skb(struct ipcm_cookie *ipc,
+					struct sk_buff *skb)
+{
+	skb->secmark = ipc->secid;
+}
+
+#else
+
+static inline void security_skb_classify_ipcm(struct sk_buff *skb,
+					struct ipcm_cookie *ipc)
+{
+}
+
+static inline void security_ipcm_classify_skb(struct ipcm_cookie *ipc,
+					struct sk_buff *skb)
+{
+}
+
+#endif /* CONFIG_SECURITY_NETWORK */
+
 #endif	/* _IP_H */
Index: net-2.6_secidfinal/include/net/request_sock.h
===================================================================
--- net-2.6_secidfinal.orig/include/net/request_sock.h
+++ net-2.6_secidfinal/include/net/request_sock.h
@@ -54,6 +54,7 @@ struct request_sock {
 	struct request_sock_ops		*rsk_ops;
 	struct sock			*sk;
 	u32				secid;
+	u32				peer_secid;
 };
 
 static inline struct request_sock *reqsk_alloc(struct request_sock_ops *ops)
@@ -259,4 +260,21 @@ static inline void reqsk_queue_hash_req(
 	write_unlock(&queue->syn_wait_lock);
 }
 
+#ifdef CONFIG_SECURITY_NETWORK
+
+static inline void security_req_classify_skb(struct request_sock *req,
+					struct sk_buff *skb)
+{
+	skb->secmark = req->secid;
+}
+
+#else
+
+static inline void security_req_classify_skb(struct request_sock *req,
+					struct sk_buff *skb)
+{
+}
+
+#endif /* CONFIG_SECURITY_NETWORK */
+
 #endif /* _REQUEST_SOCK_H */
Index: net-2.6_secidfinal/net/dccp/ipv4.c
===================================================================
--- net-2.6_secidfinal.orig/net/dccp/ipv4.c
+++ net-2.6_secidfinal/net/dccp/ipv4.c
@@ -230,6 +230,8 @@ static void dccp_v4_reqsk_send_ack(struc
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb),
 			 DCCP_SKB_CB(rxskb)->dccpd_seq);
 
+	security_req_classify_skb(req, skb);
+
 	bh_lock_sock(dccp_v4_ctl_socket->sk);
 	err = ip_build_and_send_pkt(skb, dccp_v4_ctl_socket->sk,
 				    rxskb->nh.iph->daddr,
@@ -261,6 +263,7 @@ static int dccp_v4_send_response(struct 
 		dh->dccph_checksum = dccp_v4_checksum(skb, ireq->loc_addr,
 						      ireq->rmt_addr);
 		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+		security_req_classify_skb(req, skb);
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
 					    ireq->opt);
@@ -743,6 +746,8 @@ static void dccp_v4_ctl_send_reset(struc
 	dh->dccph_checksum = dccp_v4_checksum(skb, rxskb->nh.iph->saddr,
 					      rxskb->nh.iph->daddr);
 
+	security_skb_classify_skb(rxskb, skb);
+
 	bh_lock_sock(dccp_v4_ctl_socket->sk);
 	err = ip_build_and_send_pkt(skb, dccp_v4_ctl_socket->sk,
 				    rxskb->nh.iph->daddr,
Index: net-2.6_secidfinal/net/ipv4/icmp.c
===================================================================
--- net-2.6_secidfinal.orig/net/ipv4/icmp.c
+++ net-2.6_secidfinal/net/ipv4/icmp.c
@@ -389,6 +389,8 @@ static void icmp_reply(struct icmp_bxm *
 	if (icmp_xmit_lock())
 		return;
 
+	security_skb_classify_ipcm(skb, &ipc);
+
 	icmp_param->data.icmph.checksum = 0;
 	icmp_out_count(icmp_param->data.icmph.type);
 
@@ -507,6 +509,8 @@ void icmp_send(struct sk_buff *skb_in, i
 	if (icmp_xmit_lock())
 		return;
 
+	security_skb_classify_ipcm(skb_in, &ipc);
+
 	/*
 	 *	Construct source address and options.
 	 */
Index: net-2.6_secidfinal/net/ipv4/ip_output.c
===================================================================
--- net-2.6_secidfinal.orig/net/ipv4/ip_output.c
+++ net-2.6_secidfinal/net/ipv4/ip_output.c
@@ -926,6 +926,8 @@ alloc_new_skb:
 			if (skb == NULL)
 				goto error;
 
+			security_ipcm_classify_skb(ipc, skb);
+
 			/*
 			 *	Fill in the control structures
 			 */
@@ -1122,6 +1124,8 @@ ssize_t	ip_append_page(struct sock *sk, 
 				goto error;
 			}
 
+			security_skb_classify_skb(skb_prev, skb);
+
 			/*
 			 *	Fill in the control structures
 			 */
@@ -1349,6 +1353,8 @@ void ip_send_reply(struct sock *sk, stru
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
 
+	security_skb_classify_ipcm(skb, &ipc);
+
 	if (replyopts.opt.optlen) {
 		ipc.opt = &replyopts.opt;
 
Index: net-2.6_secidfinal/net/ipv4/tcp_ipv4.c
===================================================================
--- net-2.6_secidfinal.orig/net/ipv4/tcp_ipv4.c
+++ net-2.6_secidfinal/net/ipv4/tcp_ipv4.c
@@ -658,6 +658,7 @@ static int tcp_v4_send_synack(struct soc
 					 ireq->rmt_addr,
 					 csum_partial((char *)th, skb->len,
 						      skb->csum));
+		security_req_classify_skb(req, skb);
 
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,

--
paul moore
linux security @ hp
