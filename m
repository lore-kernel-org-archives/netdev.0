From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v4 7/8] forcedeth: new ethtool stat counter for TX timeouts
Date: Tue, 15 Nov 2011 11:25:40 -0800
Message-ID: <52bc9f8b3924e22f6921bbc41be4865030215747.1321384662.git.david.decotigny@google.com>
References: <cover.1321384662.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321384662.git.david.decotigny@google.com>
In-Reply-To: <cover.1321384662.git.david.decotigny@google.com>
References: <cover.1321384662.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change publishes a new ethtool stats: tx_timeout that counts the
number of times the tx_timeout callback was triggered.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index a50c839..7284f40 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -634,6 +634,7 @@ static const struct nv_ethtool_str nv_estats_str[] = {
 	{ "rx_packets" },
 	{ "rx_errors_total" },
 	{ "tx_errors_total" },
+	{ "tx_timeout" },
 
 	/* version 2 stats */
 	{ "tx_deferral" },
@@ -674,6 +675,7 @@ struct nv_ethtool_stats {
 	u64 rx_packets; /* should be ifconfig->rx_packets */
 	u64 rx_errors_total;
 	u64 tx_errors_total;
+	u64 tx_timeout;
 
 	/* version 2 stats */
 	u64 tx_deferral;
@@ -848,6 +850,9 @@ struct fe_priv {
 	u64 stat_tx_bytes;
 	u64 stat_tx_dropped;
 
+	/* TX software stats exported by ethtool */
+	atomic_t stat_tx_timeout;  /* TX timeouts since last nv_update_stats */
+
 	/* msi/msi-x fields */
 	u32 msi_flags;
 	struct msix_entry msi_x_entry[NV_MSI_X_MAX_VECTORS];
@@ -1731,6 +1736,8 @@ static void nv_update_stats(struct net_device *dev)
 		np->estats.tx_multicast += readl(base + NvRegTxMulticast);
 		np->estats.tx_broadcast += readl(base + NvRegTxBroadcast);
 	}
+
+	np->estats.tx_timeout += atomic_xchg(&np->stat_tx_timeout, 0);
 }
 
 /*
@@ -2627,6 +2634,8 @@ static void nv_tx_timeout(struct net_device *dev)
 		}
 	}
 
+	atomic_inc(&np->stat_tx_timeout);
+
 	spin_lock_irq(&np->lock);
 
 	/* 1) stop tx engine */
-- 
1.7.3.1
