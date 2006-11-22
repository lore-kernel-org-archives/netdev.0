From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Rename cs_rate to zd_rate
Date: Wed, 22 Nov 2006 00:06:38 +0000 (GMT)
Message-ID: <20061122000638.EAFAD7B40A1@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:39129 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1756891AbWKVAGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 19:06:37 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These controlset rate constants are also applicable in places outside
the controlset, such as in the RTS/CTS control register.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_ieee80211.h |    1 +
 zd_mac.c       |   56 ++++++++++++++++++++++++++++----------------------------
 zd_mac.h       |    9 +++++----
 3 files changed, 34 insertions(+), 32 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_ieee80211.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_ieee80211.h
+++ linux/drivers/net/wireless/zd1211rw/zd_ieee80211.h
@@ -50,6 +50,7 @@ static inline u8 zd_ofdm_plcp_header_rat
 	return header->prefix[0] & 0xf;
 }
 
+/* These are referred to as zd_rates */
 #define ZD_OFDM_RATE_6M		0xb
 #define ZD_OFDM_RATE_9M		0xf
 #define ZD_OFDM_RATE_12M	0xa
Index: linux/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -325,13 +325,13 @@ u8 zd_mac_get_channel(struct zd_mac *mac
 }
 
 /* If wrong rate is given, we are falling back to the slowest rate: 1MBit/s */
-static u8 cs_typed_rate(u8 cs_rate)
+static u8 zd_rate_typed(u8 zd_rate)
 {
 	static const u8 typed_rates[16] = {
-		[ZD_CS_CCK_RATE_1M]	= ZD_CS_CCK|ZD_CS_CCK_RATE_1M,
-		[ZD_CS_CCK_RATE_2M]	= ZD_CS_CCK|ZD_CS_CCK_RATE_2M,
-		[ZD_CS_CCK_RATE_5_5M]	= ZD_CS_CCK|ZD_CS_CCK_RATE_5_5M,
-		[ZD_CS_CCK_RATE_11M]	= ZD_CS_CCK|ZD_CS_CCK_RATE_11M,
+		[ZD_CCK_RATE_1M]	= ZD_CS_CCK|ZD_CCK_RATE_1M,
+		[ZD_CCK_RATE_2M]	= ZD_CS_CCK|ZD_CCK_RATE_2M,
+		[ZD_CCK_RATE_5_5M]	= ZD_CS_CCK|ZD_CCK_RATE_5_5M,
+		[ZD_CCK_RATE_11M]	= ZD_CS_CCK|ZD_CCK_RATE_11M,
 		[ZD_OFDM_RATE_6M]	= ZD_CS_OFDM|ZD_OFDM_RATE_6M,
 		[ZD_OFDM_RATE_9M]	= ZD_CS_OFDM|ZD_OFDM_RATE_9M,
 		[ZD_OFDM_RATE_12M]	= ZD_CS_OFDM|ZD_OFDM_RATE_12M,
@@ -343,19 +343,19 @@ static u8 cs_typed_rate(u8 cs_rate)
 	};
 
 	ZD_ASSERT(ZD_CS_RATE_MASK == 0x0f);
-	return typed_rates[cs_rate & ZD_CS_RATE_MASK];
+	return typed_rates[zd_rate & ZD_CS_RATE_MASK];
 }
 
 /* Fallback to lowest rate, if rate is unknown. */
-static u8 rate_to_cs_rate(u8 rate)
+static u8 rate_to_zd_rate(u8 rate)
 {
 	switch (rate) {
 	case IEEE80211_CCK_RATE_2MB:
-		return ZD_CS_CCK_RATE_2M;
+		return ZD_CCK_RATE_2M;
 	case IEEE80211_CCK_RATE_5MB:
-		return ZD_CS_CCK_RATE_5_5M;
+		return ZD_CCK_RATE_5_5M;
 	case IEEE80211_CCK_RATE_11MB:
-		return ZD_CS_CCK_RATE_11M;
+		return ZD_CCK_RATE_11M;
 	case IEEE80211_OFDM_RATE_6MB:
 		return ZD_OFDM_RATE_6M;
 	case IEEE80211_OFDM_RATE_9MB:
@@ -373,7 +373,7 @@ static u8 rate_to_cs_rate(u8 rate)
 	case IEEE80211_OFDM_RATE_54MB:
 		return ZD_OFDM_RATE_54M;
 	}
-	return ZD_CS_CCK_RATE_1M;
+	return ZD_CCK_RATE_1M;
 }
 
 int zd_mac_set_mode(struct zd_mac *mac, u32 mode)
@@ -474,13 +474,13 @@ int zd_mac_get_range(struct zd_mac *mac,
 	return 0;
 }
 
