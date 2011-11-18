From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/6] net: Remove all uses of LL_ALLOCATED_SPACE
Date: Fri, 18 Nov 2011 20:20:04 +0800
Message-ID: <E1RRNQK-0000lM-Ms@gondolin.me.apana.org.au>
References: <20111118121832.GA2868@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	evonlanthen@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, timo.teras@iki.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net: Remove all uses of LL_ALLOCATED_SPACE

The macro LL_ALLOCATED_SPACE was ill-conceived.  It applies the
alignment to the sum of needed_headroom and needed_tailroom.  As
the amount that is then reserved for head room is needed_headroom
with alignment, this means that the tail room left may be too small.

This patch replaces all uses of LL_ALLOCATED_SPACE with the macro
LL_RESERVED_SPACE and direct reference to needed_tailroom.

This also fixes the problem with needed_headroom changing between
allocating the skb and reserving the head room.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/netpoll.c     |    6 ++++--
 net/econet/af_econet.c |    7 +++++--
 net/ieee802154/dgram.c |    7 +++++--
 net/ieee802154/raw.c   |    7 +++++--
 net/packet/af_packet.c |   18 +++++++++++-------
 5 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index cf64c1f..1a7d8e2 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -422,6 +422,7 @@ static void arp_reply(struct sk_buff *skb)
 	struct sk_buff *send_skb;
 	struct netpoll *np, *tmp;
 	unsigned long flags;
+	int hlen, tlen;
 	int hits = 0;
 
 	if (list_empty(&npinfo->rx_np))
@@ -479,8 +480,9 @@ static void arp_reply(struct sk_buff *skb)
 		if (tip != np->local_ip)
 			continue;
 
-		send_skb = find_skb(np, size + LL_ALLOCATED_SPACE(np->dev),
-				    LL_RESERVED_SPACE(np->dev));
+		hlen = LL_RESERVED_SPACE(np->dev);
+		tlen = np->dev->needed_tailroom;
+		send_skb = find_skb(np, size + hlen + tlen, hlen);
 		if (!send_skb)
 			continue;
 
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 1c1f26c..7e717cb 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -322,6 +322,7 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 		/* Real hardware Econet.  We're not worthy etc. */
 #ifdef CONFIG_ECONET_NATIVE
 		unsigned short proto = 0;
+		int hlen, tlen;
 		int res;
 
 		if (len + 15 > dev->mtu) {
@@ -331,12 +332,14 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 		dev_hold(dev);
 
-		skb = sock_alloc_send_skb(sk, len + LL_ALLOCATED_SPACE(dev),
+		hlen = LL_RESERVED_SPACE(dev);
+		tlen = dev->needed_tailroom;
+		skb = sock_alloc_send_skb(sk, len + hlen + tlen,
 					  msg->msg_flags & MSG_DONTWAIT, &err);
 		if (skb == NULL)
 			goto out_unlock;
 
-		skb_reserve(skb, LL_RESERVED_SPACE(dev));
+		skb_reserve(skb, hlen);
 		skb_reset_network_header(skb);
 
 		eb = (struct ec_cb *)&skb->cb;
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index faecf64..1b09eaa 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -209,6 +209,7 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	unsigned mtu;
 	struct sk_buff *skb;
 	struct dgram_sock *ro = dgram_sk(sk);
+	int hlen, tlen;
 	int err;
 
 	if (msg->msg_flags & MSG_OOB) {
@@ -229,13 +230,15 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	mtu = dev->mtu;
 	pr_debug("name = %s, mtu = %u\n", dev->name, mtu);
 
-	skb = sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + size,
+	hlen = LL_RESERVED_SPACE(dev);
+	tlen = dev->needed_tailroom;
+	skb = sock_alloc_send_skb(sk, hlen + tlen + size,
 			msg->msg_flags & MSG_DONTWAIT,
 			&err);
 	if (!skb)
 		goto out_dev;
 
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reserve(skb, hlen);
 
 	skb_reset_network_header(skb);
 
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 10970ca..f96bae8 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -108,6 +108,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct net_device *dev;
 	unsigned mtu;
 	struct sk_buff *skb;
+	int hlen, tlen;
 	int err;
 
 	if (msg->msg_flags & MSG_OOB) {
@@ -137,12 +138,14 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		goto out_dev;
 	}
 
-	skb = sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + size,
+	hlen = LL_RESERVED_SPACE(dev);
+	tlen = dev->needed_tailroom;
+	skb = sock_alloc_send_skb(sk, hlen + tlen + size,
 			msg->msg_flags & MSG_DONTWAIT, &err);
 	if (!skb)
 		goto out_dev;
 
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reserve(skb, hlen);
 
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 82a6f34..71c1a75 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1944,7 +1944,7 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		void *frame, struct net_device *dev, int size_max,
-		__be16 proto, unsigned char *addr)
+		__be16 proto, unsigned char *addr, int hlen)
 {
 	union {
 		struct tpacket_hdr *h1;
@@ -1978,7 +1978,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		return -EMSGSIZE;
 	}
 
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
 
 	data = ph.raw + po->tp_hdrlen - sizeof(struct sockaddr_ll);
@@ -2053,6 +2053,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	unsigned char *addr;
 	int len_sum = 0;
 	int status = 0;
+	int hlen, tlen;
 
 	mutex_lock(&po->pg_vec_lock);
 
@@ -2101,16 +2102,17 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		}
 
 		status = TP_STATUS_SEND_REQUEST;
+		hlen = LL_RESERVED_SPACE(dev);
+		tlen = dev->needed_tailroom;
 		skb = sock_alloc_send_skb(&po->sk,
-				LL_ALLOCATED_SPACE(dev)
-				+ sizeof(struct sockaddr_ll),
+				hlen + tlen + sizeof(struct sockaddr_ll),
 				0, &err);
 
 		if (unlikely(skb == NULL))
 			goto out_status;
 
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
-				addr);
+				addr, hlen);
 
 		if (unlikely(tp_len < 0)) {
 			if (po->tp_loss) {
@@ -2207,6 +2209,7 @@ static int packet_snd(struct socket *sock,
 	int vnet_hdr_len;
 	struct packet_sock *po = pkt_sk(sk);
 	unsigned short gso_type = 0;
+	int hlen, tlen;
 
 	/*
 	 *	Get and verify the address.
@@ -2291,8 +2294,9 @@ static int packet_snd(struct socket *sock,
 		goto out_unlock;
 
 	err = -ENOBUFS;
-	skb = packet_alloc_skb(sk, LL_ALLOCATED_SPACE(dev),
-			       LL_RESERVED_SPACE(dev), len, vnet_hdr.hdr_len,
+	hlen = LL_RESERVED_SPACE(dev);
+	tlen = dev->needed_tailroom;
+	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len, vnet_hdr.hdr_len,
 			       msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto out_unlock;
