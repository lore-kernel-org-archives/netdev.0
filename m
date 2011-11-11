From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v2 07/10] forcedeth: account for dropped RX frames
Date: Thu, 10 Nov 2011 17:31:32 -0800
Message-ID: <d92ce3b825650e1be19baa6379e8dd51d886c65b.1320974990.git.david.decotigny@google.com>
References: <cover.1320974990.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f202.google.com ([209.85.215.202]:63779 "EHLO
	mail-ey0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab1KKBcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 20:32:14 -0500
Received: by eyg5 with SMTP id 5so80452eyg.1
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 17:32:13 -0800 (PST)
In-Reply-To: <cover.1320974990.git.david.decotigny@google.com>
In-Reply-To: <cover.1320974990.git.david.decotigny@google.com>
References: <cover.1320974990.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the stats counter for dropped RX frames.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index cabc121..0a979b8 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -824,6 +824,7 @@ struct fe_priv {
 	/* RX software stats */
 	struct nv_driver_stat stat_rx_bytes; /* not always available in HW */
 	struct nv_driver_stat stat_rx_missed_errors;
+	struct nv_driver_stat stat_rx_dropped;
 
 	/* media detection workaround.
 	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
@@ -1738,6 +1739,7 @@ static void nv_update_stats(struct net_device *dev)
 	/* update software stats */
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_bytes);
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_missed_errors);
+	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_dropped);
 
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_tx_packets);
 	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_tx_dropped);
@@ -1780,6 +1782,8 @@ nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
 		storage->tx_bytes   = np->estats.tx_bytes;
 		storage->rx_errors  = np->estats.rx_errors_total;
 		storage->tx_errors  = np->estats.tx_errors_total;
+		storage->rx_dropped = NV_DRIVER_STAT_GET_TOTAL(
+			&np->stat_rx_dropped);
 		storage->tx_dropped = NV_DRIVER_STAT_GET_TOTAL(
 			&np->stat_tx_dropped);
 
@@ -1835,8 +1839,10 @@ static int nv_alloc_rx(struct net_device *dev)
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
@@ -1867,8 +1873,10 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
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
