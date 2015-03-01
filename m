From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next v3 4/7] net: packet: use sockaddr_ll fields as storage for skb original length in recvmsg path
Date: Sun,  1 Mar 2015 14:58:28 +0200
Message-ID: <1425214711-9562-5-git-send-email-eyal.birger@gmail.com>
References: <1425214711-9562-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	linux-bluetooth@vger.kernel.org, marcel@holtmann.org,
	netdev@vger.kernel.org, Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:36031 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbbCAM6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 07:58:53 -0500
In-Reply-To: <1425214711-9562-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of an effort to move skb->dropcount to skb->cb[], 4 bytes
of additional room are needed in skb->cb[] in packet sockets.

Store the skb original length in the first two fields of sockaddr_ll
(sll_family and sll_protocol) as they can be derived from the skb when
needed.

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 net/packet/af_packet.c | 30 ++++++++++++++++++++++++------
 1 file changed, 24 insertions(+), 6 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9c28cec..7eea30b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -216,10 +216,16 @@ static void prb_fill_vlan_info(struct tpacket_kbdq_core *,
 static void packet_flush_mclist(struct sock *sk);
 
 struct packet_skb_cb {
-	unsigned int origlen;
 	union {
 		struct sockaddr_pkt pkt;
-		struct sockaddr_ll ll;
+		union {
+			/* Trick: alias skb original length with
+			 * ll.sll_family and ll.protocol in order
+			 * to save room.
+			 */
+			unsigned int origlen;
+			struct sockaddr_ll ll;
+		};
 	} sa;
 };
 
@@ -1814,9 +1820,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 		     sizeof(skb->cb));
 
 	sll = &PACKET_SKB_CB(skb)->sa.ll;
-	sll->sll_family = AF_PACKET;
 	sll->sll_hatype = dev->type;
-	sll->sll_protocol = skb->protocol;
 	sll->sll_pkttype = skb->pkt_type;
 	if (unlikely(po->origdev))
 		sll->sll_ifindex = orig_dev->ifindex;
@@ -1825,7 +1829,10 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
 
-	PACKET_SKB_CB(skb)->origlen = skb->len;
+	/* sll->sll_family and sll->sll_protocol are set in packet_recvmsg().
+	 * Use their space for storing the original skb length.
+	 */
+	PACKET_SKB_CB(skb)->sa.origlen = skb->len;
 
 	if (pskb_trim(skb, snaplen))
 		goto drop_n_acct;
@@ -2883,6 +2890,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int copied, err;
 	int vnet_hdr_len = 0;
+	unsigned int origlen = 0;
 
 	err = -EINVAL;
 	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT|MSG_ERRQUEUE))
@@ -2982,6 +2990,15 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (err)
 		goto out_free;
 
+	if (sock->type != SOCK_PACKET) {
+		struct sockaddr_ll *sll = &PACKET_SKB_CB(skb)->sa.ll;
+
+		/* Original length was stored in sockaddr_ll fields */
+		origlen = PACKET_SKB_CB(skb)->sa.origlen;
+		sll->sll_family = AF_PACKET;
+		sll->sll_protocol = skb->protocol;
+	}
+
 	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (msg->msg_name) {
@@ -2993,6 +3010,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 			msg->msg_namelen = sizeof(struct sockaddr_pkt);
 		} else {
 			struct sockaddr_ll *sll = &PACKET_SKB_CB(skb)->sa.ll;
+
 			msg->msg_namelen = sll->sll_halen +
 				offsetof(struct sockaddr_ll, sll_addr);
 		}
@@ -3006,7 +3024,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		aux.tp_status = TP_STATUS_USER;
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			aux.tp_status |= TP_STATUS_CSUMNOTREADY;
-		aux.tp_len = PACKET_SKB_CB(skb)->origlen;
+		aux.tp_len = origlen;
 		aux.tp_snaplen = skb->len;
 		aux.tp_mac = 0;
 		aux.tp_net = skb_network_offset(skb);
-- 
2.1.4
