From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/16] sfc: Split MAC stats DMA initiation and completion
Date: Thu, 26 Nov 2009 02:11:35 +0000
Message-ID: <1259201495.2806.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31300 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbZKZCLc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:11:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BB=BFFrom: Steve Hodgson <shodgson@solarflare.com>

Currently we initiate MAC stats DMA and busy-wait for completion when
stats are requested.  We can improve on this with a periodic timer to
initiate and poll for stats, and opportunistically poll when stats are
requested.

Since efx_nic::stats_disable_count and efx_stats_{disable,enable}()
are Falcon-specific, rename them and move them accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |   48 ++++----------
 drivers/net/sfc/efx.h           |    2 -
 drivers/net/sfc/falcon.c        |  131 ++++++++++++++++++++++++++++++-=
--------
 drivers/net/sfc/falcon.h        |   12 +++-
 drivers/net/sfc/falcon_boards.c |   10 ++--
 drivers/net/sfc/falcon_gmac.c   |    5 --
 drivers/net/sfc/falcon_xmac.c   |   13 +++--
 drivers/net/sfc/net_driver.h    |    2 -
 drivers/net/sfc/tenxpress.c     |    4 +-
 9 files changed, 139 insertions(+), 88 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 155aa1c..41ca5db 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -637,6 +637,7 @@ void __efx_reconfigure_port(struct efx_nic *efx)
 		netif_addr_unlock_bh(efx->net_dev);
 	}
=20
+	falcon_stop_nic_stats(efx);
 	falcon_deconfigure_mac_wrapper(efx);
=20
 	/* Reconfigure the PHY, disabling transmit in mac level loopback. */
@@ -651,6 +652,8 @@ void __efx_reconfigure_port(struct efx_nic *efx)
=20
 	efx->mac_op->reconfigure(efx);
=20
+	falcon_start_nic_stats(efx);
+
 	/* Inform kernel of loss/gain of carrier */
 	efx_link_status_changed(efx);
 	return;
@@ -749,7 +752,6 @@ static int efx_init_port(struct efx_nic *efx)
 	efx->mac_op->reconfigure(efx);
=20
 	efx->port_initialized =3D true;
-	efx_stats_enable(efx);
=20
 	mutex_unlock(&efx->mac_lock);
 	return 0;
@@ -802,7 +804,6 @@ static void efx_fini_port(struct efx_nic *efx)
 	if (!efx->port_initialized)
 		return;
=20
-	efx_stats_disable(efx);
 	efx->phy_op->fini(efx);
 	efx->port_initialized =3D false;
=20
@@ -1158,6 +1159,8 @@ static void efx_start_all(struct efx_nic *efx)
 	if (efx->state =3D=3D STATE_RUNNING)
 		queue_delayed_work(efx->workqueue, &efx->monitor_work,
 				   efx_monitor_interval);
+
+	falcon_start_nic_stats(efx);
 }
=20
 /* Flush all delayed work. Should only be called when no more delayed =
work
@@ -1195,6 +1198,8 @@ static void efx_stop_all(struct efx_nic *efx)
 	if (!efx->port_enabled)
 		return;
=20
+	falcon_stop_nic_stats(efx);
+
 	/* Disable interrupts and wait for ISR to complete */
 	falcon_disable_interrupts(efx);
 	if (efx->legacy_irq)
@@ -1438,20 +1443,6 @@ static int efx_net_stop(struct net_device *net_d=
ev)
 	return 0;
 }
