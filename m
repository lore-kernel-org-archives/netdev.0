From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 2 Jan 2007 21:42:47 -0500
Message-ID: <20070103024247.GC5661@tuxdriver.com>
References: <20070103024117.GB5661@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4280 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961AbXACDDN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jan 2007 22:03:13 -0500
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20070103024117.GB5661@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit fe5f8e2a1c5c040209c598a28e19c55f30e1040d:
  Zhu Yi (1):
        ipw2100: Fix dropping fragmented small packet problem

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Daniel Drake (5):
      zd1211rw: Generic HMAC initialization
      zd1211rw: 2 new ZD1211B device ID's
      zd1211rw: Consistency for address space constants
      zd1211rw: Remove addressing abstraction
      zd1211rw: Add ID for Linksys WUSBF54G

John W. Linville (1):
      softmac: avoid assert in ieee80211softmac_wx_get_rate

Kai Engert (1):
      prism54: add ethtool -i interface

Larry Finger (1):
      bcm43xx: Interrogate hardware-enable switch and update LEDs

Michael Buesch (1):
      Update Prism54 MAINTAINERS entry

 MAINTAINERS                                   |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx.h        |    7 +-
 drivers/net/wireless/bcm43xx/bcm43xx_leds.c   |   11 +-
 drivers/net/wireless/bcm43xx/bcm43xx_main.c   |   36 ++++--
 drivers/net/wireless/bcm43xx/bcm43xx_radio.c  |    2 +
 drivers/net/wireless/bcm43xx/bcm43xx_radio.h  |   16 +++
 drivers/net/wireless/prism54/islpci_dev.c     |   13 ++
 drivers/net/wireless/prism54/islpci_dev.h     |    4 +
 drivers/net/wireless/prism54/islpci_hotplug.c |    3 -
 drivers/net/wireless/zd1211rw/zd_chip.c       |  126 ++++++++++----------
 drivers/net/wireless/zd1211rw/zd_chip.h       |  158 ++++++++++++++-----------
 drivers/net/wireless/zd1211rw/zd_def.h        |    2 +
 drivers/net/wireless/zd1211rw/zd_ieee80211.h  |    1 -
 drivers/net/wireless/zd1211rw/zd_rf.h         |    2 -
 drivers/net/wireless/zd1211rw/zd_types.h      |   71 -----------
 drivers/net/wireless/zd1211rw/zd_usb.c        |  127 ++------------------
 drivers/net/wireless/zd1211rw/zd_usb.h        |    6 +-
 net/ieee80211/softmac/ieee80211softmac_wx.c   |    6 +
 18 files changed, 253 insertions(+), 340 deletions(-)
 delete mode 100644 drivers/net/wireless/zd1211rw/zd_types.h

diff --git a/MAINTAINERS b/MAINTAINERS
index d5a97d3..edb4c39 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2606,7 +2606,7 @@ S:	Supported
 
 PRISM54 WIRELESS DRIVER
 P:	Prism54 Development Team
-M:	prism54-private@prism54.org
+M:	developers@islsm.org
 L:	netdev@vger.kernel.org
 W:	http://prism54.org
 S:	Maintained
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index 8286678..3a064de 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -352,6 +352,10 @@
 #define BCM43xx_UCODEFLAG_UNKPACTRL	0x0040
 #define BCM43xx_UCODEFLAG_JAPAN		0x0080
 
+/* Hardware Radio Enable masks */
+#define BCM43xx_MMIO_RADIO_HWENABLED_HI_MASK (1 << 16)
+#define BCM43xx_MMIO_RADIO_HWENABLED_LO_MASK (1 << 4)
+
 /* Generic-Interrupt reasons. */
 #define BCM43xx_IRQ_READY		(1 << 0)
 #define BCM43xx_IRQ_BEACON		(1 << 1)
