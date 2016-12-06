From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 1/2] ethtool: Add set regs -D option support
Date: Wed,  7 Dec 2016 00:33:09 +0200
Message-ID: <1481063590-7727-2-git-send-email-saeedm@mellanox.com>
References: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org,
        "John W . Linville" <linville@tuxdriver.com>,
        Gal Pressman <galp@mellanox.com>,
        Dmitry Teif <dimat@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54081 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751563AbcLFWdv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 17:33:51 -0500
In-Reply-To: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Currently ethtool only allows us to get device registers, in this patch
we extend this functionality to also set device registers.
ethtool -D DEVNAME [ file FILENAME ] is used to set registers in
the device using vendor specific binary registers data provided via
stdin/file. Changes made by this option can be queried using get
regs -d flag.

Example:
$ ethtool -D eth1 file /tmp/mlx5_regs

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Dmitry Teif <dimat@mellanox.com>
CC: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/ethtool.h      |  1 +
 include/uapi/linux/ethtool.h |  1 +
 net/core/ethtool.c           | 31 +++++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9ded8c6..c9f5d37 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -305,6 +305,7 @@ struct ethtool_ops {
 	void	(*get_drvinfo)(struct net_device *, struct ethtool_drvinfo *);
 	int	(*get_regs_len)(struct net_device *);
 	void	(*get_regs)(struct net_device *, struct ethtool_regs *, void *);
+	int	(*set_regs)(struct net_device *, struct ethtool_regs *, u8 *);
 	void	(*get_wol)(struct net_device *, struct ethtool_wolinfo *);
 	int	(*set_wol)(struct net_device *, struct ethtool_wolinfo *);
 	u32	(*get_msglevel)(struct net_device *);
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index f0db778..f81c6fd 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1330,6 +1330,7 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
 #define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
 #define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
+#define ETHTOOL_SREGS		0x00000050 /* Set NIC registers */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index e23766c..5548565 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1424,6 +1424,34 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 	return ret;
 }
 
+static int ethtool_set_regs(struct net_device *dev, char __user *useraddr)
+{
+	void __user *userbuf = useraddr + offsetof(struct ethtool_regs, data);
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct ethtool_regs regs;
+	int ret = 0;
+	u8 *data;
+
+	if (!ops->set_regs || !ops->get_regs_len)
+		return -EOPNOTSUPP;
+	if (copy_from_user(&regs, useraddr, sizeof(regs)))
+		return -EFAULT;
+
+	data = kmalloc(PAGE_SIZE, GFP_USER);
+	if (!data)
+		return -ENOMEM;
+
+	ret = -EFAULT;
+	if (copy_from_user(data, userbuf, regs.len))
+		goto out;
+
+	ret = ops->set_regs(dev, &regs, data);
+
+out:
+	kfree(data);
+	return ret;
+}
+
 static int ethtool_reset(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value reset;
@@ -2597,6 +2625,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GREGS:
 		rc = ethtool_get_regs(dev, useraddr);
 		break;
+	case ETHTOOL_SREGS:
+		rc = ethtool_set_regs(dev, useraddr);
+		break;
 	case ETHTOOL_GWOL:
 		rc = ethtool_get_wol(dev, useraddr);
 		break;
-- 
2.7.4
