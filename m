From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: [PATCH net-next 3/4] ethtool: Support for configurable RSS hash key.
Date: Fri, 17 Jan 2014 13:02:44 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8E5@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:7144 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbaAQNCp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 08:02:45 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethtool patch primarily copies the ioctl command data structures from/to the User space and invokes the driver hook.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 include/linux/ethtool.h      |    2 ++
 include/uapi/linux/ethtool.h |   19 +++++++++++++++++++
 net/core/ethtool.c           |   40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h index c8e3e7e..2c30fd1 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -227,6 +227,8 @@ struct ethtool_ops {
 	int	(*get_rxnfc)(struct net_device *,
 			     struct ethtool_rxnfc *, u32 *rule_locs);
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
+	int     (*set_rsshkey) (struct net_device *, struct ethtool_rss_hkey *);
+	int     (*get_rsshkey) (struct net_device *, struct ethtool_rss_hkey *);
 	int	(*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
 	u32	(*get_rxfh_indir_size)(struct net_device *);
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h index 38dbafa..f39d82f 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -678,6 +678,22 @@ struct ethtool_rx_ntuple {
 	struct ethtool_rx_ntuple_flow_spec	fs;
 };
 
+
+/**
+ * struct ethtool_rss_hkey - command to set/get RSS hash key of the device.
+ * @cmd: Command number - %ETHTOOL_SET_RSS_HKEY/ETHTOOL_GET_RSS_HKEY
+ * @data: 40 or 16 byte rss hash key
+ * @data_len: rss hash key length
+ */
+
+#define RSS_HASH_KEY_LEN	40
+/* RSS Hash key */
+struct ethtool_rss_hkey {
+	__u32   cmd;            /* ETHTOOL_SET/GET_RSS_HKEY */
+	__u8    data[RSS_HASH_KEY_LEN];
+	__u32	data_len;
+};
+
 #define ETHTOOL_FLASH_MAX_FILENAME	128
 enum ethtool_flash_op_type {
 	ETHTOOL_FLASH_ALL_REGIONS	= 0,
@@ -901,6 +917,9 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
 #define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
 
+#define ETHTOOL_SET_RSS_HKEY	0x00000046 /* Set RSS hash key */
+#define ETHTOOL_GET_RSS_HKEY	0x00000047 /* Get RSS hash key */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c index 30071de..70f68ff 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -501,6 +501,40 @@ static noinline_for_stack int ethtool_set_rxnfc(struct net_device *dev,
 	return 0;
 }
 
+static noinline_for_stack int ethtool_get_rsshkey(struct net_device *dev,
+						  void __user *useraddr)
+{
+	struct ethtool_rss_hkey info;
+	int rc;
+
+	if (!dev->ethtool_ops->get_rsshkey)
+		return -EOPNOTSUPP;
+
+	rc = dev->ethtool_ops->get_rsshkey(dev, &info);
+
+	if (copy_to_user(useraddr, &info, sizeof(info)))
+		rc = -EFAULT;
+
+	return rc;
+}
+
+static noinline_for_stack int ethtool_set_rsshkey(struct net_device *dev,
+						  void __user *useraddr)
+{
+	struct ethtool_rss_hkey info;
+	int rc;
+
+	if (!dev->ethtool_ops->set_rsshkey)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&info, useraddr, sizeof(info)))
+		return -EFAULT;
+
+	rc = dev->ethtool_ops->set_rsshkey(dev, &info);
+
+	return rc;
+}
+
 static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
 						u32 cmd, void __user *useraddr)
 {
@@ -1612,6 +1646,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SRXCLSRLINS:
 		rc = ethtool_set_rxnfc(dev, ethcmd, useraddr);
 		break;
+	case ETHTOOL_GET_RSS_HKEY:
+		rc = ethtool_get_rsshkey(dev, useraddr);
+		break;
+	case ETHTOOL_SET_RSS_HKEY:
+		rc = ethtool_set_rsshkey(dev, useraddr);
+		break;
 	case ETHTOOL_FLASHDEV:
 		rc = ethtool_flash_device(dev, useraddr);
 		break;
--
1.7.1
