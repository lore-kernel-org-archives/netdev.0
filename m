From: "David S. Miller" <davem@redhat.com>
Subject: [PATCH] Tigon3 driver update
Date: Sat, 23 Aug 2003 21:49:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030823214939.0c012f3d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Included is a Tigon3 driver test patch against current
2.6.0-testX kernels.

Features:

1) Full 5705/5782/5788/5901 support.
2) More reliable PHY resetting on 5703/5704/5705.
3) Updated TSO support, it is not enabled by default
   but one can turn it on using a current version of ethtool.

Feedback welcome.

Enjoy.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1315  -> 1.1330 
#	   drivers/net/tg3.h	1.25    -> 1.30   
#	  net/core/ethtool.c	1.2     -> 1.3    
#	include/linux/ethtool.h	1.19    -> 1.20   
#	include/linux/pci_ids.h	1.116   -> 1.119  
#	 drivers/pci/pci.ids	1.50    -> 1.51   
#	   drivers/net/tg3.c	1.82    -> 1.96   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/22	davem@nuts.ninka.net	1.1316
# [TG3]: Initial implementation of 5705 support.
# --------------------------------------------
# 03/08/22	jgarzik@redhat.com	1.1317
# [TG3]: Bug fixes for 5705 support.
# 
# - (major) status block DMA address wasn't being set, for 5705. whoops. :)
# - (minor) pass 5705-specific RX_STD_MAX_SIZE
# - (minor) don't program RCVBDI_JUMBO_THRESH reg on 5705
# - (very minor) re-order *THRESH, HOSTCC* regs per bcm570x driver order
# --------------------------------------------
# 03/08/22	jgarzik@redhat.com	1.1318
# [TG3]: More 5705 updates.
# 
# - do not zero stats/status block on 5705, they don't exist
#   (in controller memory, at least)
# - define TG3_MAX_MTU macro such that it takes a (tp) pointer arg,
#   because the value varies between 5705 and non-5705
# - use the macro to simply tg3_change_mtu
# --------------------------------------------
# 03/08/22	jgarzik@redhat.com	1.1319
# [TG3]: More 5705 fixes.
# 
# - call set-wire-speed phy function from tg3_phy_reset, not just _phy_probe
# - disable set-wire-speed usage on certain chips, per bcm5700 driver
# --------------------------------------------
# 03/08/22	jgarzik@redhat.com	1.1320
# [TG3]: Another 5705 fix: enable eeprom write prot as needed.
# --------------------------------------------
# 03/08/22	jgarzik@redhat.com	1.1321
# [TG3]: Only write the on-nic sram addr on non-5705.
# --------------------------------------------
# 03/08/22	jgarzik@redhat.com	1.1322
# [TG3]: Add 5782 pci id.
# --------------------------------------------
# 03/08/22	davem@nuts.ninka.net	1.1323
# [TG3]: Fix statistics on 5705.
# --------------------------------------------
# 03/08/22	davem@nuts.ninka.net	1.1324
# [TG3]: Do not reset the RX_MAC unless PHY is Serdes.
# 
# Bug discovered by Michael Chan @ Broadcom.
# --------------------------------------------
# 03/08/22	davem@nuts.ninka.net	1.1325
# [TG3]: More missing PCI IDs.
# --------------------------------------------
# 03/08/23	davem@nuts.ninka.net	1.1326
# [TG3]: Reset PHY more reliably on 570{3,4,5} chips.
# --------------------------------------------
# 03/08/23	davem@nuts.ninka.net	1.1327
# [TG3]: Fix 5788/5901, update TSO code.
# - Do not set RDMAC_MODE_FIFO_LONG_BURST on 5788
# - Do not set WDMAC_MODE_RX_ACCEL on 5788
# - Note that 5788 cannot use tagged irq status.
# - 5788 cannot do TSO
# - 5788 cannot do NETIF_F_HIGHDMA.
# - 5901 is 10/100 only.
# - Update TSO firmware, add 5705 specific TSO firmware.
# - Update TSO packet handling in ->hard_start_xmit() to
#   match updated TSO firmware.
# - TSO is still off by default until more perf analysis is done.
# --------------------------------------------
# 03/08/23	davem@nuts.ninka.net	1.1328
# [TG3]: Differentiate between TSO capable and TSO enabled.
# --------------------------------------------
# 03/08/23	davem@nuts.ninka.net	1.1329
# [ETHTOOL]: Add {G,S}TSO support to ethtool_ops.
# --------------------------------------------
# 03/08/23	davem@nuts.ninka.net	1.1330
# [TG3]: Add {get,set}_tso ethtool_ops support.
# 
# Also, include TSO support code when NETIF_F_TSO is available
# but do not enable TSO by default even on capable cards.  User
# can turn it on via ethtool.
# --------------------------------------------
#
diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	Sat Aug 23 21:49:57 2003
+++ b/drivers/net/tg3.c	Sat Aug 23 21:49:57 2003
@@ -27,6 +27,8 @@
 #include <linux/tcp.h>
 #include <linux/workqueue.h>
 
+#include <net/checksum.h>
+
 #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/byteorder.h>
@@ -45,12 +47,9 @@
 #endif
 
 #ifdef NETIF_F_TSO
-/* XXX Works but still disabled, decreases TCP performance to 7MB/sec even
- * XXX over gigabit.
- */
-#define TG3_DO_TSO	0
+#define TG3_TSO_SUPPORT	1
 #else
-#define TG3_DO_TSO	0
+#define TG3_TSO_SUPPORT	0
 #endif
 
 #include "tg3.h"
@@ -80,7 +79,8 @@
 
 /* hardware minimum and maximum for a single frame's data payload */
 #define TG3_MIN_MTU			60
-#define TG3_MAX_MTU			9000
+#define TG3_MAX_MTU(tp)	\
+	(GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705 ? 9000 : 1500)
 
 /* These numbers seem to be hard coded in the NIC firmware somehow.
  * You can't change the ring sizes, but you can change where you place
@@ -90,7 +90,17 @@
 #define TG3_DEF_RX_RING_PENDING		200
 #define TG3_RX_JUMBO_RING_SIZE		256
 #define TG3_DEF_RX_JUMBO_RING_PENDING	100
-#define TG3_RX_RCB_RING_SIZE		1024
+
+/* Do not place this n-ring entries value into the tp struct itself,
+ * we really want to expose these constants to GCC so that modulo et
+ * al.  operations are done with shifts and masks instead of with
+ * hw multiply/modulo instructions.  Another solution would be to
+ * replace things like '% foo' with '& (foo - 1)'.
+ */
+#define TG3_RX_RCB_RING_SIZE(tp)	\
+	(GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 ? \
+	 512 : 1024)
+
 #define TG3_TX_RING_SIZE		512
 #define TG3_DEF_TX_RING_PENDING		(TG3_TX_RING_SIZE - 1)
 
@@ -98,8 +108,8 @@
 				 TG3_RX_RING_SIZE)
 #define TG3_RX_JUMBO_RING_BYTES	(sizeof(struct tg3_rx_buffer_desc) * \
 			         TG3_RX_JUMBO_RING_SIZE)
-#define TG3_RX_RCB_RING_BYTES	(sizeof(struct tg3_rx_buffer_desc) * \
-			         TG3_RX_RCB_RING_SIZE)
+#define TG3_RX_RCB_RING_BYTES(tp) (sizeof(struct tg3_rx_buffer_desc) * \
+			           TG3_RX_RCB_RING_SIZE(tp))
 #define TG3_TX_RING_BYTES	(sizeof(struct tg3_tx_buffer_desc) * \
 				 TG3_TX_RING_SIZE)
 #define TX_RING_GAP(TP)	\
@@ -140,6 +150,14 @@
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5702FE,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705_2,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705M,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705M_2,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5702X,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5703X,
@@ -150,6 +168,14 @@
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5703A3,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5782,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5788,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901_2,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_SYSKONNECT, 0x4400,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000,
@@ -288,17 +314,28 @@
 
 static void tg3_switch_clocks(struct tg3 *tp)
 {
-	if (tr32(TG3PCI_CLOCK_CTRL) & CLOCK_CTRL_44MHZ_CORE) {
+	u32 clock_ctrl = tr32(TG3PCI_CLOCK_CTRL);
+	u32 orig_clock_ctrl;
+
+	orig_clock_ctrl = clock_ctrl;
+	clock_ctrl &= (CLOCK_CTRL_FORCE_CLKRUN |
+		       CLOCK_CTRL_CLKRUN_OENABLE |
+		       0x1f);
+	tp->pci_clock_ctrl = clock_ctrl;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705 &&
+	    (orig_clock_ctrl & CLOCK_CTRL_44MHZ_CORE) != 0) {
 		tw32(TG3PCI_CLOCK_CTRL,
+		     clock_ctrl |
 		     (CLOCK_CTRL_44MHZ_CORE | CLOCK_CTRL_ALTCLK));
 		tr32(TG3PCI_CLOCK_CTRL);
 		udelay(40);
 		tw32(TG3PCI_CLOCK_CTRL,
-		     (CLOCK_CTRL_ALTCLK));
+		     clock_ctrl | (CLOCK_CTRL_ALTCLK));
 		tr32(TG3PCI_CLOCK_CTRL);
 		udelay(40);
 	}
-	tw32(TG3PCI_CLOCK_CTRL, 0);
+	tw32(TG3PCI_CLOCK_CTRL, clock_ctrl);
 	tr32(TG3PCI_CLOCK_CTRL);
 	udelay(40);
 }
@@ -401,24 +438,22 @@
 	return ret;
 }
 
-/* This will reset the tigon3 PHY if there is no valid
- * link unless the FORCE argument is non-zero.
- */
-static int tg3_phy_reset(struct tg3 *tp, int force)
+static void tg3_phy_set_wirespeed(struct tg3 *tp)
 {
-	u32 phy_status, phy_control;
-	int err, limit;
+	u32 val;
 
-	err  = tg3_readphy(tp, MII_BMSR, &phy_status);
-	err |= tg3_readphy(tp, MII_BMSR, &phy_status);
-	if (err != 0)
-		return -EBUSY;
+	if (tp->tg3_flags2 & TG3_FLG2_NO_ETH_WIRE_SPEED)
+		return;
 
-	/* If we have link, and not forcing a reset, then nothing
-	 * to do.
-	 */
-	if ((phy_status & BMSR_LSTATUS) != 0 && (force == 0))
-		return 0;
+	tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x7007);
+	tg3_readphy(tp, MII_TG3_AUX_CTRL, &val);
+	tg3_writephy(tp, MII_TG3_AUX_CTRL, (val | (1 << 15) | (1 << 4)));
+}
+
+static int tg3_bmcr_reset(struct tg3 *tp)
+{
+	u32 phy_control;
+	int limit, err;
 
 	/* OK, reset it, and poll the BMCR_RESET bit until it
 	 * clears or we time out.
@@ -436,12 +471,303 @@
 
 		if ((phy_control & BMCR_RESET) == 0) {
 			udelay(40);
-			return 0;
+			break;
 		}
 		udelay(10);
 	}
+	if (limit <= 0)
+		return -EBUSY;
 
-	return -EBUSY;
+	return 0;
+}
+
+static int tg3_wait_macro_done(struct tg3 *tp)
+{
+	int limit = 100;
+
+	while (limit--) {
+		u32 tmp32;
+
+		tg3_readphy(tp, 0x16, &tmp32);
+		if ((tmp32 & 0x1000) == 0)
+			break;
+	}
+	if (limit <= 0)
+		return -EBUSY;
+
+	return 0;
+}
+
+static int tg3_phy_write_and_check_testpat(struct tg3 *tp, int *resetp)
+{
+	static const u32 test_pat[4][6] = {
+	{ 0x00005555, 0x00000005, 0x00002aaa, 0x0000000a, 0x00003456, 0x00000003 },
+	{ 0x00002aaa, 0x0000000a, 0x00003333, 0x00000003, 0x0000789a, 0x00000005 },
+	{ 0x00005a5a, 0x00000005, 0x00002a6a, 0x0000000a, 0x00001bcd, 0x00000003 },
+	{ 0x00002a5a, 0x0000000a, 0x000033c3, 0x00000003, 0x00002ef1, 0x00000005 }
+	};
+	int chan;
+
+	for (chan = 0; chan < 4; chan++) {
+		int i;
+
+		tg3_writephy(tp, MII_TG3_DSP_ADDRESS,
+			     (chan * 0x2000) | 0x0200);
+		tg3_writephy(tp, 0x16, 0x0002);
+
+		for (i = 0; i < 6; i++)
+			tg3_writephy(tp, MII_TG3_DSP_RW_PORT,
+				     test_pat[chan][i]);
+
+		tg3_writephy(tp, 0x16, 0x0202);
+		if (tg3_wait_macro_done(tp)) {
+			*resetp = 1;
+			return -EBUSY;
+		}
+
+		tg3_writephy(tp, MII_TG3_DSP_ADDRESS,
+			     (chan * 0x2000) | 0x0200);
+		tg3_writephy(tp, 0x16, 0x0082);
+		if (tg3_wait_macro_done(tp)) {
+			*resetp = 1;
+			return -EBUSY;
+		}
+
+		tg3_writephy(tp, 0x16, 0x0802);
+		if (tg3_wait_macro_done(tp)) {
+			*resetp = 1;
+			return -EBUSY;
+		}
+
+		for (i = 0; i < 6; i += 2) {
+			u32 low, high;
+
+			tg3_readphy(tp, MII_TG3_DSP_RW_PORT, &low);
+			tg3_readphy(tp, MII_TG3_DSP_RW_PORT, &high);
+			if (tg3_wait_macro_done(tp)) {
+				*resetp = 1;
+				return -EBUSY;
+			}
+			low &= 0x7fff;
+			high &= 0x000f;
+			if (low != test_pat[chan][i] ||
+			    high != test_pat[chan][i+1]) {
+				tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x000b);
+				tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x4001);
+				tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x4005);
+
+				return -EBUSY;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static int tg3_phy_reset_chanpat(struct tg3 *tp)
+{
+	int chan;
+
+	for (chan = 0; chan < 4; chan++) {
+		int i;
+
+		tg3_writephy(tp, MII_TG3_DSP_ADDRESS,
+			     (chan * 0x2000) | 0x0200);
+		tg3_writephy(tp, 0x16, 0x0002);
+		for (i = 0; i < 6; i++)
+			tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x000);
+		tg3_writephy(tp, 0x16, 0x0202);
+		if (tg3_wait_macro_done(tp))
+			return -EBUSY;
+	}
+
+	return 0;
+}
+
+static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
+{
+	u32 reg32, phy9_orig;
+	int retries, do_phy_reset, err;
+
+	retries = 10;
+	do_phy_reset = 1;
+	do {
+		if (do_phy_reset) {
+			err = tg3_bmcr_reset(tp);
+			if (err)
+				return err;
+			do_phy_reset = 0;
+		}
+
+		/* Disable transmitter and interrupt.  */
+		tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32);
+		reg32 |= 0x3000;
+		tg3_writephy(tp, MII_TG3_EXT_CTRL, reg32);
+
+		/* Set full-duplex, 1000 mbps.  */
+		tg3_writephy(tp, MII_BMCR,
+			     BMCR_FULLDPLX | TG3_BMCR_SPEED1000);
+
+		/* Set to master mode.  */
+		tg3_readphy(tp, MII_TG3_CTRL, &phy9_orig);
+		tg3_writephy(tp, MII_TG3_CTRL,
+			     (MII_TG3_CTRL_AS_MASTER |
+			      MII_TG3_CTRL_ENABLE_AS_MASTER));
+
+		/* Enable SM_DSP_CLOCK and 6dB.  */
+		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
+
+		/* Block the PHY control access.  */
+		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x8005);
+		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x0800);
+
+		err = tg3_phy_write_and_check_testpat(tp, &do_phy_reset);
+		if (!err)
+			break;
+	} while (--retries);
+
+	err = tg3_phy_reset_chanpat(tp);
+	if (err)
+		return err;
+
+	tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x8005);
+	tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x0000);
+
+	tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x8200);
+	tg3_writephy(tp, 0x16, 0x0000);
+
+	tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
+
+	tg3_writephy(tp, MII_TG3_CTRL, phy9_orig);
+
+	tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32);
+	reg32 &= ~0x3000;
+	tg3_writephy(tp, MII_TG3_EXT_CTRL, reg32);
+
+	return err;
+}
+
+/* This will reset the tigon3 PHY if there is no valid
+ * link unless the FORCE argument is non-zero.
+ */
+static int tg3_phy_reset(struct tg3 *tp, int force)
+{
+	u32 phy_status;
+	int err;
+
+	err  = tg3_readphy(tp, MII_BMSR, &phy_status);
+	err |= tg3_readphy(tp, MII_BMSR, &phy_status);
+	if (err != 0)
+		return -EBUSY;
+
+	/* If we have link, and not forcing a reset, then nothing
+	 * to do.
+	 */
+	if ((phy_status & BMSR_LSTATUS) != 0 && (force == 0))
+		return 0;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5703 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5704 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705) {
+		err = tg3_phy_reset_5703_4_5(tp);
+		if (err)
+			return err;
+		goto out;
+	}
+
+	err = tg3_bmcr_reset(tp);
+	if (err)
+		return err;
+
+out:
+	tg3_phy_set_wirespeed(tp);
+	return 0;
+}
+
+static void tg3_frob_aux_power(struct tg3 *tp)
+{
+	struct tg3 *tp_peer = tp;
+
+	if ((tp->tg3_flags & TG3_FLAG_EEPROM_WRITE_PROT) != 0)
+		return;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
+		tp_peer = pci_get_drvdata(tp->pdev_peer);
+		if (!tp_peer)
+			BUG();
+	}
+
+
+	if ((tp->tg3_flags & TG3_FLAG_WOL_ENABLE) != 0 ||
+	    (tp_peer->tg3_flags & TG3_FLAG_WOL_ENABLE) != 0) {
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701) {
+			tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl |
+			     (GRC_LCLCTRL_GPIO_OE0 |
+			      GRC_LCLCTRL_GPIO_OE1 |
+			      GRC_LCLCTRL_GPIO_OE2 |
+			      GRC_LCLCTRL_GPIO_OUTPUT0 |
+			      GRC_LCLCTRL_GPIO_OUTPUT1));
+			tr32(GRC_LOCAL_CTRL);
+			udelay(100);
+		} else {
+			if (tp_peer != tp &&
+			    (tp_peer->tg3_flags & TG3_FLAG_INIT_COMPLETE) != 0)
+				return;
+
+			tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl |
+			     (GRC_LCLCTRL_GPIO_OE0 |
+			      GRC_LCLCTRL_GPIO_OE1 |
+			      GRC_LCLCTRL_GPIO_OE2 |
+			      GRC_LCLCTRL_GPIO_OUTPUT1 |
+			      GRC_LCLCTRL_GPIO_OUTPUT2));
+			tr32(GRC_LOCAL_CTRL);
+			udelay(100);
+
+			tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl |
+			     (GRC_LCLCTRL_GPIO_OE0 |
+			      GRC_LCLCTRL_GPIO_OE1 |
+			      GRC_LCLCTRL_GPIO_OE2 |
+			      GRC_LCLCTRL_GPIO_OUTPUT0 |
+			      GRC_LCLCTRL_GPIO_OUTPUT1 |
+			      GRC_LCLCTRL_GPIO_OUTPUT2));
+			tr32(GRC_LOCAL_CTRL);
+			udelay(100);
+
+			tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl |
+			     (GRC_LCLCTRL_GPIO_OE0 |
+			      GRC_LCLCTRL_GPIO_OE1 |
+			      GRC_LCLCTRL_GPIO_OE2 |
+			      GRC_LCLCTRL_GPIO_OUTPUT0 |
+			      GRC_LCLCTRL_GPIO_OUTPUT1));
+			tr32(GRC_LOCAL_CTRL);
+			udelay(100);
+		}
+	} else {
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
+		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701) {
+			if (tp_peer != tp &&
+			    (tp_peer->tg3_flags & TG3_FLAG_INIT_COMPLETE) != 0)
+				return;
+
+			tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl |
+			     (GRC_LCLCTRL_GPIO_OE1 |
+			      GRC_LCLCTRL_GPIO_OUTPUT1));
+			tr32(GRC_LOCAL_CTRL);
+			udelay(100);
+
+			tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl |
+			     (GRC_LCLCTRL_GPIO_OE1));
+			tr32(GRC_LOCAL_CTRL);
+			udelay(100);
+
+			tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl |
+			     (GRC_LCLCTRL_GPIO_OE1 |
+			      GRC_LCLCTRL_GPIO_OUTPUT1));
+			tr32(GRC_LOCAL_CTRL);
+			udelay(100);
+		}
+	}
 }
 
 static int tg3_setup_phy(struct tg3 *);
@@ -547,89 +873,65 @@
 		udelay(10);
 	}
 
-	if (tp->tg3_flags & TG3_FLAG_WOL_SPEED_100MB) {
+	if (!(tp->tg3_flags & TG3_FLAG_WOL_SPEED_100MB) &&
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)) {
 		u32 base_val;
 
-		base_val = 0;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)
-			base_val |= (CLOCK_CTRL_RXCLK_DISABLE |
-				     CLOCK_CTRL_TXCLK_DISABLE);
-
-		tw32(TG3PCI_CLOCK_CTRL, base_val |
-		     CLOCK_CTRL_ALTCLK);
-		tr32(TG3PCI_CLOCK_CTRL);
-		udelay(40);
+		base_val = tp->pci_clock_ctrl;
+		base_val |= (CLOCK_CTRL_RXCLK_DISABLE |
+			     CLOCK_CTRL_TXCLK_DISABLE);
 
 		tw32(TG3PCI_CLOCK_CTRL, base_val |
 		     CLOCK_CTRL_ALTCLK |
-		     CLOCK_CTRL_44MHZ_CORE);
-		tr32(TG3PCI_CLOCK_CTRL);
-		udelay(40);
-
-		tw32(TG3PCI_CLOCK_CTRL, base_val |
-		     CLOCK_CTRL_44MHZ_CORE);
+		     CLOCK_CTRL_PWRDOWN_PLL133);
 		tr32(TG3PCI_CLOCK_CTRL);
 		udelay(40);
 	} else {
-		u32 base_val;
+		u32 newbits1, newbits2;
 
-		base_val = 0;
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)
-			base_val |= (CLOCK_CTRL_RXCLK_DISABLE |
-				     CLOCK_CTRL_TXCLK_DISABLE);
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701) {
+			newbits1 = (CLOCK_CTRL_RXCLK_DISABLE |
+				    CLOCK_CTRL_TXCLK_DISABLE |
+				    CLOCK_CTRL_ALTCLK);
+			newbits2 = newbits1 | CLOCK_CTRL_44MHZ_CORE;
+		} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+			newbits1 = CLOCK_CTRL_625_CORE;
+			newbits2 = newbits1 | CLOCK_CTRL_ALTCLK;
+		} else {
+			newbits1 = CLOCK_CTRL_ALTCLK;
+			newbits2 = newbits1 | CLOCK_CTRL_44MHZ_CORE;
+		}
 
-		tw32(TG3PCI_CLOCK_CTRL, base_val |
-		     CLOCK_CTRL_ALTCLK |
-		     CLOCK_CTRL_PWRDOWN_PLL133);
+		tw32(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl | newbits1);
 		tr32(TG3PCI_CLOCK_CTRL);
 		udelay(40);
-	}
 
