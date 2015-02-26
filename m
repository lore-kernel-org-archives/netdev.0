From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next 4/7] net: packet: use skb->dev as storage for skb orig len instead of skb->cb[]
Date: Thu, 26 Feb 2015 04:10:09 +0200
Message-ID: <1424916612-744-5-git-send-email-eyal.birger@gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	marcel@holtmann.org, netdev@vger.kernel.org,
	Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:45112 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbbBZCKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 21:10:36 -0500
Received: by wgha1 with SMTP id a1so7221566wgh.12
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 18:10:35 -0800 (PST)
In-Reply-To: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of an effort to move skb->dropcount to skb->cb[], 4 bytes
of additional room are needed in skb->cb[] in packet sockets.

Store the skb original length in skb->dev instead of skb->cb[] for
this purpose.

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 net/packet/af_packet.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9c28cec..26889fd 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -216,7 +216,6 @@ static void prb_fill_vlan_info(struct tpacket_kbdq_core *,
 static void packet_flush_mclist(struct sock *sk);
 
 struct packet_skb_cb {
-	unsigned int origlen;
 	union {
 		struct sockaddr_pkt pkt;
 		struct sockaddr_ll ll;
@@ -224,6 +223,7 @@ struct packet_skb_cb {
 };
 
 #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
+#define PACKET_SKB_ORIGLEN(__skb) ((unsigned long *)&(__skb)->dev)
 
 #define GET_PBDQC_FROM_RB(x)	((struct tpacket_kbdq_core *)(&(x)->prb_bdqc))
 #define GET_PBLOCK_DESC(x, bid)	\
@@ -1825,13 +1825,12 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
 
-	PACKET_SKB_CB(skb)->origlen = skb->len;
+	*PACKET_SKB_ORIGLEN(skb) = skb->len;
 
 	if (pskb_trim(skb, snaplen))
 		goto drop_n_acct;
 
 	skb_set_owner_r(skb, sk);
-	skb->dev = NULL;
 	skb_dst_drop(skb);
 
 	/* drop conntrack reference */
@@ -3006,7 +3005,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		aux.tp_status = TP_STATUS_USER;
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			aux.tp_status |= TP_STATUS_CSUMNOTREADY;
-		aux.tp_len = PACKET_SKB_CB(skb)->origlen;
+		aux.tp_len = *PACKET_SKB_ORIGLEN(skb);
 		aux.tp_snaplen = skb->len;
 		aux.tp_mac = 0;
 		aux.tp_net = skb_network_offset(skb);
-- 
2.1.4
