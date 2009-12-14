From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6 v4] bonding: allow arp_ip_targets on
	separate vlans to use arp validation
Date: Mon, 14 Dec 2009 15:48:58 -0500
Message-ID: <20091214204858.GP1639@gospo.rdu.redhat.com>
References: <29892.1259625638@death.nxdomain.ibm.com> <20091201012145.GH1639@gospo.rdu.redhat.com> <6611.1259632635@death.nxdomain.ibm.com> <20091201144410.GI1639@gospo.rdu.redhat.com> <21331.1259702893@death.nxdomain.ibm.com> <20091202212449.GL1639@gospo.rdu.redhat.com> <20091207181349.GN1639@gospo.rdu.redhat.com> <4B1D4879.3040809@gmail.com> <20091209220131.GO1639@gospo.rdu.redhat.com> <32269.1260508632@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7074 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754975AbZLNUtG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2009 15:49:06 -0500
Content-Disposition: inline
In-Reply-To: <32269.1260508632@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2009 at 09:17:12PM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >[...]  Here is the updated patch:
> >
> >[PATCH net-next-2.6 v3] bonding: allow arp_ip_targets on separate vlans to use arp validation
> >
> >This allows a bond device to specify an arp_ip_target as a host that is
> >not on the same vlan as the base bond device and still use arp
> >validation.  A configuration like this, now works:
> [...]
> 
> 	I'm testing with one modification to your patch (the change from
> your patch is below).  The gist of this change is to use "null_or_orig"
> instead of adding a new variable "null_or_bond."  I believe this is
> safe, as null_or_orig should currently only be set for non-VLAN traffic
> (VLAN traffic won't pass the "orig_dev->master" test; the VLAN code
> itself does the skb_bond_should_drop stuff), and the null_or_bond is/was
> only used for VLAN traffic.
> 

Overall I think this is a reasonable way to do it.  I hesitated to
overload null_or_orig, but this certainly seems to pass my tests.  Here
is an updated patch with the printk removed (I'm not sure how you want
to attribute this, so I'll let you add your own signed-off-by line).

[PATCH net-next-2.6 v4] bonding: allow arp_ip_targets on separate vlans to use arp validation

This allows a bond device to specify an arp_ip_target as a host that is
not on the same vlan as the base bond device and still use arp
validation.  A configuration like this, now works:

BONDING_OPTS="mode=active-backup arp_interval=1000 arp_ip_target=10.0.100.1 arp_validate=3" 

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
    
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)

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


Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_main.c |   11 +++++++++++
 net/8021q/vlan_core.c           |    2 ++
 net/core/dev.c                  |   20 +++++++++++++++++---
 3 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index af9b9c4..537e365 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2691,6 +2691,17 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
 
+	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+		/*
+		 * When using VLANS and bonding, dev and oriv_dev may be
+		 * incorrect if the physical interface supports VLAN
+		 * acceleration.  With this change ARP validation now
+		 * works for hosts only reachable on the VLAN interface.
+		 */
+		dev = vlan_dev_real_dev(dev);
+		orig_dev = dev_get_by_index_rcu(dev_net(skb->dev),skb->skb_iif);
+	}
+
 	if (!(dev->priv_flags & IFF_BONDING) || !(dev->flags & IFF_MASTER))
 		goto out;
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index e75a2f3..c0316e0 100644
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
index c36a17a..a674f84 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2487,12 +2487,26 @@ ncls:
 	if (!skb)
 		goto out;
 
+	/*
+	 * Make sure frames received on VLAN interfaces stacked on
+	 * bonding interfaces still make their way to any base bonding
+	 * device that may have registered for a specific ptype.  The
+	 * handler may have to adjust skb->dev and orig_dev.
+	 *
+	 * null_or_orig can be overloaded since it will not be set when
+	 * using VLANs on top of bonding.  Putting it here prevents
+	 * disturbing the ptype_all handlers above.
+	 */
+	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
+	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
+		null_or_orig = vlan_dev_real_dev(skb->dev);
+	}
+
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
-		if (ptype->type == type &&
-		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
-		     ptype->dev == orig_dev)) {
+		if (ptype->type == type && (ptype->dev == null_or_orig ||
+		     ptype->dev == skb->dev || ptype->dev == orig_dev)) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