-static int zd_calc_tx_length_us(u8 *service, u8 cs_rate, u16 tx_length)
+static int zd_calc_tx_length_us(u8 *service, u8 zd_rate, u16 tx_length)
 {
 	static const u8 rate_divisor[] = {
-		[ZD_CS_CCK_RATE_1M]	=  1,
-		[ZD_CS_CCK_RATE_2M]	=  2,
-		[ZD_CS_CCK_RATE_5_5M]	= 11, /* bits must be doubled */
-		[ZD_CS_CCK_RATE_11M]	= 11,
+		[ZD_CCK_RATE_1M]	=  1,
+		[ZD_CCK_RATE_2M]	=  2,
+		[ZD_CCK_RATE_5_5M]	= 11, /* bits must be doubled */
+		[ZD_CCK_RATE_11M]	= 11,
 		[ZD_OFDM_RATE_6M]	=  6,
 		[ZD_OFDM_RATE_9M]	=  9,
 		[ZD_OFDM_RATE_12M]	= 12,
@@ -494,15 +494,15 @@ static int zd_calc_tx_length_us(u8 *serv
 	u32 bits = (u32)tx_length * 8;
 	u32 divisor;
 
-	divisor = rate_divisor[cs_rate];
+	divisor = rate_divisor[zd_rate];
 	if (divisor == 0)
 		return -EINVAL;
 
-	switch (cs_rate) {
-	case ZD_CS_CCK_RATE_5_5M:
+	switch (zd_rate) {
+	case ZD_CCK_RATE_5_5M:
 		bits = (2*bits) + 10; /* round up to the next integer */
 		break;
-	case ZD_CS_CCK_RATE_11M:
+	case ZD_CCK_RATE_11M:
 		if (service) {
 			u32 t = bits % 11;
 			*service &= ~ZD_PLCP_SERVICE_LENGTH_EXTENSION;
@@ -522,16 +522,16 @@ enum {
 	R2M_11A		   = 0x02,
 };
 
-static u8 cs_rate_to_modulation(u8 cs_rate, int flags)
+static u8 zd_rate_to_modulation(u8 zd_rate, int flags)
 {
 	u8 modulation;
 
-	modulation = cs_typed_rate(cs_rate);
+	modulation = zd_rate_typed(zd_rate);
 	if (flags & R2M_SHORT_PREAMBLE) {
 		switch (ZD_CS_RATE(modulation)) {
-		case ZD_CS_CCK_RATE_2M:
-		case ZD_CS_CCK_RATE_5_5M:
-		case ZD_CS_CCK_RATE_11M:
+		case ZD_CCK_RATE_2M:
+		case ZD_CCK_RATE_5_5M:
+		case ZD_CCK_RATE_11M:
 			modulation |= ZD_CS_CCK_PREA_SHORT;
 			return modulation;
 		}
@@ -548,15 +548,15 @@ static void cs_set_modulation(struct zd_
 {
 	struct ieee80211softmac_device *softmac = ieee80211_priv(mac->netdev);
 	u16 ftype = WLAN_FC_GET_TYPE(le16_to_cpu(hdr->frame_ctl));
-	u8 rate, cs_rate;
+	u8 rate, zd_rate;
 	int is_mgt = (ftype == IEEE80211_FTYPE_MGMT) != 0;
 
 	/* FIXME: 802.11a? short preamble? */
 	rate = ieee80211softmac_suggest_txrate(softmac,
 		is_multicast_ether_addr(hdr->addr1), is_mgt);
 
-	cs_rate = rate_to_cs_rate(rate);
-	cs->modulation = cs_rate_to_modulation(cs_rate, 0);
+	zd_rate = rate_to_zd_rate(rate);
+	cs->modulation = zd_rate_to_modulation(zd_rate, 0);
 }
 
 static void cs_set_control(struct zd_mac *mac, struct zd_ctrlset *cs,
Index: linux/drivers/net/wireless/zd1211rw/zd_mac.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_mac.h
+++ linux/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -48,10 +48,11 @@ struct zd_ctrlset {
 #define ZD_CS_CCK		0x00
 #define ZD_CS_OFDM		0x10
 
-#define ZD_CS_CCK_RATE_1M	0x00
-#define ZD_CS_CCK_RATE_2M	0x01
-#define ZD_CS_CCK_RATE_5_5M	0x02
-#define ZD_CS_CCK_RATE_11M	0x03
+/* These are referred to as zd_rates */
+#define ZD_CCK_RATE_1M	0x00
+#define ZD_CCK_RATE_2M	0x01
+#define ZD_CCK_RATE_5_5M	0x02
+#define ZD_CCK_RATE_11M	0x03
 /* The rates for OFDM are encoded as in the PLCP header. Use ZD_OFDM_RATE_*.
  */
 
