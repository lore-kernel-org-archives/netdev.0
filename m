From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 4/4] ethtool: internal simplification
Date: Fri, 10 Aug 2007 16:26:54 -0400
Message-ID: <20070810202654.GC25095@havoc.gtf.org>
References: <20070810202426.GA25050@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:43078 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966029AbXHJU0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:26:55 -0400
Content-Disposition: inline
In-Reply-To: <20070810202426.GA25050@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 758522226b3e7758a84e721998bce8f63855caca
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Aug 10 16:17:09 2007 -0400

    [ETHTOOL] Internal cleanup of ethtool_value-related handlers
    
    Several get/set functions can be handled by a passing the ethtool_op
    function pointer directly to a generic function.  This permits deletion
    of a fair bit of redundant code.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

 net/core/ethtool.c |  199 ++++++++++-------------------------------------------
 1 file changed, 39 insertions(+), 160 deletions(-)

758522226b3e7758a84e721998bce8f63855caca
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f721e38..4559200 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -272,34 +272,6 @@ static int ethtool_set_wol(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_wol(dev, &wol);
 }
 
-static int ethtool_get_msglevel(struct net_device *dev, char __user *useraddr)
-{
-	struct ethtool_value edata = { ETHTOOL_GMSGLVL };
-
-	if (!dev->ethtool_ops->get_msglevel)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_msglevel(dev);
-
-	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		return -EFAULT;
-	return 0;
-}
-
-static int ethtool_set_msglevel(struct net_device *dev, char __user *useraddr)
-{
-	struct ethtool_value edata;
-
-	if (!dev->ethtool_ops->set_msglevel)
-		return -EOPNOTSUPP;
-
-	if (copy_from_user(&edata, useraddr, sizeof(edata)))
-		return -EFAULT;
-
-	dev->ethtool_ops->set_msglevel(dev, edata.data);
-	return 0;
-}
-
 static int ethtool_nway_reset(struct net_device *dev)
 {
 	if (!dev->ethtool_ops->nway_reset)
@@ -308,20 +280,6 @@ static int ethtool_nway_reset(struct net_device *dev)
 	return dev->ethtool_ops->nway_reset(dev);
 }
 
-static int ethtool_get_link(struct net_device *dev, void __user *useraddr)
-{
-	struct ethtool_value edata = { ETHTOOL_GLINK };
-
-	if (!dev->ethtool_ops->get_link)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_link(dev);
-
-	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		return -EFAULT;
-	return 0;
-}
-
 static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_eeprom eeprom;
@@ -489,48 +447,6 @@ static int ethtool_set_pauseparam(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_pauseparam(dev, &pauseparam);
 }
 
