From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/2] sfc: Remove support for SFN4111T, SFT9001
 and Falcon GMAC
Date: Wed, 22 Sep 2010 21:00:11 +0100
Message-ID: <1285185611.2279.16.camel@achroite.uk.solarflarecom.com>
References: <1285185501.2279.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24060 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156Ab0IVUAR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 16:00:17 -0400
In-Reply-To: <1285185501.2279.14.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SFN4111T never reached production and is not being used for internal
or customer testing.

Since we have no production Falcon boards using the SFT9001 or the
GMAC, remove support for them as well.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Makefile        |    2 +-
 drivers/net/sfc/falcon.c        |  117 ++---------
 drivers/net/sfc/falcon_boards.c |  127 +-----------
 drivers/net/sfc/falcon_gmac.c   |  230 ---------------------
 drivers/net/sfc/mac.h           |    1 -
 drivers/net/sfc/mdio_10g.c      |   30 +---
 drivers/net/sfc/net_driver.h    |    2 -
 drivers/net/sfc/phy.h           |    7 +-
 drivers/net/sfc/tenxpress.c     |  424 +++----------------------------=
--------
 drivers/net/sfc/workarounds.h   |    9 +-
 10 files changed, 56 insertions(+), 893 deletions(-)
 delete mode 100644 drivers/net/sfc/falcon_gmac.c

diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index fd9272b..39f7c1b 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,5 +1,5 @@
 sfc-y			+=3D efx.o nic.o falcon.o siena.o tx.o rx.o filter.o \
-			   falcon_gmac.o falcon_xmac.o mcdi_mac.o \
+			   falcon_xmac.o mcdi_mac.o \
 			   selftest.o ethtool.o qt202x_phy.o mdio_10g.o \
 			   tenxpress.o falcon_boards.o mcdi.o mcdi_phy.o
 sfc-$(CONFIG_SFC_MTD)	+=3D mtd.o
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index b398a41..254a599 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -446,30 +446,19 @@ static void falcon_reset_macs(struct efx_nic *efx=
)
 		/* It's not safe to use GLB_CTL_REG to reset the
 		 * macs, so instead use the internal MAC resets
 		 */
-		if (!EFX_IS10G(efx)) {
-			EFX_POPULATE_OWORD_1(reg, FRF_AB_GM_SW_RST, 1);
-			efx_writeo(efx, &reg, FR_AB_GM_CFG1);
-			udelay(1000);
-
-			EFX_POPULATE_OWORD_1(reg, FRF_AB_GM_SW_RST, 0);
-			efx_writeo(efx, &reg, FR_AB_GM_CFG1);
-			udelay(1000);
-			return;
-		} else {
-			EFX_POPULATE_OWORD_1(reg, FRF_AB_XM_CORE_RST, 1);
-			efx_writeo(efx, &reg, FR_AB_XM_GLB_CFG);
-
-			for (count =3D 0; count < 10000; count++) {
-				efx_reado(efx, &reg, FR_AB_XM_GLB_CFG);
-				if (EFX_OWORD_FIELD(reg, FRF_AB_XM_CORE_RST) =3D=3D
-				    0)
-					return;
-				udelay(10);
-			}
-
-			netif_err(efx, hw, efx->net_dev,
-				  "timed out waiting for XMAC core reset\n");
+		EFX_POPULATE_OWORD_1(reg, FRF_AB_XM_CORE_RST, 1);
+		efx_writeo(efx, &reg, FR_AB_XM_GLB_CFG);
+
+		for (count =3D 0; count < 10000; count++) {
+			efx_reado(efx, &reg, FR_AB_XM_GLB_CFG);
+			if (EFX_OWORD_FIELD(reg, FRF_AB_XM_CORE_RST) =3D=3D
+			    0)
+				return;
+			udelay(10);
 		}
+
+		netif_err(efx, hw, efx->net_dev,
+			  "timed out waiting for XMAC core reset\n");
 	}
=20
 	/* Mac stats will fail whist the TX fifo is draining */
@@ -508,7 +497,6 @@ static void falcon_reset_macs(struct efx_nic *efx)
 	 * are re-enabled by the caller */
 	efx_writeo(efx, &mac_ctrl, FR_AB_MAC_CTRL);
=20
-	/* This can run even when the GMAC is selected */
 	falcon_setup_xaui(efx);
 }
=20
@@ -646,8 +634,6 @@ static void falcon_stats_timer_func(unsigned long c=
ontext)
 	spin_unlock(&efx->stats_lock);
 }
=20
-static void falcon_switch_mac(struct efx_nic *efx);
-
 static bool falcon_loopback_link_poll(struct efx_nic *efx)
 {
 	struct efx_link_state old_state =3D efx->link_state;
@@ -658,11 +644,7 @@ static bool falcon_loopback_link_poll(struct efx_n=
ic *efx)
 	efx->link_state.fd =3D true;
 	efx->link_state.fc =3D efx->wanted_fc;
 	efx->link_state.up =3D true;
-
-	if (efx->loopback_mode =3D=3D LOOPBACK_GMAC)
-		efx->link_state.speed =3D 1000;
-	else
-		efx->link_state.speed =3D 10000;
+	efx->link_state.speed =3D 10000;
=20
 	return !efx_link_state_equal(&efx->link_state, &old_state);
 }
@@ -685,7 +667,7 @@ static int falcon_reconfigure_port(struct efx_nic *=
efx)
 	falcon_stop_nic_stats(efx);
 	falcon_deconfigure_mac_wrapper(efx);
=20
-	falcon_switch_mac(efx);
+	falcon_reset_macs(efx);
=20
 	efx->phy_op->reconfigure(efx);
 	rc =3D efx->mac_op->reconfigure(efx);
@@ -835,69 +817,16 @@ out:
 	return rc;
 }
=20
-static void falcon_clock_mac(struct efx_nic *efx)
-{
-	unsigned strap_val;
-	efx_oword_t nic_stat;
-
-	/* Configure the NIC generated MAC clock correctly */
-	efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
-	strap_val =3D EFX_IS10G(efx) ? 5 : 3;
-	if (efx_nic_rev(efx) >=3D EFX_REV_FALCON_B0) {
-		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP_EN, 1);
-		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP, strap_val);
-		efx_writeo(efx, &nic_stat, FR_AB_NIC_STAT);
-	} else {
-		/* Falcon A1 does not support 1G/10G speed switching
-		 * and must not be used with a PHY that does. */
-		BUG_ON(EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_PINS) !=3D
-		       strap_val);
-	}
-}
-
-static void falcon_switch_mac(struct efx_nic *efx)
-{
-	struct efx_mac_operations *old_mac_op =3D efx->mac_op;
-	struct falcon_nic_data *nic_data =3D efx->nic_data;
-	unsigned int stats_done_offset;
-
-	WARN_ON(!mutex_is_locked(&efx->mac_lock));
-	WARN_ON(nic_data->stats_disable_count =3D=3D 0);
-
-	efx->mac_op =3D (EFX_IS10G(efx) ?
-		       &falcon_xmac_operations : &falcon_gmac_operations);
-
-	if (EFX_IS10G(efx))
-		stats_done_offset =3D XgDmaDone_offset;
-	else
-		stats_done_offset =3D GDmaDone_offset;
-	nic_data->stats_dma_done =3D efx->stats_buffer.addr + stats_done_offs=
et;
-
-	if (old_mac_op =3D=3D efx->mac_op)
-		return;
-
-	falcon_clock_mac(efx);
-
-	netif_dbg(efx, hw, efx->net_dev, "selected %cMAC\n",
-		  EFX_IS10G(efx) ? 'X' : 'G');
-	/* Not all macs support a mac-level link state */
-	efx->xmac_poll_required =3D false;
-	falcon_reset_macs(efx);
-}
-
 /* This call is responsible for hooking in the MAC and PHY operations =
*/
 static int falcon_probe_port(struct efx_nic *efx)
 {
+	struct falcon_nic_data *nic_data =3D efx->nic_data;
 	int rc;
=20
 	switch (efx->phy_type) {
 	case PHY_TYPE_SFX7101:
 		efx->phy_op =3D &falcon_sfx7101_phy_ops;
 		break;
-	case PHY_TYPE_SFT9001A:
-	case PHY_TYPE_SFT9001B:
-		efx->phy_op =3D &falcon_sft9001_phy_ops;
-		break;
 	case PHY_TYPE_QT2022C2:
 	case PHY_TYPE_QT2025C:
 		efx->phy_op =3D &falcon_qt202x_phy_ops;
@@ -937,6 +866,7 @@ static int falcon_probe_port(struct efx_nic *efx)
 		  (u64)efx->stats_buffer.dma_addr,
 		  efx->stats_buffer.addr,
 		  (u64)virt_to_phys(efx->stats_buffer.addr));
+	nic_data->stats_dma_done =3D efx->stats_buffer.addr + XgDmaDone_offse=
t;
=20
 	return 0;
 }
