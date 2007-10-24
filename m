From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000, e1000e valid-addr fixes
Date: Tue, 23 Oct 2007 22:20:30 -0400
Message-ID: <471EABEE.8030900@garzik.org>
References: <20071023.145339.55504234.davem@davemloft.net>	<471E9801.2000006@garzik.org>	<471E99E8.6030404@garzik.org> <20071023.180744.115914004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050906060804060408070304"
Cc: netdev@vger.kernel.org, davej@redhat.com, auke-jan.h.kok@intel.com,
	ajax@redhat.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37406 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183AbXJXCUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 22:20:34 -0400
In-Reply-To: <20071023.180744.115914004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050906060804060408070304
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Tue, 23 Oct 2007 21:03:36 -0400
> 
>> I'm wondering if there is a way to avoid adding
>>
>> 	if (!is_valid_ether_addr(dev->dev_addr))
>> 		return -EINVAL;
>>
>> to every ethernet driver's ->open() hook.
> 
> The first idea I get is:
> 
> 1) Create netdev->validate_dev_addr().
> 
> 2) If it exists, invoke it before ->open(), abort
>    and return if any errors signaled.
> 
> etherdev init hooks up a function that does the above
> check, which allows us to avoid editing every ethernet
> driver
> 
> What do you think?

Seems sane to me.  Something like this (attached)?

	Jeff




--------------050906060804060408070304
Content-Type: text/plain;
 name="patch.validate-addr"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch.validate-addr"

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

--------------050906060804060408070304--
