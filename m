From: anirban.chakraborty@qlogic.com
Subject: [net-next-2.6 PATCH] ethtool: Support to take FW dump
Date: Mon,  2 May 2011 16:29:17 -0700
Message-ID: <1304378957-24123-2-git-send-email-anirban.chakraborty@qlogic.com>
References: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: --no-chain-reply-to@mv.qlogic.com, bhutchings@solarflare.com,
	davem@davemloft.net,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:35313 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1751600Ab1EBXfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2011 19:35:14 -0400
In-Reply-To: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Added code to take FW dump via ethtool. A pair of set and get functions are
added to configure dump level and fetch it from the driver respectively. A
third function is added to retrieve the dumped FW data from the driver.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 include/linux/ethtool.h |   20 ++++++++++++
 net/core/ethtool.c      |   76 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 96 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9de3127..3dd91a5 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -595,6 +595,19 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
 
+/**
+ * struct ethtool_dump - used for retrieving, setting device dump
+ * @flag: flag for dump setting
+ * @len: length of dump data
+ * @data: data collected for this command
+ */
+struct ethtool_dump {
+	__u32	cmd;
+	__u32	flag;
+	__u32	len;
+	u8	data[0];
+};
+
 /* for returning and changing feature sets */
 
 /**
@@ -926,6 +939,10 @@ struct ethtool_ops {
 				  const struct ethtool_rxfh_indir *);
 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
 	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
+	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
+	int	(*get_dump)(struct net_device *, struct ethtool_dump *);
+	int	(*get_dump_data)(struct net_device *,
+				struct ethtool_dump *, void *);
 
 };
 #endif /* __KERNEL__ */
@@ -997,6 +1014,9 @@ struct ethtool_ops {
 #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
 #define ETHTOOL_GCHANNELS	0x0000003c /* Get no of channels */
 #define ETHTOOL_SCHANNELS	0x0000003d /* Set no of channels */
+#define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
+#define ETHTOOL_GET_DUMP	0x0000003f /* Get dump settings */
+#define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d8b1a8d..dce547c 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1827,6 +1827,73 @@ static noinline_for_stack int ethtool_flash_device(struct net_device *dev,
 	return dev->ethtool_ops->flash_device(dev, &efl);
 }
 
+static int ethtool_set_dump(struct net_device *dev,
+			void __user *useraddr)
+{
+	struct ethtool_dump dump;
+
+	if (!dev->ethtool_ops->set_dump)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&dump, useraddr, sizeof(dump)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_dump(dev, &dump);
+}
+
+static int ethtool_get_dump(struct net_device *dev,
+			void __user *useraddr)
+{
+	struct ethtool_dump dump;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+
+	if (!dev->ethtool_ops->get_dump)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&dump, useraddr, sizeof(dump)))
+		return -EFAULT;
+
+	if (ops->get_dump(dev, &dump))
+		return -EFAULT;
+
+	if (copy_to_user(useraddr, &dump, sizeof(dump)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_get_dump_data(struct net_device *dev,
+				void __user *useraddr)
+{
+	int ret;
+	void *data;
+	struct ethtool_dump dump;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+
+	if (!dev->ethtool_ops->get_dump_data)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&dump, useraddr, sizeof(dump)))
+		return -EFAULT;
+	data = vzalloc(dump.len);
+	if (!data)
+		return -ENOMEM;
+	ret = ops->get_dump_data(dev, &dump, data);
+	if (ret) {
+		ret = -EFAULT;
+		goto out;
+	}
+	if (copy_to_user(useraddr, &dump, sizeof(dump))) {
+		ret = -EFAULT;
+		goto out;
+	}
+	useraddr += offsetof(struct ethtool_dump, data);
+	if (copy_to_user(useraddr, data, dump.len))
+		ret = -EFAULT;
+out:
+	vfree(data);
+	return ret;
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -2043,6 +2110,15 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SCHANNELS:
 		rc = ethtool_set_channels(dev, useraddr);
 		break;
+	case ETHTOOL_SET_DUMP:
+		rc = ethtool_set_dump(dev, useraddr);
+		break;
+	case ETHTOOL_GET_DUMP:
+		rc = ethtool_get_dump(dev, useraddr);
+		break;
+	case ETHTOOL_GET_DUMP_DATA:
+		rc = ethtool_get_dump_data(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.4.1

