From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v1 7/9] forcedeth: new ethtool stat counter for TX timeouts
Date: Wed,  9 Nov 2011 14:09:21 -0800
Message-ID: <ab1c51e8efa9ecc5071a9460d79c98698bf6e7c5.1320875577.git.david.decotigny@google.com>
References: <cover.1320875577.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Sameer Nanda <snanda@google.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320875577.git.david.decotigny@google.com>
In-Reply-To: <cover.1320875577.git.david.decotigny@google.com>
References: <cover.1320875577.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sameer Nanda <snanda@google.com>

This change publishes a new ethtool stats: tx_timeout that counts the
number of times the tx_timeout callback was triggered.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 85e34b6c..6a6604a 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -633,6 +633,7 @@ static const struct nv_ethtool_str nv_estats_str[] = {
 	{ "rx_packets" },
 	{ "rx_errors_total" },
 	{ "tx_errors_total" },
+	{ "tx_timeout" },
 
 	/* version 2 stats */
 	{ "tx_deferral" },
@@ -673,6 +674,7 @@ struct nv_ethtool_stats {
 	u64 rx_packets;
 	u64 rx_errors_total;
 	u64 tx_errors_total;
+	u64 tx_timeout;
 
 	/* version 2 stats */
 	u64 tx_deferral;
@@ -842,6 +844,7 @@ struct fe_priv {
 	struct nv_skb_map *tx_end_flip;
 	int tx_stop;
 	struct nv_driver_stat stat_tx_dropped;
+	atomic_t stat_tx_timeout;  /* TX timeouts since last nv_update_stats */
 
 	/* msi/msi-x fields */
 	u32 msi_flags;
@@ -1728,6 +1731,7 @@ static void nv_update_stats(struct net_device *dev)
 	}
 
 	/* update software stats */
+	np->estats.tx_timeout += atomic_xchg(&np->stat_tx_timeout, 0);
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_dropped);
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_tx_dropped);
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_missed_errors);
@@ -2590,6 +2594,8 @@ static void nv_tx_timeout(struct net_device *dev)
 		}
 	}
 
+	atomic_inc(&np->stat_tx_timeout);
+
 	spin_lock_irq(&np->lock);
 
 	/* 1) stop tx engine */
-- 
1.7.3.1
