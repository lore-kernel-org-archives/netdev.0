From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 6/24] RT2x00: Add TXPOWER_FROM_DEV and TXPOWER_TO_DEV macros
Date: Wed, 26 Jul 2006 20:24:38 +0200
Message-ID: <200607262024.38766.IvDoorn@gmail.com>
References: <200607261904.52874.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:15622 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751747AbWGZSYw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:24:52 -0400
Received: by nf-out-0910.google.com with SMTP id o25so839123nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:24:51 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200607261904.52874.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Add TXPOWER_FROM_DEV and TXPOWER_TO_DEV macro's
to convert the txpower values read from the eeprom
to the value dscape expects, and vice versa.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -rU3 wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 17:01:06.000000000 +0200
+++ wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 17:24:56.000000000 +0200
@@ -582,8 +582,7 @@
 
 static void rt2400pci_config_txpower(struct rt2x00_dev *rt2x00dev, u8 txpower)
 {
-	txpower = (txpower < 39) ? 39 : txpower;
-	txpower = (txpower > 62) ? 62 : txpower;
+	txpower = TXPOWER_TO_DEV(txpower);
 	rt2x00_bbp_write(rt2x00dev, 3, txpower);
 }
 
@@ -2343,15 +2342,11 @@
 		rt2x00_eeprom_read(rt2x00dev,
 			EEPROM_TXPOWER_START + i, &eeprom);
 
-		channels[(i * 2)].power_level =
-			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_1);
-		if (channels[(i * 2)].power_level > 0x7f)
-			channels[(i * 2)].power_level = 0x27;
-
-		channels[(i * 2) + 1].power_level =
-			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_2);
-		if (channels[(i * 2) + 1].power_level > 0x7f)
-			channels[(i * 2) + 1].power_level = 0x27;
+		channels[(i * 2)].power_level = TXPOWER_FROM_DEV(
+			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_1));
+
+		channels[(i * 2) + 1].power_level = TXPOWER_FROM_DEV(
+			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_2));
 	}
 
 	/*
diff -rU3 wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2400pci.h wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
--- wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-07-23 16:34:46.000000000 +0200
+++ wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-07-23 17:15:44.000000000 +0200
@@ -845,6 +845,34 @@
 };
 
 /*
+ * Macro's for converting txpower from EEPROM to dscape value
+ * and from dscape value to register value.
+ * NOTE: Logics in rt2400pci for txpower are reversed
+ * compared to the other rt2x00 drivers. A higher txpower
+ * value means that the txpower must be lowered. This is
+ * important when converting the value coming from the
+ * dscape stack to the rt2400 acceptable value.
+ */
+#define MIN_TXPOWER	31
+#define MAX_TXPOWER	62
+#define DEFAULT_TXPOWER	39
+
+#define TXPOWER_FROM_DEV(__txpower) \
+	({ \
+		((__txpower) > MAX_TXPOWER) ? DEFAULT_TXPOWER - MIN_TXPOWER : \
+		((__txpower) < MIN_TXPOWER) ? DEFAULT_TXPOWER - MIN_TXPOWER : \
+		(((__txpower) - MAX_TXPOWER) + MIN_TXPOWER); \
+	})
+
+#define TXPOWER_TO_DEV(__txpower) \
+	({ \
+		(__txpower) += MIN_TXPOWER; \
+		((__txpower) < MIN_TXPOWER) ? MAX_TXPOWER : \
+		(((__txpower) > MAX_TXPOWER) ? MIN_TXPOWER : \
+		(MAX_TXPOWER - ((__txpower) - MIN_TXPOWER))); \
+	})
+
+/*
  * IEEE stack callback functions declarations.
  */
 static int rt2400pci_tx(struct net_device *net_dev,
diff -rU3 wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 17:01:39.000000000 +0200
+++ wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 17:31:27.000000000 +0200
@@ -533,8 +533,9 @@
 	u32 rf3 = rt2x00dev->rf3;
 	u32 rf4 = rt2x00dev->rf4;
 
-	txpower = (txpower < 19) ? 19 : txpower;
-	txpower = (txpower > 31) ? 31 : txpower;
+	if (txpower == 0xff)
+		txpower = rt2x00dev->tx_power;
+	txpower = TXPOWER_TO_DEV(txpower);
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF2525E) && channel == 14)
 		rf4 |= cpu_to_le32(0x00000010);
@@ -615,6 +616,14 @@
 	rt2x00_register_read(rt2x00dev, CNT0, &rf1);
 }
 
