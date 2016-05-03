From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH net v2] vlan: Propagate MAC address to VLANs unless explicitly
 set
Date: Tue, 3 May 2016 16:20:12 +0100
Message-ID: <5728C1AC.3090708@brocade.com>
References: <5728BA0B.6050807@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:59327 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932883AbcECPU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 11:20:26 -0400
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u43EW6Ui019129
	for <netdev@vger.kernel.org>; Tue, 3 May 2016 08:20:24 -0700
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 22mv4cyxps-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 03 May 2016 08:20:24 -0700
In-Reply-To: <5728BA0B.6050807@brocade.com>
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
 net/8021q/vlan.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -286,22 +286,25 @@ static void vlan_sync_address(struct net
 			      struct net_device *vlandev)
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
+	bool real_addr_in_use;
 
 	/* May be called without an actual change */
 	if (ether_addr_equal(vlan->real_dev_addr, dev->dev_addr))
 		return;
 
-	/* vlan address was different from the old address and is equal to
+	real_addr_in_use =
+		ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr);
+
+	/* vlan address was different from the real address and is equal to
 	 * the new address */
-	if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
+	if ((vlandev->flags & IFF_UP) && !real_addr_in_use &&
 	    ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
 		dev_uc_del(dev, vlandev->dev_addr);
 
-	/* vlan address was equal to the old address and is different from
+	/* vlan address was equal to the real address so now also inherit
 	 * the new address */
-	if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
-	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
-		dev_uc_add(dev, vlandev->dev_addr);
+	if (real_addr_in_use)
+		ether_addr_copy(vlandev->dev_addr, dev->dev_addr);
 
 	ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
 }
@@ -389,13 +392,8 @@ static int vlan_device_event(struct noti
 
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
