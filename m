From: Denis Vlasenko <vda@ilport.com.ua>
Subject: [PATCH] acxsm: merge from acx 0.3.32
Date: Fri, 3 Feb 2006 14:14:19 +0200
Message-ID: <200602031414.19571.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_bk04DDjABK7YSTN"
Cc: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: "John W. Linville" <linville@tuxdriver.com>
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

--Boundary-00=_bk04DDjABK7YSTN
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Standalone acx driver had several fixes since
acxsm fork, this patch merges them:
- initial support for new TNETW1450 USB chip
- support for firmware 2.3.1.31

Also we had one report that acxsm is actually working.
That's quite unexpected.

Signed-off-by: Denis Vlasenko <vda@ilport.com.ua>
--
vda

--Boundary-00=_bk04DDjABK7YSTN
Content-Type: text/x-diff;
  charset="us-ascii";
  name="acx.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="acx.diff"

diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/Changelog wireless-2.6.git.acx/drivers/net/wireless/tiacx/Changelog
--- wireless-2.6.git/drivers/net/wireless/tiacx/Changelog	Thu Feb  2 17:17:50 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/Changelog	Fri Feb  3 13:38:12 2006
@@ -70,6 +70,12 @@ TODO: from Efthym <efthym@gmx.net>:
 13:13:32 wlan0: tx error 0x20, buf 05!
 13:13:32 wlan0: tx error 0x20, buf 06!
 
+[20060203] 0.4.3
+* merge from acx 0.3.32
+
+[20060123] 0.4.2
+* conv.c removed
+
 [20060117] 0.4.1
 * Lots of code commented out
 
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/acx_config.h wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_config.h
--- wireless-2.6.git/drivers/net/wireless/tiacx/acx_config.h	Thu Feb  2 17:17:50 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_config.h	Fri Feb  3 13:38:12 2006
@@ -1,10 +1,10 @@
-#define ACX_RELEASE "v0.4.2"
+#define ACX_RELEASE "v0.4.3"
 
 /* set to 0 if you don't want any debugging code to be compiled in */
 /* set to 1 if you want some debugging */
 /* set to 2 if you want extensive debug log */
 #define ACX_DEBUG 2
-#define ACX_DEFAULT_MSG 0
+#define ACX_DEFAULT_MSG (L_ASSOC|L_INIT)
 
 /* assume 32bit I/O width
  * (16bit is also compatible with Compact Flash) */
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/acx_func.h wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_func.h
--- wireless-2.6.git/drivers/net/wireless/tiacx/acx_func.h	Thu Feb  2 17:17:50 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_func.h	Fri Feb  3 13:38:12 2006
@@ -565,14 +565,7 @@ acx_l_tx_data(acx_device_t *adev, tx_t *
 static inline wlan_hdr_t*
 acx_get_wlan_hdr(acx_device_t *adev, const rxbuffer_t *rxbuf)
 {
-	if (!(adev->rx_config_1 & RX_CFG1_INCLUDE_PHY_HDR))
-		return (wlan_hdr_t*)&rxbuf->hdr_a3;
-
-	/* take into account phy header in front of packet */
-	if (IS_ACX111(adev))
-		return (wlan_hdr_t*)((u8*)&rxbuf->hdr_a3 + 8);
-
-	return (wlan_hdr_t*)((u8*)&rxbuf->hdr_a3 + 4);
+	return (wlan_hdr_t*)((u8*)&rxbuf->hdr_a3 + adev->phy_header_len);
 }
 
 void acxpci_l_power_led(acx_device_t *adev, int enable);
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/acx_struct.h wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_struct.h
--- wireless-2.6.git/drivers/net/wireless/tiacx/acx_struct.h	Thu Feb  2 17:17:50 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/acx_struct.h	Fri Feb  3 13:38:12 2006
@@ -105,6 +105,10 @@ enum { acx_debug = 0 };
 #define DEVTYPE_PCI		0
 #define DEVTYPE_USB		1
 
+#if !defined(CONFIG_ACX_PCI) && !defined(CONFIG_ACX_USB)
+#error Driver must include PCI and/or USB support. You selected neither.
+#endif
+
 #if defined(CONFIG_ACX_PCI)
  #if !defined(CONFIG_ACX_USB)
   #define IS_PCI(adev)	1
@@ -148,6 +152,7 @@ enum { acx_debug = 0 };
 #define RADIO_UNKNOWN_17	0x17
 /* FwRad19.bin was found in a Safecom driver; must be an ACX111 radio: */
 #define RADIO_UNKNOWN_19	0x19
+#define RADIO_UNKNOWN_1B	0x1b    /* radio in SafeCom SWLUT-54125 USB adapter; entirely unknown!! */
 
 /* Controller Commands */
 /* can be found in table cmdTable in firmware "Rev. 1.5.0" (FW150) */
@@ -174,13 +179,18 @@ enum { acx_debug = 0 };
 #define ACX1xx_CMD_WAKE			0x10
 #define ACX1xx_CMD_UNKNOWN_11		0x11	/* mapped to unknownCMD in FW150 */
 #define ACX100_CMD_INIT_MEMORY		0x12
+#define ACX1FF_CMD_DISABLE_RADIO	0x12	/* new firmware? TNETW1450? */
 #define ACX1xx_CMD_CONFIG_BEACON	0x13
 #define ACX1xx_CMD_CONFIG_PROBE_RESPONSE	0x14
 #define ACX1xx_CMD_CONFIG_NULL_DATA	0x15
 #define ACX1xx_CMD_CONFIG_PROBE_REQUEST	0x16
-#define ACX1xx_CMD_TEST			0x17
+#define ACX1xx_CMD_FCC_TEST		0x17
 #define ACX1xx_CMD_RADIOINIT		0x18
 #define ACX111_CMD_RADIOCALIB		0x19
+#define ACX1FF_CMD_NOISE_HISTOGRAM	0x1c /* new firmware? TNETW1450? */
+#define ACX1FF_CMD_RX_RESET		0x1d /* new firmware? TNETW1450? */
+#define ACX1FF_CMD_LNA_CONTROL		0x20 /* new firmware? TNETW1450? */
+#define ACX1FF_CMD_CONTROL_DBG_TRACE	0x21 /* new firmware? TNETW1450? */
 
 /* 'After Interrupt' Commands */
 #define ACX_AFTER_IRQ_CMD_STOP_SCAN	0x01
@@ -229,18 +239,22 @@ enum { acx_debug = 0 };
 /* these are handled by real_cfgtable in firmware "Rev 1.5.0" (FW150) */
 DEF_IE(1xx_IE_UNKNOWN_00		,0x0000, -1);	/* mapped to cfgInvalid in FW150 */
 DEF_IE(100_IE_ACX_TIMER			,0x0001, 0x10);
-DEF_IE(1xx_IE_POWER_MGMT		,0x0002, 0x06);
+DEF_IE(1xx_IE_POWER_MGMT		,0x0002, 0x06); /* TNETW1450: length 0x18!! */
 DEF_IE(1xx_IE_QUEUE_CONFIG		,0x0003, 0x1c);
 DEF_IE(100_IE_BLOCK_SIZE		,0x0004, 0x02);
+DEF_IE(1FF_IE_SLOT_TIME			,0x0004, 0x08); /* later firmware versions only? */
 DEF_IE(1xx_IE_MEMORY_CONFIG_OPTIONS	,0x0005, 0x14);
-DEF_IE(1xx_IE_RATE_FALLBACK		,0x0006, 0x01);
+DEF_IE(1FF_IE_QUEUE_HEAD		,0x0005, 0x14 /* FIXME: length? */);
+DEF_IE(1xx_IE_RATE_FALLBACK		,0x0006, 0x01); /* TNETW1450: length 2 */
 DEF_IE(100_IE_WEP_OPTIONS		,0x0007, 0x03);
 DEF_IE(111_IE_RADIO_BAND		,0x0007, -1);
-DEF_IE(1xx_IE_MEMORY_MAP		,0x0008, 0x28); /* huh? */
+DEF_IE(1FF_IE_TIMING_CFG		,0x0007, -1);	/* later firmware versions; TNETW1450 only? */
 DEF_IE(100_IE_SSID			,0x0008, 0x20); /* huh? */
+DEF_IE(1xx_IE_MEMORY_MAP		,0x0008, 0x28); /* huh? TNETW1450 has length 0x40!! */
 DEF_IE(1xx_IE_SCAN_STATUS		,0x0009, 0x04); /* mapped to cfgInvalid in FW150 */
 DEF_IE(1xx_IE_ASSOC_ID			,0x000a, 0x02);
 DEF_IE(1xx_IE_UNKNOWN_0B		,0x000b, -1);	/* mapped to cfgInvalid in FW150 */
+DEF_IE(1FF_IE_TX_POWER_LEVEL_TABLE	,0x000b, 0x18); /* later firmware versions; TNETW1450 only? */
 DEF_IE(100_IE_UNKNOWN_0C		,0x000c, -1);	/* very small implementation in FW150! */
 /* ACX100 has an equivalent struct in the cmd mailbox directly after reset.
  * 0x14c seems extremely large, will trash stack on failure (memset!)
@@ -253,30 +267,47 @@ DEF_IE(1xx_IE_RXCONFIG			,0x0010, 0x04);
 DEF_IE(100_IE_UNKNOWN_11		,0x0011, -1);	/* NONBINARY: large implementation in FW150! link quality readings or so? */
 DEF_IE(111_IE_QUEUE_THRESH		,0x0011, -1);
 DEF_IE(100_IE_UNKNOWN_12		,0x0012, -1);	/* NONBINARY: VERY large implementation in FW150!! */
-DEF_IE(111_IE_BSS_POWER_SAVE		,0x0012, -1);
-DEF_IE(1xx_IE_FIRMWARE_STATISTICS	,0x0013, 0x9c);
+DEF_IE(111_IE_BSS_POWER_SAVE		,0x0012, /* -1 */ 2);
+DEF_IE(1xx_IE_FIRMWARE_STATISTICS	,0x0013, 0x9c); /* TNETW1450: length 0x134!! */
+DEF_IE(1FF_IE_RX_INTR_CONFIG		,0x0014, 0x14); /* later firmware versions, TNETW1450 only? */
 DEF_IE(1xx_IE_FEATURE_CONFIG		,0x0015, 0x08);
 DEF_IE(111_IE_KEY_CHOOSE		,0x0016, 0x04);	/* for rekeying. really len=4?? */
+DEF_IE(1FF_IE_MISC_CONFIG_TABLE		,0x0017, 0x04); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_WONE_CONFIG		,0x0018, -1);	/* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_TID_CONFIG		,0x001a, 0x2c); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_CALIB_ASSESSMENT		,0x001e, 0x04); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_BEACON_FILTER_OPTIONS	,0x001f, 0x02); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_LOW_RSSI_THRESH_OPT	,0x0020, 0x04); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_NOISE_HISTOGRAM_RESULTS	,0x0021, 0x30); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_PACKET_DETECT_THRESH	,0x0023, 0x04); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_TX_CONFIG_OPTIONS		,0x0024, 0x04); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_CCA_THRESHOLD		,0x0025, 0x02); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_EVENT_MASK		,0x0026, 0x08); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_DTIM_PERIOD		,0x0027, 0x02); /* later firmware versions, TNETW1450 only? */
+DEF_IE(1FF_IE_ACI_CONFIG_SET		,0x0029, 0x06); /* later firmware versions; maybe TNETW1450 only? */
+DEF_IE(1FF_IE_EEPROM_VER		,0x0030, 0x04); /* later firmware versions; maybe TNETW1450 only? */
 DEF_IE(1xx_IE_DOT11_STATION_ID		,0x1001, 0x06);
 DEF_IE(100_IE_DOT11_UNKNOWN_1002	,0x1002, -1);	/* mapped to cfgInvalid in FW150 */