-	if (!(tp->tg3_flags & TG3_FLAG_EEPROM_WRITE_PROT) &&
-	    (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)) {
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701) {
-			tw32(GRC_LOCAL_CTRL,
-			     (GRC_LCLCTRL_GPIO_OE0 |
-			      GRC_LCLCTRL_GPIO_OE1 |
-			      GRC_LCLCTRL_GPIO_OE2 |
-			      GRC_LCLCTRL_GPIO_OUTPUT0 |
-			      GRC_LCLCTRL_GPIO_OUTPUT1));
-			tr32(GRC_LOCAL_CTRL);
-			udelay(100);
-		} else {
-			tw32(GRC_LOCAL_CTRL,
-			     (GRC_LCLCTRL_GPIO_OE0 |
-			      GRC_LCLCTRL_GPIO_OE1 |
-			      GRC_LCLCTRL_GPIO_OE2 |
-			      GRC_LCLCTRL_GPIO_OUTPUT1 |
-			      GRC_LCLCTRL_GPIO_OUTPUT2));
-			tr32(GRC_LOCAL_CTRL);
-			udelay(100);
+		tw32(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl | newbits2);
+		tr32(TG3PCI_CLOCK_CTRL);
+		udelay(40);
 
-			tw32(GRC_LOCAL_CTRL,
-			     (GRC_LCLCTRL_GPIO_OE0 |
-			      GRC_LCLCTRL_GPIO_OE1 |
-			      GRC_LCLCTRL_GPIO_OE2 |
-			      GRC_LCLCTRL_GPIO_OUTPUT0 |
-			      GRC_LCLCTRL_GPIO_OUTPUT1 |
-			      GRC_LCLCTRL_GPIO_OUTPUT2));
-			tr32(GRC_LOCAL_CTRL);
-			udelay(100);
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705) {
+			u32 newbits3;
 
-			tw32(GRC_LOCAL_CTRL,
-			     (GRC_LCLCTRL_GPIO_OE0 |
-			      GRC_LCLCTRL_GPIO_OE1 |
-			      GRC_LCLCTRL_GPIO_OE2 |
-			      GRC_LCLCTRL_GPIO_OUTPUT0 |
-			      GRC_LCLCTRL_GPIO_OUTPUT1));
-			tr32(GRC_LOCAL_CTRL);
-			udelay(100);
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701) {
+				newbits3 = (CLOCK_CTRL_RXCLK_DISABLE |
+					    CLOCK_CTRL_TXCLK_DISABLE |
+					    CLOCK_CTRL_44MHZ_CORE);
+			} else {
+				newbits3 = CLOCK_CTRL_44MHZ_CORE;
+			}
+
+			tw32(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl | newbits3);
+			tr32(TG3PCI_CLOCK_CTRL);
+			udelay(40);
 		}
 	}
 
+	tg3_frob_aux_power(tp);
+
 	/* Finally, set the new power state. */
 	pci_write_config_word(tp->pdev, pm + PCI_PM_CTRL, power_control);
 
@@ -948,11 +1250,10 @@
 
 	/* Some third-party PHYs need to be reset on link going
 	 * down.
-	 *
-	 * XXX 5705 note: This workaround also applies to 5705_a0
 	 */
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) &&
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 ||
+	     tp->pci_chip_rev_id == CHIPREV_ID_5705_A0) &&
 	    netif_carrier_ok(tp->dev)) {
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		tg3_readphy(tp, MII_BMSR, &bmsr);
@@ -1942,7 +2243,7 @@
 	int received;
 
 	hw_idx = tp->hw_status->idx[0].rx_producer;
-	sw_idx = rx_rcb_ptr % TG3_RX_RCB_RING_SIZE;
+	sw_idx = rx_rcb_ptr % TG3_RX_RCB_RING_SIZE(tp);
 	work_mask = 0;
 	received = 0;
 	while (sw_idx != hw_idx && budget > 0) {
@@ -2043,13 +2344,13 @@
 		(*post_ptr)++;
 next_pkt_nopost:
 		rx_rcb_ptr++;
-		sw_idx = rx_rcb_ptr % TG3_RX_RCB_RING_SIZE;
+		sw_idx = rx_rcb_ptr % TG3_RX_RCB_RING_SIZE(tp);
 	}
 
 	/* ACK the status ring. */
 	tp->rx_rcb_ptr = rx_rcb_ptr;
 	tw32_mailbox(MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW,
-		     (rx_rcb_ptr % TG3_RX_RCB_RING_SIZE));
+		     (rx_rcb_ptr % TG3_RX_RCB_RING_SIZE(tp)));
 	if (tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER)
 		tr32(MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW);
 
@@ -2388,19 +2689,34 @@
 	base_flags = 0;
 	if (skb->ip_summed == CHECKSUM_HW)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
-#if TG3_DO_TSO != 0
-	if ((mss = skb_shinfo(skb)->tso_size) != 0) {
-		static int times = 0;
+#if TG3_TSO_SUPPORT != 0
+	mss = 0;
+	if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
+	    (mss = skb_shinfo(skb)->tso_size) != 0) {
+		int tcp_opt_len, ip_tcp_len;
+
+		tcp_opt_len = ((skb->h.th->doff - 5) * 4);
+		ip_tcp_len = (skb->nh.iph->ihl * 4) + sizeof(struct tcphdr);
 
-		mss += ((skb->h.th->doff * 4) - 20);
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
-		if (times++ < 5) {
-			printk("tg3_xmit: tso_size[%u] tso_segs[%u] len[%u]\n",
-			       (unsigned int) skb_shinfo(skb)->tso_size,
-			       (unsigned int) skb_shinfo(skb)->tso_segs,
-			       skb->len);
+		skb->nh.iph->check = 0;
+		skb->nh.iph->tot_len = ntohs(mss + ip_tcp_len + tcp_opt_len);
+		skb->h.th->check = ~csum_tcpudp_magic(skb->nh.iph->saddr,
+						      skb->nh.iph->daddr,
+						      0, IPPROTO_TCP, 0);
+
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+			if (tcp_opt_len || skb->nh.iph->ihl > 5) {
+				int tsflags;
+
+				tsflags = ((skb->nh.iph->ihl - 5) +
+					   (tcp_opt_len >> 2));
+				mss |= (tsflags << 11);
+			}
+		} else {
+			mss += tcp_opt_len;
 		}
 	}
 #else
@@ -2580,23 +2896,34 @@
 	base_flags = 0;
 	if (skb->ip_summed == CHECKSUM_HW)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
-#if TG3_DO_TSO != 0
-	if ((mss = skb_shinfo(skb)->tso_size) != 0) {
-		static int times = 0;
+#if TG3_TSO_SUPPORT != 0
+	mss = 0;
+	if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
+	    (mss = skb_shinfo(skb)->tso_size) != 0) {
+		int tcp_opt_len, ip_tcp_len;
 
-		/* TSO firmware wants TCP options included in
-		 * tx descriptor MSS value.
-		 */
-		mss += ((skb->h.th->doff * 4) - 20);
+		tcp_opt_len = ((skb->h.th->doff - 5) * 4);
+		ip_tcp_len = (skb->nh.iph->ihl * 4) + sizeof(struct tcphdr);
 
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
-		if (times++ < 5) {
-			printk("tg3_xmit: tso_size[%u] tso_segs[%u] len[%u]\n",
-			       (unsigned int) skb_shinfo(skb)->tso_size,
-			       (unsigned int) skb_shinfo(skb)->tso_segs,
-			       skb->len);
+		skb->nh.iph->check = 0;
+		skb->nh.iph->tot_len = ntohs(mss + ip_tcp_len + tcp_opt_len);
+		skb->h.th->check = ~csum_tcpudp_magic(skb->nh.iph->saddr,
+						      skb->nh.iph->daddr,
+						      0, IPPROTO_TCP, 0);
+
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+			if (tcp_opt_len || skb->nh.iph->ihl > 5) {
+				int tsflags;
+
+				tsflags = ((skb->nh.iph->ihl - 5) +
+					   (tcp_opt_len >> 2));
+				mss |= (tsflags << 11);
+			}
+		} else {
+			mss += tcp_opt_len;
 		}
 	}
 #else
@@ -2698,7 +3025,7 @@
 {
 	struct tg3 *tp = dev->priv;
 
-	if (new_mtu < TG3_MIN_MTU || new_mtu > TG3_MAX_MTU)
+	if (new_mtu < TG3_MIN_MTU || new_mtu > TG3_MAX_MTU(tp))
 		return -EINVAL;
 
 	if (!netif_running(dev)) {
@@ -2816,7 +3143,7 @@
 	/* Zero out all descriptors. */
 	memset(tp->rx_std, 0, TG3_RX_RING_BYTES);
 	memset(tp->rx_jumbo, 0, TG3_RX_JUMBO_RING_BYTES);
-	memset(tp->rx_rcb, 0, TG3_RX_RCB_RING_BYTES);
+	memset(tp->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 
 	if (tp->tg3_flags & TG3_FLAG_HOST_TXDS) {
 		memset(tp->tx_ring, 0, TG3_TX_RING_BYTES);
@@ -2899,7 +3226,7 @@
 		tp->rx_jumbo = NULL;
 	}
 	if (tp->rx_rcb) {
-		pci_free_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES,
+		pci_free_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
 				    tp->rx_rcb, tp->rx_rcb_mapping);
 		tp->rx_rcb = NULL;
 	}
@@ -2957,7 +3284,7 @@
 	if (!tp->rx_jumbo)
 		goto err_out;
 
-	tp->rx_rcb = pci_alloc_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES,
+	tp->rx_rcb = pci_alloc_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
 					  &tp->rx_rcb_mapping);
 	if (!tp->rx_rcb)
 		goto err_out;
@@ -3004,6 +3331,23 @@
 	unsigned int i;
 	u32 val;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+		switch (ofs) {
+		case RCVLSC_MODE:
+		case DMAC_MODE:
+		case MBFREE_MODE:
+		case BUFMGR_MODE:
+		case MEMARB_MODE:
+			/* We can't enable/disable these bits of the
+			 * 5705, just say success.
+			 */
+			return 0;
+
+		default:
+			break;
+		};
+	}
+
 	val = tr32(ofs);
 	val &= ~enable_bit;
 	tw32(ofs, val);
@@ -3127,7 +3471,10 @@
 	tp->tg3_flags &= ~TG3_FLAG_5701_REG_WRITE_BUG;
 
 	/* do the reset */
-	tw32(GRC_MISC_CFG, GRC_MISC_CFG_CORECLK_RESET);
+	val = GRC_MISC_CFG_CORECLK_RESET;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
+		val |= GRC_MISC_CFG_KEEP_GPHY_POWER;
+	tw32(GRC_MISC_CFG, val);
 
 	/* restore 5701 hardware bug workaround flag */
 	tp->tg3_flags = flags_save;
@@ -3163,6 +3510,13 @@
 
 	tw32(MEMARB_MODE, MEMARB_MODE_ENABLE);
 
+	if ((tp->nic_sram_data_cfg & NIC_SRAM_DATA_CFG_MINI_PCI) != 0 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+		tp->pci_clock_ctrl |=
+			(CLOCK_CTRL_FORCE_CLKRUN | CLOCK_CTRL_CLKRUN_OENABLE);
+		tw32(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl);
+	}
+
 	tw32(TG3PCI_MISC_HOST_CTRL, tp->misc_host_ctrl);
 }
 
@@ -3358,28 +3712,32 @@
 #define TX_CPU_SCRATCH_SIZE	0x04000
 
 /* tp->lock is held. */