@@ -1201,7 +1131,7 @@ static void falcon_monitor(struct efx_nic *efx)
 		falcon_stop_nic_stats(efx);
 		falcon_deconfigure_mac_wrapper(efx);
=20
-		falcon_switch_mac(efx);
+		falcon_reset_macs(efx);
 		rc =3D efx->mac_op->reconfigure(efx);
 		BUG_ON(rc);
=20
@@ -1210,8 +1140,7 @@ static void falcon_monitor(struct efx_nic *efx)
 		efx_link_status_changed(efx);
 	}
=20
-	if (EFX_IS10G(efx))
-		falcon_poll_xmac(efx);
+	falcon_poll_xmac(efx);
 }
=20
 /* Zeroes out the SRAM contents.  This routine must be called in
@@ -1604,16 +1533,6 @@ static int falcon_init_nic(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(temp, FRF_AB_ONCHIP_SRAM, 1);
 	efx_writeo(efx, &temp, FR_AB_NIC_STAT);
=20
-	/* Set the source of the GMAC clock */
-	if (efx_nic_rev(efx) =3D=3D EFX_REV_FALCON_B0) {
-		efx_reado(efx, &temp, FR_AB_GPIO_CTL);
-		EFX_SET_OWORD_FIELD(temp, FRF_AB_USE_NIC_CLK, true);
-		efx_writeo(efx, &temp, FR_AB_GPIO_CTL);
-	}
-
-	/* Select the correct MAC */
-	falcon_clock_mac(efx);
-
 	rc =3D falcon_reset_sram(efx);
 	if (rc)
 		return rc;
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_b=
oards.c
index 3d950c2..bf029b3 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -26,7 +26,6 @@
 /* Board types */
 #define FALCON_BOARD_SFE4001 0x01
 #define FALCON_BOARD_SFE4002 0x02
-#define FALCON_BOARD_SFN4111T 0x51
 #define FALCON_BOARD_SFN4112F 0x52
=20
 /* Board temperature is about 15=C2=B0C above ambient when air flow is
@@ -142,17 +141,17 @@ static inline int efx_check_lm87(struct efx_nic *=
efx, unsigned mask)
 #endif /* CONFIG_SENSORS_LM87 */
=20
 /*********************************************************************=
********
- * Support for the SFE4001 and SFN4111T NICs.
+ * Support for the SFE4001 NIC.
  *
  * The SFE4001 does not power-up fully at reset due to its high power
  * consumption.  We control its power via a PCA9539 I/O expander.
- * Both boards have a MAX6647 temperature monitor which we expose to
+ * It also has a MAX6647 temperature monitor which we expose to
  * the lm90 driver.
  *
  * This also provides minimal support for reflashing the PHY, which is
  * initiated by resetting it with the FLASH_CFG_1 pin pulled down.
  * On SFE4001 rev A2 and later this is connected to the 3V3X output of
- * the IO-expander; on the SFN4111T it is connected to Falcon's GPIO3.
+ * the IO-expander.
  * We represent reflash mode as PHY_MODE_SPECIAL and make it mutually
  * exclusive with the network device being open.
  */
@@ -304,34 +303,6 @@ fail_on:
 	return rc;
 }