-DEF_IE(111_IE_DOT11_FRAG_THRESH		,0x1002, -1);	/* mapped to cfgInvalid in FW150 */
+DEF_IE(111_IE_DOT11_FRAG_THRESH		,0x1002, -1);	/* mapped to cfgInvalid in FW150; TNETW1450 has length 2!! */
 DEF_IE(100_IE_DOT11_BEACON_PERIOD	,0x1003, 0x02);	/* mapped to cfgInvalid in FW150 */
 DEF_IE(1xx_IE_DOT11_DTIM_PERIOD		,0x1004, -1);	/* mapped to cfgInvalid in FW150 */
-DEF_IE(1xx_IE_DOT11_SHORT_RETRY_LIMIT	,0x1005, 0x01);
-DEF_IE(1xx_IE_DOT11_LONG_RETRY_LIMIT	,0x1006, 0x01);
-DEF_IE(100_IE_DOT11_WEP_DEFAULT_KEY_WRITE	,0x1007, 0x20);	/* configure default keys */
+DEF_IE(1FF_IE_DOT11_MAX_RX_LIFETIME	,0x1004, -1);	/* later firmware versions; maybe TNETW1450 only? */
+DEF_IE(1xx_IE_DOT11_SHORT_RETRY_LIMIT	,0x1005, 0x01); /* TNETW1450: length 2 */
+DEF_IE(1xx_IE_DOT11_LONG_RETRY_LIMIT	,0x1006, 0x01); /* TNETW1450: length 2 */
+DEF_IE(100_IE_DOT11_WEP_DEFAULT_KEY_WRITE	,0x1007, 0x20);	/* configure default keys; TNETW1450 has length 0x24!! */
 DEF_IE(1xx_IE_DOT11_MAX_XMIT_MSDU_LIFETIME	,0x1008, 0x04);
 DEF_IE(1xx_IE_DOT11_GROUP_ADDR		,0x1009, -1);
 DEF_IE(1xx_IE_DOT11_CURRENT_REG_DOMAIN	,0x100a, 0x02);
 //It's harmless to have larger struct. Use USB case always.
 DEF_IE(1xx_IE_DOT11_CURRENT_ANTENNA	,0x100b, 0x02);	/* in fact len=1 for PCI */
 DEF_IE(1xx_IE_DOT11_UNKNOWN_100C	,0x100c, -1);	/* mapped to cfgInvalid in FW150 */
-DEF_IE(1xx_IE_DOT11_TX_POWER_LEVEL	,0x100d, 0x01);
+DEF_IE(1xx_IE_DOT11_TX_POWER_LEVEL	,0x100d, 0x01); /* TNETW1450 has length 2!! */
 DEF_IE(1xx_IE_DOT11_CURRENT_CCA_MODE	,0x100e, 0x02);	/* in fact len=1 for PCI */
 //USB doesn't return anything - len==0?!
 DEF_IE(100_IE_DOT11_ED_THRESHOLD	,0x100f, 0x04);
-DEF_IE(1xx_IE_DOT11_WEP_DEFAULT_KEY_SET	,0x1010, 0x01);	/* set default key ID */
+DEF_IE(1xx_IE_DOT11_WEP_DEFAULT_KEY_SET	,0x1010, 0x01);	/* set default key ID; TNETW1450: length 2 */
 DEF_IE(100_IE_DOT11_UNKNOWN_1011	,0x1011, -1);	/* mapped to cfgInvalid in FW150 */
+DEF_IE(1FF_IE_DOT11_CURR_5GHZ_REGDOM	,0x1011, -1);	/* later firmware versions; maybe TNETW1450 only? */
 DEF_IE(100_IE_DOT11_UNKNOWN_1012	,0x1012, -1);	/* mapped to cfgInvalid in FW150 */
 DEF_IE(100_IE_DOT11_UNKNOWN_1013	,0x1013, -1);	/* mapped to cfgInvalid in FW150 */
 
