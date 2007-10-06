From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] net/core: split dev_ifsioc() according to locking
Date: Sat, 6 Oct 2007 16:42:12 -0400
Message-ID: <20071006204212.GA32177@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:34539 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761393AbXJFUmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2007 16:42:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This always bugged me:  dev_ioctl() called dev_ifsioc() either inside
read_lock(dev_base_lock) or rtnl_lock(), depending on the ioctl being
executed.

This change moves the ioctls executed inside dev_base_lock to a new
function, dev_ifsioc_locked().  Now the locking context is completely
clear to the reader.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 net/core/dev.c |   88 +++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 58 insertions(+), 30 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d998646..ea57527 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3083,9 +3083,9 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 }
 
 /*
- *	Perform the SIOCxIFxxx calls.
+ *	Perform the SIOCxIFxxx calls, inside read_lock(dev_base_lock)
  */
-static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
+static int dev_ifsioc_locked(struct net *net, struct ifreq *ifr, unsigned int cmd)
 {
 	int err;
 	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
@@ -3098,25 +3098,15 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			ifr->ifr_flags = dev_get_flags(dev);
 			return 0;
 
-		case SIOCSIFFLAGS:	/* Set interface flags */
-			return dev_change_flags(dev, ifr->ifr_flags);
-
 		case SIOCGIFMETRIC:	/* Get the metric on the interface
 					   (currently unused) */
 			ifr->ifr_metric = 0;
 			return 0;
 
-		case SIOCSIFMETRIC:	/* Set the metric on the interface
-					   (currently unused) */
-			return -EOPNOTSUPP;
-
 		case SIOCGIFMTU:	/* Get the MTU of a device */
 			ifr->ifr_mtu = dev->mtu;
 			return 0;
 
-		case SIOCSIFMTU:	/* Set the MTU of a device */
-			return dev_set_mtu(dev, ifr->ifr_mtu);
-
 		case SIOCGIFHWADDR:
 			if (!dev->addr_len)
 				memset(ifr->ifr_hwaddr.sa_data, 0, sizeof ifr->ifr_hwaddr.sa_data);
@@ -3126,6 +3116,61 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			ifr->ifr_hwaddr.sa_family = dev->type;
 			return 0;
 
+		case SIOCGIFSLAVE:
+			err = -EINVAL;
+			break;
+
+		case SIOCGIFMAP:
+			ifr->ifr_map.mem_start = dev->mem_start;
+			ifr->ifr_map.mem_end   = dev->mem_end;
+			ifr->ifr_map.base_addr = dev->base_addr;
+			ifr->ifr_map.irq       = dev->irq;
+			ifr->ifr_map.dma       = dev->dma;
+			ifr->ifr_map.port      = dev->if_port;
+			return 0;
+
+		case SIOCGIFINDEX:
+			ifr->ifr_ifindex = dev->ifindex;
+			return 0;
+
+		case SIOCGIFTXQLEN:
+			ifr->ifr_qlen = dev->tx_queue_len;
+			return 0;
+
+		default:
+			/* dev_ioctl() should ensure this case
+			 * is never reached
+			 */
+			WARN_ON(1);
+			err = -EINVAL;
+			break;
+
+	}
+	return err;
+}
+
+/*
+ *	Perform the SIOCxIFxxx calls, inside rtnl_lock()
+ */
+static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
+{
+	int err;
+	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
+
+	if (!dev)
+		return -ENODEV;
+
+	switch (cmd) {
+		case SIOCSIFFLAGS:	/* Set interface flags */
+			return dev_change_flags(dev, ifr->ifr_flags);
+
+		case SIOCSIFMETRIC:	/* Set the metric on the interface
+					   (currently unused) */
+			return -EOPNOTSUPP;
+
+		case SIOCSIFMTU:	/* Set the MTU of a device */
+			return dev_set_mtu(dev, ifr->ifr_mtu);
+
 		case SIOCSIFHWADDR:
 			return dev_set_mac_address(dev, &ifr->ifr_hwaddr);
 
@@ -3137,15 +3182,6 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 			return 0;
 
-		case SIOCGIFMAP:
-			ifr->ifr_map.mem_start = dev->mem_start;
-			ifr->ifr_map.mem_end   = dev->mem_end;
-			ifr->ifr_map.base_addr = dev->base_addr;
-			ifr->ifr_map.irq       = dev->irq;
-			ifr->ifr_map.dma       = dev->dma;
-			ifr->ifr_map.port      = dev->if_port;
-			return 0;
-
 		case SIOCSIFMAP:
 			if (dev->set_config) {
 				if (!netif_device_present(dev))
@@ -3172,14 +3208,6 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			return dev_mc_delete(dev, ifr->ifr_hwaddr.sa_data,
 					     dev->addr_len, 1);
 
-		case SIOCGIFINDEX:
-			ifr->ifr_ifindex = dev->ifindex;
-			return 0;
-
-		case SIOCGIFTXQLEN:
-			ifr->ifr_qlen = dev->tx_queue_len;
-			return 0;
-
 		case SIOCSIFTXQLEN:
 			if (ifr->ifr_qlen < 0)
 				return -EINVAL;
@@ -3290,7 +3318,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		case SIOCGIFTXQLEN:
 			dev_load(net, ifr.ifr_name);
 			read_lock(&dev_base_lock);
-			ret = dev_ifsioc(net, &ifr, cmd);
+			ret = dev_ifsioc_locked(net, &ifr, cmd);
 			read_unlock(&dev_base_lock);
 			if (!ret) {
 				if (colon)