=20
-void efx_stats_disable(struct efx_nic *efx)
-{
-	spin_lock(&efx->stats_lock);
-	++efx->stats_disable_count;
-	spin_unlock(&efx->stats_lock);
-}
-
-void efx_stats_enable(struct efx_nic *efx)
-{
-	spin_lock(&efx->stats_lock);
-	--efx->stats_disable_count;
-	spin_unlock(&efx->stats_lock);
-}
-
 /* Context: process, dev_base_lock or RTNL held, non-blocking. */
 static struct net_device_stats *efx_net_stats(struct net_device *net_d=
ev)
 {
@@ -1459,17 +1450,9 @@ static struct net_device_stats *efx_net_stats(st=
ruct net_device *net_dev)
 	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
 	struct net_device_stats *stats =3D &net_dev->stats;
=20
-	/* Update stats if possible, but do not wait if another thread
-	 * is updating them or if MAC stats fetches are temporarily
-	 * disabled; slightly stale stats are acceptable.
-	 */
-	if (!spin_trylock(&efx->stats_lock))
-		return stats;
-	if (!efx->stats_disable_count) {
-		efx->mac_op->update_stats(efx);
-		falcon_update_nic_stats(efx);
-	}
-	spin_unlock(&efx->stats_lock);
+	spin_lock_bh(&efx->stats_lock);
+	falcon_update_nic_stats(efx);
+	spin_unlock_bh(&efx->stats_lock);
=20
 	stats->rx_packets =3D mac_stats->rx_packets;
 	stats->tx_packets =3D mac_stats->tx_packets;
@@ -1726,7 +1709,6 @@ void efx_reset_down(struct efx_nic *efx, enum res=
et_type method,
 {
 	EFX_ASSERT_RESET_SERIALISED(efx);
=20
-	efx_stats_disable(efx);
 	efx_stop_all(efx);
 	mutex_lock(&efx->mac_lock);
 	mutex_lock(&efx->spi_lock);
@@ -1776,10 +1758,8 @@ int efx_reset_up(struct efx_nic *efx, enum reset=
_type method,
 	mutex_unlock(&efx->spi_lock);
 	mutex_unlock(&efx->mac_lock);
=20
-	if (ok) {
+	if (ok)
 		efx_start_all(efx);
-		efx_stats_enable(efx);
-	}
 	return rc;
 }
=20
@@ -1977,7 +1957,6 @@ static int efx_init_struct(struct efx_nic *efx, s=
truct efx_nic_type *type,
 	efx->rx_checksum_enabled =3D true;
 	spin_lock_init(&efx->netif_stop_lock);
 	spin_lock_init(&efx->stats_lock);
-	efx->stats_disable_count =3D 1;
 	mutex_init(&efx->mac_lock);
 	efx->mac_op =3D &efx_dummy_mac_operations;
 	efx->phy_op =3D &efx_dummy_phy_operations;
@@ -2219,9 +2198,8 @@ static int __devinit efx_pci_probe(struct pci_dev=
 *pci_dev,
 		goto fail4;
 	}
=20
-	/* Switch to the running state before we expose the device to
-	 * the OS.  This is to ensure that the initial gathering of
-	 * MAC stats succeeds. */
+	/* Switch to the running state before we expose the device to the OS,
+	 * so that dev_open()|efx_start_all() will actually start the device =
*/
 	efx->state =3D STATE_RUNNING;
=20
 	rc =3D efx_register_netdev(efx);
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 7acf821..01b93f9 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -60,8 +60,6 @@ extern void efx_process_channel_now(struct efx_channe=
l *channel);
 #define EFX_EVQ_MASK (EFX_EVQ_SIZE - 1)
=20
 /* Ports */
-extern void efx_stats_disable(struct efx_nic *efx);
-extern void efx_stats_enable(struct efx_nic *efx);
 extern void efx_reconfigure_port(struct efx_nic *efx);
 extern void __efx_reconfigure_port(struct efx_nic *efx);
=20
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 9eec885..3ab2daf 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -36,8 +36,6 @@
  *********************************************************************=
*****
  */
=20
-static int disable_dma_stats;
-
 /* This is set to 16 for a good reason.  In summary, if larger than
  * 16, the descriptor cache holds more than a default socket
  * buffer's worth of packets (for UDP we can only have at most one
@@ -1890,7 +1888,7 @@ static int falcon_reset_macs(struct efx_nic *efx)
=20
 	/* MAC stats will fail whilst the TX fifo is draining. Serialise
 	 * the drain sequence with the statistics fetch */
-	efx_stats_disable(efx);
+	falcon_stop_nic_stats(efx);
=20
 	efx_reado(efx, &reg, FR_AB_MAC_CTRL);
 	EFX_SET_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN, 1);
@@ -1920,13 +1918,13 @@ static int falcon_reset_macs(struct efx_nic *ef=
x)
 		udelay(10);
 	}
=20
-	efx_stats_enable(efx);
-
 	/* If we've reset the EM block and the link is up, then
 	 * we'll have to kick the XAUI link so the PHY can recover */
 	if (efx->link_state.up && EFX_IS10G(efx) && EFX_WORKAROUND_5147(efx))
 		falcon_reset_xaui(efx);
=20
+	falcon_start_nic_stats(efx);
+
 	return 0;
 }
=20
@@ -2010,25 +2008,19 @@ void falcon_reconfigure_mac_wrapper(struct efx_=
nic *efx)
 	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
 }
