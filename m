From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH] core: Add ioctls to control device unicast hw addresses
Date: Tue, 26 Feb 2013 11:59:30 -0500
Message-ID: <1361897970-1728-1-git-send-email-vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61541 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784Ab3BZQ7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2013 11:59:31 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r1QGxVPq027566
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 11:59:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is currently a way to manage the multicast HW address list
through SIOCADDMULTI/SIOCDELMULTI, but there is no way to
consistently manage the unicast list.  Some drivers provide
FDB based interface, but that depends on driver configuration
in almost every case.

This patch provides 2 new ioctls that allow on to add/delete
unicast HW address on a device.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/sockios.h |    4 ++++
 net/core/dev_ioctl.c         |   22 ++++++++++++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
index 7997a50..442360e 100644
--- a/include/uapi/linux/sockios.h
+++ b/include/uapi/linux/sockios.h
@@ -127,6 +127,10 @@
 /* hardware time stamping: parameters in linux/net_tstamp.h */
 #define SIOCSHWTSTAMP   0x89b0
 
+/* Device address management */
+#define SIOCADDHWADDR	0x89c0		/* Unicast address list */
+#define SIOCDELHWADDR	0x8932
+
 /* Device private ioctl calls */
 
 /*
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index 6cc0481..d84f6f9 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -314,6 +314,26 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 		ifr->ifr_newname[IFNAMSIZ-1] = '\0';
 		return dev_change_name(dev, ifr->ifr_newname);
 
+	case SIOCADDHWADDR:
+		if (!ops->ndo_set_rx_mode ||
+		    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
+			return -EINVAL;
+		if (!netif_device_present(dev))
+			return -ENODEV;
+		if (!is_unicast_ether_addr(addr))
+			return -EINVAL;
+		return dev_uc_add_excl(dev, ifr->ifr_hwaddr.sa_data);
+
+	case SIOCDELHWADDR:
+		if (!ops->ndo_set_rx_mode ||
+		    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
+			return -EINVAL;
+		if (!netif_device_present(dev))
+			return -ENODEV;
+		if (!is_unicast_ether_addr(addr))
+			return -EINVAL;
+		return dev_uc_del(dev, ifr->ifr_hwaddr.sa_data);
+
 	case SIOCSHWTSTAMP:
 		err = net_hwtstamp_validate(ifr);
 		if (err)
@@ -532,6 +552,8 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCBRADDIF:
 	case SIOCBRDELIF:
 	case SIOCSHWTSTAMP:
+	case SIOCADDHWADDR:
+	case SIOCDELHWADDR:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 		/* fall through */
-- 
1.7.7.6