=20
-static int sfn4111t_reset(struct efx_nic *efx)
-{
-	struct falcon_board *board =3D falcon_board(efx);
-	efx_oword_t reg;
-
-	/* GPIO 3 and the GPIO register are shared with I2C, so block that */
-	i2c_lock_adapter(&board->i2c_adap);
-
-	/* Pull RST_N (GPIO 2) low then let it up again, setting the
-	 * FLASH_CFG_1 strap (GPIO 3) appropriately.  Only change the
-	 * output enables; the output levels should always be 0 (low)
-	 * and we rely on external pull-ups. */
-	efx_reado(efx, &reg, FR_AB_GPIO_CTL);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO2_OEN, true);
-	efx_writeo(efx, &reg, FR_AB_GPIO_CTL);
-	msleep(1000);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO2_OEN, false);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO3_OEN,
-			    !!(efx->phy_mode & PHY_MODE_SPECIAL));
-	efx_writeo(efx, &reg, FR_AB_GPIO_CTL);
-	msleep(1);
-
-	i2c_unlock_adapter(&board->i2c_adap);
-
-	ssleep(1);
-	return 0;
-}
-
 static ssize_t show_phy_flash_cfg(struct device *dev,
 				  struct device_attribute *attr, char *buf)
 {
@@ -363,10 +334,7 @@ static ssize_t set_phy_flash_cfg(struct device *de=
v,
 		efx->phy_mode =3D new_mode;
 		if (new_mode & PHY_MODE_SPECIAL)
 			falcon_stop_nic_stats(efx);
-		if (falcon_board(efx)->type->id =3D=3D FALCON_BOARD_SFE4001)
-			err =3D sfe4001_poweron(efx);
-		else
-			err =3D sfn4111t_reset(efx);
+		err =3D sfe4001_poweron(efx);
 		if (!err)
 			err =3D efx_reconfigure_port(efx);
 		if (!(new_mode & PHY_MODE_SPECIAL))
@@ -479,83 +447,6 @@ fail_hwmon:
 	return rc;
 }
=20
-static int sfn4111t_check_hw(struct efx_nic *efx)
-{
-	s32 status;
-
-	/* If XAUI link is up then do not monitor */
-	if (EFX_WORKAROUND_7884(efx) && !efx->xmac_poll_required)
-		return 0;
-
-	/* Test LHIGH, RHIGH, FAULT, EOT and IOT alarms */
-	status =3D i2c_smbus_read_byte_data(falcon_board(efx)->hwmon_client,
-					  MAX664X_REG_RSL);
-	if (status < 0)
-		return -EIO;
-	if (status & 0x57)
-		return -ERANGE;
-	return 0;
-}
-
-static void sfn4111t_fini(struct efx_nic *efx)
-{
-	netif_info(efx, drv, efx->net_dev, "%s\n", __func__);
-
-	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
-	i2c_unregister_device(falcon_board(efx)->hwmon_client);
-}
-
-static struct i2c_board_info sfn4111t_a0_hwmon_info =3D {
-	I2C_BOARD_INFO("max6647", 0x4e),
-};
-
-static struct i2c_board_info sfn4111t_r5_hwmon_info =3D {
-	I2C_BOARD_INFO("max6646", 0x4d),
-};
-
-static void sfn4111t_init_phy(struct efx_nic *efx)
-{
-	if (!(efx->phy_mode & PHY_MODE_SPECIAL)) {
-		if (sft9001_wait_boot(efx) !=3D -EINVAL)
-			return;
-
-		efx->phy_mode =3D PHY_MODE_SPECIAL;
-		falcon_stop_nic_stats(efx);
-	}
-
-	sfn4111t_reset(efx);
-	sft9001_wait_boot(efx);
-}
-
-static int sfn4111t_init(struct efx_nic *efx)
-{
-	struct falcon_board *board =3D falcon_board(efx);
-	int rc;
-
-	board->hwmon_client =3D
-		i2c_new_device(&board->i2c_adap,
-			       (board->minor < 5) ?
-			       &sfn4111t_a0_hwmon_info :
-			       &sfn4111t_r5_hwmon_info);
-	if (!board->hwmon_client)
-		return -EIO;
-
-	rc =3D device_create_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg=
);
-	if (rc)
-		goto fail_hwmon;
-
-	if (efx->phy_mode & PHY_MODE_SPECIAL)
-		/* PHY may not generate a 156.25 MHz clock and MAC
-		 * stats fetch will fail. */
-		falcon_stop_nic_stats(efx);
-
-	return 0;
-
-fail_hwmon:
-	i2c_unregister_device(board->hwmon_client);
-	return rc;
-}
-
 /*********************************************************************=
********
  * Support for the SFE4002
  *
@@ -713,16 +604,6 @@ static const struct falcon_board_type board_types[=
] =3D {
 		.monitor	=3D sfe4002_check_hw,
 	},
 	{
-		.id		=3D FALCON_BOARD_SFN4111T,
-		.ref_model	=3D "SFN4111T",
-		.gen_type	=3D "100/1000/10GBASE-T adapter",
-		.init		=3D sfn4111t_init,
-		.init_phy	=3D sfn4111t_init_phy,
-		.fini		=3D sfn4111t_fini,
-		.set_id_led	=3D tenxpress_set_id_led,
-		.monitor	=3D sfn4111t_check_hw,
-	},
-	{
 		.id		=3D FALCON_BOARD_SFN4112F,
 		.ref_model	=3D "SFN4112F",
 		.gen_type	=3D "SFP+ adapter",
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gma=
c.c
deleted file mode 100644
index 7dadfcb..0000000
--- a/drivers/net/sfc/falcon_gmac.c
+++ /dev/null
@@ -1,230 +0,0 @@
-/*********************************************************************=
*******
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modif=
y it
- * under the terms of the GNU General Public License version 2 as publ=
ished
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#include <linux/delay.h>
-#include "net_driver.h"
-#include "efx.h"
-#include "nic.h"
-#include "mac.h"
-#include "regs.h"
-#include "io.h"
-
-/*********************************************************************=
*****
- *
- * MAC operations
- *
- *********************************************************************=
****/
-
-static int falcon_reconfigure_gmac(struct efx_nic *efx)
-{
-	struct efx_link_state *link_state =3D &efx->link_state;
-	bool loopback, tx_fc, rx_fc, bytemode;
-	int if_mode;
-	unsigned int max_frame_len;
-	efx_oword_t reg;
-
-	/* Configuration register 1 */
-	tx_fc =3D (link_state->fc & EFX_FC_TX) || !link_state->fd;
-	rx_fc =3D !!(link_state->fc & EFX_FC_RX);
-	loopback =3D (efx->loopback_mode =3D=3D LOOPBACK_GMAC);
-	bytemode =3D (link_state->speed =3D=3D 1000);
-
-	EFX_POPULATE_OWORD_5(reg,
-			     FRF_AB_GM_LOOP, loopback,
-			     FRF_AB_GM_TX_EN, 1,
-			     FRF_AB_GM_TX_FC_EN, tx_fc,
-			     FRF_AB_GM_RX_EN, 1,
-			     FRF_AB_GM_RX_FC_EN, rx_fc);
-	efx_writeo(efx, &reg, FR_AB_GM_CFG1);
-	udelay(10);
-
-	/* Configuration register 2 */
-	if_mode =3D (bytemode) ? 2 : 1;
-	EFX_POPULATE_OWORD_5(reg,
-			     FRF_AB_GM_IF_MODE, if_mode,
-			     FRF_AB_GM_PAD_CRC_EN, 1,
-			     FRF_AB_GM_LEN_CHK, 1,
-			     FRF_AB_GM_FD, link_state->fd,
-			     FRF_AB_GM_PAMBL_LEN, 0x7/*datasheet recommended */);
-
-	efx_writeo(efx, &reg, FR_AB_GM_CFG2);
-	udelay(10);
-
-	/* Max frame len register */
-	max_frame_len =3D EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
-	EFX_POPULATE_OWORD_1(reg, FRF_AB_GM_MAX_FLEN, max_frame_len);
-	efx_writeo(efx, &reg, FR_AB_GM_MAX_FLEN);
-	udelay(10);
-
-	/* FIFO configuration register 0 */
-	EFX_POPULATE_OWORD_5(reg,
-			     FRF_AB_GMF_FTFENREQ, 1,
-			     FRF_AB_GMF_STFENREQ, 1,
-			     FRF_AB_GMF_FRFENREQ, 1,
-			     FRF_AB_GMF_SRFENREQ, 1,
-			     FRF_AB_GMF_WTMENREQ, 1);
-	efx_writeo(efx, &reg, FR_AB_GMF_CFG0);
-	udelay(10);
-
-	/* FIFO configuration register 1 */
-	EFX_POPULATE_OWORD_2(reg,
-			     FRF_AB_GMF_CFGFRTH, 0x12,
-			     FRF_AB_GMF_CFGXOFFRTX, 0xffff);
-	efx_writeo(efx, &reg, FR_AB_GMF_CFG1);
-	udelay(10);
-
-	/* FIFO configuration register 2 */
-	EFX_POPULATE_OWORD_2(reg,
-			     FRF_AB_GMF_CFGHWM, 0x3f,
-			     FRF_AB_GMF_CFGLWM, 0xa);
-	efx_writeo(efx, &reg, FR_AB_GMF_CFG2);
-	udelay(10);
-
-	/* FIFO configuration register 3 */
-	EFX_POPULATE_OWORD_2(reg,
-			     FRF_AB_GMF_CFGHWMFT, 0x1c,
-			     FRF_AB_GMF_CFGFTTH, 0x08);
-	efx_writeo(efx, &reg, FR_AB_GMF_CFG3);
-	udelay(10);
-
-	/* FIFO configuration register 4 */
-	EFX_POPULATE_OWORD_1(reg, FRF_AB_GMF_HSTFLTRFRM_PAUSE, 1);
-	efx_writeo(efx, &reg, FR_AB_GMF_CFG4);
-	udelay(10);
-
-	/* FIFO configuration register 5 */
-	efx_reado(efx, &reg, FR_AB_GMF_CFG5);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_CFGBYTMODE, bytemode);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_CFGHDPLX, !link_state->fd);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_HSTDRPLT64, !link_state->fd);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_HSTFLTRFRMDC_PAUSE, 0);
-	efx_writeo(efx, &reg, FR_AB_GMF_CFG5);
-	udelay(10);
-
-	/* MAC address */
-	EFX_POPULATE_OWORD_4(reg,
-			     FRF_AB_GM_ADR_B0, efx->net_dev->dev_addr[5],
-			     FRF_AB_GM_ADR_B1, efx->net_dev->dev_addr[4],
-			     FRF_AB_GM_ADR_B2, efx->net_dev->dev_addr[3],
-			     FRF_AB_GM_ADR_B3, efx->net_dev->dev_addr[2]);
-	efx_writeo(efx, &reg, FR_AB_GM_ADR1);
-	udelay(10);
-	EFX_POPULATE_OWORD_2(reg,
-			     FRF_AB_GM_ADR_B4, efx->net_dev->dev_addr[1],
-			     FRF_AB_GM_ADR_B5, efx->net_dev->dev_addr[0]);
-	efx_writeo(efx, &reg, FR_AB_GM_ADR2);
-	udelay(10);
-
-	falcon_reconfigure_mac_wrapper(efx);
-
-	return 0;
-}
-
-static void falcon_update_stats_gmac(struct efx_nic *efx)
-{
-	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
-	unsigned long old_rx_pause, old_tx_pause;
-	unsigned long new_rx_pause, new_tx_pause;
-
-	/* Pause frames are erroneously counted as errors (SFC bug 3269) */
-	old_rx_pause =3D mac_stats->rx_pause;
-	old_tx_pause =3D mac_stats->tx_pause;
-
-	/* Update MAC stats from DMAed values */
-	FALCON_STAT(efx, GRxGoodOct, rx_good_bytes);
-	FALCON_STAT(efx, GRxBadOct, rx_bad_bytes);
-	FALCON_STAT(efx, GRxMissPkt, rx_missed);
-	FALCON_STAT(efx, GRxFalseCRS, rx_false_carrier);
-	FALCON_STAT(efx, GRxPausePkt, rx_pause);
-	FALCON_STAT(efx, GRxBadPkt, rx_bad);
-	FALCON_STAT(efx, GRxUcastPkt, rx_unicast);
-	FALCON_STAT(efx, GRxMcastPkt, rx_multicast);
-	FALCON_STAT(efx, GRxBcastPkt, rx_broadcast);
-	FALCON_STAT(efx, GRxGoodLt64Pkt, rx_good_lt64);
-	FALCON_STAT(efx, GRxBadLt64Pkt, rx_bad_lt64);
-	FALCON_STAT(efx, GRx64Pkt, rx_64);
-	FALCON_STAT(efx, GRx65to127Pkt, rx_65_to_127);
-	FALCON_STAT(efx, GRx128to255Pkt, rx_128_to_255);
-	FALCON_STAT(efx, GRx256to511Pkt, rx_256_to_511);
-	FALCON_STAT(efx, GRx512to1023Pkt, rx_512_to_1023);
-	FALCON_STAT(efx, GRx1024to15xxPkt, rx_1024_to_15xx);
-	FALCON_STAT(efx, GRx15xxtoJumboPkt, rx_15xx_to_jumbo);
-	FALCON_STAT(efx, GRxGtJumboPkt, rx_gtjumbo);
-	FALCON_STAT(efx, GRxFcsErr64to15xxPkt, rx_bad_64_to_15xx);
-	FALCON_STAT(efx, GRxFcsErr15xxtoJumboPkt, rx_bad_15xx_to_jumbo);
-	FALCON_STAT(efx, GRxFcsErrGtJumboPkt, rx_bad_gtjumbo);
-	FALCON_STAT(efx, GTxGoodBadOct, tx_bytes);
-	FALCON_STAT(efx, GTxGoodOct, tx_good_bytes);
-	FALCON_STAT(efx, GTxSglColPkt, tx_single_collision);
-	FALCON_STAT(efx, GTxMultColPkt, tx_multiple_collision);
-	FALCON_STAT(efx, GTxExColPkt, tx_excessive_collision);
-	FALCON_STAT(efx, GTxDefPkt, tx_deferred);
-	FALCON_STAT(efx, GTxLateCol, tx_late_collision);
-	FALCON_STAT(efx, GTxExDefPkt, tx_excessive_deferred);
-	FALCON_STAT(efx, GTxPausePkt, tx_pause);
-	FALCON_STAT(efx, GTxBadPkt, tx_bad);
-	FALCON_STAT(efx, GTxUcastPkt, tx_unicast);
-	FALCON_STAT(efx, GTxMcastPkt, tx_multicast);
-	FALCON_STAT(efx, GTxBcastPkt, tx_broadcast);
-	FALCON_STAT(efx, GTxLt64Pkt, tx_lt64);
-	FALCON_STAT(efx, GTx64Pkt, tx_64);
-	FALCON_STAT(efx, GTx65to127Pkt, tx_65_to_127);
-	FALCON_STAT(efx, GTx128to255Pkt, tx_128_to_255);
-	FALCON_STAT(efx, GTx256to511Pkt, tx_256_to_511);
-	FALCON_STAT(efx, GTx512to1023Pkt, tx_512_to_1023);
-	FALCON_STAT(efx, GTx1024to15xxPkt, tx_1024_to_15xx);
-	FALCON_STAT(efx, GTx15xxtoJumboPkt, tx_15xx_to_jumbo);
-	FALCON_STAT(efx, GTxGtJumboPkt, tx_gtjumbo);
-	FALCON_STAT(efx, GTxNonTcpUdpPkt, tx_non_tcpudp);
-	FALCON_STAT(efx, GTxMacSrcErrPkt, tx_mac_src_error);
-	FALCON_STAT(efx, GTxIpSrcErrPkt, tx_ip_src_error);
-
-	/* Pause frames are erroneously counted as errors (SFC bug 3269) */
-	new_rx_pause =3D mac_stats->rx_pause;
-	new_tx_pause =3D mac_stats->tx_pause;
-	mac_stats->rx_bad -=3D (new_rx_pause - old_rx_pause);
-	mac_stats->tx_bad -=3D (new_tx_pause - old_tx_pause);
-
-	/* Derive stats that the MAC doesn't provide directly */
-	mac_stats->tx_bad_bytes =3D
-		mac_stats->tx_bytes - mac_stats->tx_good_bytes;
-	mac_stats->tx_packets =3D
-		mac_stats->tx_lt64 + mac_stats->tx_64 +
-		mac_stats->tx_65_to_127 + mac_stats->tx_128_to_255 +
-		mac_stats->tx_256_to_511 + mac_stats->tx_512_to_1023 +
-		mac_stats->tx_1024_to_15xx + mac_stats->tx_15xx_to_jumbo +
-		mac_stats->tx_gtjumbo;
-	mac_stats->tx_collision =3D
-		mac_stats->tx_single_collision +
-		mac_stats->tx_multiple_collision +
-		mac_stats->tx_excessive_collision +
-		mac_stats->tx_late_collision;
-	mac_stats->rx_bytes =3D
-		mac_stats->rx_good_bytes + mac_stats->rx_bad_bytes;
-	mac_stats->rx_packets =3D
-		mac_stats->rx_good_lt64 + mac_stats->rx_bad_lt64 +
-		mac_stats->rx_64 + mac_stats->rx_65_to_127 +
-		mac_stats->rx_128_to_255 + mac_stats->rx_256_to_511 +
-		mac_stats->rx_512_to_1023 + mac_stats->rx_1024_to_15xx +
-		mac_stats->rx_15xx_to_jumbo + mac_stats->rx_gtjumbo;
-	mac_stats->rx_good =3D mac_stats->rx_packets - mac_stats->rx_bad;
-	mac_stats->rx_lt64 =3D mac_stats->rx_good_lt64 + mac_stats->rx_bad_lt=
64;
-}
-
-static bool falcon_gmac_check_fault(struct efx_nic *efx)
-{
-	return false;
-}
-
-struct efx_mac_operations falcon_gmac_operations =3D {
-	.reconfigure	=3D falcon_reconfigure_gmac,
-	.update_stats	=3D falcon_update_stats_gmac,
-	.check_fault 	=3D falcon_gmac_check_fault,
-};
diff --git a/drivers/net/sfc/mac.h b/drivers/net/sfc/mac.h
index f1aa5f3..7a6e5ca 100644
--- a/drivers/net/sfc/mac.h
+++ b/drivers/net/sfc/mac.h
@@ -13,7 +13,6 @@
=20
 #include "net_driver.h"
