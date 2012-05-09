From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/13] 8021q: Convert compare_ether_addr to ether_addr_equal
Date: Tue,  8 May 2012 21:56:47 -0700
Message-ID: <8167269651fa71407be1938157a7db7f0451bc5f.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1336538937.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new bool function ether_addr_equal to add
some clarity and reduce the likelihood for misuse
of compare_ether_addr for sorting.

Done via cocci script:

$ cat compare_ether_addr.cocci
@@
expression a,b;
@@
-	!compare_ether_addr(a, b)
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	compare_ether_addr(a, b)
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) == 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) != 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) == 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) != 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal(a, b)
+	ether_addr_equal(a, b)

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/8021q/vlan.c      |   10 +++++-----
 net/8021q/vlan_core.c |    3 +--
 net/8021q/vlan_dev.c  |   10 +++++-----
 3 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index efea35b..6089f0c 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -266,19 +266,19 @@ static void vlan_sync_address(struct net_device *dev,
 	struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
 
 	/* May be called without an actual change */
-	if (!compare_ether_addr(vlan->real_dev_addr, dev->dev_addr))
+	if (ether_addr_equal(vlan->real_dev_addr, dev->dev_addr))
 		return;
 
 	/* vlan address was different from the old address and is equal to
 	 * the new address */
-	if (compare_ether_addr(vlandev->dev_addr, vlan->real_dev_addr) &&
-	    !compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
+	if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
+	    ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
 		dev_uc_del(dev, vlandev->dev_addr);
 
 	/* vlan address was equal to the old address and is different from
 	 * the new address */
-	if (!compare_ether_addr(vlandev->dev_addr, vlan->real_dev_addr) &&
-	    compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
+	if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
+	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
 		dev_uc_add(dev, vlandev->dev_addr);
 
 	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 4d39d80..8ca533c 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -31,8 +31,7 @@ bool vlan_do_receive(struct sk_buff **skbp, bool last_handler)
 		/* Our lower layer thinks this is not local, let's make sure.
 		 * This allows the VLAN to have a different MAC than the
 		 * underlying device, and still route correctly. */
-		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-					vlan_dev->dev_addr))
+		if (ether_addr_equal(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
 			skb->pkt_type = PACKET_HOST;
 	}
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9988d4a..eaf5f21 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -277,7 +277,7 @@ static int vlan_dev_open(struct net_device *dev)
 	    !(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
 		return -ENETDOWN;
 
-	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr)) {
+	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr)) {
 		err = dev_uc_add(real_dev, dev->dev_addr);
 		if (err < 0)
 			goto out;
@@ -307,7 +307,7 @@ clear_allmulti:
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(real_dev, -1);
 del_unicast:
-	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
+	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr))
 		dev_uc_del(real_dev, dev->dev_addr);
 out:
 	netif_carrier_off(dev);
@@ -326,7 +326,7 @@ static int vlan_dev_stop(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC)
 		dev_set_promiscuity(real_dev, -1);
 
-	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
+	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr))
 		dev_uc_del(real_dev, dev->dev_addr);
 
 	netif_carrier_off(dev);
@@ -345,13 +345,13 @@ static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 	if (!(dev->flags & IFF_UP))
 		goto out;
 
-	if (compare_ether_addr(addr->sa_data, real_dev->dev_addr)) {
+	if (!ether_addr_equal(addr->sa_data, real_dev->dev_addr)) {
 		err = dev_uc_add(real_dev, addr->sa_data);
 		if (err < 0)
 			return err;
 	}
 
-	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
+	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr))
 		dev_uc_del(real_dev, dev->dev_addr);
 
 out:
-- 
1.7.8.111.gad25c.dirty
