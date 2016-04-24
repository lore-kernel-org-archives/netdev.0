From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 4/6] drivers: net: use NETDEV_TX_OK instead of NETDEV_TX_LOCKED
Date: Sun, 24 Apr 2016 21:38:12 +0200
Message-ID: <1461526694-11367-5-git-send-email-fw@strlen.de>
References: <1461526694-11367-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	linux-parisc@vger.kernel.org, linux-hams@vger.kernel.org,
	Thomas Sailer <t.sailer@alumni.ethz.ch>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461526694-11367-1-git-send-email-fw@strlen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These drivers already call netif_stop_queue() so we should not be called
unless tx space is available.  Just free the skb and return TX_OK.

Followup patch will remove NETDEV_TX_LOCKED from the kernel.

Cc: linux-parisc@vger.kernel.org
Cc: linux-hams@vger.kernel.org
Cc: Thomas Sailer <t.sailer@alumni.ethz.ch>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 checkpatch chokes on this one, tulip uses spaces, not tabs...

 drivers/net/ethernet/amd/7990.c        | 8 +++++---
 drivers/net/ethernet/amd/a2065.c       | 7 +++----
 drivers/net/ethernet/dec/tulip/de4x5.c | 7 +++++--
 drivers/net/hamradio/baycom_epp.c      | 6 ++++--
 drivers/net/hamradio/hdlcdrv.c         | 6 ++++--
 5 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index 66d0b73c..8e75755 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -543,11 +543,13 @@ int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	static int outs;
 	unsigned long flags;
 
-	if (!TX_BUFFS_AVAIL)
-		return NETDEV_TX_LOCKED;
-
 	netif_stop_queue(dev);
 
+	if (!TX_BUFFS_AVAIL) {
+		dev_consume_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
 	skblen = skb->len;
 
 #ifdef DEBUG_DRIVER
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 5613918..2a18d34 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -547,10 +547,8 @@ static netdev_tx_t lance_start_xmit(struct sk_buff *skb,
 
 	local_irq_save(flags);
 
-	if (!lance_tx_buffs_avail(lp)) {
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
+	if (!lance_tx_buffs_avail(lp))
+		goto out_free;
 
 #ifdef DEBUG
 	/* dump the packet */
@@ -573,6 +571,7 @@ static netdev_tx_t lance_start_xmit(struct sk_buff *skb,
 
 	/* Kick the lance: transmit now */
 	ll->rdp = LE_C0_INEA | LE_C0_TDMD;
+ out_free:
 	dev_kfree_skb(skb);
 
 	local_irq_restore(flags);
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 3acde3b..d88fbab 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1465,7 +1465,7 @@ de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 
     netif_stop_queue(dev);
     if (!lp->tx_enable)                   /* Cannot send for now */
-	return NETDEV_TX_LOCKED;
+		goto tx_err;
 
     /*
     ** Clean out the TX ring asynchronously to interrupts - sometimes the
@@ -1478,7 +1478,7 @@ de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 
     /* Test if cache is already locked - requeue skb if so */
     if (test_and_set_bit(0, (void *)&lp->cache.lock) && !lp->interrupt)
-	return NETDEV_TX_LOCKED;
+		goto tx_err;
 
     /* Transmit descriptor ring full or stale skb */
     if (netif_queue_stopped(dev) || (u_long) lp->tx_skb[lp->tx_new] > 1) {
@@ -1519,6 +1519,9 @@ de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
     lp->cache.lock = 0;
 
     return NETDEV_TX_OK;
+tx_err:
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
 }
 
 /*
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 72c9f1f..eb66638 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -780,8 +780,10 @@ static int baycom_send_packet(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	if (bc->skb)
-		return NETDEV_TX_LOCKED;
+	if (bc->skb) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
 	/* strip KISS byte */
 	if (skb->len >= HDLCDRV_MAXFLEN+1 || skb->len < 3) {
 		dev_kfree_skb(skb);
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 49fe59b..4bad0b8 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -412,8 +412,10 @@ static netdev_tx_t hdlcdrv_send_packet(struct sk_buff *skb,
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	if (sm->skb)
-		return NETDEV_TX_LOCKED;
+	if (sm->skb) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
 	netif_stop_queue(dev);
 	sm->skb = skb;
 	return NETDEV_TX_OK;
-- 
2.7.3