=20
-extern struct efx_mac_operations falcon_gmac_operations;
 extern struct efx_mac_operations falcon_xmac_operations;
 extern struct efx_mac_operations efx_mcdi_mac_operations;
 extern void falcon_reconfigure_xmac_core(struct efx_nic *efx);
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index eeaf0bd..98d9460 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -286,46 +286,24 @@ int efx_mdio_set_settings(struct efx_nic *efx, st=
ruct ethtool_cmd *ecmd)
  */
 void efx_mdio_an_reconfigure(struct efx_nic *efx)
 {
-	bool xnp =3D (efx->link_advertising & ADVERTISED_10000baseT_Full
-		    || EFX_WORKAROUND_13204(efx));
 	int reg;
=20
 	WARN_ON(!(efx->mdio.mmds & MDIO_DEVS_AN));
=20
 	/* Set up the base page */
-	reg =3D ADVERTISE_CSMA;
-	if (efx->link_advertising & ADVERTISED_10baseT_Half)
-		reg |=3D ADVERTISE_10HALF;
-	if (efx->link_advertising & ADVERTISED_10baseT_Full)
-		reg |=3D ADVERTISE_10FULL;
-	if (efx->link_advertising & ADVERTISED_100baseT_Half)
-		reg |=3D ADVERTISE_100HALF;
-	if (efx->link_advertising & ADVERTISED_100baseT_Full)
-		reg |=3D ADVERTISE_100FULL;
-	if (xnp)
-		reg |=3D ADVERTISE_RESV;
-	else if (efx->link_advertising & (ADVERTISED_1000baseT_Half |
-					  ADVERTISED_1000baseT_Full))
-		reg |=3D ADVERTISE_NPAGE;
+	reg =3D ADVERTISE_CSMA | ADVERTISE_RESV;
 	if (efx->link_advertising & ADVERTISED_Pause)
 		reg |=3D ADVERTISE_PAUSE_CAP;
 	if (efx->link_advertising & ADVERTISED_Asym_Pause)
 		reg |=3D ADVERTISE_PAUSE_ASYM;
 	efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, reg);
