From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCHv3 net-next-2.6] ethtool: Added support for FW dump
Date: Wed, 11 May 2011 15:54:05 -0700
Message-ID: <1305154448-9687-2-git-send-email-anirban.chakraborty@qlogic.com>
References: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:60147 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1756490Ab1EKXA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 19:00:28 -0400
In-Reply-To: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added code to take FW dump via ethtool. Dump level can be controlled via setting the
dump flag. A get function is provided to query the current setting of the dump flag.
Dump data is obtained from the driver via a separate get function.

Changes from v2:
Provided separate commands for get flag and data.
Check for minimum of the two buffer length obtained via ethtool and driver and
use that for dump buffer
Pass up the driver return error codes up to the caller.
Added kernel doc comments.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 include/linux/ethtool.h |   28 +++++++++++++++
 net/core/ethtool.c      |   88 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 116 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index bd0b50b..5ac7e18 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -601,6 +601,24 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
 
+/**
+ * struct ethtool_dump - used for retrieving, setting device dump
+ * @cmd: Command number - %ETHTOOL_GET_DUMP_FLAG, %ETHTOOL_GET_DUMP_DATA, or
+ * 	%ETHTOOL_SET_DUMP
+ * @version: FW version of the dump, filled in by driver
+ * @flag: driver dependent flag for dump setting, filled in by driver during
+ * 	  get and filled in by ethtool for set operation
+ * @len: length of dump data, returned by driver for get operation
+ * @data: data collected for get dump data operation
+ */
+struct ethtool_dump {
+	__u32	cmd;
+	__u32	version;
+	__u32	flag;
+	__u32	len;
+	u8	data[0];
+};
+
 /* for returning and changing feature sets */
 
 /**
@@ -853,6 +871,9 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
  * @get_channels: Get number of channels.
  * @set_channels: Set number of channels.  Returns a negative error code or
  *	zero.
+ * @get_dump_flag: Get dump flag indicating current dump settings of the device.
+ * @get_dump_data: Get dump data.
+ * @set_dump: Set dump specific flags to the device.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -927,6 +948,10 @@ struct ethtool_ops {
 				  const struct ethtool_rxfh_indir *);
 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
 	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
+	int	(*get_dump_flag)(struct net_device *, struct ethtool_dump *);
+	int	(*get_dump_data)(struct net_device *,
+				 struct ethtool_dump *, void *);
+	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
 
 };
 #endif /* __KERNEL__ */
@@ -998,6 +1023,9 @@ struct ethtool_ops {
 #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
 #define ETHTOOL_GCHANNELS	0x0000003c /* Get no of channels */
 #define ETHTOOL_SCHANNELS	0x0000003d /* Set no of channels */
+#define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
+#define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
+#define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b6f4058..01819d8 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1823,6 +1823,85 @@ static noinline_for_stack int ethtool_flash_device(struct net_device *dev,
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
+static int ethtool_get_dump_flag(struct net_device *dev,
+				void __user *useraddr)
+{
+	int ret;
+	struct ethtool_dump dump;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+
+	if (!dev->ethtool_ops->get_dump_flag)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&dump, useraddr, sizeof(dump)))
+		return -EFAULT;
+
+	ret = ops->get_dump_flag(dev, &dump);
+	if (ret)
+		return ret;
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
+	__u32 len;
+	struct ethtool_dump dump, tmp;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	void *data = NULL;
+
+	if (!dev->ethtool_ops->get_dump_data ||
+		!dev->ethtool_ops->get_dump_flag)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&dump, useraddr, sizeof(dump)))
+		return -EFAULT;
+
+	memset(&tmp, 0, sizeof(tmp));
+	tmp.cmd = dump.cmd;
+	ret = ops->get_dump_flag(dev, &tmp);
+	if (ret)
+		return ret;
+
+	len = (tmp.len > dump.len) ? dump.len : tmp.len;
+
+	data = vzalloc(len);
+	if (!data)
+		return -ENOMEM;
+	ret = ops->get_dump_data(dev, &dump, data);
+	if (ret)
+		goto out;
+
+	if (copy_to_user(useraddr, &dump, sizeof(dump))) {
+		ret = -EFAULT;
+		goto out;
+	}
+	useraddr += offsetof(struct ethtool_dump, data);
+	if (copy_to_user(useraddr, data, len))
+		ret = -EFAULT;
+out:
+	vfree(data);
+	return ret;
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -2039,6 +2118,15 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SCHANNELS:
 		rc = ethtool_set_channels(dev, useraddr);
 		break;
+	case ETHTOOL_SET_DUMP:
+		rc = ethtool_set_dump(dev, useraddr);
+		break;
+	case ETHTOOL_GET_DUMP_FLAG:
+		rc = ethtool_get_dump_flag(dev, useraddr);
+		break;
+	case ETHTOOL_GET_DUMP_DATA:
+		rc = ethtool_get_dump_data(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.4.1