=20
-int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
+static void falcon_stats_request(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data =3D efx->nic_data;
 	efx_oword_t reg;
-	u32 *dma_done;
-	int i;
=20
-	if (disable_dma_stats)
-		return 0;
+	WARN_ON(nic_data->stats_pending);
+	WARN_ON(nic_data->stats_disable_count);
=20
-	/* Statistics fetch will fail if the MAC is in TX drain */
-	if (falcon_rev(efx) >=3D FALCON_REV_B0) {
-		efx_oword_t temp;
-		efx_reado(efx, &temp, FR_AB_MAC_CTRL);
-		if (EFX_OWORD_FIELD(temp, FRF_BB_TXFIFO_DRAIN_EN))
-			return 0;
-	}
+	if (nic_data->stats_dma_done =3D=3D NULL)
+		return;	/* no mac selected */
=20
-	dma_done =3D (efx->stats_buffer.addr + done_offset);
-	*dma_done =3D FALCON_STATS_NOT_DONE;
+	*nic_data->stats_dma_done =3D FALCON_STATS_NOT_DONE;
+	nic_data->stats_pending =3D true;
 	wmb(); /* ensure done flag is clear */
=20
 	/* Initiate DMA transfer of stats */
@@ -2038,17 +2030,37 @@ int falcon_dma_stats(struct efx_nic *efx, unsig=
ned int done_offset)
 			     efx->stats_buffer.dma_addr);
 	efx_writeo(efx, &reg, FR_AB_MAC_STAT_DMA);
=20
-	/* Wait for transfer to complete */
-	for (i =3D 0; i < 400; i++) {
-		if (*(volatile u32 *)dma_done =3D=3D FALCON_STATS_DONE) {
-			rmb(); /* Ensure the stats are valid. */
-			return 0;
-		}
-		udelay(10);
+	mod_timer(&nic_data->stats_timer, round_jiffies_up(jiffies + HZ / 2))=
;
+}
+
+static void falcon_stats_complete(struct efx_nic *efx)
+{
+	struct falcon_nic_data *nic_data =3D efx->nic_data;
+
+	if (!nic_data->stats_pending)
+		return;
+
+	nic_data->stats_pending =3D 0;
+	if (*nic_data->stats_dma_done =3D=3D FALCON_STATS_DONE) {
+		rmb(); /* read the done flag before the stats */
+		efx->mac_op->update_stats(efx);
+	} else {
+		EFX_ERR(efx, "timed out waiting for statistics\n");
 	}
+}
=20
-	EFX_ERR(efx, "timed out waiting for statistics\n");
-	return -ETIMEDOUT;
+static void falcon_stats_timer_func(unsigned long context)
+{
+	struct efx_nic *efx =3D (struct efx_nic *)context;
+	struct falcon_nic_data *nic_data =3D efx->nic_data;
+
+	spin_lock(&efx->stats_lock);
+
+	falcon_stats_complete(efx);
+	if (nic_data->stats_disable_count =3D=3D 0)
+		falcon_stats_request(efx);
+
+	spin_unlock(&efx->stats_lock);
 }
=20
 /*********************************************************************=
*****
@@ -2206,10 +2218,12 @@ static void falcon_clock_mac(struct efx_nic *ef=
x)
 int falcon_switch_mac(struct efx_nic *efx)
 {
 	struct efx_mac_operations *old_mac_op =3D efx->mac_op;
+	struct falcon_nic_data *nic_data =3D efx->nic_data;
+	unsigned int stats_done_offset;
 	int rc =3D 0;
=20
 	/* Don't try to fetch MAC stats while we're switching MACs */
