From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH net v4] vlan: Propagate MAC address to VLANs
Date: Sat, 7 May 2016 11:00:09 +0100
Message-ID: <572DBCA9.7060906@brocade.com>
References: <572DB364.2040109@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:7094 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751023AbcEGKAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 06:00:23 -0400
Received: from pps.filterd (m0000700.ppops.net [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u479xBTt006667
	for <netdev@vger.kernel.org>; Sat, 7 May 2016 03:00:22 -0700
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 22se00g0q9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 07 May 2016 03:00:22 -0700
In-Reply-To: <572DB364.2040109@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MAC address of the physical interface is only copied to the VLAN
when it is first created, resulting in an inconsistency after MAC
address changes of only newly created VLANs having an up-to-date MAC.

The VLANs should continue inheriting the MAC address of the physical
interface until the VLAN MAC address is explicitly set to any value. 
This allows IPv6 EUI64 addresses for the VLAN to reflect any changes
to the MAC of the physical interface and thus for DAD to behave as
expected.

Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/8021q/vlan.c     |    7 +++++++
 net/8021q/vlan_dev.c |   14 ++++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -291,6 +291,12 @@ static void vlan_sync_address(struct net
 	if (ether_addr_equal(vlan->real_dev_addr, dev->dev_addr))
 		return;
 
+	/* vlan continues to inherit address of parent interface */
+	if (vlandev->addr_assign_type == NET_ADDR_STOLEN) {
+		ether_addr_copy(vlandev->dev_addr, dev->dev_addr);
+		goto out;
+	}
+
 	/* vlan address was different from the old address and is equal to
 	 * the new address */
 	if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
@@ -303,6 +309,7 @@ static void vlan_sync_address(struct net
 	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
 		dev_uc_add(dev, vlandev->dev_addr);
 
+out:
 	ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
 }
 
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -255,9 +255,13 @@ static int vlan_dev_open(struct net_devi
 		return -ENETDOWN;
 
 	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr)) {
-		err = dev_uc_add(real_dev, dev->dev_addr);
-		if (err < 0)
-			goto out;
+		if (dev->addr_assign_type == NET_ADDR_STOLEN) {
+			ether_addr_copy(dev->dev_addr, real_dev->dev_addr);
+		} else {
+			err = dev_uc_add(real_dev, dev->dev_addr);
+			if (err < 0)
+				goto out;
+		}
 	}
 
 	if (dev->flags & IFF_ALLMULTI) {
@@ -558,8 +562,10 @@ static int vlan_dev_init(struct net_devi
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;
 
-	if (is_zero_ether_addr(dev->dev_addr))
+	if (is_zero_ether_addr(dev->dev_addr)) {
 		eth_hw_addr_inherit(dev, real_dev);
+		dev->addr_assign_type = NET_ADDR_STOLEN;
+	}
 	if (is_zero_ether_addr(dev->broadcast))
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);

-- 
1.7.10.4
