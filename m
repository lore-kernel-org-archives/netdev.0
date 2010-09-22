From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/2] sfc: Add support for SFE4003 board and
 TXC43128 PHY
Date: Wed, 22 Sep 2010 21:00:47 +0100
Message-ID: <1285185647.2279.17.camel@achroite.uk.solarflarecom.com>
References: <1285185501.2279.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:24085 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156Ab0IVUAu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 16:00:50 -0400
In-Reply-To: <1285185501.2279.14.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This board never went into production, but some engineering samples
are in use.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Makefile        |    3 +-
 drivers/net/sfc/falcon.c        |    3 +
 drivers/net/sfc/falcon_boards.c |   80 ++++++
 drivers/net/sfc/phy.h           |   11 +
 drivers/net/sfc/txc43128_phy.c  |  560 +++++++++++++++++++++++++++++++=
++++++++
 5 files changed, 656 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/sfc/txc43128_phy.c

diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index 39f7c1b..ab31c71 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,7 +1,8 @@
 sfc-y			+=3D efx.o nic.o falcon.o siena.o tx.o rx.o filter.o \
 			   falcon_xmac.o mcdi_mac.o \
 			   selftest.o ethtool.o qt202x_phy.o mdio_10g.o \
-			   tenxpress.o falcon_boards.o mcdi.o mcdi_phy.o
+			   tenxpress.o txc43128_phy.o falcon_boards.o \
+			   mcdi.o mcdi_phy.o
 sfc-$(CONFIG_SFC_MTD)	+=3D mtd.o
=20
 obj-$(CONFIG_SFC)	+=3D sfc.o
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 254a599..267019b 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -831,6 +831,9 @@ static int falcon_probe_port(struct efx_nic *efx)
 	case PHY_TYPE_QT2025C:
 		efx->phy_op =3D &falcon_qt202x_phy_ops;
 		break;
+	case PHY_TYPE_TXC43128:
+		efx->phy_op =3D &falcon_txc_phy_ops;
+		break;
 	default:
 		netif_err(efx, probe, efx->net_dev, "Unknown PHY type %d\n",
 			  efx->phy_type);
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_b=
oards.c
index bf029b3..cfc6a5b 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -26,6 +26,7 @@
 /* Board types */
 #define FALCON_BOARD_SFE4001 0x01
 #define FALCON_BOARD_SFE4002 0x02
+#define FALCON_BOARD_SFE4003 0x03
 #define FALCON_BOARD_SFN4112F 0x52
