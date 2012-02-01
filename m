From: David Miller <davem@davemloft.net>
Subject: atm: clip: Convert over to dst_neigh_lookup().
Date: Wed, 01 Feb 2012 17:25:05 -0500 (EST)
Message-ID: <20120201.172505.1287833035459070704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050Ab2BAWZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 17:25:07 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q11MP551008160
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 1 Feb 2012 14:25:06 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


CLIP only support ipv4, and this is evidenced by the fact that it
is a device specific extension of arp_tbl, so this conversion is
pretty straightforward.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/atm/clip.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index c12c258..ef95a30 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -328,6 +328,8 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 	struct atmarp_entry *entry;
 	struct neighbour *n;
 	struct atm_vcc *vcc;
+	struct rtable *rt;
+	__be32 *daddr;
 	int old;
 	unsigned long flags;
 
@@ -338,7 +340,12 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
-	n = dst_get_neighbour_noref(dst);
+	rt = (struct rtable *) dst;
+	if (rt->rt_gateway)
+		daddr = &rt->rt_gateway;
+	else
+		daddr = &ip_hdr(skb)->daddr;
+	n = dst_neigh_lookup(dst, daddr);
 	if (!n) {
 		pr_err("NO NEIGHBOUR !\n");
 		dev_kfree_skb(skb);
@@ -358,7 +365,7 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 			dev_kfree_skb(skb);
 			dev->stats.tx_dropped++;
 		}
-		return NETDEV_TX_OK;
+		goto out_release_neigh;
 	}
 	pr_debug("neigh %p, vccs %p\n", entry, entry->vccs);
 	ATM_SKB(skb)->vcc = vcc = entry->vccs->vcc;
@@ -377,14 +384,14 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 	old = xchg(&entry->vccs->xoff, 1);	/* assume XOFF ... */
 	if (old) {
 		pr_warning("XOFF->XOFF transition\n");
-		return NETDEV_TX_OK;
+		goto out_release_neigh;
 	}
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 	vcc->send(vcc, skb);
 	if (atm_may_send(vcc, 0)) {
 		entry->vccs->xoff = 0;
-		return NETDEV_TX_OK;
+		goto out_release_neigh;
 	}
 	spin_lock_irqsave(&clip_priv->xoff_lock, flags);
 	netif_stop_queue(dev);	/* XOFF -> throttle immediately */
@@ -396,6 +403,8 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 	   of the brief netif_stop_queue. If this isn't true or if it
 	   changes, use netif_wake_queue instead. */
 	spin_unlock_irqrestore(&clip_priv->xoff_lock, flags);
+out_release_neigh:
+	neigh_release(n);
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.7.6
