From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH net v5] vlan: Propagate MAC address to VLANs
Date: Fri, 27 May 2016 17:45:07 +0100
Message-ID: <57487993.2040609@brocade.com>
References: <57487691.7090808@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:33971 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750744AbcE0Qpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 12:45:35 -0400
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4RGWn7U027940
	for <netdev@vger.kernel.org>; Fri, 27 May 2016 09:45:34 -0700
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 236nh6sffq-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 27 May 2016 09:45:34 -0700
In-Reply-To: <57487691.7090808@brocade.com>
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
 net/8021q/vlan.c     |    5 +++++
 net/8021q/vlan.h     |    2 ++
 net/8021q/vlan_dev.c |   20 +++++++++++++++++---
 3 files changed, 24 insertions(+), 3 deletions(-)

--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -291,6 +291,10 @@ static void vlan_sync_address(struct net
 	if (ether_addr_equal(vlan->real_dev_addr, dev->dev_addr))
 		return;
 
+	/* vlan continues to inherit address of lower device */
+	if (vlan_dev_inherit_address(vlandev, dev))
+		goto out;
+
 	/* vlan address was different from the old address and is equal to
 	 * the new address */
 	if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
@@ -303,6 +307,7 @@ static void vlan_sync_address(struct net
 	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
 		dev_uc_add(dev, vlandev->dev_addr);
 
+out:
 	ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
 }
 
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -109,6 +109,8 @@ int vlan_check_real_dev(struct net_devic
 void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
 void unregister_vlan_dev(struct net_device *dev, struct list_head *head);
+bool vlan_dev_inherit_address(struct net_device *dev,
+			      struct net_device *real_dev);
 
 static inline u32 vlan_get_ingress_priority(struct net_device *dev,
 					    u16 vlan_tci)
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -244,6 +244,17 @@ void vlan_dev_get_realdev_name(const str
 	strncpy(result, vlan_dev_priv(dev)->real_dev->name, 23);
 }
 
+bool vlan_dev_inherit_address(struct net_device *dev,
+			      struct net_device *real_dev)
+{
+	if (dev->addr_assign_type != NET_ADDR_STOLEN)
+		return false;
+
+	ether_addr_copy(dev->dev_addr, real_dev->dev_addr);
+	call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	return true;
+}
+
 static int vlan_dev_open(struct net_device *dev)
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
@@ -254,7 +265,8 @@ static int vlan_dev_open(struct net_devi
 	    !(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
 		return -ENETDOWN;
 
-	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr)) {
+	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr) &&
+	    !vlan_dev_inherit_address(dev, real_dev)) {
 		err = dev_uc_add(real_dev, dev->dev_addr);
 		if (err < 0)
 			goto out;
@@ -558,8 +570,10 @@ static int vlan_dev_init(struct net_devi
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;
 
-	if (is_zero_ether_addr(dev->dev_addr))
-		eth_hw_addr_inherit(dev, real_dev);
+	if (is_zero_ether_addr(dev->dev_addr)) {
+		ether_addr_copy(dev->dev_addr, real_dev->dev_addr);
+		dev->addr_assign_type = NET_ADDR_STOLEN;
+	}
 	if (is_zero_ether_addr(dev->broadcast))
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
 
-- 
1.7.10.4
