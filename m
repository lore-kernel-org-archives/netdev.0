From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 8/9] ixgb: add tx timeout counter
Date: Tue, 23 May 2006 11:04:20 -0700
Message-ID: <20060523180420.17428.17568.stgit@gitlost.site>
References: <20060523180302.17428.89125.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:47877 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932128AbWEWR7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:59:22 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523180302.17428.89125.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This adds a TX timeout counter to the ethtool stats, a tx timeout
debug message, and sets the timer to 5 seconds.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb.h         |    1 +
 drivers/net/ixgb/ixgb_ethtool.c |    1 +
 drivers/net/ixgb/ixgb_main.c    |   29 +++++++++++++++++++++++++----
 3 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index a687f12..b9c37fd 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -180,6 +180,7 @@ struct ixgb_adapter {
 	uint64_t hw_csum_tx_good;
 	uint64_t hw_csum_tx_error;
 	uint32_t tx_int_delay;
+	uint32_t tx_timeout_count;
 	boolean_t tx_int_delay_enable;
 	boolean_t detect_tx_hung;
 
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 560b4b6..6d8192f 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -78,6 +78,7 @@ static struct ixgb_stats ixgb_gstrings_s
 	{"tx_heartbeat_errors", IXGB_STAT(net_stats.tx_heartbeat_errors)},
 	{"tx_window_errors", IXGB_STAT(net_stats.tx_window_errors)},
 	{"tx_deferred_ok", IXGB_STAT(stats.dc)},
+	{"tx_timeout_count", IXGB_STAT(tx_timeout_count) },
 	{"rx_long_length_errors", IXGB_STAT(stats.roc)},
 	{"rx_short_length_errors", IXGB_STAT(stats.ruc)},
 #ifdef NETIF_F_TSO
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 4115bf3..da0b919 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -428,7 +428,7 @@ ixgb_probe(struct pci_dev *pdev,
 	netdev->change_mtu = &ixgb_change_mtu;
 	ixgb_set_ethtool_ops(netdev);
 	netdev->tx_timeout = &ixgb_tx_timeout;
-	netdev->watchdog_timeo = HZ;
+	netdev->watchdog_timeo = 5 * HZ;
 #ifdef CONFIG_IXGB_NAPI
 	netdev->poll = &ixgb_clean;
 	netdev->weight = 64;
@@ -1509,6 +1509,7 @@ ixgb_tx_timeout_task(struct net_device *
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
+	adapter->tx_timeout_count++;
 	ixgb_down(adapter, TRUE);
 	ixgb_up(adapter);
 }
@@ -1838,11 +1839,31 @@ ixgb_clean_tx_irq(struct ixgb_adapter *a
 		/* detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = FALSE;
-		if(tx_ring->buffer_info[i].dma &&
-		   time_after(jiffies, tx_ring->buffer_info[i].time_stamp + HZ)
+		if (tx_ring->buffer_info[eop].dma &&
+		   time_after(jiffies, tx_ring->buffer_info[eop].time_stamp + HZ)
 		   && !(IXGB_READ_REG(&adapter->hw, STATUS) &
-			IXGB_STATUS_TXOFF))
+		        IXGB_STATUS_TXOFF)) {
+			/* detected Tx unit hang */
+			DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
+					"  TDH                  <%x>\n"
+					"  TDT                  <%x>\n"
+					"  next_to_use          <%x>\n"
+					"  next_to_clean        <%x>\n"
+					"buffer_info[next_to_clean]\n"
+					"  time_stamp           <%lx>\n"
+					"  next_to_watch        <%x>\n"
+					"  jiffies              <%lx>\n"
+					"  next_to_watch.status <%x>\n",
+				IXGB_READ_REG(&adapter->hw, TDH),
+				IXGB_READ_REG(&adapter->hw, TDT),
+				tx_ring->next_to_use,
+				tx_ring->next_to_clean,
+				tx_ring->buffer_info[eop].time_stamp,
+				eop,
+				jiffies,
+				eop_desc->status);
 			netif_stop_queue(netdev);
+		}
 	}
 
 	return cleaned;



--
Auke Kok <auke-jan.h.kok@intel.com>