-static int tg3_reset_cpu(struct tg3 *tp, u32 offset)
+static int tg3_halt_cpu(struct tg3 *tp, u32 offset)
 {
 	int i;
 
-	tw32(offset + CPU_STATE, 0xffffffff);
-	tw32(offset + CPU_MODE,  CPU_MODE_RESET);
+	if (offset == TX_CPU_BASE &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
+		BUG();
+
 	if (offset == RX_CPU_BASE) {
-		for (i = 0; i < 10000; i++)
-			if (!(tr32(offset + CPU_MODE) & CPU_MODE_RESET))
+		for (i = 0; i < 10000; i++) {
+			tw32(offset + CPU_STATE, 0xffffffff);
+			tw32(offset + CPU_MODE,  CPU_MODE_HALT);
+			if (tr32(offset + CPU_MODE) & CPU_MODE_HALT)
 				break;
+		}
+
 		tw32(offset + CPU_STATE, 0xffffffff);
-		tw32(offset + CPU_MODE,  CPU_MODE_RESET);
+		tw32(offset + CPU_MODE,  CPU_MODE_HALT);
 		tr32(offset + CPU_MODE);
 		udelay(10);
 	} else {
 		for (i = 0; i < 10000; i++) {
-			if (!(tr32(offset + CPU_MODE) & CPU_MODE_RESET))
-				break;
 			tw32(offset + CPU_STATE, 0xffffffff);
-			tw32(offset + CPU_MODE,  CPU_MODE_RESET);
-			tr32(offset + CPU_MODE);
-			udelay(10);
+			tw32(offset + CPU_MODE,  CPU_MODE_HALT);
+			if (tr32(offset + CPU_MODE) & CPU_MODE_HALT)
+				break;
 		}
 	}
 
@@ -3411,38 +3769,52 @@
 {
 	int err, i;
 	u32 orig_tg3_flags = tp->tg3_flags;
+	void (*write_op)(struct tg3 *, u32, u32);
+
+	if (cpu_base == TX_CPU_BASE &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+		printk(KERN_ERR PFX "tg3_load_firmware_cpu: Trying to load "
+		       "TX cpu firmware on %s which is 5705.\n",
+		       tp->dev->name);
+		return -EINVAL;
+	}
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
+		write_op = tg3_write_mem;
+	else
+		write_op = tg3_write_indirect_reg32;
 
 	/* Force use of PCI config space for indirect register
 	 * write calls.
 	 */
 	tp->tg3_flags |= TG3_FLAG_PCIX_TARGET_HWBUG;
 
-	err = tg3_reset_cpu(tp, cpu_base);
+	err = tg3_halt_cpu(tp, cpu_base);
 	if (err)
 		goto out;
 
 	for (i = 0; i < cpu_scratch_size; i += sizeof(u32))
-		tg3_write_indirect_reg32(tp, cpu_scratch_base + i, 0);
+		write_op(tp, cpu_scratch_base + i, 0);
 	tw32(cpu_base + CPU_STATE, 0xffffffff);
 	tw32(cpu_base + CPU_MODE, tr32(cpu_base+CPU_MODE)|CPU_MODE_HALT);
 	for (i = 0; i < (info->text_len / sizeof(u32)); i++)
-		tg3_write_indirect_reg32(tp, (cpu_scratch_base +
-					      (info->text_base & 0xffff) +
-					      (i * sizeof(u32))),
-					 (info->text_data ?
-					  info->text_data[i] : 0));
+		write_op(tp, (cpu_scratch_base +
+			      (info->text_base & 0xffff) +
+			      (i * sizeof(u32))),
+			 (info->text_data ?
+			  info->text_data[i] : 0));
 	for (i = 0; i < (info->rodata_len / sizeof(u32)); i++)
-		tg3_write_indirect_reg32(tp, (cpu_scratch_base +
-					      (info->rodata_base & 0xffff) +
-					      (i * sizeof(u32))),
-					 (info->rodata_data ?
-					  info->rodata_data[i] : 0));
+		write_op(tp, (cpu_scratch_base +
+			      (info->rodata_base & 0xffff) +
+			      (i * sizeof(u32))),
+			 (info->rodata_data ?
+			  info->rodata_data[i] : 0));
 	for (i = 0; i < (info->data_len / sizeof(u32)); i++)
-		tg3_write_indirect_reg32(tp, (cpu_scratch_base +
-					      (info->data_base & 0xffff) +
-					      (i * sizeof(u32))),
-					 (info->data_data ?
-					  info->data_data[i] : 0));
+		write_op(tp, (cpu_scratch_base +
+			      (info->data_base & 0xffff) +
+			      (i * sizeof(u32))),
+			 (info->data_data ?
+			  info->data_data[i] : 0));
 
 	err = 0;
 
@@ -3513,269 +3885,318 @@
 	return 0;
 }
 
-#if TG3_DO_TSO != 0
+#if TG3_TSO_SUPPORT != 0
 
 #define TG3_TSO_FW_RELEASE_MAJOR	0x1
-#define TG3_TSO_FW_RELASE_MINOR		0x8
+#define TG3_TSO_FW_RELASE_MINOR		0x3
 #define TG3_TSO_FW_RELEASE_FIX		0x0
 #define TG3_TSO_FW_START_ADDR		0x08000000
 #define TG3_TSO_FW_TEXT_ADDR		0x08000000
-#define TG3_TSO_FW_TEXT_LEN		0x1650
+#define TG3_TSO_FW_TEXT_LEN		0x1ac0
 #define TG3_TSO_FW_RODATA_ADDR		0x08001650
-#define TG3_TSO_FW_RODATA_LEN		0x30
+#define TG3_TSO_FW_RODATA_LEN		0x60
 #define TG3_TSO_FW_DATA_ADDR		0x080016a0
 #define TG3_TSO_FW_DATA_LEN		0x20
 #define TG3_TSO_FW_SBSS_ADDR		0x080016c0
-#define TG3_TSO_FW_SBSS_LEN		0x14
+#define TG3_TSO_FW_SBSS_LEN		0x2c
 #define TG3_TSO_FW_BSS_ADDR		0x080016e0
-#define TG3_TSO_FW_BSS_LEN		0x8fc
+#define TG3_TSO_FW_BSS_LEN		0x890
 
 static u32 tg3TsoFwText[] = {
 	0x00000000, 0x10000003, 0x00000000, 0x0000000d, 0x0000000d, 0x3c1d0800,
 	0x37bd4000, 0x03a0f021, 0x3c100800, 0x26100000, 0x0e000010, 0x00000000,
-	0x0000000d, 0x00000000, 0x00000000, 0x00000000, 0x27bdffe0, 0x3c1bc000,
-	0xafbf0018, 0x0e000058, 0xaf60680c, 0x3c040800, 0x24841650, 0x03602821,
-	0x24060001, 0x24070004, 0xafa00010, 0x0e00006c, 0xafa00014, 0x8f625c50,
-	0x34420001, 0xaf625c50, 0x8f625c90, 0x34420001, 0xaf625c90, 0x2402ffff,
-	0x0e000098, 0xaf625404, 0x8fbf0018, 0x03e00008, 0x27bd0020, 0x00000000,
-	0x00000000, 0x00000000, 0x24030b60, 0x24050fff, 0xac000b50, 0x00002021,
-	0xac640000, 0x24630004, 0x0065102b, 0x1440fffc, 0x24840001, 0x24030b60,
-	0x0065102b, 0x10400011, 0x00002021, 0x24090b54, 0x3c06dead, 0x34c6beef,
-	0x24080b58, 0x24070b5c, 0x8c620000, 0x50440006, 0x24630004, 0xad260000,
-	0x8c620000, 0xace40000, 0xad020000, 0x24630004, 0x0065102b, 0x1440fff6,
-	0x24840001, 0x03e00008, 0x00000000, 0x27bdfff8, 0x18800009, 0x00002821,
-	0x8f63680c, 0x8f62680c, 0x1043fffe, 0x00000000, 0x24a50001, 0x00a4102a,
-	0x1440fff9, 0x00000000, 0x03e00008, 0x27bd0008, 0x3c020800, 0x34423000,
-	0x3c030800, 0x34633000, 0x3c040800, 0x348437ff, 0x3c010800, 0xac2216c4,
-	0x24020040, 0x3c010800, 0xac2216c8, 0x3c010800, 0xac2016c0, 0xac600000,
-	0x24630004, 0x0083102b, 0x5040fffd, 0xac600000, 0x03e00008, 0x00000000,
-	0x00804821, 0x8faa0010, 0x3c020800, 0x8c4216c0, 0x3c040800, 0x8c8416c8,
-	0x8fab0014, 0x24430001, 0x0044102b, 0x3c010800, 0xac2316c0, 0x14400003,
-	0x00004021, 0x3c010800, 0xac2016c0, 0x3c020800, 0x8c4216c0, 0x3c030800,
-	0x8c6316c4, 0x91240000, 0x00021140, 0x00431021, 0x00481021, 0x25080001,
-	0xa0440000, 0x29020008, 0x1440fff4, 0x25290001, 0x3c020800, 0x8c4216c0,
-	0x3c030800, 0x8c6316c4, 0x8f64680c, 0x00021140, 0x00431021, 0xac440008,
-	0xac45000c, 0xac460010, 0xac470014, 0xac4a0018, 0x03e00008, 0xac4b001c,
-	0x00000000, 0x00000000, 0x27bdffe0, 0xafbf0018, 0xafb10014, 0x0e0000b6,
-	0xafb00010, 0x24110001, 0x8f706820, 0x32020100, 0x10400003, 0x00000000,
-	0x0e000127, 0x00000000, 0x8f706820, 0x32022000, 0x10400004, 0x32020001,
-	0x0e00025a, 0x24040001, 0x32020001, 0x10400003, 0x00000000, 0x0e0000e6,
-	0x00000000, 0x0a00009e, 0xaf715028, 0x8fbf0018, 0x8fb10014, 0x8fb00010,
-	0x03e00008, 0x27bd0020, 0x27bdffe0, 0x3c040800, 0x24841660, 0x00002821,
-	0x00003021, 0x00003821, 0xafbf0018, 0xafa00010, 0x0e00006c, 0xafa00014,
-	0x3c010800, 0xa4201fb8, 0x3c010800, 0xa02016f8, 0x3c010800, 0xac2016fc,
-	0x3c010800, 0xac201700, 0x3c010800, 0xac201704, 0x3c010800, 0xac20170c,
-	0x3c010800, 0xac201718, 0x3c010800, 0xac20171c, 0x8f624434, 0x3c010800,
-	0xac2216e8, 0x8f624438, 0x3c010800, 0xac2216ec, 0x8f624410, 0x3c010800,
-	0xac2016e0, 0x3c010800, 0xac2016e4, 0x3c010800, 0xac201fc0, 0x3c010800,
-	0xac201f68, 0x3c010800, 0xac201f6c, 0x3c010800, 0xac2216f0, 0x8fbf0018,
-	0x03e00008, 0x27bd0020, 0x27bdffe0, 0x3c040800, 0x2484166c, 0x00002821,
-	0x00003021, 0x00003821, 0xafbf0018, 0xafa00010, 0x0e00006c, 0xafa00014,
-	0x3c040800, 0x24841660, 0x00002821, 0x00003021, 0x00003821, 0xafa00010,
-	0x0e00006c, 0xafa00014, 0x3c010800, 0xa4201fb8, 0x3c010800, 0xa02016f8,
-	0x3c010800, 0xac2016fc, 0x3c010800, 0xac201700, 0x3c010800, 0xac201704,
-	0x3c010800, 0xac20170c, 0x3c010800, 0xac201718, 0x3c010800, 0xac20171c,
-	0x8f624434, 0x3c010800, 0xac2216e8, 0x8f624438, 0x3c010800, 0xac2216ec,
-	0x8f624410, 0x3c010800, 0xac2016e0, 0x3c010800, 0xac2016e4, 0x3c010800,
-	0xac201fc0, 0x3c010800, 0xac201f68, 0x3c010800, 0xac201f6c, 0x3c010800,
-	0xac2216f0, 0x0e000120, 0x00002021, 0x8fbf0018, 0x03e00008, 0x27bd0020,
-	0x24020001, 0x8f636820, 0x00821004, 0x00021027, 0x00621824, 0x03e00008,
-	0xaf636820, 0x27bdffd0, 0x3c0300ff, 0xafbf002c, 0xafb60028, 0xafb50024,
-	0xafb40020, 0xafb3001c, 0xafb20018, 0xafb10014, 0xafb00010, 0x8f665c5c,
-	0x3c040800, 0x2484171c, 0x8c820000, 0x3463fff8, 0x14460005, 0x00c38824,
-	0x3c020800, 0x904216f8, 0x14400115, 0x00000000, 0x00111902, 0x306300ff,
-	0x30c20003, 0x000211c0, 0x00623825, 0x00e02821, 0x00061602, 0xac860000,
-	0x3c030800, 0x906316f8, 0x3044000f, 0x1460002b, 0x00804021, 0x24020001,
-	0x3c010800, 0xa02216f8, 0x00071100, 0x00821025, 0x3c010800, 0xac2016fc,
-	0x3c010800, 0xac201700, 0x3c010800, 0xac201704, 0x3c010800, 0xac20170c,
-	0x3c010800, 0xac201718, 0x3c010800, 0xac201710, 0x3c010800, 0xac201714,
-	0x3c010800, 0xa4221fb8, 0x9623000c, 0x30628000, 0x10400008, 0x30627fff,
-	0x2442003e, 0x3c010800, 0xa42216f6, 0x24020001, 0x3c010800, 0x0a00016e,
-	0xac221fd4, 0x24620036, 0x3c010800, 0xa42216f6, 0x3c010800, 0xac201fd4,
-	0x3c010800, 0xac201fd0, 0x3c010800, 0x0a000176, 0xac201fd8, 0x9622000c,
-	0x3c010800, 0xa4221fcc, 0x3c040800, 0x248416fc, 0x8c820000, 0x00021100,
-	0x3c010800, 0x00220821, 0xac311728, 0x8c820000, 0x00021100, 0x3c010800,
-	0x00220821, 0xac26172c, 0x8c820000, 0x24a30001, 0x306701ff, 0x00021100,
-	0x3c010800, 0x00220821, 0xac271730, 0x8c820000, 0x00021100, 0x3c010800,
-	0x00220821, 0xac281734, 0x96230008, 0x3c020800, 0x8c42170c, 0x00432821,
-	0x3c010800, 0xac25170c, 0x9622000a, 0x30420004, 0x14400019, 0x00071100,
-	0x3c02c000, 0x00c21825, 0xaf635c5c, 0x8f625c50, 0x30420002, 0x1440fffc,
-	0x00000000, 0x8f630c14, 0x3063000f, 0x2c620002, 0x1440001e, 0x00000000,
-	0x8f630c14, 0x3c020800, 0x8c4216b4, 0x3063000f, 0x24420001, 0x3c010800,
-	0xac2216b4, 0x2c620002, 0x1040fff7, 0x00000000, 0x0a0001c1, 0x00000000,
-	0x3c030800, 0x8c6316e0, 0x3c040800, 0x948416f4, 0x01021025, 0x3c010800,
-	0xa4221fba, 0x24020001, 0x3c010800, 0xac221718, 0x24630001, 0x0085202a,
-	0x3c010800, 0x10800003, 0xac2316e0, 0x3c010800, 0xa42516f4, 0x3c030800,
-	0x246316fc, 0x8c620000, 0x24420001, 0xac620000, 0x28420080, 0x14400005,
-	0x24020001, 0x0e0002df, 0x24040002, 0x0a000250, 0x00000000, 0x3c030800,
-	0x906316f8, 0x1462007c, 0x24020003, 0x3c160800, 0x96d616f6, 0x3c050800,
-	0x8ca5170c, 0x32c4ffff, 0x00a4102a, 0x14400078, 0x00000000, 0x3c020800,
-	0x8c421718, 0x10400005, 0x32c2ffff, 0x14a40003, 0x00000000, 0x3c010800,
-	0xac231fd0, 0x10400062, 0x00009021, 0x0040a021, 0x3c150800, 0x26b51700,
-	0x26b30010, 0x8ea20000, 0x00028100, 0x3c110800, 0x02308821, 0x0e0002e1,
-	0x8e311728, 0x00403021, 0x10c00059, 0x00000000, 0x9628000a, 0x31020040,
-	0x10400004, 0x2407180c, 0x8e22000c, 0x2407188c, 0xacc20018, 0x31021000,
-	0x10400004, 0x34e32000, 0x00081040, 0x3042c000, 0x00623825, 0x3c030800,
-	0x00701821, 0x8c631730, 0x3c020800, 0x00501021, 0x8c421734, 0x00031d00,
-	0x00021400, 0x00621825, 0xacc30014, 0x8ea30004, 0x96220008, 0x00432023,
-	0x3242ffff, 0x3083ffff, 0x00431021, 0x0282102a, 0x14400002, 0x02d22823,
-	0x00802821, 0x8e620000, 0x30a4ffff, 0x00441021, 0xae620000, 0x8e220000,
-	0xacc20000, 0x8e220004, 0x8e63fff4, 0x00431021, 0xacc20004, 0xa4c5000e,
-	0x8e62fff4, 0x00441021, 0xae62fff4, 0x96230008, 0x0043102a, 0x14400005,
-	0x02459021, 0x8e62fff0, 0xae60fff4, 0x24420001, 0xae62fff0, 0xacc00008,
-	0x3242ffff, 0x14540008, 0x24020305, 0x31020080, 0x54400001, 0x34e70010,
-	0x24020905, 0xa4c2000c, 0x0a000233, 0x34e70020, 0xa4c2000c, 0x30e2ffff,
-	0xacc20010, 0x3c020800, 0x8c421fd0, 0x10400003, 0x3c024b65, 0x0a00023d,
-	0x34427654, 0x3c02b49a, 0x344289ab, 0xacc2001c, 0x0e000560, 0x00c02021,
-	0x3242ffff, 0x0054102b, 0x1440ffa4, 0x00000000, 0x24020002, 0x3c010800,
-	0x0a000250, 0xa02216f8, 0x8ea208bc, 0x24420001, 0x0a000250, 0xaea208bc,
-	0x14620003, 0x00000000, 0x0e000450, 0x00000000, 0x8fbf002c, 0x8fb60028,
-	0x8fb50024, 0x8fb40020, 0x8fb3001c, 0x8fb20018, 0x8fb10014, 0x8fb00010,
-	0x03e00008, 0x27bd0030, 0x27bdffd8, 0xafb3001c, 0x00809821, 0xafbf0020,
-	0xafb20018, 0xafb10014, 0xafb00010, 0x8f725c9c, 0x3c0200ff, 0x3442fff8,
-	0x3c040800, 0x24841714, 0x02428824, 0x9623000e, 0x8c820000, 0x00431021,
-	0xac820000, 0x8e220010, 0x30420020, 0x14400011, 0x00000000, 0x0e0002f7,
+	0x0000000d, 0x00000000, 0x00000000, 0x00000000, 0x27bdffe0, 0x3c04fefe,
+	0xafbf0018, 0x0e0005e0, 0x34840002, 0x0e000670, 0x00000000, 0x3c030800,
+	0x90631b78, 0x24020002, 0x3c040800, 0x24841acc, 0x14620003, 0x24050001,
+	0x3c040800, 0x24841ac0, 0x24060002, 0x00003821, 0xafa00010, 0x0e000684,
+	0xafa00014, 0x8f625c50, 0x34420001, 0xaf625c50, 0x8f625c90, 0x34420001,
+	0xaf625c90, 0x2402ffff, 0x0e000034, 0xaf625404, 0x8fbf0018, 0x03e00008,
+	0x27bd0020, 0x00000000, 0x00000000, 0x00000000, 0x27bdffe0, 0xafbf0018,
+	0xafb10014, 0x0e000052, 0xafb00010, 0x24110001, 0x8f706820, 0x32020100,
+	0x10400003, 0x00000000, 0x0e0000b2, 0x00000000, 0x8f706820, 0x32022000,
+	0x10400004, 0x32020001, 0x0e0001e3, 0x24040001, 0x32020001, 0x10400003,
+	0x00000000, 0x0e00009a, 0x00000000, 0x0a00003a, 0xaf715028, 0x8fbf0018,
+	0x8fb10014, 0x8fb00010, 0x03e00008, 0x27bd0020, 0x27bdffe0, 0x3c040800,
+	0x24841ae0, 0x00002821, 0x00003021, 0x00003821, 0xafbf0018, 0xafa00010,
+	0x0e000684, 0xafa00014, 0x3c040800, 0x248423e8, 0xa4800000, 0x3c010800,
+	0xa0201ba8, 0x3c010800, 0xac201bac, 0x3c010800, 0xac201bb0, 0x3c010800,
+	0xac201bb4, 0x3c010800, 0xac201bbc, 0x3c010800, 0xac201bc8, 0x3c010800,
+	0xac201bcc, 0x8f624434, 0x3c010800, 0xac221b98, 0x8f624438, 0x3c010800,
+	0xac221b9c, 0x8f624410, 0xac80f7a8, 0x3c010800, 0xac201b94, 0x3c010800,
+	0xac2023f0, 0x3c010800, 0xac2023d8, 0x3c010800, 0xac2023dc, 0x3c010800,
+	0xac202410, 0x3c010800, 0xac221ba0, 0x8f620068, 0x24030007, 0x00021702,
+	0x10430005, 0x00000000, 0x8f620068, 0x00021702, 0x14400004, 0x24020001,
+	0x3c010800, 0x0a00008e, 0xac20241c, 0xac820034, 0x3c040800, 0x24841aec,
+	0x3c050800, 0x8ca5241c, 0x00003021, 0x00003821, 0xafa00010, 0x0e000684,
+	0xafa00014, 0x8fbf0018, 0x03e00008, 0x27bd0020, 0x27bdffe0, 0x3c040800,
+	0x24841af8, 0x00002821, 0x00003021, 0x00003821, 0xafbf0018, 0xafa00010,
+	0x0e000684, 0xafa00014, 0x0e000052, 0x00000000, 0x0e0000ab, 0x00002021,
+	0x8fbf0018, 0x03e00008, 0x27bd0020, 0x24020001, 0x8f636820, 0x00821004,
+	0x00021027, 0x00621824, 0x03e00008, 0xaf636820, 0x27bdffd0, 0xafbf002c,
+	0xafb60028, 0xafb50024, 0xafb40020, 0xafb3001c, 0xafb20018, 0xafb10014,
+	0xafb00010, 0x8f665c5c, 0x3c030800, 0x24631bcc, 0x8c620000, 0x14460005,
+	0x3c0200ff, 0x3c020800, 0x90421ba8, 0x14400115, 0x3c0200ff, 0x3442fff8,
+	0x00c28824, 0xac660000, 0x00111902, 0x306300ff, 0x30c20003, 0x000211c0,
+	0x00623825, 0x00e02821, 0x00061602, 0x3c030800, 0x90631ba8, 0x3044000f,
+	0x1460002b, 0x00804021, 0x24020001, 0x3c010800, 0xa0221ba8, 0x00071100,
+	0x00821025, 0x3c010800, 0xac201bac, 0x3c010800, 0xac201bb0, 0x3c010800,
+	0xac201bb4, 0x3c010800, 0xac201bbc, 0x3c010800, 0xac201bc8, 0x3c010800,
+	0xac201bc0, 0x3c010800, 0xac201bc4, 0x3c010800, 0xa42223e8, 0x9623000c,
+	0x30628000, 0x10400008, 0x30627fff, 0x2442003e, 0x3c010800, 0xa4221ba6,
+	0x24020001, 0x3c010800, 0x0a0000f9, 0xac222404, 0x24620036, 0x3c010800,
+	0xa4221ba6, 0x3c010800, 0xac202404, 0x3c010800, 0xac202400, 0x3c010800,
+	0x0a000101, 0xac202408, 0x9622000c, 0x3c010800, 0xa42223fc, 0x3c040800,
+	0x24841bac, 0x8c820000, 0x00021100, 0x3c010800, 0x00220821, 0xac311bd8,
+	0x8c820000, 0x00021100, 0x3c010800, 0x00220821, 0xac261bdc, 0x8c820000,
+	0x24a30001, 0x306701ff, 0x00021100, 0x3c010800, 0x00220821, 0xac271be0,
+	0x8c820000, 0x00021100, 0x3c010800, 0x00220821, 0xac281be4, 0x96230008,
+	0x3c020800, 0x8c421bbc, 0x00432821, 0x3c010800, 0xac251bbc, 0x9622000a,
+	0x30420004, 0x14400018, 0x00071100, 0x8f630c14, 0x3063000f, 0x2c620002,
+	0x1440000b, 0x3c02c000, 0x8f630c14, 0x3c020800, 0x8c421b50, 0x3063000f,
+	0x24420001, 0x3c010800, 0xac221b50, 0x2c620002, 0x1040fff7, 0x3c02c000,
+	0x00c21825, 0xaf635c5c, 0x8f625c50, 0x30420002, 0x10400014, 0x00000000,
+	0x0a000133, 0x00000000, 0x3c030800, 0x8c631b90, 0x3c040800, 0x94841ba4,
+	0x01021025, 0x3c010800, 0xa42223ea, 0x24020001, 0x3c010800, 0xac221bc8,
+	0x24630001, 0x0085202a, 0x3c010800, 0x10800003, 0xac231b90, 0x3c010800,
+	0xa4251ba4, 0x3c060800, 0x24c61bac, 0x8cc20000, 0x24420001, 0xacc20000,
+	0x28420080, 0x14400005, 0x00000000, 0x0e00065e, 0x24040002, 0x0a0001d9,
+	0x00000000, 0x3c020800, 0x8c421bc8, 0x1040007f, 0x24020001, 0x3c040800,
+	0x90841ba8, 0x14820077, 0x24020003, 0x3c150800, 0x96b51ba6, 0x3c050800,
+	0x8ca51bbc, 0x32a3ffff, 0x00a3102a, 0x14400073, 0x00000000, 0x14a30003,
+	0x00000000, 0x3c010800, 0xac242400, 0x10600061, 0x00009021, 0x24d60004,
+	0x0060a021, 0x24d30014, 0x8ec20000, 0x00028100, 0x3c110800, 0x02308821,
+	0x0e00062d, 0x8e311bd8, 0x00403021, 0x10c00059, 0x00000000, 0x9628000a,
+	0x31020040, 0x10400004, 0x2407180c, 0x8e22000c, 0x2407188c, 0xacc20018,
+	0x31021000, 0x10400004, 0x34e32000, 0x00081040, 0x3042c000, 0x00623825,
+	0x3c030800, 0x00701821, 0x8c631be0, 0x3c020800, 0x00501021, 0x8c421be4,
+	0x00031d00, 0x00021400, 0x00621825, 0xacc30014, 0x8ec30004, 0x96220008,
+	0x00432023, 0x3242ffff, 0x3083ffff, 0x00431021, 0x0282102a, 0x14400002,
+	0x02b22823, 0x00802821, 0x8e620000, 0x30a4ffff, 0x00441021, 0xae620000,
+	0x8e220000, 0xacc20000, 0x8e220004, 0x8e63fff4, 0x00431021, 0xacc20004,
+	0xa4c5000e, 0x8e62fff4, 0x00441021, 0xae62fff4, 0x96230008, 0x0043102a,
+	0x14400005, 0x02459021, 0x8e62fff0, 0xae60fff4, 0x24420001, 0xae62fff0,
+	0xacc00008, 0x3242ffff, 0x14540008, 0x24020305, 0x31020080, 0x54400001,
+	0x34e70010, 0x24020905, 0xa4c2000c, 0x0a0001bc, 0x34e70020, 0xa4c2000c,
+	0x3c020800, 0x8c422400, 0x10400003, 0x3c024b65, 0x0a0001c4, 0x34427654,
+	0x3c02b49a, 0x344289ab, 0xacc2001c, 0x30e2ffff, 0xacc20010, 0x0e0005aa,
+	0x00c02021, 0x3242ffff, 0x0054102b, 0x1440ffa4, 0x00000000, 0x24020002,
+	0x3c010800, 0x0a0001d9, 0xa0221ba8, 0x8ec2083c, 0x24420001, 0x0a0001d9,
+	0xaec2083c, 0x14820003, 0x00000000, 0x0e0004b9, 0x00000000, 0x8fbf002c,
+	0x8fb60028, 0x8fb50024, 0x8fb40020, 0x8fb3001c, 0x8fb20018, 0x8fb10014,
+	0x8fb00010, 0x03e00008, 0x27bd0030, 0x27bdffd0, 0xafbf0028, 0xafb30024,
+	0xafb20020, 0xafb1001c, 0xafb00018, 0x8f725c9c, 0x3c0200ff, 0x3442fff8,
+	0x3c060800, 0x24c61bc4, 0x02428824, 0x9623000e, 0x8cc20000, 0x00431021,
+	0xacc20000, 0x8e220010, 0x30420020, 0x14400011, 0x00809821, 0x0e000643,
 	0x02202021, 0x3c02c000, 0x02421825, 0xaf635c9c, 0x8f625c90, 0x30420002,
-	0x10400061, 0x00000000, 0xaf635c9c, 0x8f625c90, 0x30420002, 0x1040005c,
-	0x00000000, 0x0a000278, 0x00000000, 0x8e220008, 0x00021c02, 0x000321c0,
-	0x3042ffff, 0x3c030800, 0x906316f8, 0x000229c0, 0x24020002, 0x14620003,
-	0x3c034b65, 0x0a000290, 0x00008021, 0x8e22001c, 0x34637654, 0x10430002,
-	0x24100002, 0x24100001, 0x0e000300, 0x02003021, 0x24020003, 0x3c010800,
-	0xa02216f8, 0x24020002, 0x1202000a, 0x24020001, 0x3c030800, 0x8c631fd0,
-	0x10620006, 0x00000000, 0x3c020800, 0x94421fb8, 0x00021400, 0x0a0002cd,
-	0xae220014, 0x3c040800, 0x24841fba, 0x94820000, 0x00021400, 0xae220014,
-	0x3c020800, 0x8c42171c, 0x3c03c000, 0x3c010800, 0xa02016f8, 0x00431025,
-	0xaf625c5c, 0x8f625c50, 0x30420002, 0x10400009, 0x00000000, 0x2484f762,
+	0x10400121, 0x00000000, 0xaf635c9c, 0x8f625c90, 0x30420002, 0x1040011c,
+	0x00000000, 0x0a000200, 0x00000000, 0x8e240008, 0x8e230014, 0x00041402,
+	0x000241c0, 0x00031502, 0x304201ff, 0x2442ffff, 0x3042007f, 0x00031942,
+	0x30637800, 0x00021100, 0x24424000, 0x00625021, 0x9542000a, 0x3084ffff,
+	0x30420008, 0x104000b3, 0x000429c0, 0x3c020800, 0x8c422410, 0x1440002d,
+	0x25050008, 0x95020014, 0x3c010800, 0xa42223e0, 0x8d070010, 0x00071402,
+	0x3c010800, 0xa42223e2, 0x3c010800, 0xa42723e4, 0x9502000e, 0x30e3ffff,
+	0x00431023, 0x3c010800, 0xac222418, 0x8f626800, 0x3c030010, 0x00431024,
+	0x10400005, 0x00000000, 0x9503001a, 0x9502001c, 0x0a000235, 0x00431021,
+	0x9502001a, 0x3c010800, 0xac22240c, 0x3c02c000, 0x02421825, 0x3c010800,
+	0xac282410, 0x3c010800, 0xac322414, 0xaf635c9c, 0x8f625c90, 0x30420002,
+	0x104000df, 0x00000000, 0xaf635c9c, 0x8f625c90, 0x30420002, 0x104000da,
+	0x00000000, 0x0a000242, 0x00000000, 0x9502000e, 0x3c030800, 0x946323e4,
+	0x00434823, 0x3123ffff, 0x2c620008, 0x1040001c, 0x00000000, 0x95020014,
+	0x24420028, 0x00a22821, 0x00031042, 0x1840000b, 0x00002021, 0x24c60848,
+	0x00403821, 0x94a30000, 0x8cc20000, 0x24840001, 0x00431021, 0xacc20000,
+	0x0087102a, 0x1440fff9, 0x24a50002, 0x31220001, 0x1040001f, 0x3c024000,
+	0x3c040800, 0x2484240c, 0xa0a00001, 0x94a30000, 0x8c820000, 0x00431021,
+	0x0a000281, 0xac820000, 0x8f626800, 0x3c030010, 0x00431024, 0x10400009,
+	0x00000000, 0x9502001a, 0x3c030800, 0x8c63240c, 0x00431021, 0x3c010800,
+	0xac22240c, 0x0a000282, 0x3c024000, 0x9502001a, 0x9504001c, 0x3c030800,
+	0x8c63240c, 0x00441023, 0x00621821, 0x3c010800, 0xac23240c, 0x3c024000,
+	0x02421825, 0xaf635c9c, 0x8f625c90, 0x30420002, 0x1440fffc, 0x00000000,
+	0x9542000a, 0x30420010, 0x10400095, 0x00000000, 0x3c060800, 0x24c62410,
+	0x3c020800, 0x944223e4, 0x8cc50000, 0x3c040800, 0x8c842418, 0x24420030,
+	0x00a22821, 0x94a20004, 0x3c030800, 0x8c63240c, 0x00441023, 0x00621821,
+	0x00603821, 0x00032402, 0x30e2ffff, 0x00823821, 0x00071402, 0x00e23821,
+	0x00071027, 0x3c010800, 0xac23240c, 0xa4a20006, 0x3c030800, 0x8c632414,
+	0x3c0200ff, 0x3442fff8, 0x00628824, 0x96220008, 0x24040001, 0x24034000,
+	0x000241c0, 0x00e01021, 0xa502001a, 0xa500001c, 0xacc00000, 0x3c010800,
+	0xac241b70, 0xaf635cb8, 0x8f625cb0, 0x30420002, 0x10400003, 0x00000000,
+	0x3c010800, 0xac201b70, 0x8e220008, 0xaf625cb8, 0x8f625cb0, 0x30420002,
+	0x10400003, 0x00000000, 0x3c010800, 0xac201b70, 0x3c020800, 0x8c421b70,
+	0x1040ffec, 0x00000000, 0x3c040800, 0x0e000643, 0x8c842414, 0x0a000320,
+	0x00000000, 0x3c030800, 0x90631ba8, 0x24020002, 0x14620003, 0x3c034b65,
+	0x0a0002d7, 0x00008021, 0x8e22001c, 0x34637654, 0x10430002, 0x24100002,
+	0x24100001, 0x01002021, 0x0e000346, 0x02003021, 0x24020003, 0x3c010800,
+	0xa0221ba8, 0x24020002, 0x1202000a, 0x24020001, 0x3c030800, 0x8c632400,
+	0x10620006, 0x00000000, 0x3c020800, 0x944223e8, 0x00021400, 0x0a000315,
+	0xae220014, 0x3c040800, 0x248423ea, 0x94820000, 0x00021400, 0xae220014,
+	0x3c020800, 0x8c421bcc, 0x3c03c000, 0x3c010800, 0xa0201ba8, 0x00431025,
+	0xaf625c5c, 0x8f625c50, 0x30420002, 0x10400009, 0x00000000, 0x2484f7e2,
 	0x8c820000, 0x00431025, 0xaf625c5c, 0x8f625c50, 0x30420002, 0x1440fffa,
-	0x00000000, 0x3c020800, 0x244216e4, 0x8c430000, 0x24630001, 0xac430000,
-	0x8f630c14, 0x3063000f, 0x2c620002, 0x1440000b, 0x00009821, 0x8f630c14,
-	0x3c020800, 0x8c4216b4, 0x3063000f, 0x24420001, 0x3c010800, 0xac2216b4,
-	0x2c620002, 0x1040fff7, 0x00009821, 0x3c024000, 0x02421825, 0xaf635c9c,
+	0x00000000, 0x3c020800, 0x24421b94, 0x8c430000, 0x24630001, 0xac430000,
+	0x8f630c14, 0x3063000f, 0x2c620002, 0x1440000c, 0x3c024000, 0x8f630c14,
+	0x3c020800, 0x8c421b50, 0x3063000f, 0x24420001, 0x3c010800, 0xac221b50,
+	0x2c620002, 0x1040fff7, 0x00000000, 0x3c024000, 0x02421825, 0xaf635c9c,
 	0x8f625c90, 0x30420002, 0x1440fffc, 0x00000000, 0x12600003, 0x00000000,
-	0x0e000450, 0x00000000, 0x8fbf0020, 0x8fb3001c, 0x8fb20018, 0x8fb10014,
-	0x8fb00010, 0x03e00008, 0x27bd0028, 0x0a0002df, 0x00000000, 0x8f634450,
-	0x3c040800, 0x248416e8, 0x8c820000, 0x00031c02, 0x0043102b, 0x14400007,
-	0x3c038000, 0x8c840004, 0x8f624450, 0x00021c02, 0x0083102b, 0x1040fffc,
-	0x3c038000, 0xaf634444, 0x8f624444, 0x00431024, 0x1440fffd, 0x00000000,
-	0x8f624448, 0x03e00008, 0x3042ffff, 0x3c024000, 0x00822025, 0xaf645c38,
-	0x8f625c30, 0x30420002, 0x1440fffc, 0x00000000, 0x03e00008, 0x00000000,
-	0x27bdffe0, 0x00805021, 0x14c00017, 0x254c0008, 0x3c020800, 0x8c421fd4,
-	0x1040000a, 0x2402003e, 0x3c010800, 0xa4221fb0, 0x24020016, 0x3c010800,
-	0xa4221fb2, 0x2402002a, 0x3c010800, 0x0a00031a, 0xa4221fb4, 0x95420014,
-	0x3c010800, 0xa4221fb0, 0x8d430010, 0x00031402, 0x3c010800, 0xa4221fb2,
-	0x3c010800, 0xa4231fb4, 0x3c040800, 0x94841fb4, 0x3c030800, 0x94631fb2,
-	0x958d0006, 0x3c020800, 0x94421fb0, 0x00832023, 0x01a27023, 0x3065ffff,
-	0x24a20028, 0x01824021, 0x3082ffff, 0x14c0001a, 0x01025821, 0x9562000c,
-	0x3042003f, 0x3c010800, 0xa4221fb6, 0x95620004, 0x95630006, 0x3c010800,
-	0xac201fc4, 0x3c010800, 0xac201fc8, 0x00021400, 0x00431025, 0x3c010800,
-	0xac221720, 0x95020004, 0x3c010800, 0xa4221724, 0x95030002, 0x01a51023,
-	0x0043102a, 0x10400010, 0x24020001, 0x3c010800, 0x0a00034e, 0xac221fd8,
-	0x3c030800, 0x8c631fc8, 0x3c020800, 0x94421724, 0x00431021, 0xa5020004,
-	0x3c020800, 0x94421720, 0xa5620004, 0x3c020800, 0x8c421720, 0xa5620006,
-	0x3c020800, 0x8c421fd0, 0x3c070800, 0x8ce71fc4, 0x3c050800, 0x144000c7,
-	0x8ca51fc8, 0x3c020800, 0x94421724, 0x00451821, 0x3063ffff, 0x0062182b,
-	0x24020002, 0x10c2000d, 0x00a32823, 0x3c020800, 0x94421fb6, 0x30420009,
-	0x10400008, 0x00000000, 0x9562000c, 0x3042fff6, 0xa562000c, 0x3c020800,
-	0x94421fb6, 0x30420009, 0x00e23823, 0x3c020800, 0x8c421fd8, 0x1040004b,
-	0x24020002, 0x01003021, 0x3c020800, 0x94421fb2, 0x00003821, 0xa500000a,
-	0x01a21023, 0xa5020002, 0x3082ffff, 0x00021042, 0x18400008, 0x00002821,
-	0x00401821, 0x94c20000, 0x24e70001, 0x00a22821, 0x00e3102a, 0x1440fffb,
-	0x24c60002, 0x00051c02, 0x30a2ffff, 0x00622821, 0x00051402, 0x00a22821,
-	0x00a04821, 0x00051027, 0xa502000a, 0x00002821, 0x2506000c, 0x00003821,
-	0x94c20000, 0x24e70001, 0x00a22821, 0x2ce20004, 0x1440fffb, 0x24c60002,
-	0x95020002, 0x00003821, 0x91030009, 0x00442023, 0x01603021, 0x3082ffff,
-	0xa4c00010, 0x00621821, 0x00021042, 0x18400010, 0x00a32821, 0x00404021,
-	0x94c20000, 0x24c60002, 0x00a22821, 0x30c2007f, 0x14400006, 0x24e70001,
-	0x8d430000, 0x3c02007f, 0x3442ff80, 0x00625024, 0x25460008, 0x00e8102a,
-	0x1440fff3, 0x00000000, 0x30820001, 0x10400005, 0x00051c02, 0xa0c00001,
-	0x94c20000, 0x00a22821, 0x00051c02, 0x30a2ffff, 0x00622821, 0x00051402,
-	0x00a22821, 0x0a000415, 0x30a5ffff, 0x14c20063, 0x00000000, 0x3c090800,
-	0x95291fb2, 0x95030002, 0x01a91023, 0x1062005d, 0x01003021, 0x00003821,
-	0x00002821, 0x01a91023, 0xa5020002, 0x3082ffff, 0x00021042, 0x18400008,
-	0xa500000a, 0x00401821, 0x94c20000, 0x24e70001, 0x00a22821, 0x00e3102a,
-	0x1440fffb, 0x24c60002, 0x00051c02, 0x30a2ffff, 0x00622821, 0x00051402,
-	0x00a22821, 0x00a04821, 0x00051027, 0xa502000a, 0x00002821, 0x2506000c,
-	0x00003821, 0x94c20000, 0x24e70001, 0x00a22821, 0x2ce20004, 0x1440fffb,
-	0x24c60002, 0x95020002, 0x00003821, 0x91030009, 0x00442023, 0x01603021,
-	0x3082ffff, 0xa4c00010, 0x3c040800, 0x94841fb4, 0x00621821, 0x00a32821,
-	0x00051c02, 0x30a2ffff, 0x00622821, 0x00051c02, 0x3c020800, 0x94421fb0,
-	0x00a34021, 0x00441023, 0x00021fc2, 0x00431021, 0x00021043, 0x18400010,
-	0x00002821, 0x00402021, 0x94c20000, 0x24c60002, 0x00a22821, 0x30c2007f,
-	0x14400006, 0x24e70001, 0x8d430000, 0x3c02007f, 0x3442ff80, 0x00625024,
-	0x25460008, 0x00e4102a, 0x1440fff3, 0x00000000, 0x3c020800, 0x94421fcc,
-	0x00a22821, 0x00051c02, 0x30a2ffff, 0x00622821, 0x00051402, 0x00a22821,
-	0x3102ffff, 0x00a22821, 0x00051c02, 0x30a2ffff, 0x00622821, 0x00051402,
-	0x00a22821, 0x00a02021, 0x00051027, 0xa5620010, 0xad800014, 0x0a000435,
-	0xad800000, 0x8d830010, 0x00602021, 0x10a00007, 0x00034c02, 0x01252821,
-	0x00051402, 0x30a3ffff, 0x00432821, 0x00051402, 0x00a24821, 0x00091027,
-	0xa502000a, 0x3c030800, 0x94631fb4, 0x3082ffff, 0x01a21021, 0x00432823,
-	0x00a72821, 0x00051c02, 0x30a2ffff, 0x00622821, 0x00051402, 0x00a22821,
-	0x00a02021, 0x00051027, 0xa5620010, 0x3082ffff, 0x00091c00, 0x00431025,
-	0xad820010, 0x3c020800, 0x8c421fd4, 0x10400002, 0x25a2fff2, 0xa5820034,
-	0x3c020800, 0x8c421fc8, 0x3c030800, 0x8c631720, 0x24420001, 0x3c010800,
-	0xac221fc8, 0x3c020800, 0x8c421fc4, 0x31c4ffff, 0x00641821, 0x3c010800,
-	0xac231720, 0x00441021, 0x3c010800, 0xac221fc4, 0x03e00008, 0x27bd0020,
-	0x27bdffc8, 0x3c040800, 0x248416f8, 0xafbf0034, 0xafbe0030, 0xafb7002c,
-	0xafb60028, 0xafb50024, 0xafb40020, 0xafb3001c, 0xafb20018, 0xafb10014,
-	0xafb00010, 0x90830000, 0x24020003, 0x146200f4, 0x00000000, 0x3c020800,
-	0x8c421710, 0x3c030800, 0x8c63170c, 0x3c1e0800, 0x97de16f6, 0x0043102a,
-	0x104000eb, 0x3c168000, 0x249708c4, 0x33d5ffff, 0x24920018, 0x3c020800,
-	0x8c421718, 0x104000e4, 0x00000000, 0x3c140800, 0x96941fb0, 0x3282ffff,
-	0x104000d6, 0x00008021, 0x00409821, 0x00008821, 0x8f634450, 0x3c020800,
-	0x8c4216e8, 0x00031c02, 0x0043102b, 0x14400008, 0x00000000, 0x3c040800,
-	0x8c8416ec, 0x8f624450, 0x00021c02, 0x0083102b, 0x1040fffc, 0x00000000,
-	0xaf764444, 0x8f624444, 0x00561024, 0x10400006, 0x00000000, 0x3c038000,
-	0x8f624444, 0x00431024, 0x1440fffd, 0x00000000, 0x8f624448, 0x3046ffff,
-	0x10c0005f, 0x00000000, 0x3c090800, 0x01314821, 0x8d291728, 0x9528000a,
-	0x31020040, 0x10400004, 0x2407180c, 0x8d22000c, 0x2407188c, 0xacc20018,
-	0x31021000, 0x10400004, 0x34e32000, 0x00081040, 0x3042c000, 0x00623825,
-	0x31020080, 0x54400001, 0x34e70010, 0x3c020800, 0x00511021, 0x8c421730,
-	0x3c030800, 0x00711821, 0x8c631734, 0x00021500, 0x00031c00, 0x00431025,
-	0xacc20014, 0x95240008, 0x3202ffff, 0x00821021, 0x0262102a, 0x14400002,
-	0x02902823, 0x00802821, 0x8d220000, 0x02058021, 0xacc20000, 0x8d220004,
-	0x00c02021, 0x26310010, 0xac820004, 0x30e2ffff, 0xac800008, 0xa485000e,
-	0xac820010, 0x24020305, 0x0e000560, 0xa482000c, 0x3202ffff, 0x0053102b,
-	0x1440ffaf, 0x3202ffff, 0x0a00054c, 0x00000000, 0x8e420000, 0x8e43fffc,
-	0x0043102a, 0x10400084, 0x00000000, 0x8e45fff0, 0x8f644450, 0x3c030800,
-	0x8c6316e8, 0x00051100, 0x3c090800, 0x01224821, 0x8d291728, 0x00041402,
-	0x0062182b, 0x14600008, 0x00000000, 0x3c030800, 0x8c6316ec, 0x8f624450,
-	0x00021402, 0x0062102b, 0x1040fffc, 0x00000000, 0xaf764444, 0x8f624444,
-	0x00561024, 0x10400006, 0x00000000, 0x3c038000, 0x8f624444, 0x00431024,
-	0x1440fffd, 0x00000000, 0x8f624448, 0x3046ffff, 0x14c00005, 0x00000000,
-	0x8ee20000, 0x24420001, 0x0a000554, 0xaee20000, 0x9528000a, 0x31020040,
-	0x10400004, 0x2407180c, 0x8d22000c, 0x2407188c, 0xacc20018, 0x31021000,
-	0x10400004, 0x34e32000, 0x00081040, 0x3042c000, 0x00623825, 0x00051900,
-	0x3c020800, 0x00431021, 0x8c421730, 0x3c010800, 0x00230821, 0x8c231734,
-	0x00021500, 0x00031c00, 0x00431025, 0xacc20014, 0x3c030800, 0x8c631704,
-	0x95220008, 0x00432023, 0x3202ffff, 0x3083ffff, 0x00431021, 0x02a2102a,
-	0x14400002, 0x03d02823, 0x00802821, 0x8e420000, 0x30a4ffff, 0x00441021,
-	0xae420000, 0xa4c5000e, 0x8d220000, 0xacc20000, 0x8d220004, 0x8e43fff4,
-	0x00431021, 0xacc20004, 0x8e43fff4, 0x95220008, 0x00641821, 0x0062102a,
-	0x14400006, 0x02058021, 0x8e42fff0, 0xae40fff4, 0x24420001, 0x0a000530,
-	0xae42fff0, 0xae43fff4, 0xacc00008, 0x3202ffff, 0x10550003, 0x31020004,
-	0x10400006, 0x24020305, 0x31020080, 0x54400001, 0x34e70010, 0x34e70020,
-	0x24020905, 0xa4c2000c, 0x30e2ffff, 0xacc20010, 0x3c030800, 0x8c63170c,
-	0x3c020800, 0x8c421710, 0x54620004, 0x3c02b49a, 0x3c024b65, 0x0a000548,
-	0x34427654, 0x344289ab, 0xacc2001c, 0x0e000560, 0x00c02021, 0x3202ffff,
-	0x0055102b, 0x1440ff7e, 0x00000000, 0x8e420000, 0x8e43fffc, 0x0043102a,
-	0x1440ff1a, 0x00000000, 0x8fbf0034, 0x8fbe0030, 0x8fb7002c, 0x8fb60028,
-	0x8fb50024, 0x8fb40020, 0x8fb3001c, 0x8fb20018, 0x8fb10014, 0x8fb00010,
-	0x03e00008, 0x27bd0038, 0x27bdffe8, 0xafbf0014, 0xafb00010, 0x8f624450,
-	0x8f634410, 0x0a00056f, 0x00808021, 0x8f626820, 0x30422000, 0x10400003,
-	0x00000000, 0x0e00025a, 0x00002021, 0x8f624450, 0x8f634410, 0x3042ffff,
-	0x0043102b, 0x1440fff5, 0x00000000, 0x8f630c14, 0x3063000f, 0x2c620002,
-	0x1440000b, 0x00000000, 0x8f630c14, 0x3c020800, 0x8c4216b4, 0x3063000f,
-	0x24420001, 0x3c010800, 0xac2216b4, 0x2c620002, 0x1040fff7, 0x00000000,
-	0xaf705c18, 0x8f625c10, 0x30420002, 0x10400009, 0x00000000, 0x8f626820,
-	0x30422000, 0x1040fff8, 0x00000000, 0x0e00025a, 0x00002021, 0x0a000582,
-	0x00000000, 0x8fbf0014, 0x8fb00010, 0x03e00008, 0x27bd0018, 0x00000000,
-	0x00000000
+	0x0e0004b9, 0x00000000, 0x8fbf0028, 0x8fb30024, 0x8fb20020, 0x8fb1001c,
+	0x8fb00018, 0x03e00008, 0x27bd0030, 0x8f634450, 0x3c040800, 0x24841b98,
+	0x8c820000, 0x00031c02, 0x0043102b, 0x14400007, 0x3c038000, 0x8c840004,
+	0x8f624450, 0x00021c02, 0x0083102b, 0x1040fffc, 0x3c038000, 0xaf634444,
+	0x8f624444, 0x00431024, 0x1440fffd, 0x00000000, 0x8f624448, 0x03e00008,
+	0x3042ffff, 0x3c024000, 0x00822025, 0xaf645c38, 0x8f625c30, 0x30420002,
+	0x1440fffc, 0x00000000, 0x03e00008, 0x00000000, 0x27bdffe0, 0x00805821,
+	0x14c00017, 0x256e0008, 0x3c020800, 0x8c422404, 0x1040000a, 0x2402003e,
+	0x3c010800, 0xa42223e0, 0x24020016, 0x3c010800, 0xa42223e2, 0x2402002a,
+	0x3c010800, 0x0a000360, 0xa42223e4, 0x95620014, 0x3c010800, 0xa42223e0,
+	0x8d670010, 0x00071402, 0x3c010800, 0xa42223e2, 0x3c010800, 0xa42723e4,
+	0x3c040800, 0x948423e4, 0x3c030800, 0x946323e2, 0x95cf0006, 0x3c020800,
+	0x944223e0, 0x00832023, 0x01e2c023, 0x3065ffff, 0x24a20028, 0x01c24821,
+	0x3082ffff, 0x14c0001a, 0x01226021, 0x9582000c, 0x3042003f, 0x3c010800,
+	0xa42223e6, 0x95820004, 0x95830006, 0x3c010800, 0xac2023f4, 0x3c010800,
+	0xac2023f8, 0x00021400, 0x00431025, 0x3c010800, 0xac221bd0, 0x95220004,
+	0x3c010800, 0xa4221bd4, 0x95230002, 0x01e51023, 0x0043102a, 0x10400010,
+	0x24020001, 0x3c010800, 0x0a000394, 0xac222408, 0x3c030800, 0x8c6323f8,
+	0x3c020800, 0x94421bd4, 0x00431021, 0xa5220004, 0x3c020800, 0x94421bd0,
+	0xa5820004, 0x3c020800, 0x8c421bd0, 0xa5820006, 0x3c020800, 0x8c422400,
+	0x3c0d0800, 0x8dad23f4, 0x3c0a0800, 0x144000e5, 0x8d4a23f8, 0x3c020800,
+	0x94421bd4, 0x004a1821, 0x3063ffff, 0x0062182b, 0x24020002, 0x10c2000d,
+	0x01435023, 0x3c020800, 0x944223e6, 0x30420009, 0x10400008, 0x00000000,
+	0x9582000c, 0x3042fff6, 0xa582000c, 0x3c020800, 0x944223e6, 0x30420009,
+	0x01a26823, 0x3c020800, 0x8c422408, 0x1040004a, 0x01203821, 0x3c020800,
+	0x944223e2, 0x00004021, 0xa520000a, 0x01e21023, 0xa5220002, 0x3082ffff,
+	0x00021042, 0x18400008, 0x00003021, 0x00401821, 0x94e20000, 0x25080001,
+	0x00c23021, 0x0103102a, 0x1440fffb, 0x24e70002, 0x00061c02, 0x30c2ffff,
+	0x00623021, 0x00061402, 0x00c23021, 0x00c02821, 0x00061027, 0xa522000a,
+	0x00003021, 0x2527000c, 0x00004021, 0x94e20000, 0x25080001, 0x00c23021,
+	0x2d020004, 0x1440fffb, 0x24e70002, 0x95220002, 0x00004021, 0x91230009,
+	0x00442023, 0x01803821, 0x3082ffff, 0xa4e00010, 0x00621821, 0x00021042,
+	0x18400010, 0x00c33021, 0x00404821, 0x94e20000, 0x24e70002, 0x00c23021,
+	0x30e2007f, 0x14400006, 0x25080001, 0x8d630000, 0x3c02007f, 0x3442ff80,
+	0x00625824, 0x25670008, 0x0109102a, 0x1440fff3, 0x00000000, 0x30820001,
+	0x10400005, 0x00061c02, 0xa0e00001, 0x94e20000, 0x00c23021, 0x00061c02,
+	0x30c2ffff, 0x00623021, 0x00061402, 0x00c23021, 0x0a000479, 0x30c6ffff,
+	0x24020002, 0x14c20081, 0x00000000, 0x3c020800, 0x8c42241c, 0x14400007,
+	0x00000000, 0x3c020800, 0x944223e2, 0x95230002, 0x01e21023, 0x10620077,
+	0x00000000, 0x3c020800, 0x944223e2, 0x01e21023, 0xa5220002, 0x3c020800,
+	0x8c42241c, 0x1040001a, 0x31e3ffff, 0x8dc70010, 0x3c020800, 0x94421ba6,
+	0x00e04021, 0x00072c02, 0x00aa2021, 0x00431023, 0x00823823, 0x00072402,
+	0x30e2ffff, 0x00823821, 0x00071027, 0xa522000a, 0x3102ffff, 0x3c040800,
+	0x948423e4, 0x00453023, 0x00e02821, 0x00641823, 0x006d1821, 0x00c33021,
+	0x00061c02, 0x30c2ffff, 0x0a000479, 0x00623021, 0x01203821, 0x00004021,
+	0x3082ffff, 0x00021042, 0x18400008, 0x00003021, 0x00401821, 0x94e20000,
+	0x25080001, 0x00c23021, 0x0103102a, 0x1440fffb, 0x24e70002, 0x00061c02,
+	0x30c2ffff, 0x00623021, 0x00061402, 0x00c23021, 0x00c02821, 0x00061027,
+	0xa522000a, 0x00003021, 0x2527000c, 0x00004021, 0x94e20000, 0x25080001,
+	0x00c23021, 0x2d020004, 0x1440fffb, 0x24e70002, 0x95220002, 0x00004021,
+	0x91230009, 0x00442023, 0x01803821, 0x3082ffff, 0xa4e00010, 0x3c040800,
+	0x948423e4, 0x00621821, 0x00c33021, 0x00061c02, 0x30c2ffff, 0x00623021,
+	0x00061c02, 0x3c020800, 0x944223e0, 0x00c34821, 0x00441023, 0x00021fc2,
+	0x00431021, 0x00021043, 0x18400010, 0x00003021, 0x00402021, 0x94e20000,
+	0x24e70002, 0x00c23021, 0x30e2007f, 0x14400006, 0x25080001, 0x8d630000,
+	0x3c02007f, 0x3442ff80, 0x00625824, 0x25670008, 0x0104102a, 0x1440fff3,
+	0x00000000, 0x3c020800, 0x944223fc, 0x00c23021, 0x3122ffff, 0x00c23021,
+	0x00061c02, 0x30c2ffff, 0x00623021, 0x00061402, 0x00c23021, 0x00c04021,
+	0x00061027, 0xa5820010, 0xadc00014, 0x0a000499, 0xadc00000, 0x8dc70010,
+	0x00e04021, 0x11400007, 0x00072c02, 0x00aa3021, 0x00061402, 0x30c3ffff,
+	0x00433021, 0x00061402, 0x00c22821, 0x00051027, 0xa522000a, 0x3c030800,
+	0x946323e4, 0x3102ffff, 0x01e21021, 0x00433023, 0x00cd3021, 0x00061c02,
+	0x30c2ffff, 0x00623021, 0x00061402, 0x00c23021, 0x00c04021, 0x00061027,
+	0xa5820010, 0x3102ffff, 0x00051c00, 0x00431025, 0xadc20010, 0x3c020800,
+	0x8c422404, 0x10400002, 0x25e2fff2, 0xa5c20034, 0x3c020800, 0x8c4223f8,
+	0x3c040800, 0x8c8423f4, 0x24420001, 0x3c010800, 0xac2223f8, 0x3c020800,
+	0x8c421bd0, 0x3303ffff, 0x00832021, 0x3c010800, 0xac2423f4, 0x00431821,
+	0x0062102b, 0x10400003, 0x2482ffff, 0x3c010800, 0xac2223f4, 0x3c010800,
+	0xac231bd0, 0x03e00008, 0x27bd0020, 0x27bdffb8, 0x3c050800, 0x24a51ba8,
+	0xafbf0044, 0xafbe0040, 0xafb7003c, 0xafb60038, 0xafb50034, 0xafb40030,
+	0xafb3002c, 0xafb20028, 0xafb10024, 0xafb00020, 0x90a30000, 0x24020003,
+	0x146200d5, 0x00000000, 0x3c090800, 0x95291ba6, 0x3c020800, 0x944223e0,
+	0x3c030800, 0x8c631bc0, 0x3c040800, 0x8c841bbc, 0x01221023, 0x0064182a,
+	0xa7a9001e, 0x106000c8, 0xa7a20016, 0x24be0020, 0x97b6001e, 0x24b30018,
+	0x24b70014, 0x8fc20000, 0x14400008, 0x00000000, 0x8fc2fff8, 0x97a30016,
+	0x8fc4fff4, 0x00431021, 0x0082202a, 0x148000ba, 0x00000000, 0x97d50818,
+	0x32a2ffff, 0x104000ad, 0x00009021, 0x0040a021, 0x00008821, 0x0e00062d,
+	0x00000000, 0x00403021, 0x14c00007, 0x00000000, 0x3c020800, 0x8c4223ec,
+	0x24420001, 0x3c010800, 0x0a00059e, 0xac2223ec, 0x3c100800, 0x02118021,
+	0x8e101bd8, 0x9608000a, 0x31020040, 0x10400004, 0x2407180c, 0x8e02000c,
+	0x2407188c, 0xacc20018, 0x31021000, 0x10400004, 0x34e32000, 0x00081040,
+	0x3042c000, 0x00623825, 0x31020080, 0x54400001, 0x34e70010, 0x3c020800,
+	0x00511021, 0x8c421be0, 0x3c030800, 0x00711821, 0x8c631be4, 0x00021500,
+	0x00031c00, 0x00431025, 0xacc20014, 0x96040008, 0x3242ffff, 0x00821021,
+	0x0282102a, 0x14400002, 0x02b22823, 0x00802821, 0x8e020000, 0x02459021,
+	0xacc20000, 0x8e020004, 0x00c02021, 0x26310010, 0xac820004, 0x30e2ffff,
+	0xac800008, 0xa485000e, 0xac820010, 0x24020305, 0x0e0005aa, 0xa482000c,
+	0x3242ffff, 0x0054102b, 0x1440ffc0, 0x3242ffff, 0x0a000596, 0x00000000,
+	0x8e620000, 0x8e63fffc, 0x0043102a, 0x1040006c, 0x00000000, 0x8e62fff0,
+	0x00028900, 0x3c100800, 0x02118021, 0x0e00062d, 0x8e101bd8, 0x00403021,
+	0x14c00005, 0x00000000, 0x8e62082c, 0x24420001, 0x0a00059e, 0xae62082c,
+	0x9608000a, 0x31020040, 0x10400004, 0x2407180c, 0x8e02000c, 0x2407188c,
+	0xacc20018, 0x31021000, 0x10400004, 0x34e32000, 0x00081040, 0x3042c000,
+	0x00623825, 0x3c020800, 0x00511021, 0x8c421be0, 0x3c030800, 0x00711821,
+	0x8c631be4, 0x00021500, 0x00031c00, 0x00431025, 0xacc20014, 0x8e63fff4,
+	0x96020008, 0x00432023, 0x3242ffff, 0x3083ffff, 0x00431021, 0x02c2102a,
+	0x10400003, 0x00802821, 0x97a9001e, 0x01322823, 0x8e620000, 0x30a4ffff,
+	0x00441021, 0xae620000, 0xa4c5000e, 0x8e020000, 0xacc20000, 0x8e020004,
+	0x8e63fff4, 0x00431021, 0xacc20004, 0x8e63fff4, 0x96020008, 0x00641821,
+	0x0062102a, 0x14400006, 0x02459021, 0x8e62fff0, 0xae60fff4, 0x24420001,
+	0x0a000579, 0xae62fff0, 0xae63fff4, 0xacc00008, 0x3242ffff, 0x10560003,
+	0x31020004, 0x10400006, 0x24020305, 0x31020080, 0x54400001, 0x34e70010,
+	0x34e70020, 0x24020905, 0xa4c2000c, 0x8ee30000, 0x8ee20004, 0x14620007,
+	0x3c02b49a, 0x8ee20860, 0x54400001, 0x34e70400, 0x3c024b65, 0x0a000590,
+	0x34427654, 0x344289ab, 0xacc2001c, 0x30e2ffff, 0xacc20010, 0x0e0005aa,
+	0x00c02021, 0x3242ffff, 0x0056102b, 0x1440ff96, 0x00000000, 0x8e620000,
+	0x8e63fffc, 0x0043102a, 0x1440ff3e, 0x00000000, 0x8fbf0044, 0x8fbe0040,
+	0x8fb7003c, 0x8fb60038, 0x8fb50034, 0x8fb40030, 0x8fb3002c, 0x8fb20028,
+	0x8fb10024, 0x8fb00020, 0x03e00008, 0x27bd0048, 0x27bdffe8, 0xafbf0014,
+	0xafb00010, 0x8f624450, 0x8f634410, 0x0a0005b9, 0x00808021, 0x8f626820,
+	0x30422000, 0x10400003, 0x00000000, 0x0e0001e3, 0x00002021, 0x8f624450,
+	0x8f634410, 0x3042ffff, 0x0043102b, 0x1440fff5, 0x00000000, 0x8f630c14,
+	0x3063000f, 0x2c620002, 0x1440000b, 0x00000000, 0x8f630c14, 0x3c020800,
+	0x8c421b50, 0x3063000f, 0x24420001, 0x3c010800, 0xac221b50, 0x2c620002,
+	0x1040fff7, 0x00000000, 0xaf705c18, 0x8f625c10, 0x30420002, 0x10400009,
+	0x00000000, 0x8f626820, 0x30422000, 0x1040fff8, 0x00000000, 0x0e0001e3,
+	0x00002021, 0x0a0005cc, 0x00000000, 0x8fbf0014, 0x8fb00010, 0x03e00008,
+	0x27bd0018, 0x00000000, 0x00000000, 0x00000000, 0x27bdffe8, 0x3c1bc000,
+	0xafbf0014, 0xafb00010, 0xaf60680c, 0x8f626804, 0x34420082, 0xaf626804,
+	0x8f634000, 0x24020b50, 0x3c010800, 0xac221b64, 0x24020b78, 0x3c010800,
+	0xac221b74, 0x34630002, 0xaf634000, 0x0e00060d, 0x00808021, 0x3c010800,
+	0xa0221b78, 0x304200ff, 0x24030002, 0x14430005, 0x00000000, 0x3c020800,
+	0x8c421b64, 0x0a000600, 0xac5000c0, 0x3c020800, 0x8c421b64, 0xac5000bc,
+	0x8f624434, 0x8f634438, 0x8f644410, 0x3c010800, 0xac221b6c, 0x3c010800,
+	0xac231b7c, 0x3c010800, 0xac241b68, 0x8fbf0014, 0x8fb00010, 0x03e00008,
+	0x27bd0018, 0x3c040800, 0x8c870000, 0x3c03aa55, 0x3463aa55, 0x3c06c003,
+	0xac830000, 0x8cc20000, 0x14430007, 0x24050002, 0x3c0355aa, 0x346355aa,
+	0xac830000, 0x8cc20000, 0x50430001, 0x24050001, 0x3c020800, 0xac470000,
+	0x03e00008, 0x00a01021, 0x27bdfff8, 0x18800009, 0x00002821, 0x8f63680c,
+	0x8f62680c, 0x1043fffe, 0x00000000, 0x24a50001, 0x00a4102a, 0x1440fff9,
+	0x00000000, 0x03e00008, 0x27bd0008, 0x8f634450, 0x3c020800, 0x8c421b6c,
+	0x00031c02, 0x0043102b, 0x14400008, 0x3c038000, 0x3c040800, 0x8c841b7c,
+	0x8f624450, 0x00021c02, 0x0083102b, 0x1040fffc, 0x3c038000, 0xaf634444,
+	0x8f624444, 0x00431024, 0x1440fffd, 0x00000000, 0x8f624448, 0x03e00008,
+	0x3042ffff, 0x3082ffff, 0x2442e000, 0x2c422001, 0x14400003, 0x3c024000,
+	0x0a000650, 0x2402ffff, 0x00822025, 0xaf645c38, 0x8f625c30, 0x30420002,
+	0x1440fffc, 0x00001021, 0x03e00008, 0x00000000, 0x8f624450, 0x3c030800,
+	0x8c631b68, 0x0a000659, 0x3042ffff, 0x8f624450, 0x3042ffff, 0x0043102b,
+	0x1440fffc, 0x00000000, 0x03e00008, 0x00000000, 0x27bdffe0, 0x00802821,
+	0x3c040800, 0x24841b10, 0x00003021, 0x00003821, 0xafbf0018, 0xafa00010,
+	0x0e000684, 0xafa00014, 0x0a000668, 0x00000000, 0x8fbf0018, 0x03e00008,
+	0x27bd0020, 0x00000000, 0x00000000, 0x00000000, 0x3c020800, 0x34423000,
+	0x3c030800, 0x34633000, 0x3c040800, 0x348437ff, 0x3c010800, 0xac221b84,
+	0x24020040, 0x3c010800, 0xac221b88, 0x3c010800, 0xac201b80, 0xac600000,
+	0x24630004, 0x0083102b, 0x5040fffd, 0xac600000, 0x03e00008, 0x00000000,
+	0x00804821, 0x8faa0010, 0x3c020800, 0x8c421b80, 0x3c040800, 0x8c841b88,
+	0x8fab0014, 0x24430001, 0x0044102b, 0x3c010800, 0xac231b80, 0x14400003,
+	0x00004021, 0x3c010800, 0xac201b80, 0x3c020800, 0x8c421b80, 0x3c030800,
+	0x8c631b84, 0x91240000, 0x00021140, 0x00431021, 0x00481021, 0x25080001,
+	0xa0440000, 0x29020008, 0x1440fff4, 0x25290001, 0x3c020800, 0x8c421b80,
+	0x3c030800, 0x8c631b84, 0x8f64680c, 0x00021140, 0x00431021, 0xac440008,
+	0xac45000c, 0xac460010, 0xac470014, 0xac4a0018, 0x03e00008, 0xac4b001c,
+	0x00000000, 0x00000000,
 };
 
 u32 tg3TsoFwRodata[] = {
-	0x4d61696e, 0x43707542, 0x00000000, 0x00000000, 0x74637073, 0x6567496e,
-	0x00000000, 0x53774576, 0x656e7430, 0x00000000, 0x00000000, 0x00000000,
-	0x00000000
+	0x4d61696e, 0x43707542, 0x00000000, 0x4d61696e, 0x43707541,
+	0x00000000, 0x00000000, 0x00000000, 0x73746b6f, 0x66666c64,
+	0x496e0000, 0x73746b6f, 0x66662a2a, 0x00000000, 0x53774576,
+	0x656e7430, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
+	0x66617461, 0x6c457272, 0x00000000, 0x00000000, 0x00000000
 };
 
 #if 0 /* All zeros, don't eat up space with it. */
@@ -3785,63 +4206,274 @@
 };
 #endif
 
+/* 5705 needs a special version of the TSO firmware.  */
+#define TG3_TSO5_FW_RELEASE_MAJOR	0x1
+#define TG3_TSO5_FW_RELASE_MINOR	0x1
+#define TG3_TSO5_FW_RELEASE_FIX		0x0
+#define TG3_TSO5_FW_START_ADDR		0x00010000
+#define TG3_TSO5_FW_TEXT_ADDR		0x00010000
+#define TG3_TSO5_FW_TEXT_LEN		0xeb0
+#define TG3_TSO5_FW_RODATA_ADDR		0x00010eb0
+#define TG3_TSO5_FW_RODATA_LEN		0x50
+#define TG3_TSO5_FW_DATA_ADDR		0x00010f20
+#define TG3_TSO5_FW_DATA_LEN		0x20
+#define TG3_TSO5_FW_SBSS_ADDR		0x00010f40
+#define TG3_TSO5_FW_SBSS_LEN		0x28
+#define TG3_TSO5_FW_BSS_ADDR		0x00010f70
+#define TG3_TSO5_FW_BSS_LEN		0x88
+
+static u32 tg3Tso5FwText[] = {
+	0x0c004003, 0x00000000, 0x00010f30, 0x00000000, 0x10000003, 0x00000000,
+	0x0000000d, 0x0000000d, 0x3c1d0001, 0x37bde000, 0x03a0f021, 0x3c100001,
+	0x26100000, 0x0c004010, 0x00000000, 0x0000000d, 0x27bdffe0, 0x3c04fefe,
+	0xafbf0018, 0x0c0042f0, 0x34840002, 0x0c00436c, 0x00000000, 0x3c030001,
+	0x90630f54, 0x24020002, 0x3c040001, 0x24840ebc, 0x14620003, 0x24050001,
+	0x3c040001, 0x24840eb0, 0x24060001, 0x00003821, 0xafa00010, 0x0c004380,
+	0xafa00014, 0x0c00402c, 0x00000000, 0x8fbf0018, 0x03e00008, 0x27bd0020,
+	0x00000000, 0x00000000, 0x27bdffe0, 0xafbf001c, 0xafb20018, 0xafb10014,
+	0x0c0042d3, 0xafb00010, 0x3c128000, 0x24110001, 0x8f706810, 0x32020400,
+	0x10400007, 0x00000000, 0x8f641008, 0x00921024, 0x14400003, 0x00000000,
+	0x0c004064, 0x00000000, 0x3c020001, 0x90420f76, 0x10510003, 0x32020200,
+	0x1040fff1, 0x00000000, 0x0c0041b4, 0x00000000, 0x08004034, 0x00000000,
+	0x8fbf001c, 0x8fb20018, 0x8fb10014, 0x8fb00010, 0x03e00008, 0x27bd0020,
+	0x27bdffe0, 0x3c040001, 0x24840ed0, 0x00002821, 0x00003021, 0x00003821,
+	0xafbf0018, 0xafa00010, 0x0c004380, 0xafa00014, 0x0000d021, 0x24020130,
+	0xaf625000, 0x3c010001, 0xa4200f70, 0x3c010001, 0xa0200f77, 0x8fbf0018,
+	0x03e00008, 0x27bd0020, 0x00000000, 0x00000000, 0x3c030001, 0x24630f80,
+	0x90620000, 0x27bdfff0, 0x14400003, 0x0080c021, 0x08004073, 0x00004821,
+	0x3c022000, 0x03021024, 0x10400003, 0x24090002, 0x08004073, 0xa0600000,
+	0x24090001, 0x00181040, 0x30431f80, 0x346f8008, 0x1520004b, 0x25eb0028,
+	0x3c040001, 0x00832021, 0x8c848010, 0x3c050001, 0x24a50f9a, 0x00041402,
+	0xa0a20000, 0x3c010001, 0xa0240f9b, 0x3c020001, 0x00431021, 0x94428014,
+	0x3c010001, 0xa0220f9c, 0x3c0c0001, 0x01836021, 0x8d8c8018, 0x304200ff,
+	0x24420008, 0x000220c3, 0x24020001, 0x3c010001, 0xa0220f80, 0x0124102b,
+	0x1040000c, 0x00003821, 0x24a6000e, 0x01602821, 0x8ca20000, 0x8ca30004,
+	0x24a50008, 0x24e70001, 0xacc20000, 0xacc30004, 0x00e4102b, 0x1440fff8,
+	0x24c60008, 0x00003821, 0x3c080001, 0x25080f9b, 0x91060000, 0x3c020001,
+	0x90420f9c, 0x2503000d, 0x00c32821, 0x00461023, 0x00021fc2, 0x00431021,
+	0x00021043, 0x1840000c, 0x00002021, 0x91020001, 0x00461023, 0x00021fc2,
+	0x00431021, 0x00021843, 0x94a20000, 0x24e70001, 0x00822021, 0x00e3102a,
+	0x1440fffb, 0x24a50002, 0x00041c02, 0x3082ffff, 0x00622021, 0x00041402,
+	0x00822021, 0x3c02ffff, 0x01821024, 0x3083ffff, 0x00431025, 0x3c010001,
+	0x080040fa, 0xac220fa0, 0x3c050001, 0x24a50f9c, 0x90a20000, 0x3c0c0001,
+	0x01836021, 0x8d8c8018, 0x000220c2, 0x1080000e, 0x00003821, 0x01603021,
+	0x24a5000c, 0x8ca20000, 0x8ca30004, 0x24a50008, 0x24e70001, 0xacc20000,
+	0xacc30004, 0x00e4102b, 0x1440fff8, 0x24c60008, 0x3c050001, 0x24a50f9c,
+	0x90a20000, 0x30430007, 0x24020004, 0x10620011, 0x28620005, 0x10400005,
+	0x24020002, 0x10620008, 0x000710c0, 0x080040fa, 0x00000000, 0x24020006,
+	0x1062000e, 0x000710c0, 0x080040fa, 0x00000000, 0x00a21821, 0x9463000c,
+	0x004b1021, 0x080040fa, 0xa4430000, 0x000710c0, 0x00a21821, 0x8c63000c,
+	0x004b1021, 0x080040fa, 0xac430000, 0x00a21821, 0x8c63000c, 0x004b2021,
+	0x00a21021, 0xac830000, 0x94420010, 0xa4820004, 0x95e70006, 0x3c020001,
+	0x90420f9c, 0x3c030001, 0x90630f9a, 0x00e2c823, 0x3c020001, 0x90420f9b,
+	0x24630028, 0x01e34021, 0x24420028, 0x15200012, 0x01e23021, 0x94c2000c,
+	0x3c010001, 0xa4220f98, 0x94c20004, 0x94c30006, 0x3c010001, 0xa4200f96,
+	0x3c010001, 0xa4200f92, 0x00021400, 0x00431025, 0x3c010001, 0xac220f8c,
+	0x95020004, 0x3c010001, 0x08004124, 0xa4220f90, 0x3c020001, 0x94420f90,
+	0x3c030001, 0x94630f92, 0x00431021, 0xa5020004, 0x3c020001, 0x94420f8c,
+	0xa4c20004, 0x3c020001, 0x8c420f8c, 0xa4c20006, 0x3c040001, 0x94840f92,
+	0x3c020001, 0x94420f90, 0x3c0a0001, 0x954a0f96, 0x00441821, 0x3063ffff,
+	0x0062182a, 0x24020002, 0x1122000b, 0x00832023, 0x3c030001, 0x94630f98,
+	0x30620009, 0x10400006, 0x3062fff6, 0xa4c2000c, 0x3c020001, 0x94420f98,
+	0x30420009, 0x01425023, 0x24020001, 0x1122001b, 0x29220002, 0x50400005,
+	0x24020002, 0x11200007, 0x31a2ffff, 0x08004197, 0x00000000, 0x1122001d,
+	0x24020016, 0x08004197, 0x31a2ffff, 0x3c0e0001, 0x95ce0fa0, 0x10800005,
+	0x01806821, 0x01c42021, 0x00041c02, 0x3082ffff, 0x00627021, 0x000e1027,
+	0xa502000a, 0x3c030001, 0x90630f9b, 0x31a2ffff, 0x00e21021, 0x0800418d,
+	0x00432023, 0x3c020001, 0x94420fa0, 0x00442021, 0x00041c02, 0x3082ffff,
+	0x00622021, 0x00807021, 0x00041027, 0x08004185, 0xa502000a, 0x3c050001,
+	0x24a50f9a, 0x90a30000, 0x14620002, 0x24e2fff2, 0xa5e20034, 0x90a20000,
+	0x00e21023, 0xa5020002, 0x3c030001, 0x94630fa0, 0x3c020001, 0x94420f7a,
+	0x30e5ffff, 0x00641821, 0x00451023, 0x00622023, 0x00041c02, 0x3082ffff,
+	0x00622021, 0x00041027, 0xa502000a, 0x3c030001, 0x90630f9c, 0x24620001,
+	0x14a20005, 0x00807021, 0x01631021, 0x90420000, 0x08004185, 0x00026200,
+	0x24620002, 0x14a20003, 0x306200fe, 0x004b1021, 0x944c0000, 0x3c020001,
+	0x94420fa2, 0x3183ffff, 0x3c040001, 0x90840f9b, 0x00431021, 0x00e21021,
+	0x00442023, 0x008a2021, 0x00041c02, 0x3082ffff, 0x00622021, 0x00041402,
+	0x00822021, 0x00806821, 0x00041027, 0xa4c20010, 0x31a2ffff, 0x000e1c00,
+	0x00431025, 0x3c040001, 0x24840f92, 0xade20010, 0x94820000, 0x3c050001,
+	0x94a50f96, 0x3c030001, 0x8c630f8c, 0x24420001, 0x00b92821, 0xa4820000,
+	0x3322ffff, 0x00622021, 0x0083182b, 0x3c010001, 0xa4250f96, 0x10600003,
+	0x24a2ffff, 0x3c010001, 0xa4220f96, 0x3c024000, 0x03021025, 0x3c010001,
+	0xac240f8c, 0xaf621008, 0x03e00008, 0x27bd0010, 0x3c030001, 0x90630f76,
+	0x27bdffe8, 0x24020001, 0xafbf0014, 0x10620026, 0xafb00010, 0x8f620cf4,
+	0x2442ffff, 0x3042007f, 0x00021100, 0x8c434000, 0x3c010001, 0xac230f84,
+	0x8c434008, 0x24444000, 0x8c5c4004, 0x30620040, 0x14400002, 0x24020088,
+	0x24020008, 0x3c010001, 0xa4220f88, 0x30620004, 0x10400005, 0x24020001,
+	0x3c010001, 0xa0220f77, 0x080041d5, 0x00031402, 0x3c010001, 0xa0200f77,
+	0x00031402, 0x3c010001, 0xa4220f74, 0x9483000c, 0x24020001, 0x3c010001,
+	0xa4200f70, 0x3c010001, 0xa0220f76, 0x3c010001, 0xa4230f82, 0x24020001,
+	0x1342001e, 0x00000000, 0x13400005, 0x24020003, 0x13420067, 0x00000000,
+	0x080042cf, 0x00000000, 0x3c020001, 0x94420f82, 0x241a0001, 0x3c010001,
+	0xa4200f7e, 0x3c010001, 0xa4200f72, 0x304407ff, 0x00021bc2, 0x00031823,
+	0x3063003e, 0x34630036, 0x00021242, 0x3042003c, 0x00621821, 0x3c010001,
+	0xa4240f78, 0x00832021, 0x24630030, 0x3c010001, 0xa4240f7a, 0x3c010001,
+	0xa4230f7c, 0x3c060001, 0x24c60f72, 0x94c50000, 0x94c30002, 0x3c040001,
+	0x94840f7a, 0x00651021, 0x0044102a, 0x10400013, 0x3c108000, 0x00a31021,
+	0xa4c20000, 0x3c02a000, 0xaf620cf4, 0x3c010001, 0xa0200f76, 0x8f641008,
+	0x00901024, 0x14400003, 0x00000000, 0x0c004064, 0x00000000, 0x8f620cf4,
+	0x00501024, 0x104000b7, 0x00000000, 0x0800420f, 0x00000000, 0x3c030001,
+	0x94630f70, 0x00851023, 0xa4c40000, 0x00621821, 0x3042ffff, 0x3c010001,
+	0xa4230f70, 0xaf620ce8, 0x3c020001, 0x94420f88, 0x34420024, 0xaf620cec,
+	0x94c30002, 0x3c020001, 0x94420f70, 0x14620012, 0x3c028000, 0x3c108000,
+	0x3c02a000, 0xaf620cf4, 0x3c010001, 0xa0200f76, 0x8f641008, 0x00901024,
+	0x14400003, 0x00000000, 0x0c004064, 0x00000000, 0x8f620cf4, 0x00501024,
+	0x1440fff7, 0x00000000, 0x080042cf, 0x241a0003, 0xaf620cf4, 0x3c108000,
+	0x8f641008, 0x00901024, 0x14400003, 0x00000000, 0x0c004064, 0x00000000,
+	0x8f620cf4, 0x00501024, 0x1440fff7, 0x00000000, 0x080042cf, 0x241a0003,
+	0x3c070001, 0x24e70f70, 0x94e20000, 0x03821021, 0xaf620ce0, 0x3c020001,
+	0x8c420f84, 0xaf620ce4, 0x3c050001, 0x94a50f74, 0x94e30000, 0x3c040001,
+	0x94840f78, 0x3c020001, 0x94420f7e, 0x00a32823, 0x00822023, 0x30a6ffff,
+	0x3083ffff, 0x00c3102b, 0x14400043, 0x00000000, 0x3c020001, 0x94420f7c,
+	0x00021400, 0x00621025, 0xaf620ce8, 0x94e20000, 0x3c030001, 0x94630f74,
+	0x00441021, 0xa4e20000, 0x3042ffff, 0x14430021, 0x3c020008, 0x3c020001,
+	0x90420f77, 0x10400006, 0x3c03000c, 0x3c020001, 0x94420f88, 0x34630624,
+	0x0800427c, 0x0000d021, 0x3c020001, 0x94420f88, 0x3c030008, 0x34630624,
+	0x00431025, 0xaf620cec, 0x3c108000, 0x3c02a000, 0xaf620cf4, 0x3c010001,
+	0xa0200f76, 0x8f641008, 0x00901024, 0x14400003, 0x00000000, 0x0c004064,
+	0x00000000, 0x8f620cf4, 0x00501024, 0x10400015, 0x00000000, 0x08004283,
+	0x00000000, 0x3c030001, 0x94630f88, 0x34420624, 0x3c108000, 0x00621825,
+	0x3c028000, 0xaf630cec, 0xaf620cf4, 0x8f641008, 0x00901024, 0x14400003,
+	0x00000000, 0x0c004064, 0x00000000, 0x8f620cf4, 0x00501024, 0x1440fff7,
+	0x00000000, 0x3c010001, 0x080042cf, 0xa4200f7e, 0x3c020001, 0x94420f7c,
+	0x00021400, 0x00c21025, 0xaf620ce8, 0x3c020001, 0x90420f77, 0x10400009,
+	0x3c03000c, 0x3c020001, 0x94420f88, 0x34630624, 0x0000d021, 0x00431025,
+	0xaf620cec, 0x080042c1, 0x3c108000, 0x3c020001, 0x94420f88, 0x3c030008,
+	0x34630604, 0x00431025, 0xaf620cec, 0x3c020001, 0x94420f7e, 0x00451021,
+	0x3c010001, 0xa4220f7e, 0x3c108000, 0x3c02a000, 0xaf620cf4, 0x3c010001,
+	0xa0200f76, 0x8f641008, 0x00901024, 0x14400003, 0x00000000, 0x0c004064,
+	0x00000000, 0x8f620cf4, 0x00501024, 0x1440fff7, 0x00000000, 0x8fbf0014,
+	0x8fb00010, 0x03e00008, 0x27bd0018, 0x27bdffe0, 0x3c040001, 0x24840ee0,
+	0x00002821, 0x00003021, 0x00003821, 0xafbf0018, 0xafa00010, 0x0c004380,
+	0xafa00014, 0x0000d021, 0x24020130, 0xaf625000, 0x3c010001, 0xa4200f70,
+	0x3c010001, 0xa0200f77, 0x8f636804, 0x3c020001, 0x3442e000, 0x00621824,
+	0x3c020001, 0x14620003, 0x00000000, 0x080042eb, 0x00000000, 0x8fbf0018,
+	0x03e00008, 0x27bd0020, 0x27bdffe8, 0x3c1bc000, 0xafbf0014, 0xafb00010,
+	0xaf60680c, 0x8f626804, 0x34420082, 0xaf626804, 0x8f634000, 0x24020b50,
+	0x3c010001, 0xac220f40, 0x24020b78, 0x3c010001, 0xac220f50, 0x34630002,
+	0xaf634000, 0x0c00431d, 0x00808021, 0x3c010001, 0xa0220f54, 0x304200ff,
+	0x24030002, 0x14430005, 0x00000000, 0x3c020001, 0x8c420f40, 0x08004310,
+	0xac5000c0, 0x3c020001, 0x8c420f40, 0xac5000bc, 0x8f624434, 0x8f634438,
+	0x8f644410, 0x3c010001, 0xac220f48, 0x3c010001, 0xac230f58, 0x3c010001,
+	0xac240f44, 0x8fbf0014, 0x8fb00010, 0x03e00008, 0x27bd0018, 0x03e00008,
+	0x24020001, 0x27bdfff8, 0x18800009, 0x00002821, 0x8f63680c, 0x8f62680c,
+	0x1043fffe, 0x00000000, 0x24a50001, 0x00a4102a, 0x1440fff9, 0x00000000,
+	0x03e00008, 0x27bd0008, 0x8f634450, 0x3c020001, 0x8c420f48, 0x00031c02,
+	0x0043102b, 0x14400008, 0x3c038000, 0x3c040001, 0x8c840f58, 0x8f624450,
+	0x00021c02, 0x0083102b, 0x1040fffc, 0x3c038000, 0xaf634444, 0x8f624444,
+	0x00431024, 0x1440fffd, 0x00000000, 0x8f624448, 0x03e00008, 0x3042ffff,
+	0x3082ffff, 0x2442e000, 0x2c422001, 0x14400003, 0x3c024000, 0x0800434f,
+	0x2402ffff, 0x00822025, 0xaf645c38, 0x8f625c30, 0x30420002, 0x1440fffc,
+	0x00001021, 0x03e00008, 0x00000000, 0x8f624450, 0x3c030001, 0x8c630f44,
+	0x08004358, 0x3042ffff, 0x8f624450, 0x3042ffff, 0x0043102b, 0x1440fffc,
+	0x00000000, 0x03e00008, 0x00000000, 0x27bdffe0, 0x00802821, 0x3c040001,
+	0x24840ef0, 0x00003021, 0x00003821, 0xafbf0018, 0xafa00010, 0x0c004380,
+	0xafa00014, 0x08004367, 0x00000000, 0x8fbf0018, 0x03e00008, 0x27bd0020,
+	0x3c020001, 0x3442d600, 0x3c030001, 0x3463d600, 0x3c040001, 0x3484ddff,
+	0x3c010001, 0xac220f60, 0x24020040, 0x3c010001, 0xac220f64, 0x3c010001,
+	0xac200f5c, 0xac600000, 0x24630004, 0x0083102b, 0x5040fffd, 0xac600000,
+	0x03e00008, 0x00000000, 0x00804821, 0x8faa0010, 0x3c020001, 0x8c420f5c,
+	0x3c040001, 0x8c840f64, 0x8fab0014, 0x24430001, 0x0044102b, 0x3c010001,
+	0xac230f5c, 0x14400003, 0x00004021, 0x3c010001, 0xac200f5c, 0x3c020001,
+	0x8c420f5c, 0x3c030001, 0x8c630f60, 0x91240000, 0x00021140, 0x00431021,
+	0x00481021, 0x25080001, 0xa0440000, 0x29020008, 0x1440fff4, 0x25290001,
+	0x3c020001, 0x8c420f5c, 0x3c030001, 0x8c630f60, 0x8f64680c, 0x00021140,
+	0x00431021, 0xac440008, 0xac45000c, 0xac460010, 0xac470014, 0xac4a0018,
+	0x03e00008, 0xac4b001c, 0x00000000, 0x00000000,
+};
+
+u32 tg3Tso5FwRodata[] = {
+	0x4d61696e, 0x43707542, 0x00000000, 0x4d61696e, 0x43707541, 0x00000000,
+	0x00000000, 0x00000000, 0x73746b6f, 0x66666c64, 0x00000000, 0x00000000,
+	0x73746b6f, 0x66666c64, 0x00000000, 0x00000000, 0x66617461, 0x6c457272,
+	0x00000000, 0x00000000, 0x00000000
+};
+
+u32 tg3Tso5FwData[] = {
+	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x73746b6f, 
+	0x66666c64, 0x5f76312e, 0x312e3000, 0x00000000
+};
+
 /* tp->lock is held. */
 static int tg3_load_tso_firmware(struct tg3 *tp)
 {
 	struct fw_info info;
+	unsigned long cpu_base, cpu_scratch_base, cpu_scratch_size;
 	int err, i;
 
-	info.text_base = TG3_TSO_FW_TEXT_ADDR;
-	info.text_len = TG3_TSO_FW_TEXT_LEN;
-	info.text_data = &tg3TsoFwText[0];
-	info.rodata_base = TG3_TSO_FW_RODATA_ADDR;
-	info.rodata_len = TG3_TSO_FW_RODATA_LEN;
-	info.rodata_data = &tg3TsoFwRodata[0];
-	info.data_base = TG3_TSO_FW_DATA_ADDR;
-	info.data_len = TG3_TSO_FW_DATA_LEN;
-	info.data_data = NULL;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+		info.text_base = TG3_TSO5_FW_TEXT_ADDR;
+		info.text_len = TG3_TSO5_FW_TEXT_LEN;
+		info.text_data = &tg3Tso5FwText[0];
+		info.rodata_base = TG3_TSO5_FW_RODATA_ADDR;
+		info.rodata_len = TG3_TSO5_FW_RODATA_LEN;
+		info.rodata_data = &tg3Tso5FwRodata[0];
+		info.data_base = TG3_TSO5_FW_DATA_ADDR;
+		info.data_len = TG3_TSO5_FW_DATA_LEN;
+		info.data_data = &tg3Tso5FwData[0];
+		cpu_base = RX_CPU_BASE;
+		cpu_scratch_base = NIC_SRAM_MBUF_POOL_BASE5705;
+		cpu_scratch_size = (info.text_len +
+				    info.rodata_len +
+				    info.data_len +
+				    TG3_TSO5_FW_SBSS_LEN +
+				    TG3_TSO5_FW_BSS_LEN);
+	} else {
+		info.text_base = TG3_TSO_FW_TEXT_ADDR;
+		info.text_len = TG3_TSO_FW_TEXT_LEN;
+		info.text_data = &tg3TsoFwText[0];
+		info.rodata_base = TG3_TSO_FW_RODATA_ADDR;
+		info.rodata_len = TG3_TSO_FW_RODATA_LEN;
+		info.rodata_data = &tg3TsoFwRodata[0];
+		info.data_base = TG3_TSO_FW_DATA_ADDR;
+		info.data_len = TG3_TSO_FW_DATA_LEN;
+		info.data_data = NULL;
+		cpu_base = TX_CPU_BASE;
+		cpu_scratch_base = TX_CPU_SCRATCH_BASE;
+		cpu_scratch_size = TX_CPU_SCRATCH_SIZE;
+	}
 
-	err = tg3_load_firmware_cpu(tp, TX_CPU_BASE,
-				    TX_CPU_SCRATCH_BASE, TX_CPU_SCRATCH_SIZE,
+	err = tg3_load_firmware_cpu(tp, cpu_base,
+				    cpu_scratch_base, cpu_scratch_size,
 				    &info);
 	if (err)
 		return err;
 
-	/* Now startup only the TX cpu. */
-	tw32(TX_CPU_BASE + CPU_STATE, 0xffffffff);
-	tw32(TX_CPU_BASE + CPU_PC,    TG3_TSO_FW_TEXT_ADDR);
+	/* Now startup the cpu. */
+	tw32(cpu_base + CPU_STATE, 0xffffffff);
+	tw32(cpu_base + CPU_PC,    info.text_base);
 
 	/* Flush posted writes. */
-	tr32(TX_CPU_BASE + CPU_PC);
+	tr32(cpu_base + CPU_PC);
 	for (i = 0; i < 5; i++) {
-		if (tr32(TX_CPU_BASE + CPU_PC) == TG3_TSO_FW_TEXT_ADDR)
+		if (tr32(cpu_base + CPU_PC) == info.text_base)
 			break;
-		tw32(TX_CPU_BASE + CPU_STATE, 0xffffffff);
-		tw32(TX_CPU_BASE + CPU_MODE,  CPU_MODE_HALT);
-		tw32(TX_CPU_BASE + CPU_PC,    TG3_TSO_FW_TEXT_ADDR);
+		tw32(cpu_base + CPU_STATE, 0xffffffff);
+		tw32(cpu_base + CPU_MODE,  CPU_MODE_HALT);
+		tw32(cpu_base + CPU_PC,    info.text_base);
 
 		/* Flush posted writes. */
-		tr32(TX_CPU_BASE + CPU_PC);
+		tr32(cpu_base + CPU_PC);
 
 		udelay(1000);
 	}
 	if (i >= 5) {
 		printk(KERN_ERR PFX "tg3_load_tso_firmware fails for %s "
-		       "to set TX CPU PC, is %08x should be %08x\n",
-		       tp->dev->name, tr32(TX_CPU_BASE + CPU_PC),
-		       TG3_TSO_FW_TEXT_ADDR);
+		       "to set CPU PC, is %08x should be %08x\n",
+		       tp->dev->name, tr32(cpu_base + CPU_PC),
+		       info.text_base);
 		return -ENODEV;
 	}
-	tw32(TX_CPU_BASE + CPU_STATE, 0xffffffff);
-	tw32(TX_CPU_BASE + CPU_MODE,  0x00000000);
+	tw32(cpu_base + CPU_STATE, 0xffffffff);
+	tw32(cpu_base + CPU_MODE,  0x00000000);
 
 	/* Flush posted writes. */
-	tr32(TX_CPU_BASE + CPU_MODE);
+	tr32(cpu_base + CPU_MODE);
 
 	return 0;
 }
 
