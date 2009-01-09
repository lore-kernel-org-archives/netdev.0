From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Fri, 09 Jan 2009 00:03:57 -0500
Message-ID: <4966DABD.1000203@pobox.com>
References: <20090109041952.GA12087@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050200040405080602080802"
Cc: bhutchings@solarflare.com, rick.jones2@hp.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59323 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbZAIFEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 00:04:08 -0500
In-Reply-To: <20090109041952.GA12087@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050200040405080602080802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Jeff Garzik <jgarzik@pobox.com> wrote:
>> For generic net stack flags outside the driver's control, that can 
>> easily be added to ethtool_{get,set}_flags() overriding or ignoring 
>> whatever the driver may have done.
> 
> To use the flags interface as is, you'd have to go through every
> single driver to get them to call ethtool_op_set_flags.  I'm sorry
> but I'm sticking with the current interface.

I think you misunderstand.  You don't have touch any drivers at all... 
see attached demonstration patch.

The more general point is that it is silly to add two ethtool ioctls 
each time you want to twiddle a single boolean flag (whatever that flag 
may be, generic or driver-specific or whatnot).

If you still desire separation from ->{get,set}_flags() ops, then at 
least create an ETHTOOL_[GS]STACK_FLAGS.

	Jeff




--------------050200040405080602080802
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 27c67a5..75fab70 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -285,6 +285,7 @@ struct ethtool_perm_addr {
  */
 enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
+	ETH_FLAG_GRO		= (1 << 14),	/* GRO is enabled */
 };
 
 struct ethtool_rxnfc {
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 947710a..a114afa 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -864,6 +864,60 @@ static int ethtool_set_value(struct net_device *dev, char __user *useraddr,
 	return actor(dev, edata.data);
 }
 
+static int ethtool_get_generic_flags(struct net_device *dev, u32 *val_out)
+{
+	if (dev->features & NETIF_F_GRO)
+		*val_out |= ETH_FLAG_GRO;
+
+	return 0;
+}
+
+static int ethtool_set_generic_flags(struct net_device *dev, u32 val_in)
+{
+	if (val_in & ETH_FLAG_GRO) {
+		if (!dev->ethtool_ops->get_rx_csum ||
+		    !dev->ethtool_ops->get_rx_csum(dev))
+			return -EINVAL;
+		dev->features |= NETIF_F_GRO;
+	} else
+		dev->features &= ~NETIF_F_GRO;
+
+	return 0;
+}
+
+static int ethtool_get_flags(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GFLAGS };
+	int rc;
+
+	if (dev->ethtool_ops->get_flags)
+		edata.data = dev->ethtool_ops->get_flags(dev);
+
+	rc = ethtool_get_generic_flags(dev, &edata.data);
+	if (rc)
+		return rc;
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_flags(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+	int rc;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	rc = ethtool_set_generic_flags(dev, edata.data);
+
+	if (rc == 0 && dev->ethtool_ops->set_flags)
+		rc = dev->ethtool_ops->set_flags(dev, edata.data);
+
+	return rc;
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1036,12 +1090,10 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		rc = ethtool_set_gso(dev, useraddr);
 		break;
 	case ETHTOOL_GFLAGS:
-		rc = ethtool_get_value(dev, useraddr, ethcmd,
-				       dev->ethtool_ops->get_flags);
+		rc = ethtool_get_flags(dev, useraddr);
 		break;
 	case ETHTOOL_SFLAGS:
-		rc = ethtool_set_value(dev, useraddr,
-				       dev->ethtool_ops->set_flags);
+		rc = ethtool_set_flags(dev, useraddr);
 		break;
 	case ETHTOOL_GPFLAGS:
 		rc = ethtool_get_value(dev, useraddr, ethcmd,

--------------050200040405080602080802--
