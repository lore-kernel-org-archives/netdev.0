From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 11/15] wireless/orinoco: Clean up firmware
	version & capability detection
Date: Tue, 26 Oct 2004 15:18:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098818311.3663.81.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o Clean up firmware version & capability detection

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco.c.11-firmware-fixes	2004-10-26 15:15:11.454350912 -0400
+++ b/drivers/net/wireless/orinoco.c	2004-10-26 15:15:11.456350608 -0400
@@ -1452,7 +1452,7 @@
 		return err;
 
 	err = hermes_allocate(hw, priv->nicbuf_size, &priv->txfid);
-	if (err == -EIO) {
+	if (err == -EIO && priv->nicbuf_size > TX_NICBUF_SIZE_BUG) {
 		/* Try workaround for old Symbol firmware bug */
 		printk(KERN_WARNING "%s: firmware ALLOC bug detected "
 		       "(old Symbol firmware?). Trying to work around... ",
@@ -2098,39 +2098,54 @@
 /* Initialization                                                   */
 /********************************************************************/
 
-struct sta_id {
+struct comp_id {
 	u16 id, variant, major, minor;
 } __attribute__ ((packed));
 
-static int determine_firmware_type(struct net_device *dev, struct sta_id *sta_id)
+static inline fwtype_t determine_firmware_type(struct comp_id *nic_id)
 {
-	/* FIXME: this is fundamentally broken */
-	unsigned int firmver = ((u32)sta_id->major << 16) | sta_id->minor;
-	
-	if (sta_id->variant == 1)
+	if (nic_id->id < 0x8000)
 		return FIRMWARE_TYPE_AGERE;
-	else if ((sta_id->variant == 2) &&
-		   ((firmver == 0x10001) || (firmver == 0x20001)))
+	else if (nic_id->id == 0x8000 && nic_id->major == 0)
 		return FIRMWARE_TYPE_SYMBOL;
 	else
 		return FIRMWARE_TYPE_INTERSIL;
 }
 
-static void determine_firmware(struct net_device *dev)
+/* Set priv->firmware type, determine firmware properties */
+static int determine_firmware(struct net_device *dev)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	int err;
-	struct sta_id sta_id;
+	struct comp_id nic_id, sta_id;
 	unsigned int firmver;
 	char tmp[SYMBOL_MAX_VER_LEN+1];
 
+	/* Get the hardware version */
+	err = HERMES_READ_RECORD(hw, USER_BAP, HERMES_RID_NICID, &nic_id);
+	if (err) {
+		printk(KERN_ERR "%s: Cannot read hardware identity: error %d\n",
+		       dev->name, err);
+		return err;
+	}
+
+	le16_to_cpus(&nic_id.id);
+	le16_to_cpus(&nic_id.variant);
+	le16_to_cpus(&nic_id.major);
+	le16_to_cpus(&nic_id.minor);
+	printk(KERN_DEBUG "%s: Hardware identity %04x:%04x:%04x:%04x\n",
+	       dev->name, nic_id.id, nic_id.variant,
+	       nic_id.major, nic_id.minor);
+
+	priv->firmware_type = determine_firmware_type(&nic_id);
+
 	/* Get the firmware version */
 	err = HERMES_READ_RECORD(hw, USER_BAP, HERMES_RID_STAID, &sta_id);
 	if (err) {
 		printk(KERN_ERR "%s: Cannot read station identity: error %d\n",
 		       dev->name, err);
-		memset(&sta_id, 0, sizeof(sta_id));
+		return err;
 	}
 
 	le16_to_cpus(&sta_id.id);
@@ -2141,8 +2156,23 @@
 	       dev->name, sta_id.id, sta_id.variant,
 	       sta_id.major, sta_id.minor);
 
-	if (! priv->firmware_type)
-		priv->firmware_type = determine_firmware_type(dev, &sta_id);
+	switch (sta_id.id) {
+	case 0x15:
+		printk(KERN_ERR "%s: Primary firmware is active\n",
+		       dev->name);
+		return -ENODEV;
+	case 0x14b:
+		printk(KERN_ERR "%s: Tertiary firmware is active\n",
+		       dev->name);
+		return -ENODEV;
+	case 0x1f:	/* Intersil, Agere, Symbol Spectrum24 */
+	case 0x21:	/* Symbol Spectrum24 Trilogy */
+		break;
+	default:
+		printk(KERN_NOTICE "%s: Unknown station ID, please report\n",
+		       dev->name);
+		break;
+	}
 
 	/* Default capabilities */
 	priv->has_sensitivity = 1;
@@ -2158,9 +2188,8 @@
 	case FIRMWARE_TYPE_AGERE:
 		/* Lucent Wavelan IEEE, Lucent Orinoco, Cabletron RoamAbout,
 		   ELSA, Melco, HP, IBM, Dell 1150, Compaq 110/210 */
-		printk(KERN_DEBUG "%s: Looks like a Lucent/Agere firmware "
-		       "version %d.%02d\n", dev->name,
-		       sta_id.major, sta_id.minor);
+		snprintf(priv->fw_name, sizeof(priv->fw_name) - 1,
+			 "Lucent/Agere %d.%02d", sta_id.major, sta_id.minor);
 
 		firmver = ((unsigned long)sta_id.major << 16) | sta_id.minor;
 
@@ -2203,16 +2232,19 @@
 			tmp[SYMBOL_MAX_VER_LEN] = '\0';
 		}
 
-		printk(KERN_DEBUG "%s: Looks like a Symbol firmware "
-		       "version [%s] (parsing to %X)\n", dev->name,
-		       tmp, firmver);
+		snprintf(priv->fw_name, sizeof(priv->fw_name) - 1,
+			 "Symbol %s", tmp);
 
 		priv->has_ibss = (firmver >= 0x20000);
 		priv->has_wep = (firmver >= 0x15012);
 		priv->has_big_wep = (firmver >= 0x20000);
-		priv->has_pm = (firmver >= 0x20000) && (firmver < 0x22000);
+		priv->has_pm = (firmver >= 0x20000 && firmver < 0x22000) || 
+			       (firmver >= 0x29000 && firmver < 0x30000) ||
+			       firmver >= 0x31000;
 		priv->has_preamble = (firmver >= 0x20000);
 		priv->ibss_port = 4;
+		priv->broken_disableport = (firmver == 0x25013) ||
+					   (firmver >= 0x30000 && firmver <= 0x31000);
 		/* Tested with Intel firmware : 0x20015 => Jean II */
 		/* Tested with 3Com firmware : 0x15012 & 0x22001 => Jean II */
 		break;
@@ -2222,9 +2254,9 @@
 		 * different and less well tested */
 		/* D-Link MAC : 00:40:05:* */
 		/* Addtron MAC : 00:90:D1:* */
-		printk(KERN_DEBUG "%s: Looks like an Intersil firmware "
-		       "version %d.%d.%d\n", dev->name,
-		       sta_id.major, sta_id.minor, sta_id.variant);
+		snprintf(priv->fw_name, sizeof(priv->fw_name) - 1,
+			 "Intersil %d.%d.%d", sta_id.major, sta_id.minor,
+			 sta_id.variant);
 
 		firmver = ((unsigned long)sta_id.major << 16) |
 			((unsigned long)sta_id.minor << 8) | sta_id.variant;
@@ -2242,9 +2274,11 @@
 			priv->ibss_port = 1;
 		}
 		break;
-	default:
-		break;
 	}
