From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] NET: Validate device addr prior to interface-up
Date: Tue, 23 Oct 2007 22:33:13 -0400
Message-ID: <20071024023313.GA19263@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:48313 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbXJXCdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 22:33:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
David, I would actually prefer if you queued this one up, please...


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a3f54e..962d1de 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -669,6 +669,8 @@ struct net_device
 #define HAVE_SET_MAC_ADDR  		 
 	int			(*set_mac_address)(struct net_device *dev,
 						   void *addr);
+#define HAVE_VALIDATE_ADDR  		 
+	int			(*validate_addr)(struct net_device *dev);
 #define HAVE_PRIVATE_IOCTL
 	int			(*do_ioctl)(struct net_device *dev,
 					    struct ifreq *ifr, int cmd);
diff --git a/net/core/dev.c b/net/core/dev.c
index 8726589..f861555 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1007,17 +1007,20 @@ int dev_open(struct net_device *dev)
 	 *	Call device private open method
 	 */
 	set_bit(__LINK_STATE_START, &dev->state);
-	if (dev->open) {
+
+	if (dev->validate_addr)
+		ret = dev->validate_addr(dev);
+
+	if (!ret && dev->open)
 		ret = dev->open(dev);
-		if (ret)
-			clear_bit(__LINK_STATE_START, &dev->state);
-	}
 
 	/*
 	 *	If it went open OK then:
 	 */
 
-	if (!ret) {
+	if (ret)
+		clear_bit(__LINK_STATE_START, &dev->state);
+	else {
 		/*
 		 *	Set the flags.
 		 */
@@ -1038,6 +1041,7 @@ int dev_open(struct net_device *dev)
 		 */
 		call_netdevice_notifiers(NETDEV_UP, dev);
 	}
+
 	return ret;
 }
 
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index ed8a3d4..5471cd2 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -298,6 +298,14 @@ static int eth_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static int eth_validate_addr(struct net_device *dev)
+{
+	if (!is_valid_ether_addr(dev->dev_addr))
+		return -EINVAL;
+	
+	return 0;
+}
+
 const struct header_ops eth_header_ops ____cacheline_aligned = {
 	.create		= eth_header,
 	.parse		= eth_header_parse,
@@ -317,6 +325,7 @@ void ether_setup(struct net_device *dev)
 
 	dev->change_mtu		= eth_change_mtu;
 	dev->set_mac_address 	= eth_mac_addr;
+	dev->validate_addr	= eth_validate_addr;
 
 	dev->type		= ARPHRD_ETHER;
 	dev->hard_header_len 	= ETH_HLEN;