-#endif /* TG3_DO_TSO != 0 */
+#endif /* TG3_TSO_SUPPORT != 0 */
 
 /* tp->lock is held. */
 static void __tg3_set_mac_addr(struct tg3 *tp)
@@ -3860,6 +4492,15 @@
 		tw32(MAC_ADDR_0_LOW + (i * 8), addr_low);
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705) {
+		for (i = 0; i < 12; i++) {
+			tw32(MAC_EXTADDR_0_HIGH + (i * 8), addr_high);
+			tw32(MAC_EXTADDR_0_LOW + (i * 8), addr_low);
+		}
+	}
+
 	addr_high = (tp->dev->dev_addr[0] +
 		     tp->dev->dev_addr[1] +
 		     tp->dev->dev_addr[2] +
@@ -3893,23 +4534,19 @@
 			   u32 nic_addr)
 {
 	tg3_write_mem(tp,
-		      (bdinfo_addr +
-		       TG3_BDINFO_HOST_ADDR +
-		       TG3_64BIT_REG_HIGH),
+		      (bdinfo_addr + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_HIGH),
 		      ((u64) mapping >> 32));
 	tg3_write_mem(tp,
-		      (bdinfo_addr +
-		       TG3_BDINFO_HOST_ADDR +
-		       TG3_64BIT_REG_LOW),
+		      (bdinfo_addr + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW),
 		      ((u64) mapping & 0xffffffff));
 	tg3_write_mem(tp,
-		      (bdinfo_addr +
-		       TG3_BDINFO_MAXLEN_FLAGS),
+		      (bdinfo_addr + TG3_BDINFO_MAXLEN_FLAGS),
 		       maxlen_flags);
-	tg3_write_mem(tp,
-		      (bdinfo_addr +
-		       TG3_BDINFO_NIC_ADDR),
-		      nic_addr);
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705)
+		tg3_write_mem(tp,
+			      (bdinfo_addr + TG3_BDINFO_NIC_ADDR),
+			      nic_addr);
 }
 
 static void __tg3_set_rx_mode(struct net_device *);
