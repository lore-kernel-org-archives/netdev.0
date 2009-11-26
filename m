From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 13/16] sfc: Simplify XMAC link polling
Date: Thu, 26 Nov 2009 02:12:01 +0000
Message-ID: <1259201521.2806.29.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31343 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753465AbZKZCL6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:11:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BB=BFFrom: Steve Hodgson <shodgson@solarflare.com>

Only the XMAC on Falcon needs help from the driver to poll and reset
the MAC-PHY link (XAUI); GMII is a simple parallel bus and on later
NICs firmware takes care of the XAUI link.  Also, an XMAC interrupt
currently schedules a work item which simply clears a flag
(efx_nic::mac_up) to be checked by the regular monitor (or the next
link reconfiguration, if that is sooner).

Rename the flag to xmac_poll_required, changing its sense.  Remove the
needless indirection and just set the flag immediately.  Call
falcon_xmac_poll() directly where required.

Add a new generic operation mac_op::check_fault to check the link
outside of regular monitoring, as required during self-tests.

(Note that this leaves us with an unused work item, but we will
immediately have another use for it.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |    5 ----
 drivers/net/sfc/falcon.c        |    7 +++--
 drivers/net/sfc/falcon.h        |    2 +
 drivers/net/sfc/falcon_boards.c |    4 +-
 drivers/net/sfc/falcon_gmac.c   |    8 ++++-
 drivers/net/sfc/falcon_xmac.c   |   50 +++++++++++++++----------------=
-------
 drivers/net/sfc/net_driver.h    |   10 +++----
 drivers/net/sfc/selftest.c      |    9 ++----
 8 files changed, 41 insertions(+), 54 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d17cea9..15616dd 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -693,8 +693,6 @@ static void efx_mac_work(struct work_struct *data)
 	struct efx_nic *efx =3D container_of(data, struct efx_nic, mac_work);
=20
 	mutex_lock(&efx->mac_lock);
-	if (efx->port_enabled)
-		efx->mac_op->irq(efx);
 	mutex_unlock(&efx->mac_lock);
 }
=20
@@ -774,7 +772,6 @@ static void efx_start_port(struct efx_nic *efx)
 	mutex_lock(&efx->mac_lock);
 	efx->port_enabled =3D true;
 	__efx_reconfigure_port(efx);
-	efx->mac_op->irq(efx);
 	mutex_unlock(&efx->mac_lock);
 }
=20
@@ -1903,8 +1900,6 @@ void efx_port_dummy_op_set_id_led(struct efx_nic =
*efx, enum efx_led_mode mode)
=20
 static struct efx_mac_operations efx_dummy_mac_operations =3D {
 	.reconfigure	=3D efx_port_dummy_op_void,
-	.poll		=3D efx_port_dummy_op_void,
-	.irq		=3D efx_port_dummy_op_void,
 };
=20
 static struct efx_phy_operations efx_dummy_phy_operations =3D {
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index c43c5e6..fac534a 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -900,7 +900,7 @@ static void falcon_handle_global_event(struct efx_c=
hannel *channel,
=20
 	if ((falcon_rev(efx) >=3D FALCON_REV_B0) &&
 	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_XG_MGT_INTR)) {
-		queue_work(efx->workqueue, &efx->mac_work);
+		efx->xmac_poll_required =3D true;
 		handled =3D true;
 	}
=20
@@ -2251,7 +2251,7 @@ int falcon_switch_mac(struct efx_nic *efx)
=20
 	EFX_LOG(efx, "selected %cMAC\n", EFX_IS10G(efx) ? 'X' : 'G');
 	/* Not all macs support a mac-level link state */
-	efx->mac_up =3D true;
+	efx->xmac_poll_required =3D false;
=20
 	rc =3D falcon_reset_macs(efx);
 out:
@@ -2624,7 +2624,8 @@ void falcon_monitor(struct efx_nic *efx)
 		falcon_sim_phy_event(efx);
 	}
 	efx->phy_op->poll(efx);
-	efx->mac_op->poll(efx);
+	if (EFX_IS10G(efx))
+		falcon_poll_xmac(efx);
 }