@@ -758,7 +762,8 @@ struct bcm43xx_private {
 	    bad_frames_preempt:1,	/* Use "Bad Frames Preemption" (default off) */
 	    reg124_set_0x4:1,		/* Some variable to keep track of IRQ stuff. */
 	    short_preamble:1,		/* TRUE, if short preamble is enabled. */
-	    firmware_norelease:1;	/* Do not release the firmware. Used on suspend. */
+	    firmware_norelease:1,	/* Do not release the firmware. Used on suspend. */
+	    radio_hw_enable:1;		/* TRUE if radio is hardware enabled */
 
 	struct bcm43xx_stats stats;
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
index 7d383a2..8f198be 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
@@ -26,6 +26,7 @@
 */
 
 #include "bcm43xx_leds.h"
+#include "bcm43xx_radio.h"
 #include "bcm43xx.h"
 
 #include <asm/bitops.h>
@@ -108,6 +109,7 @@ static void bcm43xx_led_init_hardcoded(struct bcm43xx_private *bcm,
 	switch (led_index) {
 	case 0:
 		led->behaviour = BCM43xx_LED_ACTIVITY;
+		led->activelow = 1;
 		if (bcm->board_vendor == PCI_VENDOR_ID_COMPAQ)
 			led->behaviour = BCM43xx_LED_RADIO_ALL;
 		break;
@@ -199,20 +201,21 @@ void bcm43xx_leds_update(struct bcm43xx_private *bcm, int activity)
 			turn_on = activity;
 			break;
 		case BCM43xx_LED_RADIO_ALL:
-			turn_on = radio->enabled;
+			turn_on = radio->enabled && bcm43xx_is_hw_radio_enabled(bcm);
 			break;
 		case BCM43xx_LED_RADIO_A:
 		case BCM43xx_LED_BCM4303_2:
-			turn_on = (radio->enabled && phy->type == BCM43xx_PHYTYPE_A);
+			turn_on = (radio->enabled && bcm43xx_is_hw_radio_enabled(bcm) &&
+				   phy->type == BCM43xx_PHYTYPE_A);
 			break;
 		case BCM43xx_LED_RADIO_B:
 		case BCM43xx_LED_BCM4303_1:
-			turn_on = (radio->enabled &&
+			turn_on = (radio->enabled && bcm43xx_is_hw_radio_enabled(bcm) &&
 				   (phy->type == BCM43xx_PHYTYPE_B ||
 				    phy->type == BCM43xx_PHYTYPE_G));
 			break;
 		case BCM43xx_LED_MODE_BG:
-			if (phy->type == BCM43xx_PHYTYPE_G &&
+			if (phy->type == BCM43xx_PHYTYPE_G && bcm43xx_is_hw_radio_enabled(bcm) &&
 			    1/*FIXME: using G rates.*/)
 				turn_on = 1;
 			break;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 2ec2e5a..763625a 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2441,6 +2441,9 @@ static int bcm43xx_chip_init(struct bcm43xx_private *bcm)
 	if (err)
 		goto err_gpio_cleanup;
 	bcm43xx_radio_turn_on(bcm);
+	bcm->radio_hw_enable = bcm43xx_is_hw_radio_enabled(bcm);
+	dprintk(KERN_INFO PFX "Radio %s by hardware\n",
+		(bcm->radio_hw_enable == 0) ? "disabled" : "enabled");
 
 	bcm43xx_write16(bcm, 0x03E6, 0x0000);
 	err = bcm43xx_phy_init(bcm);
@@ -3172,9 +3175,24 @@ static void bcm43xx_periodic_every30sec(struct bcm43xx_private *bcm)
 
 static void bcm43xx_periodic_every15sec(struct bcm43xx_private *bcm)
 {
+	bcm43xx_phy_xmitpower(bcm); //FIXME: unless scanning?
+	//TODO for APHY (temperature?)
+}
+
+static void bcm43xx_periodic_every1sec(struct bcm43xx_private *bcm)
+{
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
+	int radio_hw_enable;
 
+	/* check if radio hardware enabled status changed */
+	radio_hw_enable = bcm43xx_is_hw_radio_enabled(bcm);
+	if (unlikely(bcm->radio_hw_enable != radio_hw_enable)) {
+		bcm->radio_hw_enable = radio_hw_enable;
+		dprintk(KERN_INFO PFX "Radio hardware status changed to %s\n",
+		       (radio_hw_enable == 0) ? "disabled" : "enabled");
+		bcm43xx_leds_update(bcm, 0);
+	}
 	if (phy->type == BCM43xx_PHYTYPE_G) {
 		//TODO: update_aci_moving_average
 		if (radio->aci_enable && radio->aci_wlan_automatic) {
@@ -3198,21 +3216,21 @@ static void bcm43xx_periodic_every15sec(struct bcm43xx_private *bcm)
 			//TODO: implement rev1 workaround
 		}
 	}
-	bcm43xx_phy_xmitpower(bcm); //FIXME: unless scanning?
-	//TODO for APHY (temperature?)
 }
 
 static void do_periodic_work(struct bcm43xx_private *bcm)
 {
-	if (bcm->periodic_state % 8 == 0)
+	if (bcm->periodic_state % 120 == 0)
 		bcm43xx_periodic_every120sec(bcm);
-	if (bcm->periodic_state % 4 == 0)
+	if (bcm->periodic_state % 60 == 0)
 		bcm43xx_periodic_every60sec(bcm);
-	if (bcm->periodic_state % 2 == 0)
+	if (bcm->periodic_state % 30 == 0)
 		bcm43xx_periodic_every30sec(bcm);
-	bcm43xx_periodic_every15sec(bcm);
+	if (bcm->periodic_state % 15 == 0)
+		bcm43xx_periodic_every15sec(bcm);
+	bcm43xx_periodic_every1sec(bcm);
 
-	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
+	schedule_delayed_work(&bcm->periodic_work, HZ);
 }
 
 static void bcm43xx_periodic_work_handler(struct work_struct *work)
@@ -3225,7 +3243,7 @@ static void bcm43xx_periodic_work_handler(struct work_struct *work)
 	unsigned long orig_trans_start = 0;
 
 	mutex_lock(&bcm->mutex);
-	if (unlikely(bcm->periodic_state % 4 == 0)) {
+	if (unlikely(bcm->periodic_state % 60 == 0)) {
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
@@ -3257,7 +3275,7 @@ static void bcm43xx_periodic_work_handler(struct work_struct *work)
 
 	do_periodic_work(bcm);
 
-	if (unlikely(bcm->periodic_state % 4 == 0)) {
+	if (unlikely(bcm->periodic_state % 60 == 0)) {
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 		tasklet_enable(&bcm->isr_tasklet);
 		bcm43xx_interrupt_enable(bcm, savedirqs);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
index bb9c484..af19a07 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
@@ -1981,6 +1981,7 @@ void bcm43xx_radio_turn_on(struct bcm43xx_private *bcm)
 	}
 	radio->enabled = 1;
 	dprintk(KERN_INFO PFX "Radio turned on\n");
+	bcm43xx_leds_update(bcm, 0);
 }
 	
 void bcm43xx_radio_turn_off(struct bcm43xx_private *bcm)
@@ -2001,6 +2002,7 @@ void bcm43xx_radio_turn_off(struct bcm43xx_private *bcm)
 		bcm43xx_phy_write(bcm, 0x0015, 0xAA00);
 	radio->enabled = 0;
 	dprintk(KERN_INFO PFX "Radio turned off\n");
+	bcm43xx_leds_update(bcm, 0);
 }
 
 void bcm43xx_radio_clear_tssi(struct bcm43xx_private *bcm)
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_radio.h b/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
index 9ed1803..77a98a5 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
@@ -65,6 +65,22 @@ void bcm43xx_radio_init2060(struct bcm43xx_private *bcm);
 void bcm43xx_radio_turn_on(struct bcm43xx_private *bcm);
 void bcm43xx_radio_turn_off(struct bcm43xx_private *bcm);
 
+static inline
+int bcm43xx_is_hw_radio_enabled(struct bcm43xx_private *bcm)
+{
+	/* function to return state of hardware enable of radio
+	 * returns 0 if radio disabled, 1 if radio enabled
+	 */
+	if (bcm->current_core->rev >= 3)
+		return ((bcm43xx_read32(bcm, BCM43xx_MMIO_RADIO_HWENABLED_HI)
+					& BCM43xx_MMIO_RADIO_HWENABLED_HI_MASK)
+					== 0) ? 1 : 0;
+	else
+		return ((bcm43xx_read16(bcm, BCM43xx_MMIO_RADIO_HWENABLED_LO)
+					& BCM43xx_MMIO_RADIO_HWENABLED_LO_MASK)
+					== 0) ? 0 : 1;
+}
+
 int bcm43xx_radio_selectchannel(struct bcm43xx_private *bcm, u8 channel,
 				int synthetic_pu_workaround);
 
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index f057fd9..a037b11 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -21,6 +21,7 @@
 #include <linux/module.h>
 
 #include <linux/netdevice.h>
+#include <linux/ethtool.h>
 #include <linux/pci.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
@@ -787,6 +788,17 @@ islpci_set_multicast_list(struct net_device *dev)
 }
 #endif
 
+static void islpci_ethtool_get_drvinfo(struct net_device *dev,
+                                       struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+}
+
+static struct ethtool_ops islpci_ethtool_ops = {
+	.get_drvinfo = islpci_ethtool_get_drvinfo,
+};
+
 struct net_device *
 islpci_setup(struct pci_dev *pdev)
 {
@@ -813,6 +825,7 @@ islpci_setup(struct pci_dev *pdev)
 	ndev->do_ioctl = &prism54_ioctl;
 	ndev->wireless_handlers =
 	    (struct iw_handler_def *) &prism54_handler_def;
+	ndev->ethtool_ops = &islpci_ethtool_ops;
 
 	ndev->hard_start_xmit = &islpci_eth_transmit;
 	/* ndev->set_multicast_list = &islpci_set_multicast_list; */
diff --git a/drivers/net/wireless/prism54/islpci_dev.h b/drivers/net/wireless/prism54/islpci_dev.h
index a9aa166..736666d 100644
--- a/drivers/net/wireless/prism54/islpci_dev.h
+++ b/drivers/net/wireless/prism54/islpci_dev.h
@@ -211,4 +211,8 @@ islpci_trigger(islpci_private *priv)
 
 int islpci_free_memory(islpci_private *);
 struct net_device *islpci_setup(struct pci_dev *);
+
+#define DRV_NAME	"prism54"
+#define DRV_VERSION	"1.2"
+
 #endif				/* _ISLPCI_DEV_H */
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
index 58257b4..3dcb13b 100644
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -28,9 +28,6 @@
 #include "islpci_mgt.h"		/* for pc_debug */
 #include "isl_oid.h"
 
-#define DRV_NAME	"prism54"
-#define DRV_VERSION	"1.2"
-
 MODULE_AUTHOR("[Intersil] R.Bastings and W.Termorshuizen, The prism54.org Development Team <prism54-devel@prism54.org>");
 MODULE_DESCRIPTION("The Prism54 802.11 Wireless LAN adapter");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 78ea72f..12dfc0b 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -84,6 +84,18 @@ static void print_id(struct zd_chip *chip)
 	dev_info(zd_chip_dev(chip), "%s\n", buffer);
 }
 
+static zd_addr_t inc_addr(zd_addr_t addr)
+{
+	u16 a = (u16)addr;
+	/* Control registers use byte addressing, but everything else uses word
+	 * addressing. */
+	if ((a & 0xf000) == CR_START)
+		a += 2;
+	else
+		a += 1;
+	return (zd_addr_t)a;
+}
+
 /* Read a variable number of 32-bit values. Parameter count is not allowed to
  * exceed USB_MAX_IOREAD32_COUNT.
  */
@@ -114,7 +126,7 @@ int zd_ioread32v_locked(struct zd_chip *chip, u32 *values, const zd_addr_t *addr
 	for (i = 0; i < count; i++) {
 		int j = 2*i;
 		/* We read the high word always first. */
-		a16[j] = zd_inc_word(addr[i]);
+		a16[j] = inc_addr(addr[i]);
 		a16[j+1] = addr[i];
 	}
 
@@ -163,7 +175,7 @@ int _zd_iowrite32v_locked(struct zd_chip *chip, const struct zd_ioreq32 *ioreqs,
 		j = 2*i;
 		/* We write the high word always first. */
 		ioreqs16[j].value   = ioreqs[i].value >> 16;
-		ioreqs16[j].addr    = zd_inc_word(ioreqs[i].addr);
+		ioreqs16[j].addr    = inc_addr(ioreqs[i].addr);
 		ioreqs16[j+1].value = ioreqs[i].value;
 		ioreqs16[j+1].addr  = ioreqs[i].addr;
 	}
@@ -466,7 +478,8 @@ static int read_values(struct zd_chip *chip, u8 *values, size_t count,
 
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
 	for (i = 0;;) {
-		r = zd_ioread32_locked(chip, &v, e2p_addr+i/2);
+		r = zd_ioread32_locked(chip, &v,
+			               (zd_addr_t)((u16)e2p_addr+i/2));
 		if (r)
 			return r;
 		v -= guard;
@@ -798,47 +811,18 @@ static int hw_reset_phy(struct zd_chip *chip)
 static int zd1211_hw_init_hmac(struct zd_chip *chip)
 {
 	static const struct zd_ioreq32 ioreqs[] = {
-		{ CR_ACK_TIMEOUT_EXT,		0x20 },
-		{ CR_ADDA_MBIAS_WARMTIME,	0x30000808 },
 		{ CR_ZD1211_RETRY_MAX,		0x2 },
-		{ CR_SNIFFER_ON,		0 },
-		{ CR_RX_FILTER,			STA_RX_FILTER },
-		{ CR_GROUP_HASH_P1,		0x00 },
-		{ CR_GROUP_HASH_P2,		0x80000000 },
-		{ CR_REG1,			0xa4 },
-		{ CR_ADDA_PWR_DWN,		0x7f },
-		{ CR_BCN_PLCP_CFG,		0x00f00401 },
-		{ CR_PHY_DELAY,			0x00 },
-		{ CR_ACK_TIMEOUT_EXT,		0x80 },
-		{ CR_ADDA_PWR_DWN,		0x00 },
-		{ CR_ACK_TIME_80211,		0x100 },
-		{ CR_RX_PE_DELAY,		0x70 },
-		{ CR_PS_CTRL,			0x10000000 },
-		{ CR_RTS_CTS_RATE,		0x02030203 },
 		{ CR_RX_THRESHOLD,		0x000c0640 },
-		{ CR_AFTER_PNP,			0x1 },
-		{ CR_WEP_PROTECT,		0x114 },
 	};
 
-	int r;
-
 	dev_dbg_f(zd_chip_dev(chip), "\n");
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
-	r = zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
-#ifdef DEBUG
-	if (r) {
-		dev_err(zd_chip_dev(chip),
-			"error in zd_iowrite32a_locked. Error number %d\n", r);
-	}
-#endif /* DEBUG */
-	return r;
+	return zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
 }
 
 static int zd1211b_hw_init_hmac(struct zd_chip *chip)
 {
 	static const struct zd_ioreq32 ioreqs[] = {
-		{ CR_ACK_TIMEOUT_EXT,		0x20 },
-		{ CR_ADDA_MBIAS_WARMTIME,	0x30000808 },
 		{ CR_ZD1211B_RETRY_MAX,		0x02020202 },
 		{ CR_ZD1211B_TX_PWR_CTL4,	0x007f003f },
 		{ CR_ZD1211B_TX_PWR_CTL3,	0x007f003f },
@@ -847,6 +831,20 @@ static int zd1211b_hw_init_hmac(struct zd_chip *chip)
 		{ CR_ZD1211B_AIFS_CTL1,		0x00280028 },
 		{ CR_ZD1211B_AIFS_CTL2,		0x008C003C },
 		{ CR_ZD1211B_TXOP,		0x01800824 },
+		{ CR_RX_THRESHOLD,		0x000c0eff, },
+	};
+
+	dev_dbg_f(zd_chip_dev(chip), "\n");
+	ZD_ASSERT(mutex_is_locked(&chip->mutex));
+	return zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+}
+
+static int hw_init_hmac(struct zd_chip *chip)
+{
+	int r;
+	static const struct zd_ioreq32 ioreqs[] = {
+		{ CR_ACK_TIMEOUT_EXT,		0x20 },
+		{ CR_ADDA_MBIAS_WARMTIME,	0x30000808 },
 		{ CR_SNIFFER_ON,		0 },
 		{ CR_RX_FILTER,			STA_RX_FILTER },
 		{ CR_GROUP_HASH_P1,		0x00 },
@@ -861,25 +859,16 @@ static int zd1211b_hw_init_hmac(struct zd_chip *chip)
 		{ CR_RX_PE_DELAY,		0x70 },
 		{ CR_PS_CTRL,			0x10000000 },
 		{ CR_RTS_CTS_RATE,		0x02030203 },
-		{ CR_RX_THRESHOLD,		0x000c0eff, },
 		{ CR_AFTER_PNP,			0x1 },
 		{ CR_WEP_PROTECT,		0x114 },
+		{ CR_IFS_VALUE,			IFS_VALUE_DEFAULT },
 	};
 
-	int r;
-
-	dev_dbg_f(zd_chip_dev(chip), "\n");
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
 	r = zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
-	if (r) {
-		dev_dbg_f(zd_chip_dev(chip),
-			"error in zd_iowrite32a_locked. Error number %d\n", r);
-	}
-	return r;
-}
+	if (r)
+		return r;
 
-static int hw_init_hmac(struct zd_chip *chip)
-{
 	return chip->is_zd1211b ?
 		zd1211b_hw_init_hmac(chip) : zd1211_hw_init_hmac(chip);
 }
@@ -974,16 +963,14 @@ static int hw_init(struct zd_chip *chip)
 	if (r)
 		return r;
 
-	/* Although the vendor driver defaults to a different value during
-	 * init, it overwrites the IFS value with the following every time
-	 * the channel changes. We should aim to be more intelligent... */
-	r = zd_iowrite32_locked(chip, IFS_VALUE_DEFAULT, CR_IFS_VALUE);
-	if (r)
-		return r;
-
 	return set_beacon_interval(chip, 100);
 }
 
+static zd_addr_t fw_reg_addr(struct zd_chip *chip, u16 offset)
+{
+	return (zd_addr_t)((u16)chip->fw_regs_base + offset);
+}
+
 #ifdef DEBUG
 static int dump_cr(struct zd_chip *chip, const zd_addr_t addr,
 	           const char *addr_string)
@@ -1018,9 +1005,11 @@ static int test_init(struct zd_chip *chip)
 
 static void dump_fw_registers(struct zd_chip *chip)
 {
-	static const zd_addr_t addr[4] = {
-		FW_FIRMWARE_VER, FW_USB_SPEED, FW_FIX_TX_RATE,
-		FW_LINK_STATUS
+	const zd_addr_t addr[4] = {
+		fw_reg_addr(chip, FW_REG_FIRMWARE_VER),
+		fw_reg_addr(chip, FW_REG_USB_SPEED),
+		fw_reg_addr(chip, FW_REG_FIX_TX_RATE),
+		fw_reg_addr(chip, FW_REG_LED_LINK_STATUS),
 	};
 
 	int r;
@@ -1046,7 +1035,8 @@ static int print_fw_version(struct zd_chip *chip)
 	int r;
 	u16 version;
 
-	r = zd_ioread16_locked(chip, &version, FW_FIRMWARE_VER);
+	r = zd_ioread16_locked(chip, &version,
+		fw_reg_addr(chip, FW_REG_FIRMWARE_VER));
 	if (r)
 		return r;
 
@@ -1126,6 +1116,22 @@ int zd_chip_disable_hwint(struct zd_chip *chip)
 	return r;
 }
 
+static int read_fw_regs_offset(struct zd_chip *chip)
+{
+	int r;
+
+	ZD_ASSERT(mutex_is_locked(&chip->mutex));
+	r = zd_ioread16_locked(chip, (u16*)&chip->fw_regs_base,
+		               FWRAW_REGS_ADDR);
+	if (r)
+		return r;
+	dev_dbg_f(zd_chip_dev(chip), "fw_regs_base: %#06hx\n",
+		  (u16)chip->fw_regs_base);
+
+	return 0;
+}
+
+
 int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
 {
 	int r;
@@ -1145,7 +1151,7 @@ int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
 	if (r)
 		goto out;
 
-	r = zd_usb_init_hw(&chip->usb);
+	r = read_fw_regs_offset(chip);
 	if (r)
 		goto out;
 
@@ -1325,15 +1331,15 @@ u8 zd_chip_get_channel(struct zd_chip *chip)
 
 int zd_chip_control_leds(struct zd_chip *chip, enum led_status status)
 {
-	static const zd_addr_t a[] = {
-		FW_LINK_STATUS,
+	const zd_addr_t a[] = {
+		fw_reg_addr(chip, FW_REG_LED_LINK_STATUS),
 		CR_LED,
 	};
 
 	int r;
 	u16 v[ARRAY_SIZE(a)];
 	struct zd_ioreq16 ioreqs[ARRAY_SIZE(a)] = {
-		[0] = { FW_LINK_STATUS },
+		[0] = { fw_reg_addr(chip, FW_REG_LED_LINK_STATUS) },
 		[1] = { CR_LED },
 	};
 	u16 other_led;
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index a4e3cee..b07569e 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -18,7 +18,6 @@
 #ifndef _ZD_CHIP_H
 #define _ZD_CHIP_H
 
-#include "zd_types.h"
 #include "zd_rf.h"
 #include "zd_usb.h"
 
@@ -27,6 +26,37 @@
  * adds a processor for handling the USB protocol.
  */
 
+/* Address space */
+enum {
+	/* CONTROL REGISTERS */
+	CR_START			= 0x9000,
+
+
+	/* FIRMWARE */
+	FW_START			= 0xee00,
+
+
+	/* EEPROM */
+	E2P_START			= 0xf800,
+	E2P_LEN				= 0x800,
+
+	/* EEPROM layout */
+	E2P_LOAD_CODE_LEN		= 0xe,		/* base 0xf800 */
+	E2P_LOAD_VECT_LEN		= 0x9,		/* base 0xf80e */
+	/* E2P_DATA indexes into this */
+	E2P_DATA_LEN			= 0x7e,		/* base 0xf817 */
+	E2P_BOOT_CODE_LEN		= 0x760,	/* base 0xf895 */
+	E2P_INTR_VECT_LEN		= 0xb,		/* base 0xfff5 */
+
+	/* Some precomputed offsets into the EEPROM */
+	E2P_DATA_OFFSET			= E2P_LOAD_CODE_LEN + E2P_LOAD_VECT_LEN,
+	E2P_BOOT_CODE_OFFSET		= E2P_DATA_OFFSET + E2P_DATA_LEN,
+};
+
+#define CTL_REG(offset) ((zd_addr_t)(CR_START + (offset)))
+#define E2P_DATA(offset) ((zd_addr_t)(E2P_START + E2P_DATA_OFFSET + (offset)))
+#define FWRAW_DATA(offset) ((zd_addr_t)(FW_START + (offset)))
+
 /* 8-bit hardware registers */
 #define CR0   CTL_REG(0x0000)
 #define CR1   CTL_REG(0x0004)
@@ -302,7 +332,7 @@
 
 #define CR_MAX_PHY_REG 255
 
-/* Taken from the ZYDAS driver, not all of them are relevant for the ZSD1211
+/* Taken from the ZYDAS driver, not all of them are relevant for the ZD1211
  * driver.
  */
 
@@ -594,81 +624,71 @@
 /*
  * Upper 16 bit contains the regulatory domain.
  */
-#define E2P_SUBID		E2P_REG(0x00)
-#define E2P_POD			E2P_REG(0x02)
-#define E2P_MAC_ADDR_P1		E2P_REG(0x04)
-#define E2P_MAC_ADDR_P2		E2P_REG(0x06)
-#define E2P_PWR_CAL_VALUE1	E2P_REG(0x08)
-#define E2P_PWR_CAL_VALUE2	E2P_REG(0x0a)
-#define E2P_PWR_CAL_VALUE3	E2P_REG(0x0c)
-#define E2P_PWR_CAL_VALUE4      E2P_REG(0x0e)
-#define E2P_PWR_INT_VALUE1	E2P_REG(0x10)
-#define E2P_PWR_INT_VALUE2	E2P_REG(0x12)
-#define E2P_PWR_INT_VALUE3	E2P_REG(0x14)
-#define E2P_PWR_INT_VALUE4	E2P_REG(0x16)
+#define E2P_SUBID		E2P_DATA(0x00)
+#define E2P_POD			E2P_DATA(0x02)
+#define E2P_MAC_ADDR_P1		E2P_DATA(0x04)
+#define E2P_MAC_ADDR_P2		E2P_DATA(0x06)
+#define E2P_PWR_CAL_VALUE1	E2P_DATA(0x08)
+#define E2P_PWR_CAL_VALUE2	E2P_DATA(0x0a)
+#define E2P_PWR_CAL_VALUE3	E2P_DATA(0x0c)
+#define E2P_PWR_CAL_VALUE4      E2P_DATA(0x0e)
+#define E2P_PWR_INT_VALUE1	E2P_DATA(0x10)
+#define E2P_PWR_INT_VALUE2	E2P_DATA(0x12)
+#define E2P_PWR_INT_VALUE3	E2P_DATA(0x14)
+#define E2P_PWR_INT_VALUE4	E2P_DATA(0x16)
 
 /* Contains a bit for each allowed channel. It gives for Europe (ETSI 0x30)
  * also only 11 channels. */
-#define E2P_ALLOWED_CHANNEL	E2P_REG(0x18)
-
-#define E2P_PHY_REG		E2P_REG(0x1a)
-#define E2P_DEVICE_VER		E2P_REG(0x20)
-#define E2P_36M_CAL_VALUE1	E2P_REG(0x28)
-#define E2P_36M_CAL_VALUE2      E2P_REG(0x2a)
-#define E2P_36M_CAL_VALUE3      E2P_REG(0x2c)
-#define E2P_36M_CAL_VALUE4	E2P_REG(0x2e)
-#define E2P_11A_INT_VALUE1	E2P_REG(0x30)
-#define E2P_11A_INT_VALUE2	E2P_REG(0x32)
-#define E2P_11A_INT_VALUE3	E2P_REG(0x34)
-#define E2P_11A_INT_VALUE4	E2P_REG(0x36)
-#define E2P_48M_CAL_VALUE1	E2P_REG(0x38)
-#define E2P_48M_CAL_VALUE2	E2P_REG(0x3a)
-#define E2P_48M_CAL_VALUE3	E2P_REG(0x3c)
-#define E2P_48M_CAL_VALUE4	E2P_REG(0x3e)
-#define E2P_48M_INT_VALUE1	E2P_REG(0x40)
-#define E2P_48M_INT_VALUE2	E2P_REG(0x42)
-#define E2P_48M_INT_VALUE3	E2P_REG(0x44)
-#define E2P_48M_INT_VALUE4	E2P_REG(0x46)
-#define E2P_54M_CAL_VALUE1	E2P_REG(0x48)	/* ??? */
-#define E2P_54M_CAL_VALUE2	E2P_REG(0x4a)
-#define E2P_54M_CAL_VALUE3	E2P_REG(0x4c)
-#define E2P_54M_CAL_VALUE4	E2P_REG(0x4e)
-#define E2P_54M_INT_VALUE1	E2P_REG(0x50)
-#define E2P_54M_INT_VALUE2	E2P_REG(0x52)
-#define E2P_54M_INT_VALUE3	E2P_REG(0x54)
-#define E2P_54M_INT_VALUE4	E2P_REG(0x56)
-
-/* All 16 bit values */
-#define FW_FIRMWARE_VER         FW_REG(0)
-/* non-zero if USB high speed connection */
-#define FW_USB_SPEED            FW_REG(1)
-#define FW_FIX_TX_RATE          FW_REG(2)
-/* Seems to be able to control LEDs over the firmware */
-#define FW_LINK_STATUS          FW_REG(3)
-#define FW_SOFT_RESET           FW_REG(4)
-#define FW_FLASH_CHK            FW_REG(5)
+#define E2P_ALLOWED_CHANNEL	E2P_DATA(0x18)
+
+#define E2P_PHY_REG		E2P_DATA(0x1a)
+#define E2P_DEVICE_VER		E2P_DATA(0x20)
+#define E2P_36M_CAL_VALUE1	E2P_DATA(0x28)
+#define E2P_36M_CAL_VALUE2      E2P_DATA(0x2a)
+#define E2P_36M_CAL_VALUE3      E2P_DATA(0x2c)
+#define E2P_36M_CAL_VALUE4	E2P_DATA(0x2e)
+#define E2P_11A_INT_VALUE1	E2P_DATA(0x30)
+#define E2P_11A_INT_VALUE2	E2P_DATA(0x32)
+#define E2P_11A_INT_VALUE3	E2P_DATA(0x34)
+#define E2P_11A_INT_VALUE4	E2P_DATA(0x36)
+#define E2P_48M_CAL_VALUE1	E2P_DATA(0x38)
+#define E2P_48M_CAL_VALUE2	E2P_DATA(0x3a)
+#define E2P_48M_CAL_VALUE3	E2P_DATA(0x3c)
+#define E2P_48M_CAL_VALUE4	E2P_DATA(0x3e)
+#define E2P_48M_INT_VALUE1	E2P_DATA(0x40)
+#define E2P_48M_INT_VALUE2	E2P_DATA(0x42)
+#define E2P_48M_INT_VALUE3	E2P_DATA(0x44)
+#define E2P_48M_INT_VALUE4	E2P_DATA(0x46)
+#define E2P_54M_CAL_VALUE1	E2P_DATA(0x48)	/* ??? */
+#define E2P_54M_CAL_VALUE2	E2P_DATA(0x4a)
+#define E2P_54M_CAL_VALUE3	E2P_DATA(0x4c)
+#define E2P_54M_CAL_VALUE4	E2P_DATA(0x4e)
+#define E2P_54M_INT_VALUE1	E2P_DATA(0x50)
+#define E2P_54M_INT_VALUE2	E2P_DATA(0x52)
+#define E2P_54M_INT_VALUE3	E2P_DATA(0x54)
+#define E2P_54M_INT_VALUE4	E2P_DATA(0x56)
+
+/* This word contains the base address of the FW_REG_ registers below */
+#define FWRAW_REGS_ADDR		FWRAW_DATA(0x1d)
+
+/* All 16 bit values, offset from the address in FWRAW_REGS_ADDR */
+enum {
+	FW_REG_FIRMWARE_VER	= 0,
+	/* non-zero if USB high speed connection */
+	FW_REG_USB_SPEED	= 1,
+	FW_REG_FIX_TX_RATE	= 2,
+	/* Seems to be able to control LEDs over the firmware */
+	FW_REG_LED_LINK_STATUS	= 3,
+	FW_REG_SOFT_RESET	= 4,
+	FW_REG_FLASH_CHK	= 5,
+};
 
+/* Values for FW_LINK_STATUS */
 #define FW_LINK_OFF		0x0
 #define FW_LINK_TX		0x1
 /* 0x2 - link led on? */
 
 enum {
-	CR_BASE_OFFSET			= 0x9000,
-	FW_START_OFFSET			= 0xee00,
-	FW_BASE_ADDR_OFFSET		= FW_START_OFFSET + 0x1d,
-	EEPROM_START_OFFSET		= 0xf800,
-	EEPROM_SIZE			= 0x800, /* words */
-	LOAD_CODE_SIZE			= 0xe, /* words */
-	LOAD_VECT_SIZE			= 0x10000 - 0xfff7, /* words */
-	EEPROM_REGS_OFFSET		= LOAD_CODE_SIZE + LOAD_VECT_SIZE,
-	EEPROM_REGS_SIZE		= 0x7e, /* words */
-	E2P_BASE_OFFSET			= EEPROM_START_OFFSET +
-		                          EEPROM_REGS_OFFSET,
-};
-
-#define FW_REG_TABLE_ADDR	USB_ADDR(FW_START_OFFSET + 0x1d)
-
-enum {
 	/* indices for ofdm_cal_values */
 	OFDM_36M_INDEX = 0,
 	OFDM_48M_INDEX = 1,
@@ -679,6 +699,8 @@ struct zd_chip {
 	struct zd_usb usb;
 	struct zd_rf rf;
 	struct mutex mutex;
+	/* Base address of FW_REG_ registers */
+	zd_addr_t fw_regs_base;
 	u8 e2p_mac[ETH_ALEN];
 	/* EepSetPoint in the vendor driver */
 	u8 pwr_cal_values[E2P_CHANNEL_COUNT];
diff --git a/drivers/net/wireless/zd1211rw/zd_def.h b/drivers/net/wireless/zd1211rw/zd_def.h
index fb22f62..deb99d1 100644
--- a/drivers/net/wireless/zd1211rw/zd_def.h
+++ b/drivers/net/wireless/zd1211rw/zd_def.h
@@ -23,6 +23,8 @@
 #include <linux/device.h>
 #include <linux/kernel.h>
 
+typedef u16 __nocast zd_addr_t;
+
 #define dev_printk_f(level, dev, fmt, args...) \
 	dev_printk(level, dev, "%s() " fmt, __func__, ##args)
 
diff --git a/drivers/net/wireless/zd1211rw/zd_ieee80211.h b/drivers/net/wireless/zd1211rw/zd_ieee80211.h
index 26b8298..c4f36d3 100644
--- a/drivers/net/wireless/zd1211rw/zd_ieee80211.h
+++ b/drivers/net/wireless/zd1211rw/zd_ieee80211.h
@@ -2,7 +2,6 @@
 #define _ZD_IEEE80211_H
 
 #include <net/ieee80211.h>
-#include "zd_types.h"
 
 /* Additional definitions from the standards.
  */
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.h b/drivers/net/wireless/zd1211rw/zd_rf.h
index 676b373..a57732e 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf.h
+++ b/drivers/net/wireless/zd1211rw/zd_rf.h
@@ -18,8 +18,6 @@
 #ifndef _ZD_RF_H
 #define _ZD_RF_H
 
-#include "zd_types.h"
-
 #define UW2451_RF			0x2
 #define UCHIP_RF			0x3
 #define AL2230_RF			0x4
diff --git a/drivers/net/wireless/zd1211rw/zd_types.h b/drivers/net/wireless/zd1211rw/zd_types.h
deleted file mode 100644
index 0155a15..0000000
--- a/drivers/net/wireless/zd1211rw/zd_types.h
+++ /dev/null
@@ -1,71 +0,0 @@
-/* zd_types.h
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
- */
-
-#ifndef _ZD_TYPES_H
-#define _ZD_TYPES_H
-
-#include <linux/types.h>
-
-/* We have three register spaces mapped into the overall USB address space of
- * 64K words (16-bit values). There is the control register space of
- * double-word registers, the eeprom register space and the firmware register
- * space. The control register space is byte mapped, the others are word
- * mapped.
- *
- * For that reason, we are using byte offsets for control registers and word
- * offsets for everything else.
- */
-
-typedef u32 __nocast zd_addr_t;
-
-enum {
-	ADDR_BASE_MASK		= 0xff000000,
-	ADDR_OFFSET_MASK	= 0x0000ffff,
-	ADDR_ZERO_MASK		= 0x00ff0000,
-	NULL_BASE		= 0x00000000,
-	USB_BASE		= 0x01000000,
-	CR_BASE			= 0x02000000,
-	CR_MAX_OFFSET		= 0x0b30,
-	E2P_BASE		= 0x03000000,
-	E2P_MAX_OFFSET		= 0x007e,
-	FW_BASE			= 0x04000000,
-	FW_MAX_OFFSET		= 0x0005,
-};
-
-#define ZD_ADDR_BASE(addr) ((u32)(addr) & ADDR_BASE_MASK)
-#define ZD_OFFSET(addr) ((u32)(addr) & ADDR_OFFSET_MASK)
-
-#define ZD_ADDR(base, offset) \
-	((zd_addr_t)(((base) & ADDR_BASE_MASK) | ((offset) & ADDR_OFFSET_MASK)))
-
-#define ZD_NULL_ADDR    ((zd_addr_t)0)
-#define USB_REG(offset)  ZD_ADDR(USB_BASE, offset)	/* word addressing */
-#define CTL_REG(offset)  ZD_ADDR(CR_BASE, offset)	/* byte addressing */
-#define E2P_REG(offset)  ZD_ADDR(E2P_BASE, offset)	/* word addressing */
-#define FW_REG(offset)   ZD_ADDR(FW_BASE, offset)	/* word addressing */
-
-static inline zd_addr_t zd_inc_word(zd_addr_t addr)
-{
-	u32 base = ZD_ADDR_BASE(addr);
-	u32 offset = ZD_OFFSET(addr);
-
-	offset += base == CR_BASE ? 2 : 1;
-
-	return base | offset;
-}
-
-#endif /* _ZD_TYPES_H */
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 605e96e..1b8ea88 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -58,6 +58,9 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x1582, 0x6003), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x050d, 0x705c), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x083a, 0x4505), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0471, 0x1236), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x13b1, 0x0024), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
@@ -73,96 +76,6 @@ MODULE_DEVICE_TABLE(usb, usb_ids);
 #define FW_ZD1211_PREFIX	"zd1211/zd1211_"
 #define FW_ZD1211B_PREFIX	"zd1211/zd1211b_"
 
-/* register address handling */
-
-#ifdef DEBUG
-static int check_addr(struct zd_usb *usb, zd_addr_t addr)
-{
-	u32 base = ZD_ADDR_BASE(addr);
-	u32 offset = ZD_OFFSET(addr);
-
-	if ((u32)addr & ADDR_ZERO_MASK)
-		goto invalid_address;
-	switch (base) {
-	case USB_BASE:
-		break;
-	case CR_BASE:
-		if (offset > CR_MAX_OFFSET) {
-			dev_dbg(zd_usb_dev(usb),
-				"CR offset %#010x larger than"
-				" CR_MAX_OFFSET %#10x\n",
-				offset, CR_MAX_OFFSET);
-			goto invalid_address;
-		}
-		if (offset & 1) {
-			dev_dbg(zd_usb_dev(usb),
-				"CR offset %#010x is not a multiple of 2\n",
-				offset);
-			goto invalid_address;
-		}
-		break;
-	case E2P_BASE:
-		if (offset > E2P_MAX_OFFSET) {
-			dev_dbg(zd_usb_dev(usb),
-				"E2P offset %#010x larger than"
-				" E2P_MAX_OFFSET %#010x\n",
-				offset, E2P_MAX_OFFSET);
-			goto invalid_address;
-		}
-		break;
-	case FW_BASE:
-		if (!usb->fw_base_offset) {
-			dev_dbg(zd_usb_dev(usb),
-			       "ERROR: fw base offset has not been set\n");
-			return -EAGAIN;
-		}
-		if (offset > FW_MAX_OFFSET) {
-			dev_dbg(zd_usb_dev(usb),
-				"FW offset %#10x is larger than"
-				" FW_MAX_OFFSET %#010x\n",
-				offset, FW_MAX_OFFSET);
-			goto invalid_address;
-		}
-		break;
-	default:
-		dev_dbg(zd_usb_dev(usb),
-			"address has unsupported base %#010x\n", addr);
-		goto invalid_address;
-	}
-
-	return 0;
-invalid_address:
-	dev_dbg(zd_usb_dev(usb),
-		"ERROR: invalid address: %#010x\n", addr);
-	return -EINVAL;
-}
-#endif /* DEBUG */
-
-static u16 usb_addr(struct zd_usb *usb, zd_addr_t addr)
-{
-	u32 base;
-	u16 offset;
-
-	base = ZD_ADDR_BASE(addr);
-	offset = ZD_OFFSET(addr);
-
-	ZD_ASSERT(check_addr(usb, addr) == 0);
-
-	switch (base) {
-	case CR_BASE:
-		offset += CR_BASE_OFFSET;
-		break;
-	case E2P_BASE:
-		offset += E2P_BASE_OFFSET;
-		break;
-	case FW_BASE:
-		offset += usb->fw_base_offset;
-		break;
-	}
-
-	return offset;
-}
-
 /* USB device initialization */
 
 static int request_fw_file(
@@ -295,14 +208,13 @@ static int handle_version_mismatch(struct usb_device *udev, u8 device_type,
 	if (r)
 		goto error;
 
-	r = upload_code(udev, ur_fw->data, ur_fw->size, FW_START_OFFSET,
-		REBOOT);
+	r = upload_code(udev, ur_fw->data, ur_fw->size, FW_START, REBOOT);
 	if (r)
 		goto error;
 
-	offset = ((EEPROM_REGS_OFFSET + EEPROM_REGS_SIZE) * sizeof(u16));
+	offset = (E2P_BOOT_CODE_OFFSET * sizeof(u16));
 	r = upload_code(udev, ub_fw->data + offset, ub_fw->size - offset,
-		E2P_BASE_OFFSET + EEPROM_REGS_SIZE, REBOOT);
+		E2P_START + E2P_BOOT_CODE_OFFSET, REBOOT);
 
 	/* At this point, the vendor driver downloads the whole firmware
 	 * image, hacks around with version IDs, and uploads it again,
@@ -331,7 +243,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 	if (r)
 		goto error;
 
-	fw_bcdDevice = get_word(ub_fw->data, EEPROM_REGS_OFFSET);
+	fw_bcdDevice = get_word(ub_fw->data, E2P_DATA_OFFSET);
 
 	if (fw_bcdDevice != bcdDevice) {
 		dev_info(&udev->dev,
@@ -357,8 +269,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 	if (r)
 		goto error;
 
-	r = upload_code(udev, uph_fw->data, uph_fw->size, FW_START_OFFSET,
-		        REBOOT);
+	r = upload_code(udev, uph_fw->data, uph_fw->size, FW_START, REBOOT);
 	if (r) {
 		dev_err(&udev->dev,
 			"Could not upload firmware code uph. Error number %d\n",
@@ -858,7 +769,7 @@ static inline void init_usb_interrupt(struct zd_usb *usb)
 	spin_lock_init(&intr->lock);
 	intr->interval = int_urb_interval(zd_usb_to_usbdev(usb));
 	init_completion(&intr->read_regs.completion);
-	intr->read_regs.cr_int_addr = cpu_to_le16(usb_addr(usb, CR_INTERRUPT));
+	intr->read_regs.cr_int_addr = cpu_to_le16((u16)CR_INTERRUPT);
 }
 
 static inline void init_usb_rx(struct zd_usb *usb)
@@ -890,22 +801,6 @@ void zd_usb_init(struct zd_usb *usb, struct net_device *netdev,
 	init_usb_rx(usb);
 }
 
-int zd_usb_init_hw(struct zd_usb *usb)
-{
-	int r;
-	struct zd_chip *chip = zd_usb_to_chip(usb);
-
-	ZD_ASSERT(mutex_is_locked(&chip->mutex));
-	r = zd_ioread16_locked(chip, &usb->fw_base_offset,
-		        USB_REG((u16)FW_BASE_ADDR_OFFSET));
-	if (r)
-		return r;
-	dev_dbg_f(zd_usb_dev(usb), "fw_base_offset: %#06hx\n",
-		 usb->fw_base_offset);
-
-	return 0;
-}
-
 void zd_usb_clear(struct zd_usb *usb)
 {
 	usb_set_intfdata(usb->intf, NULL);
@@ -1253,7 +1148,7 @@ int zd_usb_ioread16v(struct zd_usb *usb, u16 *values,
 		return -ENOMEM;
 	req->id = cpu_to_le16(USB_REQ_READ_REGS);
 	for (i = 0; i < count; i++)
-		req->addr[i] = cpu_to_le16(usb_addr(usb, addresses[i]));
+		req->addr[i] = cpu_to_le16((u16)addresses[i]);
 
 	udev = zd_usb_to_usbdev(usb);
 	prepare_read_regs_int(usb);
@@ -1318,7 +1213,7 @@ int zd_usb_iowrite16v(struct zd_usb *usb, const struct zd_ioreq16 *ioreqs,
 	req->id = cpu_to_le16(USB_REQ_WRITE_REGS);
 	for (i = 0; i < count; i++) {
 		struct reg_data *rw  = &req->reg_writes[i];
-		rw->addr = cpu_to_le16(usb_addr(usb, ioreqs[i].addr));
+		rw->addr = cpu_to_le16((u16)ioreqs[i].addr);
 		rw->value = cpu_to_le16(ioreqs[i].value);
 	}
 
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zd1211rw/zd_usb.h
index 317d37c..506ea6a 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -25,7 +25,6 @@
 #include <linux/usb.h>
 
 #include "zd_def.h"
-#include "zd_types.h"
 
 enum devicetype {
 	DEVICE_ZD1211  = 0,
@@ -181,15 +180,14 @@ struct zd_usb_tx {
 	spinlock_t lock;
 };
 
-/* Contains the usb parts. The structure doesn't require a lock, because intf
- * and fw_base_offset, will not be changed after initialization.
+/* Contains the usb parts. The structure doesn't require a lock because intf
+ * will not be changed after initialization.
  */
 struct zd_usb {
 	struct zd_usb_interrupt intr;
 	struct zd_usb_rx rx;
 	struct zd_usb_tx tx;
 	struct usb_interface *intf;
-	u16 fw_base_offset;
 };
 
 #define zd_usb_dev(usb) (&usb->intf->dev)
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index fa2f7da..fb58e03 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -265,6 +265,12 @@ ieee80211softmac_wx_get_rate(struct net_device *net_dev,
 	int err = -EINVAL;
 
 	spin_lock_irqsave(&mac->lock, flags);
+
+	if (unlikely(!mac->running)) {
+		err = -ENODEV;
+		goto out_unlock;
+	}
+
 	switch (mac->txrates.default_rate) {
 	case IEEE80211_CCK_RATE_1MB:
 		data->bitrate.value = 1000000;
-- 
John W. Linville
linville@tuxdriver.com