=20
 /* Board temperature is about 15=C2=B0C above ambient when air flow is
@@ -582,6 +583,75 @@ static int sfn4112f_init(struct efx_nic *efx)
 	return efx_init_lm87(efx, &sfn4112f_hwmon_info, sfn4112f_lm87_regs);
 }
=20
+/*********************************************************************=
********
+ * Support for the SFE4003
+ *
+ */
+static u8 sfe4003_lm87_channel =3D 0x03; /* use AIN not FAN inputs */
+
+static const u8 sfe4003_lm87_regs[] =3D {
+	LM87_IN_LIMITS(0, 0x67, 0x7f),		/* 2.5V:  1.5V +/- 10% */
+	LM87_IN_LIMITS(1, 0x4c, 0x5e),		/* Vccp1: 1.2V +/- 10% */
+	LM87_IN_LIMITS(2, 0xac, 0xd4),		/* 3.3V:  3.3V +/- 10% */
+	LM87_IN_LIMITS(4, 0xac, 0xe0),		/* 12V:   10.8-14V */
+	LM87_IN_LIMITS(5, 0x3f, 0x4f),		/* Vccp2: 1.0V +/- 10% */
+	LM87_TEMP_INT_LIMITS(0, 70 + FALCON_BOARD_TEMP_BIAS),
+	0
+};
+
+static struct i2c_board_info sfe4003_hwmon_info =3D {
+	I2C_BOARD_INFO("lm87", 0x2e),
+	.platform_data	=3D &sfe4003_lm87_channel,
+};
+
+/* Board-specific LED info. */
+#define SFE4003_RED_LED_GPIO	11
+#define SFE4003_LED_ON		1
+#define SFE4003_LED_OFF		0
+
+static void sfe4003_set_id_led(struct efx_nic *efx, enum efx_led_mode =
mode)
+{
+	struct falcon_board *board =3D falcon_board(efx);
+
+	/* The LEDs were not wired to GPIOs before A3 */
+	if (board->minor < 3 && board->major =3D=3D 0)
+		return;
+
+	falcon_txc_set_gpio_val(
+		efx, SFE4003_RED_LED_GPIO,
+		(mode =3D=3D EFX_LED_ON) ? SFE4003_LED_ON : SFE4003_LED_OFF);
+}
+
+static void sfe4003_init_phy(struct efx_nic *efx)
+{
+	struct falcon_board *board =3D falcon_board(efx);
+
+	/* The LEDs were not wired to GPIOs before A3 */
+	if (board->minor < 3 && board->major =3D=3D 0)
+		return;
+
+	falcon_txc_set_gpio_dir(efx, SFE4003_RED_LED_GPIO, TXC_GPIO_DIR_OUTPU=
T);
+	falcon_txc_set_gpio_val(efx, SFE4003_RED_LED_GPIO, SFE4003_LED_OFF);
+}
+
+static int sfe4003_check_hw(struct efx_nic *efx)
+{
+	struct falcon_board *board =3D falcon_board(efx);
+
+	/* A0/A1/A2 board rev. 4003s  report a temperature fault the whole ti=
me
+	 * (bad sensor) so we mask it out. */
+	unsigned alarm_mask =3D
+		(board->major =3D=3D 0 && board->minor <=3D 2) ?
+		~LM87_ALARM_TEMP_EXT1 : ~0;
+
+	return efx_check_lm87(efx, alarm_mask);
+}
+
+static int sfe4003_init(struct efx_nic *efx)
+{
+	return efx_init_lm87(efx, &sfe4003_hwmon_info, sfe4003_lm87_regs);
+}
+
 static const struct falcon_board_type board_types[] =3D {
 	{
 		.id		=3D FALCON_BOARD_SFE4001,
@@ -604,6 +674,16 @@ static const struct falcon_board_type board_types[=
] =3D {
 		.monitor	=3D sfe4002_check_hw,
 	},
 	{
+		.id		=3D FALCON_BOARD_SFE4003,
+		.ref_model	=3D "SFE4003",
+		.gen_type	=3D "10GBASE-CX4 adapter",
+		.init		=3D sfe4003_init,
+		.init_phy	=3D sfe4003_init_phy,
+		.fini		=3D efx_fini_lm87,
+		.set_id_led	=3D sfe4003_set_id_led,
+		.monitor	=3D sfe4003_check_hw,
+	},
+	{
 		.id		=3D FALCON_BOARD_SFN4112F,
 		.ref_model	=3D "SFN4112F",
 		.gen_type	=3D "SFP+ adapter",
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index 7ab0757..1dab609 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -37,6 +37,17 @@ extern struct efx_phy_operations falcon_qt202x_phy_o=
ps;
 extern void falcon_qt202x_set_led(struct efx_nic *p, int led, int stat=
e);
=20
 /*********************************************************************=
*******
+* Transwitch CX4 retimer
+*/
+extern struct efx_phy_operations falcon_txc_phy_ops;
+
+#define TXC_GPIO_DIR_INPUT	0
+#define TXC_GPIO_DIR_OUTPUT	1
+
+extern void falcon_txc_set_gpio_dir(struct efx_nic *efx, int pin, int =
dir);
+extern void falcon_txc_set_gpio_val(struct efx_nic *efx, int pin, int =
val);
+
+/*********************************************************************=
*******
  * Siena managed PHYs
  */
 extern struct efx_phy_operations efx_mcdi_phy_ops;
diff --git a/drivers/net/sfc/txc43128_phy.c b/drivers/net/sfc/txc43128_=
phy.c
new file mode 100644
index 0000000..351794a
--- /dev/null
+++ b/drivers/net/sfc/txc43128_phy.c
@@ -0,0 +1,560 @@
+/*********************************************************************=
*******
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2006-2010 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License version 2 as publ=
ished
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+/*
+ * Driver for Transwitch/Mysticom CX4 retimer
+ * see www.transwitch.com, part is TXC-43128
+ */
+
+#include <linux/delay.h>
+#include <linux/slab.h>
+#include "efx.h"
+#include "mdio_10g.h"
+#include "phy.h"
+#include "nic.h"
+
+/* We expect these MMDs to be in the package */
+#define TXC_REQUIRED_DEVS (MDIO_DEVS_PCS |	\
+			   MDIO_DEVS_PMAPMD |	\
+			   MDIO_DEVS_PHYXS)
+
+#define TXC_LOOPBACKS ((1 << LOOPBACK_PCS) |	\
+		       (1 << LOOPBACK_PMAPMD) |	\
+		       (1 << LOOPBACK_PHYXS_WS))
+
+/*********************************************************************=
*****
+ *
+ * Compile-time config
+ *
+ *********************************************************************=
*****
+ */
+#define TXCNAME "TXC43128"
+/* Total length of time we'll wait for the PHY to come out of reset (m=
s) */
+#define TXC_MAX_RESET_TIME	500
+/* Interval between checks (ms) */
+#define TXC_RESET_WAIT		10
+/* How long to run BIST (us) */
+#define TXC_BIST_DURATION	50
+
+/*********************************************************************=
*****
+ *
+ * Register definitions
+ *
+ *********************************************************************=
*****
+ */
+
+/* Command register */
+#define TXC_GLRGS_GLCMD		0xc004
+/* Useful bits in command register */
+/* Lane power-down */
+#define TXC_GLCMD_L01PD_LBN	5
+#define TXC_GLCMD_L23PD_LBN	6
+/* Limited SW reset: preserves configuration but
+ * initiates a logic reset. Self-clearing */
+#define TXC_GLCMD_LMTSWRST_LBN	14
+
+/* Signal Quality Control */
+#define TXC_GLRGS_GSGQLCTL	0xc01a
+/* Enable bit */
+#define TXC_GSGQLCT_SGQLEN_LBN	15
+/* Lane selection */
+#define TXC_GSGQLCT_LNSL_LBN	13
+#define TXC_GSGQLCT_LNSL_WIDTH	2
+
+/* Analog TX control */
+#define TXC_ALRGS_ATXCTL	0xc040
+/* Lane power-down */
+#define TXC_ATXCTL_TXPD3_LBN	15
+#define TXC_ATXCTL_TXPD2_LBN	14
+#define TXC_ATXCTL_TXPD1_LBN	13
+#define TXC_ATXCTL_TXPD0_LBN	12
+
+/* Amplitude on lanes 0, 1 */
+#define TXC_ALRGS_ATXAMP0	0xc041
+/* Amplitude on lanes 2, 3 */
+#define TXC_ALRGS_ATXAMP1	0xc042
+/* Bit position of value for lane 0 (or 2) */
+#define TXC_ATXAMP_LANE02_LBN	3
+/* Bit position of value for lane 1 (or 3) */
+#define TXC_ATXAMP_LANE13_LBN	11
+
+#define TXC_ATXAMP_1280_mV	0
+#define TXC_ATXAMP_1200_mV	8
+#define TXC_ATXAMP_1120_mV	12
+#define TXC_ATXAMP_1060_mV	14
+#define TXC_ATXAMP_0820_mV	25
+#define TXC_ATXAMP_0720_mV	26
+#define TXC_ATXAMP_0580_mV	27
+#define TXC_ATXAMP_0440_mV	28
+
+#define TXC_ATXAMP_0820_BOTH					\
+	((TXC_ATXAMP_0820_mV << TXC_ATXAMP_LANE02_LBN)		\
+	 | (TXC_ATXAMP_0820_mV << TXC_ATXAMP_LANE13_LBN))
+
+#define TXC_ATXAMP_DEFAULT	0x6060 /* From databook */
+
+/* Preemphasis on lanes 0, 1 */
+#define TXC_ALRGS_ATXPRE0	0xc043
+/* Preemphasis on lanes 2, 3 */
+#define TXC_ALRGS_ATXPRE1	0xc044
+
+#define TXC_ATXPRE_NONE 0
+#define TXC_ATXPRE_DEFAULT	0x1010 /* From databook */
+
+#define TXC_ALRGS_ARXCTL	0xc045
+/* Lane power-down */
+#define TXC_ARXCTL_RXPD3_LBN	15
+#define TXC_ARXCTL_RXPD2_LBN	14
+#define TXC_ARXCTL_RXPD1_LBN	13
+#define TXC_ARXCTL_RXPD0_LBN	12
+
+/* Main control */
+#define TXC_MRGS_CTL		0xc340
+/* Bits in main control */
+#define TXC_MCTL_RESET_LBN	15	/* Self clear */
+#define TXC_MCTL_TXLED_LBN	14	/* 1 to show align status */
+#define TXC_MCTL_RXLED_LBN	13	/* 1 to show align status */
+
+/* GPIO output */
+#define TXC_GPIO_OUTPUT		0xc346
+#define TXC_GPIO_DIR		0xc348
+
+/* Vendor-specific BIST registers */
+#define TXC_BIST_CTL		0xc280
+#define TXC_BIST_TXFRMCNT	0xc281
+#define TXC_BIST_RX0FRMCNT	0xc282
+#define TXC_BIST_RX1FRMCNT	0xc283
+#define TXC_BIST_RX2FRMCNT	0xc284
+#define TXC_BIST_RX3FRMCNT	0xc285
+#define TXC_BIST_RX0ERRCNT	0xc286
+#define TXC_BIST_RX1ERRCNT	0xc287
+#define TXC_BIST_RX2ERRCNT	0xc288
+#define TXC_BIST_RX3ERRCNT	0xc289
+
+/* BIST type (controls bit patter in test) */
+#define TXC_BIST_CTRL_TYPE_LBN	10
+#define TXC_BIST_CTRL_TYPE_TSD	0	/* TranSwitch Deterministic */
+#define TXC_BIST_CTRL_TYPE_CRP	1	/* CRPAT standard */
+#define TXC_BIST_CTRL_TYPE_CJP	2	/* CJPAT standard */
+#define TXC_BIST_CTRL_TYPE_TSR	3	/* TranSwitch pseudo-random */
+/* Set this to 1 for 10 bit and 0 for 8 bit */
+#define TXC_BIST_CTRL_B10EN_LBN	12
+/* Enable BIST (write 0 to disable) */
+#define TXC_BIST_CTRL_ENAB_LBN	13
+/* Stop BIST (self-clears when stop complete) */
+#define TXC_BIST_CTRL_STOP_LBN	14
+/* Start BIST (cleared by writing 1 to STOP) */
+#define TXC_BIST_CTRL_STRT_LBN	15
+
+/* Mt. Diablo test configuration */
+#define TXC_MTDIABLO_CTRL	0xc34f
+#define TXC_MTDIABLO_CTRL_PMA_LOOP_LBN	10
+
+struct txc43128_data {
+	unsigned long bug10934_timer;
+	enum efx_phy_mode phy_mode;
+	enum efx_loopback_mode loopback_mode;
+};
+
+/* The PHY sometimes needs a reset to bring the link back up.  So long=
 as
+ * it reports link down, we reset it every 5 seconds.
+ */
+#define BUG10934_RESET_INTERVAL (5 * HZ)
+
+/* Perform a reset that doesn't clear configuration changes */
+static void txc_reset_logic(struct efx_nic *efx);
+
+/* Set the output value of a gpio */
+void falcon_txc_set_gpio_val(struct efx_nic *efx, int pin, int on)
+{
+	efx_mdio_set_flag(efx, MDIO_MMD_PHYXS, TXC_GPIO_OUTPUT, 1 << pin, on)=
;
+}
+
+/* Set up the GPIO direction register */
+void falcon_txc_set_gpio_dir(struct efx_nic *efx, int pin, int dir)
+{
+	efx_mdio_set_flag(efx, MDIO_MMD_PHYXS, TXC_GPIO_DIR, 1 << pin, dir);
+}
+
+/* Reset the PMA/PMD MMD. The documentation is explicit that this does=
 a
+ * global reset (it's less clear what reset of other MMDs does).*/
+static int txc_reset_phy(struct efx_nic *efx)
+{
+	int rc =3D efx_mdio_reset_mmd(efx, MDIO_MMD_PMAPMD,
+				    TXC_MAX_RESET_TIME / TXC_RESET_WAIT,
+				    TXC_RESET_WAIT);
+	if (rc < 0)
+		goto fail;
+
+	/* Check that all the MMDs we expect are present and responding. */
+	rc =3D efx_mdio_check_mmds(efx, TXC_REQUIRED_DEVS, 0);
+	if (rc < 0)
+		goto fail;
+
+	return 0;
+
+fail:
+	netif_err(efx, hw, efx->net_dev, TXCNAME ": reset timed out!\n");
+	return rc;
+}
+
+/* Run a single BIST on one MMD */
+static int txc_bist_one(struct efx_nic *efx, int mmd, int test)
+{
+	int ctrl, bctl;
+	int lane;
+	int rc =3D 0;
+
+	/* Set PMA to test into loopback using Mt Diablo reg as per app note =
*/
+	ctrl =3D efx_mdio_read(efx, MDIO_MMD_PCS, TXC_MTDIABLO_CTRL);
+	ctrl |=3D (1 << TXC_MTDIABLO_CTRL_PMA_LOOP_LBN);
+	efx_mdio_write(efx, MDIO_MMD_PCS, TXC_MTDIABLO_CTRL, ctrl);
+
+	/* The BIST app. note lists these  as 3 distinct steps. */
+	/* Set the BIST type */
+	bctl =3D (test << TXC_BIST_CTRL_TYPE_LBN);
+	efx_mdio_write(efx, mmd, TXC_BIST_CTL, bctl);
+
+	/* Set the BSTEN bit in the BIST Control register to enable */
+	bctl |=3D (1 << TXC_BIST_CTRL_ENAB_LBN);
+	efx_mdio_write(efx, mmd, TXC_BIST_CTL, bctl);
+
+	/* Set the BSTRT bit in the BIST Control register */
+	efx_mdio_write(efx, mmd, TXC_BIST_CTL,
+		       bctl | (1 << TXC_BIST_CTRL_STRT_LBN));
+
+	/* Wait. */
+	udelay(TXC_BIST_DURATION);
+
+	/* Set the BSTOP bit in the BIST Control register */
+	bctl |=3D (1 << TXC_BIST_CTRL_STOP_LBN);
+	efx_mdio_write(efx, mmd, TXC_BIST_CTL, bctl);
+
+	/* The STOP bit should go off when things have stopped */
+	while (bctl & (1 << TXC_BIST_CTRL_STOP_LBN))
+		bctl =3D efx_mdio_read(efx, mmd, TXC_BIST_CTL);
+
+	/* Check all the error counts are 0 and all the frame counts are
+	   non-zero */
+	for (lane =3D 0; lane < 4; lane++) {
+		int count =3D efx_mdio_read(efx, mmd, TXC_BIST_RX0ERRCNT + lane);
+		if (count !=3D 0) {
+			netif_err(efx, hw, efx->net_dev, TXCNAME": BIST error. "
+				  "Lane %d had %d errs\n", lane, count);
+			rc =3D -EIO;
+		}
+		count =3D efx_mdio_read(efx, mmd, TXC_BIST_RX0FRMCNT + lane);
+		if (count =3D=3D 0) {
+			netif_err(efx, hw, efx->net_dev, TXCNAME": BIST error. "
+				  "Lane %d got 0 frames\n", lane);
+			rc =3D -EIO;
+		}
+	}
+
+	if (rc =3D=3D 0)
+		netif_info(efx, hw, efx->net_dev, TXCNAME": BIST pass\n");
+
+	/* Disable BIST */
+	efx_mdio_write(efx, mmd, TXC_BIST_CTL, 0);
+
+	/* Turn off loopback */
+	ctrl &=3D ~(1 << TXC_MTDIABLO_CTRL_PMA_LOOP_LBN);
+	efx_mdio_write(efx, MDIO_MMD_PCS, TXC_MTDIABLO_CTRL, ctrl);
+
+	return rc;
+}
+
+static int txc_bist(struct efx_nic *efx)
+{
+	return txc_bist_one(efx, MDIO_MMD_PCS, TXC_BIST_CTRL_TYPE_TSD);
+}
+
+/* Push the non-configurable defaults into the PHY. This must be
+ * done after every full reset */
+static void txc_apply_defaults(struct efx_nic *efx)
+{
+	int mctrl;
+
+	/* Turn amplitude down and preemphasis off on the host side
+	 * (PHY<->MAC) as this is believed less likely to upset Falcon
+	 * and no adverse effects have been noted. It probably also
+	 * saves a picowatt or two */
+
+	/* Turn off preemphasis */
+	efx_mdio_write(efx, MDIO_MMD_PHYXS, TXC_ALRGS_ATXPRE0, TXC_ATXPRE_NON=
E);
+	efx_mdio_write(efx, MDIO_MMD_PHYXS, TXC_ALRGS_ATXPRE1, TXC_ATXPRE_NON=
E);
+
+	/* Turn down the amplitude */
+	efx_mdio_write(efx, MDIO_MMD_PHYXS,
+		       TXC_ALRGS_ATXAMP0, TXC_ATXAMP_0820_BOTH);
+	efx_mdio_write(efx, MDIO_MMD_PHYXS,
+		       TXC_ALRGS_ATXAMP1, TXC_ATXAMP_0820_BOTH);
+
+	/* Set the line side amplitude and preemphasis to the databook
+	 * defaults as an erratum causes them to be 0 on at least some
+	 * PHY rev.s */
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD,
+		       TXC_ALRGS_ATXPRE0, TXC_ATXPRE_DEFAULT);
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD,
+		       TXC_ALRGS_ATXPRE1, TXC_ATXPRE_DEFAULT);
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD,
+		       TXC_ALRGS_ATXAMP0, TXC_ATXAMP_DEFAULT);
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD,
+		       TXC_ALRGS_ATXAMP1, TXC_ATXAMP_DEFAULT);
+
+	/* Set up the LEDs  */
+	mctrl =3D efx_mdio_read(efx, MDIO_MMD_PHYXS, TXC_MRGS_CTL);
+
+	/* Set the Green and Red LEDs to their default modes */
+	mctrl &=3D ~((1 << TXC_MCTL_TXLED_LBN) | (1 << TXC_MCTL_RXLED_LBN));
+	efx_mdio_write(efx, MDIO_MMD_PHYXS, TXC_MRGS_CTL, mctrl);
+
+	/* Databook recommends doing this after configuration changes */
+	txc_reset_logic(efx);
+
+	falcon_board(efx)->type->init_phy(efx);
+}
+
+static int txc43128_phy_probe(struct efx_nic *efx)
+{
+	struct txc43128_data *phy_data;
+
+	/* Allocate phy private storage */
+	phy_data =3D kzalloc(sizeof(*phy_data), GFP_KERNEL);
+	if (!phy_data)
+		return -ENOMEM;
+	efx->phy_data =3D phy_data;
+	phy_data->phy_mode =3D efx->phy_mode;
+
+	efx->mdio.mmds =3D TXC_REQUIRED_DEVS;
+	efx->mdio.mode_support =3D MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+
+	efx->loopback_modes =3D TXC_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
+
+	return 0;
+}
+
+/* Initialisation entry point for this PHY driver */
+static int txc43128_phy_init(struct efx_nic *efx)
+{
+	int rc;
+
+	rc =3D txc_reset_phy(efx);
+	if (rc < 0)
+		return rc;
+
+	rc =3D txc_bist(efx);
+	if (rc < 0)
+		return rc;
+
+	txc_apply_defaults(efx);
+
+	return 0;
+}
+
+/* Set the lane power down state in the global registers */
+static void txc_glrgs_lane_power(struct efx_nic *efx, int mmd)
+{
+	int pd =3D (1 << TXC_GLCMD_L01PD_LBN) | (1 << TXC_GLCMD_L23PD_LBN);
+	int ctl =3D efx_mdio_read(efx, mmd, TXC_GLRGS_GLCMD);
+
+	if (!(efx->phy_mode & PHY_MODE_LOW_POWER))
+		ctl &=3D ~pd;
+	else
+		ctl |=3D pd;
+
+	efx_mdio_write(efx, mmd, TXC_GLRGS_GLCMD, ctl);
+}
+
+/* Set the lane power down state in the analog control registers */
+static void txc_analog_lane_power(struct efx_nic *efx, int mmd)
+{
+	int txpd =3D (1 << TXC_ATXCTL_TXPD3_LBN) | (1 << TXC_ATXCTL_TXPD2_LBN=
)
+		| (1 << TXC_ATXCTL_TXPD1_LBN) | (1 << TXC_ATXCTL_TXPD0_LBN);
+	int rxpd =3D (1 << TXC_ARXCTL_RXPD3_LBN) | (1 << TXC_ARXCTL_RXPD2_LBN=
)
+		| (1 << TXC_ARXCTL_RXPD1_LBN) | (1 << TXC_ARXCTL_RXPD0_LBN);
+	int txctl =3D efx_mdio_read(efx, mmd, TXC_ALRGS_ATXCTL);
+	int rxctl =3D efx_mdio_read(efx, mmd, TXC_ALRGS_ARXCTL);
+
+	if (!(efx->phy_mode & PHY_MODE_LOW_POWER)) {
+		txctl &=3D ~txpd;
+		rxctl &=3D ~rxpd;
+	} else {
+		txctl |=3D txpd;
+		rxctl |=3D rxpd;
+	}
+
+	efx_mdio_write(efx, mmd, TXC_ALRGS_ATXCTL, txctl);
+	efx_mdio_write(efx, mmd, TXC_ALRGS_ARXCTL, rxctl);
+}
+
+static void txc_set_power(struct efx_nic *efx)
+{
+	/* According to the data book, all the MMDs can do low power */
+	efx_mdio_set_mmds_lpower(efx,
+				 !!(efx->phy_mode & PHY_MODE_LOW_POWER),
+				 TXC_REQUIRED_DEVS);
+
+	/* Global register bank is in PCS, PHY XS. These control the host
+	 * side and line side settings respectively. */
+	txc_glrgs_lane_power(efx, MDIO_MMD_PCS);
+	txc_glrgs_lane_power(efx, MDIO_MMD_PHYXS);
+
+	/* Analog register bank in PMA/PMD, PHY XS */
+	txc_analog_lane_power(efx, MDIO_MMD_PMAPMD);
+	txc_analog_lane_power(efx, MDIO_MMD_PHYXS);
+}
+
+static void txc_reset_logic_mmd(struct efx_nic *efx, int mmd)
+{
+	int val =3D efx_mdio_read(efx, mmd, TXC_GLRGS_GLCMD);
+	int tries =3D 50;
+
+	val |=3D (1 << TXC_GLCMD_LMTSWRST_LBN);
+	efx_mdio_write(efx, mmd, TXC_GLRGS_GLCMD, val);
+	while (tries--) {
+		val =3D efx_mdio_read(efx, mmd, TXC_GLRGS_GLCMD);
+		if (!(val & (1 << TXC_GLCMD_LMTSWRST_LBN)))
+			break;
+		udelay(1);
+	}
+	if (!tries)
+		netif_info(efx, hw, efx->net_dev,
+			   TXCNAME " Logic reset timed out!\n");
+}
+
+/* Perform a logic reset. This preserves the configuration registers
+ * and is needed for some configuration changes to take effect */
+static void txc_reset_logic(struct efx_nic *efx)
+{
+	/* The data sheet claims we can do the logic reset on either the
+	 * PCS or the PHYXS and the result is a reset of both host- and
+	 * line-side logic. */
+	txc_reset_logic_mmd(efx, MDIO_MMD_PCS);
+}
+
+static bool txc43128_phy_read_link(struct efx_nic *efx)
+{
+	return efx_mdio_links_ok(efx, TXC_REQUIRED_DEVS);
+}
+
+static int txc43128_phy_reconfigure(struct efx_nic *efx)
+{
+	struct txc43128_data *phy_data =3D efx->phy_data;
+	enum efx_phy_mode mode_change =3D efx->phy_mode ^ phy_data->phy_mode;
+	bool loop_change =3D LOOPBACK_CHANGED(phy_data, efx, TXC_LOOPBACKS);
+
+	if (efx->phy_mode & mode_change & PHY_MODE_TX_DISABLED) {
+		txc_reset_phy(efx);
+		txc_apply_defaults(efx);
+		falcon_reset_xaui(efx);
+		mode_change &=3D ~PHY_MODE_TX_DISABLED;
+	}
+
+	efx_mdio_transmit_disable(efx);
+	efx_mdio_phy_reconfigure(efx);
+	if (mode_change & PHY_MODE_LOW_POWER)
+		txc_set_power(efx);
+
+	/* The data sheet claims this is required after every reconfiguration
+	 * (note at end of 7.1), but we mustn't do it when nothing changes as
+	 * it glitches the link, and reconfigure gets called on link change,
+	 * so we get an IRQ storm on link up. */
+	if (loop_change || mode_change)
+		txc_reset_logic(efx);
+
+	phy_data->phy_mode =3D efx->phy_mode;
+	phy_data->loopback_mode =3D efx->loopback_mode;
+
+	return 0;
+}
+
+static void txc43128_phy_fini(struct efx_nic *efx)
+{
+	/* Disable link events */
+	efx_mdio_write(efx, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_CTRL, 0);
+}
+
+static void txc43128_phy_remove(struct efx_nic *efx)
+{
+	kfree(efx->phy_data);
+	efx->phy_data =3D NULL;
+}
+
+/* Periodic callback: this exists mainly to poll link status as we
+ * don't use LASI interrupts */
+static bool txc43128_phy_poll(struct efx_nic *efx)
+{
+	struct txc43128_data *data =3D efx->phy_data;
+	bool was_up =3D efx->link_state.up;
+
+	efx->link_state.up =3D txc43128_phy_read_link(efx);
+	efx->link_state.speed =3D 10000;
+	efx->link_state.fd =3D true;
+	efx->link_state.fc =3D efx->wanted_fc;
+
+	if (efx->link_state.up || (efx->loopback_mode !=3D LOOPBACK_NONE)) {
+		data->bug10934_timer =3D jiffies;
+	} else {
+		if (time_after_eq(jiffies, (data->bug10934_timer +
+					    BUG10934_RESET_INTERVAL))) {
+			data->bug10934_timer =3D jiffies;
+			txc_reset_logic(efx);
+		}
+	}
+
+	return efx->link_state.up !=3D was_up;
+}
+
+static const char *txc43128_test_names[] =3D {
+	"bist"
+};
+
+static const char *txc43128_test_name(struct efx_nic *efx, unsigned in=
t index)
+{
+	if (index < ARRAY_SIZE(txc43128_test_names))
+		return txc43128_test_names[index];
+	return NULL;
+}
+
+static int txc43128_run_tests(struct efx_nic *efx, int *results, unsig=
ned flags)
+{
+	int rc;
+
+	if (!(flags & ETH_TEST_FL_OFFLINE))
+		return 0;
+
+	rc =3D txc_reset_phy(efx);
+	if (rc < 0)
+		return rc;
+
+	rc =3D txc_bist(efx);
+	txc_apply_defaults(efx);
+	results[0] =3D rc ? -1 : 1;
+	return rc;
+}
+
+static void txc43128_get_settings(struct efx_nic *efx, struct ethtool_=
cmd *ecmd)
+{
+	mdio45_ethtool_gset(&efx->mdio, ecmd);
+}
+
+struct efx_phy_operations falcon_txc_phy_ops =3D {
+	.probe		=3D txc43128_phy_probe,
+	.init		=3D txc43128_phy_init,
+	.reconfigure	=3D txc43128_phy_reconfigure,
+	.poll		=3D txc43128_phy_poll,
+	.fini		=3D txc43128_phy_fini,
+	.remove		=3D txc43128_phy_remove,
+	.get_settings	=3D txc43128_get_settings,
+	.set_settings	=3D efx_mdio_set_settings,
+	.test_alive	=3D efx_mdio_test_alive,
+	.run_tests	=3D txc43128_run_tests,
+	.test_name	=3D txc43128_test_name,
+};
--=20
1.7.2.1


--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

