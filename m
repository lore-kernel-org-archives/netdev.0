From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/2] ethtool-copy.h: sync with net-next
Date: Sat, 17 Dec 2011 01:27:08 +0000
Message-ID: <1324085228.2798.47.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15907 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752745Ab1LQB1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 20:27:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers kernel changes up to:

commit XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Mon Sep 5 21:53:10 2011 +0100

    ethtool: Allow drivers to select RX NFC rule locations

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool-copy.h |   33 ++++++++++++++++++++++++++++++---
 1 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 8342ade..7fb0c3b 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -498,10 +498,23 @@ struct ethtool_rx_flow_spec {
  * must use the second parameter to get_rxnfc() instead of @rule_locs.
  *
  * For %ETHTOOL_SRXCLSRLINS, @fs specifies the rule to add or update.
- * @fs.@location specifies the location to use and must not be ignored.
+ * @fs.@location either specifies the location to use or is a special
+ * location value with %RX_CLS_LOC_SPECIAL flag set.  Drivers do not
+ * have to support special location values but must report an error
+ * for an unsupported value.  On return, @fs.@location is the actual
+ * rule location.
  *
  * For %ETHTOOL_SRXCLSRLDEL, @fs.@location specifies the location of an
  * existing rule on entry.
+ *
+ * A driver supporting the special location values for
+ * %ETHTOOL_SRXCLSRLINS may add the rule at any suitable unused
+ * location, and may remove a rule at a later location (lower
+ * priority) that matches exactly the same set of flows.  The special
+ * values are: %RX_CLS_LOC_ANY, selecting any location;
+ * %RX_CLS_LOC_FIRST, selecting the first suitable location (maximum
+ * priority); and %RX_CLS_LOC_LAST, selecting the last suitable
+ * location (minimum priority).
  */
 struct ethtool_rxnfc {
 	__u32				cmd;
@@ -516,9 +529,15 @@ struct ethtool_rxnfc {
 /**
  * struct ethtool_rxfh_indir - command to get or set RX flow hash indirection
  * @cmd: Specific command number - %ETHTOOL_GRXFHINDIR or %ETHTOOL_SRXFHINDIR
- * @size: On entry, the array size of the user buffer.  On return from
- *	%ETHTOOL_GRXFHINDIR, the array size of the hardware indirection table.
+ * @size: On entry, the array size of the user buffer, which may be zero.
+ *	On return from %ETHTOOL_GRXFHINDIR, the array size of the hardware
+ *	indirection table.
  * @ring_index: RX ring/queue index for each hash value
+ *
+ * For %ETHTOOL_GRXFHINDIR, a @size of zero means that only the size
+ * should be returned.  For %ETHTOOL_SRXFHINDIR, a @size of zero means
+ * the table should be reset to default values.  This last feature
+ * is not supported by the original implementations.
  */
 struct ethtool_rxfh_indir {
 	__u32	cmd;
@@ -831,10 +850,12 @@ enum ethtool_sfeatures_retval_bits {
 #define SPEED_1000		1000
 #define SPEED_2500		2500
 #define SPEED_10000		10000
+#define SPEED_UNKNOWN		-1
 
 /* Duplex, half or full. */
 #define DUPLEX_HALF		0x00
 #define DUPLEX_FULL		0x01
+#define DUPLEX_UNKNOWN		0xff
 
 /* Which connector port. */
 #define PORT_TP			0x00
@@ -905,6 +926,12 @@ enum ethtool_sfeatures_retval_bits {
 
 #define	RX_CLS_FLOW_DISC	0xffffffffffffffffULL
 
+/* Special RX classification rule insert location values */
+#define RX_CLS_LOC_SPECIAL	0x80000000	/* flag */
+#define RX_CLS_LOC_ANY		0xffffffff
+#define RX_CLS_LOC_FIRST	0xfffffffe
+#define RX_CLS_LOC_LAST		0xfffffffd
+
 /* Reset flags */
 /* The reset() operation must clear the flags for the components which
  * were actually reset.  On successful return, the flags indicate the
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
