From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: remove skb_orphan_try()
Date: Thu, 14 Jun 2012 18:42:44 +0200
Message-ID: <1339692164.7491.64.camel@edumazet-glaptop>
References: <1339667417.22704.707.camel@edumazet-glaptop>
	 <20120614.030021.2291563831943273331.davem@davemloft.net>
	 <1339668471.22704.714.camel@edumazet-glaptop>
	 <20120614.033153.258221733380821664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhautbois@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36954 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756138Ab2FNQmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 12:42:49 -0400
Received: by eeit10 with SMTP id t10so648537eei.19
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2012 09:42:48 -0700 (PDT)
In-Reply-To: <20120614.033153.258221733380821664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Thu, 2012-06-14 at 03:31 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>

> > We should have a way to properly park packets in Qdiscs, and only do the
> > orphaning once skb given to real device for 'immediate or so'
> > transmission.
> 
> Ok.

In the other hand, all this stuff happens too late with BQL, since more
packets are parked in a Qdisc instead of being delivered with hot
caches.

Doing the orphaning once packet was enqueued, then dequeued, is probably
not worth adding yet another test in fast path.



[PATCH] net: remove skb_orphan_try()

Orphaning skb in dev_hard_start_xmit() makes bonding behavior
unfriendly for applications sending big UDP bursts : Once packets
pass the bonding device and come to real device, they might hit a full
qdisc and be dropped. Without orphaning, the sender is automatically
throttled because sk->sk_wmemalloc reaches sk->sk_sndbuf (assuming
sk_sndbuf is not too big)

We could try to defer the orphaning adding another test in
dev_hard_start_xmit(), but all this seems of little gain,
now that BQL tends to make packets more likely to be parked
in Qdisc queues instead of NIC TX ring, in cases where performance
matters.

Reverts commits :
fc6055a5ba31 net: Introduce skb_orphan_try()
87fd308cfc6b net: skb_tx_hash() fix relative to skb_orphan_try()
and removes SKBTX_DRV_NEEDS_SK_REF flag

Reported-and-bisected-by: Jean-Michel Hautbois <jhautbois@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |    7 ++-----
 net/can/raw.c          |    3 ---
 net/core/dev.c         |   23 +----------------------
 net/iucv/af_iucv.c     |    1 -
 4 files changed, 3 insertions(+), 31 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b534a1b..642cb73 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -225,14 +225,11 @@ enum {
 	/* device driver is going to provide hardware time stamp */
 	SKBTX_IN_PROGRESS = 1 << 2,
 
-	/* ensure the originating sk reference is available on driver level */
-	SKBTX_DRV_NEEDS_SK_REF = 1 << 3,
-
 	/* device driver supports TX zero-copy buffers */
-	SKBTX_DEV_ZEROCOPY = 1 << 4,
+	SKBTX_DEV_ZEROCOPY = 1 << 3,
 
 	/* generate wifi status information (where possible) */
-	SKBTX_WIFI_STATUS = 1 << 5,
+	SKBTX_WIFI_STATUS = 1 << 4,
 };
 
 /*
diff --git a/net/can/raw.c b/net/can/raw.c
index cde1b4a..46cca3a 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -681,9 +681,6 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (err < 0)
 		goto free_skb;
 
-	/* to be able to check the received tx sock reference in raw_rcv() */
-	skb_shinfo(skb)->tx_flags |= SKBTX_DRV_NEEDS_SK_REF;
-
 	skb->dev = dev;
 	skb->sk  = sk;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index cd09819..6df2140 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2089,25 +2089,6 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
 	return 0;
 }
 
-/*
- * Try to orphan skb early, right before transmission by the device.
- * We cannot orphan skb if tx timestamp is requested or the sk-reference
- * is needed on driver level for other reasons, e.g. see net/can/raw.c
- */
-static inline void skb_orphan_try(struct sk_buff *skb)
-{
-	struct sock *sk = skb->sk;
-
-	if (sk && !skb_shinfo(skb)->tx_flags) {
-		/* skb_tx_hash() wont be able to get sk.
-		 * We copy sk_hash into skb->rxhash
-		 */
-		if (!skb->rxhash)
-			skb->rxhash = sk->sk_hash;
-		skb_orphan(skb);
-	}
-}
-
 static bool can_checksum_protocol(netdev_features_t features, __be16 protocol)
 {
 	return ((features & NETIF_F_GEN_CSUM) ||
@@ -2193,8 +2174,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
 
-		skb_orphan_try(skb);
-
 		features = netif_skb_features(skb);
 
 		if (vlan_tx_tag_present(skb) &&
@@ -2304,7 +2283,7 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 	if (skb->sk && skb->sk->sk_hash)
 		hash = skb->sk->sk_hash;
 	else
-		hash = (__force u16) skb->protocol ^ skb->rxhash;
+		hash = (__force u16) skb->protocol;
 	hash = jhash_1word(hash, hashrnd);
 
 	return (u16) (((u64) hash * qcount) >> 32) + qoffset;
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 07d7d55..cd6f7a9 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -372,7 +372,6 @@ static int afiucv_hs_send(struct iucv_message *imsg, struct sock *sock,
 			skb_trim(skb, skb->dev->mtu);
 	}
 	skb->protocol = ETH_P_AF_IUCV;
-	skb_shinfo(skb)->tx_flags |= SKBTX_DRV_NEEDS_SK_REF;
 	nskb = skb_clone(skb, GFP_ATOMIC);
 	if (!nskb)
 		return -ENOMEM;
