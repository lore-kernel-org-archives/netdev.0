From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/4] packet: Add pre-defragmentation support for ipv4
 fanouts.
Date: Tue, 05 Jul 2011 02:04:26 -0700 (PDT)
Message-ID: <20110705.020426.1881513648974221645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: victor@inliniac.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187Ab1GEJEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 05:04:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The skb->rxhash cannot be properly computed if the
packet is a fragment.  To alleviate this, allow the
AF_PACKET client to ask for defragmentation to be
done at demux time.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/if_packet.h |    1 +
 net/packet/af_packet.c    |   50 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 49 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 1efa1cb..84e684e 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -53,6 +53,7 @@ struct sockaddr_ll {
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
+#define PACKET_FANOUT_FLAG_DEFRAG	0x8000
 
 struct tpacket_stats {
 	unsigned int	tp_packets;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 696d19c..6f381ba 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -223,7 +223,7 @@ struct packet_fanout {
 	int			num_members;
 	u16			id;
 	u8			type;
-	u8			pad;
+	u8			defrag;
 	atomic_t		rr_cur;
 	struct list_head	list;
 	struct sock		*arr[PACKET_FANOUT_MAX];
@@ -447,6 +447,41 @@ static struct sock *fanout_demux_lb(struct packet_fanout *f, struct sk_buff *skb
 	return f->arr[cur];
 }
 
+static struct sk_buff *fanout_check_defrag(struct sk_buff *skb)
+{
+	const struct iphdr *iph;
+	u32 len;
+
+	if (skb->protocol != htons(ETH_P_IP))
+		return skb;
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		return skb;
+
+	iph = ip_hdr(skb);
+	if (iph->ihl < 5 || iph->version != 4)
+		return skb;
+	if (!pskb_may_pull(skb, iph->ihl*4))
+		return skb;
+	iph = ip_hdr(skb);
+	len = ntohs(iph->tot_len);
+	if (skb->len < len || len < (iph->ihl * 4))
+		return skb;
+
+	if (ip_is_fragment(ip_hdr(skb))) {
+		skb = skb_clone(skb, GFP_ATOMIC);
+		if (skb) {
+			if (pskb_trim_rcsum(skb, len))
+				return skb;
+			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+			if (ip_defrag(skb, IP_DEFRAG_AF_PACKET))
+				return NULL;
+			skb->rxhash = 0;
+		}
+	}
+	return skb;
+}
+
 static int packet_rcv_fanout_hash(struct sk_buff *skb, struct net_device *dev,
 				  struct packet_type *pt, struct net_device *orig_dev)
 {
@@ -459,6 +494,12 @@ static int packet_rcv_fanout_hash(struct sk_buff *skb, struct net_device *dev,
 		return 0;
 	}
 
+	if (f->defrag) {
+		skb = fanout_check_defrag(skb);
+		if (!skb)
+			return 0;
+	}
+
 	skb_get_rxhash(skb);
 
 	sk = fanout_demux_hash(f, skb);
@@ -515,10 +556,12 @@ static void __fanout_unlink(struct sock *sk, struct packet_sock *po)
 	spin_unlock(&f->lock);
 }
 
-static int fanout_add(struct sock *sk, u16 id, u8 type)
+static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 {
 	struct packet_sock *po = pkt_sk(sk);
 	struct packet_fanout *f, *match;
+	u8 type = type_flags & 0xff;
+	u8 defrag = (type_flags & PACKET_FANOUT_FLAG_DEFRAG) ? 1 : 0;
 	int err;
 
 	switch (type) {
@@ -544,12 +587,15 @@ static int fanout_add(struct sock *sk, u16 id, u8 type)
 			break;
 		}
 	}
+	if (match && match->defrag != defrag)
+		return -EINVAL;
 	if (!match) {
 		match = kzalloc(sizeof(*match), GFP_KERNEL);
 		if (match) {
 			write_pnet(&match->net, sock_net(sk));
 			match->id = id;
 			match->type = type;
+			match->defrag = defrag;
 			atomic_set(&match->rr_cur, 0);
 			INIT_LIST_HEAD(&match->list);
 			spin_lock_init(&match->lock);
-- 
1.7.5.4