@@ -3917,8 +4554,8 @@
 /* tp->lock is held. */
 static int tg3_reset_hw(struct tg3 *tp)
 {
-	u32 val;
-	int i, err;
+	u32 val, rdmac_mode;
+	int i, err, limit;
 
 	tg3_disable_ints(tp);
 
@@ -3970,9 +4607,8 @@
 	 * B3 tigon3 silicon.  This bit has no effect on any
 	 * other revision.
 	 */
-	val = tr32(TG3PCI_CLOCK_CTRL);
-	val |= CLOCK_CTRL_DELAY_PCI_GRANT;
-	tw32(TG3PCI_CLOCK_CTRL, val);
+	tp->pci_clock_ctrl |= CLOCK_CTRL_DELAY_PCI_GRANT;
+	tw32(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl);
 	tr32(TG3PCI_CLOCK_CTRL);
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0 &&
@@ -3990,11 +4626,13 @@
 	tg3_init_rings(tp);
 
 	/* Clear statistics/status block in chip, and status block in ram. */
-	for (i = NIC_SRAM_STATS_BLK;
-	     i < NIC_SRAM_STATUS_BLK + TG3_HW_STATUS_SIZE;
-	     i += sizeof(u32)) {
-		tg3_write_mem(tp, i, 0);
-		udelay(40);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705) {
+		for (i = NIC_SRAM_STATS_BLK;
+	     	     i < NIC_SRAM_STATUS_BLK + TG3_HW_STATUS_SIZE;
+	     	     i += sizeof(u32)) {
+			tg3_write_mem(tp, i, 0);
+			udelay(40);
+		}
 	}
 	memset(tp->hw_status, 0, TG3_HW_STATUS_SIZE);
 
@@ -4025,13 +4663,31 @@
 	     (65 << GRC_MISC_CFG_PRESCALAR_SHIFT));
 
 	/* Initialize MBUF/DESC pool. */
