From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH net] Propagate MAC address changes to VLANs
Date: Mon, 29 Feb 2016 11:32:51 +0000
Message-ID: <56D42C63.1070602@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:9855 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753490AbcB2Lce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 06:32:34 -0500
Received: from pps.filterd (m0048193.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TB4hri010284
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 03:32:33 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 21bbd9m4hj-3
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 03:32:33 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MAC address of the physical interface is only copied to the VLAN
when it is first created, resulting in an inconsistency after MAC
address changes of only newly created VLANs having an up-to-date MAC.

Continuing to inherit the MAC address unless explicitly changed for
the VLAN allows IPv6 EUI64 addresses for the VLAN to reflect the change
and thus for DAD to behave as expected for the given MAC.

Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/8021q/vlan.c |   17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d2cd9de..2f57cf2 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -293,15 +293,15 @@ static void vlan_sync_address(struct net_device *dev,
 
 	/* vlan address was different from the old address and is equal to
 	 * the new address */
-	if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
+	if ((vlandev->flags & IFF_UP) &&
+	    !ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
 	    ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
 		dev_uc_del(dev, vlandev->dev_addr);
 
-	/* vlan address was equal to the old address and is different from
+	/* vlan address was equal to the old address so now also inherit
 	 * the new address */
-	if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
-	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
-		dev_uc_add(dev, vlandev->dev_addr);
+	if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr))
+		ether_addr_copy(vlandev->dev_addr, dev->dev_addr);
 
 	ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
 }
@@ -389,13 +389,8 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_CHANGEADDR:
 		/* Adjust unicast filters on underlying device */
-		vlan_group_for_each_dev(grp, i, vlandev) {
-			flgs = vlandev->flags;
-			if (!(flgs & IFF_UP))
-				continue;
-
+		vlan_group_for_each_dev(grp, i, vlandev)
 			vlan_sync_address(dev, vlandev);
-		}
 		break;
 
 	case NETDEV_CHANGEMTU:
-- 
1.7.10.4
