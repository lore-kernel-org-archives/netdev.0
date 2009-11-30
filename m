From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
	separate vlan from bond device
Date: Mon, 30 Nov 2009 15:14:54 -0500
Message-ID: <20091130201453.GF1639@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565AbZK3UO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 15:14:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This allows a bond device to specify an arp_ip_target as a host that is
not on the same vlan as the base bond device.  A configuration like
this, now works:

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
3: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
8: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::213:21ff:febe:33e9/64 scope link
       valid_lft forever preferred_lft forever
9: bond0.100@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
    inet 10.0.100.2/24 brd 10.0.100.255 scope global bond0.100
    inet6 fe80::213:21ff:febe:33e9/64 scope link
       valid_lft forever preferred_lft forever

Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0
ARP Polling Interval (ms): 1000
ARP IP target/s (n.n.n.n form): 10.0.100.1

Slave Interface: eth1
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:40:05:30:ff:30

Slave Interface: eth0
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:13:21:be:33:e9

I've tested this on 2.6.31 with devices and support VLAN acceleration
and those that do not as well as a backport on 2.6.18 with success.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_main.c |    3 +++
 net/8021q/vlan_core.c           |    2 ++
 net/core/dev.c                  |    6 +++---
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 726bd75..aee8973 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2691,6 +2691,9 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
 
+	while (dev->priv_flags & IFF_802_1Q_VLAN)
+		dev = vlan_dev_real_dev(dev);
+
 	if (!(dev->priv_flags & IFF_BONDING) || !(dev->flags & IFF_MASTER))
 		goto out;
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index e75a2f3..8d8a778 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -14,6 +14,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	if (skb_bond_should_drop(skb))
 		goto drop;
 
+	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
 
@@ -85,6 +86,7 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 	if (skb_bond_should_drop(skb))
 		goto drop;
 
+	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 5d131c2..eeee269 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2439,8 +2439,8 @@ int netif_receive_skb(struct sk_buff *skb)
 		skb->skb_iif = skb->dev->ifindex;
 
 	null_or_orig = NULL;
-	orig_dev = skb->dev;
-	if (orig_dev->master) {
+	orig_dev = __dev_get_by_index(dev_net(skb->dev),skb->skb_iif);
+	if (orig_dev->master && !(skb->dev->priv_flags & IFF_802_1Q_VLAN)) {
 		if (skb_bond_should_drop(skb))
 			null_or_orig = orig_dev; /* deliver only exact match */
 		else
@@ -2492,7 +2492,7 @@ ncls:
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type == type &&
 		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
-		     ptype->dev == orig_dev)) {
+		     ptype->dev == orig_dev || ptype->dev == orig_dev->master)) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
-- 
1.6.2.5

