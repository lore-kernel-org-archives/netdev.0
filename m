From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: [PATCH 2/3] ethtool: Update ethtool-copy.h to support module eeprom
 retrieval
Date: Fri, 18 May 2012 15:58:36 +0100
Message-ID: <4FB6639C.9090901@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Yaniv Rosner <yanivr@broadcom.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58880 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752394Ab2ERO6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 10:58:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
---
 ethtool-copy.h |   72 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 70 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d904c1a..9e26a76 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -27,10 +27,15 @@ struct ethtool_cmd {
 				 * access it */
 	__u8	duplex;		/* Duplex, half or full */
 	__u8	port;		/* Which connector port */
-	__u8	phy_address;
+	__u8	phy_address;	/* MDIO PHY address (PRTAD for clause 45).
+				 * May be read-only or read-write
+				 * depending on the driver.
+				 */
 	__u8	transceiver;	/* Which transceiver to use */
 	__u8	autoneg;	/* Enable or disable autonegotiation */
-	__u8	mdio_support;
+	__u8	mdio_support;	/* MDIO protocols supported.  Read-only.
+				 * Not set by all drivers.
+				 */
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;       /* The forced speed (upper
@@ -56,6 +61,20 @@ static __inline__ __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 	return (ep->speed_hi << 16) | ep->speed;
 }
 
+/* Device supports clause 22 register access to PHY or peripherals
+ * using the interface defined in <linux/mii.h>.  This should not be
+ * set if there are known to be no such peripherals present or if
+ * the driver only emulates clause 22 registers for compatibility.
+ */
+#define ETH_MDIO_SUPPORTS_C22	1
+
+/* Device supports clause 45 register access to PHY or peripherals
+ * using the interface defined in <linux/mii.h> and <linux/mdio.h>.
+ * This should not be set if there are known to be no such peripherals
+ * present.
+ */
+#define ETH_MDIO_SUPPORTS_C45	2
+
 #define ETHTOOL_FWVERS_LEN	32
 #define ETHTOOL_BUSINFO_LEN	32
 /* these strings are set to whatever the driver author decides... */
@@ -115,6 +134,23 @@ struct ethtool_eeprom {
 };
 
 /**
+ * struct ethtool_modinfo - plugin module eeprom information
+ * @cmd: %ETHTOOL_GMODULEINFO
+ * @type: Standard the module information conforms to %ETH_MODULE_SFF_xxxx
+ * @eeprom_len: Length of the eeprom
+ *
+ * This structure is used to return the information to
+ * properly size memory for a subsequent call to %ETHTOOL_GMODULEEEPROM.
+ * The type code indicates the eeprom data format
+ */
+struct ethtool_modinfo {
+	__u32   cmd;
+	__u32   type;
+	__u32   eeprom_len;
+	__u32   reserved[8];
+};
+
+/**
  * struct ethtool_coalesce - coalescing parameters for IRQs and stats updates
  * @cmd: ETHTOOL_{G,S}COALESCE
  * @rx_coalesce_usecs: How many usecs to delay an RX interrupt after
@@ -680,6 +716,29 @@ struct ethtool_sfeatures {
 	struct ethtool_set_features_block features[0];
 };
 
+/**
+ * struct ethtool_ts_info - holds a device's timestamping and PHC association
+ * @cmd: command number = %ETHTOOL_GET_TS_INFO
+ * @so_timestamping: bit mask of the sum of the supported SO_TIMESTAMPING flags
+ * @phc_index: device index of the associated PHC, or -1 if there is none
+ * @tx_types: bit mask of the supported hwtstamp_tx_types enumeration values
+ * @rx_filters: bit mask of the supported hwtstamp_rx_filters enumeration values
+ *
+ * The bits in the 'tx_types' and 'rx_filters' fields correspond to
+ * the 'hwtstamp_tx_types' and 'hwtstamp_rx_filters' enumeration values,
+ * respectively.  For example, if the device supports HWTSTAMP_TX_ON,
+ * then (1 << HWTSTAMP_TX_ON) in 'tx_types' will be set.
+ */
+struct ethtool_ts_info {
+	__u32	cmd;
+	__u32	so_timestamping;
+	__s32	phc_index;
+	__u32	tx_types;
+	__u32	tx_reserved[3];
+	__u32	rx_filters;
+	__u32	rx_reserved[3];
+};
+
 /*
  * %ETHTOOL_SFEATURES changes features present in features[].valid to the
  * values of corresponding bits in features[].requested. Bits in .requested
@@ -786,6 +845,9 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
+#define ETHTOOL_GMODULEINFO	0x00000042 /* Get plug-in module information */
+#define ETHTOOL_GMODULEEEPROM	0x00000043 /* Get plug-in module eeprom */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -935,6 +997,12 @@ enum ethtool_sfeatures_retval_bits {
 #define RX_CLS_LOC_FIRST	0xfffffffe
 #define RX_CLS_LOC_LAST		0xfffffffd
 
+/* EEPROM Standards for plug in modules */
+#define ETH_MODULE_SFF_8079		0x1
+#define ETH_MODULE_SFF_8079_LEN		256
+#define ETH_MODULE_SFF_8472		0x2
+#define ETH_MODULE_SFF_8472_LEN		512
+
 /* Reset flags */
 /* The reset() operation must clear the flags for the components which
  * were actually reset.  On successful return, the flags indicate the
-- 
1.7.7.6
