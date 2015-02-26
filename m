From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 4/7] net: packet: use skb->dev as storage for skb orig len instead of skb->cb[]
Date: Thu, 26 Feb 2015 21:07:01 +0200
Message-ID: <1424977624-649-5-git-send-email-eyal.birger@gmail.com>
References: <1424977624-649-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, shmulik.ladkani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1424977624-649-1-git-send-email-eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

As part of an effort to move skb->dropcount to skb->cb[], 4 bytes
of additional room are needed in skb->cb[] in packet sockets.

Store the skb original length in skb->dev instead of skb->cb[] for
this purpose.

Signed-off-by: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/packet/af_packet.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9c28cec..9d571bc 100644
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
@@ -1757,7 +1757,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct packet_sock *po;
 	u8 *skb_head = skb->data;
 	int skb_len = skb->len;
-	unsigned int snaplen, res;
+	unsigned int snaplen, origlen, res;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -1825,13 +1825,13 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
 
-	PACKET_SKB_CB(skb)->origlen = skb->len;
+	origlen = skb->len;
 
 	if (pskb_trim(skb, snaplen))
 		goto drop_n_acct;
 
 	skb_set_owner_r(skb, sk);
-	skb->dev = NULL;
+	*PACKET_SKB_ORIGLEN(skb) = origlen;
 	skb_dst_drop(skb);
 
 	/* drop conntrack reference */
@@ -3006,7 +3006,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
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
