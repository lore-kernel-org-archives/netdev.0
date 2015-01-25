From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH ethtool 1/5] ethtool-copy.h: sync with net
Date: Sun, 25 Jan 2015 15:51:19 +0200
Message-ID: <1422193883-30504-2-git-send-email-amirv@mellanox.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:55309 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753260AbbAYNvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2015 08:51:39 -0500
In-Reply-To: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Grossman <eyalgr@mellanox.com>

This covers kernel changes up to:

commit 892311f66f2411b813ca631009356891a0c2b0a1
Author: Eyal Perry <eyalpe@mellanox.com>
Date:   Tue Dec 2 18:12:10 2014 +0200

	ethtool: Support for configurable RSS hash function

Signed-off-by: Eyal Grossman <eyalgr@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 ethtool-copy.h | 67 +++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 59 insertions(+), 8 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 61b78fc..5f66d9c 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -10,8 +10,8 @@
  * Portions Copyright (C) Sun Microsystems 2008
  */
 
-#ifndef _LINUX_ETHTOOL_H
-#define _LINUX_ETHTOOL_H
+#ifndef _UAPI_LINUX_ETHTOOL_H
+#define _UAPI_LINUX_ETHTOOL_H
 
 #include <linux/types.h>
 #include <linux/if_ether.h>
@@ -110,7 +110,7 @@ struct ethtool_cmd {
 	__u32	reserved[2];
 };
 