-	tw32(BUFMGR_MB_POOL_ADDR, NIC_SRAM_MBUF_POOL_BASE);
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704)
-		tw32(BUFMGR_MB_POOL_SIZE, NIC_SRAM_MBUF_POOL_SIZE64);
-	else
-		tw32(BUFMGR_MB_POOL_SIZE, NIC_SRAM_MBUF_POOL_SIZE96);
-	tw32(BUFMGR_DMA_DESC_POOL_ADDR, NIC_SRAM_DMA_DESC_POOL_BASE);
-	tw32(BUFMGR_DMA_DESC_POOL_SIZE, NIC_SRAM_DMA_DESC_POOL_SIZE);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705) {
+		tw32(BUFMGR_MB_POOL_ADDR, NIC_SRAM_MBUF_POOL_BASE);
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704)
+			tw32(BUFMGR_MB_POOL_SIZE, NIC_SRAM_MBUF_POOL_SIZE64);
+		else
+			tw32(BUFMGR_MB_POOL_SIZE, NIC_SRAM_MBUF_POOL_SIZE96);
+		tw32(BUFMGR_DMA_DESC_POOL_ADDR, NIC_SRAM_DMA_DESC_POOL_BASE);
+		tw32(BUFMGR_DMA_DESC_POOL_SIZE, NIC_SRAM_DMA_DESC_POOL_SIZE);
+	}
+#if TG3_TSO_SUPPORT != 0
+	else if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
+		int fw_len;
+
+		fw_len = (TG3_TSO5_FW_TEXT_LEN +
+			  TG3_TSO5_FW_RODATA_LEN +
+			  TG3_TSO5_FW_DATA_LEN +
+			  TG3_TSO5_FW_SBSS_LEN +
+			  TG3_TSO5_FW_BSS_LEN);
+		fw_len = (fw_len + (0x80 - 1)) & ~(0x80 - 1);
+		tw32(BUFMGR_MB_POOL_ADDR,
+		     NIC_SRAM_MBUF_POOL_BASE5705 + fw_len);
+		tw32(BUFMGR_MB_POOL_SIZE,
+		     NIC_SRAM_MBUF_POOL_SIZE5705 - fw_len - 0xa00);
+	}
+#endif
 
 	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_ENABLE)) {
 		tw32(BUFMGR_MB_RDMA_LOW_WATER,
@@ -4078,6 +4734,9 @@
 		return -ENODEV;
 	}
 
+	/* Setup replenish threshold. */
+	tw32(RCVBDI_STD_THRESH, tp->rx_pending / 8);
+
 	/* Initialize TG3_BDINFO's at:
 	 *  RCVDBDI_STD_BD:	standard eth size rx ring
 	 *  RCVDBDI_JUMBO_BD:	jumbo frame rx ring
@@ -4099,35 +4758,50 @@
 	     ((u64) tp->rx_std_mapping >> 32));
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
 	     ((u64) tp->rx_std_mapping & 0xffffffff));
-	tw32(RCVDBDI_STD_BD + TG3_BDINFO_MAXLEN_FLAGS,
-	     RX_STD_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT);
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_NIC_ADDR,
 	     NIC_SRAM_RX_BUFFER_DESC);
 
-	tw32(RCVDBDI_MINI_BD + TG3_BDINFO_MAXLEN_FLAGS,
-	     BDINFO_FLAGS_DISABLED);
-
-	if (tp->tg3_flags & TG3_FLAG_JUMBO_ENABLE) {
-		tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_HIGH,
-		     ((u64) tp->rx_jumbo_mapping >> 32));
-		tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
-		     ((u64) tp->rx_jumbo_mapping & 0xffffffff));
-		tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
-		     RX_JUMBO_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT);
-		tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_NIC_ADDR,
-		     NIC_SRAM_RX_JUMBO_BUFFER_DESC);
+	/* Don't even try to program the JUMBO/MINI buffer descriptor
+	 * configs on 5705.
+	 */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+		tw32(RCVDBDI_STD_BD + TG3_BDINFO_MAXLEN_FLAGS,
+		     RX_STD_MAX_SIZE_5705 << BDINFO_FLAGS_MAXLEN_SHIFT);
 	} else {
-		tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
+		tw32(RCVDBDI_STD_BD + TG3_BDINFO_MAXLEN_FLAGS,
+		     RX_STD_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT);
+
+		tw32(RCVDBDI_MINI_BD + TG3_BDINFO_MAXLEN_FLAGS,
 		     BDINFO_FLAGS_DISABLED);
-	}
 
-	/* Setup replenish thresholds. */
-	tw32(RCVBDI_STD_THRESH, tp->rx_pending / 8);
-	tw32(RCVBDI_JUMBO_THRESH, tp->rx_jumbo_pending / 8);
+		/* Setup replenish threshold. */
+		tw32(RCVBDI_JUMBO_THRESH, tp->rx_jumbo_pending / 8);
+
+		if (tp->tg3_flags & TG3_FLAG_JUMBO_ENABLE) {
+			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_HIGH,
+			     ((u64) tp->rx_jumbo_mapping >> 32));
+			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
+			     ((u64) tp->rx_jumbo_mapping & 0xffffffff));
+			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
+			     RX_JUMBO_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT);
+			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_NIC_ADDR,
+			     NIC_SRAM_RX_JUMBO_BUFFER_DESC);
+		} else {
+			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
+			     BDINFO_FLAGS_DISABLED);
+		}
 
-	/* Clear out send RCB ring in SRAM. */
-	for (i = NIC_SRAM_SEND_RCB; i < NIC_SRAM_RCV_RET_RCB; i += TG3_BDINFO_SIZE)
-		tg3_write_mem(tp, i + TG3_BDINFO_MAXLEN_FLAGS, BDINFO_FLAGS_DISABLED);
+	}
+
+	/* There is only one send ring on 5705, no need to explicitly
+	 * disable the others.
+	 */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705) {
+		/* Clear out send RCB ring in SRAM. */
+		for (i = NIC_SRAM_SEND_RCB; i < NIC_SRAM_RCV_RET_RCB; i += TG3_BDINFO_SIZE)
+			tg3_write_mem(tp, i + TG3_BDINFO_MAXLEN_FLAGS,
+				      BDINFO_FLAGS_DISABLED);
+	}
 
 	tp->tx_prod = 0;
 	tp->tx_cons = 0;
@@ -4149,9 +4823,15 @@
 			       NIC_SRAM_TX_BUFFER_DESC);
 	}
 
-	for (i = NIC_SRAM_RCV_RET_RCB; i < NIC_SRAM_STATS_BLK; i += TG3_BDINFO_SIZE) {
-		tg3_write_mem(tp, i + TG3_BDINFO_MAXLEN_FLAGS,
-			      BDINFO_FLAGS_DISABLED);
+	/* There is only one receive return ring on 5705, no need to explicitly
+	 * disable the others.
+	 */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705) {
+		for (i = NIC_SRAM_RCV_RET_RCB; i < NIC_SRAM_STATS_BLK;
+		     i += TG3_BDINFO_SIZE) {
+			tg3_write_mem(tp, i + TG3_BDINFO_MAXLEN_FLAGS,
+				      BDINFO_FLAGS_DISABLED);
+		}
 	}
 
 	tp->rx_rcb_ptr = 0;
@@ -4161,7 +4841,7 @@
 
 	tg3_set_bdinfo(tp, NIC_SRAM_RCV_RET_RCB,
 		       tp->rx_rcb_mapping,
-		       (TG3_RX_RCB_RING_SIZE <<
+		       (TG3_RX_RCB_RING_SIZE(tp) <<
 			BDINFO_FLAGS_MAXLEN_SHIFT),
 		       0);
 
@@ -4198,8 +4878,36 @@
 	tw32(MAC_RCV_RULE_CFG, RCV_RULE_CFG_DEFAULT_CLASS);
 	tw32(RCVLPC_CONFIG, 0x0181);
 
+	/* Calculate RDMAC_MODE setting early, we need it to determine
+	 * the RCVLPC_STATE_ENABLE mask.
+	 */
+	rdmac_mode = (RDMAC_MODE_ENABLE | RDMAC_MODE_TGTABORT_ENAB |
+		      RDMAC_MODE_MSTABORT_ENAB | RDMAC_MODE_PARITYERR_ENAB |
+		      RDMAC_MODE_ADDROFLOW_ENAB | RDMAC_MODE_FIFOOFLOW_ENAB |
+		      RDMAC_MODE_FIFOURUN_ENAB | RDMAC_MODE_FIFOOREAD_ENAB |
+		      RDMAC_MODE_LNGREAD_ENAB);
+	if (tp->tg3_flags & TG3_FLAG_SPLIT_MODE)
+		rdmac_mode |= RDMAC_MODE_SPLIT_ENABLE;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+		if (tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) {
+			if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
+				rdmac_mode |= RDMAC_MODE_FIFO_SIZE_128;
+			} else if (!(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH) &&
+				   !(tp->tg3_flags2 & TG3_FLG2_IS_5788)) {
+				rdmac_mode |= RDMAC_MODE_FIFO_LONG_BURST;
+			}
+		}
+	}
+
 	/* Receive/send statistics. */
-	tw32(RCVLPC_STATS_ENABLE, 0xffffff);
+	if ((rdmac_mode & RDMAC_MODE_FIFO_SIZE_128) &&
+	    (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)) {
+		val = tr32(RCVLPC_STATS_ENABLE);
+		val &= ~RCVLPC_STATSENAB_LNGBRST_RFIX;
+		tw32(RCVLPC_STATS_ENABLE, val);
+	} else {
+		tw32(RCVLPC_STATS_ENABLE, 0xffffff);
+	}
 	tw32(RCVLPC_STATSCTRL, RCVLPC_STATSCTRL_ENABLE);
 	tw32(SNDDATAI_STATSENAB, 0xffffff);
 	tw32(SNDDATAI_STATSCTRL,
@@ -4215,33 +4923,43 @@
 	}
 
 	tw32(HOSTCC_RXCOL_TICKS, 0);
