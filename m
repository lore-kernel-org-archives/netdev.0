From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 6/9] secid reconciliation-v04: Label locally generated IPv4
 traffic
Date: Sun, 01 Oct 2006 16:26:57 -0500
Message-ID: <452032A1.6040009@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:32544 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932406AbWJAV1P
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 17:27:15 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

diff --git a/include/net/ip.h b/include/net/ip.h
index 98f9084..40ac276 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -48,6 +48,9 @@ struct ipcm_cookie
 	u32			addr;
 	int			oif;
 	struct ip_options	*opt;
+#ifdef CONFIG_SECURITY_NETWORK
+	u32			secid;
+#endif /* CONFIG_SECURITY_NETWORK */
 };
 
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
@@ -383,4 +386,32 @@ #endif
 
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
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 8e165ca..6d6da9c 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
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
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 66be29b..57ba542 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
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
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c2ad07e..956791a 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
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
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 97aee76..2e0775c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
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
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 39b1798..f21509b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -658,6 +658,7 @@ static int tcp_v4_send_synack(struct soc
 					 ireq->rmt_addr,
 					 csum_partial((char *)th, skb->len,
 						      skb->csum));
+		security_req_classify_skb(req, skb);
 
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