+static void rt2500pci_config_txpower(struct rt2x00_dev *rt2x00dev, int txpower)
+{
+	txpower = TXPOWER_TO_DEV(txpower);
+
+	rt2x00_set_field32(&rt2x00dev->rf3, RF3_TXPOWER, txpower);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3);
+}
+
 static void rt2500pci_config_antenna(struct rt2x00_dev *rt2x00dev, int antenna)
 {
 	u32 reg;
@@ -2003,6 +2012,7 @@
 	rt2500pci_config_channel(rt2x00dev,
 		conf->channel_val, conf->channel, conf->freq,
 		conf->power_level);
+	rt2500pci_config_txpower(rt2x00dev, conf->power_level);
 	rt2500pci_config_antenna(rt2x00dev, conf->antenna_sel);
 	rt2500pci_config_duration(rt2x00dev, conf->short_slot_time);
 	rt2500pci_config_phymode(rt2x00dev, conf->phymode);
@@ -2471,7 +2481,7 @@
 			channels[i].flag = IEEE80211_CHAN_W_IBSS
 				| IEEE80211_CHAN_W_ACTIVE_SCAN
 				| IEEE80211_CHAN_W_SCAN;
-			channels[i].power_level = 0x18;
+			channels[i].power_level = DEFAULT_TXPOWER;
 			channels[i].antenna_max = 0xff;
 		}
 	}
@@ -2542,15 +2552,11 @@
 		rt2x00_eeprom_read(rt2x00dev,
 			EEPROM_TXPOWER_START + i, &eeprom);
 
-		channels[(i * 2)].power_level =
-			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_1);
-		if (channels[(i * 2)].power_level > 0x20)
-			channels[(i * 2)].power_level = 0x18;
-
-		channels[(i * 2) + 1].power_level =
-			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_2);
-		if (channels[(i * 2) + 1].power_level > 0x20)
-			channels[(i * 2) + 1].power_level = 0x18;
+		channels[(i * 2)].power_level = TXPOWER_FROM_DEV(
+			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_1));
+
+		channels[(i * 2) + 1].power_level = TXPOWER_FROM_DEV(
+			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_2));
 	}
 
 	/*
diff -rU3 wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500pci.h wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
--- wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-07-23 16:35:07.000000000 +0200
+++ wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-07-23 17:16:15.000000000 +0200
@@ -1114,6 +1114,26 @@
 };
 
 /*
+ * Macro's for converting txpower from EEPROM to dscape value
+ * and from dscape value to register value.
+ */
+#define MIN_TXPOWER	0
+#define MAX_TXPOWER	31
+#define DEFAULT_TXPOWER	24
+
+#define TXPOWER_FROM_DEV(__txpower) \
+	({ \
+		((__txpower) > MAX_TXPOWER) ? DEFAULT_TXPOWER : (__txpower); \
+	})
+
+#define TXPOWER_TO_DEV(__txpower) \
+	({ \
+		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		(__txpower)); \
+	})
+
+/*
  * IEEE stack callback functions declarations.
  */
 static int rt2500pci_tx(struct net_device *net_dev,
diff -rU3 wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 17:02:01.000000000 +0200
+++ wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 17:31:13.000000000 +0200
@@ -380,8 +380,9 @@
 	u32 rf3 = rt2x00dev->rf3;
 	u32 rf4 = rt2x00dev->rf4;
 
-	txpower = (txpower < 19) ? 19 : txpower;
-	txpower = (txpower > 31) ? 31 : txpower;
+	if (txpower == 0xff)
+		txpower = rt2x00dev->tx_power;
+	txpower = TXPOWER_TO_DEV(txpower);
 
 	if ((rt2x00_rf(&rt2x00dev->chip, RF2523) ||
 	     rt2x00_rf(&rt2x00dev->chip, RF2524) ||
@@ -444,6 +445,14 @@
 	rt2x00dev->rx_params.channel = channel;
 }
 
+static void rt2500usb_config_txpower(struct rt2x00_dev *rt2x00dev, int txpower)
+{
+	txpower = TXPOWER_TO_DEV(txpower);
+
+	rt2x00_set_field32_nb(&rt2x00dev->rf3, RF3_TXPOWER, txpower);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3);
+}
+
 static void rt2500usb_config_antenna(struct rt2x00_dev *rt2x00dev, int antenna)
 {
 	u8 reg_rx;
@@ -1665,6 +1674,7 @@
 	rt2500usb_config_channel(rt2x00dev,
 		conf->channel_val, conf->channel, conf->freq,
 		conf->power_level);
+	rt2500usb_config_txpower(rt2x00dev, conf->power_level);
 	rt2500usb_config_antenna(rt2x00dev, conf->antenna_sel);
 	rt2500usb_config_duration(rt2x00dev, conf->short_slot_time);
 	rt2500usb_config_phymode(rt2x00dev, conf->phymode);
@@ -2104,7 +2114,7 @@
 			channels[i].flag = IEEE80211_CHAN_W_IBSS
 				| IEEE80211_CHAN_W_ACTIVE_SCAN
 				| IEEE80211_CHAN_W_SCAN;
-			channels[i].power_level = 0x18;
+			channels[i].power_level = DEFAULT_TXPOWER;
 			channels[i].antenna_max = 0xff;
 		}
 	}