=20
-	/* Set up the (extended) next page if necessary */
-	if (efx->phy_op->set_npage_adv)
-		efx->phy_op->set_npage_adv(efx, efx->link_advertising);
+	/* Set up the (extended) next page */
+	efx->phy_op->set_npage_adv(efx, efx->link_advertising);
=20
 	/* Enable and restart AN */
 	reg =3D efx_mdio_read(efx, MDIO_MMD_AN, MDIO_CTRL1);
-	reg |=3D MDIO_AN_CTRL1_ENABLE;
-	if (!(EFX_WORKAROUND_15195(efx) && LOOPBACK_EXTERNAL(efx)))
-		reg |=3D MDIO_AN_CTRL1_RESTART;
-	if (xnp)
-		reg |=3D MDIO_AN_CTRL1_XNP;
-	else
-		reg &=3D ~MDIO_AN_CTRL1_XNP;
+	reg |=3D MDIO_AN_CTRL1_ENABLE | MDIO_AN_CTRL1_RESTART | MDIO_AN_CTRL1=
_XNP;
 	efx_mdio_write(efx, MDIO_MMD_AN, MDIO_CTRL1, reg);
 }
=20
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.=
h
index ea6691c..2497126 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -405,8 +405,6 @@ enum efx_int_mode {
 };
 #define EFX_INT_MODE_USE_MSI(x) (((x)->interrupt_mode) <=3D EFX_INT_MO=
DE_MSI)
=20
-#define EFX_IS10G(efx) ((efx)->link_state.speed =3D=3D 10000)
-
 enum nic_state {
 	STATE_INIT =3D 0,
 	STATE_RUNNING =3D 1,
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index 5bc2613..7ab0757 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -11,17 +11,12 @@
 #define EFX_PHY_H
=20
 /*********************************************************************=
*******
- * 10Xpress (SFX7101 and SFT9001) PHYs
+ * 10Xpress (SFX7101) PHY
  */
 extern struct efx_phy_operations falcon_sfx7101_phy_ops;
-extern struct efx_phy_operations falcon_sft9001_phy_ops;
=20
 extern void tenxpress_set_id_led(struct efx_nic *efx, enum efx_led_mod=
e mode);
=20
-/* Wait for the PHY to boot. Return 0 on success, -EINVAL if the PHY f=
ailed
- * to boot due to corrupt flash, or some other negative error code. */
-extern int sft9001_wait_boot(struct efx_nic *efx);
-
 /*********************************************************************=
*******
  * AMCC/Quake QT202x PHYs
  */
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 6791be9..1bc6c48 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -19,10 +19,7 @@
 #include "workarounds.h"
 #include "selftest.h"
=20
-/* We expect these MMDs to be in the package.  SFT9001 also has a
- * clause 22 extension MMD, but since it doesn't have all the generic
- * MMD registers it is pointless to include it here.
- */
+/* We expect these MMDs to be in the package. */
 #define TENXPRESS_REQUIRED_DEVS (MDIO_DEVS_PMAPMD	| \
 				 MDIO_DEVS_PCS		| \
 				 MDIO_DEVS_PHYXS	| \
@@ -33,12 +30,6 @@
 			   (1 << LOOPBACK_PMAPMD) |	\
 			   (1 << LOOPBACK_PHYXS_WS))
=20
-#define SFT9001_LOOPBACKS ((1 << LOOPBACK_GPHY) |	\
-			   (1 << LOOPBACK_PHYXS) |	\
-			   (1 << LOOPBACK_PCS) |	\
-			   (1 << LOOPBACK_PMAPMD) |	\
-			   (1 << LOOPBACK_PHYXS_WS))
-
 /* We complain if we fail to see the link partner as 10G capable this =
many
  * times in a row (must be > 1 as sampling the autoneg. registers is r=
acy)
  */
@@ -50,9 +41,8 @@
 #define PMA_PMD_EXT_GMII_EN_WIDTH 1
 #define PMA_PMD_EXT_CLK_OUT_LBN	2
 #define PMA_PMD_EXT_CLK_OUT_WIDTH 1
-#define PMA_PMD_LNPGA_POWERDOWN_LBN 8	/* SFX7101 only */
+#define PMA_PMD_LNPGA_POWERDOWN_LBN 8
 #define PMA_PMD_LNPGA_POWERDOWN_WIDTH 1
-#define PMA_PMD_EXT_CLK312_LBN	8	/* SFT9001 only */
 #define PMA_PMD_EXT_CLK312_WIDTH 1
 #define PMA_PMD_EXT_LPOWER_LBN  12
 #define PMA_PMD_EXT_LPOWER_WIDTH 1
@@ -84,7 +74,6 @@
 #define PMA_PMD_LED_FLASH	(3)
 #define PMA_PMD_LED_MASK	3
 /* All LEDs under hardware control */
-#define SFT9001_PMA_PMD_LED_DEFAULT 0
 /* Green and Amber under hardware control, Red off */
 #define SFX7101_PMA_PMD_LED_DEFAULT (PMA_PMD_LED_OFF << PMA_PMD_LED_RX=
_LBN)
=20
@@ -98,31 +87,7 @@
 #define PMA_PMD_SPEED_LBN        4
 #define PMA_PMD_SPEED_WIDTH      4
=20
-/* Cable diagnostics - SFT9001 only */
-#define PMA_PMD_CDIAG_CTRL_REG  49213
-#define CDIAG_CTRL_IMMED_LBN    15
-#define CDIAG_CTRL_BRK_LINK_LBN 12
-#define CDIAG_CTRL_IN_PROG_LBN  11
-#define CDIAG_CTRL_LEN_UNIT_LBN 10
-#define CDIAG_CTRL_LEN_METRES   1
-#define PMA_PMD_CDIAG_RES_REG   49174
-#define CDIAG_RES_A_LBN         12
-#define CDIAG_RES_B_LBN         8
-#define CDIAG_RES_C_LBN         4
-#define CDIAG_RES_D_LBN         0
-#define CDIAG_RES_WIDTH         4
-#define CDIAG_RES_OPEN          2
-#define CDIAG_RES_OK            1
-#define CDIAG_RES_INVALID       0
-/* Set of 4 registers for pairs A-D */
-#define PMA_PMD_CDIAG_LEN_REG   49175
-
-/* Serdes control registers - SFT9001 only */
-#define PMA_PMD_CSERDES_CTRL_REG 64258
-/* Set the 156.25 MHz output to 312.5 MHz to drive Falcon's XMAC */
-#define PMA_PMD_CSERDES_DEFAULT	0x000f
-
-/* Misc register defines - SFX7101 only */
+/* Misc register defines */
 #define PCS_CLOCK_CTRL_REG	55297
 #define PLL312_RST_N_LBN 2
=20
@@ -185,121 +150,17 @@ struct tenxpress_phy_data {
 	int bad_lp_tries;
 };
