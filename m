From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v3 7/9] amd-xgbe: Remove Tx coalescing
Date: Fri, 20 Mar 2015 11:50:28 -0500
Message-ID: <20150320165028.13799.29483.stgit@tlendack-t1.amdoffice.net>
References: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0143.outbound.protection.outlook.com ([157.56.111.143]:12000
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752108AbbCTQuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 12:50:35 -0400
In-Reply-To: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Tx coalescing support in the driver was a software implementation
for something lacking in the hardware. Using hrtimers, the idea was to
trigger a timer interrupt after having queued a packet for transmit.
Unfortunately, as the timer value was lowered, the timer expired before
the hardware actually did the transmit and so it was racey and resulted
in unnecessary interrupts.

Remove the Tx coalescing support and hrtimer and replace with a Tx timer
that is used as a reclaim timer in case of inactivity.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |    7 +++----
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |   16 +++++-----------
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |    6 ++----
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    4 ++--
 4 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index e165d06..80dd7a9 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1367,12 +1367,11 @@ static void xgbe_tx_start_xmit(struct xgbe_channel *channel,
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_TDTR_LO,
 			  lower_32_bits(rdata->rdesc_dma));
 
-	/* Start the Tx coalescing timer */
+	/* Start the Tx timer */
 	if (pdata->tx_usecs && !channel->tx_timer_active) {
 		channel->tx_timer_active = 1;
-		hrtimer_start(&channel->tx_timer,
-			      ktime_set(0, pdata->tx_usecs * NSEC_PER_USEC),
-			      HRTIMER_MODE_REL);
+		mod_timer(&channel->tx_timer,
+			  jiffies + usecs_to_jiffies(pdata->tx_usecs));
 	}
 
 	ring->tx.xmit_more = 0;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index ef4625e..122a631 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -411,11 +411,9 @@ static irqreturn_t xgbe_dma_isr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static enum hrtimer_restart xgbe_tx_timer(struct hrtimer *timer)
+static void xgbe_tx_timer(unsigned long data)
 {
-	struct xgbe_channel *channel = container_of(timer,
-						    struct xgbe_channel,
-						    tx_timer);
+	struct xgbe_channel *channel = (struct xgbe_channel *)data;
 	struct xgbe_prv_data *pdata = channel->pdata;
 	struct napi_struct *napi;
 
@@ -437,8 +435,6 @@ static enum hrtimer_restart xgbe_tx_timer(struct hrtimer *timer)
 	channel->tx_timer_active = 0;
 
 	DBGPR("<--xgbe_tx_timer\n");
-
-	return HRTIMER_NORESTART;
 }
 
 static void xgbe_init_tx_timers(struct xgbe_prv_data *pdata)
@@ -454,9 +450,8 @@ static void xgbe_init_tx_timers(struct xgbe_prv_data *pdata)
 			break;
 
 		DBGPR("  %s adding tx timer\n", channel->name);
-		hrtimer_init(&channel->tx_timer, CLOCK_MONOTONIC,
-			     HRTIMER_MODE_REL);
-		channel->tx_timer.function = xgbe_tx_timer;
+		setup_timer(&channel->tx_timer, xgbe_tx_timer,
+			    (unsigned long)channel);
 	}
 
 	DBGPR("<--xgbe_init_tx_timers\n");
@@ -475,8 +470,7 @@ static void xgbe_stop_tx_timers(struct xgbe_prv_data *pdata)
 			break;
 
 		DBGPR("  %s deleting tx timer\n", channel->name);
-		channel->tx_timer_active = 0;
-		hrtimer_cancel(&channel->tx_timer);
+		del_timer_sync(&channel->tx_timer);
 	}
 
 	DBGPR("<--xgbe_stop_tx_timers\n");
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 43e5571..376d6a5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -388,7 +388,6 @@ static int xgbe_get_coalesce(struct net_device *netdev,
 	ec->rx_coalesce_usecs = hw_if->riwt_to_usec(pdata, riwt);
 	ec->rx_max_coalesced_frames = pdata->rx_frames;
 
-	ec->tx_coalesce_usecs = pdata->tx_usecs;
 	ec->tx_max_coalesced_frames = pdata->tx_frames;
 
 	DBGPR("<--xgbe_get_coalesce\n");
@@ -402,13 +401,14 @@ static int xgbe_set_coalesce(struct net_device *netdev,
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	unsigned int rx_frames, rx_riwt, rx_usecs;
-	unsigned int tx_frames, tx_usecs;
+	unsigned int tx_frames;
 
 	DBGPR("-->xgbe_set_coalesce\n");
 
 	/* Check for not supported parameters  */
 	if ((ec->rx_coalesce_usecs_irq) ||
 	    (ec->rx_max_coalesced_frames_irq) ||
+	    (ec->tx_coalesce_usecs) ||
 	    (ec->tx_coalesce_usecs_irq) ||
 	    (ec->tx_max_coalesced_frames_irq) ||
 	    (ec->stats_block_coalesce_usecs) ||
@@ -457,7 +457,6 @@ static int xgbe_set_coalesce(struct net_device *netdev,
 		return -EINVAL;
 	}
 
-	tx_usecs = ec->tx_coalesce_usecs;
 	tx_frames = ec->tx_max_coalesced_frames;
 
 	/* Check the bounds of values for Tx */
@@ -471,7 +470,6 @@ static int xgbe_set_coalesce(struct net_device *netdev,
 	pdata->rx_frames = rx_frames;
 	hw_if->config_rx_coalesce(pdata);
 
-	pdata->tx_usecs = tx_usecs;
 	pdata->tx_frames = tx_frames;
 	hw_if->config_tx_coalesce(pdata);
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index bfe11fb..72b8f27 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -222,7 +222,7 @@
 	 ((_idx) & ((_ring)->rdesc_count - 1)))
 
 /* Default coalescing parameters */
-#define XGMAC_INIT_DMA_TX_USECS		50
+#define XGMAC_INIT_DMA_TX_USECS		1000
 #define XGMAC_INIT_DMA_TX_FRAMES	25
 
 #define XGMAC_MAX_DMA_RIWT		0xff
@@ -410,7 +410,7 @@ struct xgbe_channel {
 	unsigned int saved_ier;
 
 	unsigned int tx_timer_active;
-	struct hrtimer tx_timer;
+	struct timer_list tx_timer;
 
 	struct xgbe_ring *tx_ring;
 	struct xgbe_ring *rx_ring;