-	efx_stats_disable(efx);
+	falcon_stop_nic_stats(efx);
=20
 	/* Internal loopbacks override the phy speed setting */
 	if (efx->loopback_mode =3D=3D LOOPBACK_GMAC) {
@@ -2224,6 +2238,12 @@ int falcon_switch_mac(struct efx_nic *efx)
 	efx->mac_op =3D (EFX_IS10G(efx) ?
 		       &falcon_xmac_operations : &falcon_gmac_operations);
=20
+	if (EFX_IS10G(efx))
+		stats_done_offset =3D XgDmaDone_offset;
+	else
+		stats_done_offset =3D GDmaDone_offset;
+	nic_data->stats_dma_done =3D efx->stats_buffer.addr + stats_done_offs=
et;
+
 	if (old_mac_op =3D=3D efx->mac_op)
 		goto out;
=20
@@ -2235,7 +2255,7 @@ int falcon_switch_mac(struct efx_nic *efx)
=20
 	rc =3D falcon_reset_macs(efx);
 out:
-	efx_stats_enable(efx);
+	falcon_start_nic_stats(efx);
 	return rc;
 }
=20
@@ -2900,6 +2920,10 @@ int falcon_probe_nic(struct efx_nic *efx)
 		goto fail6;
 	}
=20
+	nic_data->stats_disable_count =3D 1;
+	setup_timer(&nic_data->stats_timer, &falcon_stats_timer_func,
+		    (unsigned long)efx);
+
 	return 0;
=20
  fail6:
@@ -3125,11 +3149,58 @@ void falcon_remove_nic(struct efx_nic *efx)
=20
 void falcon_update_nic_stats(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data =3D efx->nic_data;
 	efx_oword_t cnt;
=20
+	if (nic_data->stats_disable_count)
+		return;
+
 	efx_reado(efx, &cnt, FR_AZ_RX_NODESC_DROP);
 	efx->n_rx_nodesc_drop_cnt +=3D
 		EFX_OWORD_FIELD(cnt, FRF_AB_RX_NODESC_DROP_CNT);
+
+	if (nic_data->stats_pending &&
+	    *nic_data->stats_dma_done =3D=3D FALCON_STATS_DONE) {
+		nic_data->stats_pending =3D false;
+		rmb(); /* read the done flag before the stats */
+		efx->mac_op->update_stats(efx);
+	}
+}
+
+void falcon_start_nic_stats(struct efx_nic *efx)
+{
+	struct falcon_nic_data *nic_data =3D efx->nic_data;
+
+	spin_lock_bh(&efx->stats_lock);
+	if (--nic_data->stats_disable_count =3D=3D 0)
+		falcon_stats_request(efx);
+	spin_unlock_bh(&efx->stats_lock);
+}
+
+void falcon_stop_nic_stats(struct efx_nic *efx)
+{
+	struct falcon_nic_data *nic_data =3D efx->nic_data;
+	int i;
+
+	might_sleep();
+
+	spin_lock_bh(&efx->stats_lock);
+	++nic_data->stats_disable_count;
+	spin_unlock_bh(&efx->stats_lock);
+
+	del_timer_sync(&nic_data->stats_timer);
+
+	/* Wait enough time for the most recent transfer to
+	 * complete. */
+	for (i =3D 0; i < 4 && nic_data->stats_pending; i++) {
+		if (*nic_data->stats_dma_done =3D=3D FALCON_STATS_DONE)
+			break;
+		msleep(1);
+	}
+
+	spin_lock_bh(&efx->stats_lock);
+	falcon_stats_complete(efx);
+	spin_unlock_bh(&efx->stats_lock);
 }