@@ -2174,15 +2184,11 @@
 		rt2x00_eeprom_read(rt2x00dev,
 			EEPROM_TXPOWER_START + i, &eeprom);
 
-		channels[(i * 2)].power_level =
-			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_1);
-		if (channels[(i * 2)].power_level > 0x20)
-			channels[(i * 2)].power_level = 0x18;
-
-		channels[(i * 2) + 1].power_level =
-			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_2);
-		if (channels[(i * 2) + 1].power_level > 0x20)
-			channels[(i * 2) + 1].power_level = 0x18;
+		channels[(i * 2)].power_level = TXPOWER_FROM_DEV(
+			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_1));
+
+		channels[(i * 2) + 1].power_level = TXPOWER_FROM_DEV(
+			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_2));
 	}
 
 	/*
diff -rU3 wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500usb.h wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-07-23 16:35:21.000000000 +0200
+++ wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-07-23 17:16:31.000000000 +0200
@@ -634,6 +634,26 @@
 };
 
 /*
+ * Macro's for converting txpower from EEPROM to dscape value
+ * and from dscape value to register value.
+ */
+#define MIN_TXPOWER	0
+#define MAX_TXPOWER	31
+#define DEFAULT_TXPOWER	24
+
+#define TXPOWER_FROM_DEV(__txpower) \
+	({ \
+		((__txpower) > MAX_TXPOWER) ? DEFAULT_TXPOWER : (__txpower);  \
+	})
+
+#define TXPOWER_TO_DEV(__txpower) \
+	({ \
+		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		(__txpower)); \
+	})
+
+/*
  * IEEE stack callback functions declarations.
  */
 static int rt2500usb_tx(struct net_device *net_dev,
diff -rU3 wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 17:02:10.000000000 +0200
+++ wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 17:31:05.000000000 +0200
@@ -565,8 +565,9 @@
 	u32 rf3 = 0;
 	u32 rf4 = 0;
 
-	txpower = (txpower < 0) ? 0 : txpower;
-	txpower = (txpower > 31) ? 31 : txpower;
+	if (txpower == 0xff)
+		txpower = rt2x00dev->tx_power;
+	txpower = TXPOWER_TO_DEV(txpower);
 
 	if (!GET_FLAG(rt2x00dev, CONFIG_RF_SEQUENCE) || channel <= 14)
 		rf1 = cpu_to_le32(0x00002ccc);
@@ -783,6 +784,32 @@
 	rt2x00dev->rx_params.channel = channel;
 }
 