+	printk(KERN_DEBUG "%s: Firmware determined as %s\n", dev->name,
+	       priv->fw_name);
+
+	return 0;
 }
 
 static int orinoco_init(struct net_device *dev)
@@ -2263,14 +2297,19 @@
 	priv->nicbuf_size = IEEE802_11_FRAME_LEN + ETH_HLEN;
 
 	/* Initialize the firmware */
-	err = hermes_init(hw);
+	err = orinoco_reinit_firmware(dev);
 	if (err != 0) {
 		printk(KERN_ERR "%s: failed to initialize firmware (err = %d)\n",
 		       dev->name, err);
 		goto out;
 	}
 
-	determine_firmware(dev);
+	err = determine_firmware(dev);
+	if (err != 0) {
+		printk(KERN_ERR "%s: Incompatible firmware, aborting\n",
+		       dev->name);
+		goto out;
+	}
 
 	if (priv->has_port3)
 		printk(KERN_DEBUG "%s: Ad-hoc demo mode supported\n", dev->name);
@@ -2391,31 +2430,12 @@
 	/* By default use IEEE/IBSS ad-hoc mode if we have it */
 	priv->prefer_port3 = priv->has_port3 && (! priv->has_ibss);
 	set_port_type(priv);
-	priv->channel = 10; /* default channel, more-or-less arbitrary */
+	priv->channel = 0; /* use firmware default */
 
 	priv->promiscuous = 0;
 	priv->wep_on = 0;
 	priv->tx_key = 0;
 
-	err = hermes_allocate(hw, priv->nicbuf_size, &priv->txfid);
-	if (err == -EIO) {
-		/* Try workaround for old Symbol firmware bug */
-		printk(KERN_WARNING "%s: firmware ALLOC bug detected "
-		       "(old Symbol firmware?). Trying to work around... ",
-		       dev->name);
-		
-		priv->nicbuf_size = TX_NICBUF_SIZE_BUG;
-		err = hermes_allocate(hw, priv->nicbuf_size, &priv->txfid);
-		if (err)
-			printk("failed!\n");
-		else
-			printk("ok.\n");
-	}
-	if (err) {
-		printk("%s: Error %d allocating Tx buffer\n", dev->name, err);
-		goto out;
-	}
-
 	/* Make the hardware available, as long as it hasn't been
 	 * removed elsewhere (e.g. by PCMCIA hot unplug) */
 	orinoco_spin_lock(priv);
--- a/drivers/net/wireless/orinoco.h.11-firmware-fixes	2004-10-26 15:15:11.454350912 -0400
+++ b/drivers/net/wireless/orinoco.h	2004-10-26 15:15:11.456350608 -0400
@@ -36,6 +36,12 @@
 	char data[ORINOCO_MAX_KEY_SIZE];
 } __attribute__ ((packed));
 
+typedef enum {
+	FIRMWARE_TYPE_AGERE,
+	FIRMWARE_TYPE_INTERSIL,
+	FIRMWARE_TYPE_SYMBOL
+} fwtype_t;
+
 struct orinoco_private {
 	void *card;	/* Pointer to card dependent structure */
 	int (*hard_reset)(struct orinoco_private *);
@@ -60,12 +66,9 @@
 	u16 txfid;
 
 	/* Capabilities of the hardware/firmware */
-	int firmware_type;
-#define FIRMWARE_TYPE_AGERE 1
-#define FIRMWARE_TYPE_INTERSIL 2
-#define FIRMWARE_TYPE_SYMBOL 3
+	fwtype_t firmware_type;
+	char fw_name[32];
 	int ibss_port;
-	int has_ibss_any;
 	int nicbuf_size;
 	u16 channel_mask;
 
