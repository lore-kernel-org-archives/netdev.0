From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v1 6/9] forcedeth: account for dropped RX frames
Date: Wed,  9 Nov 2011 14:09:20 -0800
Message-ID: <06463c792db6a8b0abbd71c67cfbb8f1569729f3.1320875577.git.david.decotigny@google.com>
References: <cover.1320875577.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320875577.git.david.decotigny@google.com>
In-Reply-To: <cover.1320875577.git.david.decotigny@google.com>
References: <cover.1320875577.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds the stats counter for dropped RX frames.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 0b4fd1a..85e34b6c 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -818,6 +818,7 @@ struct fe_priv {
 	u32 nic_poll_irq;
 	int rx_ring_size;
 	struct nv_driver_stat stat_rx_missed_errors;
+	struct nv_driver_stat stat_rx_dropped;
 
 	/* media detection workaround.
 	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
@@ -1727,6 +1728,7 @@ static void nv_update_stats(struct net_device *dev)
 	}
 
 	/* update software stats */
+	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_dropped);
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_tx_dropped);
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_missed_errors);
 }
@@ -1759,6 +1761,8 @@ nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
 		storage->tx_bytes   = np->estats.tx_bytes;
 		storage->rx_errors  = np->estats.rx_errors_total;
 		storage->tx_errors  = np->estats.tx_errors_total;
+		storage->rx_dropped = NV_DRIVER_STAT_GET_TOTAL(
+			&np->stat_rx_dropped);
 		storage->tx_dropped = NV_DRIVER_STAT_GET_TOTAL(
 			&np->stat_tx_dropped);
 		storage->multicast  = np->estats.rx_multicast;
@@ -1812,8 +1816,10 @@ static int nv_alloc_rx(struct net_device *dev)
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
@@ -1844,8 +1850,10 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
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