-static int ethtool_get_rx_csum(struct net_device *dev, char __user *useraddr)
-{
-	struct ethtool_value edata = { ETHTOOL_GRXCSUM };
-
-	if (!dev->ethtool_ops->get_rx_csum)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_rx_csum(dev);
-
-	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		return -EFAULT;
-	return 0;
-}
-
-static int ethtool_set_rx_csum(struct net_device *dev, char __user *useraddr)
-{
-	struct ethtool_value edata;
-
-	if (!dev->ethtool_ops->set_rx_csum)
-		return -EOPNOTSUPP;
-
-	if (copy_from_user(&edata, useraddr, sizeof(edata)))
-		return -EFAULT;
-
-	dev->ethtool_ops->set_rx_csum(dev, edata.data);
-	return 0;
-}
-
-static int ethtool_get_tx_csum(struct net_device *dev, char __user *useraddr)
-{
-	struct ethtool_value edata = { ETHTOOL_GTXCSUM };
-
-	if (!dev->ethtool_ops->get_tx_csum)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_tx_csum(dev);
-
-	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		return -EFAULT;
-	return 0;
-}
-
 static int __ethtool_set_sg(struct net_device *dev, u32 data)
 {
 	int err;
@@ -569,20 +485,6 @@ static int ethtool_set_tx_csum(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_tx_csum(dev, edata.data);
 }
 
-static int ethtool_get_sg(struct net_device *dev, char __user *useraddr)
-{
-	struct ethtool_value edata = { ETHTOOL_GSG };
-
-	if (!dev->ethtool_ops->get_sg)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_sg(dev);
-
-	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		return -EFAULT;
-	return 0;
-}
-
 static int ethtool_set_sg(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata;
@@ -600,20 +502,6 @@ static int ethtool_set_sg(struct net_device *dev, char __user *useraddr)
 	return __ethtool_set_sg(dev, edata.data);
 }
 
-static int ethtool_get_tso(struct net_device *dev, char __user *useraddr)
-{
-	struct ethtool_value edata = { ETHTOOL_GTSO };
-
-	if (!dev->ethtool_ops->get_tso)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_tso(dev);
-
-	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		return -EFAULT;
-	return 0;
-}
-
 static int ethtool_set_tso(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata;
@@ -630,18 +518,6 @@ static int ethtool_set_tso(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_tso(dev, edata.data);
 }
 
-static int ethtool_get_ufo(struct net_device *dev, char __user *useraddr)
-{
-	struct ethtool_value edata = { ETHTOOL_GUFO };
-
-	if (!dev->ethtool_ops->get_ufo)
-		return -EOPNOTSUPP;
-	edata.data = dev->ethtool_ops->get_ufo(dev);
-	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		 return -EFAULT;
-	return 0;
-}
-
 static int ethtool_set_ufo(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata;
@@ -857,58 +733,48 @@ static int ethtool_get_perm_addr(struct net_device *dev, void __user *useraddr)
 	return 0;
 }
 
-static int ethtool_get_flags(struct net_device *dev, char __user *useraddr)
+static int ethtool_get_value(struct net_device *dev, char __user *useraddr,
+			     u32 cmd, u32 (*actor)(struct net_device *))
 {
-	struct ethtool_value edata = { ETHTOOL_GFLAGS };
+	struct ethtool_value edata = { cmd };
 
-	if (!dev->ethtool_ops->get_flags)
+	if (!actor)
 		return -EOPNOTSUPP;
 
-	edata.data = dev->ethtool_ops->get_flags(dev);
+	edata.data = actor(dev);
 
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
 		return -EFAULT;
 	return 0;
 }
 
-static int ethtool_set_flags(struct net_device *dev, char __user *useraddr)
+static int ethtool_set_value_void(struct net_device *dev, char __user *useraddr,
+			     void (*actor)(struct net_device *, u32))
 {
 	struct ethtool_value edata;
 
-	if (!dev->ethtool_ops->set_flags)
+	if (!actor)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
 
-	return dev->ethtool_ops->set_flags(dev, edata.data);
-}
-
-static int ethtool_get_priv_flags(struct net_device *dev, char __user *useraddr)
-{
-	struct ethtool_value edata = { ETHTOOL_GPFLAGS };
-
-	if (!dev->ethtool_ops->get_priv_flags)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_priv_flags(dev);
-
-	if (copy_to_user(useraddr, &edata, sizeof(edata)))
-		return -EFAULT;
+	actor(dev, edata.data);
 	return 0;
 }
 
-static int ethtool_set_priv_flags(struct net_device *dev, char __user *useraddr)
+static int ethtool_set_value(struct net_device *dev, char __user *useraddr,
+			     int (*actor)(struct net_device *, u32))
 {
 	struct ethtool_value edata;
 
-	if (!dev->ethtool_ops->set_priv_flags)
+	if (!actor)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
 
-	return dev->ethtool_ops->set_priv_flags(dev, edata.data);
+	return actor(dev, edata.data);
 }
 
 /* The main entry point in this file.  Called from net/core/dev.c */
@@ -979,16 +845,19 @@ int dev_ethtool(struct ifreq *ifr)
 		rc = ethtool_set_wol(dev, useraddr);
 		break;
 	case ETHTOOL_GMSGLVL:
-		rc = ethtool_get_msglevel(dev, useraddr);
+		rc = ethtool_get_value(dev, useraddr, ethcmd,
+				       dev->ethtool_ops->get_msglevel);
 		break;
 	case ETHTOOL_SMSGLVL:
-		rc = ethtool_set_msglevel(dev, useraddr);
+		rc = ethtool_set_value_void(dev, useraddr,
+				       dev->ethtool_ops->set_msglevel);
 		break;
 	case ETHTOOL_NWAY_RST:
 		rc = ethtool_nway_reset(dev);
 		break;
 	case ETHTOOL_GLINK:
-		rc = ethtool_get_link(dev, useraddr);
+		rc = ethtool_get_value(dev, useraddr, ethcmd,
+				       dev->ethtool_ops->get_link);
 		break;
 	case ETHTOOL_GEEPROM:
 		rc = ethtool_get_eeprom(dev, useraddr);
@@ -1015,25 +884,30 @@ int dev_ethtool(struct ifreq *ifr)
 		rc = ethtool_set_pauseparam(dev, useraddr);
 		break;
 	case ETHTOOL_GRXCSUM:
-		rc = ethtool_get_rx_csum(dev, useraddr);
+		rc = ethtool_get_value(dev, useraddr, ethcmd,
+				       dev->ethtool_ops->get_rx_csum);
 		break;
 	case ETHTOOL_SRXCSUM:
-		rc = ethtool_set_rx_csum(dev, useraddr);
+		rc = ethtool_set_value(dev, useraddr,
+				       dev->ethtool_ops->set_rx_csum);
 		break;
 	case ETHTOOL_GTXCSUM:
-		rc = ethtool_get_tx_csum(dev, useraddr);
+		rc = ethtool_get_value(dev, useraddr, ethcmd,
+				       dev->ethtool_ops->get_tx_csum);
 		break;
 	case ETHTOOL_STXCSUM:
 		rc = ethtool_set_tx_csum(dev, useraddr);
 		break;
 	case ETHTOOL_GSG:
-		rc = ethtool_get_sg(dev, useraddr);
+		rc = ethtool_get_value(dev, useraddr, ethcmd,
+				       dev->ethtool_ops->get_sg);
 		break;
 	case ETHTOOL_SSG:
 		rc = ethtool_set_sg(dev, useraddr);
 		break;
 	case ETHTOOL_GTSO:
-		rc = ethtool_get_tso(dev, useraddr);
+		rc = ethtool_get_value(dev, useraddr, ethcmd,
+				       dev->ethtool_ops->get_tso);
 		break;
 	case ETHTOOL_STSO:
 		rc = ethtool_set_tso(dev, useraddr);
@@ -1054,7 +928,8 @@ int dev_ethtool(struct ifreq *ifr)
 		rc = ethtool_get_perm_addr(dev, useraddr);
 		break;
 	case ETHTOOL_GUFO:
-		rc = ethtool_get_ufo(dev, useraddr);
+		rc = ethtool_get_value(dev, useraddr, ethcmd,
+				       dev->ethtool_ops->get_ufo);
 		break;
 	case ETHTOOL_SUFO:
 		rc = ethtool_set_ufo(dev, useraddr);
@@ -1066,16 +941,20 @@ int dev_ethtool(struct ifreq *ifr)
 		rc = ethtool_set_gso(dev, useraddr);
 		break;
 	case ETHTOOL_GFLAGS:
-		rc = ethtool_get_flags(dev, useraddr);
+		rc = ethtool_get_value(dev, useraddr, ethcmd,
+				       dev->ethtool_ops->get_flags);
 		break;
 	case ETHTOOL_SFLAGS:
-		rc = ethtool_set_flags(dev, useraddr);
+		rc = ethtool_set_value(dev, useraddr,
+				       dev->ethtool_ops->set_flags);
 		break;
 	case ETHTOOL_GPFLAGS:
-		rc = ethtool_get_priv_flags(dev, useraddr);
+		rc = ethtool_get_value(dev, useraddr, ethcmd,
+				       dev->ethtool_ops->get_priv_flags);
 		break;
 	case ETHTOOL_SPFLAGS:
-		rc = ethtool_set_priv_flags(dev, useraddr);
+		rc = ethtool_set_value(dev, useraddr,
+				       dev->ethtool_ops->set_priv_flags);
 		break;
 	default:
 		rc = -EOPNOTSUPP;
