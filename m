From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 10/11] Phonet: emit errors when a packet cannot be delivered locally
Date: Mon, 22 Sep 2008 18:47:24 +0300
Message-ID: <1222098445-26175-10-git-send-email-remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:34635 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753646AbYIVPru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 11:47:50 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8MFlIhh008928
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 10:47:48 -0500
In-Reply-To: <200809221845.54736.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is no listener socket for a received packet, send an error
back to the sender.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/phonet.h      |   32 ++++++++++++++
 include/net/phonet/phonet.h |    5 ++
 net/phonet/af_phonet.c      |   96 +++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 129 insertions(+), 4 deletions(-)

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 001c0e6..3a027f5 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -45,6 +45,38 @@ struct phonethdr {
 	__u8	pn_sobj;
 } __attribute__((packed));
 
+/* Common Phonet payload header */
+struct phonetmsg {
+	__u8	pn_trans_id;	/* transaction ID */
+	__u8	pn_msg_id;	/* message type */
+	union {
+		struct {
+			__u8	pn_submsg_id;	/* message subtype */
+			__u8	pn_data[5];
+		} base;
+		struct {
+			__u16	pn_e_res_id;	/* extended resource ID */
+			__u8	pn_e_submsg_id;	/* message subtype */
+			__u8	pn_e_data[3];
+		} ext;
+	} pn_msg_u;
+};
+#define PN_COMMON_MESSAGE	0xF0
+#define PN_PREFIX		0xE0 /* resource for extended messages */
+#define pn_submsg_id		pn_msg_u.base.pn_submsg_id
+#define pn_e_submsg_id		pn_msg_u.ext.pn_e_submsg_id
+#define pn_e_res_id		pn_msg_u.ext.pn_e_res_id
+#define pn_data			pn_msg_u.base.pn_data
+#define pn_e_data		pn_msg_u.ext.pn_e_data
+
+/* data for unreachable errors */
+#define PN_COMM_SERVICE_NOT_IDENTIFIED_RESP	0x01
+#define PN_COMM_ISA_ENTITY_NOT_REACHABLE_RESP	0x14
+#define pn_orig_msg_id		pn_data[0]
+#define pn_status		pn_data[1]
+#define pn_e_orig_msg_id	pn_e_data[0]
+#define pn_e_status		pn_e_data[1]
+
 /* Phonet socket address structure */
 struct sockaddr_pn {
 	sa_family_t spn_family;
diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index 1c6f7e7..d4e7250 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -60,6 +60,11 @@ static inline struct phonethdr *pn_hdr(struct sk_buff *skb)
 	return (struct phonethdr *)skb_network_header(skb);
 }
 