=20
-static ssize_t show_phy_short_reach(struct device *dev,
-				    struct device_attribute *attr, char *buf)
-{
-	struct efx_nic *efx =3D pci_get_drvdata(to_pci_dev(dev));
-	int reg;
-
-	reg =3D efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_PMA_10GBT_TXPWR);
-	return sprintf(buf, "%d\n", !!(reg & MDIO_PMA_10GBT_TXPWR_SHORT));
-}
-
-static ssize_t set_phy_short_reach(struct device *dev,
-				   struct device_attribute *attr,
-				   const char *buf, size_t count)
-{
-	struct efx_nic *efx =3D pci_get_drvdata(to_pci_dev(dev));
-	int rc;
-
-	rtnl_lock();
-	if (efx->state !=3D STATE_RUNNING) {
-		rc =3D -EBUSY;
-	} else {
-		efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, MDIO_PMA_10GBT_TXPWR,
-				  MDIO_PMA_10GBT_TXPWR_SHORT,
-				  count !=3D 0 && *buf !=3D '0');
-		rc =3D efx_reconfigure_port(efx);
-	}
-	rtnl_unlock();
-
-	return rc < 0 ? rc : (ssize_t)count;
-}
-
-static DEVICE_ATTR(phy_short_reach, 0644, show_phy_short_reach,
-		   set_phy_short_reach);
-
-int sft9001_wait_boot(struct efx_nic *efx)
-{
-	unsigned long timeout =3D jiffies + HZ + 1;
-	int boot_stat;
-
-	for (;;) {
-		boot_stat =3D efx_mdio_read(efx, MDIO_MMD_PCS,
-					  PCS_BOOT_STATUS_REG);
-		if (boot_stat >=3D 0) {
-			netif_dbg(efx, hw, efx->net_dev,
-				  "PHY boot status =3D %#x\n", boot_stat);
-			switch (boot_stat &
-				((1 << PCS_BOOT_FATAL_ERROR_LBN) |
-				 (3 << PCS_BOOT_PROGRESS_LBN) |
-				 (1 << PCS_BOOT_DOWNLOAD_WAIT_LBN) |
-				 (1 << PCS_BOOT_CODE_STARTED_LBN))) {
-			case ((1 << PCS_BOOT_FATAL_ERROR_LBN) |
-			      (PCS_BOOT_PROGRESS_CHECKSUM <<
-			       PCS_BOOT_PROGRESS_LBN)):
-			case ((1 << PCS_BOOT_FATAL_ERROR_LBN) |
-			      (PCS_BOOT_PROGRESS_INIT <<
-			       PCS_BOOT_PROGRESS_LBN) |
-			      (1 << PCS_BOOT_DOWNLOAD_WAIT_LBN)):
-				return -EINVAL;
-			case ((PCS_BOOT_PROGRESS_WAIT_MDIO <<
-			       PCS_BOOT_PROGRESS_LBN) |
-			      (1 << PCS_BOOT_DOWNLOAD_WAIT_LBN)):
-				return (efx->phy_mode & PHY_MODE_SPECIAL) ?
-					0 : -EIO;
-			case ((PCS_BOOT_PROGRESS_JUMP <<
-			       PCS_BOOT_PROGRESS_LBN) |
-			      (1 << PCS_BOOT_CODE_STARTED_LBN)):
-			case ((PCS_BOOT_PROGRESS_JUMP <<
-			       PCS_BOOT_PROGRESS_LBN) |
-			      (1 << PCS_BOOT_DOWNLOAD_WAIT_LBN) |
-			      (1 << PCS_BOOT_CODE_STARTED_LBN)):
-				return (efx->phy_mode & PHY_MODE_SPECIAL) ?
-					-EIO : 0;
-			default:
-				if (boot_stat & (1 << PCS_BOOT_FATAL_ERROR_LBN))
-					return -EIO;
-				break;
-			}
-		}
-
-		if (time_after_eq(jiffies, timeout))
-			return -ETIMEDOUT;
-
-		msleep(50);
-	}
-}
-
 static int tenxpress_init(struct efx_nic *efx)
 {
-	int reg;
-
-	if (efx->phy_type =3D=3D PHY_TYPE_SFX7101) {
-		/* Enable 312.5 MHz clock */
-		efx_mdio_write(efx, MDIO_MMD_PCS, PCS_TEST_SELECT_REG,
-			       1 << CLK312_EN_LBN);
-	} else {
-		/* Enable 312.5 MHz clock and GMII */
-		reg =3D efx_mdio_read(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG);
-		reg |=3D ((1 << PMA_PMD_EXT_GMII_EN_LBN) |
-			(1 << PMA_PMD_EXT_CLK_OUT_LBN) |
-			(1 << PMA_PMD_EXT_CLK312_LBN) |
-			(1 << PMA_PMD_EXT_ROBUST_LBN));
-
-		efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG, reg);
-		efx_mdio_set_flag(efx, MDIO_MMD_C22EXT,
-			      GPHY_XCONTROL_REG, 1 << GPHY_ISOLATE_LBN,
-			      false);
-	}
+	/* Enable 312.5 MHz clock */
+	efx_mdio_write(efx, MDIO_MMD_PCS, PCS_TEST_SELECT_REG,
+		       1 << CLK312_EN_LBN);
=20
 	/* Set the LEDs up as: Green =3D Link, Amber =3D Link/Act, Red =3D Of=
f */
-	if (efx->phy_type =3D=3D PHY_TYPE_SFX7101) {
-		efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_CTRL_REG,
-				  1 << PMA_PMA_LED_ACTIVITY_LBN, true);
-		efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG,
-			       SFX7101_PMA_PMD_LED_DEFAULT);
-	}
+	efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_CTRL_REG,
+			  1 << PMA_PMA_LED_ACTIVITY_LBN, true);
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG,
+		       SFX7101_PMA_PMD_LED_DEFAULT);
=20
 	return 0;
 }
@@ -307,7 +168,6 @@ static int tenxpress_init(struct efx_nic *efx)
 static int tenxpress_phy_probe(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data;
-	int rc;
=20
 	/* Allocate phy private storage */
 	phy_data =3D kzalloc(sizeof(*phy_data), GFP_KERNEL);
@@ -316,42 +176,15 @@ static int tenxpress_phy_probe(struct efx_nic *ef=
x)
 	efx->phy_data =3D phy_data;
 	phy_data->phy_mode =3D efx->phy_mode;
=20
-	/* Create any special files */
-	if (efx->phy_type =3D=3D PHY_TYPE_SFT9001B) {
-		rc =3D device_create_file(&efx->pci_dev->dev,
-					&dev_attr_phy_short_reach);
-		if (rc)
-			goto fail;
-	}
-
-	if (efx->phy_type =3D=3D PHY_TYPE_SFX7101) {
-		efx->mdio.mmds =3D TENXPRESS_REQUIRED_DEVS;
-		efx->mdio.mode_support =3D MDIO_SUPPORTS_C45;
-
-		efx->loopback_modes =3D SFX7101_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
+	efx->mdio.mmds =3D TENXPRESS_REQUIRED_DEVS;
+	efx->mdio.mode_support =3D MDIO_SUPPORTS_C45;
=20
-		efx->link_advertising =3D (ADVERTISED_TP | ADVERTISED_Autoneg |
-					 ADVERTISED_10000baseT_Full);
-	} else {
-		efx->mdio.mmds =3D TENXPRESS_REQUIRED_DEVS;
-		efx->mdio.mode_support =3D MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	efx->loopback_modes =3D SFX7101_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
=20
-		efx->loopback_modes =3D (SFT9001_LOOPBACKS |
-				       FALCON_XMAC_LOOPBACKS |=20
-				       FALCON_GMAC_LOOPBACKS);
-
-		efx->link_advertising =3D (ADVERTISED_TP | ADVERTISED_Autoneg |
-					 ADVERTISED_10000baseT_Full |
-					 ADVERTISED_1000baseT_Full |
-					 ADVERTISED_100baseT_Full);
-	}
+	efx->link_advertising =3D (ADVERTISED_TP | ADVERTISED_Autoneg |
+				 ADVERTISED_10000baseT_Full);
=20
 	return 0;
-
-fail:
-	kfree(efx->phy_data);
-	efx->phy_data =3D NULL;
-	return rc;
 }
=20
 static int tenxpress_phy_init(struct efx_nic *efx)
@@ -361,16 +194,6 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	falcon_board(efx)->type->init_phy(efx);
=20
 	if (!(efx->phy_mode & PHY_MODE_SPECIAL)) {
-		if (efx->phy_type =3D=3D PHY_TYPE_SFT9001A) {
-			int reg;
-			reg =3D efx_mdio_read(efx, MDIO_MMD_PMAPMD,
-					    PMA_PMD_XCONTROL_REG);
-			reg |=3D (1 << PMA_PMD_EXT_SSR_LBN);
-			efx_mdio_write(efx, MDIO_MMD_PMAPMD,
-				       PMA_PMD_XCONTROL_REG, reg);
-			mdelay(200);
-		}
-
 		rc =3D efx_mdio_wait_reset_mmds(efx, TENXPRESS_REQUIRED_DEVS);
 		if (rc < 0)
 			return rc;
@@ -403,7 +226,7 @@ static int tenxpress_special_reset(struct efx_nic *=
efx)
 {
 	int rc, reg;
=20
-	/* The XGMAC clock is driven from the SFC7101/SFT9001 312MHz clock, s=
o
+	/* The XGMAC clock is driven from the SFX7101 312MHz clock, so
 	 * a special software reset can glitch the XGMAC sufficiently for sta=
ts
 	 * requests to fail. */
 	falcon_stop_nic_stats(efx);
@@ -484,53 +307,18 @@ static bool sfx7101_link_ok(struct efx_nic *efx)
 				 MDIO_DEVS_PHYXS);
 }
