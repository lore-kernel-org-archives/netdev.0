From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 12:25:14 -0700
Message-ID: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30868 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751457AbWI1TZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 15:25:41 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is no reason to not allow non-admin users to query network
statistics and settings.


--- linux-2.6.orig/net/core/ethtool.c
+++ linux-2.6/net/core/ethtool.c
@@ -806,13 +806,6 @@ int dev_ethtool(struct ifreq *ifr)
 	int rc;
 	unsigned long old_features;
 
-	/*
-	 * XXX: This can be pushed down into the ethtool_* handlers that
-	 * need it.  Keep existing behaviour for the moment.
-	 */
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	if (!dev || !netif_device_present(dev))
 		return -ENODEV;
 
@@ -822,6 +815,33 @@ int dev_ethtool(struct ifreq *ifr)
 	if (copy_from_user(&ethcmd, useraddr, sizeof (ethcmd)))
 		return -EFAULT;
 
+	/* Allow some commands to be done by anyone */
+	switch(ethcmd) {
+	case ETHTOOL_GSET:
+	case ETHTOOL_GDRVINFO:
+	case ETHTOOL_GREGS:
+	case ETHTOOL_GWOL:
+	case ETHTOOL_GMSGLVL:
+	case ETHTOOL_GLINK:
+	case ETHTOOL_GCOALESCE:
+	case ETHTOOL_GRINGPARAM:
+	case ETHTOOL_GPAUSEPARAM:
+	case ETHTOOL_GRXCSUM:
+	case ETHTOOL_GTXCSUM:
+	case ETHTOOL_GSG:
+	case ETHTOOL_GSTRINGS:
+	case ETHTOOL_PHYS_ID:
+	case ETHTOOL_GSTATS:
+	case ETHTOOL_GTSO:
+	case ETHTOOL_GPERMADDR:
+	case ETHTOOL_GUFO:
+	case ETHTOOL_GGSO:
+		break;
+	default:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+	}
+
 	if(dev->ethtool_ops->begin)
 		if ((rc = dev->ethtool_ops->begin(dev)) < 0)
 			return rc;
@@ -947,6 +967,10 @@ int dev_ethtool(struct ifreq *ifr)
 	return rc;
 
  ioctl:
+	/* Keep existing behaviour for the moment.	 */
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (dev->do_ioctl)
 		return dev->do_ioctl(dev, ifr, SIOCETHTOOL);
 	return -EOPNOTSUPP;