+static inline struct phonetmsg *pn_msg(struct sk_buff *skb)
+{
+	return (struct phonetmsg *)skb_transport_header(skb);
+}
+
 /*
  * Get the other party's sockaddr from received skb. The skb begins
  * with a Phonet header.
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 50dc258..1d8df6b 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -132,7 +132,7 @@ EXPORT_SYMBOL(phonet_header_ops);
  * Prepends an ISI header and sends a datagram.
  */
 static int pn_send(struct sk_buff *skb, struct net_device *dev,
-			u16 dst, u16 src, u8 res)
+			u16 dst, u16 src, u8 res, u8 irq)
 {
 	struct phonethdr *ph;
 	int err;
@@ -163,7 +163,10 @@ static int pn_send(struct sk_buff *skb, struct net_device *dev,
 		skb_reset_mac_header(skb);
 		skb->pkt_type = PACKET_LOOPBACK;
 		skb_orphan(skb);
-		netif_rx_ni(skb);
+		if (irq)
+			netif_rx(skb);
+		else
+			netif_rx_ni(skb);
 		err = 0;
 	} else {
 		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
@@ -181,6 +184,19 @@ drop:
 	return err;
 }
 
+static int pn_raw_send(const void *data, int len, struct net_device *dev,
+			u16 dst, u16 src, u8 res)
+{
+	struct sk_buff *skb = alloc_skb(MAX_PHONET_HEADER + len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	skb_reserve(skb, MAX_PHONET_HEADER);
+	__skb_put(skb, len);
+	skb_copy_to_linear_data(skb, data, len);
+	return pn_send(skb, dev, dst, src, res, 1);
+}
+
 /*
  * Create a Phonet header for the skb and send it out. Returns
  * non-zero error code if failed. The skb is freed then.
@@ -211,7 +227,7 @@ int pn_skb_send(struct sock *sk, struct sk_buff *skb,
 		src = pn_object(saddr, pn_obj(src));
 
 	err = pn_send(skb, dev, pn_sockaddr_get_object(target),
-			src, pn_sockaddr_get_resource(target));
+			src, pn_sockaddr_get_resource(target), 0);
 	dev_put(dev);
 	return err;
 
@@ -223,6 +239,73 @@ drop:
 }
 EXPORT_SYMBOL(pn_skb_send);
 
+/* Do not send an error message in response to an error message */
+static inline int can_respond(struct sk_buff *skb)
+{
+	const struct phonethdr *ph;
+	const struct phonetmsg *pm;
+	u8 submsg_id;
+
+	if (!pskb_may_pull(skb, 3))
+		return 0;
+
+	ph = pn_hdr(skb);
+	if (phonet_address_get(skb->dev, ph->pn_rdev) != ph->pn_rdev)
+		return 0; /* we are not the destination */
+	if (ph->pn_res == PN_PREFIX && !pskb_may_pull(skb, 5))
+		return 0;
+
+	ph = pn_hdr(skb); /* re-acquires the pointer */
+	pm = pn_msg(skb);
+	if (pm->pn_msg_id != PN_COMMON_MESSAGE)
+		return 1;
+	submsg_id = (ph->pn_res == PN_PREFIX)
+		? pm->pn_e_submsg_id : pm->pn_submsg_id;
+	if (submsg_id != PN_COMM_ISA_ENTITY_NOT_REACHABLE_RESP &&
+		pm->pn_e_submsg_id != PN_COMM_SERVICE_NOT_IDENTIFIED_RESP)
+		return 1;
+	return 0;
+}
+
+static int send_obj_unreachable(struct sk_buff *rskb)
+{
+	const struct phonethdr *oph = pn_hdr(rskb);
+	const struct phonetmsg *opm = pn_msg(rskb);
+	struct phonetmsg resp;
+
+	memset(&resp, 0, sizeof(resp));
+	resp.pn_trans_id = opm->pn_trans_id;
+	resp.pn_msg_id = PN_COMMON_MESSAGE;
+	if (oph->pn_res == PN_PREFIX) {
+		resp.pn_e_res_id = opm->pn_e_res_id;
+		resp.pn_e_submsg_id = PN_COMM_ISA_ENTITY_NOT_REACHABLE_RESP;
+		resp.pn_e_orig_msg_id = opm->pn_msg_id;
+		resp.pn_e_status = 0;
+	} else {
+		resp.pn_submsg_id = PN_COMM_ISA_ENTITY_NOT_REACHABLE_RESP;
+		resp.pn_orig_msg_id = opm->pn_msg_id;
+		resp.pn_status = 0;
+	}
+	return pn_raw_send(&resp, sizeof(resp), rskb->dev,
+				pn_object(oph->pn_sdev, oph->pn_sobj),
+				pn_object(oph->pn_rdev, oph->pn_robj),
+				oph->pn_res);
+}
+
+static int send_reset_indications(struct sk_buff *rskb)
+{
+	struct phonethdr *oph = pn_hdr(rskb);
+	static const u8 data[4] = {
+		0x00 /* trans ID */, 0x10 /* subscribe msg */,
+		0x00 /* subscription count */, 0x00 /* dummy */
+	};
+
+	return pn_raw_send(data, sizeof(data), rskb->dev,
+				pn_object(oph->pn_sdev, 0x00),
+				pn_object(oph->pn_rdev, oph->pn_robj), 0x10);
+}
+
+
 /* packet type functions */
 
 /*
@@ -260,8 +343,13 @@ static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto out; /* currently, we cannot be device 0 */
 
 	sk = pn_find_sock_by_sa(&sa);
-	if (sk == NULL)
+	if (sk == NULL) {
+		if (can_respond(skb)) {
+			send_obj_unreachable(skb);
+			send_reset_indications(skb);
+		}
 		goto out;
+	}
 
 	/* Push data to the socket (or other sockets connected to it). */
 	return sk_receive_skb(sk, skb, 0);
-- 
1.5.4.3