=20
 /* Zeroes out the SRAM contents.  This routine must be called in
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 05e51c2..9ae1b6c 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -209,4 +209,6 @@ extern int falcon_test_registers(struct efx_nic *ef=
x);
 extern void falcon_generate_event(struct efx_channel *channel,
 				  efx_qword_t *event);
=20
+extern void falcon_poll_xmac(struct efx_nic *efx);
+
 #endif /* EFX_FALCON_H */
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_b=
oards.c
index 72d1c78..da75095 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -380,7 +380,7 @@ static int sfe4001_check_hw(struct efx_nic *efx)
 	s32 status;
=20
 	/* If XAUI link is up then do not monitor */
-	if (EFX_WORKAROUND_7884(efx) && efx->mac_up)
+	if (EFX_WORKAROUND_7884(efx) && !efx->xmac_poll_required)
 		return 0;
=20
 	/* Check the powered status of the PHY. Lack of power implies that
@@ -468,7 +468,7 @@ static int sfn4111t_check_hw(struct efx_nic *efx)
 	s32 status;
=20
 	/* If XAUI link is up then do not monitor */
-	if (EFX_WORKAROUND_7884(efx) && efx->mac_up)
+	if (EFX_WORKAROUND_7884(efx) && !efx->xmac_poll_required)
 		return 0;
=20
 	/* Test LHIGH, RHIGH, FAULT, EOT and IOT alarms */
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gma=
c.c
index 2aeb3fc..66d499c 100644
--- a/drivers/net/sfc/falcon_gmac.c
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -216,9 +216,13 @@ static void falcon_update_stats_gmac(struct efx_ni=
c *efx)
 	mac_stats->rx_lt64 =3D mac_stats->rx_good_lt64 + mac_stats->rx_bad_lt=
64;
 }
=20
+static bool falcon_gmac_check_fault(struct efx_nic *efx)
+{
+	return false;
+}
+
 struct efx_mac_operations falcon_gmac_operations =3D {
 	.reconfigure	=3D falcon_reconfigure_gmac,
 	.update_stats	=3D falcon_update_stats_gmac,
-	.irq		=3D efx_port_dummy_op_void,
-	.poll		=3D efx_port_dummy_op_void,
+	.check_fault 	=3D falcon_gmac_check_fault,
 };
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xma=
c.c
index e57545d..784260f 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -98,7 +98,7 @@ static void falcon_mask_status_intr(struct efx_nic *e=
fx, bool enable)
=20
 	/* We can only use this interrupt to signal the negative edge of
 	 * xaui_align [we have to poll the positive edge]. */
-	if (!efx->mac_up)
+	if (efx->xmac_poll_required)
 		return;
=20
 	/* Flush the ISR */
@@ -243,29 +243,35 @@ static void falcon_reconfigure_xgxs_core(struct e=
fx_nic *efx)
 }
=20

-/* Try and bring the Falcon side of the Falcon-Phy XAUI link fails
- * to come back up. Bash it until it comes back up */
-static void falcon_check_xaui_link_up(struct efx_nic *efx, int tries)
+/* Try to bring up the Falcon side of the Falcon-Phy XAUI link */
+static bool falcon_check_xaui_link_up(struct efx_nic *efx, int tries)
 {
-	efx->mac_up =3D falcon_xaui_link_ok(efx);
+	bool mac_up =3D falcon_xaui_link_ok(efx);
=20
 	if ((efx->loopback_mode =3D=3D LOOPBACK_NETWORK) ||
 	    efx_phy_mode_disabled(efx->phy_mode))
 		/* XAUI link is expected to be down */
-		return;
+		return mac_up;
=20
 	falcon_stop_nic_stats(efx);
=20
-	while (!efx->mac_up && tries) {
+	while (!mac_up && tries) {
 		EFX_LOG(efx, "bashing xaui\n");
 		falcon_reset_xaui(efx);
 		udelay(200);
=20
-		efx->mac_up =3D falcon_xaui_link_ok(efx);
+		mac_up =3D falcon_xaui_link_ok(efx);
 		--tries;
 	}
=20
 	falcon_start_nic_stats(efx);
+
+	return mac_up;
+}
+
+static bool falcon_xmac_check_fault(struct efx_nic *efx)
+{
+	return !falcon_check_xaui_link_up(efx, 5);
 }
=20
 static void falcon_reconfigure_xmac(struct efx_nic *efx)
@@ -277,7 +283,7 @@ static void falcon_reconfigure_xmac(struct efx_nic =
*efx)
=20
 	falcon_reconfigure_mac_wrapper(efx);
=20
-	falcon_check_xaui_link_up(efx, 5);
+	efx->xmac_poll_required =3D !falcon_check_xaui_link_up(efx, 5);
 	falcon_mask_status_intr(efx, true);
 }
