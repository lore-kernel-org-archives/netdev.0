From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 2/5] [VLAN]: Add vlan tag into PACKET_AUXDATA
Date: Fri, 11 Apr 2008 22:57:45 +0900
Message-ID: <20080411135745.GB8137@tp64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.179]:42377 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062AbYDKN6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:58:14 -0400
Received: by el-out-1112.google.com with SMTP id v27so373974ele.17
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 06:58:12 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware vlan acceleration feature of netdev strips vlan tag.
This patch put the tag into auxdata if it was stripped.
Since the skb->cb has no additional room for the tag, this patch
eliminates sll_family from the skb->cb which is AF_PACKET always.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/if_packet.h |    1 +
 net/packet/af_packet.c    |   78 +++++++++++++++++++++++++++++++++++----------
 2 files changed, 62 insertions(+), 17 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index ad09609..08ba915 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -57,6 +57,7 @@ struct tpacket_auxdata
 	__u32		tp_snaplen;
 	__u16		tp_mac;
 	__u16		tp_net;
+	__u16		tp_vlan_TCI;
 };
 
 struct tpacket_hdr
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b8b827c..2897aaf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -79,6 +79,7 @@
 #include <linux/poll.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/if_vlan.h>
 
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -191,11 +192,26 @@ struct packet_sock {
 #endif
 };
 
+struct sockaddr_ll_af {
+	/* unsigned short	sll_family; */
+	__be16			sll_protocol;
+	int			sll_ifindex;
+	unsigned short		sll_hatype;
+	unsigned char		sll_pkttype;
+	unsigned char		sll_halen;
+	unsigned char		sll_addr[8];
+} __attribute__ ((packed));
+
+#define BUILD_OFFSET_BUG_ON(ll, offset)					\
+	BUILD_BUG_ON(offsetof(struct sockaddr_ll_af, ll) + offset	\
+		     != offsetof(struct sockaddr_ll, ll));
+
 struct packet_skb_cb {
-	unsigned int origlen;
+	unsigned int		origlen;
+	unsigned short		vlan_TCI;
 	union {
 		struct sockaddr_pkt pkt;
-		struct sockaddr_ll ll;
+		struct sockaddr_ll_af ll_af;
 	} sa;
 };
 
@@ -241,6 +257,7 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct
 {
 	struct sock *sk;
 	struct sockaddr_pkt *spkt;
+	unsigned short tag;
 
 	/*
 	 *	When we registered the protocol we saved the socket in the data
@@ -288,6 +305,13 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct
 	strlcpy(spkt->spkt_device, dev->name, sizeof(spkt->spkt_device));
 	spkt->spkt_protocol = skb->protocol;
 
+	if (dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX))
+		__vlan_hwaccel_get_tag(skb, &tag);
+	else
+		tag = 0;
+
+	PACKET_SKB_CB(skb)->vlan_TCI = tag;
+
 	/*
 	 *	Charge the memory to the socket. This is done specifically
 	 *	to prevent sockets using all the memory up.
@@ -439,11 +463,12 @@ static inline unsigned int run_filter(struct sk_buff *skb, struct sock *sk,
 static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct sock *sk;
-	struct sockaddr_ll *sll;
+	struct sockaddr_ll_af *sll_af;
 	struct packet_sock *po;
 	u8 * skb_head = skb->data;
 	int skb_len = skb->len;
 	unsigned int snaplen, res;
+	unsigned short tag;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -500,17 +525,23 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	BUILD_BUG_ON(sizeof(*PACKET_SKB_CB(skb)) + MAX_ADDR_LEN - 8 >
 		     sizeof(skb->cb));
 
-	sll = &PACKET_SKB_CB(skb)->sa.ll;
-	sll->sll_family = AF_PACKET;
-	sll->sll_hatype = dev->type;
-	sll->sll_protocol = skb->protocol;
-	sll->sll_pkttype = skb->pkt_type;
+	if (dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX))
+		__vlan_hwaccel_get_tag(skb, &tag);
+	else
+		tag = 0;
+
+	sll_af = &PACKET_SKB_CB(skb)->sa.ll_af;
+	sll_af->sll_hatype = dev->type;
+	sll_af->sll_protocol = skb->protocol;
+	sll_af->sll_pkttype = skb->pkt_type;
 	if (unlikely(po->origdev))
-		sll->sll_ifindex = orig_dev->ifindex;
+		sll_af->sll_ifindex = orig_dev->ifindex;
 	else
-		sll->sll_ifindex = dev->ifindex;
+		sll_af->sll_ifindex = dev->ifindex;
 
-	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
+	sll_af->sll_halen = dev_parse_header(skb, sll_af->sll_addr);
+
+	PACKET_SKB_CB(skb)->vlan_TCI = tag;
 
 	PACKET_SKB_CB(skb)->origlen = skb->len;
 
@@ -1034,7 +1065,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
 	int copied, err;
-	struct sockaddr_ll *sll;
+	struct sockaddr_ll_af *sll_af;
 
 	err = -EINVAL;
 	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
@@ -1071,11 +1102,12 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 *	it in now.
 	 */
 
-	sll = &PACKET_SKB_CB(skb)->sa.ll;
+	sll_af = &PACKET_SKB_CB(skb)->sa.ll_af;
 	if (sock->type == SOCK_PACKET)
 		msg->msg_namelen = sizeof(struct sockaddr_pkt);
 	else
-		msg->msg_namelen = sll->sll_halen + offsetof(struct sockaddr_ll, sll_addr);
+		msg->msg_namelen = sll_af->sll_halen
+				   + offsetof(struct sockaddr_ll_af, sll_addr);
 
 	/*
 	 *	You lose any data beyond the buffer you gave. If it worries a
@@ -1095,9 +1127,20 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	sock_recv_timestamp(msg, sk, skb);
 
-	if (msg->msg_name)
-		memcpy(msg->msg_name, &PACKET_SKB_CB(skb)->sa,
-		       msg->msg_namelen);
+	if (msg->msg_name) {
+		struct sockaddr_ll *ll = (struct sockaddr_ll*)msg->msg_name;
+
+		BUILD_OFFSET_BUG_ON(sll_protocol,  sizeof(ll->sll_family));
+		BUILD_OFFSET_BUG_ON(sll_ifindex,  sizeof(ll->sll_family));
+		BUILD_OFFSET_BUG_ON(sll_hatype,  sizeof(ll->sll_family));
+		BUILD_OFFSET_BUG_ON(sll_pkttype,  sizeof(ll->sll_family));
+		BUILD_OFFSET_BUG_ON(sll_halen,  sizeof(ll->sll_family));
+		BUILD_OFFSET_BUG_ON(sll_addr,  sizeof(ll->sll_family));
+
+		ll->sll_family = AF_PACKET;
+		memcpy((unsigned char*)ll + sizeof(ll->sll_family),
+		       &PACKET_SKB_CB(skb)->sa, msg->msg_namelen);
+	}
 
 	if (pkt_sk(sk)->auxdata) {
 		struct tpacket_auxdata aux;
@@ -1109,6 +1152,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		aux.tp_snaplen = skb->len;
 		aux.tp_mac = 0;
 		aux.tp_net = skb_network_offset(skb);
+		aux.tp_vlan_TCI = PACKET_SKB_CB(skb)->vlan_TCI;
 
 		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
 	}
-- 
1.5.4.3


