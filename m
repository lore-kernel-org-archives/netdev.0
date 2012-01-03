From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next 2/8] ethtool: Allow drivers to select RX NFC
 rule locations
Date: Tue, 3 Jan 2012 22:04:51 +0000
Message-ID: <1325628291.2832.38.camel@bwh-desktop>
References: <1325627819.2832.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36862 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754957Ab2ACWEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:04:55 -0500
In-Reply-To: <1325627819.2832.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define special location values for RX NFC that request the driver to
select the actual rule location.  This allows for implementation on
devices that use hash-based filter lookup, whereas currently the API is
more suited to devices with TCAM lookup or linear search.

In ethtool_set_rxnfc() and the compat wrapper ethtool_ioctl(), copy
the structure back to user-space after insertion so that the actual
location is returned.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Drivers are now required to report that they recognise special location
values and userland is expected to check this before using them.  This
should allow me to use them in the ethtool utility without breaking
compatibility with the current gianfar driver.

Ben.

 include/linux/ethtool.h |   26 ++++++++++++++++++++++++--
 net/core/ethtool.c      |   11 ++++++++++-
 net/socket.c            |    2 +-
 3 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index b38bf69..d901714 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -489,7 +489,10 @@ struct ethtool_rx_flow_spec {
  * on return.
  *
  * For %ETHTOOL_GRXCLSRLCNT, @rule_cnt is set to the number of defined
- * rules on return.
+ * rules on return.  If @data is non-zero on return then it is the
+ * size of the rule table, plus the flag %RX_CLS_LOC_SPECIAL if the
+ * driver supports any special location values.  If that flag is not
+ * set in @data then special location values should not be used.
  *
  * For %ETHTOOL_GRXCLSRULE, @fs.@location specifies the location of an
  * existing rule on entry and @fs contains the rule on return.
@@ -501,10 +504,23 @@ struct ethtool_rx_flow_spec {
  * must use the second parameter to get_rxnfc() instead of @rule_locs.
  *
  * For %ETHTOOL_SRXCLSRLINS, @fs specifies the rule to add or update.
- * @fs.@location specifies the location to use and must not be ignored.
+ * @fs.@location either specifies the location to use or is a special
+ * location value with %RX_CLS_LOC_SPECIAL flag set.  On return,
+ * @fs.@location is the actual rule location.
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
+ * location (minimum priority).  Additional special values may be
+ * defined in future and drivers must return -%EINVAL for any
+ * unrecognised value.
  */
 struct ethtool_rxnfc {
 	__u32				cmd;
@@ -1141,6 +1157,12 @@ struct ethtool_ops {
 
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
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 597732c..e88b80d 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -439,6 +439,7 @@ static noinline_for_stack int ethtool_set_rxnfc(struct net_device *dev,
 {
 	struct ethtool_rxnfc info;
 	size_t info_size = sizeof(info);
+	int rc;
 
 	if (!dev->ethtool_ops->set_rxnfc)
 		return -EOPNOTSUPP;
@@ -454,7 +455,15 @@ static noinline_for_stack int ethtool_set_rxnfc(struct net_device *dev,
 	if (copy_from_user(&info, useraddr, info_size))
 		return -EFAULT;
 
-	return dev->ethtool_ops->set_rxnfc(dev, &info);
+	rc = dev->ethtool_ops->set_rxnfc(dev, &info);
+	if (rc)
+		return rc;
+
+	if (cmd == ETHTOOL_SRXCLSRLINS &&
+	    copy_to_user(useraddr, &info, info_size))
+		return -EFAULT;
+
+	return 0;
 }
 
 static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
diff --git a/net/socket.c b/net/socket.c
index e62b4f0..2cad581 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2758,10 +2758,10 @@ static int ethtool_ioctl(struct net *net, struct compat_ifreq __user *ifr32)
 	case ETHTOOL_GRXRINGS:
 	case ETHTOOL_GRXCLSRLCNT:
 	case ETHTOOL_GRXCLSRULE:
+	case ETHTOOL_SRXCLSRLINS:
 		convert_out = true;
 		/* fall through */
 	case ETHTOOL_SRXCLSRLDEL:
-	case ETHTOOL_SRXCLSRLINS:
 		buf_size += sizeof(struct ethtool_rxnfc);
 		convert_in = true;
 		break;
-- 
1.7.4.4
