From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 02/45] br2684: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:00:59 -0800
Message-ID: <20090109230136.856606078@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42305 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755286AbZAIXSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:14 -0500
Content-Disposition: inline; filename=br2684-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/atm/br2684.c	2009-01-08 23:20:52.000000000 -0800
+++ b/net/atm/br2684.c	2009-01-08 23:29:33.000000000 -0800
@@ -259,10 +259,9 @@ static int br2684_start_xmit(struct sk_b
  * We remember when the MAC gets set, so we don't override it later with
  * the ESI of the ATM card of the first VC
  */
-static int (*my_eth_mac_addr) (struct net_device *, void *);
 static int br2684_mac_addr(struct net_device *dev, void *p)
 {
-	int err = my_eth_mac_addr(dev, p);
+	int err = eth_mac_addr(dev, p);
 	if (!err)
 		BRPRIV(dev)->mac_was_set = 1;
 	return err;
@@ -538,16 +537,20 @@ static int br2684_regvcc(struct atm_vcc 
 	return err;
 }
 
+static const struct net_device_ops br2684_netdev_ops = {
+	.ndo_start_xmit 	= br2684_start_xmit,
+	.ndo_set_mac_address	= br2684_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static void br2684_setup(struct net_device *netdev)
 {
 	struct br2684_dev *brdev = BRPRIV(netdev);
 
 	ether_setup(netdev);
-	brdev->net_dev = netdev;
 
-	my_eth_mac_addr = netdev->set_mac_address;
-	netdev->set_mac_address = br2684_mac_addr;
-	netdev->hard_start_xmit = br2684_start_xmit;
+	netdev->netdev_ops = &br2684_netdev_ops;
 
 	INIT_LIST_HEAD(&brdev->brvccs);
 }
@@ -558,9 +561,8 @@ static void br2684_setup_routed(struct n
 	brdev->net_dev = netdev;
 
 	netdev->hard_header_len = 0;
-	my_eth_mac_addr = netdev->set_mac_address;
-	netdev->set_mac_address = br2684_mac_addr;
-	netdev->hard_start_xmit = br2684_start_xmit;
+
+	netdev->netdev_ops = &br2684_netdev_ops;
 	netdev->addr_len = 0;
 	netdev->mtu = 1500;
 	netdev->type = ARPHRD_PPP;


