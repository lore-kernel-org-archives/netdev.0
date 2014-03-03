From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next] vlan: use ether_addr_equal_64bits to instead of
 ether_addr_equal
Date: Mon, 3 Mar 2014 09:14:39 +0800
Message-ID: <5313D77F.3090508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:22725 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaCCBPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 20:15:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ether_addr_equal_64bits is more efficient than ether_addr_equal, and
can be used when each argument is an array within a structure that
contains at least two bytes of data beyond the array, so it is safe
to use it for vlan.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/8021q/vlan.c      | 10 +++++-----
 net/8021q/vlan_core.c |  2 +-
 net/8021q/vlan_dev.c  | 10 +++++-----
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ec99099..16fb0f4 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -286,19 +286,19 @@ static void vlan_sync_address(struct net_device *dev,
 	struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
 
 	/* May be called without an actual change */
-	if (ether_addr_equal(vlan->real_dev_addr, dev->dev_addr))
+	if (ether_addr_equal_64bits(vlan->real_dev_addr, dev->dev_addr))
 		return;
 
 	/* vlan address was different from the old address and is equal to
 	 * the new address */
-	if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
-	    ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
+	if (!ether_addr_equal_64bits(vlandev->dev_addr, vlan->real_dev_addr) &&
+	    ether_addr_equal_64bits(vlandev->dev_addr, dev->dev_addr))
 		dev_uc_del(dev, vlandev->dev_addr);
 
 	/* vlan address was equal to the old address and is different from
 	 * the new address */
-	if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
-	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
+	if (ether_addr_equal_64bits(vlandev->dev_addr, vlan->real_dev_addr) &&
+	    !ether_addr_equal_64bits(vlandev->dev_addr, dev->dev_addr))
 		dev_uc_add(dev, vlandev->dev_addr);
 
 	ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 6ee48aa..39cbb46 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -26,7 +26,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
 		/* Our lower layer thinks this is not local, let's make sure.
 		 * This allows the VLAN to have a different MAC than the
 		 * underlying device, and still route correctly. */
-		if (ether_addr_equal(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
+		if (ether_addr_equal_64bits(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
 			skb->pkt_type = PACKET_HOST;
 	}
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 76d8fab..5e1edd6 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -286,7 +286,7 @@ static int vlan_dev_open(struct net_device *dev)
 	    !(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
 		return -ENETDOWN;
 
-	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr)) {
+	if (!ether_addr_equal_64bits(dev->dev_addr, real_dev->dev_addr)) {
 		err = dev_uc_add(real_dev, dev->dev_addr);
 		if (err < 0)
 			goto out;
@@ -319,7 +319,7 @@ clear_allmulti:
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(real_dev, -1);
 del_unicast:
-	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr))
+	if (!ether_addr_equal_64bits(dev->dev_addr, real_dev->dev_addr))
 		dev_uc_del(real_dev, dev->dev_addr);
 out:
 	netif_carrier_off(dev);
@@ -338,7 +338,7 @@ static int vlan_dev_stop(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC)
 		dev_set_promiscuity(real_dev, -1);
 
-	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr))
+	if (!ether_addr_equal_64bits(dev->dev_addr, real_dev->dev_addr))
 		dev_uc_del(real_dev, dev->dev_addr);
 
 	netif_carrier_off(dev);
@@ -357,13 +357,13 @@ static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 	if (!(dev->flags & IFF_UP))
 		goto out;
 
-	if (!ether_addr_equal(addr->sa_data, real_dev->dev_addr)) {
+	if (!ether_addr_equal_64bits(addr->sa_data, real_dev->dev_addr)) {
 		err = dev_uc_add(real_dev, addr->sa_data);
 		if (err < 0)
 			return err;
 	}
 
-	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr))
+	if (!ether_addr_equal_64bits(dev->dev_addr, real_dev->dev_addr))
 		dev_uc_del(real_dev, dev->dev_addr);
 
 out:
-- 
1.8.0
