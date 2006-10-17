From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 17 Oct 2006 17:35:57 -0400
Message-ID: <20061017213557.GE32614@tuxdriver.com>
References: <20061017213412.GD32614@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:14859 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750787AbWJQVgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 17:36:54 -0400
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20061017213412.GD32614@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 41072a1be57f63bf83afc31c44d72de018d800fa:
  John W. Linville:
        zd1211rw: fix build-break caused by association race fix

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Alexey Dobriyan:
      prism54: use BUILD_BUG_ON

Daniel Drake:
      zd1211rw: Add 3 more device IDs
      ieee80211: Move IV/ICV stripping into ieee80211_rx

Dmitry Torokhov:
      atmel: save on array initialization
      atmel: use ARRAY_SIZE()
      atmel: whitespace cleanup
      prism54: fix potential race in reset scheduling
      prism54: whitespace cleanup

Holden Karau:
      atmel: output signal strength information

Larry Finger:
      bcm43xx: output proper link quality with scans
      ieee80211: Drop and count duplicate data frames to remove 'replay detected' log messages

matthieu castet:
      ieee80211: allow mtu bigger than 1500

Stefano Brivio:
      bcm43xx: add PCI-E code

 drivers/net/wireless/atmel.c                  |   36 ++++--
 drivers/net/wireless/atmel_cs.c               |   74 ++++++-------
 drivers/net/wireless/atmel_pci.c              |   10 +-
 drivers/net/wireless/bcm43xx/bcm43xx.h        |   32 ++++++
 drivers/net/wireless/bcm43xx/bcm43xx_main.c   |  145 +++++++++++++++++++------
 drivers/net/wireless/bcm43xx/bcm43xx_power.c  |   28 ++++-
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c     |    4 -
 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c   |   19 ---
 drivers/net/wireless/prism54/isl_38xx.c       |   17 +--
 drivers/net/wireless/prism54/isl_38xx.h       |    7 +
 drivers/net/wireless/prism54/isl_ioctl.c      |   61 +++++------
 drivers/net/wireless/prism54/isl_ioctl.h      |    1 
 drivers/net/wireless/prism54/isl_oid.h        |   48 ++++----
 drivers/net/wireless/prism54/islpci_dev.c     |   13 +-
 drivers/net/wireless/prism54/islpci_dev.h     |   11 +-
 drivers/net/wireless/prism54/islpci_eth.c     |   30 +++--
 drivers/net/wireless/prism54/islpci_eth.h     |    1 
 drivers/net/wireless/prism54/islpci_hotplug.c |   23 ++--
 drivers/net/wireless/prism54/islpci_mgt.c     |    3 -
 drivers/net/wireless/prism54/islpci_mgt.h     |    5 -
 drivers/net/wireless/prism54/oid_mgt.c        |    6 +
 drivers/net/wireless/prism54/prismcompat.h    |    4 -
 drivers/net/wireless/zd1211rw/zd_usb.c        |    3 +
 include/net/ieee80211.h                       |    6 +
 net/ieee80211/ieee80211_module.c              |    9 ++
 net/ieee80211/ieee80211_rx.c                  |   61 +++++++++--
 26 files changed, 409 insertions(+), 248 deletions(-)

diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 0c07b8b..10bcb48 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -595,7 +595,7 @@ static void atmel_join_bss(struct atmel_
 static void atmel_smooth_qual(struct atmel_private *priv);
 static void atmel_writeAR(struct net_device *dev, u16 data);
 static int probe_atmel_card(struct net_device *dev);
-static int reset_atmel_card(struct net_device *dev );
+static int reset_atmel_card(struct net_device *dev);
 static void atmel_enter_state(struct atmel_private *priv, int new_state);
 int atmel_open (struct net_device *dev);
 
@@ -784,11 +784,11 @@ static void tx_update_descriptor(struct 
 
 static int start_tx(struct sk_buff *skb, struct net_device *dev)
 {
+	static const u8 SNAP_RFC1024[6] = { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
 	struct atmel_private *priv = netdev_priv(dev);
 	struct ieee80211_hdr_4addr header;
 	unsigned long flags;
 	u16 buff, frame_ctl, len = (ETH_ZLEN < skb->len) ? skb->len : ETH_ZLEN;
-	u8 SNAP_RFC1024[6] = {0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00};
 
 	if (priv->card && priv->present_callback &&
 	    !(*priv->present_callback)(priv->card)) {
@@ -1193,7 +1193,7 @@ static irqreturn_t service_interrupt(int
 
 		atmel_set_gcr(dev, GCR_ACKINT); /* acknowledge interrupt */
 
-		for (i = 0; i < sizeof(irq_order)/sizeof(u8); i++)
+		for (i = 0; i < ARRAY_SIZE(irq_order); i++)
 			if (isr & irq_order[i])
 				break;
 
@@ -1345,10 +1345,10 @@ int atmel_open(struct net_device *dev)
 		atmel_set_mib8(priv, Phy_Mib_Type, PHY_MIB_REG_DOMAIN_POS, priv->reg_domain);
 	} else {
 		priv->reg_domain = atmel_get_mib8(priv, Phy_Mib_Type, PHY_MIB_REG_DOMAIN_POS);
-		for (i = 0; i < sizeof(channel_table)/sizeof(channel_table[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(channel_table); i++)
 			if (priv->reg_domain == channel_table[i].reg_domain)
 				break;
-		if (i == sizeof(channel_table)/sizeof(channel_table[0])) {
+		if (i == ARRAY_SIZE(channel_table)) {
 			priv->reg_domain = REG_DOMAIN_MKK1;
 			printk(KERN_ALERT "%s: failed to get regulatory domain: assuming MKK1.\n", dev->name);
 		}
@@ -1393,7 +1393,7 @@ static int atmel_validate_channel(struct
 	   else return suitable default channel */
 	int i;
 
-	for (i = 0; i < sizeof(channel_table)/sizeof(channel_table[0]); i++)
+	for (i = 0; i < ARRAY_SIZE(channel_table); i++)
 		if (priv->reg_domain == channel_table[i].reg_domain) {
 			if (channel >= channel_table[i].min &&
 			    channel <= channel_table[i].max)
@@ -1437,7 +1437,7 @@ static int atmel_proc_output (char *buf,
 		}
 
 		r = "<unknown>";
-		for (i = 0; i < sizeof(channel_table)/sizeof(channel_table[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(channel_table); i++)
 			if (priv->reg_domain == channel_table[i].reg_domain)
 				r = channel_table[i].name;
 
@@ -1736,7 +1736,7 @@ static int atmel_set_encode(struct net_d
 				/* Disable the key */
 				priv->wep_key_len[index] = 0;
 		/* Check if the key is not marked as invalid */
-		if(!(dwrq->flags & IW_ENCODE_NOKEY)) {
+		if (!(dwrq->flags & IW_ENCODE_NOKEY)) {
 			/* Cleanup */
 			memset(priv->wep_keys[index], 0, 13);
 			/* Copy the key in the driver */
@@ -1907,7 +1907,7 @@ static int atmel_get_encodeext(struct ne
 
 	encoding->flags = idx + 1;
 	memset(ext, 0, sizeof(*ext));
-	
+
 	if (!priv->wep_is_on) {
 		ext->alg = IW_ENCODE_ALG_NONE;
 		ext->key_len = 0;
@@ -2343,6 +2343,14 @@ static int atmel_get_scan(struct net_dev
 		iwe.u.freq.e = 0;
 		current_ev = iwe_stream_add_event(current_ev, extra + IW_SCAN_MAX_DATA, &iwe, IW_EV_FREQ_LEN);
 
+		/* Add quality statistics */
+		iwe.cmd = IWEVQUAL;
+		iwe.u.qual.level = priv->BSSinfo[i].RSSI;
+		iwe.u.qual.qual  = iwe.u.qual.level;
+		/* iwe.u.qual.noise  = SOMETHING */
+		current_ev = iwe_stream_add_event(current_ev, extra + IW_SCAN_MAX_DATA , &iwe, IW_EV_QUAL_LEN);
+
+
 		iwe.cmd = SIOCGIWENCODE;
 		if (priv->BSSinfo[i].UsingWEP)
 			iwe.u.data.flags = IW_ENCODE_ENABLED | IW_ENCODE_NOKEY;
@@ -2373,7 +2381,7 @@ static int atmel_get_range(struct net_de
 	range->min_nwid = 0x0000;
 	range->max_nwid = 0x0000;
 	range->num_channels = 0;
-	for (j = 0; j < sizeof(channel_table)/sizeof(channel_table[0]); j++)
+	for (j = 0; j < ARRAY_SIZE(channel_table); j++)
 		if (priv->reg_domain == channel_table[j].reg_domain) {
 			range->num_channels = channel_table[j].max - channel_table[j].min + 1;
 			break;
@@ -2579,9 +2587,9 @@ static const struct iw_priv_args atmel_p
 
 static const struct iw_handler_def atmel_handler_def =
 {
-	.num_standard	= sizeof(atmel_handler)/sizeof(iw_handler),
-	.num_private	= sizeof(atmel_private_handler)/sizeof(iw_handler),
-	.num_private_args = sizeof(atmel_private_args)/sizeof(struct iw_priv_args),
+	.num_standard	= ARRAY_SIZE(atmel_handler),
+	.num_private	= ARRAY_SIZE(atmel_private_handler),
+	.num_private_args = ARRAY_SIZE(atmel_private_args),
 	.standard	= (iw_handler *) atmel_handler,
 	.private	= (iw_handler *) atmel_private_handler,
 	.private_args	= (struct iw_priv_args *) atmel_private_args,
@@ -2645,7 +2653,7 @@ static int atmel_ioctl(struct net_device
 
 		domain[REGDOMAINSZ] = 0;
 		rc = -EINVAL;
-		for (i = 0; i < sizeof(channel_table)/sizeof(channel_table[0]); i++) {
+		for (i = 0; i < ARRAY_SIZE(channel_table); i++) {
 			/* strcasecmp doesn't exist in the library */
 			char *a = channel_table[i].name;
 			char *b = domain;
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 7856640..5c41098 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -5,12 +5,12 @@
         Copyright 2000-2001 ATMEL Corporation.
         Copyright 2003 Simon Kelley.
 
-    This code was developed from version 2.1.1 of the Atmel drivers, 
-    released by Atmel corp. under the GPL in December 2002. It also 
-    includes code from the Linux aironet drivers (C) Benjamin Reed, 
-    and the Linux PCMCIA package, (C) David Hinds. 
+    This code was developed from version 2.1.1 of the Atmel drivers,
+    released by Atmel corp. under the GPL in December 2002. It also
+    includes code from the Linux aironet drivers (C) Benjamin Reed,
+    and the Linux PCMCIA package, (C) David Hinds.
 
-    For all queries about this code, please contact the current author, 
+    For all queries about this code, please contact the current author,
     Simon Kelley <simon@thekelleys.org.uk> and not Atmel Corporation.
 
     This program is free software; you can redistribute it and/or modify
@@ -87,7 +87,7 @@ MODULE_SUPPORTED_DEVICE("Atmel at76c50x 
    event is received.  The config() and release() entry points are
    used to configure or release a socket, in response to card
    insertion and ejection events.  They are invoked from the atmel_cs
-   event handler. 
+   event handler.
 */
 
 static int atmel_config(struct pcmcia_device *link);
@@ -133,22 +133,22 @@ static void atmel_detach(struct pcmcia_d
    device IO routines can use a flag like this to throttle IO to a
    card that is not ready to accept it.
 */
-   
+
 typedef struct local_info_t {
 	dev_node_t	node;
 	struct net_device *eth_dev;
 } local_info_t;
 
 /*======================================================================
-  
+
   atmel_attach() creates an "instance" of the driver, allocating
   local data structures for one device.  The device is registered
   with Card Services.
-  
+
   The dev_link structure is initialized, but we don't actually
   configure the card at this point -- we wait until we receive a
   card insertion event.
-  
+
   ======================================================================*/
 
 static int atmel_probe(struct pcmcia_device *p_dev)
@@ -184,12 +184,12 @@ static int atmel_probe(struct pcmcia_dev
 } /* atmel_attach */
 
 /*======================================================================
-  
+
   This deletes a driver "instance".  The device is de-registered
   with Card Services.  If it has been released, all local data
   structures are freed.  Otherwise, the structures will be freed
   when the device is released.
-  
+
   ======================================================================*/
 
 static void atmel_detach(struct pcmcia_device *link)
@@ -202,11 +202,11 @@ static void atmel_detach(struct pcmcia_d
 }
 
 /*======================================================================
-  
+
   atmel_config() is scheduled to run after a CARD_INSERTION event
   is received, to configure the PCMCIA socket, and to make the
   device available to the system.
-  
+
   ======================================================================*/
 
 #define CS_CHECK(fn, ret) \
@@ -237,12 +237,12 @@ static int atmel_config(struct pcmcia_de
 	did = handle_to_dev(link).driver_data;
 
 	DEBUG(0, "atmel_config(0x%p)\n", link);
-	
+
 	tuple.Attributes = 0;
 	tuple.TupleData = buf;
 	tuple.TupleDataMax = sizeof(buf);
 	tuple.TupleOffset = 0;
-	
+
 	/*
 	  This reads the card's CONFIG tuple to find its configuration
 	  registers.
@@ -258,7 +258,7 @@ static int atmel_config(struct pcmcia_de
 	  In this loop, we scan the CIS for configuration table entries,
 	  each of which describes a valid card configuration, including
 	  voltage, IO window, memory window, and interrupt settings.
-	  
+
 	  We make no assumptions about the card to be configured: we use
 	  just the information available in the CIS.  In an ideal world,
 	  this would work for any PCMCIA card, but it requires a complete
@@ -274,17 +274,17 @@ static int atmel_config(struct pcmcia_de
 		if (pcmcia_get_tuple_data(link, &tuple) != 0 ||
 				pcmcia_parse_tuple(link, &tuple, &parse) != 0)
 			goto next_entry;
-		
+
 		if (cfg->flags & CISTPL_CFTABLE_DEFAULT) dflt = *cfg;
 		if (cfg->index == 0) goto next_entry;
 		link->conf.ConfigIndex = cfg->index;
-		
+
 		/* Does this card need audio output? */
 		if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
 			link->conf.Attributes |= CONF_ENABLE_SPKR;
 			link->conf.Status = CCSR_AUDIO_ENA;
 		}
-		
+
 		/* Use power settings for Vcc and Vpp if present */
 		/*  Note that the CIS values need to be rescaled */
 		if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
@@ -293,11 +293,11 @@ static int atmel_config(struct pcmcia_de
 		else if (dflt.vpp1.present & (1<<CISTPL_POWER_VNOM))
 			link->conf.Vpp =
 				dflt.vpp1.param[CISTPL_POWER_VNOM]/10000;
-		
+
 		/* Do we need to allocate an interrupt? */
 		if (cfg->irq.IRQInfo1 || dflt.irq.IRQInfo1)
 			link->conf.Attributes |= CONF_ENABLE_IRQ;
-		
+
 		/* IO window settings */
 		link->io.NumPorts1 = link->io.NumPorts2 = 0;
 		if ((cfg->io.nwin > 0) || (dflt.io.nwin > 0)) {
@@ -315,18 +315,18 @@ static int atmel_config(struct pcmcia_de
 				link->io.NumPorts2 = io->win[1].len;
 			}
 		}
-		
+
 		/* This reserves IO space but doesn't actually enable it */
 		if (pcmcia_request_io(link, &link->io) != 0)
 			goto next_entry;
 
 		/* If we got this far, we're cool! */
 		break;
-		
+
 	next_entry:
 		CS_CHECK(GetNextTuple, pcmcia_get_next_tuple(link, &tuple));
 	}
-	
+
 	/*
 	  Allocate an interrupt line.  Note that this does not assign a
 	  handler to the interrupt, unless the 'Handler' member of the
@@ -334,31 +334,31 @@ static int atmel_config(struct pcmcia_de
 	*/
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
-	
+
 	/*
 	  This actually configures the PCMCIA socket -- setting up
 	  the I/O windows and the interrupt mapping, and putting the
 	  card and host interface into "Memory and IO" mode.
 	*/
 	CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
-	
+
 	if (link->irq.AssignedIRQ == 0) {
-		printk(KERN_ALERT 
+		printk(KERN_ALERT
 		       "atmel: cannot assign IRQ: check that CONFIG_ISA is set in kernel config.");
 		goto cs_failed;
 	}
-       
-	((local_info_t*)link->priv)->eth_dev = 
+
+	((local_info_t*)link->priv)->eth_dev =
 		init_atmel_card(link->irq.AssignedIRQ,
 				link->io.BasePort1,
 				did ? did->driver_info : ATMEL_FW_TYPE_NONE,
 				&handle_to_dev(link),
-				card_present, 
+				card_present,
 				link);
-	if (!((local_info_t*)link->priv)->eth_dev) 
+	if (!((local_info_t*)link->priv)->eth_dev)
 			goto cs_failed;
-	
-	
+
+
 	/*
 	  At this point, the dev_node_t structure(s) need to be
 	  initialized and arranged in a linked list at link->dev_node.
@@ -376,11 +376,11 @@ static int atmel_config(struct pcmcia_de
 }
 
 /*======================================================================
-  
+
   After a card is removed, atmel_release() will unregister the
   device, and release the PCMCIA configuration.  If the device is
   still open, this will be postponed until it is closed.
-  
+
   ======================================================================*/
 
 static void atmel_release(struct pcmcia_device *link)
@@ -517,7 +517,7 @@ static void atmel_cs_cleanup(void)
     HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
     STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
     IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-    POSSIBILITY OF SUCH DAMAGE.    
+    POSSIBILITY OF SUCH DAMAGE.
 */
 
 module_init(atmel_cs_init);
diff --git a/drivers/net/wireless/atmel_pci.c b/drivers/net/wireless/atmel_pci.c
index 3bfa791..92f87fb 100644
--- a/drivers/net/wireless/atmel_pci.c
+++ b/drivers/net/wireless/atmel_pci.c
@@ -53,18 +53,18 @@ static int __devinit atmel_pci_probe(str
 				     const struct pci_device_id *pent)
 {
 	struct net_device *dev;
-		
+
 	if (pci_enable_device(pdev))
 		return -ENODEV;
-	
+
 	pci_set_master(pdev);
-	
-	dev = init_atmel_card(pdev->irq, pdev->resource[1].start, 
+
+	dev = init_atmel_card(pdev->irq, pdev->resource[1].start,
 			      ATMEL_FW_TYPE_506,
 			      &pdev->dev, NULL, NULL);
 	if (!dev)
 		return -ENODEV;
-	
+
 	pci_set_drvdata(pdev, dev);
 	return 0;
 }
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index d6a8bf0..94dfb92 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -159,6 +159,7 @@ #define BCM43xx_MACFILTER_ASSOC		0x0003
 
 /* Chipcommon registers. */
 #define BCM43xx_CHIPCOMMON_CAPABILITIES 	0x04
+#define BCM43xx_CHIPCOMMON_CTL			0x28
 #define BCM43xx_CHIPCOMMON_PLLONDELAY		0xB0
 #define BCM43xx_CHIPCOMMON_FREFSELDELAY		0xB4
 #define BCM43xx_CHIPCOMMON_SLOWCLKCTL		0xB8
@@ -172,6 +173,33 @@ #define BCM43xx_PCICORE_SBTOPCI2	0x108
 /* SBTOPCI2 values. */
 #define BCM43xx_SBTOPCI2_PREFETCH	0x4
 #define BCM43xx_SBTOPCI2_BURST		0x8
+#define BCM43xx_SBTOPCI2_MEMREAD_MULTI	0x20
+
+/* PCI-E core registers. */
+#define BCM43xx_PCIECORE_REG_ADDR      0x0130
+#define BCM43xx_PCIECORE_REG_DATA      0x0134
+#define BCM43xx_PCIECORE_MDIO_CTL      0x0128
+#define BCM43xx_PCIECORE_MDIO_DATA     0x012C
+
+/* PCI-E registers. */
+#define BCM43xx_PCIE_TLP_WORKAROUND    0x0004
+#define BCM43xx_PCIE_DLLP_LINKCTL      0x0100
+
+/* PCI-E MDIO bits. */
+#define BCM43xx_PCIE_MDIO_ST   0x40000000
+#define BCM43xx_PCIE_MDIO_WT   0x10000000
+#define BCM43xx_PCIE_MDIO_DEV  22
+#define BCM43xx_PCIE_MDIO_REG  18
+#define BCM43xx_PCIE_MDIO_TA   0x00020000
+#define BCM43xx_PCIE_MDIO_TC   0x0100
+
+/* MDIO devices. */
+#define BCM43xx_MDIO_SERDES_RX	0x1F
+
+/* SERDES RX registers. */
+#define BCM43xx_SERDES_RXTIMER	0x2
+#define BCM43xx_SERDES_CDR	0x6
+#define BCM43xx_SERDES_CDR_BW	0x7
 
 /* Chipcommon capabilities. */
 #define BCM43xx_CAPABILITIES_PCTL		0x00040000
@@ -221,6 +249,7 @@ #define BCM43xx_COREID_USB11_DEV        
 #define BCM43xx_COREID_USB20_HOST       0x819
 #define BCM43xx_COREID_USB20_DEV        0x81a
 #define BCM43xx_COREID_SDIO_HOST        0x81b
+#define BCM43xx_COREID_PCIE		0x820
 
 /* Core Information Registers */
 #define BCM43xx_CIR_BASE		0xf00
@@ -365,6 +394,9 @@ #define BCM43xx_DEFAULT_RTS_THRESHOLD		B
 #define BCM43xx_DEFAULT_SHORT_RETRY_LIMIT	7
 #define BCM43xx_DEFAULT_LONG_RETRY_LIMIT	4
 
+/* FIXME: the next line is a guess as to what the maximum RSSI value might be */
+#define RX_RSSI_MAX				60
+
 /* Max size of a security key */
 #define BCM43xx_SEC_KEYSIZE			16
 /* Security algorithms. */
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index a94c6d8..78db999 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -130,6 +130,10 @@ #endif /* CONFIG_BCM43XX_DEBUG*/
 	{ PCI_VENDOR_ID_BROADCOM, 0x4301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4307 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4311 802.11(a)/b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4311, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4312 802.11a/b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4312, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4318 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4319 802.11a/b/g */
@@ -2583,8 +2587,9 @@ static int bcm43xx_probe_cores(struct bc
 	/* fetch sb_id_hi from core information registers */
 	sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
 
-	core_id = (sb_id_hi & 0xFFF0) >> 4;
-	core_rev = (sb_id_hi & 0xF);
+	core_id = (sb_id_hi & 0x8FF0) >> 4;
+	core_rev = (sb_id_hi & 0x7000) >> 8;
+	core_rev |= (sb_id_hi & 0xF);
 	core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
 
 	/* if present, chipcommon is always core 0; read the chipid from it */
@@ -2694,6 +2699,7 @@ #endif
 		core = NULL;
 		switch (core_id) {
 		case BCM43xx_COREID_PCI:
+		case BCM43xx_COREID_PCIE:
 			core = &bcm->core_pci;
 			if (core->available) {
 				printk(KERN_WARNING PFX "Multiple PCI cores found.\n");
@@ -2732,12 +2738,12 @@ #endif
 			case 6:
 			case 7:
 			case 9:
+			case 10:
 				break;
 			default:
-				printk(KERN_ERR PFX "Error: Unsupported 80211 core revision %u\n",
+				printk(KERN_WARNING PFX
+				       "Unsupported 80211 core revision %u\n",
 				       core_rev);
-				err = -ENODEV;
-				goto out;
 			}
 			bcm->nr_80211_available++;
 			core->priv = ext_80211;
@@ -2851,16 +2857,11 @@ static int bcm43xx_wireless_core_init(st
 	u32 sbimconfiglow;
 	u8 limit;
 
-	if (bcm->chip_rev < 5) {
+	if (bcm->core_pci.rev <= 5 && bcm->core_pci.id != BCM43xx_COREID_PCIE) {
 		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
-			sbimconfiglow |= 0x32;
-		else if (bcm->bustype == BCM43xx_BUSTYPE_SB)
-			sbimconfiglow |= 0x53;
-		else
-			assert(0);
+		sbimconfiglow |= 0x32;
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
 	}
 
@@ -2987,22 +2988,64 @@ static void bcm43xx_pcicore_broadcast_va
 
 static int bcm43xx_pcicore_commit_settings(struct bcm43xx_private *bcm)
 {
-	int err;
-	struct bcm43xx_coreinfo *old_core;
+	int err = 0;
 
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_pci);
-	if (err)
-		goto out;
+	bcm->irq_savedstate = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 
-	bcm43xx_pcicore_broadcast_value(bcm, 0xfd8, 0x00000000);
+	if (bcm->core_chipcommon.available) {
+		err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
+		if (err)
+			goto out;
+
+		bcm43xx_pcicore_broadcast_value(bcm, 0xfd8, 0x00000000);
+
+		/* this function is always called when a PCI core is mapped */
+		err = bcm43xx_switch_core(bcm, &bcm->core_pci);
+		if (err)
+			goto out;
+	} else
+		bcm43xx_pcicore_broadcast_value(bcm, 0xfd8, 0x00000000);
+
+	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
 
-	bcm43xx_switch_core(bcm, old_core);
-	assert(err == 0);
 out:
 	return err;
 }
 
+static u32 bcm43xx_pcie_reg_read(struct bcm43xx_private *bcm, u32 address)
+{
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_REG_ADDR, address);
+	return bcm43xx_read32(bcm, BCM43xx_PCIECORE_REG_DATA);
+}
+
+static void bcm43xx_pcie_reg_write(struct bcm43xx_private *bcm, u32 address,
+				    u32 data)
+{
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_REG_ADDR, address);
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_REG_DATA, data);
+}
+
+static void bcm43xx_pcie_mdio_write(struct bcm43xx_private *bcm, u8 dev, u8 reg,
+				    u16 data)
+{
+	int i;
+
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_MDIO_CTL, 0x0082);
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_MDIO_DATA, BCM43xx_PCIE_MDIO_ST |
+			BCM43xx_PCIE_MDIO_WT | (dev << BCM43xx_PCIE_MDIO_DEV) |
+			(reg << BCM43xx_PCIE_MDIO_REG) | BCM43xx_PCIE_MDIO_TA |
+			data);
+	udelay(10);
+
+	for (i = 0; i < 10; i++) {
+		if (bcm43xx_read32(bcm, BCM43xx_PCIECORE_MDIO_CTL) &
+		    BCM43xx_PCIE_MDIO_TC)
+			break;
+		msleep(1);
+	}
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_MDIO_CTL, 0);
+}
+
 /* Make an I/O Core usable. "core_mask" is the bitmask of the cores to enable.
  * To enable core 0, pass a core_mask of 1<<0
  */
@@ -3022,7 +3065,8 @@ static int bcm43xx_setup_backplane_pci_c
 	if (err)
 		goto out;
 
-	if (bcm->core_pci.rev < 6) {
+	if (bcm->current_core->rev < 6 ||
+		bcm->current_core->id == BCM43xx_COREID_PCI) {
 		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
 		value |= (1 << backplane_flag_nr);
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBINTVEC, value);
@@ -3040,21 +3084,46 @@ static int bcm43xx_setup_backplane_pci_c
 		}
 	}
 
-	value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
-	value |= BCM43xx_SBTOPCI2_PREFETCH | BCM43xx_SBTOPCI2_BURST;
-	bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
-
-	if (bcm->core_pci.rev < 5) {
-		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
-		value |= (2 << BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_SHIFT)
-			 & BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		value |= (3 << BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_SHIFT)
-			 & BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, value);
-		err = bcm43xx_pcicore_commit_settings(bcm);
-		assert(err == 0);
+	if (bcm->current_core->id == BCM43xx_COREID_PCI) {
+		value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
+		value |= BCM43xx_SBTOPCI2_PREFETCH | BCM43xx_SBTOPCI2_BURST;
+		bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
+
+		if (bcm->current_core->rev < 5) {
+			value = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
+			value |= (2 << BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_SHIFT)
+				 & BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
+			value |= (3 << BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_SHIFT)
+				 & BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
+			bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, value);
+			err = bcm43xx_pcicore_commit_settings(bcm);
+			assert(err == 0);
+		} else if (bcm->current_core->rev >= 11) {
+			value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
+			value |= BCM43xx_SBTOPCI2_MEMREAD_MULTI;
+			bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
+		}
+	} else {
+		if (bcm->current_core->rev == 0 || bcm->current_core->rev == 1) {
+			value = bcm43xx_pcie_reg_read(bcm, BCM43xx_PCIE_TLP_WORKAROUND);
+			value |= 0x8;
+			bcm43xx_pcie_reg_write(bcm, BCM43xx_PCIE_TLP_WORKAROUND,
+					       value);
+		}
+		if (bcm->current_core->rev == 0) {
+			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
+						BCM43xx_SERDES_RXTIMER, 0x8128);
+			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
+						BCM43xx_SERDES_CDR, 0x0100);
+			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
+						BCM43xx_SERDES_CDR_BW, 0x1466);
+		} else if (bcm->current_core->rev == 1) {
+			value = bcm43xx_pcie_reg_read(bcm, BCM43xx_PCIE_DLLP_LINKCTL);
+			value |= 0x40;
+			bcm43xx_pcie_reg_write(bcm, BCM43xx_PCIE_DLLP_LINKCTL,
+					       value);
+		}
 	}
-
 out_switch_back:
 	err = bcm43xx_switch_core(bcm, old_core);
 out:
@@ -3644,7 +3713,7 @@ static int bcm43xx_read_phyinfo(struct b
 		bcm->ieee->freq_band = IEEE80211_24GHZ_BAND;
 		break;
 	case BCM43xx_PHYTYPE_G:
-		if (phy_rev > 7)
+		if (phy_rev > 8)
 			phy_rev_ok = 0;
 		bcm->ieee->modulation = IEEE80211_OFDM_MODULATION |
 					IEEE80211_CCK_MODULATION;
@@ -3656,6 +3725,8 @@ static int bcm43xx_read_phyinfo(struct b
 		       phy_type);
 		return -ENODEV;
 	};
+	bcm->ieee->perfect_rssi = RX_RSSI_MAX;
+	bcm->ieee->worst_rssi = 0;
 	if (!phy_rev_ok) {
 		printk(KERN_WARNING PFX "Invalid PHY Revision %x\n",
 		       phy_rev);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_power.c b/drivers/net/wireless/bcm43xx/bcm43xx_power.c
index 6569da3..7e774f4 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_power.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_power.c
@@ -153,8 +153,6 @@ int bcm43xx_pctl_init(struct bcm43xx_pri
 	int err, maxfreq;
 	struct bcm43xx_coreinfo *old_core;
 
-	if (!(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
-		return 0;
 	old_core = bcm->current_core;
 	err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
 	if (err == -ENODEV)
@@ -162,11 +160,27 @@ int bcm43xx_pctl_init(struct bcm43xx_pri
 	if (err)
 		goto out;
 
-	maxfreq = bcm43xx_pctl_clockfreqlimit(bcm, 1);
-	bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_PLLONDELAY,
-			(maxfreq * 150 + 999999) / 1000000);
-	bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_FREFSELDELAY,
-			(maxfreq * 15 + 999999) / 1000000);
+	if (bcm->chip_id == 0x4321) {
+		if (bcm->chip_rev == 0)
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_CTL, 0x03A4);
+		if (bcm->chip_rev == 1)
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_CTL, 0x00A4);
+	}
+
+	if (bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL) {
+		if (bcm->current_core->rev >= 10) {
+			/* Set Idle Power clock rate to 1Mhz */
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_SYSCLKCTL,
+				       (bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SYSCLKCTL)
+				       & 0x0000FFFF) | 0x40000);
+		} else {
+			maxfreq = bcm43xx_pctl_clockfreqlimit(bcm, 1);
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_PLLONDELAY,
+				       (maxfreq * 150 + 999999) / 1000000);
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_FREFSELDELAY,
+				       (maxfreq * 15 + 999999) / 1000000);
+		}
+	}
 
 	err = bcm43xx_switch_core(bcm, old_core);
 	assert(err == 0);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index d27016f..a659442 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -47,9 +47,6 @@ #include "bcm43xx_phy.h"
 #define BCM43xx_WX_VERSION	18
 
 #define MAX_WX_STRING		80
-/* FIXME: the next line is a guess as to what the maximum RSSI value might be */
-#define RX_RSSI_MAX		60
-
 
 static int bcm43xx_wx_get_name(struct net_device *net_dev,
                                struct iw_request_info *info,
@@ -693,6 +690,7 @@ static int bcm43xx_wx_set_swencryption(s
 	bcm->ieee->host_encrypt = !!on;
 	bcm->ieee->host_decrypt = !!on;
 	bcm->ieee->host_build_iv = !on;
+	bcm->ieee->host_strip_iv_icv = !on;
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	mutex_unlock(&bcm->mutex);
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
index 0159e4e..a957bc8 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -543,25 +543,6 @@ int bcm43xx_rx(struct bcm43xx_private *b
 		break;
 	}
 
-	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
-	if ((frame_ctl & IEEE80211_FCTL_PROTECTED) && !bcm->ieee->host_decrypt) {
-		frame_ctl &= ~IEEE80211_FCTL_PROTECTED;
-		wlhdr->frame_ctl = cpu_to_le16(frame_ctl);		
-		/* trim IV and ICV */
-		/* FIXME: this must be done only for WEP encrypted packets */
-		if (skb->len < 32) {
-			dprintkl(KERN_ERR PFX "RX packet dropped (PROTECTED flag "
-					      "set and length < 32)\n");
-			return -EINVAL;
-		} else {		
-			memmove(skb->data + 4, skb->data, 24);
-			skb_pull(skb, 4);
-			skb_trim(skb, skb->len - 4);
-			stats.len -= 8;
-		}
-		wlhdr = (struct ieee80211_hdr_4addr *)(skb->data);
-	}
-	
 	switch (WLAN_FC_GET_TYPE(frame_ctl)) {
 	case IEEE80211_FTYPE_MGMT:
 		ieee80211_rx_mgt(bcm->ieee, wlhdr, &stats);
diff --git a/drivers/net/wireless/prism54/isl_38xx.c b/drivers/net/wireless/prism54/isl_38xx.c
index 23deee6..02fc67b 100644
--- a/drivers/net/wireless/prism54/isl_38xx.c
+++ b/drivers/net/wireless/prism54/isl_38xx.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2003-2004 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>_
  *
@@ -38,7 +37,7 @@ #include "islpci_mgt.h"
  * isl38xx_disable_interrupts - disable all interrupts
  * @device: pci memory base address
  *
- *  Instructs the device to disable all interrupt reporting by asserting 
+ *  Instructs the device to disable all interrupt reporting by asserting
  *  the IRQ line. New events may still show up in the interrupt identification
  *  register located at offset %ISL38XX_INT_IDENT_REG.
  */
@@ -204,17 +203,19 @@ #endif
 	/* enable the interrupt for detecting initialization */
 
 	/* Note: Do not enable other interrupts here. We want the
-	 * device to have come up first 100% before allowing any other 
+	 * device to have come up first 100% before allowing any other
 	 * interrupts. */
 	isl38xx_w32_flush(device_base, ISL38XX_INT_IDENT_INIT, ISL38XX_INT_EN_REG);
 	udelay(ISL38XX_WRITEIO_DELAY);  /* allow complete full reset */
 }
 
 void
-isl38xx_enable_common_interrupts(void __iomem *device_base) {
+isl38xx_enable_common_interrupts(void __iomem *device_base)
+{
 	u32 reg;
-	reg = ( ISL38XX_INT_IDENT_UPDATE | 
-			ISL38XX_INT_IDENT_SLEEP | ISL38XX_INT_IDENT_WAKEUP);
+
+	reg = ISL38XX_INT_IDENT_UPDATE | ISL38XX_INT_IDENT_SLEEP |
+	      ISL38XX_INT_IDENT_WAKEUP;
 	isl38xx_w32_flush(device_base, reg, ISL38XX_INT_EN_REG);
 	udelay(ISL38XX_WRITEIO_DELAY);
 }
@@ -234,23 +235,21 @@ isl38xx_in_queue(isl38xx_control_block *
 		/* send queues */
 	case ISL38XX_CB_TX_MGMTQ:
 		BUG_ON(delta > ISL38XX_CB_MGMT_QSIZE);
+
 	case ISL38XX_CB_TX_DATA_LQ:
 	case ISL38XX_CB_TX_DATA_HQ:
 		BUG_ON(delta > ISL38XX_CB_TX_QSIZE);
 		return delta;
-		break;
 
 		/* receive queues */
 	case ISL38XX_CB_RX_MGMTQ:
 		BUG_ON(delta > ISL38XX_CB_MGMT_QSIZE);
 		return ISL38XX_CB_MGMT_QSIZE - delta;
-		break;
 
 	case ISL38XX_CB_RX_DATA_LQ:
 	case ISL38XX_CB_RX_DATA_HQ:
 		BUG_ON(delta > ISL38XX_CB_RX_QSIZE);
 		return ISL38XX_CB_RX_QSIZE - delta;
-		break;
 	}
 	BUG();
 	return 0;
diff --git a/drivers/net/wireless/prism54/isl_38xx.h b/drivers/net/wireless/prism54/isl_38xx.h
index 8af2098..3fadcb6 100644
--- a/drivers/net/wireless/prism54/isl_38xx.h
+++ b/drivers/net/wireless/prism54/isl_38xx.h
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *
  *  This program is free software; you can redistribute it and/or modify
@@ -67,10 +66,10 @@ #define ISL38XX_PCI_POSTING_FLUSH		ISL38
  * @base: (host) memory base address of the device
  * @val: 32bit value (host order) to write
  * @offset: byte offset into @base to write value to
- * 
+ *
  *  This helper takes care of writing a 32bit datum to the
- *  specified offset into the device's pci memory space, and making sure 
- *  the pci memory buffers get flushed by performing one harmless read 
+ *  specified offset into the device's pci memory space, and making sure
+ *  the pci memory buffers get flushed by performing one harmless read
  *  from the %ISL38XX_PCI_POSTING_FLUSH offset.
  */
 static inline void
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 286325c..4a20e45 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *            (C) 2003,2004 Aurelien Alleaume <slts@free.fr>
  *            (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
@@ -55,12 +54,12 @@ static const unsigned char scan_rate_lis
  * prism54_mib_mode_helper - MIB change mode helper function
  * @mib: the &struct islpci_mib object to modify
  * @iw_mode: new mode (%IW_MODE_*)
- * 
+ *
  *  This is a helper function, hence it does not lock. Make sure
- *  caller deals with locking *if* necessary. This function sets the 
- *  mode-dependent mib values and does the mapping of the Linux 
- *  Wireless API modes to Device firmware modes. It also checks for 
- *  correct valid Linux wireless modes. 
+ *  caller deals with locking *if* necessary. This function sets the
+ *  mode-dependent mib values and does the mapping of the Linux
+ *  Wireless API modes to Device firmware modes. It also checks for
+ *  correct valid Linux wireless modes.
  */
 static int
 prism54_mib_mode_helper(islpci_private *priv, u32 iw_mode)
@@ -118,7 +117,7 @@ prism54_mib_mode_helper(islpci_private *
  *
  *  this function initializes the struct given as @mib with defaults,
  *  of which many are retrieved from the global module parameter
- *  variables.  
+ *  variables.
  */
 
 void
@@ -134,7 +133,7 @@ prism54_mib_init(islpci_private *priv)
 	authen = CARD_DEFAULT_AUTHEN;
 	wep = CARD_DEFAULT_WEP;
 	filter = CARD_DEFAULT_FILTER; /* (0) Do not filter un-encrypted data */
-	dot1x = CARD_DEFAULT_DOT1X; 
+	dot1x = CARD_DEFAULT_DOT1X;
 	mlme = CARD_DEFAULT_MLME_MODE;
 	conformance = CARD_DEFAULT_CONFORMANCE;
 	power = 127;
@@ -228,7 +227,7 @@ prism54_get_wireless_stats(struct net_de
 	} else
 		priv->iwstatistics.qual.updated = 0;
 
-	/* Update our wireless stats, but do not schedule to often 
+	/* Update our wireless stats, but do not schedule to often
 	 * (max 1 HZ) */
 	if ((priv->stats_timestamp == 0) ||
 	    time_after(jiffies, priv->stats_timestamp + 1 * HZ)) {
@@ -705,7 +704,7 @@ prism54_get_scan(struct net_device *ndev
 	* Starting with WE-17, the buffer can be as big as needed.
 	* But the device won't repport anything if you change the value
 	* of IWMAX_BSS=24. */
-	
+
 	rvalue |= mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
 	bsslist = r.ptr;
 
@@ -785,7 +784,7 @@ prism54_get_essid(struct net_device *nde
 	return rvalue;
 }
 
-/* Provides no functionality, just completes the ioctl. In essence this is a 
+/* Provides no functionality, just completes the ioctl. In essence this is a
  * just a cosmetic ioctl.
  */
 static int
@@ -1104,7 +1103,7 @@ prism54_set_encode(struct net_device *nd
 					    &key);
 		}
 		/*
-		 * If a valid key is set, encryption should be enabled 
+		 * If a valid key is set, encryption should be enabled
 		 * (user may turn it off later).
 		 * This is also how "iwconfig ethX key on" works
 		 */
@@ -1126,7 +1125,7 @@ prism54_set_encode(struct net_device *nd
 	}
 	/* now read the flags */
 	if (dwrq->flags & IW_ENCODE_DISABLED) {
-		/* Encoding disabled, 
+		/* Encoding disabled,
 		 * authen = DOT11_AUTH_OS;
 		 * invoke = 0;
 		 * exunencrypt = 0; */
@@ -1214,7 +1213,7 @@ prism54_get_txpower(struct net_device *n
 	vwrq->value = (s32) r.u / 4;
 	vwrq->fixed = 1;
 	/* radio is not turned of
-	 * btw: how is possible to turn off only the radio 
+	 * btw: how is possible to turn off only the radio
 	 */
 	vwrq->disabled = 0;
 
@@ -2354,17 +2353,17 @@ prism54_process_trap_helper(islpci_priva
 		handle_request(priv, mlme, oid);
 		send_formatted_event(priv, "Authenticate request (ex)", mlme, 1);
 
-		if (priv->iw_mode != IW_MODE_MASTER 
+		if (priv->iw_mode != IW_MODE_MASTER
 				&& mlmeex->state != DOT11_STATE_AUTHING)
 			break;
 
 		confirm = kmalloc(sizeof(struct obj_mlmeex) + 6, GFP_ATOMIC);
 
-		if (!confirm) 
+		if (!confirm)
 			break;
 
 		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
-		printk(KERN_DEBUG "Authenticate from: address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
+		printk(KERN_DEBUG "Authenticate from: address:\t%02x:%02x:%02x:%02x:%02x:%02x\n",
 				mlmeex->address[0],
 				mlmeex->address[1],
 				mlmeex->address[2],
@@ -2398,10 +2397,10 @@ prism54_process_trap_helper(islpci_priva
 		handle_request(priv, mlme, oid);
 		send_formatted_event(priv, "Associate request (ex)", mlme, 1);
 
-		if (priv->iw_mode != IW_MODE_MASTER 
+		if (priv->iw_mode != IW_MODE_MASTER
 				&& mlmeex->state != DOT11_STATE_ASSOCING)
 			break;
-		
+
 		confirm = kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
 
 		if (!confirm)
@@ -2417,7 +2416,7 @@ prism54_process_trap_helper(islpci_priva
 
 		if (!wpa_ie_len) {
 			printk(KERN_DEBUG "No WPA IE found from "
-					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
+					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n",
 				mlmeex->address[0],
 				mlmeex->address[1],
 				mlmeex->address[2],
@@ -2435,14 +2434,14 @@ prism54_process_trap_helper(islpci_priva
 		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
 
 		kfree(confirm);
-		
+
 		break;
 
 	case DOT11_OID_REASSOCIATEEX:
 		handle_request(priv, mlme, oid);
 		send_formatted_event(priv, "Reassociate request (ex)", mlme, 1);
 
-		if (priv->iw_mode != IW_MODE_MASTER 
+		if (priv->iw_mode != IW_MODE_MASTER
 				&& mlmeex->state != DOT11_STATE_ASSOCING)
 			break;
 
@@ -2461,7 +2460,7 @@ prism54_process_trap_helper(islpci_priva
 
 		if (!wpa_ie_len) {
 			printk(KERN_DEBUG "No WPA IE found from "
-					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
+					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n",
 				mlmeex->address[0],
 				mlmeex->address[1],
 				mlmeex->address[2],
@@ -2473,13 +2472,13 @@ prism54_process_trap_helper(islpci_priva
 			break;
 		}
 
-		confirm->size = wpa_ie_len; 
+		confirm->size = wpa_ie_len;
 		memcpy(&confirm->data, wpa_ie, wpa_ie_len);
 
 		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
 
 		kfree(confirm);
-		
+
 		break;
 
 	default:
@@ -2545,10 +2544,10 @@ #define PRISM2_HOSTAPD_MAX_BUF_SIZE 1024
 #define PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN \
 ((int) (&((struct prism2_hostapd_param *) 0)->u.generic_elem.data))
 
-/* Maximum length for algorithm names (-1 for nul termination) 
+/* Maximum length for algorithm names (-1 for nul termination)
  * used in ioctl() */
 #define HOSTAP_CRYPT_ALG_NAME_LEN 16
-	
+
 struct prism2_hostapd_param {
 	u32 cmd;
 	u8 sta_addr[ETH_ALEN];
@@ -2621,7 +2620,7 @@ prism2_ioctl_set_encryption(struct net_d
 					    &key);
 		}
 		/*
-		 * If a valid key is set, encryption should be enabled 
+		 * If a valid key is set, encryption should be enabled
 		 * (user may turn it off later).
 		 * This is also how "iwconfig ethX key on" works
 		 */
@@ -2643,7 +2642,7 @@ prism2_ioctl_set_encryption(struct net_d
 	}
 	/* now read the flags */
 	if (param->u.crypt.flags & IW_ENCODE_DISABLED) {
-		/* Encoding disabled, 
+		/* Encoding disabled,
 		 * authen = DOT11_AUTH_OS;
 		 * invoke = 0;
 		 * exunencrypt = 0; */
@@ -2710,7 +2709,7 @@ #define WLAN_FC_STYPE_REASSOC_REQ 2
 
 	       ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, len);
 
-	       if (ret == 0) 
+	       if (ret == 0)
 		       printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
 				       ndev->name);
        }
@@ -2870,7 +2869,7 @@ prism54_set_wpa(struct net_device *ndev,
 			mlme = DOT11_MLME_AUTO;
 			printk("%s: Disabling WPA\n", ndev->name);
 			break;
-		case 2: 
+		case 2:
 		case 1: /* WPA */
 			printk("%s: Enabling WPA\n", ndev->name);
 			break;
diff --git a/drivers/net/wireless/prism54/isl_ioctl.h b/drivers/net/wireless/prism54/isl_ioctl.h
index 65f33ac..e8183d3 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.h
+++ b/drivers/net/wireless/prism54/isl_ioctl.h
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *            (C) 2003 Aurelien Alleaume <slts@free.fr>
  *            (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
diff --git a/drivers/net/wireless/prism54/isl_oid.h b/drivers/net/wireless/prism54/isl_oid.h
index 419edf7..b7534c2 100644
--- a/drivers/net/wireless/prism54/isl_oid.h
+++ b/drivers/net/wireless/prism54/isl_oid.h
@@ -1,6 +1,4 @@
 /*
- *
- *  
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *  Copyright (C) 2004 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *  Copyright (C) 2004 Aurelien Alleaume <slts@free.fr>
@@ -23,7 +21,7 @@
 #if !defined(_ISL_OID_H)
 #define _ISL_OID_H
 
-/* 
+/*
  * MIB related constant and structure definitions for communicating
  * with the device firmware
  */
@@ -99,21 +97,21 @@ struct obj_attachment {
 	char data[0];
 } __attribute__((packed));
 
-/* 
+/*
  * in case everything's ok, the inlined function below will be
  * optimized away by the compiler...
  */
 static inline void
 __bug_on_wrong_struct_sizes(void)
 {
-	BUG_ON(sizeof (struct obj_ssid) != 34);
-	BUG_ON(sizeof (struct obj_key) != 34);
-	BUG_ON(sizeof (struct obj_mlme) != 12);
-	BUG_ON(sizeof (struct obj_mlmeex) != 14);
-	BUG_ON(sizeof (struct obj_buffer) != 8);
-	BUG_ON(sizeof (struct obj_bss) != 60);
-	BUG_ON(sizeof (struct obj_bsslist) != 4);
-	BUG_ON(sizeof (struct obj_frequencies) != 2);
+	BUILD_BUG_ON(sizeof (struct obj_ssid) != 34);
+	BUILD_BUG_ON(sizeof (struct obj_key) != 34);
+	BUILD_BUG_ON(sizeof (struct obj_mlme) != 12);
+	BUILD_BUG_ON(sizeof (struct obj_mlmeex) != 14);
+	BUILD_BUG_ON(sizeof (struct obj_buffer) != 8);
+	BUILD_BUG_ON(sizeof (struct obj_bss) != 60);
+	BUILD_BUG_ON(sizeof (struct obj_bsslist) != 4);
+	BUILD_BUG_ON(sizeof (struct obj_frequencies) != 2);
 }
 
 enum dot11_state_t {
@@ -154,13 +152,13 @@ enum dot11_priv_t {
 
 /* Prism "Nitro" / Frameburst / "Packet Frame Grouping"
  * Value is in microseconds. Represents the # microseconds
- * the firmware will take to group frames before sending out then out 
+ * the firmware will take to group frames before sending out then out
  * together with a CSMA contention. Without this all frames are
- * sent with a CSMA contention. 
- * Bibliography: 
+ * sent with a CSMA contention.
+ * Bibliography:
  * http://www.hpl.hp.com/personal/Jean_Tourrilhes/Papers/Packet.Frame.Grouping.html
  */
-enum dot11_maxframeburst_t { 
+enum dot11_maxframeburst_t {
 	/* Values for DOT11_OID_MAXFRAMEBURST */
 	DOT11_MAXFRAMEBURST_OFF = 0, /* Card firmware default */
 	DOT11_MAXFRAMEBURST_MIXED_SAFE = 650, /* 802.11 a,b,g safe */
@@ -176,9 +174,9 @@ enum dot11_maxframeburst_t { 
 /* Support for 802.11 long and short frame preambles.
  * Long	 preamble uses 128-bit sync field, 8-bit  CRC
  * Short preamble uses 56-bit  sync field, 16-bit CRC
- * 
+ *
  * 802.11a -- not sure, both optionally ?
- * 802.11b supports long and optionally short 
+ * 802.11b supports long and optionally short
  * 802.11g supports both */
 enum dot11_preamblesettings_t {
 	DOT11_PREAMBLESETTING_LONG = 0,
@@ -194,7 +192,7 @@ enum dot11_preamblesettings_t {
  * Long uses 802.11a slot timing  (9 usec ?)
  * Short uses 802.11b slot timing (20 use ?) */
 enum dot11_slotsettings_t {
-	DOT11_SLOTSETTINGS_LONG = 0, 
+	DOT11_SLOTSETTINGS_LONG = 0,
 		/* Allows *only* long 802.11b slot timing */
 	DOT11_SLOTSETTINGS_SHORT = 1,
 		/* Allows *only* long 802.11a slot timing */
@@ -203,7 +201,7 @@ enum dot11_slotsettings_t {
 };
 
 /* All you need to know, ERP is "Extended Rate PHY".
- * An Extended Rate PHY (ERP) STA or AP shall support three different 
+ * An Extended Rate PHY (ERP) STA or AP shall support three different
  * preamble and header formats:
  * Long  preamble (refer to above)
  * Short preamble (refer to above)
@@ -221,7 +219,7 @@ enum do11_nonerpstatus_t {
 /* (ERP is "Extended Rate PHY") Way to read NONERP is NON-ERP-*
  * The key here is DOT11 NON ERP NEVER protects against
  * NON ERP STA's. You *don't* want this unless
- * you know what you are doing. It means you will only 
+ * you know what you are doing. It means you will only
  * get Extended Rate capabilities */
 enum dot11_nonerpprotection_t {
 	DOT11_NONERP_NEVER = 0,
@@ -229,13 +227,13 @@ enum dot11_nonerpprotection_t {
 	DOT11_NONERP_DYNAMIC = 2
 };
 
-/* Preset OID configuration for 802.11 modes 
- * Note: DOT11_OID_CW[MIN|MAX] hold the values of the 
+/* Preset OID configuration for 802.11 modes
+ * Note: DOT11_OID_CW[MIN|MAX] hold the values of the
  * DCS MIN|MAX backoff used */
 enum dot11_profile_t { /* And set/allowed values */
 	/* Allowed values for DOT11_OID_PROFILES */
 	DOT11_PROFILE_B_ONLY = 0,
-		/* DOT11_OID_RATES: 1, 2, 5.5, 11Mbps 
+		/* DOT11_OID_RATES: 1, 2, 5.5, 11Mbps
 		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_DYNAMIC
 		 * DOT11_OID_CWMIN: 31
 		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_DYNAMIC
@@ -275,7 +273,7 @@ enum oid_inl_conformance_t {
 	OID_INL_CONFORMANCE_NONE = 0,	/* Perform active scanning */
 	OID_INL_CONFORMANCE_STRICT = 1,	/* Strictly adhere to 802.11d */
 	OID_INL_CONFORMANCE_FLEXIBLE = 2,	/* Use passed 802.11d info to
-		* determine channel AND/OR just make assumption that active 
+		* determine channel AND/OR just make assumption that active
 		* channels are valid  channels */
 };
 
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index ec1c00f..1e0603c 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *  Copyright (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
@@ -413,7 +412,7 @@ prism54_bring_down(islpci_private *priv)
 	islpci_set_state(priv, PRV_STATE_PREBOOT);
 
 	/* disable all device interrupts in case they weren't */
-	isl38xx_disable_interrupts(priv->device_base);  
+	isl38xx_disable_interrupts(priv->device_base);
 
 	/* For safety reasons, we may want to ensure that no DMA transfer is
 	 * currently in progress by emptying the TX and RX queues. */
@@ -480,7 +479,7 @@ islpci_reset_if(islpci_private *priv)
 
 	DEFINE_WAIT(wait);
 	prepare_to_wait(&priv->reset_done, &wait, TASK_UNINTERRUPTIBLE);
-	
+
 	/* now the last step is to reset the interface */
 	isl38xx_interface_reset(priv->device_base, priv->device_host_address);
 	islpci_set_state(priv, PRV_STATE_PREINIT);
@@ -488,7 +487,7 @@ islpci_reset_if(islpci_private *priv)
         for(count = 0; count < 2 && result; count++) {
 		/* The software reset acknowledge needs about 220 msec here.
 		 * Be conservative and wait for up to one second. */
-	
+
 		remaining = schedule_timeout_uninterruptible(HZ);
 
 		if(remaining > 0) {
@@ -496,7 +495,7 @@ islpci_reset_if(islpci_private *priv)
 			break;
 		}
 
-		/* If we're here it's because our IRQ hasn't yet gone through. 
+		/* If we're here it's because our IRQ hasn't yet gone through.
 		 * Retry a bit more...
 		 */
 		printk(KERN_ERR "%s: no 'reset complete' IRQ seen - retrying\n",
@@ -514,7 +513,7 @@ islpci_reset_if(islpci_private *priv)
 
 	/* Now that the device is 100% up, let's allow
 	 * for the other interrupts --
-	 * NOTE: this is not *yet* true since we've only allowed the 
+	 * NOTE: this is not *yet* true since we've only allowed the
 	 * INIT interrupt on the IRQ line. We can perhaps poll
 	 * the IRQ line until we know for sure the reset went through */
 	isl38xx_enable_common_interrupts(priv->device_base);
@@ -716,7 +715,7 @@ #endif
 
 	prism54_acl_init(&priv->acl);
 	prism54_wpa_bss_ie_init(priv);
-	if (mgt_init(priv)) 
+	if (mgt_init(priv))
 		goto out_free;
 
 	return 0;
diff --git a/drivers/net/wireless/prism54/islpci_dev.h b/drivers/net/wireless/prism54/islpci_dev.h
index 2f7e525..a9aa166 100644
--- a/drivers/net/wireless/prism54/islpci_dev.h
+++ b/drivers/net/wireless/prism54/islpci_dev.h
@@ -1,6 +1,5 @@
 /*
- *  
- *  Copyright (C) 2002 Intersil Americas Inc. 
+ *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *  Copyright (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *  Copyright (C) 2003 Aurelien Alleaume <slts@free.fr>
@@ -72,12 +71,12 @@ struct islpci_bss_wpa_ie {
 	u8 bssid[ETH_ALEN];
 	u8 wpa_ie[MAX_WPA_IE_LEN];
 	size_t wpa_ie_len;
-	
+
 };
 
 typedef struct {
 	spinlock_t slock;	/* generic spinlock; */
-	
+
 	u32 priv_oid;
 
 	/* our mib cache */
@@ -85,7 +84,7 @@ typedef struct {
         struct rw_semaphore mib_sem;
 	void **mib;
 	char nickname[IW_ESSID_MAX_SIZE+1];
-	
+
 	/* Take care of the wireless stats */
 	struct work_struct stats_work;
 	struct semaphore stats_sem;
@@ -120,7 +119,7 @@ typedef struct {
 	struct net_device *ndev;
 
 	/* device queue interface members */
-	struct isl38xx_cb *control_block;	/* device control block 
+	struct isl38xx_cb *control_block;	/* device control block
 							   (== driver_mem_address!) */
 
 	/* Each queue has three indexes:
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index a8261d8..676d838 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2004 Aurelien Alleaume <slts@free.fr>
  *  This program is free software; you can redistribute it and/or modify
@@ -48,7 +47,7 @@ islpci_eth_cleanup_transmit(islpci_priva
 		/* read the index of the first fragment to be freed */
 		index = priv->free_data_tx % ISL38XX_CB_TX_QSIZE;
 
-		/* check for holes in the arrays caused by multi fragment frames 
+		/* check for holes in the arrays caused by multi fragment frames
 		 * searching for the last fragment of a frame */
 		if (priv->pci_map_tx_address[index] != (dma_addr_t) NULL) {
 			/* entry is the last fragment of a frame
@@ -253,6 +252,7 @@ islpci_monitor_rx(islpci_private *priv, 
 	 * header and without the FCS. But there a is a bit that
 	 * indicates if the packet is corrupted :-) */
 	struct rfmon_header *hdr = (struct rfmon_header *) (*skb)->data;
+
 	if (hdr->flags & 0x01)
 		/* This one is bad. Drop it ! */
 		return -1;
@@ -284,7 +284,7 @@ islpci_monitor_rx(islpci_private *priv, 
 		    (struct avs_80211_1_header *) skb_push(*skb,
 							   sizeof (struct
 								   avs_80211_1_header));
-		
+
 		avs->version = cpu_to_be32(P80211CAPTURE_VERSION);
 		avs->length = cpu_to_be32(sizeof (struct avs_80211_1_header));
 		avs->mactime = cpu_to_be64(le64_to_cpu(clock));
@@ -390,7 +390,7 @@ #endif
 			struct rx_annex_header *annex =
 			    (struct rx_annex_header *) skb->data;
 			wstats.level = annex->rfmon.rssi;
-			/* The noise value can be a bit outdated if nobody's 
+			/* The noise value can be a bit outdated if nobody's
 			 * reading wireless stats... */
 			wstats.noise = priv->local_iwstatistics.qual.noise;
 			wstats.qual = wstats.level - wstats.noise;
@@ -464,10 +464,8 @@ #endif
 			break;
 		}
 		/* update the fragment address */
-		control_block->rx_data_low[index].address = cpu_to_le32((u32)
-									priv->
-									pci_map_rx_address
-									[index]);
+		control_block->rx_data_low[index].address =
+			cpu_to_le32((u32)priv->pci_map_rx_address[index]);
 		wmb();
 
 		/* increment the driver read pointer */
@@ -484,10 +482,12 @@ #endif
 void
 islpci_do_reset_and_wake(void *data)
 {
-	islpci_private *priv = (islpci_private *) data;
+	islpci_private *priv = data;
+
 	islpci_reset(priv, 1);
-	netif_wake_queue(priv->ndev);
 	priv->reset_task_pending = 0;
+	smp_wmb();
+	netif_wake_queue(priv->ndev);
 }
 
 void
@@ -499,12 +499,14 @@ islpci_eth_tx_timeout(struct net_device 
 	/* increment the transmit error counter */
 	statistics->tx_errors++;
 
-	printk(KERN_WARNING "%s: tx_timeout", ndev->name);
 	if (!priv->reset_task_pending) {
-		priv->reset_task_pending = 1;
-		printk(", scheduling a reset");
+		printk(KERN_WARNING
+			"%s: tx_timeout, scheduling reset", ndev->name);
 		netif_stop_queue(ndev);
+		priv->reset_task_pending = 1;
 		schedule_work(&priv->reset_task);
+	} else {
+		printk(KERN_WARNING
+			"%s: tx_timeout, waiting for reset", ndev->name);
 	}
-	printk("\n");
 }
diff --git a/drivers/net/wireless/prism54/islpci_eth.h b/drivers/net/wireless/prism54/islpci_eth.h
index bc9d7a6..2678945 100644
--- a/drivers/net/wireless/prism54/islpci_eth.h
+++ b/drivers/net/wireless/prism54/islpci_eth.h
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *
  *  This program is free software; you can redistribute it and/or modify
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
index f692dcc..f6354b1 100644
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *
@@ -40,8 +39,8 @@ static int	init_pcitm = 0;
 module_param(init_pcitm, int, 0);
 
 /* In this order: vendor, device, subvendor, subdevice, class, class_mask,
- * driver_data 
- * If you have an update for this please contact prism54-devel@prism54.org 
+ * driver_data
+ * If you have an update for this please contact prism54-devel@prism54.org
  * The latest list can be found at http://prism54.org/supported_cards.php */
 static const struct pci_device_id prism54_id_tbl[] = {
 	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
@@ -132,15 +131,15 @@ #endif
 
 	/* 0x40 is the programmable timer to configure the response timeout (TRDY_TIMEOUT)
 	 * 0x41 is the programmable timer to configure the retry timeout (RETRY_TIMEOUT)
-	 * 	The RETRY_TIMEOUT is used to set the number of retries that the core, as a
-	 * 	Master, will perform before abandoning a cycle. The default value for
-	 * 	RETRY_TIMEOUT is 0x80, which far exceeds the PCI 2.1 requirement for new
-	 * 	devices. A write of zero to the RETRY_TIMEOUT register disables this
-	 * 	function to allow use with any non-compliant legacy devices that may
-	 * 	execute more retries.
+	 *	The RETRY_TIMEOUT is used to set the number of retries that the core, as a
+	 *	Master, will perform before abandoning a cycle. The default value for
+	 *	RETRY_TIMEOUT is 0x80, which far exceeds the PCI 2.1 requirement for new
+	 *	devices. A write of zero to the RETRY_TIMEOUT register disables this
+	 *	function to allow use with any non-compliant legacy devices that may
+	 *	execute more retries.
 	 *
-	 * 	Writing zero to both these two registers will disable both timeouts and
-	 * 	*can* solve problems caused by devices that are slow to respond.
+	 *	Writing zero to both these two registers will disable both timeouts and
+	 *	*can* solve problems caused by devices that are slow to respond.
 	 *	Make this configurable - MSW
 	 */
 	if ( init_pcitm >= 0 ) {
@@ -241,7 +240,7 @@ prism54_remove(struct pci_dev *pdev)
 		isl38xx_disable_interrupts(priv->device_base);
 		islpci_set_state(priv, PRV_STATE_OFF);
 		/* This bellow causes a lockup at rmmod time. It might be
-		 * because some interrupts still linger after rmmod time, 
+		 * because some interrupts still linger after rmmod time,
 		 * see bug #17 */
 		/* pci_set_power_state(pdev, 3);*/	/* try to power-off */
 	}
diff --git a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wireless/prism54/islpci_mgt.c
index 2e061a8..036a875 100644
--- a/drivers/net/wireless/prism54/islpci_mgt.c
+++ b/drivers/net/wireless/prism54/islpci_mgt.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright 2004 Jens Maurer <Jens.Maurer@gmx.net>
  *
@@ -502,7 +501,7 @@ islpci_mgt_transaction(struct net_device
 	printk(KERN_WARNING "%s: timeout waiting for mgmt response\n",
 	       ndev->name);
 
-	/* TODO: we should reset the device here */     
+	/* TODO: we should reset the device here */
  out:
 	finish_wait(&priv->mgmt_wqueue, &wait);
 	up(&priv->mgmt_sem);
diff --git a/drivers/net/wireless/prism54/islpci_mgt.h b/drivers/net/wireless/prism54/islpci_mgt.h
index 2982be3..fc53b58 100644
--- a/drivers/net/wireless/prism54/islpci_mgt.h
+++ b/drivers/net/wireless/prism54/islpci_mgt.h
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *
@@ -36,8 +35,8 @@ #define init_wds 0	/* help compiler opti
 
 
 /* General driver definitions */
-#define PCIDEVICE_LATENCY_TIMER_MIN 		0x40
-#define PCIDEVICE_LATENCY_TIMER_VAL 		0x50
+#define PCIDEVICE_LATENCY_TIMER_MIN		0x40
+#define PCIDEVICE_LATENCY_TIMER_VAL		0x50
 
 /* Debugging verbose definitions */
 #define SHOW_NOTHING                            0x00	/* overrules everything */
diff --git a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
index ebb2387..fbc52b6 100644
--- a/drivers/net/wireless/prism54/oid_mgt.c
+++ b/drivers/net/wireless/prism54/oid_mgt.c
@@ -1,4 +1,4 @@
-/*   
+/*
  *  Copyright (C) 2003,2004 Aurelien Alleaume <slts@free.fr>
  *
  *  This program is free software; you can redistribute it and/or modify
@@ -503,7 +503,7 @@ mgt_set_varlen(islpci_private *priv, enu
 		}
 		if (ret || response_op == PIMFOR_OP_ERROR)
 			ret = -EIO;
-	} else 
+	} else
 		ret = -EIO;
 
 	/* re-set given data to what it was */
@@ -727,7 +727,7 @@ mgt_commit(islpci_private *priv)
  * MEDIUMLIMIT,BEACONPERIOD,DTIMPERIOD,ATIMWINDOW,LISTENINTERVAL
  * FREQUENCY,EXTENDEDRATES.
  *
- * The way to do this is to set ESSID. Note though that they may get 
+ * The way to do this is to set ESSID. Note though that they may get
  * unlatch before though by setting another OID. */
 #if 0
 void
diff --git a/drivers/net/wireless/prism54/prismcompat.h b/drivers/net/wireless/prism54/prismcompat.h
index d71eca5..aa1d174 100644
--- a/drivers/net/wireless/prism54/prismcompat.h
+++ b/drivers/net/wireless/prism54/prismcompat.h
@@ -1,4 +1,4 @@
-/*  
+/*
  *  (C) 2004 Margit Schubert-While <margitsw@t-online.de>
  *
  *  This program is free software; you can redistribute it and/or modify
@@ -16,7 +16,7 @@
  *
  */
 
-/*  
+/*
  *	Compatibility header file to aid support of different kernel versions
  */
 
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 3faaeb2..005ca7a 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -47,6 +47,9 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0586, 0x3402), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0b3b, 0x5630), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0b05, 0x170c), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x1435, 0x0711), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0586, 0x3409), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0b3b, 0x1630), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index b174ebb..e6af381 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -1037,6 +1037,10 @@ struct ieee80211_device {
 	/* host performs multicast decryption */
 	int host_mc_decrypt;
 
+	/* host should strip IV and ICV from protected frames */
+	/* meaningful only when hardware decryption is being used */
+	int host_strip_iv_icv;
+
 	int host_open_frag;
 	int host_build_iv;
 	int ieee802_1x;		/* is IEEE 802.1X used */
@@ -1076,6 +1080,8 @@ struct ieee80211_device {
 	int perfect_rssi;
 	int worst_rssi;
 
+	u16 prev_seq_ctl;	/* used to drop duplicate frames */
+
 	/* Callback functions */
 	void (*set_security) (struct net_device * dev,
 			      struct ieee80211_security * sec);
diff --git a/net/ieee80211/ieee80211_module.c b/net/ieee80211/ieee80211_module.c
index 13b1e5f..2b14c2f 100644
--- a/net/ieee80211/ieee80211_module.c
+++ b/net/ieee80211/ieee80211_module.c
@@ -118,6 +118,14 @@ static void ieee80211_networks_initializ
 			      &ieee->network_free_list);
 }
 
+static int ieee80211_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < 68) || (new_mtu > IEEE80211_DATA_LEN))
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 struct net_device *alloc_ieee80211(int sizeof_priv)
 {
 	struct ieee80211_device *ieee;
@@ -133,6 +141,7 @@ struct net_device *alloc_ieee80211(int s
 	}
 	ieee = netdev_priv(dev);
 	dev->hard_start_xmit = ieee80211_xmit;
+	dev->change_mtu = ieee80211_change_mtu;
 
 	ieee->dev = dev;
 
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 7707041..50699b5 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -415,17 +415,16 @@ #endif
 	    ieee->host_mc_decrypt : ieee->host_decrypt;
 
 	if (can_be_decrypted) {
-		int idx = 0;
 		if (skb->len >= hdrlen + 3) {
 			/* Top two-bits of byte 3 are the key index */
-			idx = skb->data[hdrlen + 3] >> 6;
+			keyidx = skb->data[hdrlen + 3] >> 6;
 		}
 
-		/* ieee->crypt[] is WEP_KEY (4) in length.  Given that idx
-		 * is only allowed 2-bits of storage, no value of idx can
-		 * be provided via above code that would result in idx
+		/* ieee->crypt[] is WEP_KEY (4) in length.  Given that keyidx
+		 * is only allowed 2-bits of storage, no value of keyidx can
+		 * be provided via above code that would result in keyidx
 		 * being out of range */
-		crypt = ieee->crypt[idx];
+		crypt = ieee->crypt[keyidx];
 
 #ifdef NOT_YET
 		sta = NULL;
@@ -479,6 +478,11 @@ #ifdef NOT_YET
 			goto rx_exit;
 	}
 #endif
+	/* drop duplicate 802.11 retransmissions (IEEE 802.11 Chap. 9.29) */
+	if (sc == ieee->prev_seq_ctl)
+		goto rx_dropped;
+	else
+		ieee->prev_seq_ctl = sc;
 
 	/* Data frame - extract src/dst addresses */
 	if (skb->len < IEEE80211_3ADDR_LEN)
@@ -655,6 +659,51 @@ #endif
 		goto rx_dropped;
 	}
 
+	/* If the frame was decrypted in hardware, we may need to strip off
+	 * any security data (IV, ICV, etc) that was left behind */
+	if (!can_be_decrypted && (fc & IEEE80211_FCTL_PROTECTED) &&
+	    ieee->host_strip_iv_icv) {
+	    	int trimlen = 0;
+
+		/* Top two-bits of byte 3 are the key index */
+		if (skb->len >= hdrlen + 3)
+			keyidx = skb->data[hdrlen + 3] >> 6;
+
+		/* To strip off any security data which appears before the
+		 * payload, we simply increase hdrlen (as the header gets
+		 * chopped off immediately below). For the security data which
+		 * appears after the payload, we use skb_trim. */
+
+		switch (ieee->sec.encode_alg[keyidx]) {
+		case SEC_ALG_WEP:
+			/* 4 byte IV */
+			hdrlen += 4;
+			/* 4 byte ICV */
+			trimlen = 4;
+			break;
+		case SEC_ALG_TKIP:
+			/* 4 byte IV, 4 byte ExtIV */
+			hdrlen += 8;
+			/* 8 byte MIC, 4 byte ICV */
+			trimlen = 12;
+			break;
+		case SEC_ALG_CCMP:
+			/* 8 byte CCMP header */
+			hdrlen += 8;
+			/* 8 byte MIC */
+			trimlen = 8;
+			break;
+		}
+
+		if (skb->len < trimlen)
+			goto rx_dropped;
+
+		__skb_trim(skb, skb->len - trimlen);
+
+		if (skb->len < hdrlen)
+			goto rx_dropped;
+	}
+
 	/* skb: hdr + (possible reassembled) full plaintext payload */
 
 	payload = skb->data + hdrlen;
-- 
John W. Linville
linville@tuxdriver.com
