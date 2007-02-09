From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Fri, 09 Feb 2007 10:32:54 -0600
Message-ID: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The specifications for the bcm43xx driver have been modified. This patch
incorporates these changes in the code, which results in the BCM4311 and
BCM4312 working. The name of one of the PHY parameters, previously known
as "version", has been changed to "analog core version" .

Signed-off-by: Larry Finger<Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

I hope this fix makes it into 2.6.21. As you have seen from the list, it is a biggie!

Larry
---

Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -542,7 +542,7 @@ struct bcm43xx_lopair {
 
 struct bcm43xx_phyinfo {
 	/* Hardware Data */
-	u8 version;
+	u8 analog;
 	u8 type;
 	u8 rev;
 	u16 antenna_diversity;
Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -205,8 +205,8 @@ static void bcm43xx_phy_init_pctl(struct
 	    (bcm->board_type == 0x0416))
 		return;
 
-	bcm43xx_write16(bcm, 0x03E6, bcm43xx_read16(bcm, 0x03E6) & 0xFFDF);
 	bcm43xx_phy_write(bcm, 0x0028, 0x8018);
+	bcm43xx_write16(bcm, 0x03E6, bcm43xx_read16(bcm, 0x03E6) & 0xFFDF);
 
 	if (phy->type == BCM43xx_PHYTYPE_G) {
 		if (!phy->connected)
@@ -729,19 +729,19 @@ static void bcm43xx_phy_initb5(struct bc
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
 	u16 offset;
+	u16 value;
+	u8 old_channel;
 
-	if (phy->version == 1 &&
-	    radio->version == 0x2050) {
+	if (phy->analog == 1)
 		bcm43xx_radio_write16(bcm, 0x007A,
 				      bcm43xx_radio_read16(bcm, 0x007A)
 				      | 0x0050);
-	}
 	if ((bcm->board_vendor != PCI_VENDOR_ID_BROADCOM) &&
 	    (bcm->board_type != 0x0416)) {
+		value = 0x2120;
 		for (offset = 0x00A8 ; offset < 0x00C7; offset++) {
-			bcm43xx_phy_write(bcm, offset,
-					  (bcm43xx_phy_read(bcm, offset) + 0x2020)
-					  & 0x3F3F);
+			bcm43xx_phy_write(bcm, offset, value);
+			value += 0x0202;
 		}
 	}
 	bcm43xx_phy_write(bcm, 0x0035,
@@ -776,7 +776,7 @@ static void bcm43xx_phy_initb5(struct bc
 				  bcm43xx_phy_read(bcm, BCM43xx_PHY_RADIO_BITFIELD) | (1 << 11));
 	}
 
-	if (phy->version == 1 && radio->version == 0x2050) {
+	if (phy->analog == 1) {
 		bcm43xx_phy_write(bcm, 0x0026, 0xCE00);
 		bcm43xx_phy_write(bcm, 0x0021, 0x3763);
 		bcm43xx_phy_write(bcm, 0x0022, 0x1BC3);
@@ -787,14 +787,15 @@ static void bcm43xx_phy_initb5(struct bc
 	bcm43xx_phy_write(bcm, 0x0030, 0x00C6);
 	bcm43xx_write16(bcm, 0x03EC, 0x3F22);
 
-	if (phy->version == 1 && radio->version == 0x2050)
+	if (phy->analog == 1)
 		bcm43xx_phy_write(bcm, 0x0020, 0x3E1C);
 	else
 		bcm43xx_phy_write(bcm, 0x0020, 0x301C);
 
-	if (phy->version == 0)
+	if (phy->analog == 0)
 		bcm43xx_write16(bcm, 0x03E4, 0x3000);
 
+	old_channel = radio->channel;
 	/* Force to channel 7, even if not supported. */
 	bcm43xx_radio_selectchannel(bcm, 7, 0);
 
@@ -816,11 +817,11 @@ static void bcm43xx_phy_initb5(struct bc
 
 	bcm43xx_radio_write16(bcm, 0x007A, bcm43xx_radio_read16(bcm, 0x007A) | 0x0007);
 
-	bcm43xx_radio_selectchannel(bcm, BCM43xx_RADIO_DEFAULT_CHANNEL_BG, 0);
+	bcm43xx_radio_selectchannel(bcm, old_channel, 0);
 
 	bcm43xx_phy_write(bcm, 0x0014, 0x0080);
 	bcm43xx_phy_write(bcm, 0x0032, 0x00CA);
-	bcm43xx_phy_write(bcm, 0x88A3, 0x002A);
+	bcm43xx_phy_write(bcm, 0x002A, 0x88A3);
 
 	bcm43xx_radio_set_txpower_bg(bcm, 0xFFFF, 0xFFFF, 0xFFFF);
 
@@ -933,6 +934,8 @@ static void bcm43xx_phy_initb6(struct bc
 		                  bcm43xx_phy_read(bcm, 0x0802) | 0x0100);
 		bcm43xx_phy_write(bcm, 0x042B,
 		                  bcm43xx_phy_read(bcm, 0x042B) | 0x2000);
+		bcm43xx_phy_write(bcm, 0x5B, 0x0000);
+		bcm43xx_phy_write(bcm, 0x5C, 0x0000);
 	}
 
 	/* Force to channel 7, even if not supported. */
@@ -976,10 +979,12 @@ static void bcm43xx_phy_initb6(struct bc
 			bcm43xx_radio_write16(bcm, 0x005D, 0x000D);
 	}
 	
-	if (phy->rev == 4)
-		bcm43xx_phy_write(bcm, 0x0002, (bcm43xx_phy_read(bcm, 0x0002) & 0xFFC0) | 0x0004);
-	else
+	if (phy->analog == 4){
 		bcm43xx_write16(bcm, 0x03E4, 0x0009);
+		bcm43xx_phy_write(bcm, 0x61, bcm43xx_phy_read(bcm, 0x61) & 0xFFF);
+	} else {
+		bcm43xx_phy_write(bcm, 0x0002, (bcm43xx_phy_read(bcm, 0x0002) & 0xFFC0) | 0x0004);
+	}
 	if (phy->type == BCM43xx_PHYTYPE_B) {
 		bcm43xx_write16(bcm, 0x03E6, 0x8140);
 		bcm43xx_phy_write(bcm, 0x0016, 0x0410);
@@ -1063,7 +1068,7 @@ static void bcm43xx_calc_loopback_gain(s
 	bcm43xx_phy_write(bcm, 0x005A, 0x0780);
 	bcm43xx_phy_write(bcm, 0x0059, 0xC810);
 	bcm43xx_phy_write(bcm, 0x0058, 0x000D);
-	if (phy->version == 0) {
+	if (phy->analog == 0) {
 		bcm43xx_phy_write(bcm, 0x0003, 0x0122);
 	} else {
 		bcm43xx_phy_write(bcm, 0x000A,
@@ -1225,7 +1230,7 @@ static void bcm43xx_phy_initg(struct bcm
 	}
 	if (phy->rev < 3 && phy->connected)
 		bcm43xx_phy_write(bcm, 0x047E, 0x0078);
-	if (phy->rev >= 6 && phy->rev <= 8) {
+	if (radio->revision == 8) {
 		bcm43xx_phy_write(bcm, 0x0801, bcm43xx_phy_read(bcm, 0x0801) | 0x0080);
 		bcm43xx_phy_write(bcm, 0x043E, bcm43xx_phy_read(bcm, 0x043E) | 0x0004);
 	}
@@ -1638,14 +1643,14 @@ void bcm43xx_phy_set_baseband_attenuatio
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	u16 value;
 
-	if (phy->version == 0) {
+	if (phy->analog == 0) {
 		value = (bcm43xx_read16(bcm, 0x03E6) & 0xFFF0);
 		value |= (baseband_attenuation & 0x000F);
 		bcm43xx_write16(bcm, 0x03E6, value);
 		return;
 	}
 
-	if (phy->version > 1) {
+	if (phy->analog > 1) {
 		value = bcm43xx_phy_read(bcm, 0x0060) & ~0x003C;
 		value |= (baseband_attenuation << 2) & 0x003C;
 	} else {
Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
@@ -1393,11 +1393,12 @@ u16 bcm43xx_radio_init2050(struct bcm43x
 	backup[12] = bcm43xx_read16(bcm, BCM43xx_MMIO_CHANNEL_EXT);
 
 	// Initialization
-	if (phy->version == 0) {
+	if (phy->analog == 0) {
 		bcm43xx_write16(bcm, 0x03E6, 0x0122);
 	} else {
-		if (phy->version >= 2)
-			bcm43xx_write16(bcm, 0x03E6, 0x0040);
+		if (phy->analog >= 2)
+			bcm43xx_write16(bcm, 0x0003, (bcm43xx_read16(bcm, 0x0003)
+					& 0xFFBF) | 0x0040);
 		bcm43xx_write16(bcm, BCM43xx_MMIO_CHANNEL_EXT,
 		                (bcm43xx_read16(bcm, BCM43xx_MMIO_CHANNEL_EXT) | 0x2000));
 	}
@@ -1488,7 +1489,7 @@ u16 bcm43xx_radio_init2050(struct bcm43x
 	bcm43xx_phy_write(bcm, 0x0059, backup[17]);
 	bcm43xx_phy_write(bcm, 0x0058, backup[18]);
 	bcm43xx_write16(bcm, 0x03E6, backup[11]);
-	if (phy->version != 0)
+	if (phy->analog != 0)
 		bcm43xx_write16(bcm, BCM43xx_MMIO_CHANNEL_EXT, backup[12]);
 	bcm43xx_phy_write(bcm, 0x0035, backup[10]);
 	bcm43xx_radio_selectchannel(bcm, radio->channel, 1);
Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3699,7 +3699,7 @@ static int bcm43xx_read_phyinfo(struct b
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	u16 value;
-	u8 phy_version;
+	u8 phy_analog;
 	u8 phy_type;
 	u8 phy_rev;
 	int phy_rev_ok = 1;
@@ -3707,12 +3707,12 @@ static int bcm43xx_read_phyinfo(struct b
 
 	value = bcm43xx_read16(bcm, BCM43xx_MMIO_PHY_VER);
 
-	phy_version = (value & 0xF000) >> 12;
+	phy_analog = (value & 0xF000) >> 12;
 	phy_type = (value & 0x0F00) >> 8;
 	phy_rev = (value & 0x000F);
 
 	dprintk(KERN_INFO PFX "Detected PHY: Version: %x, Type %x, Revision %x\n",
-		phy_version, phy_type, phy_rev);
+		phy_analog, phy_type, phy_rev);
 
 	switch (phy_type) {
 	case BCM43xx_PHYTYPE_A:
@@ -3755,7 +3755,7 @@ static int bcm43xx_read_phyinfo(struct b
 		       phy_rev);
 	}
 
-	phy->version = phy_version;
+	phy->analog = phy_analog;
 	phy->type = phy_type;
 	phy->rev = phy_rev;
 	if ((phy_type == BCM43xx_PHYTYPE_B) || (phy_type == BCM43xx_PHYTYPE_G)) {