@@ -479,15 +510,15 @@ typedef struct phy_hdr {
  * Some seem to have different meanings... */
 
 #define RXBUF_HDRSIZE 12
-#define PHY_HDR(rxbuf) ((phy_hdr_t*)&rxbuf->hdr_a3)
-#define RXBUF_BYTES_RCVD(rxbuf) (le16_to_cpu(rxbuf->mac_cnt_rcvd) & 0xfff)
+#define RXBUF_BYTES_RCVD(adev, rxbuf) \
+		((le16_to_cpu((rxbuf)->mac_cnt_rcvd) & 0xfff) - (adev)->phy_header_len)
 #define RXBUF_BYTES_USED(rxbuf) \
-		((le16_to_cpu(rxbuf->mac_cnt_rcvd) & 0xfff) + RXBUF_HDRSIZE)
+		((le16_to_cpu((rxbuf)->mac_cnt_rcvd) & 0xfff) + RXBUF_HDRSIZE)
 /* USBism */
-#define RXBUF_IS_TXSTAT(rxbuf) (le16_to_cpu(rxbuf->mac_cnt_rcvd) & 0x8000)
+#define RXBUF_IS_TXSTAT(rxbuf) (le16_to_cpu((rxbuf)->mac_cnt_rcvd) & 0x8000)
 /*
 mac_cnt_rcvd:
-    12 bits: length of frame from control field to last byte of FCS
+    12 bits: length of frame from control field to first byte of FCS
     3 bits: reserved
     1 bit: 1 = it's a tx status info, not a rx packet (USB only)
 
@@ -603,31 +634,6 @@ typedef struct fw_ver {
 
 #define FW_ID_SIZE 20
 
-
-/*--- WEP stuff --------------------------------------------------------------*/
-#define DOT11_MAX_DEFAULT_WEP_KEYS	4
-
-/* non-firmware struct, no packing necessary */
-typedef struct wep_key {
-	size_t	size; /* most often used member first */
-	u8	index;
-	u8	key[29];
-	u16	strange_filler;
-} wep_key_t;			/* size = 264 bytes (33*8) */
-/* FIXME: We don't have size 264! Or is there 2 bytes beyond the key
- * (strange_filler)? */
-
-/* non-firmware struct, no packing necessary */
-typedef struct key_struct {
-	u8	addr[ETH_ALEN];	/* 0x00 */
-	u16	filler1;	/* 0x06 */
-	u32	filler2;	/* 0x08 */
-	u32	index;		/* 0x0c */
-	u16	len;		/* 0x10 */
-	u8	key[29];	/* 0x12; is this long enough??? */
-} key_struct_t;			/* size = 276. FIXME: where is the remaining space?? */
-
-
 /*--- Client (peer) info -----------------------------------------------------*/
 /* adev->sta_list[] is used for:
 ** accumulating and processing of scan results
@@ -1108,6 +1114,9 @@ struct acx_device {
 	/* most frequent accesses first (dereferencing and cache line!) */
 
 	/*** Locking ***/
+	/* FIXME: try to convert semaphore to more efficient mutex according
+	   to Ingo Molnar's docs (but not before driver is in mainline or
+		 pre-mutex Linux 2.6.10 is very outdated). */
 	struct semaphore	sem;
 	spinlock_t		lock;
 #if defined(PARANOID_LOCKING) /* Lock debugging */
@@ -1286,14 +1295,6 @@ struct acx_device {
 	u8		rate_supported_len;
 	u8		rate_supported[13];
 
-	/*** Encryption settings (WEP) ***/
-	u32		auth_alg;		/* used in transmit_authen1 */
-	u8		wep_enabled;
-	u8		wep_restricted;
-	u8		wep_current_index;
-	wep_key_t	wep_keys[DOT11_MAX_DEFAULT_WEP_KEYS];	/* the default WEP keys */
-	key_struct_t	wep_key_struct[10];
-
 	/*** Unknown ***/
 	u8		dtim_interval;
 
@@ -1303,6 +1304,7 @@ struct acx_device {
 	u16		memblocksize;
 	unsigned int	tx_free;
 	unsigned int	tx_head; /* keep as close as possible to Tx stuff below (cache line) */
+	u16		phy_header_len;
 
 /*************************************************************************
  *** PCI/USB/... must be last or else hw agnostic code breaks horribly ***
@@ -1380,9 +1382,10 @@ struct acx_device {
 static inline acx_device_t*
 ndev2adev(struct net_device *ndev)
 {
-        return ieee80211softmac_priv(ndev);
+	return ieee80211softmac_priv(ndev);
 }
 
+
 /* For use with ACX1xx_IE_RXCONFIG */
 /*  bit     description
  *    13   include additional header (length etc.) *required*
@@ -1852,7 +1855,7 @@ typedef struct acx_joinbss {
 */
 typedef struct mem_read_write {
 	u16	addr ACX_PACKED;
-	u16	type ACX_PACKED; /* 0x0 int. RAM / 0xffff MAC reg. / 0x81 PHY RAM / 0x82 PHY reg. */
+	u16	type ACX_PACKED; /* 0x0 int. RAM / 0xffff MAC reg. / 0x81 PHY RAM / 0x82 PHY reg.; or maybe it's actually 0x30 for MAC? Better verify it by writing and reading back and checking whether the value holds! */
 	u32	len ACX_PACKED;
 	u32	data ACX_PACKED;
 } mem_read_write_t;
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/common.c wireless-2.6.git.acx/drivers/net/wireless/tiacx/common.c
--- wireless-2.6.git/drivers/net/wireless/tiacx/common.c	Thu Feb  2 17:17:50 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/common.c	Fri Feb  3 13:38:12 2006
@@ -631,13 +631,6 @@ acx_s_get_firmware_version(acx_device_t 
 			printk("acx: firmware '%s' is known to be buggy, "
 				"please upgrade\n", adev->firmware_version);
 		}
-		if (adev->firmware_numver == 0x02030131) {
-			/* With this one, all rx packets look mangled
-			** Most probably we simply do not know how to use it
-			** properly */
-			printk("acx: firmware '%s' does not work well "
-				"with this driver\n", adev->firmware_version);
-		}
 	}
 
 	adev->firmware_id = le32_to_cpu(fw.hw_id);
@@ -655,6 +648,9 @@ acx_s_get_firmware_version(acx_device_t 
 		case 0x03010000:
 			adev->chip_name = "TNETW1130";
 			break;
+		case 0x04030000: /* 0x04030101 is TNETW1450 */
+			adev->chip_name = "TNETW1450";
+			break;
 		default:
 			printk("acx: unknown chip ID 0x%08X, "
 				"please report\n", adev->firmware_id);
@@ -679,9 +675,6 @@ acx_display_hardware_details(acx_device_
 
 	switch (adev->radio_type) {
 	case RADIO_MAXIM_0D:
-		/* hmm, the DWL-650+ seems to have two variants,
-		 * according to a windows driver changelog comment:
-		 * RFMD and Maxim. */
 		radio_str = "Maxim";
 		break;
 	case RADIO_RFMD_11:
@@ -701,8 +694,11 @@ acx_display_hardware_details(acx_device_
 	case RADIO_UNKNOWN_19:
 		radio_str = "A radio used by Safecom cards?! Please report";
 		break;
+	case RADIO_UNKNOWN_1B:
+		radio_str = "An unknown radio used by TNETW1450 USB adapters";
+		break;
 	default:
-		radio_str = "UNKNOWN, please report the radio type name!";
+		radio_str = "UNKNOWN, please report radio type name!";
 		break;
 	}
 
@@ -861,6 +857,32 @@ acx100_ie_len[] = {
 	0,
 	ACX1xx_IE_FEATURE_CONFIG_LEN,
 	ACX111_IE_KEY_CHOOSE_LEN,
+	ACX1FF_IE_MISC_CONFIG_TABLE_LEN,
+	ACX1FF_IE_WONE_CONFIG_LEN,
+	0,
+	ACX1FF_IE_TID_CONFIG_LEN,
+	0,
+	0,
+	0,
+	ACX1FF_IE_CALIB_ASSESSMENT_LEN,
+	ACX1FF_IE_BEACON_FILTER_OPTIONS_LEN,
+	ACX1FF_IE_LOW_RSSI_THRESH_OPT_LEN,
+	ACX1FF_IE_NOISE_HISTOGRAM_RESULTS_LEN,
+	0,
+	ACX1FF_IE_PACKET_DETECT_THRESH_LEN,
+	ACX1FF_IE_TX_CONFIG_OPTIONS_LEN,
+	ACX1FF_IE_CCA_THRESHOLD_LEN,
+	ACX1FF_IE_EVENT_MASK_LEN,
+	ACX1FF_IE_DTIM_PERIOD_LEN,
+	0,
+	ACX1FF_IE_ACI_CONFIG_SET_LEN,
+	0,
+	0,
+	0,
+	0,
+	0,
+	0,
+	ACX1FF_IE_EEPROM_VER_LEN,
 };
 
 static const u16
@@ -912,6 +934,32 @@ acx111_ie_len[] = {
 	0,
 	ACX1xx_IE_FEATURE_CONFIG_LEN,
 	ACX111_IE_KEY_CHOOSE_LEN,
+	ACX1FF_IE_MISC_CONFIG_TABLE_LEN,
+	ACX1FF_IE_WONE_CONFIG_LEN,
+	0,
+	ACX1FF_IE_TID_CONFIG_LEN,
+	0,
+	0,
+	0,
+	ACX1FF_IE_CALIB_ASSESSMENT_LEN,
+	ACX1FF_IE_BEACON_FILTER_OPTIONS_LEN,
+	ACX1FF_IE_LOW_RSSI_THRESH_OPT_LEN,
+	ACX1FF_IE_NOISE_HISTOGRAM_RESULTS_LEN,
+	0,
+	ACX1FF_IE_PACKET_DETECT_THRESH_LEN,
+	ACX1FF_IE_TX_CONFIG_OPTIONS_LEN,
+	ACX1FF_IE_CCA_THRESHOLD_LEN,
+	ACX1FF_IE_EVENT_MASK_LEN,
+	ACX1FF_IE_DTIM_PERIOD_LEN,
+	0,
+	ACX1FF_IE_ACI_CONFIG_SET_LEN,
+	0,
+	0,
+	0,
+	0,
+	0,
+	0,
+	ACX1FF_IE_EEPROM_VER_LEN,
 };
 
 static const u16
@@ -992,6 +1040,8 @@ acx_s_interrogate_debug(acx_device_t *ad
 	u16 len;
 	int res;
 
+	/* FIXME: no check whether this exceeds the array yet.
+	 * We should probably remember the number of entries... */
 	if (type < 0x1000)
 		len = adev->ie_len[type];
 	else
@@ -1137,8 +1187,8 @@ acx_s_proc_diag_output(char *buf, acx_de
 		"WEP ena %d, restricted %d, idx %d\n",
 		adev->essid, adev->essid_active, (int)adev->essid_len,
 		adev->essid_for_assoc, adev->nick,
-		adev->wep_enabled, adev->wep_restricted,
-		adev->wep_current_index);
+		adev->ieee->sec.enabled, adev->ieee->sec.auth_mode,
+		adev->ieee->sec.active_key);
 	p += sprintf(p, "dev_addr  "MACSTR"\n", MAC(adev->dev_addr));
 	p += sprintf(p, "bssid     "MACSTR"\n", MAC(adev->bssid));
 	p += sprintf(p, "ap_filter "MACSTR"\n", MAC(adev->ap));
@@ -2087,6 +2137,12 @@ acx_s_initialize_rx_config(acx_device_t 
 	}
 	adev->rx_config_1 |= RX_CFG1_INCLUDE_RXBUF_HDR;
 
+	if ((adev->rx_config_1 & RX_CFG1_INCLUDE_PHY_HDR)
+	 || (adev->firmware_numver >= 0x02000000))
+		adev->phy_header_len = IS_ACX111(adev) ? 8 : 4;
+	else
+		adev->phy_header_len = 0;
+
 	log(L_INIT, "setting RXconfig to %04X:%04X\n",
 			adev->rx_config_1, adev->rx_config_2);
 	cfg.rx_cfg1 = cpu_to_le16(adev->rx_config_1);
@@ -2105,6 +2161,19 @@ acx_s_set_defaults(acx_device_t *adev)
 
 	FN_ENTER;
 
+	/* do it before getting settings, prevent bogus channel 0 warning */
+	adev->channel = 1;
+
+	/* query some settings from the card.
+	 * NOTE: for some settings, e.g. CCA and ED (ACX100!), an initial
+	 * query is REQUIRED, otherwise the card won't work correctly! */
+	adev->get_mask = GETSET_ANTENNA|GETSET_SENSITIVITY|GETSET_STATION_ID|GETSET_REG_DOMAIN;
+	/* Only ACX100 supports ED and CCA */
+	if (IS_ACX100(adev))
+		adev->get_mask |= GETSET_CCA|GETSET_ED_THRESH;
+
+	acx_s_update_card_settings(adev);
+
 	acx_lock(adev, flags);
 
 	/* set our global interrupt mask */
@@ -2115,8 +2184,11 @@ acx_s_set_defaults(acx_device_t *adev)
 	adev->brange_max_quality = 60; /* LED blink max quality is 60 */
 	adev->brange_time_last_state_change = jiffies;
 
+	/* copy the MAC address we just got from the card
+	 * into our MAC address used during current 802.11 session */
 	MAC_COPY(adev->dev_addr, adev->ndev->dev_addr);
 	MAC_BCAST(adev->ap);
+
 	adev->essid_len =
 		snprintf(adev->essid, sizeof(adev->essid), "STA%02X%02X%02X",
 			adev->dev_addr[3], adev->dev_addr[4], adev->dev_addr[5]);
@@ -2131,23 +2203,19 @@ acx_s_set_defaults(acx_device_t *adev)
 		adev->reg_dom_id = adev->cfgopt_domains.list[0];
 	}
 
-	adev->channel = 1;
 	/* 0xffff would be better, but then we won't get a "scan complete"
 	 * interrupt, so our current infrastructure will fail: */
 	adev->scan_count = 1;
 	adev->scan_mode = ACX_SCAN_OPT_ACTIVE;
-
 	adev->scan_duration = 100;
 	adev->scan_probe_delay = 200;
 	/* reported to break scanning: adev->scan_probe_delay = adev->cfgopt_probe_delay; */
 	adev->scan_rate = ACX_SCAN_RATE_1;
 
-	adev->auth_alg = WLAN_AUTH_ALG_OPENSYSTEM;
-	adev->preamble_mode = 2; /* auto */
+	adev->mode = ACX_MODE_2_STA;
+	adev->ieee->sec.auth_mode = WLAN_AUTH_OPEN;
 	adev->listen_interval = 100;
 	adev->beacon_interval = DEFAULT_BEACON_INTERVAL;
-	adev->mode = ACX_MODE_2_STA;
-	adev->monitor_type = ARPHRD_IEEE80211_PRISM;
 	adev->dtim_interval = DEFAULT_DTIM_INTERVAL;
 
 	adev->msdu_lifetime = DEFAULT_MSDU_LIFETIME;
@@ -2159,6 +2227,7 @@ acx_s_set_defaults(acx_device_t *adev)
 	adev->short_retry = 7; /* max. retries for (short) non-RTS packets */
 	adev->long_retry = 4; /* max. retries for long (RTS) packets */
 
+	adev->preamble_mode = 2; /* auto */
 	adev->fallback_threshold = 3;
 	adev->stepup_threshold = 10;
 	adev->rate_bcast = RATE111_1;
@@ -2170,9 +2239,12 @@ acx_s_set_defaults(acx_device_t *adev)
 	} else {
 		adev->rate_oper = RATE111_ACX100_COMPAT;
 	}
-	/* build 802.11 style ratevector (802.11 7.3.2.2) */
+
+	/* Supported Rates element - the rates here are given in units of
+	 * 500 kbit/s, plus 0x80 added. See 802.11-1999.pdf item 7.3.2.2 */
 	acx_l_update_ratevector(adev);
 
+	/* set some more defaults */
 	if (IS_ACX111(adev)) {
 		/* 30mW (15dBm) is default, at least in my acx111 card: */
 		adev->tx_level_dbm = 15;
@@ -2183,7 +2255,6 @@ acx_s_set_defaults(acx_device_t *adev)
 		adev->tx_level_dbm = 18;
 	}
 	/* adev->tx_level_auto = 1; */
-
 	if (IS_ACX111(adev)) {
 		/* start with sensitivity level 1 out of 3: */
 		adev->sensitivity = 1;
@@ -2204,31 +2275,24 @@ acx_s_set_defaults(acx_device_t *adev)
 	adev->ps_enhanced_transition_time = 0;
 #endif
 
+	/* These settings will be set in fw on ifup */
 	adev->set_mask = 0
-		/* better re-init the antenna value we got */
-		| GETSET_ANTENNA
-		| GETSET_TXPOWER
-		| SET_RXCONFIG
-		/* configure card to do rate fallback when in auto rate mode. */
 		| GETSET_RETRY
 		| SET_MSDU_LIFETIME
+	/* configure card to do rate fallback when in auto rate mode */
 		| SET_RATE_FALLBACK
+		| SET_RXCONFIG
+		| GETSET_TXPOWER
+	/* better re-init the antenna value we got above */
+		| GETSET_ANTENNA
 #if POWER_SAVE_80211
 		| GETSET_POWER_80211
 #endif
 		;
-	/* query some settings from the card.
-	 * NOTE: for some settings, e.g. CCA and ED (ACX100!), an initial
-	 * query is REQUIRED, otherwise the card won't work correctly!! */
-	adev->get_mask = GETSET_ANTENNA|GETSET_SENSITIVITY|GETSET_STATION_ID|GETSET_REG_DOMAIN;
-	/* Only ACX100 supports ED and CCA */
-	if (IS_ACX100(adev))
-		adev->get_mask |= GETSET_CCA|GETSET_ED_THRESH;
 
 	acx_unlock(adev, flags);
 	acx_lock_unhold(); /* hold time 844814 CPU ticks @2GHz */
 
-	acx_s_update_card_settings(adev);
 	acx_s_initialize_rx_config(adev);
 
 	FN_EXIT0;
@@ -2576,14 +2640,14 @@ void
 acx_l_process_rxbuf(acx_device_t *adev, rxbuffer_t *rxbuf)
 {
 	struct wlan_hdr *hdr;
-	unsigned int buf_len;
 	unsigned int qual;
+	int buf_len;
 	u16 fc;
 
 	hdr = acx_get_wlan_hdr(adev, rxbuf);
-	/* length of frame from control field to last byte of FCS */
 	fc = le16_to_cpu(hdr->fc);
-	buf_len = RXBUF_BYTES_RCVD(rxbuf);
+	/* length of frame from control field to first byte of FCS */
+	buf_len = RXBUF_BYTES_RCVD(adev, rxbuf);
 
 	if ( ((WF_FC_FSTYPE & fc) != WF_FSTYPE_BEACON)
 	  || (acx_debug & L_XFER_BEACON)
@@ -2739,16 +2803,14 @@ acx_l_softmac_process_rxbuf(acx_device_t
 	struct ieee80211_rx_stats stats;
 	struct wlan_hdr *hdr;
 	struct sk_buff *skb;
-	int buf_len;
 	int skb_len;
-	int payload_offset;
 	u16 fc;
 
 	FN_ENTER;
 
+	skb_len = RXBUF_BYTES_RCVD(adev, rxbuf);
 	hdr = acx_get_wlan_hdr(adev, rxbuf);
 	fc = le16_to_cpu(hdr->fc);
-	buf_len = RXBUF_BYTES_RCVD(rxbuf);
 
 	if ( ((WF_FC_FSTYPE & fc) != WF_FSTYPE_BEACON)
 	  || (acx_debug & L_XFER_BEACON)
@@ -2758,7 +2820,7 @@ acx_l_softmac_process_rxbuf(acx_device_t
 			"phystat:%02X phyrate:%u status:%u\n",
 			acx_get_packet_type_string(fc),
 			le32_to_cpu(rxbuf->time),
-			buf_len,
+			skb_len,
 			acx_signal_to_winlevel(rxbuf->phy_level),
 			acx_signal_to_winlevel(rxbuf->phy_snr),
 			rxbuf->mac_status,
@@ -2768,8 +2830,8 @@ acx_l_softmac_process_rxbuf(acx_device_t
 	}
 
 	if (unlikely(acx_debug & L_DATA)) {
-		printk("rx: 802.11 buf[%u]: ", buf_len);
-		acx_dump_bytes(hdr, buf_len);
+		printk("rx: 802.11 buf[%u]: ", skb_len);
+		acx_dump_bytes(hdr, skb_len);
 	}
 
 	/* FIXME: should check for Rx errors (rxbuf->mac_status?
@@ -2779,8 +2841,6 @@ acx_l_softmac_process_rxbuf(acx_device_t
 	/* we are in big luck: the acx100 doesn't modify any of the fields */
 	/* in the 802.11 frame. just pass this packet into the PF_PACKET */
 	/* subsystem. yeah. */
-	payload_offset = ((u8*)acx_get_wlan_hdr(adev, rxbuf) - (u8*)rxbuf);
-	skb_len = RXBUF_BYTES_USED(rxbuf) - payload_offset;
 
 	/* sanity check */
 	if (unlikely(skb_len > WLAN_A4FR_MAXLEN_WEP)) {
@@ -2798,7 +2858,7 @@ acx_l_softmac_process_rxbuf(acx_device_t
 	}
 
 	skb_put(skb, skb_len);
-	memcpy(skb->data, ((unsigned char*)rxbuf)+payload_offset, skb_len);
+	memcpy(skb->data, hdr, skb_len);
 
 	memset(&stats, 0, sizeof(stats));
 	stats.mac_time = le16_to_cpu(rxbuf->time);
@@ -3477,7 +3537,7 @@ acx_i_timer(unsigned long address)
 	case ACX_STATUS_3_AUTHENTICATED:
 		/* was set to 0 by set_status() */
 		if (++adev->auth_or_assoc_retries < 10) {
-			log(L_ASSOC,	"resend assoc request (attempt %d)\n",
+			log(L_ASSOC, "resend assoc request (attempt %d)\n",
 					adev->auth_or_assoc_retries + 1);
 			//sm? acx_l_transmit_assoc_req(adev);
 		} else {
@@ -4061,10 +4121,10 @@ acx_l_process_data_frame_master(acx_devi
 		/* To_DS = 0, From_DS = 1 */
 		hdr->fc = WF_FC_FROMDSi + WF_FTYPE_DATAi;
 
-		len = RXBUF_BYTES_RCVD(rxbuf);
 		txbuf = acx_l_get_txbuf(adev, tx);
 		if (txbuf) {
-			memcpy(txbuf, &rxbuf->hdr_a3, len);
+			len = RXBUF_BYTES_RCVD(adev, rxbuf);
+			memcpy(txbuf, hdr, len);
 			acx_l_tx_data(adev, tx, len);
 		} else {
 			acx_l_dealloc_tx(adev, tx);
@@ -4219,7 +4279,7 @@ acx_l_process_mgmt_frame(acx_device_t *a
 		return NOT_OK;
 	}
 
-	len = RXBUF_BYTES_RCVD(rxbuf);
+	len = RXBUF_BYTES_RCVD(adev, rxbuf);
 	if (WF_FC_ISWEPi & hdr->fc)
 		len -= 0x10;
 
@@ -5434,14 +5494,14 @@ acx100_s_set_wepkey(acx_device_t *adev)
 	ie_dot11WEPDefaultKey_t dk;
 	int i;
 
-	for (i = 0; i < DOT11_MAX_DEFAULT_WEP_KEYS; i++) {
-		if (adev->wep_keys[i].size != 0) {
+	for (i = 0; i < WEP_KEYS; i++) {
+		if (adev->ieee->sec.key_sizes[i] != 0) {
 			log(L_INIT, "setting WEP key: %d with "
-				"total size: %d\n", i, (int) adev->wep_keys[i].size);
+				"total size: %d\n", i, (int) adev->ieee->sec.key_sizes[i]);
 			dk.action = 1;
-			dk.keySize = adev->wep_keys[i].size;
+			dk.keySize = adev->ieee->sec.key_sizes[i];
 			dk.defaultKeyNum = i;
-			memcpy(dk.key, adev->wep_keys[i].key, dk.keySize);
+			memcpy(dk.key, adev->ieee->sec.keys[i], dk.keySize);
 			acx_s_configure(adev, &dk, ACX100_IE_DOT11_WEP_DEFAULT_KEY_WRITE);
 		}
 	}
@@ -5453,20 +5513,20 @@ acx111_s_set_wepkey(acx_device_t *adev)
 	acx111WEPDefaultKey_t dk;
 	int i;
 
-	for (i = 0; i < DOT11_MAX_DEFAULT_WEP_KEYS; i++) {
-		if (adev->wep_keys[i].size != 0) {
+	for (i = 0; i < WEP_KEYS; i++) {
+		if (adev->ieee->sec.key_sizes[i] != 0) {
 			log(L_INIT, "setting WEP key: %d with "
-				"total size: %d\n", i, (int) adev->wep_keys[i].size);
+				"total size: %d\n", i, (int) adev->ieee->sec.key_sizes[i]);
 			memset(&dk, 0, sizeof(dk));
 			dk.action = cpu_to_le16(1); /* "add key"; yes, that's a 16bit value */
-			dk.keySize = adev->wep_keys[i].size;
+			dk.keySize = adev->ieee->sec.key_sizes[i];
 
 			/* are these two lines necessary? */
 			dk.type = 0;              /* default WEP key */
 			dk.index = 0;             /* ignored when setting default key */
 
 			dk.defaultKeyNum = i;
-			memcpy(dk.key, adev->wep_keys[i].key, dk.keySize);
+			memcpy(dk.key, adev->ieee->sec.keys[i], dk.keySize);
 			acx_s_issue_cmd(adev, ACX1xx_CMD_WEP_MGMT, &dk, sizeof(dk));
 		}
 	}
@@ -5513,7 +5573,7 @@ acx100_s_init_wep(acx_device_t *adev)
 	}
 
 	/* let's choose maximum setting: 4 default keys, plus 10 other keys: */
-	options.NumKeys = cpu_to_le16(DOT11_MAX_DEFAULT_WEP_KEYS + 10);
+	options.NumKeys = cpu_to_le16(WEP_KEYS + 10);
 	options.WEPOption = 0x00;
 
 	log(L_ASSOC, "%s: writing WEP options\n", __func__);
@@ -5521,10 +5581,10 @@ acx100_s_init_wep(acx_device_t *adev)
 
 	acx100_s_set_wepkey(adev);
 
-	if (adev->wep_keys[adev->wep_current_index].size != 0) {
+	if (adev->ieee->sec.key_sizes[adev->ieee->sec.active_key] != 0) {
 		log(L_ASSOC, "setting active default WEP key number: %d\n",
-				adev->wep_current_index);
-		dk.KeyID = adev->wep_current_index;
+				adev->ieee->sec.active_key);
+		dk.KeyID = adev->ieee->sec.active_key;
 		acx_s_configure(adev, &dk, ACX1xx_IE_DOT11_WEP_DEFAULT_KEY_SET); /* 0x1010 */
 	}
 	/* FIXME!!! wep_key_struct is filled nowhere! But adev
@@ -6580,7 +6640,7 @@ acx_s_update_card_settings(acx_device_t 
 
 		acx_s_set_wepkey(adev);
 
-		dkey.KeyID = adev->wep_current_index;
+		dkey.KeyID = adev->ieee->sec.active_key;
 		log(L_INIT, "setting WEP key %u as default\n", dkey.KeyID);
 		acx_s_configure(adev, &dkey, ACX1xx_IE_DOT11_WEP_DEFAULT_KEY_SET);
 #ifdef DEBUG_WEP
@@ -6601,7 +6661,7 @@ acx_s_update_card_settings(acx_device_t 
 
 			/* let's choose maximum setting: 4 default keys,
 			 * plus 10 other keys: */
-			options.NumKeys = cpu_to_le16(DOT11_MAX_DEFAULT_WEP_KEYS + 10);
+			options.NumKeys = cpu_to_le16(WEP_KEYS + 10);
 			/* don't decrypt default key only,
 			 * don't override decryption: */
 			options.WEPOption = 0;
@@ -6904,7 +6964,7 @@ acx_update_capabilities(acx_device_t *ad
 	/* other types of stations do not emit beacons */
 	}
 
-	if (adev->wep_restricted) {
+	if (adev->ieee->sec.auth_mode == WLAN_AUTH_SHARED_KEY) {
 		SET_BIT(cap, WF_MGMT_CAP_PRIVACY);
 	}
 	if (adev->cfgopt_dot11ShortPreambleOption) {
@@ -7134,10 +7194,74 @@ module_exit(acx_e_cleanup_module)
 
 //SM
 void
-acx_e_ieee80211_set_security(struct net_device *dev,
+acx_e_ieee80211_set_security(struct net_device *ndev,
 		struct ieee80211_security *sec)
 {
-//todo
+/* Shamelessly copied from the rt2x00 project. */
+	acx_device_t *adev = ndev2adev(ndev);
+	unsigned long flags;
+	int i;
+
+	acx_sem_lock(adev);
+	acx_lock(adev, flags);
+
+	for (i = 0; i < WEP_KEYS; ++i) {
+		/* This gives us the flag for the 4 WEP keys. */
+		if (sec->flags & (1 << i)) {
+			adev->ieee->sec.encode_alg[i] = sec->encode_alg[i];
+			adev->ieee->sec.key_sizes[i] = sec->key_sizes[i];
+
+			if (sec->key_sizes[i] != 0) {
+				memcpy(adev->ieee->sec.keys[i], sec->keys[i],
+				       sec->key_sizes[i]);
+				/* Make sure WEP flag is set. */
+				adev->ieee->sec.flags |= (1 << i);
+			} else if (sec->level != SEC_LEVEL_1)
+				/* Make sure WEP flag isn't set. */
+				adev->ieee->sec.flags &= ~(1 << i);
+		}
+		SET_BIT(adev->set_mask, SET_WEP_OPTIONS);
+	}
+
+	if (sec->flags & SEC_ACTIVE_KEY) {
+		/* Check the key number is valid. */
+		if (sec->active_key < WEP_KEYS) {
+			adev->ieee->sec.active_key = sec->active_key;
+			adev->ieee->sec.flags |= SEC_ACTIVE_KEY;
+		} else
+			adev->ieee->sec.flags &= ~SEC_ACTIVE_KEY;
+		
+	} else
+		adev->ieee->sec.flags &= ~SEC_ACTIVE_KEY;
+
+	if (sec->flags & SEC_AUTH_MODE) {
+		adev->ieee->sec.auth_mode = sec->auth_mode;
+		adev->ieee->sec.flags |= SEC_AUTH_MODE;
+		SET_BIT(adev->set_mask, SET_WEP_OPTIONS);
+	}
+
+	if (sec->flags & SEC_ENCRYPT) {
+		adev->ieee->sec.encrypt = sec->encrypt;
+		adev->ieee->sec.flags |= SEC_ENCRYPT;
+		SET_BIT(adev->set_mask, GETSET_WEP);
+	}
+
+	if (sec->flags & SEC_ENABLED) {
+		adev->ieee->sec.enabled = sec->enabled;
+		adev->ieee->sec.flags |= SEC_ENABLED;
+		SET_BIT(adev->set_mask, GETSET_WEP);
+	}
+
+	if (sec->flags & SEC_LEVEL) {
+		adev->ieee->sec.level = sec->level;
+		adev->ieee->sec.flags |= SEC_LEVEL;
+		SET_BIT(adev->set_mask, GETSET_WEP);
+	}
+	
+	acx_unlock(adev, flags);
+	acx_sem_unlock(adev);
+
+	acx_s_update_card_settings(adev);
 }
 
 
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/ioctl.c wireless-2.6.git.acx/drivers/net/wireless/tiacx/ioctl.c
--- wireless-2.6.git/drivers/net/wireless/tiacx/ioctl.c	Thu Feb  2 17:17:50 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/ioctl.c	Fri Feb  3 13:38:12 2006
@@ -1024,7 +1024,7 @@ acx_ioctl_set_encode(
 	if (dwrq->length > 0) {
 		/* if index is 0 or invalid, use default key */
 		if ((index < 0) || (index > 3))
-			index = (int)adev->wep_current_index;
+			index = (int)adev->ieee->sec.active_key;
 
 		if (0 == (dwrq->flags & IW_ENCODE_NOKEY)) {
 			if (dwrq->length > 29)
@@ -1032,26 +1032,26 @@ acx_ioctl_set_encode(
 
 			if (dwrq->length > 13) {
 				/* 29*8 == 232, WEP256 */
-				adev->wep_keys[index].size = 29;
+				adev->ieee->sec.key_sizes[index] = 29;
 			} else if (dwrq->length > 5) {
 				/* 13*8 == 104bit, WEP128 */
-				adev->wep_keys[index].size = 13;
+				adev->ieee->sec.key_sizes[index] = 13;
 			} else if (dwrq->length > 0) {
 				/* 5*8 == 40bit, WEP64 */
-				adev->wep_keys[index].size = 5;
+				adev->ieee->sec.key_sizes[index] = 5;
 			} else {
 				/* disable key */
-				adev->wep_keys[index].size = 0;
+				adev->ieee->sec.key_sizes[index] = 0;
 			}
 
-			memset(adev->wep_keys[index].key, 0,
-				sizeof(adev->wep_keys[index].key));
-			memcpy(adev->wep_keys[index].key, extra, dwrq->length);
+			memset(adev->ieee->sec.keys[index], 0,
+				sizeof(adev->ieee->sec.keys[index]));
+			memcpy(adev->ieee->sec.keys[index], extra, dwrq->length);
 		}
 	} else {
 		/* set transmit key */
 		if ((index >= 0) && (index <= 3))
-			adev->wep_current_index = index;
+			adev->ieee->sec.active_key = index;
 		else if (0 == (dwrq->flags & IW_ENCODE_MODE)) {
 			/* complain if we were not just setting
 			 * the key mode */
@@ -1060,15 +1060,13 @@ acx_ioctl_set_encode(
 		}
 	}
 
-	adev->wep_enabled = !(dwrq->flags & IW_ENCODE_DISABLED);
+	adev->ieee->sec.enabled = !(dwrq->flags & IW_ENCODE_DISABLED);
 
 	if (dwrq->flags & IW_ENCODE_OPEN) {
-		adev->auth_alg = WLAN_AUTH_ALG_OPENSYSTEM;
-		adev->wep_restricted = 0;
+		adev->ieee->sec.auth_mode = WLAN_AUTH_OPEN;
 
 	} else if (dwrq->flags & IW_ENCODE_RESTRICTED) {
-		adev->auth_alg = WLAN_AUTH_ALG_SHAREDKEY;
-		adev->wep_restricted = 1;
+	  adev->ieee->sec.auth_mode = WLAN_AUTH_SHARED_KEY;
 	}
 
 	/* set flag to make sure the card WEP settings get updated */
@@ -1078,11 +1076,11 @@ acx_ioctl_set_encode(
 		dwrq->length, extra, dwrq->flags);
 
 	for (index = 0; index <= 3; index++) {
-		if (adev->wep_keys[index].size) {
+		if (adev->ieee->sec.key_sizes[index]) {
 			log(L_IOCTL,	"index=%d, size=%d, key at 0x%p\n",
-				adev->wep_keys[index].index,
-				(int) adev->wep_keys[index].size,
-				adev->wep_keys[index].key);
+				adev->ieee->sec.active_key,
+				(int) adev->ieee->sec.key_sizes[index],
+				adev->ieee->sec.keys[index]);
 		}
 	}
 	result = -EINPROGRESS;
@@ -1111,18 +1109,18 @@ acx_ioctl_get_encode(
 
 	FN_ENTER;
 
-	if (adev->wep_enabled == 0) {
+	if (adev->ieee->sec.enabled == 0) {
 		dwrq->flags = IW_ENCODE_DISABLED;
 	} else {
 		if ((index < 0) || (index > 3))
-			index = (int)adev->wep_current_index;
+			index = (int)adev->ieee->sec.active_key;
 
-		dwrq->flags = (adev->wep_restricted == 1) ?
+		dwrq->flags = (adev->ieee->sec.auth_mode == WLAN_AUTH_SHARED_KEY) ?
 				IW_ENCODE_RESTRICTED : IW_ENCODE_OPEN;
-		dwrq->length = adev->wep_keys[index].size;
+		dwrq->length = adev->ieee->sec.key_sizes[index];
 
-		memcpy(extra, adev->wep_keys[index].key,
-			      adev->wep_keys[index].size);
+		memcpy(extra, adev->ieee->sec.keys[index],
+			      adev->ieee->sec.key_sizes[index]);
 	}
 
 	/* set the current index */
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/pci.c wireless-2.6.git.acx/drivers/net/wireless/tiacx/pci.c
--- wireless-2.6.git/drivers/net/wireless/tiacx/pci.c	Thu Feb  2 17:17:50 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/pci.c	Fri Feb  3 13:38:12 2006
@@ -476,23 +476,23 @@ acxpci_s_write_phy_reg(acx_device_t *ade
 **
 ** Arguments:
 **	adev		wlan device structure
-**	apfw_image	firmware image.
+**	fw_image	firmware image.
 **
 ** Returns:
 **	1	firmware image corrupted
 **	0	success
 */
 static int
-acxpci_s_write_fw(acx_device_t *adev, const firmware_image_t *apfw_image, u32 offset)
+acxpci_s_write_fw(acx_device_t *adev, const firmware_image_t *fw_image, u32 offset)
 {
 	int len, size;
 	u32 sum, v32;
 	/* we skip the first four bytes which contain the control sum */
-	const u8 *image = (u8*)apfw_image + 4;
+	const u8 *p = (u8*)fw_image + 4;
 
 	/* start the image checksum by adding the image size value */
-	sum = image[0]+image[1]+image[2]+image[3];
-	image += 4;
+	sum = p[0]+p[1]+p[2]+p[3];
+	p += 4;
 
 	write_reg32(adev, IO_ACX_SLV_END_CTL, 0);
 
@@ -505,12 +505,12 @@ acxpci_s_write_fw(acx_device_t *adev, co
 #endif
 
 	len = 0;
-	size = le32_to_cpu(apfw_image->size) & (~3);
+	size = le32_to_cpu(fw_image->size) & (~3);
 
 	while (likely(len < size)) {
-		v32 = be32_to_cpu(*(u32*)image);
-		sum += image[0]+image[1]+image[2]+image[3];
-		image += 4;
+		v32 = be32_to_cpu(*(u32*)p);
+		sum += p[0]+p[1]+p[2]+p[3];
+		p += 4;
 		len += 4;
 
 #if NO_AUTO_INCREMENT
@@ -521,10 +521,10 @@ acxpci_s_write_fw(acx_device_t *adev, co
 	}
 
 	log(L_DEBUG, "firmware written, size:%d sum1:%x sum2:%x\n",
-			size, sum, le32_to_cpu(apfw_image->chksum));
+			size, sum, le32_to_cpu(fw_image->chksum));
 
 	/* compare our checksum with the stored image checksum */
-	return (sum != le32_to_cpu(apfw_image->chksum));
+	return (sum != le32_to_cpu(fw_image->chksum));
 }
 
 
@@ -536,25 +536,25 @@ acxpci_s_write_fw(acx_device_t *adev, co
 **
 ** Arguments:
 **	adev		wlan device structure
-**   apfw_image  firmware image.
+**   fw_image  firmware image.
 **
 ** Returns:
 **	NOT_OK	firmware image corrupted or not correctly written
 **	OK	success
 */
 static int
-acxpci_s_validate_fw(acx_device_t *adev, const firmware_image_t *apfw_image,
+acxpci_s_validate_fw(acx_device_t *adev, const firmware_image_t *fw_image,
 				u32 offset)
 {
 	u32 sum, v32, w32;
 	int len, size;
 	int result = OK;
 	/* we skip the first four bytes which contain the control sum */
-	const u8 *image = (u8*)apfw_image + 4;
+	const u8 *p = (u8*)fw_image + 4;
 
 	/* start the image checksum by adding the image size value */
-	sum = image[0]+image[1]+image[2]+image[3];
-	image += 4;
+	sum = p[0]+p[1]+p[2]+p[3];
+	p += 4;
 
 	write_reg32(adev, IO_ACX_SLV_END_CTL, 0);
 
@@ -566,11 +566,11 @@ acxpci_s_validate_fw(acx_device_t *adev,
 #endif
 
 	len = 0;
-	size = le32_to_cpu(apfw_image->size) & (~3);
+	size = le32_to_cpu(fw_image->size) & (~3);
 
 	while (likely(len < size)) {
-		v32 = be32_to_cpu(*(u32*)image);
-		image += 4;
+		v32 = be32_to_cpu(*(u32*)p);
+		p += 4;
 		len += 4;
 
 #if NO_AUTO_INCREMENT
@@ -593,7 +593,7 @@ acxpci_s_validate_fw(acx_device_t *adev,
 
 	/* sum control verification */
 	if (result != NOT_OK) {
-		if (sum != le32_to_cpu(apfw_image->chksum)) {
+		if (sum != le32_to_cpu(fw_image->chksum)) {
 			printk("acx: FATAL: firmware upload: "
 				"checksums don't match!\n");
 			result = NOT_OK;
@@ -612,10 +612,10 @@ acxpci_s_validate_fw(acx_device_t *adev,
 static int
 acxpci_s_upload_fw(acx_device_t *adev)
 {
-	firmware_image_t *apfw_image = NULL;
+	firmware_image_t *fw_image = NULL;
 	int res = NOT_OK;
 	int try;
-	u32 size;
+	u32 file_size;
 	char filename[sizeof("tiacx1NNcNN")];
 
 	FN_ENTER;
@@ -625,22 +625,22 @@ acxpci_s_upload_fw(acx_device_t *adev)
 	snprintf(filename, sizeof(filename), "tiacx1%02dc%02X",
 		IS_ACX111(adev)*11, adev->radio_type);
 
-	apfw_image = acx_s_read_fw(&adev->pdev->dev, filename, &size);
-	if (!apfw_image) {
+	fw_image = acx_s_read_fw(&adev->pdev->dev, filename, &file_size);
+	if (!fw_image) {
 		adev->need_radio_fw = 1;
 		filename[sizeof("tiacx1NN")-1] = '\0';
-		apfw_image = acx_s_read_fw(&adev->pdev->dev, filename, &size);
-		if (!apfw_image) {
+		fw_image = acx_s_read_fw(&adev->pdev->dev, filename, &file_size);
+		if (!fw_image) {
 			FN_EXIT1(NOT_OK);
 			return NOT_OK;
 		}
 	}
 
 	for (try = 1; try <= 5; try++) {
-		res = acxpci_s_write_fw(adev, apfw_image, 0);
+		res = acxpci_s_write_fw(adev, fw_image, 0);
 		log(L_DEBUG|L_INIT, "acx_write_fw (main/combined):%d\n", res);
 		if (OK == res) {
-			res = acxpci_s_validate_fw(adev, apfw_image, 0);
+			res = acxpci_s_validate_fw(adev, fw_image, 0);
 			log(L_DEBUG|L_INIT, "acx_validate_fw "
 					"(main/combined):%d\n", res);
 		}
@@ -654,7 +654,7 @@ acxpci_s_upload_fw(acx_device_t *adev)
 		acx_s_msleep(1000); /* better wait for a while... */
 	}
 
-	vfree(apfw_image);
+	vfree(fw_image);
 
 	FN_EXIT1(res);
 	return res;
@@ -930,22 +930,22 @@ acxpci_s_reset_dev(acx_device_t *adev)
 	acx_unlock(adev, flags);
 
 	/* need to know radio type before fw load */
- 	/* Need to wait for arrival of this information in a loop,
- 	 * most probably since eCPU runs some init code from EEPROM
- 	 * (started burst read in reset_mac()) which also
- 	 * sets the radio type ID */
- 
- 	count = 0xffff;
- 	do {
- 		hardware_info = read_reg16(adev, IO_ACX_EEPROM_INFORMATION);
- 		if (!--count) {
- 			msg = "eCPU didn't indicate radio type";
- 			goto end_fail;
- 		}
- 		cpu_relax();
- 	} while (!(hardware_info & 0xff00)); /* radio type still zero? */
- 
- 	/* printk("DEBUG: count %d\n", count); */
+	/* Need to wait for arrival of this information in a loop,
+	 * most probably since eCPU runs some init code from EEPROM
+	 * (started burst read in reset_mac()) which also
+	 * sets the radio type ID */
+
+	count = 0xffff;
+	do {
+		hardware_info = read_reg16(adev, IO_ACX_EEPROM_INFORMATION);
+		if (!--count) {
+			msg = "eCPU didn't indicate radio type";
+			goto end_fail;
+		}
+		cpu_relax();
+	} while (!(hardware_info & 0xff00)); /* radio type still zero? */
+
+	/* printk("DEBUG: count %d\n", count); */
 	adev->form_factor = hardware_info & 0xff;
 	adev->radio_type = hardware_info >> 8;
 
@@ -1641,6 +1641,10 @@ acxpci_e_probe(struct pci_dev *pdev, con
 	adev->softmac = ieee80211_priv(ndev);
 	adev->softmac->set_channel = acx_e_ieee80211_set_chan;
 
+	adev->ieee->sec.encrypt = 0;
+	adev->ieee->sec.enabled = 0;
+	adev->ieee->sec.auth_mode = WLAN_AUTH_OPEN;
+
 #ifdef NONESSENTIAL_FEATURES
 	acx_show_card_eeprom_id(adev);
 #endif /* NONESSENTIAL_FEATURES */
@@ -1668,9 +1672,6 @@ acxpci_e_probe(struct pci_dev *pdev, con
 	if (OK != acxpci_s_reset_dev(adev))
 		goto fail_reset;
 
-	if (OK != acxpci_read_eeprom_byte(adev, 0x05, &adev->eeprom_version))
-		goto fail_read_eeprom_version;
-
 	if (IS_ACX100(adev)) {
 		/* ACX100: configopt struct in cmd mailbox - directly after reset */
 		memcpy_fromio(&co, adev->cmd_area, sizeof(co));
@@ -1728,7 +1729,6 @@ fail_register_netdev:
 	pci_set_drvdata(pdev, NULL);
 
 fail_init_mac:
-fail_read_eeprom_version:
 fail_reset:
 
 	acxpci_s_device_chain_remove(ndev);
diff -urpN wireless-2.6.git/drivers/net/wireless/tiacx/usb.c wireless-2.6.git.acx/drivers/net/wireless/tiacx/usb.c
--- wireless-2.6.git/drivers/net/wireless/tiacx/usb.c	Thu Feb  2 17:17:50 2006
+++ wireless-2.6.git.acx/drivers/net/wireless/tiacx/usb.c	Fri Feb  3 13:54:06 2006
@@ -78,14 +78,25 @@
 
 /***********************************************************************
 */
+/* ACX100 (TNETW1100) USB device: D-Link DWL-120+ */
 #define ACX100_VENDOR_ID 0x2001
 #define ACX100_PRODUCT_ID_UNBOOTED 0x3B01
 #define ACX100_PRODUCT_ID_BOOTED 0x3B00
 
+/* TNETW1450 USB devices */
+#define VENDOR_ID_DLINK		0x07b8 /* D-Link Corp. */
+#define PRODUCT_ID_WUG2400	0xb21a /* AboCom WUG2400 or SafeCom SWLUT-54125 */
+#define VENDOR_ID_AVM_GMBH	0x057c
+#define PRODUCT_ID_AVM_WLAN_USB	0x5601
+#define VENDOR_ID_ZCOM		0x0cde
+#define PRODUCT_ID_ZCOM_XG750	0x0017 /* not tested yet */
+#define VENDOR_ID_TI		0x0451
+#define PRODUCT_ID_TI_UNKNOWN	0x60c5 /* not tested yet */
+
 #define ACX_USB_CTRL_TIMEOUT	5500   /* steps in ms */
 
-/* Buffer size for fw upload */
-#define ACX_USB_RWMEM_MAXLEN	2048
+/* Buffer size for fw upload, same for both ACX100 USB and TNETW1450 */
+#define USB_RWMEM_MAXLEN	2048
 
 /* The number of bulk URBs to use */
 #define ACX_TX_URB_CNT		8
@@ -106,7 +117,7 @@ static void acxusb_i_complete_rx(struct 
 static int acxusb_e_open(struct net_device *);
 static int acxusb_e_close(struct net_device *);
 static void acxusb_i_set_rx_mode(struct net_device *);
-static int acxusb_boot(struct usb_device *);
+static int acxusb_boot(struct usb_device *, int is_tnetw1450, int *radio_type);
 
 static void acxusb_l_poll_rx(acx_device_t *adev, usb_rx_t* rx);
 
@@ -132,6 +143,10 @@ static const struct usb_device_id
 acxusb_ids[] = {
 	{ USB_DEVICE(ACX100_VENDOR_ID, ACX100_PRODUCT_ID_BOOTED) },
 	{ USB_DEVICE(ACX100_VENDOR_ID, ACX100_PRODUCT_ID_UNBOOTED) },
+	{ USB_DEVICE(VENDOR_ID_DLINK, PRODUCT_ID_WUG2400) },
+	{ USB_DEVICE(VENDOR_ID_AVM_GMBH, PRODUCT_ID_AVM_WLAN_USB) },
+	{ USB_DEVICE(VENDOR_ID_ZCOM, PRODUCT_ID_ZCOM_XG750) },
+	{ USB_DEVICE(VENDOR_ID_TI, PRODUCT_ID_TI_UNKNOWN) },
 	{}
 };
 
@@ -443,107 +458,262 @@ bad:
 ** firmware and transmitting the checksum, the device resets and appears
 ** as a new device on the USB bus (the device we can finally deal with)
 */
+static inline int
+acxusb_fw_needs_padding(firmware_image_t *fw_image, unsigned int usb_maxlen)
+{
+	unsigned int num_xfers = ((fw_image->size - 1) / usb_maxlen) + 1;
+
+	return ((num_xfers % 2) == 0);
+}
+
 static int
-acxusb_boot(struct usb_device *usbdev)
+acxusb_boot(struct usb_device *usbdev, int is_tnetw1450, int *radio_type)
 {
-	static const char filename[] = "tiacx100usb";
+	char filename[sizeof("tiacx1NNusbcRR")];
 
-	char *firmware = NULL;
+	firmware_image_t *fw_image = NULL;
 	char *usbbuf;
 	unsigned int offset;
-	unsigned int len, inpipe, outpipe;
-	u32 checksum;
-	u32 size;
-	int result;
+	unsigned int blk_len, inpipe, outpipe;
+	u32 num_processed;
+	u32 img_checksum, sum;
+	u32 file_size;
+	int result = -EIO;
+	int i;
 
 	FN_ENTER;
 
-	usbbuf = kmalloc(ACX_USB_RWMEM_MAXLEN, GFP_KERNEL);
+	/* dump_device(usbdev); */
+
+	usbbuf = kmalloc(USB_RWMEM_MAXLEN, GFP_KERNEL);
 	if (!usbbuf) {
-		printk(KERN_ERR "acx: no memory for USB transfer buffer ("
-			STRING(ACX_USB_RWMEM_MAXLEN)" bytes)\n");
+		printk(KERN_ERR "acx: no memory for USB transfer buffer (%d bytes)\n", USB_RWMEM_MAXLEN);
 		result = -ENOMEM;
 		goto end;
 	}
-	firmware = (char *)acx_s_read_fw(&usbdev->dev, filename, &size);
-	if (!firmware) {
+	if (is_tnetw1450) {
+		/* Obtain the I/O pipes */
+		outpipe = usb_sndbulkpipe(usbdev, 1);
+		inpipe = usb_rcvbulkpipe(usbdev, 2);
+
+		printk(KERN_DEBUG "wait for device ready\n");
+		for (i = 0; i <= 2; i++) {
+			result = usb_bulk_msg(usbdev, inpipe,
+				usbbuf,
+				USB_RWMEM_MAXLEN,
+				&num_processed,
+				2000
+				);
+
+			if ((*(u32 *)&usbbuf[4] == 0x40000001)
+			&& (*(u16 *)&usbbuf[2] == 0x1)
+			&& ((*(u16 *)usbbuf & 0x3fff) == 0)
+			&& ((*(u16 *)usbbuf & 0xc000) == 0xc000))
+				break;
+			msleep(10);
+		}
+		if (i == 2)
+			goto fw_end;
+
+		*radio_type = usbbuf[8];
+	} else {
+		/* Obtain the I/O pipes */
+		outpipe = usb_sndctrlpipe(usbdev, 0);
+		inpipe = usb_rcvctrlpipe(usbdev, 0);
+
+		/* FIXME: shouldn't be hardcoded */
+		*radio_type = RADIO_MAXIM_0D;
+	}
+
+	snprintf(filename, sizeof(filename), "tiacx1%02dusbc%02X",
+				is_tnetw1450 * 11, *radio_type);
+
+	fw_image = acx_s_read_fw(&usbdev->dev, filename, &file_size);
+	if (!fw_image) {
 		result = -EIO;
 		goto end;
 	}
-	log(L_INIT, "firmware size: %d bytes\n", size);
+	log(L_INIT, "firmware size: %d bytes\n", file_size);
 
-	/* Obtain the I/O pipes */
-	outpipe = usb_sndctrlpipe(usbdev, 0);
-	inpipe = usb_rcvctrlpipe(usbdev, 0);
+	img_checksum = le32_to_cpu(fw_image->chksum);
+
+	if (is_tnetw1450) {
+		u8 cmdbuf[20];
+		const u8 *p;
+		u8 need_padding;
+		u32 tmplen, val;
+
+		memset(cmdbuf, 0, 16);
+
+		need_padding = acxusb_fw_needs_padding(fw_image, USB_RWMEM_MAXLEN);
+		tmplen = need_padding ? file_size-4 : file_size-8;
+		*(u16 *)&cmdbuf[0] = 0xc000;
+		*(u16 *)&cmdbuf[2] = 0x000b;
+		*(u32 *)&cmdbuf[4] = tmplen;
+		*(u32 *)&cmdbuf[8] = file_size-8;
+		*(u32 *)&cmdbuf[12] = img_checksum;
+
+		result = usb_bulk_msg(usbdev, outpipe, cmdbuf, 16, &num_processed, HZ);
+		if (result < 0)
+			goto fw_end;
+
+		p = (const u8 *)&fw_image->size;
+
+		/* first calculate checksum for image size part */
+		sum = p[0]+p[1]+p[2]+p[3];
+		p += 4;
+
+		/* now continue checksum for firmware data part */
+		tmplen = le32_to_cpu(fw_image->size);
+		for (i = 0; i < tmplen /* image size */; i++) {
+			sum += *p++;
+		}
+
+		if (sum != le32_to_cpu(fw_image->chksum)) {
+			printk("acx: FATAL: firmware upload: "
+				"checksums don't match! "
+				"(0x%08x vs. 0x%08x)\n",
+					sum, fw_image->chksum);
+			goto fw_end;
+		}
+
+		offset = 8;
+		while (offset < file_size) {
+			blk_len = file_size - offset;
+			if (blk_len > USB_RWMEM_MAXLEN) {
+				blk_len = USB_RWMEM_MAXLEN;
+			}
+
+			log(L_INIT, "uploading firmware (%d bytes, offset=%d)\n",
+							blk_len, offset);
+			memcpy(usbbuf, ((u8 *)fw_image) + offset, blk_len);
+
+			p = usbbuf;
+			for (i = 0; i < blk_len; i += 4) {
+				*(u32 *)p = be32_to_cpu(*(u32 *)p);
+				p += 4;
+			}
 
-	/* now upload the firmware, slice the data into blocks */
-	offset = 8;
-	while (offset < size) {
-		len = size - offset;
-		if (len >= ACX_USB_RWMEM_MAXLEN) {
-			len = ACX_USB_RWMEM_MAXLEN;
+			result = usb_bulk_msg(usbdev, outpipe, usbbuf, blk_len, &num_processed, HZ);
+			if ((result < 0) || (num_processed != blk_len))
+				goto fw_end;
+			offset += blk_len;
+		}
+		if (need_padding) {
+			printk(KERN_DEBUG "send padding\n");
+			memset(usbbuf, 0, 4);
+			result = usb_bulk_msg(usbdev, outpipe, usbbuf, 4, &num_processed, HZ);
+			if ((result < 0) || (num_processed != 4))
+				goto fw_end;
+		}
+		printk(KERN_DEBUG "read firmware upload result\n");
+		memset(cmdbuf, 0, 20); /* additional memset */
+		result = usb_bulk_msg(usbdev, inpipe, cmdbuf, 20, &num_processed, 2000);
+		if (result < 0)
+			goto fw_end;
+		if (*(u32 *)&cmdbuf[4] == 0x40000003)
+			goto fw_end;
+		if (*(u32 *)&cmdbuf[4])
+			goto fw_end;
+		if (*(u16 *)&cmdbuf[16] != 1)
+			goto fw_end;
+
+		val = *(u32 *)&cmdbuf[0];
+		if ((val & 0x3fff)
+		||  ((val & 0xc000) != 0xc000))
+			goto fw_end;
+
+		val = *(u32 *)&cmdbuf[8];
+		if (val & 2) {
+			result = usb_bulk_msg(usbdev, inpipe, cmdbuf, 20, &num_processed, 2000);
+			if (result < 0)
+				goto fw_end;
+			val = *(u32 *)&cmdbuf[8];
+		}
+		/* yup, no "else" here! */
+		if (val & 1) {
+			memset(usbbuf, 0, 4);
+			result = usb_bulk_msg(usbdev, outpipe, usbbuf, 4, &num_processed, HZ);
+			if ((result < 0) || (!num_processed))
+				goto fw_end;
 		}
-		log(L_INIT, "uploading firmware (%d bytes, offset=%d)\n",
-						len, offset);
+
+		printk("TNETW1450 firmware upload successful!\n");
 		result = 0;
-		memcpy(usbbuf, firmware + offset, len);
+		goto end;
+fw_end:
+		result = -EIO;
+		goto end;
+	} else {
+		/* ACX100 USB */
+
+		/* now upload the firmware, slice the data into blocks */
+		offset = 8;
+		while (offset < file_size) {
+			blk_len = file_size - offset;
+			if (blk_len > USB_RWMEM_MAXLEN) {
+				blk_len = USB_RWMEM_MAXLEN;
+			}
+			log(L_INIT, "uploading firmware (%d bytes, offset=%d)\n",
+							blk_len, offset);
+			memcpy(usbbuf, ((u8 *)fw_image) + offset, blk_len);
+			result = usb_control_msg(usbdev, outpipe,
+				ACX_USB_REQ_UPLOAD_FW,
+				USB_TYPE_VENDOR|USB_DIR_OUT,
+				(file_size - 8) & 0xffff, /* value */
+				(file_size - 8) >> 16, /* index */
+				usbbuf, /* dataptr */
+				blk_len, /* size */
+				3000 /* timeout in ms */
+			);
+			offset += blk_len;
+			if (result < 0) {
+				printk(KERN_ERR "acx: error %d during upload "
+					"of firmware, aborting\n", result);
+				goto end;
+			}
+		}
+
+		/* finally, send the checksum and reboot the device */
+		/* does this trigger the reboot? */
 		result = usb_control_msg(usbdev, outpipe,
 			ACX_USB_REQ_UPLOAD_FW,
 			USB_TYPE_VENDOR|USB_DIR_OUT,
-			size - 8, /* value */
-			0, /* index */
+			img_checksum & 0xffff, /* value */
+			img_checksum >> 16, /* index */
+			NULL, /* dataptr */
+			0, /* size */
+			3000 /* timeout in ms */
+		);
+		if (result < 0) {
+			printk(KERN_ERR "acx: error %d during tx of checksum, "
+					"aborting\n", result);
+			goto end;
+		}
+		result = usb_control_msg(usbdev, inpipe,
+			ACX_USB_REQ_ACK_CS,
+			USB_TYPE_VENDOR|USB_DIR_IN,
+			img_checksum & 0xffff, /* value */
+			img_checksum >> 16, /* index */
 			usbbuf, /* dataptr */
-			len, /* size */
+			8, /* size */
 			3000 /* timeout in ms */
 		);
-		offset += len;
 		if (result < 0) {
-			printk(KERN_ERR "acx: error %d during upload "
-				"of firmware, aborting\n", result);
+			printk(KERN_ERR "acx: error %d during ACK of checksum, "
+					"aborting\n", result);
 			goto end;
 		}
+		if (*usbbuf != 0x10) {
+			printk(KERN_ERR "acx: invalid checksum?\n");
+			result = -EINVAL;
+			goto end;
+		}
+		result = 0;
 	}
 
-	/* finally, send the checksum and reboot the device */
-	checksum = le32_to_cpu(*(u32 *)firmware);
-	/* is this triggers the reboot? */
-	result = usb_control_msg(usbdev, outpipe,
-		ACX_USB_REQ_UPLOAD_FW,
-		USB_TYPE_VENDOR|USB_DIR_OUT,
-		checksum & 0xffff, /* value */
-		checksum >> 16, /* index */
-		NULL, /* dataptr */
-		0, /* size */
-		3000 /* timeout in ms */
-	);
-	if (result < 0) {
-		printk(KERN_ERR "acx: error %d during tx of checksum, "
-				"aborting\n", result);
-		goto end;
-	}
-	result = usb_control_msg(usbdev, inpipe,
-		ACX_USB_REQ_ACK_CS,
-		USB_TYPE_VENDOR|USB_DIR_IN,
-		checksum & 0xffff, /* value */
-		checksum >> 16, /* index */
-		usbbuf, /* dataptr */
-		8, /* size */
-		3000 /* timeout in ms */
-	);
-	if (result < 0) {
-		printk(KERN_ERR "acx: error %d during ACK of checksum, "
-				"aborting\n", result);
-		goto end;
-	}
-	if (*usbbuf != 0x10) {
-		kfree(usbbuf);
-		printk(KERN_ERR "acx: invalid checksum?\n");
-		result = -EINVAL;
-		goto end;
-	}
-	result = 0;
 end:
-	vfree(firmware);
+	vfree(fw_image);
 	kfree(usbbuf);
 
 	FN_EXIT1(result);
@@ -551,16 +721,28 @@ end:
 }
 
 
+/* FIXME: maybe merge it with usual eeprom reading, into common code? */
+static void
+acxusb_s_read_eeprom_version(acx_device_t *adev)
+{
+	u8 eeprom_ver[0x8];
+
+	memset(eeprom_ver, 0, sizeof(eeprom_ver));
+	acx_s_interrogate(adev, &eeprom_ver, ACX1FF_IE_EEPROM_VER);
+
+	/* FIXME: which one of those values to take? */
+	adev->eeprom_version = eeprom_ver[5];
+}
+
+
 /*
  * temporary helper function to at least fill important cfgopt members with
  * useful replacement values until we figure out how one manages to fetch
  * the configoption struct in the USB device case...
  */
-int
+static int
 acxusb_s_fill_configoption(acx_device_t *adev)
 {
-	printk("FIXME: haven't figured out how to fetch configoption struct "
-		"from USB device, passing hardcoded values instead\n");
 	adev->cfgopt_probe_delay = 200;
 	adev->cfgopt_dot11CCAModes = 4;
 	adev->cfgopt_dot11Diversity = 1;
@@ -572,6 +754,7 @@ acxusb_s_fill_configoption(acx_device_t 
 	return OK;
 }
 
+
 /***********************************************************************
 ** acxusb_e_probe()
 **
@@ -598,28 +781,41 @@ acxusb_e_probe(struct usb_interface *int
 	int numconfigs, numfaces, numep;
 	int result = OK;
 	int i;
+	int radio_type;
+	/* this one needs to be more precise in case there appears a TNETW1450 from the same vendor */
+	int is_tnetw1450 = (usbdev->descriptor.idVendor != ACX100_VENDOR_ID);
 
 	FN_ENTER;
 
-	/* First check if this is the "unbooted" hardware */
-	if ((usbdev->descriptor.idVendor == ACX100_VENDOR_ID)
-	 && (usbdev->descriptor.idProduct == ACX100_PRODUCT_ID_UNBOOTED)) {
+	if (is_tnetw1450) {
 		/* Boot the device (i.e. upload the firmware) */
-		acxusb_boot(usbdev);
+		acxusb_boot(usbdev, is_tnetw1450, &radio_type);
 
-		/* OK, we are done with booting. Normally, the
-		** ID for the unbooted device should disappear
-		** and it will not need a driver anyway...so
-		** return a NULL
-		*/
-		log(L_INIT, "finished booting, returning from probe()\n");
-		result = OK; /* success */
-		goto end;
-	}
+		/* TNETW1450-based cards will continue right away with
+		 * the same USB ID after booting */
+	} else {
+		/* First check if this is the "unbooted" hardware */
+		if (usbdev->descriptor.idProduct == ACX100_PRODUCT_ID_UNBOOTED) {
 
-	if ((usbdev->descriptor.idVendor != ACX100_VENDOR_ID)
-	 || (usbdev->descriptor.idProduct != ACX100_PRODUCT_ID_BOOTED)) {
-		goto end_nodev;
+			/* Boot the device (i.e. upload the firmware) */
+			acxusb_boot(usbdev, is_tnetw1450, &radio_type);
+
+			/* DWL-120+ will first boot the firmware,
+			 * then later have a *separate* probe() run
+			 * since its USB ID will have changed after
+			 * firmware boot!
+			 * Since the first probe() run has no
+			 * other purpose than booting the firmware,
+			 * simply return immediately.
+			*/
+			log(L_INIT, "finished booting, returning from probe()\n");
+			result = OK; /* success */
+			goto end;
+		}
+		else
+		/* device not unbooted, but invalid USB ID!? */
+		if (usbdev->descriptor.idProduct != ACX100_PRODUCT_ID_BOOTED)
+			goto end_nodev;
 	}
 
 /* Ok, so it's our device and it has already booted */
@@ -656,10 +852,15 @@ acxusb_e_probe(struct usb_interface *int
 	adev->ndev = ndev;
 
 	adev->dev_type = DEVTYPE_USB;
-	adev->chip_type = CHIPTYPE_ACX100;
-
-	/* FIXME: should be read from register (via firmware) using standard ACX code */
-	adev->radio_type = RADIO_MAXIM_0D;
+	adev->radio_type = radio_type;
+	if (is_tnetw1450) {
+		/* well, actually it's a TNETW1450, but since it
+		 * seems to be sufficiently similar to TNETW1130,
+		 * I don't want to change large amounts of code now */
+		adev->chip_type = CHIPTYPE_ACX111;
+	} else {
+		adev->chip_type = CHIPTYPE_ACX100;
+	}
 
 	adev->usbdev = usbdev;
 	spin_lock_init(&adev->lock);    /* initial state: unlocked */
@@ -677,6 +878,10 @@ acxusb_e_probe(struct usb_interface *int
 	adev->softmac = ieee80211_priv(ndev);
 	adev->softmac->set_channel = acx_e_ieee80211_set_chan;
 
+	adev->ieee->sec.enabled = 0;
+	adev->ieee->sec.encrypt = 0;
+	adev->ieee->sec.auth_mode = WLAN_AUTH_OPEN;
+
 	/* Check that this is really the hardware we know about.
 	** If not sure, at least notify the user that he
 	** may be in trouble...
@@ -698,27 +903,32 @@ acxusb_e_probe(struct usb_interface *int
 	numep = ifdesc->bNumEndpoints;
 	log(L_DEBUG, "# of endpoints: %d\n", numep);
 
-	/* obtain information about the endpoint
-	** addresses, begin with some default values
-	*/
-	adev->bulkoutep = 1;
-	adev->bulkinep = 1;
-	for (i = 0; i < numep; i++) {
+	if (is_tnetw1450) {
+		adev->bulkoutep = 1;
+		adev->bulkinep = 2;
+	} else {
+		/* obtain information about the endpoint
+		** addresses, begin with some default values
+		*/
+		adev->bulkoutep = 1;
+		adev->bulkinep = 1;
+		for (i = 0; i < numep; i++) {
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 11)
-		ep = usbdev->ep_in[i];
-		if (!ep)
-			continue;
-		epdesc = &ep->desc;
+			ep = usbdev->ep_in[i];
+			if (!ep)
+				continue;
+			epdesc = &ep->desc;
 #else
-		epdesc = usb_epnum_to_ep_desc(usbdev, i);
-		if (!epdesc)
-			continue;
+			epdesc = usb_epnum_to_ep_desc(usbdev, i);
+			if (!epdesc)
+				continue;
 #endif
-		if (epdesc->bmAttributes & USB_ENDPOINT_XFER_BULK) {
-			if (epdesc->bEndpointAddress & 0x80)
-				adev->bulkinep = epdesc->bEndpointAddress & 0xF;
-			else
-				adev->bulkoutep = epdesc->bEndpointAddress & 0xF;
+			if (epdesc->bmAttributes & USB_ENDPOINT_XFER_BULK) {
+				if (epdesc->bEndpointAddress & 0x80)
+					adev->bulkinep = epdesc->bEndpointAddress & 0xF;
+				else
+					adev->bulkoutep = epdesc->bEndpointAddress & 0xF;
+			}
 		}
 	}
 	log(L_DEBUG, "bulkout ep: 0x%X\n", adev->bulkoutep);
@@ -773,12 +983,13 @@ acxusb_e_probe(struct usb_interface *int
 	/* put acx out of sleep mode and initialize it */
 	acx_s_issue_cmd(adev, ACX1xx_CMD_WAKE, NULL, 0);
 
-	acxusb_s_fill_configoption(adev);
-
 	result = acx_s_init_mac(adev);
 	if (result)
 		goto end;
 
+	/* TODO: see similar code in pci.c */
+	acxusb_s_read_eeprom_version(adev);
+	acxusb_s_fill_configoption(adev);
 	acx_s_set_defaults(adev);
 	acx_s_get_firmware_version(adev);
 	acx_display_hardware_details(adev);
@@ -1622,11 +1833,13 @@ dump_device(struct usb_device *usbdev)
 	/* This saw a change after 2.6.10 */
 	printk("  ep_in wMaxPacketSize: ");
 	for (i = 0; i < 16; ++i)
-		printk("%d ", usbdev->ep_in[i]->desc.wMaxPacketSize);
+		if (usbdev->ep_in[i] != NULL)
+			printk("%d:%d ", i, usbdev->ep_in[i]->desc.wMaxPacketSize);
 	printk("\n");
 	printk("  ep_out wMaxPacketSize: ");
 	for (i = 0; i < VEC_SIZE(usbdev->ep_out); ++i)
-		printk("%d ", usbdev->ep_out[i]->desc.wMaxPacketSize);
+		if (usbdev->ep_out[i] != NULL)
+			printk("%d:%d ", i, usbdev->ep_out[i]->desc.wMaxPacketSize);
 	printk("\n");
 #else
 	printk("  epmaxpacketin: ");

--Boundary-00=_bk04DDjABK7YSTN--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
