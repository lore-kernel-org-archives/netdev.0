From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next V2] bond: have random dev address by default
 instead of zeroes
Date: Fri, 25 Jan 2013 07:37:13 +0100
Message-ID: <20130125063713.GA1659@minipsycho.orion>
References: <1359057684-6732-1-git-send-email-jiri@resnulli.us>
 <13906.1359077701@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, psimerda@redhat.com, dcbw@redhat.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:52783 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab3AYGhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 01:37:17 -0500
Received: by mail-we0-f177.google.com with SMTP id d7so15294wer.36
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 22:37:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <13906.1359077701@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Jan 25, 2013 at 02:35:01AM CET, fubar@us.ibm.com wrote:
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>>Makes more sense to have randomly generated address by default than t=
o
>>have all zeroes. It also allows user to for example put the bond into
>>bridge without need to have any slaves in it.
>>
>>Also note that this changes only behaviour of bonds with no slaves. O=
nce
>>the first slave device is enslaved, its address will be used (no chan=
ge
>>here).
>>
>>Also, fix dev_assign_type values on the way.
>>
>>Reported-by: Pavel =C5=A0imerda <psimerda@redhat.com>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>	Maybe I don't see it, but this feels like a bit of a hack just
>to get a bond with no slaves into a bridge.  Am I missing something
>here?  I just have this feeling that down the road I'm going to get
>questions as to why the bond gets a MAC, and then, poof, it vanishes
>when a slave is added.  What's the point of the MAC address if it's on=
ly
>used to fool the bridge code?

I think that generally, the device should have valid mac address in
every point of its lifetime. I believe that bond is the only device who
behaves differently (bridge also uses random mac when no ports are
there)

>
>	Also, when the bond's MAC changes from the random MAC to the
>first slave's MAC, does a notifier call need to happen?  There isn't o=
ne
>now from the all zeroes to the first slave's, but that's from an inval=
id
>MAC to a valid one.  There is already a notifier when the bond goes ba=
ck
>to all zeroes, though.

You are right, all_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
should be called from bond_enslave() after calling bond_set_dev_addr()

>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
>>
>>v1->v2:
>>- fixed assign value of bond_dev->addr_assign_type in bond_set_dev_ad=
dr()
>>- added note to patch description
>>
>> drivers/net/bonding/bond_main.c | 28 ++++++++++++++++------------
>> 1 file changed, 16 insertions(+), 12 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
>>index 564cf42..1d56ac9 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -1320,14 +1320,14 @@ static void bond_netpoll_cleanup(struct net_d=
evice *bond_dev)
>>
>> /*---------------------------------- IOCTL -------------------------=
---------*/
>>
>>-static int bond_sethwaddr(struct net_device *bond_dev,
>>-			  struct net_device *slave_dev)
>>+static void bond_set_dev_addr(struct net_device *bond_dev,
>>+			      struct net_device *slave_dev)
>> {
>> 	pr_debug("bond_dev=3D%p\n", bond_dev);
>> 	pr_debug("slave_dev=3D%p\n", slave_dev);
>> 	pr_debug("slave_dev->addr_len=3D%d\n", slave_dev->addr_len);
>> 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len=
);
>>-	return 0;
>>+	bond_dev->addr_assign_type =3D NET_ADDR_SET;
>> }
>>
>> static netdev_features_t bond_fix_features(struct net_device *dev,
>>@@ -1628,10 +1628,8 @@ int bond_enslave(struct net_device *bond_dev, =
struct net_device *slave_dev)
>>
>> 	/* If this is the first slave, then we need to set the master's har=
dware
>> 	 * address to be the same as the slave's. */
>>-	if (is_zero_ether_addr(bond->dev->dev_addr))
>>-		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
>>-		       slave_dev->addr_len);
>>-
>>+	if (bond->dev->addr_assign_type !=3D NET_ADDR_SET)
>>+		bond_set_dev_addr(bond->dev, slave_dev);
>>
>> 	new_slave =3D kzalloc(sizeof(struct slave), GFP_KERNEL);
>> 	if (!new_slave) {
>>@@ -2049,11 +2047,11 @@ int bond_release(struct net_device *bond_dev,=
 struct net_device *slave_dev)
>> 	if (bond->slave_cnt =3D=3D 0) {
>> 		bond_set_carrier(bond);
>>
>>-		/* if the last slave was removed, zero the mac address
>>-		 * of the master so it will be set by the application
>>-		 * to the mac address of the first slave
>>+		/* If the last slave was removed, set random mac address
>>+		 * of the master so it will be set by bond_enslave()
>>+		 * to the mac address of the first slave.
>> 		 */
>>-		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
>>+		eth_hw_addr_random(bond_dev);
>>
>> 		if (bond_vlan_used(bond)) {
>> 			pr_warning("%s: Warning: clearing HW address of %s while it still=
 has VLANs.\n",
>>@@ -3708,7 +3706,8 @@ static int bond_do_ioctl(struct net_device *bon=
d_dev, struct ifreq *ifr, int cmd
>> 			break;
>> 		case BOND_SETHWADDR_OLD:
>> 		case SIOCBONDSETHWADDR:
>>-			res =3D bond_sethwaddr(bond_dev, slave_dev);
>>+			bond_set_dev_addr(bond_dev, slave_dev);
>>+			res =3D 0;
>> 			break;
>> 		case BOND_CHANGE_ACTIVE_OLD:
>> 		case SIOCBONDCHANGEACTIVE:
>>@@ -4858,6 +4857,11 @@ static int bond_init(struct net_device *bond_d=
ev)
>>
>> 	bond_debug_register(bond);
>>
>>+	/* Ensure valid dev_addr */
>>+	if (is_zero_ether_addr(bond_dev->dev_addr) &&
>>+	    bond_dev->addr_assign_type =3D=3D NET_ADDR_PERM)
>>+		eth_hw_addr_random(bond_dev);
>>+
>> 	__hw_addr_init(&bond->mc_list);
>> 	return 0;
>> }
>>--=20
>>1.8.1
>>
>
