From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/3] ethtool-copy.h: sync with net-next-2.6
Date: Mon, 21 Feb 2011 16:57:41 +0000
Message-ID: <1298307461.2608.48.camel@bwh-desktop>
References: <1298307282.2608.47.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56760 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756130Ab1BUQ5o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 11:57:44 -0500
In-Reply-To: <1298307282.2608.47.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers kernel changes up to:

commit e83d360d9a7e5d71d55c13e96b19109a2ea23bf0
Author: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Date:   Tue Feb 15 16:59:18 2011 +0000

    net: introduce NETIF_F_RXCSUM

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool-copy.h |   89 ++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++-
 1 files changed, 88 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 75c3ae7..6430dbd 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -251,6 +251,7 @@ enum ethtool_stringset {
 	ETH_SS_STATS,
 	ETH_SS_PRIV_FLAGS,
 	ETH_SS_NTUPLE_FILTERS,
+	ETH_SS_FEATURES,
 };
=20
 /* for passing string sets for data tagging */
@@ -523,6 +524,87 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
=20
+/* for returning and changing feature sets */
+
+/**
+ * struct ethtool_get_features_block - block with state of 32 features
+ * @available: mask of changeable features
+ * @requested: mask of features requested to be enabled if possible
+ * @active: mask of currently enabled features
+ * @never_changed: mask of features not changeable for any device
+ */
+struct ethtool_get_features_block {
+	__u32	available;
+	__u32	requested;
+	__u32	active;
+	__u32	never_changed;
+};
+
+/**
+ * struct ethtool_gfeatures - command to get state of device's feature=
s
+ * @cmd: command number =3D %ETHTOOL_GFEATURES
+ * @size: in: number of elements in the features[] array;
+ *       out: number of elements in features[] needed to hold all feat=
ures
+ * @features: state of features
+ */
+struct ethtool_gfeatures {
+	__u32	cmd;
+	__u32	size;
+	struct ethtool_get_features_block features[0];
+};
+
+/**
+ * struct ethtool_set_features_block - block with request for 32 featu=
res
+ * @valid: mask of features to be changed
+ * @requested: values of features to be changed
+ */
+struct ethtool_set_features_block {
+	__u32	valid;
+	__u32	requested;
+};
+
+/**
+ * struct ethtool_sfeatures - command to request change in device's fe=
atures
+ * @cmd: command number =3D %ETHTOOL_SFEATURES
+ * @size: array size of the features[] array
+ * @features: feature change masks
+ */
+struct ethtool_sfeatures {
+	__u32	cmd;
+	__u32	size;
+	struct ethtool_set_features_block features[0];
+};
+
+/*
+ * %ETHTOOL_SFEATURES changes features present in features[].valid to =
the
+ * values of corresponding bits in features[].requested. Bits in .requ=
ested
+ * not set in .valid or not changeable are ignored.
+ *
+ * Returns %EINVAL when .valid contains undefined or never-changable b=
its
+ * or size is not equal to required number of features words (32-bit b=
locks).
+ * Returns >=3D 0 if request was completed; bits set in the value mean=
:
+ *   %ETHTOOL_F_UNSUPPORTED - there were bits set in .valid that are n=
ot
+ *	changeable (not present in %ETHTOOL_GFEATURES' features[].available=
)
+ *	those bits were ignored.
+ *   %ETHTOOL_F_WISH - some or all changes requested were recorded but=
 the
+ *      resulting state of bits masked by .valid is not equal to .requ=
ested.
+ *      Probably there are other device-specific constraints on some f=
eatures
+ *      in the set. When %ETHTOOL_F_UNSUPPORTED is set, .valid is cons=
idered
+ *      here as though ignored bits were cleared.
+ *
+ * Meaning of bits in the masks are obtained by %ETHTOOL_GSSET_INFO (n=
umber of
+ * bits in the arrays - always multiple of 32) and %ETHTOOL_GSTRINGS c=
ommands
+ * for ETH_SS_FEATURES string set. First entry in the table correspond=
s to least
+ * significant bit in features[0] fields. Empty strings mark undefined=
 features.
+ */
+enum ethtool_sfeatures_retval_bits {
+	ETHTOOL_F_UNSUPPORTED__BIT,
+	ETHTOOL_F_WISH__BIT,
+};
+
+#define ETHTOOL_F_UNSUPPORTED   (1 << ETHTOOL_F_UNSUPPORTED__BIT)
+#define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
+
=20
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
@@ -534,7 +616,9 @@ struct ethtool_flash {
 #define ETHTOOL_GMSGLVL		0x00000007 /* Get driver message level */
 #define ETHTOOL_SMSGLVL		0x00000008 /* Set driver msg level. */
 #define ETHTOOL_NWAY_RST	0x00000009 /* Restart autonegotiation. */
-#define ETHTOOL_GLINK		0x0000000a /* Get link status (ethtool_value) *=
/
+/* Get link status for host, i.e. whether the interface *and* the
+ * physical port (if there is one) are up (ethtool_value). */
+#define ETHTOOL_GLINK		0x0000000a
 #define ETHTOOL_GEEPROM		0x0000000b /* Get EEPROM data */
 #define ETHTOOL_SEEPROM		0x0000000c /* Set EEPROM data. */
 #define ETHTOOL_GCOALESCE	0x0000000e /* Get coalesce config */
@@ -585,6 +669,9 @@ struct ethtool_flash {
 #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n tabl=
e */
 #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n tabl=
e */
=20
+#define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
+#define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings=
 */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
--=20
1.7.3.4



--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