+static void rt61pci_config_txpower(struct rt2x00_dev *rt2x00dev, int txpower)
+{
+	txpower = TXPOWER_TO_DEV(txpower);
+
+	rt2x00_set_field32(&rt2x00dev->rf3, RF3_TXPOWER, txpower);
+
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf1);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf2);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3 & ~cpu_to_le32(0x00000004));
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf4);
+
+	udelay(200);
+
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf1);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf2);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3 | cpu_to_le32(0x00000004));
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf4);
+
+	udelay(200);
+
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf1);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf2);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3 & ~cpu_to_le32(0x00000004));
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf4);
+}
+
 static void rt61pci_config_antenna(struct rt2x00_dev *rt2x00dev,
 	int antenna, int phymode)
 {
@@ -1237,7 +1264,8 @@
 	rt2x00_set_field32(&txd->word1, TXD_W1_CWMIN, ring->tx_params.cw_min);
 	rt2x00_set_field32(&txd->word1, TXD_W1_CWMAX, ring->tx_params.cw_max);
 
-	rt2x00_set_field32(&txd->word5, TXD_W5_TX_POWER, control->power_level);
+	rt2x00_set_field32(&txd->word5, TXD_W5_TX_POWER,
+		TXPOWER_TO_DEV(control->power_level));
 
 	/*
 	 * Add 4 bytes for FCS.
@@ -2460,6 +2488,7 @@
 	rt61pci_config_channel(rt2x00dev,
 		conf->channel_val, conf->channel, conf->freq,
 		conf->power_level);
+	rt61pci_config_txpower(rt2x00dev, conf->power_level);
 	rt61pci_config_antenna(rt2x00dev, conf->antenna_sel, conf->phymode);
 	rt61pci_config_duration(rt2x00dev, conf->short_slot_time);
 	rt61pci_config_phymode(rt2x00dev, conf->phymode);
@@ -3081,15 +3110,11 @@
 		rt2x00_eeprom_read(rt2x00dev,
 			EEPROM_TXPOWER_G_START + i, &eeprom);
 
-		channels[(i * 2)].power_level =
-			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_G_1);
-		if (channels[(i * 2)].power_level > 0x20)
-			channels[(i * 2)].power_level = 0x18;
-
-		channels[(i * 2) + 1].power_level =
-			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_G_2);
-		if (channels[(i * 2) + 1].power_level > 0x20)
-			channels[(i * 2) + 1].power_level = 0x18;
+		channels[(i * 2)].power_level = TXPOWER_FROM_DEV(
+			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_G_1));
+
+		channels[(i * 2) + 1].power_level = TXPOWER_FROM_DEV(
+			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_G_2));
 	}
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
@@ -3098,15 +3123,13 @@
 			rt2x00_eeprom_read(rt2x00dev,
 				EEPROM_TXPOWER_A_START + i, &eeprom);
 
-			channels[(i * 2)].power_level =
-				rt2x00_get_field16(eeprom, EEPROM_TXPOWER_A_1);
-			if (channels[(i * 2)].power_level > 0x20)
-				channels[(i * 2)].power_level = 0x18;
-
-			channels[(i * 2) + 1].power_level =
-				rt2x00_get_field16(eeprom, EEPROM_TXPOWER_A_2);
-			if (channels[(i * 2) + 1].power_level > 0x20)
-				channels[(i * 2) + 1].power_level = 0x18;
+			channels[(i * 2)].power_level = TXPOWER_FROM_DEV(
+				rt2x00_get_field16(eeprom,
+					EEPROM_TXPOWER_A_1));
+
+			channels[(i * 2) + 1].power_level = TXPOWER_FROM_DEV(
+				rt2x00_get_field16(eeprom,
+					EEPROM_TXPOWER_A_2));
 		}
 	}
 }
diff -rU3 wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-23 16:35:36.000000000 +0200
+++ wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-23 17:16:49.000000000 +0200
@@ -1330,6 +1330,26 @@
 };
 
 /*
+ * Macro's for converting txpower from EEPROM to dscape value
+ * and from dscape value to register value.
+ */
+#define MIN_TXPOWER	0
+#define MAX_TXPOWER	31
+#define DEFAULT_TXPOWER	24
+
+#define TXPOWER_FROM_DEV(__txpower) \
+	({ \
+		((__txpower) > MAX_TXPOWER) ? DEFAULT_TXPOWER : (__txpower); \
+	})
+
+#define TXPOWER_TO_DEV(__txpower) \
+	({ \
+		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		(__txpower)); \
+	})
+
+/*
  * IEEE stack callback functions declarations.
  */
 static int rt61pci_tx(struct net_device *net_dev,
diff -rU3 wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 17:02:18.000000000 +0200
+++ wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 17:30:57.000000000 +0200
@@ -386,8 +386,9 @@
 	u32 rf3 = rt2x00dev->rf3;
 	u32 rf4 = 0;
 
-	txpower = (txpower < 0) ? 0 : txpower;
-	txpower = (txpower > 31) ? 31 : txpower;
+	if (txpower == 0xff)
+		txpower = rt2x00dev->tx_power;
+	txpower = TXPOWER_TO_DEV(txpower);
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225)) {
 		if (channel <= 14)
@@ -507,6 +508,28 @@
 	rt2x00dev->rx_params.channel = channel;
 }
 