-static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
+static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 					 __u32 speed)
 {
 
@@ -118,7 +118,7 @@ static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
-static __inline__ __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
+static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 {
 	return (ep->speed_hi << 16) | ep->speed;
 }
@@ -209,6 +209,33 @@ struct ethtool_value {
 	__u32	data;
 };
 
+enum tunable_id {
+	ETHTOOL_ID_UNSPEC,
+	ETHTOOL_RX_COPYBREAK,
+	ETHTOOL_TX_COPYBREAK,
+};
+
+enum tunable_type_id {
+	ETHTOOL_TUNABLE_UNSPEC,
+	ETHTOOL_TUNABLE_U8,
+	ETHTOOL_TUNABLE_U16,
+	ETHTOOL_TUNABLE_U32,
+	ETHTOOL_TUNABLE_U64,
+	ETHTOOL_TUNABLE_STRING,
+	ETHTOOL_TUNABLE_S8,
+	ETHTOOL_TUNABLE_S16,
+	ETHTOOL_TUNABLE_S32,
+	ETHTOOL_TUNABLE_S64,
+};
+
+struct ethtool_tunable {
+	__u32	cmd;
+	__u32	id;
+	__u32	type_id;
+	__u32	len;
+	void	*data[0];
+};
+
 /**
  * struct ethtool_regs - hardware register dump
  * @cmd: Command number = %ETHTOOL_GREGS
@@ -507,6 +534,7 @@ struct ethtool_pauseparam {
  * @ETH_SS_NTUPLE_FILTERS: Previously used with %ETHTOOL_GRXNTUPLE;
  *	now deprecated
  * @ETH_SS_FEATURES: Device feature names
+ * @ETH_SS_RSS_HASH_FUNCS: RSS hush function names
  */
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -514,6 +542,7 @@ enum ethtool_stringset {
 	ETH_SS_PRIV_FLAGS,
 	ETH_SS_NTUPLE_FILTERS,
 	ETH_SS_FEATURES,
+	ETH_SS_RSS_HASH_FUNCS,
 };
 
 /**
@@ -857,6 +886,8 @@ struct ethtool_rxfh_indir {
  * @key_size: On entry, the array size of the user buffer for the hash key,
  *	which may be zero.  On return from %ETHTOOL_GRSSH, the size of the
  *	hardware hash key.
+ * @hfunc: Defines the current RSS hash function used by HW (or to be set to).
+ *	Valid values are one of the %ETH_RSS_HASH_*.
  * @rsvd:	Reserved for future extensions.
  * @rss_config: RX ring/queue index for each hash value i.e., indirection table
  *	of @indir_size __u32 elements, followed by hash key of @key_size
@@ -866,14 +897,16 @@ struct ethtool_rxfh_indir {
  * size should be returned.  For %ETHTOOL_SRSSH, an @indir_size of
  * %ETH_RXFH_INDIR_NO_CHANGE means that indir table setting is not requested
  * and a @indir_size of zero means the indir table should be reset to default
- * values.
+ * values. An hfunc of zero means that hash function setting is not requested.
  */
 struct ethtool_rxfh {
 	__u32   cmd;
 	__u32	rss_context;
 	__u32   indir_size;
 	__u32   key_size;
-	__u32	rsvd[2];
+	__u8	hfunc;
+	__u8	rsvd8[3];
+	__u32	rsvd32;
 	__u32   rss_config[0];
 };
 #define ETH_RXFH_INDIR_NO_CHANGE	0xffffffff
@@ -1152,6 +1185,8 @@ enum ethtool_sfeatures_retval_bits {
 
 #define ETHTOOL_GRSSH		0x00000046 /* Get RX flow hash configuration */
 #define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
+#define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
+#define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1184,6 +1219,10 @@ enum ethtool_sfeatures_retval_bits {
 #define SUPPORTED_40000baseCR4_Full	(1 << 24)
 #define SUPPORTED_40000baseSR4_Full	(1 << 25)
 #define SUPPORTED_40000baseLR4_Full	(1 << 26)
+#define SUPPORTED_56000baseKR4_Full	(1 << 27)
+#define SUPPORTED_56000baseCR4_Full	(1 << 28)
+#define SUPPORTED_56000baseSR4_Full	(1 << 29)
+#define SUPPORTED_56000baseLR4_Full	(1 << 30)
 
 #define ADVERTISED_10baseT_Half		(1 << 0)
 #define ADVERTISED_10baseT_Full		(1 << 1)
@@ -1212,6 +1251,10 @@ enum ethtool_sfeatures_retval_bits {
 #define ADVERTISED_40000baseCR4_Full	(1 << 24)
 #define ADVERTISED_40000baseSR4_Full	(1 << 25)
 #define ADVERTISED_40000baseLR4_Full	(1 << 26)
+#define ADVERTISED_56000baseKR4_Full	(1 << 27)
+#define ADVERTISED_56000baseCR4_Full	(1 << 28)
+#define ADVERTISED_56000baseSR4_Full	(1 << 29)
+#define ADVERTISED_56000baseLR4_Full	(1 << 30)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
@@ -1219,12 +1262,16 @@ enum ethtool_sfeatures_retval_bits {
  * it was forced up into this mode or autonegotiated.
  */
 
-/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE. */
+/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|10|20|40|56]GbE. */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
 #define SPEED_2500		2500
 #define SPEED_10000		10000
+#define SPEED_20000		20000
+#define SPEED_40000		40000
+#define SPEED_56000		56000
+
 #define SPEED_UNKNOWN		-1
 
 /* Duplex, half or full. */
@@ -1314,6 +1361,10 @@ enum ethtool_sfeatures_retval_bits {
 #define ETH_MODULE_SFF_8079_LEN		256
 #define ETH_MODULE_SFF_8472		0x2
 #define ETH_MODULE_SFF_8472_LEN		512
+#define ETH_MODULE_SFF_8636		0x3
+#define ETH_MODULE_SFF_8636_LEN		256
+#define ETH_MODULE_SFF_8436		0x4
+#define ETH_MODULE_SFF_8436_LEN		256
 
 /* Reset flags */
 /* The reset() operation must clear the flags for the components which
@@ -1345,4 +1396,4 @@ enum ethtool_reset_flags {
 };
 #define ETH_RESET_SHARED_SHIFT	16
 
-#endif /* _LINUX_ETHTOOL_H */
+#endif /* _UAPI_LINUX_ETHTOOL_H */
-- 
1.9.3
