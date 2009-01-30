From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/11] sfc: SFX7101: Remove workaround for bad link training
Date: Fri, 30 Jan 2009 03:48:43 +0000
Message-ID: <20090130034842.GD15266@solarflare.com>
References: <20090129.170811.135213740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:33250 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752580AbZA3Dss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 22:48:48 -0500
Content-Disposition: inline
In-Reply-To: <20090129.170811.135213740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Early versions of the SFX7101 firmware could complete link training in
a state where it would not adequately cancel noise (Solarflare bug
10750).  We previously worked around this by resetting the PHY after
seeing many Ethernet CRC errors.  This workaround is unsafe since it
takes no account of the interval between errors; it also appears to
be unnecessary with production firmware.  Therefore remove it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c      |    4 ----
 drivers/net/sfc/phy.h         |    1 -
 drivers/net/sfc/tenxpress.c   |   20 --------------------
 drivers/net/sfc/workarounds.h |    3 ---
 4 files changed, 0 insertions(+), 28 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 5b9f2d9..ae7b0b4 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -824,10 +824,6 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 			    rx_ev_pause_frm ? " [PAUSE]" : "");
 	}
 #endif
-
-	if (unlikely(rx_ev_eth_crc_err && EFX_WORKAROUND_10750(efx) &&
-		     efx->phy_type == PHY_TYPE_SFX7101))
-		tenxpress_crc_err(efx);
 }
 
 /* Handle receive events that are not in-order. */
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index 58c493e..07e855c 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -17,7 +17,6 @@ extern struct efx_phy_operations falcon_sfx7101_phy_ops;
 extern struct efx_phy_operations falcon_sft9001_phy_ops;
 
 extern void tenxpress_phy_blink(struct efx_nic *efx, bool blink);
-extern void tenxpress_crc_err(struct efx_nic *efx);
 
 /****************************************************************************
  * Exported functions from the driver for XFP optical PHYs
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 19cfc31..80c8d6e 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -189,25 +189,12 @@
  * rails */
 #define LNPGA_PDOWN_WAIT	(HZ / 5)
 
-static int crc_error_reset_threshold = 100;
-module_param(crc_error_reset_threshold, int, 0644);
-MODULE_PARM_DESC(crc_error_reset_threshold,
-		 "Max number of CRC errors before XAUI reset");
-
 struct tenxpress_phy_data {
 	enum efx_loopback_mode loopback_mode;
-	atomic_t bad_crc_count;
 	enum efx_phy_mode phy_mode;
 	int bad_lp_tries;
 };
 
-void tenxpress_crc_err(struct efx_nic *efx)
-{
-	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	if (phy_data != NULL)
-		atomic_inc(&phy_data->bad_crc_count);
-}
-
 static ssize_t show_phy_short_reach(struct device *dev,
 				    struct device_attribute *attr, char *buf)
 {
@@ -627,13 +614,6 @@ static void tenxpress_phy_poll(struct efx_nic *efx)
 
 	if (phy_data->phy_mode != PHY_MODE_NORMAL)
 		return;
-
-	if (EFX_WORKAROUND_10750(efx) &&
-	    atomic_read(&phy_data->bad_crc_count) > crc_error_reset_threshold) {
-		EFX_ERR(efx, "Resetting XAUI due to too many CRC errors\n");
-		falcon_reset_xaui(efx);
-		atomic_set(&phy_data->bad_crc_count, 0);
-	}
 }
 
 static void tenxpress_phy_fini(struct efx_nic *efx)
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 82e03e1..797a0cf 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -18,7 +18,6 @@
 #define EFX_WORKAROUND_ALWAYS(efx) 1
 #define EFX_WORKAROUND_FALCON_A(efx) (falcon_rev(efx) <= FALCON_REV_A1)
 #define EFX_WORKAROUND_10G(efx) EFX_IS10G(efx)
-#define EFX_WORKAROUND_SFX7101(efx) ((efx)->phy_type == PHY_TYPE_SFX7101)
 #define EFX_WORKAROUND_SFT9001A(efx) ((efx)->phy_type == PHY_TYPE_SFT9001A)
 
 /* XAUI resets if link not detected */
@@ -29,8 +28,6 @@
 #define EFX_WORKAROUND_7884 EFX_WORKAROUND_10G
 /* TX pkt parser problem with <= 16 byte TXes */
 #define EFX_WORKAROUND_9141 EFX_WORKAROUND_ALWAYS
-/* Low rate CRC errors require XAUI reset */
-#define EFX_WORKAROUND_10750 EFX_WORKAROUND_SFX7101
 /* TX_EV_PKT_ERR can be caused by a dangling TX descriptor
  * or a PCIe error (bug 11028) */
 #define EFX_WORKAROUND_10727 EFX_WORKAROUND_ALWAYS

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
