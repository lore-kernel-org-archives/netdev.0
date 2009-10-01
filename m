From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH] ethtool: Add reset operation
Date: Thu, 01 Oct 2009 20:43:15 +0100
Message-ID: <1254426195.2735.16.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57768 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbZJATph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 15:45:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After updating firmware stored in flash, users may wish to reset the
relevant hardware and start the new firmware immediately.  This should
not be completely automatic as it may be disruptive.

A selective reset may also be useful for debugging or diagnostics.

This adds a separate reset operation which takes flags indicating the
components to be reset.  Drivers are allowed to reset only a subset of
those requested, and must report the actual subset.  This allows the
use of generic component masks and some future expansion.
---
This is intentionally not signed off yet.

Our new controller has an emebedded management controller shared between
two ports.  We have a customer requirement to be able to update its
firmware in flash and then reboot it into the new firmware under driver
control.

David, you indicated that the proper interface for this is a new ethtool
op and not something specific to sfc.  So I've tried to make this
reasonably generic.

Ben.

 include/linux/ethtool.h |   29 +++++++++++++++++++++++++++++
 net/core/ethtool.c      |   23 +++++++++++++++++++++++
 2 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9cbe5f3..acf0242 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -503,6 +503,7 @@ struct ethtool_ops {
 	int	(*get_rxnfc)(struct net_device *, struct ethtool_rxnfc *, void *);
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
+	int	(*reset)(struct net_device *, u32 *);
 };
 #endif /* __KERNEL__ */
 
@@ -560,6 +561,7 @@ struct ethtool_ops {
 #define	ETHTOOL_SRXCLSRLDEL	0x00000031 /* Delete RX classification rule */
 #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
 #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
+#define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -690,4 +692,31 @@ struct ethtool_ops {
 
 #define	RX_CLS_FLOW_DISC	0xffffffffffffffffULL
 
+/* Reset flags */
+/* The driver must update the flags to indicate which components were
+ * actually reset, which must be equal to or a subset of those requested.
+ */
+enum ethtool_reset_flags {
+	/* These flags represent components dedicated to the interface
+	 * the command is addressed to.  Shift any flag left by
+	 * ETH_RESET_SHARED_SHIFT to reset a shared component of the
+	 * same type.
+	 */
+  	ETH_RESET_MGMT		= 1 << 0,	/* Management processor */
+	ETH_RESET_IRQ		= 1 << 1,	/* Interrupt requester */
+	ETH_RESET_DMA		= 1 << 2,	/* DMA engine */
+	ETH_RESET_FILTER	= 1 << 3,	/* Filtering/flow direction */
+	ETH_RESET_OFFLOAD	= 1 << 4,	/* Protocol offload */
+	ETH_RESET_MAC		= 1 << 5,	/* Media access controller */
+	ETH_RESET_PHY		= 1 << 6,	/* Transceiver/PHY */
+	ETH_RESET_RAM		= 1 << 7,	/* RAM shared between
+						 * multiple components */
+
+	ETH_RESET_DEDICATED	= 0x0000ffff,	/* All components dedicated to
+						 * this interface */
+	ETH_RESET_ALL		= 0xffffffff,	/* All components used by this
+						 * interface, even if shared */
+};
+#define ETH_RESET_SHARED_SHIFT	16
+
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 4c12ddb..6c7429c 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -309,6 +309,26 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 	return ret;
 }
 
+static int ethtool_reset(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value reset;
+	int ret;
+
+	if (!dev->ethtool_ops->reset)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&reset, useraddr, sizeof(reset)))
+		return -EFAULT;
+
+	ret = dev->ethtool_ops->reset(dev, &reset.data);
+	if (ret)
+		return ret;
+
+	if (copy_to_user(useraddr, &reset, sizeof(reset)))
+		return -EFAULT;
+	return 0;
+}
+
 static int ethtool_get_wol(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_wolinfo wol = { ETHTOOL_GWOL };
@@ -1127,6 +1147,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_FLASHDEV:
 		rc = ethtool_flash_device(dev, useraddr);
 		break;
+	case ETHTOOL_RESET:
+		rc = ethtool_reset(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