=20
-static bool sft9001_link_ok(struct efx_nic *efx, struct ethtool_cmd *e=
cmd)
-{
-	u32 reg;
-
-	if (efx_phy_mode_disabled(efx->phy_mode))
-		return false;
-	else if (efx->loopback_mode =3D=3D LOOPBACK_GPHY)
-		return true;
-	else if (efx->loopback_mode)
-		return efx_mdio_links_ok(efx,
-					 MDIO_DEVS_PMAPMD |
-					 MDIO_DEVS_PHYXS);
-
-	/* We must use the same definition of link state as LASI,
-	 * otherwise we can miss a link state transition
-	 */
-	if (ecmd->speed =3D=3D 10000) {
-		reg =3D efx_mdio_read(efx, MDIO_MMD_PCS, MDIO_PCS_10GBRT_STAT1);
-		return reg & MDIO_PCS_10GBRT_STAT1_BLKLK;
-	} else {
-		reg =3D efx_mdio_read(efx, MDIO_MMD_C22EXT, C22EXT_STATUS_REG);
-		return reg & (1 << C22EXT_STATUS_LINK_LBN);
-	}
-}
-
 static void tenxpress_ext_loopback(struct efx_nic *efx)
 {
 	efx_mdio_set_flag(efx, MDIO_MMD_PHYXS, PHYXS_TEST1,
 			  1 << LOOPBACK_NEAR_LBN,
 			  efx->loopback_mode =3D=3D LOOPBACK_PHYXS);
-	if (efx->phy_type !=3D PHY_TYPE_SFX7101)
-		efx_mdio_set_flag(efx, MDIO_MMD_C22EXT, GPHY_XCONTROL_REG,
-				  1 << GPHY_LOOPBACK_NEAR_LBN,
-				  efx->loopback_mode =3D=3D LOOPBACK_GPHY);
 }
=20
 static void tenxpress_low_power(struct efx_nic *efx)
 {
-	if (efx->phy_type =3D=3D PHY_TYPE_SFX7101)
-		efx_mdio_set_mmds_lpower(
-			efx, !!(efx->phy_mode & PHY_MODE_LOW_POWER),
-			TENXPRESS_REQUIRED_DEVS);
-	else
-		efx_mdio_set_flag(
-			efx, MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG,
-			1 << PMA_PMD_EXT_LPOWER_LBN,
-			!!(efx->phy_mode & PHY_MODE_LOW_POWER));
+	efx_mdio_set_mmds_lpower(
+		efx, !!(efx->phy_mode & PHY_MODE_LOW_POWER),
+		TENXPRESS_REQUIRED_DEVS);
 }
=20
 static int tenxpress_phy_reconfigure(struct efx_nic *efx)
@@ -550,12 +338,7 @@ static int tenxpress_phy_reconfigure(struct efx_ni=
c *efx)
=20
 	if (loop_reset || phy_mode_change) {
 		tenxpress_special_reset(efx);
-
-		/* Reset XAUI if we were in 10G, and are staying
-		 * in 10G. If we're moving into and out of 10G
-		 * then xaui will be reset anyway */
-		if (EFX_IS10G(efx))
-			falcon_reset_xaui(efx);
+		falcon_reset_xaui(efx);
 	}
=20
 	tenxpress_low_power(efx);
@@ -578,29 +361,12 @@ static bool tenxpress_phy_poll(struct efx_nic *ef=
x)
 {
 	struct efx_link_state old_state =3D efx->link_state;
=20
-	if (efx->phy_type =3D=3D PHY_TYPE_SFX7101) {
-		efx->link_state.up =3D sfx7101_link_ok(efx);
-		efx->link_state.speed =3D 10000;
-		efx->link_state.fd =3D true;
-		efx->link_state.fc =3D efx_mdio_get_pause(efx);
-
-		sfx7101_check_bad_lp(efx, efx->link_state.up);
-	} else {
-		struct ethtool_cmd ecmd;
-
-		/* Check the LASI alarm first */
-		if (efx->loopback_mode =3D=3D LOOPBACK_NONE &&
-		    !(efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_STAT) &
-		      MDIO_PMA_LASI_LSALARM))
-			return false;
+	efx->link_state.up =3D sfx7101_link_ok(efx);
+	efx->link_state.speed =3D 10000;
+	efx->link_state.fd =3D true;
+	efx->link_state.fc =3D efx_mdio_get_pause(efx);
=20
-		tenxpress_get_settings(efx, &ecmd);
-
-		efx->link_state.up =3D sft9001_link_ok(efx, &ecmd);
-		efx->link_state.speed =3D ecmd.speed;
-		efx->link_state.fd =3D (ecmd.duplex =3D=3D DUPLEX_FULL);
-		efx->link_state.fc =3D efx_mdio_get_pause(efx);
-	}
+	sfx7101_check_bad_lp(efx, efx->link_state.up);
=20
 	return !efx_link_state_equal(&efx->link_state, &old_state);
 }
@@ -621,10 +387,6 @@ static void sfx7101_phy_fini(struct efx_nic *efx)
=20
 static void tenxpress_phy_remove(struct efx_nic *efx)
 {
-	if (efx->phy_type =3D=3D PHY_TYPE_SFT9001B)
-		device_remove_file(&efx->pci_dev->dev,
-				   &dev_attr_phy_short_reach);
-
 	kfree(efx->phy_data);
 	efx->phy_data =3D NULL;
 }
@@ -647,10 +409,7 @@ void tenxpress_set_id_led(struct efx_nic *efx, enu=
m efx_led_mode mode)
 			(PMA_PMD_LED_ON << PMA_PMD_LED_LINK_LBN);
 		break;
 	default:
-		if (efx->phy_type =3D=3D PHY_TYPE_SFX7101)
-			reg =3D SFX7101_PMA_PMD_LED_DEFAULT;
-		else
-			reg =3D SFT9001_PMA_PMD_LED_DEFAULT;
+		reg =3D SFX7101_PMA_PMD_LED_DEFAULT;
 		break;
 	}
=20
@@ -685,102 +444,12 @@ sfx7101_run_tests(struct efx_nic *efx, int *resu=
lts, unsigned flags)
 	return rc;
 }
=20
-static const char *const sft9001_test_names[] =3D {
-	"bist",
-	"cable.pairA.status",
-	"cable.pairB.status",
-	"cable.pairC.status",
-	"cable.pairD.status",
-	"cable.pairA.length",
-	"cable.pairB.length",
-	"cable.pairC.length",
-	"cable.pairD.length",
-};
-
-static const char *sft9001_test_name(struct efx_nic *efx, unsigned int=
 index)