=20
@@ -341,35 +347,19 @@ static void falcon_update_stats_xmac(struct efx_n=
ic *efx)
 		 mac_stats->rx_control * 64);
 }
=20
-static void falcon_xmac_irq(struct efx_nic *efx)
-{
-	/* The XGMII link has a transient fault, which indicates either:
-	 *   - there's a transient xgmii fault
-	 *   - falcon's end of the xaui link may need a kick
-	 *   - the wire-side link may have gone down, but the lasi/poll()
-	 *     hasn't noticed yet.
-	 *
-	 * We only want to even bother polling XAUI if we're confident it's
-	 * not (1) or (3). In both cases, the only reliable way to spot this
-	 * is to wait a bit. We do this here by forcing the mac link state
-	 * to down, and waiting for the mac poll to come round and check
-	 */
-	efx->mac_up =3D false;
-}
-
-static void falcon_poll_xmac(struct efx_nic *efx)
+void falcon_poll_xmac(struct efx_nic *efx)
 {
-	if (!EFX_WORKAROUND_5147(efx) || !efx->link_state.up || efx->mac_up)
+	if (!EFX_WORKAROUND_5147(efx) || !efx->link_state.up ||
+	    !efx->xmac_poll_required)
 		return;
=20
 	falcon_mask_status_intr(efx, false);
-	falcon_check_xaui_link_up(efx, 1);
+	efx->xmac_poll_required =3D !falcon_check_xaui_link_up(efx, 1);
 	falcon_mask_status_intr(efx, true);
 }
=20
 struct efx_mac_operations falcon_xmac_operations =3D {
 	.reconfigure	=3D falcon_reconfigure_xmac,
 	.update_stats	=3D falcon_update_stats_xmac,
-	.irq		=3D falcon_xmac_irq,
-	.poll		=3D falcon_poll_xmac,
+	.check_fault	=3D falcon_xmac_check_fault,
 };
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.=
h
index 262aeab..cc1a97b 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -507,14 +507,12 @@ struct efx_link_state {
  * struct efx_mac_operations - Efx MAC operations table
  * @reconfigure: Reconfigure MAC. Serialised by the mac_lock
  * @update_stats: Update statistics
- * @irq: Hardware MAC event callback. Serialised by the mac_lock
- * @poll: Poll for hardware state. Serialised by the mac_lock
+ * @check_fault: Check fault state. True if fault present.
  */
 struct efx_mac_operations {
 	void (*reconfigure) (struct efx_nic *efx);
 	void (*update_stats) (struct efx_nic *efx);
-	void (*irq) (struct efx_nic *efx);
-	void (*poll) (struct efx_nic *efx);
+	bool (*check_fault)(struct efx_nic *efx);
 };
=20
 /**
@@ -725,7 +723,7 @@ union efx_multicast_hash {
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mdio: PHY MDIO interface
  * @phy_mode: PHY operating mode. Serialised by @mac_lock.
- * @mac_up: MAC link state
+ * @xmac_poll_required: XMAC link state needs polling
  * @link_state: Current state of the link
  * @n_link_state_changes: Number of times the link has changed state
  * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
@@ -810,7 +808,7 @@ struct efx_nic {
 	struct mdio_if_info mdio;
 	enum efx_phy_mode phy_mode;
=20
-	bool mac_up;
+	bool xmac_poll_required;
 	struct efx_link_state link_state;
 	unsigned int n_link_state_changes;
=20
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 63ff295..23e646a 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -610,13 +610,10 @@ static int efx_test_loopbacks(struct efx_nic *efx=
, struct efx_self_tests *tests,
 			flush_workqueue(efx->workqueue);
 			rmb();
=20
-			/* We need both the phy and xaui links to be ok.
-			 * rather than relying on the falcon_xmac irq/poll
-			 * regime, just poll xaui directly */
+			/* We need both the PHY and MAC-PHY links to be OK */
 			link_up =3D efx->link_state.up;
-			if (link_up && EFX_IS10G(efx) &&
-			    !falcon_xaui_link_ok(efx))
-				link_up =3D false;
+			if (link_up)
+				link_up =3D !efx->mac_op->check_fault(efx);
=20
 		} while ((++count < 20) && !link_up);
=20

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

