From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH v4] ethtool: Add direct access to ops->get_sset_count
Date: Thu, 04 Mar 2010 00:51:50 -0800
Message-ID: <20100304085054.4471.44679.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:35238
	"EHLO qmta05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752575Ab0CDIwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:52:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@redhat.com>

This patch is an alternative approach for accessing string
counts, vs. the drvinfo indirect approach.  This way the drvinfo
space doesn't run out, and we don't break ABI later.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/ethtool.h |   17 +++++++++--
 net/core/ethtool.c      |   72 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 86 insertions(+), 3 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index cca1c3d..f6f961f 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -253,6 +253,17 @@ struct ethtool_gstrings {
 	__u8	data[0];
 };
 
+struct ethtool_sset_info {
+	__u32	cmd;		/* ETHTOOL_GSSET_INFO */
+	__u32	reserved;
+	__u64	sset_mask;	/* input: each bit selects an sset to query */
+				/* output: each bit a returned sset */
+	__u32	data[0];	/* ETH_SS_xxx count, in order, based on bits
+				   in sset_mask.  One bit implies one
+				   __u32, two bits implies two
+				   __u32's, etc. */
+};
+
 enum ethtool_test_flags {
 	ETH_TEST_FL_OFFLINE	= (1 << 0),	/* online / offline */
 	ETH_TEST_FL_FAILED	= (1 << 1),	/* test passed / failed */
@@ -606,9 +617,9 @@ struct ethtool_ops {
 #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
 #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
-
-#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
-#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+#define	ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
+#define	ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+#define	ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 0f2f821..70075c4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -214,6 +214,10 @@ static noinline int ethtool_get_drvinfo(struct net_device *dev, void __user *use
 	info.cmd = ETHTOOL_GDRVINFO;
 	ops->get_drvinfo(dev, &info);
 
+	/*
+	 * this method of obtaining string set info is deprecated;
+	 * consider using ETHTOOL_GSSET_INFO instead
+	 */
 	if (ops->get_sset_count) {
 		int rc;
 
@@ -240,6 +244,71 @@ static noinline int ethtool_get_drvinfo(struct net_device *dev, void __user *use
 /*
  * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
  */
+static noinline int ethtool_get_sset_info(struct net_device *dev,
+                                          void __user *useraddr)
+{
+	struct ethtool_sset_info info;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	u64 sset_mask;
+	int i, idx = 0, n_bits = 0, ret, rc;
+	u32 *info_buf = NULL;
+
+	if (!ops->get_sset_count)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&info, useraddr, sizeof(info)))
+		return -EFAULT;
+
+	/* store copy of mask, because we zero struct later on */
+	sset_mask = info.sset_mask;
+	if (!sset_mask)
+		return 0;
+
+	/* calculate size of return buffer */
+	for (i = 0; i < 64; i++)
+		if (sset_mask & (1ULL << i))
+			n_bits++;
+
+	memset(&info, 0, sizeof(info));
+	info.cmd = ETHTOOL_GSSET_INFO;
+
+	info_buf = kzalloc(n_bits * sizeof(u32), GFP_USER);
+	if (!info_buf)
+		return -ENOMEM;
+
+	/*
+	 * fill return buffer based on input bitmask and successful
+	 * get_sset_count return
+	 */
+	for (i = 0; i < 64; i++) {
+		if (!(sset_mask & (1ULL << i)))
+			continue;
+
+		rc = ops->get_sset_count(dev, i);
+		if (rc >= 0) {
+			info.sset_mask |= (1ULL << i);
+			info_buf[idx++] = rc;
+		}
+	}
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &info, sizeof(info)))
+		goto out;
+
+	useraddr += offsetof(struct ethtool_sset_info, data);
+	if (copy_to_user(useraddr, info_buf, idx * sizeof(u32)))
+		goto out;
+
+	ret = 0;
+
+out:
+	kfree(info_buf);
+	return ret;
+}
+
+/*
+ * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
+ */
 static noinline int ethtool_set_rxnfc(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rxnfc cmd;
@@ -1471,6 +1540,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GRXNTUPLE:
 		rc = ethtool_get_rx_ntuple(dev, useraddr);
 		break;
+	case ETHTOOL_GSSET_INFO:
+		rc = ethtool_get_sset_info(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}

