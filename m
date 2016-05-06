From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH net v3] vlan: Propagate MAC address to VLANs
Date: Fri, 6 May 2016 14:26:54 +0100
Message-ID: <572C9B9E.1000304@brocade.com>
References: <572C99FB.1060905@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:23768 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758073AbcEFN1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 09:27:08 -0400
Received: from pps.filterd (m0048192.ppops.net [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u46DLLuu001131
	for <netdev@vger.kernel.org>; Fri, 6 May 2016 06:27:07 -0700
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 22rbd2v5r7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 06 May 2016 06:27:07 -0700
In-Reply-To: <572C99FB.1060905@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MAC address of the physical interface is only copied to the VLAN
when it is first created, resulting in an inconsistency after MAC
address changes of only newly created VLANs having an up-to-date MAC.

The VLANs should continue inheriting the MAC address of the physical
interface, unless explicitly changed to be different from this. 
This allows IPv6 EUI64 addresses for the VLAN to reflect any changes
to the MAC of the physical interface and thus for DAD to behave as
expected.

Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 include/linux/if_vlan.h |    2 ++
 net/8021q/vlan.c        |   17 +++++++++++------
 net/8021q/vlan_dev.c    |   13 ++++++++++---
 3 files changed, 23 insertions(+), 9 deletions(-)

--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -138,6 +138,7 @@ struct netpoll;
  *	@flags: device flags
  *	@real_dev: underlying netdevice
  *	@real_dev_addr: address of underlying netdevice
+ *	@addr_assign_type: address assignment type
  *	@dent: proc dir entry
  *	@vlan_pcpu_stats: ptr to percpu rx stats
  */
@@ -153,6 +154,7 @@ struct vlan_dev_priv {
 
 	struct net_device			*real_dev;
 	unsigned char				real_dev_addr[ETH_ALEN];
+	unsigned char				addr_assign_type;
 
 	struct proc_dir_entry			*dent;
 	struct vlan_pcpu_stats __percpu		*vlan_pcpu_stats;
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -291,6 +291,15 @@ static void vlan_sync_address(struct net
 	if (ether_addr_equal(vlan->real_dev_addr, dev->dev_addr))
 		return;
 
+	/* vlan continues to inherit address of parent interface */
+	if (vlan->addr_assign_type == NET_ADDR_STOLEN) {
+		ether_addr_copy(vlandev->dev_addr, dev->dev_addr);
+		goto out;
+	}
+
+	if (!(vlandev->flags & IFF_UP))
+		goto out;
+
 	/* vlan address was different from the old address and is equal to
 	 * the new address */
 	if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
@@ -303,6 +312,7 @@ static void vlan_sync_address(struct net
 	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
 		dev_uc_add(dev, vlandev->dev_addr);
 
+out:
 	ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
 }
 
@@ -389,13 +399,8 @@ static int vlan_device_event(struct noti
 
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
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -315,17 +315,21 @@ static int vlan_dev_stop(struct net_devi
 
 static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 {
-	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
+	struct net_device *real_dev = vlan->real_dev;
 	struct sockaddr *addr = p;
+	bool is_real_addr;
 	int err;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	is_real_addr = ether_addr_equal(addr->sa_data, real_dev->dev_addr);
+
 	if (!(dev->flags & IFF_UP))
 		goto out;
 
-	if (!ether_addr_equal(addr->sa_data, real_dev->dev_addr)) {
+	if (!is_real_addr) {
 		err = dev_uc_add(real_dev, addr->sa_data);
 		if (err < 0)
 			return err;
@@ -336,6 +340,7 @@ static int vlan_dev_set_mac_address(stru
 
 out:
 	ether_addr_copy(dev->dev_addr, addr->sa_data);
+	vlan->addr_assign_type = is_real_addr ? NET_ADDR_STOLEN : NET_ADDR_SET;
 	return 0;
 }
 
@@ -558,8 +563,10 @@ static int vlan_dev_init(struct net_devi
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;
 
-	if (is_zero_ether_addr(dev->dev_addr))
+	if (is_zero_ether_addr(dev->dev_addr)) {
 		eth_hw_addr_inherit(dev, real_dev);
+		vlan_dev_priv(dev)->addr_assign_type = NET_ADDR_STOLEN;
+	}
 	if (is_zero_ether_addr(dev->broadcast))
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);

-- 
1.7.10.4