=20
 /*********************************************************************=
*****
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index b331889..61fab0a 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -75,10 +75,18 @@ struct falcon_board {
  * struct falcon_nic_data - Falcon NIC state
  * @pci_dev2: Secondary function of Falcon A
  * @board: Board state and functions
+ * @stats_disable_count: Nest count for disabling statistics fetches
+ * @stats_pending: Is there a pending DMA of MAC statistics.
+ * @stats_timer: A timer for regularly fetching MAC statistics.
+ * @stats_dma_done: Pointer to the flag which indicates DMA completion=
=2E
  */
 struct falcon_nic_data {
 	struct pci_dev *pci_dev2;
 	struct falcon_board board;
+	unsigned int stats_disable_count;
+	bool stats_pending;
+	struct timer_list stats_timer;
+	u32 *stats_dma_done;
 };
=20
 static inline struct falcon_board *falcon_board(struct efx_nic *efx)
@@ -128,8 +136,6 @@ extern void falcon_remove_port(struct efx_nic *efx)=
;
 /* MAC/PHY */
 extern int falcon_switch_mac(struct efx_nic *efx);
 extern bool falcon_xaui_link_ok(struct efx_nic *efx);
-extern int falcon_dma_stats(struct efx_nic *efx,
-			    unsigned int done_offset);
 extern void falcon_drain_tx_fifo(struct efx_nic *efx);
 extern void falcon_deconfigure_mac_wrapper(struct efx_nic *efx);
 extern void falcon_reconfigure_mac_wrapper(struct efx_nic *efx);
@@ -154,6 +160,8 @@ extern int falcon_flush_queues(struct efx_nic *efx)=
;
 extern int falcon_reset_hw(struct efx_nic *efx, enum reset_type method=
);
 extern void falcon_remove_nic(struct efx_nic *efx);
 extern void falcon_update_nic_stats(struct efx_nic *efx);
+extern void falcon_start_nic_stats(struct efx_nic *efx);
+extern void falcon_stop_nic_stats(struct efx_nic *efx);
 extern void falcon_set_multicast_hash(struct efx_nic *efx);
 extern int falcon_reset_xaui(struct efx_nic *efx);
=20
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_b=
oards.c
index ac1258e..72d1c78 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -347,14 +347,14 @@ static ssize_t set_phy_flash_cfg(struct device *d=
ev,
 		 * MAC stats accordingly. */
 		efx->phy_mode =3D new_mode;
 		if (new_mode & PHY_MODE_SPECIAL)
-			efx_stats_disable(efx);
+			falcon_stop_nic_stats(efx);
 		if (falcon_board(efx)->type->id =3D=3D FALCON_BOARD_SFE4001)
 			err =3D sfe4001_poweron(efx);
 		else
 			err =3D sfn4111t_reset(efx);
 		efx_reconfigure_port(efx);
 		if (!(new_mode & PHY_MODE_SPECIAL))
-			efx_stats_enable(efx);
+			falcon_start_nic_stats(efx);
 	}
 	rtnl_unlock();
=20
@@ -441,7 +441,7 @@ static int sfe4001_init(struct efx_nic *efx)
 	if (efx->phy_mode & PHY_MODE_SPECIAL) {
 		/* PHY won't generate a 156.25 MHz clock and MAC stats fetch
 		 * will fail. */
-		efx_stats_disable(efx);
+		falcon_stop_nic_stats(efx);
 	}
 	rc =3D sfe4001_poweron(efx);
 	if (rc)
@@ -504,7 +504,7 @@ static void sfn4111t_init_phy(struct efx_nic *efx)
 			return;
=20
 		efx->phy_mode =3D PHY_MODE_SPECIAL;
-		efx_stats_disable(efx);
+		falcon_stop_nic_stats(efx);
 	}
=20
 	sfn4111t_reset(efx);
@@ -531,7 +531,7 @@ static int sfn4111t_init(struct efx_nic *efx)
 	if (efx->phy_mode & PHY_MODE_SPECIAL)
 		/* PHY may not generate a 156.25 MHz clock and MAC
 		 * stats fetch will fail. */
-		efx_stats_disable(efx);
+		falcon_stop_nic_stats(efx);
=20
 	return 0;
