From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v5 08/10] forcedeth: account for dropped RX frames
Date: Tue, 15 Nov 2011 21:15:56 -0800
Message-ID: <ed7284fbf466dee109a5fb6b33ad1d0443403231.1321420513.git.david.decotigny@google.com>
References: <cover.1321420513.git.david.decotigny@google.com>
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
In-Reply-To: <cover.1321420513.git.david.decotigny@google.com>
In-Reply-To: <cover.1321420513.git.david.decotigny@google.com>
References: <cover.1321420513.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds code to update the stats counter for dropped RX frames.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 6aeb0d6..d9b5a4d 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -824,6 +824,7 @@ struct fe_priv {
 	struct nv_driver_stat stat_rx_packets;
 	struct nv_driver_stat stat_rx_bytes; /* not always available in HW */
 	struct nv_driver_stat stat_rx_missed_errors;
+	struct nv_driver_stat stat_rx_dropped;
 
 	/* media detection workaround.
 	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
@@ -1739,6 +1740,7 @@ static void nv_update_stats(struct net_device *dev)
 	/* update software stats */
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_packets);
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_bytes);
+	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_dropped);
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_missed_errors);
 
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_tx_packets);
@@ -1786,6 +1788,8 @@ nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
 			&np->stat_tx_bytes);
 		storage->rx_errors  = np->estats.rx_errors_total;
 		storage->tx_errors  = np->estats.tx_errors_total;
+		storage->rx_dropped = NV_DRIVER_STAT_GET_TOTAL(
+			&np->stat_rx_dropped);
 		storage->tx_dropped = NV_DRIVER_STAT_GET_TOTAL(
 			&np->stat_tx_dropped);
 
@@ -1841,8 +1845,10 @@ static int nv_alloc_rx(struct net_device *dev)
 				np->put_rx.orig = np->first_rx.orig;
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
-		} else
+		} else {
+			NV_DRIVER_STAT_ATOMIC_INC(&np->stat_rx_dropped);
 			return 1;
+		}
 	}
 	return 0;
 }
@@ -1873,8 +1879,10 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 				np->put_rx.ex = np->first_rx.ex;
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
-		} else
+		} else {
+			NV_DRIVER_STAT_ATOMIC_INC(&np->stat_rx_dropped);
 			return 1;
+		}
 	}
 	return 0;
 }
-- 
1.7.3.1