+static void rt73usb_config_txpower(struct rt2x00_dev *rt2x00dev, int txpower)
+{
+	txpower = TXPOWER_TO_DEV(txpower);
+
+	rt2x00_set_field32(&rt2x00dev->rf3, RF3_TXPOWER, txpower);
+
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf1);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf2);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3 & ~cpu_to_le32(0x00000004));
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf4);
+
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf1);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf2);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3 | cpu_to_le32(0x00000004));
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf4);
+
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf1);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf2);
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3 & ~cpu_to_le32(0x00000004));
+	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf4);
+}
+
 static void rt73usb_config_antenna(struct rt2x00_dev *rt2x00dev,
 	int antenna, int phymode)
 {
@@ -971,7 +994,8 @@
 	rt2x00_set_field32(&txd->word1, TXD_W1_CWMIN, ring->tx_params.cw_min);
 	rt2x00_set_field32(&txd->word1, TXD_W1_CWMAX, ring->tx_params.cw_max);
 
-	rt2x00_set_field32(&txd->word5, TXD_W5_TX_POWER, control->power_level);
+	rt2x00_set_field32(&txd->word5, TXD_W5_TX_POWER,
+		TXPOWER_TO_DEV(control->power_level));
 
 	/*
 	 * Add 4 bytes for FCS.
@@ -1966,6 +1990,7 @@
 	rt73usb_config_channel(rt2x00dev,
 		conf->channel_val, conf->channel, conf->freq,
 		conf->power_level);
+	rt73usb_config_txpower(rt2x00dev, conf->power_level);
 	rt73usb_config_antenna(rt2x00dev, conf->antenna_sel, conf->phymode);
 	rt73usb_config_duration(rt2x00dev, conf->short_slot_time);
 	rt73usb_config_phymode(rt2x00dev, conf->phymode);
@@ -2566,15 +2591,11 @@
 		rt2x00_eeprom_read(rt2x00dev,
 			EEPROM_TXPOWER_G_START + i, &eeprom);
 
-		channels[(i * 2)].power_level =
-			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_G_1);
-		if (channels[(i * 2)].power_level > 0x20)
-			channels[(i * 2)].power_level = 0x18;
-
-		channels[(i * 2) + 1].power_level =
-			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_G_2);
-		if (channels[(i * 2) + 1].power_level > 0x20)
-			channels[(i * 2) + 1].power_level = 0x18;
+		channels[(i * 2)].power_level = TXPOWER_FROM_DEV(
+			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_G_1));
+
+		channels[(i * 2) + 1].power_level = TXPOWER_FROM_DEV(
+			rt2x00_get_field16(eeprom, EEPROM_TXPOWER_G_2));
 	}
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
@@ -2583,15 +2604,13 @@
 			rt2x00_eeprom_read(rt2x00dev,
 				EEPROM_TXPOWER_A_START + i, &eeprom);
 
-			channels[(i * 2)].power_level =
-				rt2x00_get_field16(eeprom, EEPROM_TXPOWER_A_1);
-			if (channels[(i * 2)].power_level > 0x20)
-				channels[(i * 2)].power_level = 0x18;
-
-			channels[(i * 2) + 1].power_level =
-				rt2x00_get_field16(eeprom, EEPROM_TXPOWER_A_2);
-			if (channels[(i * 2) + 1].power_level > 0x20)
-				channels[(i * 2) + 1].power_level = 0x18;
+			channels[(i * 2)].power_level = TXPOWER_FROM_DEV(
+				rt2x00_get_field16(eeprom,
+					EEPROM_TXPOWER_A_1));
+
+			channels[(i * 2) + 1].power_level = TXPOWER_FROM_DEV(
+				rt2x00_get_field16(eeprom,
+					EEPROM_TXPOWER_A_2));
 		}
 	}
 
diff -rU3 wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-rates/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-07-23 16:35:48.000000000 +0200
+++ wireless-dev-txpower/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-07-23 17:17:09.000000000 +0200
@@ -893,6 +893,26 @@
 };
 
 /*
+ * Macro's for converting txpower from EEPROM to dscape value
+ * and from dscape value to register value.
+ */
+#define MIN_TXPOWER	0
+#define MAX_TXPOWER	31
+#define DEFAULT_TXPOWER	24
+
+#define TXPOWER_FROM_DEV(__txpower) \
+	({ \
+		((__txpower) > MAX_TXPOWER) ? DEFAULT_TXPOWER : (__txpower); \
+	})
+
+#define TXPOWER_TO_DEV(__txpower) \
+	({ \
+		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		(__txpower)); \
+	})
+
+/*
  * IEEE stack callback functions declarations.
  */
 static int rt73usb_tx(struct net_device *net_dev,
