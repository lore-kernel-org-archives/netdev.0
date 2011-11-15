From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v4 6/8] forcedeth: account for dropped RX frames
Date: Tue, 15 Nov 2011 11:25:39 -0800
Message-ID: <005cae310e19433c9f68c178805f16c774e8dedd.1321384662.git.david.decotigny@google.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f74.google.com ([74.125.82.74]:32794 "EHLO
	mail-ww0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757317Ab1KOT0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 14:26:07 -0500
Received: by mail-ww0-f74.google.com with SMTP id 5so146965wwe.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 11:26:07 -0800 (PST)
In-Reply-To: <cover.1321384662.git.david.decotigny@google.com>
In-Reply-To: <cover.1321384662.git.david.decotigny@google.com>
References: <cover.1321384662.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the stats counter for dropped RX frames.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index ff01d5e..a50c839 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -819,6 +819,7 @@ struct fe_priv {
 	u64 stat_rx_packets;
 	u64 stat_rx_bytes; /* not always available in HW */
 	u64 stat_rx_missed_errors;
+	u64 stat_rx_dropped;
 
 	/* media detection workaround.
 	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
@@ -1762,6 +1763,7 @@ nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
 		storage->tx_packets       = np->stat_tx_packets;
 		storage->rx_bytes         = np->stat_rx_bytes;
 		storage->tx_bytes         = np->stat_tx_bytes;
+		storage->rx_dropped       = np->stat_rx_dropped;
 		storage->tx_dropped       = np->stat_tx_dropped;
 		storage->rx_missed_errors = np->stat_rx_missed_errors;
 	} while (u64_stats_fetch_retry(&np->swstats_syncp, syncp_start));
@@ -1826,8 +1828,12 @@ static int nv_alloc_rx(struct net_device *dev)
 				np->put_rx.orig = np->first_rx.orig;
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
-		} else
+		} else {
+			u64_stats_update_begin(&np->swstats_syncp);
+			np->stat_rx_dropped++;
+			u64_stats_update_end(&np->swstats_syncp);
 			return 1;
+		}
 	}
 	return 0;
 }
@@ -1858,8 +1864,12 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 				np->put_rx.ex = np->first_rx.ex;
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
-		} else
+		} else {
+			u64_stats_update_begin(&np->swstats_syncp);
+			np->stat_rx_dropped++;
+			u64_stats_update_end(&np->swstats_syncp);
 			return 1;
+		}
 	}
 	return 0;
 }
-- 
1.7.3.1
