From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6] fix bonding: allow arp_ip_targets on separate
	vlans to use arp validation
Date: Wed, 6 Jan 2010 17:56:37 -0500
Message-ID: <20100106225637.GC6490@gospo.rdu.redhat.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com> <20091120154046.67252d23@nehalam> <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com> <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com> <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com> <4B44FC2B.4090505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932852Ab0AFW4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 17:56:46 -0500
Content-Disposition: inline
In-Reply-To: <4B44FC2B.4090505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2010 at 10:10:03PM +0100, Eric Dumazet wrote:
> Le 06/01/2010 19:38, Eric Dumazet a =E9crit :
> >=20
> > (net-next-2.6 doesnt work well on my bond/vlan setup, I suspect I n=
eed a bisection)
>=20
> David, I had to revert 1f3c8804acba841b5573b953f5560d2683d2db0d
> (bonding: allow arp_ip_targets on separate vlans to use arp validatio=
n)
>=20
> Or else, my vlan devices dont work (unfortunatly I dont have much tim=
e
> these days to debug the thing)
>=20
> My config :
>=20
>               +---------+
> vlan.103 -----+ bond0   +--- eth1 (bnx2)
>               |         +
> vlan.825 -----+         +--- eth2 (tg3)
>               +---------+
>=20
> $ cat /proc/net/bonding/bond0
> Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)
>=20
> Bonding Mode: fault-tolerance (active-backup)
> Primary Slave: None
> Currently Active Slave: eth2
> MII Status: up
> MII Polling Interval (ms): 100
> Up Delay (ms): 0
> Down Delay (ms): 0
>=20
> Slave Interface: eth1  (bnx2)
> MII Status: down
> Link Failure Count: 1
> Permanent HW addr: 00:1e:0b:ec:d3:d2
>=20
> Slave Interface: eth2   (tg3)
> MII Status: up
> Link Failure Count: 0
> Permanent HW addr: 00:1e:0b:92:78:50
>=20


This patch fixes up a problem with found with commit
1f3c8804acba841b5573b953f5560d2683d2db0d.  The original change
overloaded null_or_orig, but doing that prevented any packet handlers
that were not tied to a specific device (i.e. ptype->dev =3D=3D NULL) f=
rom
ever receiving any frames.

The null_or_orig variable cannot be overloaded, and must be kept as NUL=
L
to prevent the frame from being ignored by packet handlers designed to
accept frames on any interface.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 dev.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f9aa699..d9ab9be 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2430,6 +2430,7 @@ int netif_receive_skb(struct sk_buff *skb)
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
 	struct net_device *null_or_orig;
+	struct net_device *null_or_bond;
 	int ret =3D NET_RX_DROP;
 	__be16 type;
=20
@@ -2500,21 +2501,19 @@ ncls:
 	 * bonding interfaces still make their way to any base bonding
 	 * device that may have registered for a specific ptype.  The
 	 * handler may have to adjust skb->dev and orig_dev.
-	 *
-	 * null_or_orig can be overloaded since it will not be set when
-	 * using VLANs on top of bonding.  Putting it here prevents
-	 * disturbing the ptype_all handlers above.
 	 */
+	null_or_bond =3D NULL;
 	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
 	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
-		null_or_orig =3D vlan_dev_real_dev(skb->dev);
+		null_or_bond =3D vlan_dev_real_dev(skb->dev);
 	}
=20
 	type =3D skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type =3D=3D type && (ptype->dev =3D=3D null_or_orig ||
-		     ptype->dev =3D=3D skb->dev || ptype->dev =3D=3D orig_dev)) {
+		     ptype->dev =3D=3D skb->dev || ptype->dev =3D=3D orig_dev ||
+		     ptype->dev =3D=3D null_or_bond)) {
 			if (pt_prev)
 				ret =3D deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev =3D ptype;