-	tw32(HOSTCC_RXMAX_FRAMES, 1);
-	tw32(HOSTCC_RXCOAL_TICK_INT, 0);
-	tw32(HOSTCC_RXCOAL_MAXF_INT, 1);
 	tw32(HOSTCC_TXCOL_TICKS, LOW_TXCOL_TICKS);
+	tw32(HOSTCC_RXMAX_FRAMES, 1);
 	tw32(HOSTCC_TXMAX_FRAMES, LOW_RXMAX_FRAMES);
-	tw32(HOSTCC_TXCOAL_TICK_INT, 0);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705)
+		tw32(HOSTCC_RXCOAL_TICK_INT, 0);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705)
+		tw32(HOSTCC_TXCOAL_TICK_INT, 0);
+	tw32(HOSTCC_RXCOAL_MAXF_INT, 1);
 	tw32(HOSTCC_TXCOAL_MAXF_INT, 0);
-	tw32(HOSTCC_STAT_COAL_TICKS,
-	     DEFAULT_STAT_COAL_TICKS);
 
-	/* Status/statistics block address. */
-	tw32(HOSTCC_STATS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
-	     ((u64) tp->stats_mapping >> 32));
-	tw32(HOSTCC_STATS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW,
-	     ((u64) tp->stats_mapping & 0xffffffff));
+	/* set status block DMA address */
 	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
 	     ((u64) tp->status_mapping >> 32));
 	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW,
 	     ((u64) tp->status_mapping & 0xffffffff));
-	tw32(HOSTCC_STATS_BLK_NIC_ADDR, NIC_SRAM_STATS_BLK);
-	tw32(HOSTCC_STATUS_BLK_NIC_ADDR, NIC_SRAM_STATUS_BLK);
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705) {
+		/* Status/statistics block address.  See tg3_timer,
+		 * the tg3_periodic_fetch_stats call there, and
+		 * tg3_get_stats to see how this works for 5705 chips.
+		 */
+		tw32(HOSTCC_STAT_COAL_TICKS,
+		     DEFAULT_STAT_COAL_TICKS);
+		tw32(HOSTCC_STATS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
+		     ((u64) tp->stats_mapping >> 32));
+		tw32(HOSTCC_STATS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW,
+		     ((u64) tp->stats_mapping & 0xffffffff));
+		tw32(HOSTCC_STATS_BLK_NIC_ADDR, NIC_SRAM_STATS_BLK);
+		tw32(HOSTCC_STATUS_BLK_NIC_ADDR, NIC_SRAM_STATUS_BLK);
+	}
 
 	tw32(HOSTCC_MODE, HOSTCC_MODE_ENABLE | tp->coalesce_mode);
 
 	tw32(RCVCC_MODE, RCVCC_MODE_ENABLE | RCVCC_MODE_ATTN_ENABLE);
 	tw32(RCVLPC_MODE, RCVLPC_MODE_ENABLE);
-	tw32(RCVLSC_MODE, RCVLSC_MODE_ENABLE | RCVLSC_MODE_ATTN_ENABLE);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705)
+		tw32(RCVLSC_MODE, RCVLSC_MODE_ENABLE | RCVLSC_MODE_ATTN_ENABLE);
 
 	tp->mac_mode = MAC_MODE_TXSTAT_ENABLE | MAC_MODE_RXSTAT_ENABLE |
 		MAC_MODE_TDE_ENABLE | MAC_MODE_RDE_ENABLE | MAC_MODE_FHDE_ENABLE;
@@ -4260,42 +4978,47 @@
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0);
 	tr32(MAILBOX_INTERRUPT_0);
 
-	tw32(DMAC_MODE, DMAC_MODE_ENABLE);
-	tr32(DMAC_MODE);
-	udelay(40);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705) {
+		tw32(DMAC_MODE, DMAC_MODE_ENABLE);
+		tr32(DMAC_MODE);
+		udelay(40);
+	}
 
-	tw32(WDMAC_MODE, (WDMAC_MODE_ENABLE | WDMAC_MODE_TGTABORT_ENAB |
-			  WDMAC_MODE_MSTABORT_ENAB | WDMAC_MODE_PARITYERR_ENAB |
-			  WDMAC_MODE_ADDROFLOW_ENAB | WDMAC_MODE_FIFOOFLOW_ENAB |
-			  WDMAC_MODE_FIFOURUN_ENAB | WDMAC_MODE_FIFOOREAD_ENAB |
-			  WDMAC_MODE_LNGREAD_ENAB));
+	val = (WDMAC_MODE_ENABLE | WDMAC_MODE_TGTABORT_ENAB |
+	       WDMAC_MODE_MSTABORT_ENAB | WDMAC_MODE_PARITYERR_ENAB |
+	       WDMAC_MODE_ADDROFLOW_ENAB | WDMAC_MODE_FIFOOFLOW_ENAB |
+	       WDMAC_MODE_FIFOURUN_ENAB | WDMAC_MODE_FIFOOREAD_ENAB |
+	       WDMAC_MODE_LNGREAD_ENAB);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
+	    (tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH) != 0 &&
+	    !(tp->tg3_flags2 & TG3_FLG2_IS_5788))
+		val |= WDMAC_MODE_RX_ACCEL;
+	tw32(WDMAC_MODE, val);
 	tr32(WDMAC_MODE);
 	udelay(40);
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 &&
-	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE)) {
+	if ((tp->tg3_flags & TG3_FLAG_PCIX_MODE) != 0) {
 		val = tr32(TG3PCI_X_CAPS);
-		val &= ~(PCIX_CAPS_SPLIT_MASK | PCIX_CAPS_BURST_MASK);
-		val |= (PCIX_CAPS_MAX_BURST_5704 << PCIX_CAPS_BURST_SHIFT);
-		if (tp->tg3_flags & TG3_FLAG_SPLIT_MODE)
-			val |= (tp->split_mode_max_reqs <<
-				PCIX_CAPS_SPLIT_SHIFT);
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703) {
+			val &= ~PCIX_CAPS_BURST_MASK;
+			val |= (PCIX_CAPS_MAX_BURST_CPIOB << PCIX_CAPS_BURST_SHIFT);
+		} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
+			val &= ~(PCIX_CAPS_SPLIT_MASK | PCIX_CAPS_BURST_MASK);
+			val |= (PCIX_CAPS_MAX_BURST_CPIOB << PCIX_CAPS_BURST_SHIFT);
+			if (tp->tg3_flags & TG3_FLAG_SPLIT_MODE)
+				val |= (tp->split_mode_max_reqs <<
+					PCIX_CAPS_SPLIT_SHIFT);
+		}
 		tw32(TG3PCI_X_CAPS, val);
 	}
 
-	val = (RDMAC_MODE_ENABLE | RDMAC_MODE_TGTABORT_ENAB |
-	       RDMAC_MODE_MSTABORT_ENAB | RDMAC_MODE_PARITYERR_ENAB |
-	       RDMAC_MODE_ADDROFLOW_ENAB | RDMAC_MODE_FIFOOFLOW_ENAB |
-	       RDMAC_MODE_FIFOURUN_ENAB | RDMAC_MODE_FIFOOREAD_ENAB |
-	       RDMAC_MODE_LNGREAD_ENAB);
-	if (tp->tg3_flags & TG3_FLAG_SPLIT_MODE)
-		val |= RDMAC_MODE_SPLIT_ENABLE;
-	tw32(RDMAC_MODE, val);
+	tw32(RDMAC_MODE, rdmac_mode);
 	tr32(RDMAC_MODE);
 	udelay(40);
 
 	tw32(RCVDCC_MODE, RCVDCC_MODE_ENABLE | RCVDCC_MODE_ATTN_ENABLE);
-	tw32(MBFREE_MODE, MBFREE_MODE_ENABLE);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705)
+		tw32(MBFREE_MODE, MBFREE_MODE_ENABLE);
 	tw32(SNDDATAC_MODE, SNDDATAC_MODE_ENABLE);
 	tw32(SNDBDC_MODE, SNDBDC_MODE_ENABLE | SNDBDC_MODE_ATTN_ENABLE);
 	tw32(RCVBDI_MODE, RCVBDI_MODE_ENABLE | RCVBDI_MODE_RCB_ATTN_ENAB);
@@ -4310,8 +5033,8 @@
 			return err;
 	}
 
-#if TG3_DO_TSO != 0
-	if (tp->dev->features & NETIF_F_TSO) {
+#if TG3_TSO_SUPPORT != 0
+	if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
 		err = tg3_load_tso_firmware(tp);
 		if (err)
 			return err;
@@ -4342,9 +5065,11 @@
 
 	tw32(MAC_LED_CTRL, 0);
 	tw32(MAC_MI_STAT, MAC_MI_STAT_LNKSTAT_ATTN_ENAB);
-	tw32(MAC_RX_MODE, RX_MODE_RESET);
-	tr32(MAC_RX_MODE);
-	udelay(10);
+	if (tp->phy_id == PHY_ID_SERDES) {
+		tw32(MAC_RX_MODE, RX_MODE_RESET);
+		tr32(MAC_RX_MODE);
+		udelay(10);
+	}
 	tw32(MAC_RX_MODE, tp->rx_mode);
 	tr32(MAC_RX_MODE);
 	udelay(10);
@@ -4378,22 +5103,48 @@
 	tw32(MAC_RCV_VALUE_0, 0xffffffff & RCV_RULE_DISABLE_MASK);
 	tw32(MAC_RCV_RULE_1,  0x86000004 & RCV_RULE_DISABLE_MASK);
 	tw32(MAC_RCV_VALUE_1, 0xffffffff & RCV_RULE_DISABLE_MASK);
-#if 0
-	tw32(MAC_RCV_RULE_2,  0); tw32(MAC_RCV_VALUE_2,  0);
-	tw32(MAC_RCV_RULE_3,  0); tw32(MAC_RCV_VALUE_3,  0);
-#endif
-	tw32(MAC_RCV_RULE_4,  0); tw32(MAC_RCV_VALUE_4,  0);
-	tw32(MAC_RCV_RULE_5,  0); tw32(MAC_RCV_VALUE_5,  0);
-	tw32(MAC_RCV_RULE_6,  0); tw32(MAC_RCV_VALUE_6,  0);
-	tw32(MAC_RCV_RULE_7,  0); tw32(MAC_RCV_VALUE_7,  0);
-	tw32(MAC_RCV_RULE_8,  0); tw32(MAC_RCV_VALUE_8,  0);
-	tw32(MAC_RCV_RULE_9,  0); tw32(MAC_RCV_VALUE_9,  0);
-	tw32(MAC_RCV_RULE_10,  0); tw32(MAC_RCV_VALUE_10,  0);
-	tw32(MAC_RCV_RULE_11,  0); tw32(MAC_RCV_VALUE_11,  0);
-	tw32(MAC_RCV_RULE_12,  0); tw32(MAC_RCV_VALUE_12,  0);
-	tw32(MAC_RCV_RULE_13,  0); tw32(MAC_RCV_VALUE_13,  0);
-	tw32(MAC_RCV_RULE_14,  0); tw32(MAC_RCV_VALUE_14,  0);
-	tw32(MAC_RCV_RULE_15,  0); tw32(MAC_RCV_VALUE_15,  0);
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
+		limit = 8;
+	else
+		limit = 16;
+	if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF)
+		limit -= 4;
+	switch (limit) {
+	case 16:
+		tw32(MAC_RCV_RULE_15,  0); tw32(MAC_RCV_VALUE_15,  0);
+	case 15:
+		tw32(MAC_RCV_RULE_14,  0); tw32(MAC_RCV_VALUE_14,  0);
+	case 14:
+		tw32(MAC_RCV_RULE_13,  0); tw32(MAC_RCV_VALUE_13,  0);
+	case 13:
+		tw32(MAC_RCV_RULE_12,  0); tw32(MAC_RCV_VALUE_12,  0);
+	case 12:
+		tw32(MAC_RCV_RULE_11,  0); tw32(MAC_RCV_VALUE_11,  0);
+	case 11:
+		tw32(MAC_RCV_RULE_10,  0); tw32(MAC_RCV_VALUE_10,  0);
+	case 10:
+		tw32(MAC_RCV_RULE_9,  0); tw32(MAC_RCV_VALUE_9,  0);
+	case 9:
+		tw32(MAC_RCV_RULE_8,  0); tw32(MAC_RCV_VALUE_8,  0);
+	case 8:
+		tw32(MAC_RCV_RULE_7,  0); tw32(MAC_RCV_VALUE_7,  0);
+	case 7:
+		tw32(MAC_RCV_RULE_6,  0); tw32(MAC_RCV_VALUE_6,  0);
+	case 6:
+		tw32(MAC_RCV_RULE_5,  0); tw32(MAC_RCV_VALUE_5,  0);
+	case 5:
+		tw32(MAC_RCV_RULE_4,  0); tw32(MAC_RCV_VALUE_4,  0);
+	case 4:
+		/* tw32(MAC_RCV_RULE_3,  0); tw32(MAC_RCV_VALUE_3,  0); */
+	case 3:
+		/* tw32(MAC_RCV_RULE_2,  0); tw32(MAC_RCV_VALUE_2,  0); */
+	case 2:
+	case 1:
+
+	default:
+		break;
+	};
 
 	if (tp->tg3_flags & TG3_FLAG_INIT_COMPLETE)
 		tg3_enable_ints(tp);
@@ -4423,6 +5174,50 @@
 	return err;
 }
 
+#define TG3_STAT_ADD32(PSTAT, REG) \
+do {	u32 __val = tr32(REG); \
+	(PSTAT)->low += __val; \
+	if ((PSTAT)->low < __val) \
+		(PSTAT)->high += 1; \
+} while (0)
+
+static void tg3_periodic_fetch_stats(struct tg3 *tp)
+{
+	struct tg3_hw_stats *sp = tp->hw_stats;
+
+	if (!netif_carrier_ok(tp->dev))
+		return;
+
+	TG3_STAT_ADD32(&sp->tx_octets, MAC_TX_STATS_OCTETS);
+	TG3_STAT_ADD32(&sp->tx_collisions, MAC_TX_STATS_COLLISIONS);
+	TG3_STAT_ADD32(&sp->tx_xon_sent, MAC_TX_STATS_XON_SENT);
+	TG3_STAT_ADD32(&sp->tx_xoff_sent, MAC_TX_STATS_XOFF_SENT);
+	TG3_STAT_ADD32(&sp->tx_mac_errors, MAC_TX_STATS_MAC_ERRORS);
+	TG3_STAT_ADD32(&sp->tx_single_collisions, MAC_TX_STATS_SINGLE_COLLISIONS);
+	TG3_STAT_ADD32(&sp->tx_mult_collisions, MAC_TX_STATS_MULT_COLLISIONS);
+	TG3_STAT_ADD32(&sp->tx_deferred, MAC_TX_STATS_DEFERRED);
+	TG3_STAT_ADD32(&sp->tx_excessive_collisions, MAC_TX_STATS_EXCESSIVE_COL);
+	TG3_STAT_ADD32(&sp->tx_late_collisions, MAC_TX_STATS_LATE_COL);
+	TG3_STAT_ADD32(&sp->tx_ucast_packets, MAC_TX_STATS_UCAST);
+	TG3_STAT_ADD32(&sp->tx_mcast_packets, MAC_TX_STATS_MCAST);
+	TG3_STAT_ADD32(&sp->tx_bcast_packets, MAC_TX_STATS_BCAST);
+
+	TG3_STAT_ADD32(&sp->rx_octets, MAC_RX_STATS_OCTETS);
+	TG3_STAT_ADD32(&sp->rx_fragments, MAC_RX_STATS_FRAGMENTS);
+	TG3_STAT_ADD32(&sp->rx_ucast_packets, MAC_RX_STATS_UCAST);
+	TG3_STAT_ADD32(&sp->rx_mcast_packets, MAC_RX_STATS_MCAST);
+	TG3_STAT_ADD32(&sp->rx_bcast_packets, MAC_RX_STATS_BCAST);
+	TG3_STAT_ADD32(&sp->rx_fcs_errors, MAC_RX_STATS_FCS_ERRORS);
+	TG3_STAT_ADD32(&sp->rx_align_errors, MAC_RX_STATS_ALIGN_ERRORS);
+	TG3_STAT_ADD32(&sp->rx_xon_pause_rcvd, MAC_RX_STATS_XON_PAUSE_RECVD);
+	TG3_STAT_ADD32(&sp->rx_xoff_pause_rcvd, MAC_RX_STATS_XOFF_PAUSE_RECVD);
+	TG3_STAT_ADD32(&sp->rx_mac_ctrl_rcvd, MAC_RX_STATS_MAC_CTRL_RECVD);
+	TG3_STAT_ADD32(&sp->rx_xoff_entered, MAC_RX_STATS_XOFF_ENTERED);
+	TG3_STAT_ADD32(&sp->rx_frame_too_long_errors, MAC_RX_STATS_FRAME_TOO_LONG);
+	TG3_STAT_ADD32(&sp->rx_jabbers, MAC_RX_STATS_JABBERS);
+	TG3_STAT_ADD32(&sp->rx_undersize_packets, MAC_RX_STATS_UNDERSIZE);
+}
+
 static void tg3_timer(unsigned long __opaque)
 {
 	struct tg3 *tp = (struct tg3 *) __opaque;
@@ -4451,6 +5246,9 @@
 		return;
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
+		tg3_periodic_fetch_stats(tp);
+
 	/* This part only runs once per second. */
 	if (!--tp->timer_counter) {
 		if (tp->tg3_flags & TG3_FLAG_USE_LINKCHG_REG) {
@@ -4908,7 +5706,9 @@
 		get_stat64(&hw_stats->rx_bcast_packets);
 		
 	stats->tx_packets = old_stats->tx_packets +
-		get_stat64(&hw_stats->COS_out_packets[0]);
+		get_stat64(&hw_stats->tx_ucast_packets) +
+		get_stat64(&hw_stats->tx_mcast_packets) +
+		get_stat64(&hw_stats->tx_bcast_packets);
 
 	stats->rx_bytes = old_stats->rx_bytes +
 		get_stat64(&hw_stats->rx_octets);
@@ -5232,6 +6032,28 @@
 	tp->msg_enable = value;
 }
   
+static u32 tg3_get_tso(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_TSO) != 0;
+}
+  
+static int tg3_set_tso(struct net_device *dev, u32 value)
+{
+	struct tg3 *tp = dev->priv;
+
+	if (!(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)) {
+		if (value)
+			return -EINVAL;
+		return 0;
+	} else {
+		if (!value)
+			dev->features &= ~NETIF_F_TSO;
+		else
+			dev->features |= NETIF_F_TSO;
+		return 0;
+	}
+}
+  
 static int tg3_nway_reset(struct net_device *dev)
 {
 	struct tg3 *tp = dev->priv;
@@ -5279,6 +6101,10 @@
 	spin_lock(&tp->tx_lock);
   
 	tp->rx_pending = ering->rx_pending;
+
+	if ((tp->tg3_flags2 & TG3_FLG2_MAX_RXPEND_64) &&
+	    tp->rx_pending > 64)
+		tp->rx_pending = 64;
 	tp->rx_jumbo_pending = ering->rx_jumbo_pending;
 	tp->tx_pending = ering->tx_pending;
 
@@ -5467,6 +6293,8 @@
 	.set_tx_csum		= tg3_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
+	.get_tso		= tg3_get_tso,
+	.set_tso		= tg3_set_tso,
 };
 
 /* Chips other than 5700/5701 use the NVRAM for fetching info. */
@@ -5669,6 +6497,7 @@
 		u32 nic_cfg;
 
 		tg3_read_mem(tp, NIC_SRAM_DATA_CFG, &nic_cfg);
+		tp->nic_sram_data_cfg = nic_cfg;
 
 		eeprom_signature_found = 1;
 
@@ -5702,8 +6531,10 @@
 			eeprom_led_mode = led_mode_auto;
 			break;
 		};
-		if ((tp->pci_chip_rev_id == CHIPREV_ID_5703_A1 ||
-		     tp->pci_chip_rev_id == CHIPREV_ID_5703_A2) &&
+
+		if (((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703) ||
+		     (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) ||
+		     (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)) &&
 		    (nic_cfg & NIC_SRAM_DATA_CFG_EEPROM_WP))
 			tp->tg3_flags |= TG3_FLAG_EEPROM_WRITE_PROT;
 
@@ -5785,9 +6616,7 @@
 	}
 
 	/* Enable Ethernet@WireSpeed */
-	tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x7007);
-	tg3_readphy(tp, MII_TG3_AUX_CTRL, &val);
-	tg3_writephy(tp, MII_TG3_AUX_CTRL, (val | (1 << 15) | (1 << 4)));
+	tg3_phy_set_wirespeed(tp);
 
 	if (!err && ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5401)) {
 		err = tg3_init_5401phy_dsp(tp);
@@ -6085,7 +6914,15 @@
 		tp->tg3_flags |= TG3_FLAG_WOL_SPEED_100MB;
 	}
 
+	/* A few boards don't want Ethernet@WireSpeed phy feature */
+	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700) ||
+	    ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) &&
+	     (tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) &&
+	     (tp->pci_chip_rev_id != CHIPREV_ID_5705_A1)))
+		tp->tg3_flags2 |= TG3_FLG2_NO_ETH_WIRE_SPEED;
+
 	/* Only 5701 and later support tagged irq status mode.
+	 * Also, 5788 chips cannot use tagged irq status.
 	 *
 	 * However, since we are using NAPI avoid tagged irq status
 	 * because the interrupt condition is more difficult to
@@ -6142,7 +6979,8 @@
 	/* Determine if TX descriptors will reside in
 	 * main memory or in the chip SRAM.
 	 */
-	if (tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG)
+	if ((tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG) != 0 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
 		tp->tg3_flags |= TG3_FLAG_HOST_TXDS;
 
 	grc_misc_cfg = tr32(GRC_MISC_CFG);
@@ -6154,8 +6992,18 @@
 		tp->split_mode_max_reqs = SPLIT_MODE_5704_MAX_REQ;
 	}
 
-	/* this one is limited to 10/100 only */
-	if (grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5702FE)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
+	    (grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5788 ||
+	     grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5788M))
+		tp->tg3_flags2 |= TG3_FLG2_IS_5788;
+
+	/* these are limited to 10/100 only */
+	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 &&
+	     (grc_misc_cfg == 0x8000 || grc_misc_cfg == 0x4000)) ||
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
+	     tp->pdev->vendor == PCI_VENDOR_ID_BROADCOM &&
+	     (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5901 ||
+	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5901_2)))
 		tp->tg3_flags |= TG3_FLAG_10_100_ONLY;
 
 	err = tg3_phy_probe(tp);
@@ -6414,8 +7262,6 @@
 		goto out_nofree;
 	}
 
-	tw32(TG3PCI_CLOCK_CTRL, 0);
-
 	if ((tp->tg3_flags & TG3_FLAG_PCIX_MODE) == 0) {
 		tp->dma_rwctrl =
 			(0x7 << DMA_RWCTRL_PCI_WRITE_CMD_SHIFT) |
@@ -6423,7 +7269,9 @@
 			(0x7 << DMA_RWCTRL_WRITE_WATER_SHIFT) |
 			(0x7 << DMA_RWCTRL_READ_WATER_SHIFT) |
 			(0x0f << DMA_RWCTRL_MIN_DMA_SHIFT);
-		/* XXX 5705 note: set MIN_DMA to zero here */
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
+			tp->dma_rwctrl &= ~(DMA_RWCTRL_MIN_DMA
+					    << DMA_RWCTRL_MIN_DMA_SHIFT);
 	} else {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704)
 			tp->dma_rwctrl =
@@ -6526,6 +7374,11 @@
 
 	tw32(TG3PCI_DMA_RW_CTRL, tp->dma_rwctrl);
 
+#if 0
+	/* Unneeded, already done by tg3_get_invariants.  */
+	tg3_switch_clocks(tp);
+#endif
+
 	ret = 0;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701)
@@ -6630,12 +7483,35 @@
 	case PHY_ID_BCM5701:	return "5701";
 	case PHY_ID_BCM5703:	return "5703";
 	case PHY_ID_BCM5704:	return "5704";
