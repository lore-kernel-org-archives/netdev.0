From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6 v3] bonding: allow arp_ip_targets on
	separate vlans to use arp validation
Date: Wed, 9 Dec 2009 17:01:31 -0500
Message-ID: <20091209220131.GO1639@gospo.rdu.redhat.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <29892.1259625638@death.nxdomain.ibm.com> <20091201012145.GH1639@gospo.rdu.redhat.com> <6611.1259632635@death.nxdomain.ibm.com> <20091201144410.GI1639@gospo.rdu.redhat.com> <21331.1259702893@death.nxdomain.ibm.com> <20091202212449.GL1639@gospo.rdu.redhat.com> <20091207181349.GN1639@gospo.rdu.redhat.com> <4B1D4879.3040809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753815AbZLIWBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 17:01:31 -0500
Content-Disposition: inline
In-Reply-To: <4B1D4879.3040809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 07, 2009 at 07:24:57PM +0100, Eric Dumazet wrote:
> Andy Gospodarek a =E9crit :
>=20
> >> Jay,
> >>
> >> The issue was that that orig_dev was getting set to the active sla=
ve, so
> >> your running tcpdump on the active slave made the conditional insi=
de
> >> this loop:
> >>
> >>         list_for_each_entry_rcu(ptype, &ptype_all, list) {
> >>                 if (ptype->dev =3D=3D null_or_orig || ptype->dev =3D=
=3D skb->dev ||
> >>                     ptype->dev =3D=3D orig_dev) {
> >>                         if (pt_prev)
> >>                                 ret =3D deliver_skb(skb, pt_prev, =
orig_dev);
> >>                         pt_prev =3D ptype;
> >>                 }
> >>         }
> >>
> >> hit and deliver_skb was being called for all traffic coming toward
> >> bond0.<vid>.  I'm not completely happy with this solutoin, but I t=
hink
> >> it resolves both the original problem I was trying to solve and th=
e
> >> regression you discovered with your original patch.  Let me know i=
f you
> >> see everything working now like I do.
> >>
> >> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding=
/bond_main.c
> >> index 726bd75..b1e3b2f 100644
> >> --- a/drivers/net/bonding/bond_main.c
> >> +++ b/drivers/net/bonding/bond_main.c
> >> @@ -2697,6 +2697,19 @@ static int bond_arp_rcv(struct sk_buff *skb=
, struct net_device *dev, struct pack
> >>  	bond =3D netdev_priv(dev);
> >>  	read_lock(&bond->lock);
> >> =20
> >> +	/*
> >> +	 * We may have dev passed in as a vlan device, so make sure to g=
et to the
> >> +	 * core netdev before continuing.
> >> +	 */
> >> +	if (dev->priv_flags & IFF_802_1Q_VLAN) {
> >> +		dev =3D vlan_dev_real_dev(dev);
> >> +		/*
> >> +		 * Don't necessarily trust passed in orig_dev since vlan accele=
rated
> >> +		 * netdevs and bonding don't play well together.
> >> +		 */
> >> +		orig_dev =3D __dev_get_by_index(dev_net(skb->dev),skb->skb_iif)=
;
> >> +	}
> >> +
>=20
> >=20
> > Any thoughts on the updated patch, Jay?
>=20
> Unfortunately you still use __dev_get_by_index()
> in a non safe context.
>=20

I wasn't completely happy with the last patch, so I reworked it a bit
and addressed your concern regarding __dev_get_by_index usage.  I
replaced it with dev_get_by_index_rcu. This should be safe since all
calls to deliver_skb are protected by rcu_read_lock.  I also decided to
have the device modification happen in the frame handler rather than in
netif_receive_skb.  Here is the updated patch:

[PATCH net-next-2.6 v3] bonding: allow arp_ip_targets on separate vlans=
 to use arp validation

This allows a bond device to specify an arp_ip_target as a host that is
not on the same vlan as the base bond device and still use arp
validation.  A configuration like this, now works:

BONDING_OPTS=3D"mode=3Dactive-backup arp_interval=3D1000 arp_ip_target=3D=
10.0.100.1 arp_validate=3D3"=20

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_f=
ast master bond0 qlen 1000
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
3: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_f=
ast master bond0 qlen 1000
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
8: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noque=
ue
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::213:21ff:febe:33e9/64 scope link
       valid_lft forever preferred_lft forever
9: bond0.100@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 q=
disc noqueue
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
    inet 10.0.100.2/24 brd 10.0.100.255 scope global bond0.100
    inet6 fe80::213:21ff:febe:33e9/64 scope link
       valid_lft forever preferred_lft forever
   =20
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
   =20
Slave Interface: eth1
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:40:05:30:ff:30
   =20
Slave Interface: eth0
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:13:21:be:33:e9

---
 drivers/net/bonding/bond_main.c |   11 +++++++++++
 net/8021q/vlan_core.c           |    2 ++
 net/core/dev.c                  |   17 +++++++++++++++--
 3 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index af9b9c4..537e365 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2691,6 +2691,17 @@ static int bond_arp_rcv(struct sk_buff *skb, str=
uct net_device *dev, struct pack
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
=20
+	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+		/*
+		 * When using VLANS and bonding, dev and oriv_dev may be
+		 * incorrect if the physical interface supports VLAN
+		 * acceleration.  With this change ARP validation now
+		 * works for hosts only reachable on the VLAN interface.
+		 */
+		dev =3D vlan_dev_real_dev(dev);
+		orig_dev =3D dev_get_by_index_rcu(dev_net(skb->dev),skb->skb_iif);
+	}
+
 	if (!(dev->priv_flags & IFF_BONDING) || !(dev->flags & IFF_MASTER))
 		goto out;
=20
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index e75a2f3..c0316e0 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -14,6 +14,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vla=
n_group *grp,
 	if (skb_bond_should_drop(skb))
 		goto drop;
=20
+	skb->skb_iif =3D skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
 	skb->dev =3D vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
=20
@@ -85,6 +86,7 @@ vlan_gro_common(struct napi_struct *napi, struct vlan=
_group *grp,
 	if (skb_bond_should_drop(skb))
 		goto drop;
=20
+	skb->skb_iif =3D skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
 	skb->dev =3D vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index c36a17a..ef62d2d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2422,6 +2422,7 @@ int netif_receive_skb(struct sk_buff *skb)
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
 	struct net_device *null_or_orig;
+	struct net_device *null_or_bond;
 	int ret =3D NET_RX_DROP;
 	__be16 type;
=20
@@ -2487,12 +2488,24 @@ ncls:
 	if (!skb)
 		goto out;
=20
+	/*
+	 * Make sure frames received on VLAN interfaces stacked on
+	 * bonding interfaces still make their way to any base bonding
+	 * device that may have registered for a specific ptype.  The
+	 * handler will have to adjust skb->dev and orig_dev though.
+	 */
+	null_or_bond =3D NULL;
+	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
+	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
+		null_or_bond =3D vlan_dev_real_dev(skb->dev);
+	}
+
 	type =3D skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type =3D=3D type &&
-		    (ptype->dev =3D=3D null_or_orig || ptype->dev =3D=3D skb->dev ||
-		     ptype->dev =3D=3D orig_dev)) {
+		    (ptype->dev =3D=3D null_or_orig || ptype->dev =3D=3D null_or_bon=
d ||
+		     ptype->dev =3D=3D skb->dev || ptype->dev =3D=3D orig_dev)) {
 			if (pt_prev)
 				ret =3D deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev =3D ptype;
--=20
1.6.2.5

