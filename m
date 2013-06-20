From: nikolay@redhat.com
Subject: [PATCH] 8021q: fix vlan 0 inconsistencies
Date: Thu, 20 Jun 2013 14:24:38 +0200
Message-ID: <1371731078-12531-1-git-send-email-nikolay@redhat.com>
Cc: kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56205 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757746Ab3FTM13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 08:27:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>

The first part of the patch stops the addition of VLAN 0 to bonding
devices because we use an internal vlan_list to keep the added vlans and
after that when checking if we're using vlans on the bond
(bond_vlan_used) it evaluates to true always, which leads to different
problems. Since this is intended for HW vlan filters, it's not needed
for the bonding, and for its slaves it will still get added upon
NETDEV_UP.
The second part that does unconditional vlan_vid_del is needed because
when we add vlan 0 to a bonding device, it can never be removed
completely (it will always stay in the local vlan_list). Since there's
refcounting, I don't think this will change the behaviour because if a
real device is UP then vlan 0 will have at least refcnt == 1 so
ndo_vlan_rx_kill_vid won't get called until the device is down, but in
the bonding case we need it while the device is up so we can cleanup
properly after vlan 0 removal.
As an addition I'd like to say that I tried many different fixes of this
issue from inside the bonding, but they all have shortcomings and fixing
the root cause would be much better. For example I can't filter out vlan
0 in the bond's ndo_vlan_rx_add_vid because bond_has_this_ip() (and others)
rely on being able to check the vlan devices on top through the local
vlan_list. Also there's no way to differentiate between addition of vlan 0
from vlan_device_event and from register_vlan_dev.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 net/8021q/vlan.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 9424f37..dbabaa5 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -112,11 +112,9 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	}
 
 	/* Take it out of our own structures, but be sure to interlock with
-	 * HW accelerating devices or SW vlan input packet processing if
-	 * VLAN is not 0 (leave it there for 802.1p).
+	 * HW accelerating devices or SW vlan input packet processing
 	 */
-	if (vlan_id)
-		vlan_vid_del(real_dev, vlan->vlan_proto, vlan_id);
+	vlan_vid_del(real_dev, vlan->vlan_proto, vlan_id);
 
 	/* Get rid of the vlan's reference to real_dev */
 	dev_put(real_dev);
@@ -354,7 +352,8 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		__vlan_device_event(dev, event);
 
 	if ((event == NETDEV_UP) &&
-	    (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
+	    (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER) &&
+	    !netif_is_bond_master(dev)) {
 		pr_info("adding VLAN 0 to HW filter on device %s\n",
 			dev->name);
 		vlan_vid_add(dev, htons(ETH_P_8021Q), 0);
-- 
1.8.1.4
