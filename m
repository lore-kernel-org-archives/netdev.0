From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/5] drivers: replace dev->trans_start accesses with dev_trans_start
Date: Tue,  3 May 2016 16:30:59 +0200
Message-ID: <1462285862-30946-3-git-send-email-fw@strlen.de>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	linux-rdma@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462285862-30946-1-git-send-email-fw@strlen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

a trans_start struct member exists twice:
- in struct net_device (legacy)
- in struct netdev_queue

Instead of open-coding dev->trans_start usage to obtain the current
trans_start value, use dev_trans_start() instead.

This is not exactly the same, as dev_trans_start also considers
the trans_start values of the netdev queues owned by the device
and provides the most recent one.

For legacy devices this doesn't matter as dev_trans_start can cope
with netdev trans_start values of 0 (they are ignored).

This is a prerequisite to eventual removal of dev->trans_start.

Cc: linux-rdma@vger.kernel.org
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Checkpatch complains about Lines > 80 but I find line break more ugly.

 drivers/infiniband/ulp/ipoib/ipoib_main.c              | 2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c             | 2 +-
 drivers/net/ethernet/intel/igb/igb_main.c              | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c          | 2 +-
 drivers/net/ethernet/microchip/encx24j600.c            | 2 +-
 drivers/net/ethernet/qualcomm/qca_spi.c                | 2 +-
 drivers/net/fjes/fjes_main.c                           | 2 +-
 drivers/net/hamradio/mkiss.c                           | 2 +-
 drivers/staging/rtl8192e/rtllib_softmac.c              | 2 +-
 drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c | 2 +-
 10 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 80807d6..b940ef1 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1036,7 +1036,7 @@ static void ipoib_timeout(struct net_device *dev)
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
 	ipoib_warn(priv, "transmit timeout: latency %d msecs\n",
-		   jiffies_to_msecs(jiffies - dev->trans_start));
+		   jiffies_to_msecs(jiffies - dev_trans_start(dev)));
 	ipoib_warn(priv, "queue stopped %d, tx_head %u, tx_tail %u\n",
 		   netif_queue_stopped(dev),
 		   priv->tx_head, priv->tx_tail);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a7f16c3..269087c 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -242,7 +242,7 @@ static void e1000e_dump(struct e1000_adapter *adapter)
 		dev_info(&adapter->pdev->dev, "Net device Info\n");
 		pr_info("Device Name     state            trans_start      last_rx\n");
 		pr_info("%-15s %016lX %016lX %016lX\n", netdev->name,
-			netdev->state, netdev->trans_start, netdev->last_rx);
+			netdev->state, dev_trans_start(netdev), netdev->last_rx);
 	}
 
 	/* Print Registers */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8e96c35..7460bdb 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -383,7 +383,7 @@ static void igb_dump(struct igb_adapter *adapter)
 		dev_info(&adapter->pdev->dev, "Net device Info\n");
 		pr_info("Device Name     state            trans_start      last_rx\n");
 		pr_info("%-15s %016lX %016lX %016lX\n", netdev->name,
-			netdev->state, netdev->trans_start, netdev->last_rx);
+			netdev->state, dev_trans_start(netdev), netdev->last_rx);
 	}
 
 	/* Print Registers */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0ef4a15..18dcfc5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -608,7 +608,7 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 		pr_info("%-15s %016lX %016lX %016lX\n",
 			netdev->name,
 			netdev->state,
-			netdev->trans_start,
+			dev_trans_start(netdev),
 			netdev->last_rx);
 	}
 
diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index 7df3183..707283b 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -890,7 +890,7 @@ static void encx24j600_tx_timeout(struct net_device *dev)
 	struct encx24j600_priv *priv = netdev_priv(dev);
 
 	netif_err(priv, tx_err, dev, "TX timeout at %ld, latency %ld\n",
-		  jiffies, jiffies - dev->trans_start);
+		  jiffies, jiffies - dev_trans_start(dev));
 
 	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 1ef0393..82f3c88 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -734,7 +734,7 @@ qcaspi_netdev_tx_timeout(struct net_device *dev)
 	struct qcaspi *qca = netdev_priv(dev);
 
 	netdev_info(qca->net_dev, "Transmit timeout at %ld, latency %ld\n",
-		    jiffies, jiffies - dev->trans_start);
+		    jiffies, jiffies - dev_trans_start(dev));
 	qca->net_dev->stats.tx_errors++;
 	/* Trigger tx queue flush and QCA7000 reset */
 	qca->sync = QCASPI_SYNC_UNKNOWN;
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index bb7e903..7ad3d04 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -471,7 +471,7 @@ static void fjes_tx_stall_task(struct work_struct *work)
 	int i;
 
 	if (((long)jiffies -
-		(long)(netdev->trans_start)) > FJES_TX_TX_STALL_TIMEOUT) {
+		dev_trans_start(netdev)) > FJES_TX_TX_STALL_TIMEOUT) {
 		netif_wake_queue(netdev);
 		return;
 	}
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 85828f1..c685937 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -542,7 +542,7 @@ static netdev_tx_t ax_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * May be we must check transmitter timeout here ?
 		 *      14 Oct 1994 Dmitry Gorodchanin.
 		 */
-		if (time_before(jiffies, dev->trans_start + 20 * HZ)) {
+		if (time_before(jiffies, dev_trans_start(dev) + 20 * HZ)) {
 			/* 20 sec timeout not reached */
 			return NETDEV_TX_BUSY;
 		}
diff --git a/drivers/staging/rtl8192e/rtllib_softmac.c b/drivers/staging/rtl8192e/rtllib_softmac.c
index cfab715..62154e3 100644
--- a/drivers/staging/rtl8192e/rtllib_softmac.c
+++ b/drivers/staging/rtl8192e/rtllib_softmac.c
@@ -1991,7 +1991,7 @@ static short rtllib_sta_ps_sleep(struct rtllib_device *ieee, u64 *time)
 		return 2;
 
 	if (!time_after(jiffies,
-			ieee->dev->trans_start + msecs_to_jiffies(timeout)))
+			dev_trans_start(ieee->dev) + msecs_to_jiffies(timeout)))
 		return 0;
 	if (!time_after(jiffies,
 			ieee->last_rx_ps_time + msecs_to_jiffies(timeout)))
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
index ae1274c..de71450 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
@@ -1737,7 +1737,7 @@ static short ieee80211_sta_ps_sleep(struct ieee80211_device *ieee, u32 *time_h,
 		return 2;
 
 	if(!time_after(jiffies,
-		       ieee->dev->trans_start + msecs_to_jiffies(timeout)))
+		       dev_trans_start(ieee->dev) + msecs_to_jiffies(timeout)))
 		return 0;
 
 	if(!time_after(jiffies,
-- 
2.7.3