-{
-	if (index < ARRAY_SIZE(sft9001_test_names))
-		return sft9001_test_names[index];
-	return NULL;
-}
-
-static int sft9001_run_tests(struct efx_nic *efx, int *results, unsign=
ed flags)
-{
-	int rc =3D 0, rc2, i, ctrl_reg, res_reg;
-
-	/* Initialise cable diagnostic results to unknown failure */
-	for (i =3D 1; i < 9; ++i)
-		results[i] =3D -1;
-
-	/* Run cable diagnostics; wait up to 5 seconds for them to complete.
-	 * A cable fault is not a self-test failure, but a timeout is. */
-	ctrl_reg =3D ((1 << CDIAG_CTRL_IMMED_LBN) |
-		    (CDIAG_CTRL_LEN_METRES << CDIAG_CTRL_LEN_UNIT_LBN));
-	if (flags & ETH_TEST_FL_OFFLINE) {
-		/* Break the link in order to run full diagnostics.  We
-		 * must reset the PHY to resume normal service. */
-		ctrl_reg |=3D (1 << CDIAG_CTRL_BRK_LINK_LBN);
-	}
-	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_CDIAG_CTRL_REG,
-		       ctrl_reg);
-	i =3D 0;
-	while (efx_mdio_read(efx, MDIO_MMD_PMAPMD, PMA_PMD_CDIAG_CTRL_REG) &
-	       (1 << CDIAG_CTRL_IN_PROG_LBN)) {
-		if (++i =3D=3D 50) {
-			rc =3D -ETIMEDOUT;
-			goto out;
-		}
-		msleep(100);
-	}
-	res_reg =3D efx_mdio_read(efx, MDIO_MMD_PMAPMD, PMA_PMD_CDIAG_RES_REG=
);
-	for (i =3D 0; i < 4; i++) {
-		int pair_res =3D
-			(res_reg >> (CDIAG_RES_A_LBN - i * CDIAG_RES_WIDTH))
-			& ((1 << CDIAG_RES_WIDTH) - 1);
-		int len_reg =3D efx_mdio_read(efx, MDIO_MMD_PMAPMD,
-					    PMA_PMD_CDIAG_LEN_REG + i);
-		if (pair_res =3D=3D CDIAG_RES_OK)
-			results[1 + i] =3D 1;
-		else if (pair_res =3D=3D CDIAG_RES_INVALID)
-			results[1 + i] =3D -1;
-		else
-			results[1 + i] =3D -pair_res;
-		if (pair_res !=3D CDIAG_RES_INVALID &&
-		    pair_res !=3D CDIAG_RES_OPEN &&
-		    len_reg !=3D 0xffff)
-			results[5 + i] =3D len_reg;
-	}
-
-out:
-	if (flags & ETH_TEST_FL_OFFLINE) {
-		/* Reset, running the BIST and then resuming normal service. */
-		rc2 =3D tenxpress_special_reset(efx);
-		results[0] =3D rc2 ? -1 : 1;
-		if (!rc)
-			rc =3D rc2;
-
-		efx_mdio_an_reconfigure(efx);
-	}
-
-	return rc;
-}
-
 static void
 tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
 	u32 adv =3D 0, lpa =3D 0;
 	int reg;
=20
-	if (efx->phy_type !=3D PHY_TYPE_SFX7101) {
-		reg =3D efx_mdio_read(efx, MDIO_MMD_C22EXT, C22EXT_MSTSLV_CTRL);
-		if (reg & (1 << C22EXT_MSTSLV_CTRL_ADV_1000_FD_LBN))
-			adv |=3D ADVERTISED_1000baseT_Full;
-		reg =3D efx_mdio_read(efx, MDIO_MMD_C22EXT, C22EXT_MSTSLV_STATUS);
-		if (reg & (1 << C22EXT_MSTSLV_STATUS_LP_1000_HD_LBN))
-			lpa |=3D ADVERTISED_1000baseT_Half;
-		if (reg & (1 << C22EXT_MSTSLV_STATUS_LP_1000_FD_LBN))
-			lpa |=3D ADVERTISED_1000baseT_Full;
-	}
 	reg =3D efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_10GBT_CTRL);
 	if (reg & MDIO_AN_10GBT_CTRL_ADV10G)
 		adv |=3D ADVERTISED_10000baseT_Full;
@@ -790,23 +459,9 @@ tenxpress_get_settings(struct efx_nic *efx, struct=
 ethtool_cmd *ecmd)
=20
 	mdio45_ethtool_gset_npage(&efx->mdio, ecmd, adv, lpa);
=20
-	if (efx->phy_type !=3D PHY_TYPE_SFX7101) {
-		ecmd->supported |=3D (SUPPORTED_100baseT_Full |
-				    SUPPORTED_1000baseT_Full);
-		if (ecmd->speed !=3D SPEED_10000) {
-			ecmd->eth_tp_mdix =3D
-				(efx_mdio_read(efx, MDIO_MMD_PMAPMD,
-					       PMA_PMD_XSTATUS_REG) &
-				 (1 << PMA_PMD_XSTAT_MDIX_LBN))
-				? ETH_TP_MDI_X : ETH_TP_MDI;
-		}
-	}
-
 	/* In loopback, the PHY automatically brings up the correct interface=
,
 	 * but doesn't advertise the correct speed. So override it */
-	if (efx->loopback_mode =3D=3D LOOPBACK_GPHY)
-		ecmd->speed =3D SPEED_1000;
-	else if (LOOPBACK_EXTERNAL(efx))
+	if (LOOPBACK_EXTERNAL(efx))
 		ecmd->speed =3D SPEED_10000;
 }
=20
@@ -825,16 +480,6 @@ static void sfx7101_set_npage_adv(struct efx_nic *=
efx, u32 advertising)
 			  advertising & ADVERTISED_10000baseT_Full);
 }
=20
-static void sft9001_set_npage_adv(struct efx_nic *efx, u32 advertising=
)
-{
-	efx_mdio_set_flag(efx, MDIO_MMD_C22EXT, C22EXT_MSTSLV_CTRL,
-			  1 << C22EXT_MSTSLV_CTRL_ADV_1000_FD_LBN,
-			  advertising & ADVERTISED_1000baseT_Full);
-	efx_mdio_set_flag(efx, MDIO_MMD_AN, MDIO_AN_10GBT_CTRL,
-			  MDIO_AN_10GBT_CTRL_ADV10G,
-			  advertising & ADVERTISED_10000baseT_Full);
-}
-
 struct efx_phy_operations falcon_sfx7101_phy_ops =3D {
 	.probe		  =3D tenxpress_phy_probe,
 	.init             =3D tenxpress_phy_init,
@@ -849,18 +494,3 @@ struct efx_phy_operations falcon_sfx7101_phy_ops =3D=
 {
 	.test_name	  =3D sfx7101_test_name,
 	.run_tests	  =3D sfx7101_run_tests,
 };
-
-struct efx_phy_operations falcon_sft9001_phy_ops =3D {
-	.probe		  =3D tenxpress_phy_probe,
-	.init             =3D tenxpress_phy_init,
-	.reconfigure      =3D tenxpress_phy_reconfigure,
-	.poll             =3D tenxpress_phy_poll,
-	.fini             =3D efx_port_dummy_op_void,
-	.remove		  =3D tenxpress_phy_remove,
-	.get_settings	  =3D tenxpress_get_settings,
-	.set_settings	  =3D tenxpress_set_settings,
-	.set_npage_adv    =3D sft9001_set_npage_adv,
-	.test_alive	  =3D efx_mdio_test_alive,
-	.test_name	  =3D sft9001_test_name,
-	.run_tests	  =3D sft9001_run_tests,
-};
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workaround=
s.h
index 782e45a..e0d6308 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -19,9 +19,7 @@
 #define EFX_WORKAROUND_FALCON_A(efx) (efx_nic_rev(efx) <=3D EFX_REV_FA=
LCON_A1)
 #define EFX_WORKAROUND_FALCON_AB(efx) (efx_nic_rev(efx) <=3D EFX_REV_F=
ALCON_B0)
 #define EFX_WORKAROUND_SIENA(efx) (efx_nic_rev(efx) =3D=3D EFX_REV_SIE=
NA_A0)
-#define EFX_WORKAROUND_10G(efx) EFX_IS10G(efx)
-#define EFX_WORKAROUND_SFT9001(efx) ((efx)->phy_type =3D=3D PHY_TYPE_S=
=46T9001A || \
-				     (efx)->phy_type =3D=3D PHY_TYPE_SFT9001B)
+#define EFX_WORKAROUND_10G(efx) 1
=20
 /* XAUI resets if link not detected */
 #define EFX_WORKAROUND_5147 EFX_WORKAROUND_ALWAYS
@@ -58,9 +56,4 @@
 /* Leak overlength packets rather than free */
 #define EFX_WORKAROUND_8071 EFX_WORKAROUND_FALCON_A
=20
-/* Need to send XNP pages for 100BaseT */
-#define EFX_WORKAROUND_13204 EFX_WORKAROUND_SFT9001
-/* Don't restart AN in near-side loopback */
-#define EFX_WORKAROUND_15195 EFX_WORKAROUND_SFT9001
-
 #endif /* EFX_WORKAROUNDS_H */
--=20
1.7.2.1



--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

