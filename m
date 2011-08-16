From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] bonding: use ndo_change_rx_flags callback
Date: Tue, 16 Aug 2011 15:15:04 +0200
Message-ID: <20110816131503.GA26958@minipsycho.brq.redhat.com>
References: <1313487050-4048-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFJL+y3TOj-OX4wXT-H1Z9R3EqJLnA64t5_ocCKLx6tPUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15316 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752416Ab1HPNPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 09:15:17 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBFJL+y3TOj-OX4wXT-H1Z9R3EqJLnA64t5_ocCKLx6tPUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 16, 2011 at 12:03:42PM CEST, mirqus@gmail.com wrote:
>2011/8/16 Jiri Pirko <jpirko@redhat.com>:
>> Benefit from use of ndo_change_rx_flags in handling change of promis=
c
>> and allmulti. No need to store previous state locally.
>[...]
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 854aa8d..731763a 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>[...]
>> -static void bond_set_multicast_list(struct net_device *bond_dev)
>> +static void bond_change_rx_flags(struct net_device *bond_dev, int c=
hange)
>>  {
>[...]
>> +       if (change & IFF_PROMISC)
>> +               bond_set_promiscuity(bond,
>> +                                    bond_dev->flags & IFF_ALLMULTI =
? 1 : -1);
>
>Typo: flags & IFF_PROMISC ?

Sure, thanks Micha=C5=82

V2:

Subject: [patch net-next-2.6 v2] bonding: use ndo_change_rx_flags callb=
ack

Benefit from use of ndo_change_rx_flags in handling change of promisc
and allmulti. No need to store previous state locally.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

v1->v2: fixed IFF_ALLMULTI/IFF_PROMISC c&p typo

---
 drivers/net/bonding/bond_main.c |   44 ++++++++++++-------------------=
-------
 drivers/net/bonding/bonding.h   |    1 -
 2 files changed, 14 insertions(+), 31 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 854aa8d..c3e4683 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3686,44 +3686,27 @@ static bool bond_addr_in_mc_list(unsigned char =
*addr,
 	return false;
 }
=20
-static void bond_set_multicast_list(struct net_device *bond_dev)
+static void bond_change_rx_flags(struct net_device *bond_dev, int chan=
ge)
 {
 	struct bonding *bond =3D netdev_priv(bond_dev);
-	struct netdev_hw_addr *ha;
-	bool found;
=20
-	/*
-	 * Do promisc before checking multicast_mode
-	 */
-	if ((bond_dev->flags & IFF_PROMISC) && !(bond->flags & IFF_PROMISC))
-		/*
-		 * FIXME: Need to handle the error when one of the multi-slaves
-		 * encounters error.
-		 */
-		bond_set_promiscuity(bond, 1);
-
-
-	if (!(bond_dev->flags & IFF_PROMISC) && (bond->flags & IFF_PROMISC))
-		bond_set_promiscuity(bond, -1);
+	if (change & IFF_PROMISC)
+		bond_set_promiscuity(bond,
+				     bond_dev->flags & IFF_PROMISC ? 1 : -1);
=20
+	if (change & IFF_ALLMULTI)
+		bond_set_allmulti(bond,
+				  bond_dev->flags & IFF_ALLMULTI ? 1 : -1);
+}
=20
-	/* set allmulti flag to slaves */
-	if ((bond_dev->flags & IFF_ALLMULTI) && !(bond->flags & IFF_ALLMULTI)=
)
-		/*
-		 * FIXME: Need to handle the error when one of the multi-slaves
-		 * encounters error.
-		 */
-		bond_set_allmulti(bond, 1);
-
-
-	if (!(bond_dev->flags & IFF_ALLMULTI) && (bond->flags & IFF_ALLMULTI)=
)
-		bond_set_allmulti(bond, -1);
-
+static void bond_set_multicast_list(struct net_device *bond_dev)
+{
+	struct bonding *bond =3D netdev_priv(bond_dev);
+	struct netdev_hw_addr *ha;
+	bool found;
=20
 	read_lock(&bond->lock);
=20
-	bond->flags =3D bond_dev->flags;
-
 	/* looking for addresses to add to slaves' mc list */
 	netdev_for_each_mc_addr(ha, bond_dev) {
 		found =3D bond_addr_in_mc_list(ha->addr, &bond->mc_list,
@@ -4282,6 +4265,7 @@ static const struct net_device_ops bond_netdev_op=
s =3D {
 	.ndo_select_queue	=3D bond_select_queue,
 	.ndo_get_stats64	=3D bond_get_stats,
 	.ndo_do_ioctl		=3D bond_do_ioctl,
+	.ndo_change_rx_flags	=3D bond_change_rx_flags,
 	.ndo_set_multicast_list	=3D bond_set_multicast_list,
 	.ndo_change_mtu		=3D bond_change_mtu,
 	.ndo_set_mac_address	=3D bond_set_mac_address,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bondin=
g.h
index 43526a2..e823366 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -234,7 +234,6 @@ struct bonding {
 	struct   netdev_hw_addr_list mc_list;
 	int      (*xmit_hash_policy)(struct sk_buff *, int);
 	__be32   master_ip;
-	u16      flags;
 	u16      rr_tx_counter;
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
--=20
1.7.6

