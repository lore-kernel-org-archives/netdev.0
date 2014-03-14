From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 02/10] e1000e: add timeout for TX HW
	time stamping work
Date: Fri, 14 Mar 2014 18:34:33 +0100
Message-ID: <1394818481-7652-3-git-send-email-kubakici@wp.pl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hardware may fail to report time stamp e.g.:
 - when hardware time stamping is not enabled
 - when time stamp is requested shortly after ifup

Timeout time stamp reading work to prevent it from
scheduling itself indefinitely. Report timeout events
via system log and device stats.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   | 2 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c | 1 +
 drivers/net/ethernet/intel/e1000e/netdev.c  | 7 +++++++
 3 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 5325e3e..1471c54 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -262,6 +262,7 @@ struct e1000_adapter {
 	u32 tx_head_addr;
 	u32 tx_fifo_size;
 	u32 tx_dma_failed;
+	u32 tx_hwtstamp_timeouts;
 
 	/* Rx */
 	bool (*clean_rx) (struct e1000_ring *ring, int *work_done,
@@ -334,6 +335,7 @@ struct e1000_adapter {
 	struct hwtstamp_config hwtstamp_config;
 	struct delayed_work systim_overflow_work;
 	struct sk_buff *tx_hwtstamp_skb;
+	unsigned long tx_hwtstamp_start;
 	struct work_struct tx_hwtstamp_work;
 	spinlock_t systim_lock;	/* protects SYSTIML/H regsters */
 	struct cyclecounter cc;
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 3c2898d..cad250b 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -104,6 +104,7 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	E1000_STAT("rx_hwtstamp_cleared", rx_hwtstamp_cleared),
 	E1000_STAT("uncorr_ecc_errors", uncorr_errors),
 	E1000_STAT("corr_ecc_errors", corr_errors),
+	E1000_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 };
 
 #define E1000_GLOBAL_STATS_LEN	ARRAY_SIZE(e1000_gstrings_stats)
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 3f044e7..ccdc977 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1155,6 +1155,12 @@ static void e1000e_tx_hwtstamp_work(struct work_struct *work)
 		skb_tstamp_tx(adapter->tx_hwtstamp_skb, &shhwtstamps);
 		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
 		adapter->tx_hwtstamp_skb = NULL;
+	} else if (time_after(jiffies, adapter->tx_hwtstamp_start
+			      + adapter->tx_timeout_factor * HZ)) {
+		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
+		adapter->tx_hwtstamp_skb = NULL;
+		adapter->tx_hwtstamp_timeouts++;
+		e_warn("clearing Tx timestamp hang");
 	} else {
 		/* reschedule to check later */
 		schedule_work(&adapter->tx_hwtstamp_work);
@@ -5545,6 +5551,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 			tx_flags |= E1000_TX_FLAGS_HWTSTAMP;
 			adapter->tx_hwtstamp_skb = skb_get(skb);
+			adapter->tx_hwtstamp_start = jiffies;
 			schedule_work(&adapter->tx_hwtstamp_work);
 		} else {
 			skb_tx_timestamp(skb);
-- 
1.8.5.3


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