+	case PHY_ID_BCM5705:	return "5705";
 	case PHY_ID_BCM8002:	return "8002";
 	case PHY_ID_SERDES:	return "serdes";
 	default:		return "unknown";
 	};
 }
 
+static struct pci_dev * __devinit tg3_find_5704_peer(struct tg3 *tp)
+{
+	struct pci_dev *peer = NULL;
+	unsigned int func;
+
+	for (func = 0; func < 7; func++) {
+		unsigned int devfn = tp->pdev->devfn;
+
+		devfn &= ~7;
+		devfn |= func;
+
+		if (devfn == tp->pdev->devfn)
+			continue;
+		peer = pci_find_slot(tp->pdev->bus->number, devfn);
+		if (peer)
+			break;
+	}
+	if (!peer || peer == tp->pdev)
+		BUG();
+	return peer;
+}
+
 static int __devinit tg3_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -6794,6 +7670,44 @@
 		goto err_out_iounmap;
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+		tp->bufmgr_config.mbuf_read_dma_low_water =
+			DEFAULT_MB_RDMA_LOW_WATER_5705;
+		tp->bufmgr_config.mbuf_mac_rx_low_water =
+			DEFAULT_MB_MACRX_LOW_WATER_5705;
+		tp->bufmgr_config.mbuf_high_water =
+			DEFAULT_MB_HIGH_WATER_5705;
+	}
+
+#if TG3_TSO_SUPPORT != 0
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5705_A0 ||
+	    (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0 ||
+	    (tp->tg3_flags2 & TG3_FLG2_IS_5788)) {
+		tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
+	} else {
+		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
+	}
+
+	/* TSO is off by default, user can enable using ethtool.  */
+#if 0
+	if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)
+		dev->features |= NETIF_F_TSO;
+#endif
+
+#endif
+
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
+	    !(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
+	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {
+		tp->tg3_flags2 |= TG3_FLG2_MAX_RXPEND_64;
+		tp->rx_pending = 64;
+	}
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704)
+		tp->pdev_peer = tg3_find_5704_peer(tp);
+
 	err = tg3_get_device_address(tp);
 	if (err) {
 		printk(KERN_ERR PFX "Could not obtain valid ethernet address, "
@@ -6816,16 +7730,8 @@
 	} else
 		tp->tg3_flags &= ~TG3_FLAG_RX_CHECKSUMS;
 
-#if TG3_DO_TSO != 0
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
-	     tp->pci_chip_rev_id <= CHIPREV_ID_5701_B2)) {
-		/* Not TSO capable. */
-		dev->features &= ~NETIF_F_TSO;
-	} else {
-		dev->features |= NETIF_F_TSO;
-	}
-#endif
+	if (tp->tg3_flags2 & TG3_FLG2_IS_5788)
+		dev->features &= ~NETIF_F_HIGHDMA;
 
 	err = register_netdev(dev);
 	if (err) {
diff -Nru a/drivers/net/tg3.h b/drivers/net/tg3.h
--- a/drivers/net/tg3.h	Sat Aug 23 21:49:57 2003
+++ b/drivers/net/tg3.h	Sat Aug 23 21:49:57 2003
@@ -24,6 +24,7 @@
 #define RX_COPY_THRESHOLD  		256
 
 #define RX_STD_MAX_SIZE			1536
+#define RX_STD_MAX_SIZE_5705		512
 #define RX_JUMBO_MAX_SIZE		0xdeadbeef /* XXX */
 
 /* First 256 bytes are a mirror of PCI config space. */
@@ -59,7 +60,7 @@
 #define  PCIX_CAPS_SPLIT_SHIFT		 20
 #define  PCIX_CAPS_BURST_MASK		 0x000c0000
 #define  PCIX_CAPS_BURST_SHIFT		 18
-#define  PCIX_CAPS_MAX_BURST_5704	 2
+#define  PCIX_CAPS_MAX_BURST_CPIOB	 2
 #define TG3PCI_PM_CAP_PTR		0x00000041
 #define TG3PCI_X_COMMAND		0x00000042
 #define TG3PCI_X_STATUS			0x00000044
@@ -115,11 +116,14 @@
 #define  CHIPREV_ID_5704_A0		 0x2000
 #define  CHIPREV_ID_5704_A1		 0x2001
 #define  CHIPREV_ID_5704_A2		 0x2002
+#define  CHIPREV_ID_5705_A0		 0x3000
+#define  CHIPREV_ID_5705_A1		 0x3001
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
 #define   ASIC_REV_5703			 0x01
 #define   ASIC_REV_5704			 0x02
+#define   ASIC_REV_5705			 0x03
 #define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
@@ -180,6 +184,9 @@
 #define  CLOCK_CTRL_ALTCLK		 0x00001000
 #define  CLOCK_CTRL_PWRDOWN_PLL133	 0x00008000
 #define  CLOCK_CTRL_44MHZ_CORE		 0x00040000
+#define  CLOCK_CTRL_625_CORE		 0x00100000
+#define  CLOCK_CTRL_FORCE_CLKRUN	 0x00200000
+#define  CLOCK_CTRL_CLKRUN_OENABLE	 0x00400000
 #define  CLOCK_CTRL_DELAY_PCI_GRANT	 0x80000000
 #define TG3PCI_REG_BASE_ADDR		0x00000078
 #define TG3PCI_MEM_WIN_BASE_ADDR	0x0000007c
@@ -457,17 +464,89 @@
 #define MAC_RCV_RULE_CFG		0x00000500
 #define  RCV_RULE_CFG_DEFAULT_CLASS	0x00000008
 #define MAC_LOW_WMARK_MAX_RX_FRAME	0x00000504
-/* 0x504 --> 0x590 unused */
+/* 0x508 --> 0x520 unused */
+#define MAC_HASHREGU_0			0x00000520
+#define MAC_HASHREGU_1			0x00000524
+#define MAC_HASHREGU_2			0x00000528
+#define MAC_HASHREGU_3			0x0000052c
+#define MAC_EXTADDR_0_HIGH		0x00000530
+#define MAC_EXTADDR_0_LOW		0x00000534
+#define MAC_EXTADDR_1_HIGH		0x00000538
+#define MAC_EXTADDR_1_LOW		0x0000053c
+#define MAC_EXTADDR_2_HIGH		0x00000540
+#define MAC_EXTADDR_2_LOW		0x00000544
+#define MAC_EXTADDR_3_HIGH		0x00000548
+#define MAC_EXTADDR_3_LOW		0x0000054c
+#define MAC_EXTADDR_4_HIGH		0x00000550
+#define MAC_EXTADDR_4_LOW		0x00000554
+#define MAC_EXTADDR_5_HIGH		0x00000558
+#define MAC_EXTADDR_5_LOW		0x0000055c
+#define MAC_EXTADDR_6_HIGH		0x00000560
+#define MAC_EXTADDR_6_LOW		0x00000564
+#define MAC_EXTADDR_7_HIGH		0x00000568
+#define MAC_EXTADDR_7_LOW		0x0000056c
+#define MAC_EXTADDR_8_HIGH		0x00000570
+#define MAC_EXTADDR_8_LOW		0x00000574
+#define MAC_EXTADDR_9_HIGH		0x00000578
+#define MAC_EXTADDR_9_LOW		0x0000057c
+#define MAC_EXTADDR_10_HIGH		0x00000580
+#define MAC_EXTADDR_10_LOW		0x00000584
+#define MAC_EXTADDR_11_HIGH		0x00000588
+#define MAC_EXTADDR_11_LOW		0x0000058c
 #define MAC_SERDES_CFG			0x00000590
 #define MAC_SERDES_STAT			0x00000594
 /* 0x598 --> 0x600 unused */
 #define MAC_TX_MAC_STATE_BASE		0x00000600 /* 16 bytes */
 #define MAC_RX_MAC_STATE_BASE		0x00000610 /* 20 bytes */
 /* 0x624 --> 0x800 unused */
-#define MAC_RX_STATS_BASE		0x00000800 /* 26 32-bit words */
-/* 0x868 --> 0x880 unused */
-#define MAC_TX_STATS_BASE		0x00000880 /* 28 32-bit words */
-/* 0x8f0 --> 0xc00 unused */
+#define MAC_TX_STATS_OCTETS		0x00000800
+#define MAC_TX_STATS_RESV1		0x00000804
+#define MAC_TX_STATS_COLLISIONS		0x00000808
+#define MAC_TX_STATS_XON_SENT		0x0000080c
+#define MAC_TX_STATS_XOFF_SENT		0x00000810
+#define MAC_TX_STATS_RESV2		0x00000814
+#define MAC_TX_STATS_MAC_ERRORS		0x00000818
+#define MAC_TX_STATS_SINGLE_COLLISIONS	0x0000081c
+#define MAC_TX_STATS_MULT_COLLISIONS	0x00000820
+#define MAC_TX_STATS_DEFERRED		0x00000824
+#define MAC_TX_STATS_RESV3		0x00000828
+#define MAC_TX_STATS_EXCESSIVE_COL	0x0000082c
+#define MAC_TX_STATS_LATE_COL		0x00000830
+#define MAC_TX_STATS_RESV4_1		0x00000834
+#define MAC_TX_STATS_RESV4_2		0x00000838
+#define MAC_TX_STATS_RESV4_3		0x0000083c
+#define MAC_TX_STATS_RESV4_4		0x00000840
+#define MAC_TX_STATS_RESV4_5		0x00000844
+#define MAC_TX_STATS_RESV4_6		0x00000848
+#define MAC_TX_STATS_RESV4_7		0x0000084c
+#define MAC_TX_STATS_RESV4_8		0x00000850
+#define MAC_TX_STATS_RESV4_9		0x00000854
+#define MAC_TX_STATS_RESV4_10		0x00000858
+#define MAC_TX_STATS_RESV4_11		0x0000085c
+#define MAC_TX_STATS_RESV4_12		0x00000860
+#define MAC_TX_STATS_RESV4_13		0x00000864
+#define MAC_TX_STATS_RESV4_14		0x00000868
+#define MAC_TX_STATS_UCAST		0x0000086c
+#define MAC_TX_STATS_MCAST		0x00000870
+#define MAC_TX_STATS_BCAST		0x00000874
+#define MAC_TX_STATS_RESV5_1		0x00000878
+#define MAC_TX_STATS_RESV5_2		0x0000087c
+#define MAC_RX_STATS_OCTETS		0x00000880
+#define MAC_RX_STATS_RESV1		0x00000884
+#define MAC_RX_STATS_FRAGMENTS		0x00000888
+#define MAC_RX_STATS_UCAST		0x0000088c
+#define MAC_RX_STATS_MCAST		0x00000890
+#define MAC_RX_STATS_BCAST		0x00000894
+#define MAC_RX_STATS_FCS_ERRORS		0x00000898
+#define MAC_RX_STATS_ALIGN_ERRORS	0x0000089c
+#define MAC_RX_STATS_XON_PAUSE_RECVD	0x000008a0
+#define MAC_RX_STATS_XOFF_PAUSE_RECVD	0x000008a4
+#define MAC_RX_STATS_MAC_CTRL_RECVD	0x000008a8
+#define MAC_RX_STATS_XOFF_ENTERED	0x000008ac
+#define MAC_RX_STATS_FRAME_TOO_LONG	0x000008b0
+#define MAC_RX_STATS_JABBERS		0x000008b4
+#define MAC_RX_STATS_UNDERSIZE		0x000008b8
+/* 0x8bc --> 0xc00 unused */
 
 /* Send data initiator control registers */
 #define SNDDATAI_MODE			0x00000c00
@@ -599,6 +678,7 @@
 #define  RCVLPC_STATSCTRL_ENABLE	 0x00000001
 #define  RCVLPC_STATSCTRL_FASTUPD	 0x00000002
 #define RCVLPC_STATS_ENABLE		0x00002018
+#define  RCVLPC_STATSENAB_LNGBRST_RFIX	 0x00400000
 #define RCVLPC_STATS_INCMASK		0x0000201c
 /* 0x2020 --> 0x2100 unused */
 #define RCVLPC_SELLST_BASE		0x00002100 /* 16 16-byte entries */
@@ -812,13 +892,16 @@
 #define BUFMGR_MB_POOL_ADDR		0x00004408
 #define BUFMGR_MB_POOL_SIZE		0x0000440c
 #define BUFMGR_MB_RDMA_LOW_WATER	0x00004410
-#define  DEFAULT_MB_RDMA_LOW_WATER	 0x00000040
+#define  DEFAULT_MB_RDMA_LOW_WATER	 0x00000050
+#define  DEFAULT_MB_RDMA_LOW_WATER_5705	 0x00000000
 #define  DEFAULT_MB_RDMA_LOW_WATER_JUMBO 0x00000130
 #define BUFMGR_MB_MACRX_LOW_WATER	0x00004414
 #define  DEFAULT_MB_MACRX_LOW_WATER	  0x00000020
+#define  DEFAULT_MB_MACRX_LOW_WATER_5705  0x00000010
 #define  DEFAULT_MB_MACRX_LOW_WATER_JUMBO 0x00000098
 #define BUFMGR_MB_HIGH_WATER		0x00004418
 #define  DEFAULT_MB_HIGH_WATER		 0x00000060
+#define  DEFAULT_MB_HIGH_WATER_5705	 0x00000060
 #define  DEFAULT_MB_HIGH_WATER_JUMBO	 0x0000017c
 #define BUFMGR_RX_MB_ALLOC_REQ		0x0000441c
 #define  BUFMGR_MB_ALLOC_BIT		 0x10000000
@@ -854,6 +937,8 @@
 #define  RDMAC_MODE_LNGREAD_ENAB	 0x00000200
 #define  RDMAC_MODE_SPLIT_ENABLE	 0x00000800
 #define  RDMAC_MODE_SPLIT_RESET		 0x00001000
+#define  RDMAC_MODE_FIFO_SIZE_128	 0x00020000
+#define  RDMAC_MODE_FIFO_LONG_BURST	 0x00030000
 #define RDMAC_STATUS			0x00004804
 #define  RDMAC_STATUS_TGTABORT		 0x00000004
 #define  RDMAC_STATUS_MSTABORT		 0x00000008
@@ -877,6 +962,7 @@
 #define  WDMAC_MODE_FIFOURUN_ENAB	 0x00000080
 #define  WDMAC_MODE_FIFOOREAD_ENAB	 0x00000100
 #define  WDMAC_MODE_LNGREAD_ENAB	 0x00000200
+#define  WDMAC_MODE_RX_ACCEL	 	 0x00000400
 #define WDMAC_STATUS			0x00004c04
 #define  WDMAC_STATUS_TGTABORT		 0x00000004
 #define  WDMAC_STATUS_MSTABORT		 0x00000008
@@ -1140,7 +1226,10 @@
 #define  GRC_MISC_CFG_BOARD_ID_5704	0x00000000
 #define  GRC_MISC_CFG_BOARD_ID_5704CIOBE 0x00004000
 #define  GRC_MISC_CFG_BOARD_ID_5704_A2	0x00008000
+#define  GRC_MISC_CFG_BOARD_ID_5788	0x00010000
+#define  GRC_MISC_CFG_BOARD_ID_5788M	0x00018000
 #define  GRC_MISC_CFG_BOARD_ID_AC91002A1 0x00018000
+#define  GRC_MISC_CFG_KEEP_GPHY_POWER	0x04000000
 #define GRC_LOCAL_CTRL			0x00006808
 #define  GRC_LCLCTRL_INT_ACTIVE		0x00000001
 #define  GRC_LCLCTRL_CLEARINT		0x00000002
@@ -1275,6 +1364,7 @@
 #define  NIC_SRAM_DATA_CFG_WOL_ENABLE		 0x00000040
 #define  NIC_SRAM_DATA_CFG_ASF_ENABLE		 0x00000080
 #define  NIC_SRAM_DATA_CFG_EEPROM_WP		 0x00000100
+#define  NIC_SRAM_DATA_CFG_MINI_PCI		 0x00001000
 #define  NIC_SRAM_DATA_CFG_FIBER_WOL		 0x00004000
 
 #define NIC_SRAM_DATA_PHY_ID		0x00000b74
@@ -1312,6 +1402,8 @@
 #define NIC_SRAM_MBUF_POOL_BASE		0x00008000
 #define  NIC_SRAM_MBUF_POOL_SIZE96	 0x00018000
 #define  NIC_SRAM_MBUF_POOL_SIZE64	 0x00010000
+#define  NIC_SRAM_MBUF_POOL_BASE5705	0x00010000
+#define  NIC_SRAM_MBUF_POOL_SIZE5705	0x0000e000
 
 /* Currently this is fixed. */
 #define PHY_ADDR		0x01
@@ -1824,6 +1916,10 @@
 	u32				tg3_flags2;
 #define TG3_FLG2_RESTART_TIMER		0x00000001
 #define TG3_FLG2_SUN_5704		0x00000002
+#define TG3_FLG2_NO_ETH_WIRE_SPEED	0x00000004
+#define TG3_FLG2_IS_5788		0x00000008
+#define TG3_FLG2_MAX_RXPEND_64		0x00000010
+#define TG3_FLG2_TSO_CAPABLE		0x00000020
 
 	u32				split_mode_max_reqs;
 #define SPLIT_MODE_5704_MAX_REQ		3
@@ -1868,6 +1964,7 @@
 #define PHY_ID_BCM5701			0x60008110
 #define PHY_ID_BCM5703			0x60008160
 #define PHY_ID_BCM5704			0x60008190
+#define PHY_ID_BCM5705			0x600081a0
 #define PHY_ID_BCM8002			0x60010140
 #define PHY_ID_SERDES			0xfeedbee0
 #define PHY_ID_INVALID			0xffffffff
@@ -1880,6 +1977,9 @@
 	enum phy_led_mode		led_mode;
 
 	char				board_part_number[24];
+	u32				nic_sram_data_cfg;
+	u32				pci_clock_ctrl;
+	struct pci_dev			*pdev_peer;
 
 	/* This macro assumes the passed PHY ID is already masked
 	 * with PHY_ID_MASK.
@@ -1888,6 +1988,7 @@
 	((X) == PHY_ID_BCM5400 || (X) == PHY_ID_BCM5401 || \
 	 (X) == PHY_ID_BCM5411 || (X) == PHY_ID_BCM5701 || \
 	 (X) == PHY_ID_BCM5703 || (X) == PHY_ID_BCM5704 || \
+	 (X) == PHY_ID_BCM5705 || \
 	 (X) == PHY_ID_BCM8002 || (X) == PHY_ID_SERDES)
 
 	struct tg3_hw_stats		*hw_stats;
diff -Nru a/drivers/pci/pci.ids b/drivers/pci/pci.ids
--- a/drivers/pci/pci.ids	Sat Aug 23 21:49:57 2003
+++ b/drivers/pci/pci.ids	Sat Aug 23 21:49:57 2003
@@ -5313,9 +5313,12 @@
 		1166 1648  NetXtreme CIOB-E 1000Base-T
 	164d  NetXtreme BCM5702FE Gigabit Ethernet
 	1653  NetXtreme BCM5705 Gigabit Ethernet
+	1654  NetXtreme BCM5705 Gigabit Ethernet
 	165d  NetXtreme BCM5705M Gigabit Ethernet
+	165e  NetXtreme BCM5705M Gigabit Ethernet
 	1696  NetXtreme BCM5782 Gigabit Ethernet
 		14e4 000d  NetXtreme BCM5782 1000Base-T
+	169c  NetXtreme BCM5788 Gigabit Ethernet
 	16a6  NetXtreme BCM5702 Gigabit Ethernet
 		0e11 00bb  NC7760 Gigabit Server Adapter (PCI-X, 10/100/1000-T)
 		1028 0126  BCM5702 1000Base-T
@@ -5337,6 +5340,8 @@
 	16c7  NetXtreme BCM5703 Gigabit Ethernet
 		14e4 0009  NetXtreme BCM5703 1000Base-T
 		14e4 000a  NetXtreme BCM5703 1000Base-SX
+	170d  NetXtreme BCM5901 Gigabit Ethernet
+	170e  NetXtreme BCM5901 Gigabit Ethernet
 	4210  BCM4210 iLine10 HomePNA 2.0
 	4211  BCM4211 iLine10 HomePNA 2.0 + V.90 56k modem
 	4212  BCM4212 v.90 56k modem
diff -Nru a/include/linux/ethtool.h b/include/linux/ethtool.h
--- a/include/linux/ethtool.h	Sat Aug 23 21:49:57 2003
+++ b/include/linux/ethtool.h	Sat Aug 23 21:49:57 2003
@@ -284,6 +284,8 @@
  * set_tx_csum: Turn transmit checksums on or off
  * get_sg: Report whether scatter-gather is enabled
  * set_sg: Turn scatter-gather on or off
+ * get_tso: Report whether TCP segmentation offload is enabled
+ * set_tso: Turn TCP segmentation offload on or off
  * self_test: Run specified self-tests
  * get_strings: Return a set of strings that describe the requested objects 
  * phys_id: Identify the device
@@ -337,6 +339,8 @@
 	int	(*set_tx_csum)(struct net_device *, u32);
 	u32	(*get_sg)(struct net_device *);
 	int	(*set_sg)(struct net_device *, u32);
+	u32	(*get_tso)(struct net_device *);
+	int	(*set_tso)(struct net_device *, u32);
 	int	(*self_test_count)(struct net_device *);
 	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
 	void	(*get_strings)(struct net_device *, u32 stringset, u8 *);
diff -Nru a/include/linux/pci_ids.h b/include/linux/pci_ids.h
--- a/include/linux/pci_ids.h	Sat Aug 23 21:49:57 2003
+++ b/include/linux/pci_ids.h	Sat Aug 23 21:49:57 2003
@@ -1758,11 +1758,19 @@
 #define PCI_DEVICE_ID_TIGON3_5703	0x1647
 #define PCI_DEVICE_ID_TIGON3_5704	0x1648
 #define PCI_DEVICE_ID_TIGON3_5702FE	0x164d
+#define PCI_DEVICE_ID_TIGON3_5705	0x1653
+#define PCI_DEVICE_ID_TIGON3_5705_2	0x1654
+#define PCI_DEVICE_ID_TIGON3_5705M	0x165d
+#define PCI_DEVICE_ID_TIGON3_5705M_2	0x165e
+#define PCI_DEVICE_ID_TIGON3_5782	0x1696
+#define PCI_DEVICE_ID_TIGON3_5788	0x169c
 #define PCI_DEVICE_ID_TIGON3_5702X	0x16a6
 #define PCI_DEVICE_ID_TIGON3_5703X	0x16a7
 #define PCI_DEVICE_ID_TIGON3_5704S	0x16a8
 #define PCI_DEVICE_ID_TIGON3_5702A3	0x16c6
 #define PCI_DEVICE_ID_TIGON3_5703A3	0x16c7
+#define PCI_DEVICE_ID_TIGON3_5901	0x170d
+#define PCI_DEVICE_ID_TIGON3_5901_2	0x170e
 #define PCI_DEVICE_ID_BCM4401		0x4401
 
 #define PCI_VENDOR_ID_SYBA		0x1592
diff -Nru a/net/core/ethtool.c b/net/core/ethtool.c
--- a/net/core/ethtool.c	Sat Aug 23 21:49:57 2003
+++ b/net/core/ethtool.c	Sat Aug 23 21:49:57 2003
@@ -454,6 +454,33 @@
 	return dev->ethtool_ops->set_sg(dev, edata.data);
 }
 
+static int ethtool_get_tso(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GTSO };
+
+	if (!dev->ethtool_ops->get_tso)
+		return -EOPNOTSUPP;
+
+	edata.data = dev->ethtool_ops->get_tso(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_tso(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->ethtool_ops->set_tso)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_tso(dev, edata.data);
+}
+
 static int ethtool_self_test(struct net_device *dev, char *useraddr)
 {
 	struct ethtool_test test;
@@ -653,6 +680,10 @@
 		return ethtool_get_sg(dev, useraddr);
 	case ETHTOOL_SSG:
 		return ethtool_set_sg(dev, useraddr);
+	case ETHTOOL_GTSO:
+		return ethtool_get_tso(dev, useraddr);
+	case ETHTOOL_STSO:
+		return ethtool_set_tso(dev, useraddr);
 	case ETHTOOL_TEST:
 		return ethtool_self_test(dev, useraddr);
 	case ETHTOOL_GSTRINGS:
