From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.8-rc net driver fixes
Date: Tue, 10 Aug 2004 17:24:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040810212435.GA26048@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/hp-plus.c                         |    8 -
 drivers/net/pcmcia/axnet_cs.c                 |    2 
 drivers/net/tulip/tulip_core.c                |    2 
 drivers/net/wireless/atmel.c                  |    4 
 drivers/net/wireless/prism54/isl_ioctl.c      |   17 +-
 drivers/net/wireless/prism54/islpci_dev.c     |   29 ++--
 drivers/net/wireless/prism54/islpci_hotplug.c |  172 +-------------------------
 drivers/net/wireless/prism54/islpci_mgt.h     |   15 --
 drivers/net/wireless/prism54/oid_mgt.c        |    4 
 9 files changed, 50 insertions(+), 203 deletions(-)

through these ChangeSets:

<akpm@osdl.org> (04/08/10 1.1960)
   [PATCH] bk-netdev-hp-plus-fix
   
   Signed-off-by: Andrew Morton <akpm@osdl.org>

<akpm@osdl.org> (04/08/10 1.1959)
   [PATCH] wrong mac address with netgear FA311 ethernet card
   
   From: Mathieu LESNIAK <maverick@eskuel.net>
   
   
   This patch corrects a problem with Netgear FA311
   ethernet card (a cheap one). Without it, the MAC address is byte swapped
   ie :
   HWaddr 02:00:07:E3:E9:F5
   instead of :
   HWaddr 00:02:E3:07:F5:E9
   
   (the correct MAC address vendor code for Netgear/LiteOn is 00:02:E3)
   
   
   Signed-off-by: Andrew Morton <akpm@osdl.org>

<akpm@osdl.org> (04/08/10 1.1958)
   [PATCH] bk-netdev-axnet_cs-fix
   
   Signed-off-by: Andrew Morton <akpm@osdl.org>

<simon@thekelleys.org.uk> (04/08/10 1.1957)
   [PATCH] Atmel wireless bigendian fix.
   
   The following patch adds a couple of missing byteswaps and allows the
   Atmel wireless driver to work in WEP mode on big-endian CPUs. (tested
   on powerPC).

<margitsw@t-online.de> (04/08/10 1.1956)
   [PATCH] prism54 Fix supported rates reporting
   
   * We are not correctly reporting supported bit rates.
   * Fix it.

<margitsw@t-online.de> (04/08/10 1.1955)
   [PATCH] prism54 Fix memory leaks
   
   * Change the "version" OID to what it should be.
   * Fix memory leaks - mgt_get_request always returns
   * allocated memory for non-int OIDS (with an exception -
   * keep reading). If the caller checks the return and itself
   * returns, then it must free memory.
   * However, it is possible to return from mgt_get_request
   * early (!priv->mib). In this case, weird things can happen
   * in isl_ioctl. Quick fix, at least to force an oops, is
   * to set the union value to NULL. The real fix is to
   * recode all mgt_get_request calls in isl_ioctl.

<margitsw@t-online.de> (04/08/10 1.1954)
   [PATCH] prism54 URGENT - Fix IRQ handling
   
   * We are handing back HANDLED even though the IRQ is not for us.
     We also change device state.
     This is plainly wrong.
     AFAICT we also need to take the spin lock early.
     Tested/running on UP/SMP for about a week now.
     (Discovered on one of my lappies that had the X driver on the same IRQ)
     (Proposed on Prism54 Devel with no objections)

<margitsw@t-online.de> (04/08/10 1.1953)
   [PATCH] prism54 Clarification to Viro's patch
   
   * It seems that Viro patched prism54 with the following patch set :
   http://www.kernel.org/pub/linux/kernel/v2.6/testing/cset/
   cset-viro@www.linux.org.uk[torvalds]|ChangeSet|20040727040034|54764.txt
   
   * I do not see any indication in any mailing list of this.
     It would be nice if we could be informed of such changes :-)
   
   * (Changes committed to our CVS)

diff -Nru a/drivers/net/hp-plus.c b/drivers/net/hp-plus.c
--- a/drivers/net/hp-plus.c	2004-08-10 17:23:49 -04:00
+++ b/drivers/net/hp-plus.c	2004-08-10 17:23:49 -04:00
@@ -233,7 +233,7 @@
 	}
 
 	/* Set the wrap registers for string I/O reads.   */
-	outw((HP_START_PG + TX_2X_PAGES) | ((HP_STOP_PG - 1) << 8), ioaddr + 14);
+	outw((HP_START_PG + TX_PAGES/2) | ((HP_STOP_PG - 1) << 8), ioaddr + 14);
 
 	/* Set the base address to point to the NIC, not the "real" base! */
 	dev->base_addr = ioaddr + NIC_OFFSET;
@@ -247,7 +247,7 @@
 	ei_status.name = name;
 	ei_status.word16 = 0;		/* Agggghhhhh! Debug time: 2 days! */
 	ei_status.tx_start_page = HP_START_PG;
-	ei_status.rx_start_page = HP_START_PG + TX_2X_PAGES;
+	ei_status.rx_start_page = HP_START_PG + TX_PAGES/2;
 	ei_status.stop_page = HP_STOP_PG;
 
 	ei_status.reset_8390 = &hpp_reset_8390;
@@ -261,7 +261,7 @@
 		ei_status.block_output = &hpp_mem_block_output;
 		ei_status.get_8390_hdr = &hpp_mem_get_8390_hdr;
 		dev->mem_start = mem_start;
-		ei_status.rmem_start = dev->mem_start + TX_2X_PAGES*256;
+		ei_status.rmem_start = dev->mem_start + TX_PAGES/2*256;
 		dev->mem_end = ei_status.rmem_end
 			= dev->mem_start + (HP_STOP_PG - HP_START_PG)*256;
 	}
@@ -297,7 +297,7 @@
 
 	/* Set the wrap registers for programmed-I/O operation.   */
 	outw(HW_Page, ioaddr + HP_PAGING);
-	outw((HP_START_PG + TX_2X_PAGES) | ((HP_STOP_PG - 1) << 8), ioaddr + 14);
+	outw((HP_START_PG + TX_PAGES/2) | ((HP_STOP_PG - 1) << 8), ioaddr + 14);
 
 	/* Select the operational page. */
 	outw(Perf_Page, ioaddr + HP_PAGING);
diff -Nru a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
--- a/drivers/net/pcmcia/axnet_cs.c	2004-08-10 17:23:49 -04:00
+++ b/drivers/net/pcmcia/axnet_cs.c	2004-08-10 17:23:49 -04:00
@@ -1178,7 +1178,7 @@
 	}
 	else if (ei_local->tx2 == 0) 
 	{
-		output_page = ei_local->tx_start_page + TX_1X_PAGES;
+		output_page = ei_local->tx_start_page + TX_PAGES/2;
 		ei_local->tx2 = send_length;
 		if (ei_debug  &&  ei_local->tx1 > 0)
 			printk(KERN_DEBUG "%s: idle transmitter, tx1=%d, lasttx=%d, txing=%d.\n",
diff -Nru a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c	2004-08-10 17:23:49 -04:00
+++ b/drivers/net/tulip/tulip_core.c	2004-08-10 17:23:49 -04:00
@@ -1535,7 +1535,7 @@
 		}
 	}
 	/* Lite-On boards have the address byte-swapped. */
-	if ((dev->dev_addr[0] == 0xA0  ||  dev->dev_addr[0] == 0xC0)
+	if ((dev->dev_addr[0] == 0xA0  ||  dev->dev_addr[0] == 0xC0 || dev->dev_addr[0] == 0x02)
 		&&  dev->dev_addr[1] == 0x00)
 		for (i = 0; i < 6; i+=2) {
 			char tmp = dev->dev_addr[i];
diff -Nru a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
--- a/drivers/net/wireless/atmel.c	2004-08-10 17:23:49 -04:00
+++ b/drivers/net/wireless/atmel.c	2004-08-10 17:23:49 -04:00
@@ -2647,12 +2647,12 @@
 	memcpy(header.addr3, priv->CurrentBSSID, 6);
 	
 	if (priv->wep_is_on) {
-		auth.alg = C80211_MGMT_AAN_SHAREDKEY; 
+		auth.alg = cpu_to_le16(C80211_MGMT_AAN_SHAREDKEY); 
 		/* no WEP for authentication frames with TrSeqNo 1 */
 		if (priv->CurrentAuthentTransactionSeqNum != 1)
 			header.frame_ctl |=  cpu_to_le16(IEEE802_11_FCTL_WEP); 
 	} else {
-		auth.alg = C80211_MGMT_AAN_OPENSYSTEM;
+		auth.alg = cpu_to_le16(C80211_MGMT_AAN_OPENSYSTEM);
 	}
 
 	auth.status = 0;
diff -Nru a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
--- a/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-10 17:23:49 -04:00
+++ b/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-10 17:23:49 -04:00
@@ -436,7 +436,7 @@
 {
 	struct iw_range *range = (struct iw_range *) extra;
 	islpci_private *priv = netdev_priv(ndev);
-	char *data;
+	u8 *data;
 	int i, m, rvalue;
 	struct obj_frequencies *freq;
 	union oid_res_t r;
@@ -513,8 +513,7 @@
 	i = 0;
 	while ((i < IW_MAX_BITRATES) && (*data != 0)) {
 		/*       the result must be in bps. The card gives us 500Kbps */
-		range->bitrate[i] = (__s32) (*data >> 1);
-		range->bitrate[i] *= 1000000;
+		range->bitrate[i] = *data * 500000;
 		i++;
 		data++;
 	}
@@ -820,9 +819,11 @@
 		return mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
 	}
 
-	if ((ret =
-	     mgt_get_request(priv, DOT11_OID_SUPPORTEDRATES, 0, NULL, &r)))
+	ret = mgt_get_request(priv, DOT11_OID_SUPPORTEDRATES, 0, NULL, &r);
+	if (ret) {
+		kfree(r.ptr);
 		return ret;
+	}
 
 	rate = (u32) (vwrq->value / 500000);
 	data = r.ptr;
@@ -840,6 +841,7 @@
 	}
 
 	if (!data[i]) {
+		kfree(r.ptr);
 		return -EINVAL;
 	}
 
@@ -888,8 +890,11 @@
 	vwrq->value = r.u * 500000;
 
 	/* request the device for the enabled rates */
-	if ((rvalue = mgt_get_request(priv, DOT11_OID_RATES, 0, NULL, &r)))
+	rvalue = mgt_get_request(priv, DOT11_OID_RATES, 0, NULL, &r);
+	if (rvalue) {
+		kfree(r.ptr);
 		return rvalue;
+	}
 	data = r.ptr;
 	vwrq->fixed = (data[0] != 0) && (data[1] == 0);
 	kfree(r.ptr);
diff -Nru a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
--- a/drivers/net/wireless/prism54/islpci_dev.c	2004-08-10 17:23:49 -04:00
+++ b/drivers/net/wireless/prism54/islpci_dev.c	2004-08-10 17:23:49 -04:00
@@ -39,6 +39,7 @@
 #include "oid_mgt.h"
 
 #define ISL3877_IMAGE_FILE	"isl3877"
+#define ISL3886_IMAGE_FILE	"isl3886"
 #define ISL3890_IMAGE_FILE	"isl3890"
 
 static int prism54_bring_down(islpci_private *);
@@ -185,6 +186,9 @@
 	void *device = priv->device_base;
 	int powerstate = ISL38XX_PSM_POWERSAVE_STATE;
 
+	/* lock the interrupt handler */
+	spin_lock(&priv->slock);
+
 	/* received an interrupt request on a shared IRQ line
 	 * first check whether the device is in sleep mode */
 	reg = readl(device + ISL38XX_CTRL_STAT_REG);
@@ -194,14 +198,10 @@
 #if VERBOSE > SHOW_ERROR_MESSAGES
 		DEBUG(SHOW_TRACING, "Assuming someone else called the IRQ\n");
 #endif
+		spin_unlock(&priv->slock);
 		return IRQ_NONE;
 	}
 
-	if (islpci_get_state(priv) != PRV_STATE_SLEEP)
-		powerstate = ISL38XX_PSM_ACTIVE_STATE;
-
-	/* lock the interrupt handler */
-	spin_lock(&priv->slock);
 
 	/* check whether there is any source of interrupt on the device */
 	reg = readl(device + ISL38XX_INT_IDENT_REG);
@@ -212,6 +212,9 @@
 	reg &= ISL38XX_INT_SOURCES;
 
 	if (reg != 0) {
+		if (islpci_get_state(priv) != PRV_STATE_SLEEP)
+			powerstate = ISL38XX_PSM_ACTIVE_STATE;
+
 		/* reset the request bits in the Identification register */
 		isl38xx_w32_flush(device, reg, ISL38XX_INT_ACK_REG);
 
@@ -339,6 +342,12 @@
 			isl38xx_handle_wakeup(priv->control_block,
 					      &powerstate, priv->device_base);
 		}
+	} else {
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		DEBUG(SHOW_TRACING, "Assuming someone else called the IRQ\n");
+#endif
+		spin_unlock(&priv->slock);
+		return IRQ_NONE;
 	}
 
 	/* sleep -> ready */
@@ -856,12 +865,12 @@
 
 	/* select the firmware file depending on the device id */
 	switch (pdev->device) {
-	case PCIDEVICE_ISL3890:
-	case PCIDEVICE_3COM6001:
-		strcpy(priv->firmware, ISL3890_IMAGE_FILE);
-		break;
-	case PCIDEVICE_ISL3877:
+	case 0x3877:
 		strcpy(priv->firmware, ISL3877_IMAGE_FILE);
+		break;
+
+	case 0x3886:
+		strcpy(priv->firmware, ISL3886_IMAGE_FILE);
 		break;
 
 	default:
diff -Nru a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
--- a/drivers/net/wireless/prism54/islpci_hotplug.c	2004-08-10 17:23:49 -04:00
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c	2004-08-10 17:23:49 -04:00
@@ -44,102 +44,30 @@
  * If you have an update for this please contact prism54-devel@prism54.org 
  * The latest list can be found at http://prism54.org/supported_cards.php */
 static const struct pci_device_id prism54_id_tbl[] = {
-	/* 3COM 3CRWE154G72 Wireless LAN adapter */
-	{
-	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
-	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
-	 0, 0, 0
-	},
-
-	/* D-Link Air Plus Xtreme G A1 - DWL-g650 A1 */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_DLINK, 0x3202UL, 
-	 0, 0, 0
-	},
-
-	/* I-O Data WN-G54/CB - WN-G54/CB */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_IODATA, 0xd019UL, 
-	 0, 0, 0
-	},
-
-	/* Netgear WG511 */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_NETGEAR, 0x4800UL,
-	 0, 0, 0
-	},
-
-	/* Tekram Technology clones, Allnet, Netcomm, Zyxel */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_TTL, 0x1605UL,
-	 0, 0, 0
-	},
-
-	/* SMC2802W */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_SMC, 0x2802UL,
-	 0, 0, 0
-	},
-
-	/* SMC2835W */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_SMC, 0x2835UL,
-	 0, 0, 0
-	},
-
-	/* Corega CG-WLCB54GT */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_ATI, 0xc104UL,
-	 0, 0, 0
-	},
-
-	/* I4 Z-Com XG-600 */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_I4, 0x0014UL,
-	 0, 0, 0
-	},
-
-	/* I4 Z-Com XG-900  and clones Macer, Ovislink, Planex, Peabird, */
-	/* Sitecom, Xterasys */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_I4, 0x0020UL,
-	 0, 0, 0
-	},
-
-	/* SMC 2802W V2 */
+	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_ACCTON, 0xee03UL,
+	 0x1260, 0x3890,
+	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
 
-	/* SMC 2835W V2 */
+	/* 3COM 3CRWE154G72 Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_SMC, 0xa835UL,
+	 0x10b7, 0x6001,
+	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
 
 	/* Intersil PRISM Indigo Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3877,
+	 0x1260, 0x3877,
 	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
 
-	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
-	/* Default */
+	/* Intersil PRISM Javelin/Xbow Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 0x1260, 0x3886,
 	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
@@ -166,85 +94,6 @@
 	/* .enable_wake ; we don't support this yet */
 };
 
-static void
-prism54_get_card_model(struct net_device *ndev)
-{
-	islpci_private	*priv;
-	char		*modelp;
-	int		notwork = 0;
-
-	priv = netdev_priv(ndev);
-	switch (priv->pdev->subsystem_device) {
-	case PCIDEVICE_ISL3877:
-		modelp = "PRISM Indigo";
-		break;
-	case PCIDEVICE_ISL3886:
-		modelp = "PRISM Javelin / Xbow";
-		break;
-	case PCIDEVICE_3COM6001:
-		modelp = "3COM 3CRWE154G72";
-		break;
-	case 0x3202UL:
-		modelp = "D-Link DWL-g650 A1";
-		break;
-	case 0xd019UL:
-		modelp = "WN-G54/CB";
-		break;
-	case 0x4800UL:
-		modelp = "Netgear WG511";
-		break;
-	case 0x2802UL:
-		modelp = "SMC2802W";
-		break;
-	case 0xee03UL:
-		modelp = "SMC2802W V2";
-		notwork = 1;
-		break;
-	case 0x2835UL:
-		modelp = "SMC2835W";
-		break;
-	case 0xa835UL:
-		modelp = "SMC2835W V2";
-		notwork = 1;
-		break;
-	case 0xc104UL:
-		modelp = "CG-WLCB54GT";
-		break;
-	case 0x1605UL:
-		modelp = "Tekram Technology clone";
-		break;
-	/* Let's leave this one out for now since it seems bogus/wrong 
-	 * Even if the manufacturer did use 0x0000UL it may not be correct
-	 * by their part, therefore deserving no name ;) */
-	/*      case 0x0000UL: 
-	 *              modelp = "SparkLAN WL-850F";
-	 *              break;*/
-
-	/* We have two reported for the one below :( */
-	case 0x0014UL:
-		modelp = "I4 Z-Com XG-600 and clones";
-		break;
-	case 0x0020UL:
-		modelp = "I4 Z-Com XG-900 and clones";
-		break;
-/* Default it */
-/*
-	case PCIDEVICE_ISL3890:
-		modelp = "PRISM Duette/GT";
-		break;
-*/
-	default:
-		modelp = "PRISM Duette/GT";
-	}
-	printk(KERN_DEBUG "%s: %s driver detected card model: %s\n",
-			ndev->name, DRV_NAME, modelp);
-	if ( notwork ) {
-		printk(KERN_DEBUG "%s: %s Warning - This may not work\n",
-			ndev->name, DRV_NAME);
-	}
-	return;
-}
-
 /******************************************************************************
     Module initialization functions
 ******************************************************************************/
@@ -353,9 +202,6 @@
 	}
 
 	/* firmware upload is triggered in islpci_open */
-
-	/* Pretty card model discovery output */
-	prism54_get_card_model(ndev);
 
 	return 0;
 
diff -Nru a/drivers/net/wireless/prism54/islpci_mgt.h b/drivers/net/wireless/prism54/islpci_mgt.h
--- a/drivers/net/wireless/prism54/islpci_mgt.h	2004-08-10 17:23:49 -04:00
+++ b/drivers/net/wireless/prism54/islpci_mgt.h	2004-08-10 17:23:49 -04:00
@@ -38,21 +38,6 @@
 
 
 /* General driver definitions */
-#define PCIVENDOR_INTERSIL                      0x1260UL
-#define PCIVENDOR_3COM				0x10b7UL
-#define PCIVENDOR_DLINK				0x1186UL
-#define PCIVENDOR_I4				0x17cfUL
-#define PCIVENDOR_IODATA			0x10fcUL
-#define PCIVENDOR_NETGEAR			0x1385UL
-#define PCIVENDOR_SMC				0x10b8UL
-#define PCIVENDOR_ACCTON			0x1113UL
-#define PCIVENDOR_ATI				0x1259UL
-#define PCIVENDOR_TTL				0x16a5UL
-
-#define PCIDEVICE_ISL3877                       0x3877UL
-#define PCIDEVICE_ISL3886                       0x3886UL
-#define PCIDEVICE_ISL3890                       0x3890UL
-#define	PCIDEVICE_3COM6001			0x6001UL
 #define PCIDEVICE_LATENCY_TIMER_MIN 		0x40
 #define PCIDEVICE_LATENCY_TIMER_VAL 		0x50
 
diff -Nru a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
--- a/drivers/net/wireless/prism54/oid_mgt.c	2004-08-10 17:23:49 -04:00
+++ b/drivers/net/wireless/prism54/oid_mgt.c	2004-08-10 17:23:49 -04:00
@@ -219,7 +219,7 @@
 	OID_UNKNOWN(OID_INL_MEMORY, 0xFF020002),
 	OID_U32_C(OID_INL_MODE, 0xFF020003),
 	OID_UNKNOWN(OID_INL_COMPONENT_NR, 0xFF020004),
-	OID_UNKNOWN(OID_INL_VERSION, 0xFF020005),
+	OID_STRUCT(OID_INL_VERSION, 0xFF020005, u8[8], OID_TYPE_RAW),
 	OID_UNKNOWN(OID_INL_INTERFACE_ID, 0xFF020006),
 	OID_UNKNOWN(OID_INL_COMPONENT_ID, 0xFF020007),
 	OID_U32_C(OID_INL_CONFIG, 0xFF020008),
@@ -480,6 +480,8 @@
 
 	BUG_ON(OID_NUM_LAST <= n);
 	BUG_ON(extra > isl_oid[n].range);
+
+	res->ptr = NULL;
 
 	if (!priv->mib)
 		/* memory has been freed */
