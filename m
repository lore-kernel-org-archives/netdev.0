From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH net-next] ethtool: Allow drivers to select RX NFC rule
 locations
Date: Sat, 17 Dec 2011 01:18:03 +0000
Message-ID: <1324084683.2798.45.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:15777 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752599Ab1LQBSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 20:18:07 -0500
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
This change is sufficient to allow for conversion of sfc to implementing
the RX NFC operations.  I don't know whether anything more would be
necessary for other hardware/drivers.  The ethtool_ops::set_rx_ntuple
operation would then be removed, as there will be no in-tree
implementations.

In order for userland to make use of the special location values and
reliably fallback to userland allocation, drivers must properly
range-check location values.  gianfar wasn't doing this, and as a result
it also didn't properly limit the total number of rules.  I hope the fix
for that can go into stable updates and userland can then ignore the old
versions of gianfar.

I'll post the ethtool changes as a follow-up.  If anyone would like to
see the changes to sfc at this stage, I can post them too.

Ben.

 include/linux/ethtool.h |   21 ++++++++++++++++++++-
 net/core/ethtool.c      |   11 ++++++++++-
 net/socket.c            |    2 +-
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index b38bf69..1c003d4 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -501,10 +501,23 @@ struct ethtool_rx_flow_spec {
  * must use the second parameter to get_rxnfc() instead of @rule_locs.
  *
  * For %ETHTOOL_SRXCLSRLINS, @fs specifies the rule to add or update.
- * @fs.@location specifies the location to use and must not be ignored.
+ * @fs.@location either specifies the location to use or is a special
+ * location value with %RX_CLS_LOC_SPECIAL flag set.  Drivers do not
+ * have to support special location values but must return -%EINVAL if
+ * passed an unsupported value.  On return, @fs.@location is the
+ * actual rule location.
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
@@ -1141,6 +1154,12 @@ struct ethtool_ops {
 
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


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