=20
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gma=
c.c
index 967f3fb..2aeb3fc 100644
--- a/drivers/net/sfc/falcon_gmac.c
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -130,11 +130,6 @@ static void falcon_update_stats_gmac(struct efx_ni=
c *efx)
 	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
 	unsigned long old_rx_pause, old_tx_pause;
 	unsigned long new_rx_pause, new_tx_pause;
-	int rc;
-
-	rc =3D falcon_dma_stats(efx, GDmaDone_offset);
-	if (rc)
-		return;
=20
 	/* Pause frames are erroneously counted as errors (SFC bug 3269) */
 	old_rx_pause =3D mac_stats->rx_pause;
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xma=
c.c
index cf24513..e57545d 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -60,9 +60,13 @@ static void falcon_setup_xaui(struct efx_nic *efx)
=20
 int falcon_reset_xaui(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data =3D efx->nic_data;
 	efx_oword_t reg;
 	int count;
=20
+	/* Don't fetch MAC statistics over an XMAC reset */
+	WARN_ON(nic_data->stats_disable_count =3D=3D 0);
+
 	/* Start reset sequence */
 	EFX_POPULATE_OWORD_1(reg, FRF_AB_XX_RST_XX_EN, 1);
 	efx_writeo(efx, &reg, FR_AB_XX_PWR_RST);
@@ -250,6 +254,8 @@ static void falcon_check_xaui_link_up(struct efx_ni=
c *efx, int tries)
 		/* XAUI link is expected to be down */
 		return;
=20
+	falcon_stop_nic_stats(efx);
+
 	while (!efx->mac_up && tries) {
 		EFX_LOG(efx, "bashing xaui\n");
 		falcon_reset_xaui(efx);
@@ -258,6 +264,8 @@ static void falcon_check_xaui_link_up(struct efx_ni=
c *efx, int tries)
 		efx->mac_up =3D falcon_xaui_link_ok(efx);
 		--tries;
 	}
+
+	falcon_start_nic_stats(efx);
 }
=20
 static void falcon_reconfigure_xmac(struct efx_nic *efx)
@@ -276,11 +284,6 @@ static void falcon_reconfigure_xmac(struct efx_nic=
 *efx)
 static void falcon_update_stats_xmac(struct efx_nic *efx)
 {
 	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
-	int rc;
-
-	rc =3D falcon_dma_stats(efx, XgDmaDone_offset);
-	if (rc)
-		return;
=20
 	/* Update MAC stats from DMAed values */
 	FALCON_STAT(efx, XgRxOctets, rx_bytes);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.=
h
index d0755ab..262aeab 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -717,7 +717,6 @@ union efx_multicast_hash {
  *	&struct net_device_stats.
  * @stats_buffer: DMA buffer for statistics
  * @stats_lock: Statistics update lock. Serialises statistics fetches
- * @stats_disable_count: Nest count for disabling statistics fetches
  * @mac_op: MAC interface
  * @mac_address: Permanent MAC address
  * @phy_type: PHY type
@@ -799,7 +798,6 @@ struct efx_nic {
 	struct efx_mac_stats mac_stats;
 	struct efx_buffer stats_buffer;
 	spinlock_t stats_lock;
-	unsigned int stats_disable_count;
=20
 	struct efx_mac_operations *mac_op;
 	unsigned char mac_address[ETH_ALEN];
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index a95402d..e6232fe 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -374,7 +374,7 @@ static int tenxpress_special_reset(struct efx_nic *=
efx)
 	/* The XGMAC clock is driven from the SFC7101/SFT9001 312MHz clock, s=
o
 	 * a special software reset can glitch the XGMAC sufficiently for sta=
ts
 	 * requests to fail. */
-	efx_stats_disable(efx);
+	falcon_stop_nic_stats(efx);
=20
 	/* Initiate reset */
 	reg =3D efx_mdio_read(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG);
@@ -396,7 +396,7 @@ static int tenxpress_special_reset(struct efx_nic *=
efx)
 	/* Wait for the XGXS state machine to churn */
 	mdelay(10);
 out:
-	efx_stats_enable(efx);
+	falcon_start_nic_stats(efx);
 	return rc;
 }
=20

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

