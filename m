From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 1/4 (V3)] net: ethtool: add the EEE support
Date: Fri,  6 Apr 2012 11:29:15 +0200
Message-ID: <1333704559-11251-2-git-send-email-peppe.cavallaro@st.com>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, rayagond@vayavyalabs.com,
	davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:48326 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755072Ab2DFJ3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 05:29:46 -0400
In-Reply-To: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds two new functions to detect if Energy-Efficient
Ethernet (EEE) is supported and the way to enable/disable it.

As Ben said, it is certainly necessary to distinguish:

a. PHY is advertising EEE from
b. Link partner is advertising EEE
or
c. EEE will be used (= a && b)

The logic behind this code, is that .get_eee will pass
to the user-space if the EEE is actually used and available (so point c).
The .set_eee should used to force the MAC to disable/enable the EEE (if
actually supported by MAC+PHY).
I have also added the .set_eee because the Synopsys GMAC manages the TX LPI
path through a SW timer that in this case can be disabled via ethtool.
Indeed, no action should be taken by the user for the PHY side.
Maybe, the only thing that could be changed is the clock stop enable bit
(3.0.10).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    6 ++++++
 net/core/ethtool.c      |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 560a247..d0150c8 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -920,6 +920,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @get_ts_info: Get the time stamping and PTP hardware clock capabilities.
  *	Drivers supporting transmit time stamps in software should set this to
  *	ethtool_op_get_ts_info().
+ * @get_eee: Get Energy-Efficient Ethernet (EEE) supported and status.
+ * @set_eee: Set EEE status (enable/disable).
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -984,6 +986,8 @@ struct ethtool_ops {
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
 	int	(*get_ts_info)(struct net_device *, struct ethtool_ts_info *);
 
+	int	(*get_eee) (struct net_device *, struct ethtool_value *);
+	int	(*set_eee) (struct net_device *, struct ethtool_value *);
 };
 #endif /* __KERNEL__ */
 
@@ -1058,6 +1062,8 @@ struct ethtool_ops {
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
 #define ETHTOOL_GET_TS_INFO	0x00000041 /* Get time stamping and PHC info */
+#define ETHTOOL_GEEE		0x00000042 /* Get EEE */
+#define ETHTOOL_SEEE		0x00000043 /* Set EEE */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index beacdd9..c2374f9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -729,6 +729,32 @@ static int ethtool_set_wol(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_wol(dev, &wol);
 }
 
+static int ethtool_get_eee(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->ethtool_ops->get_eee)
+		return -EOPNOTSUPP;
+
+	dev->ethtool_ops->get_eee(dev, &edata);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_eee(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->ethtool_ops->set_eee)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_eee(dev, &edata);
+}
 static int ethtool_nway_reset(struct net_device *dev)
 {
 	if (!dev->ethtool_ops->nway_reset)
@@ -1420,6 +1446,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		rc = ethtool_set_value_void(dev, useraddr,
 				       dev->ethtool_ops->set_msglevel);
 		break;
+	case ETHTOOL_GEEE:
+		rc = ethtool_get_eee(dev, useraddr);
+		break;
+	case ETHTOOL_SEEE:
+		rc = ethtool_set_eee(dev, useraddr);
+		break;
 	case ETHTOOL_NWAY_RST:
 		rc = ethtool_nway_reset(dev);
 		break;
-- 
1.7.4.4
