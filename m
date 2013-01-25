From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next V2] bond: have random dev address by default instead of zeroes
Date: Thu, 24 Jan 2013 17:35:01 -0800
Message-ID: <13906.1359077701@death.nxdomain>
References: <1359057684-6732-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, psimerda@redhat.com, dcbw@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:51318 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753065Ab3AYBfQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 20:35:16 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 24 Jan 2013 20:35:15 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 1E33E6E803A
	for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 20:35:11 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0P1ZCZR220318
	for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 20:35:12 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0P1Z94S009369
	for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 23:35:10 -0200
In-reply-to: <1359057684-6732-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> wrote:

>Makes more sense to have randomly generated address by default than to
>have all zeroes. It also allows user to for example put the bond into
>bridge without need to have any slaves in it.
>
>Also note that this changes only behaviour of bonds with no slaves. On=
ce
>the first slave device is enslaved, its address will be used (no chang=
e
>here).
>
>Also, fix dev_assign_type values on the way.
>
>Reported-by: Pavel =C5=A0imerda <psimerda@redhat.com>
>Signed-off-by: Jiri Pirko <jiri@resnulli.us>

	Maybe I don't see it, but this feels like a bit of a hack just
to get a bond with no slaves into a bridge.  Am I missing something
here?  I just have this feeling that down the road I'm going to get
questions as to why the bond gets a MAC, and then, poof, it vanishes
when a slave is added.  What's the point of the MAC address if it's onl=
y
used to fool the bridge code?

	Also, when the bond's MAC changes from the random MAC to the
first slave's MAC, does a notifier call need to happen?  There isn't on=
e
now from the all zeroes to the first slave's, but that's from an invali=
d
MAC to a valid one.  There is already a notifier when the bond goes bac=
k
to all zeroes, though.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

>
>v1->v2:
>- fixed assign value of bond_dev->addr_assign_type in bond_set_dev_add=
r()
>- added note to patch description
>
> drivers/net/bonding/bond_main.c | 28 ++++++++++++++++------------
> 1 file changed, 16 insertions(+), 12 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bon=
d_main.c
>index 564cf42..1d56ac9 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1320,14 +1320,14 @@ static void bond_netpoll_cleanup(struct net_de=
vice *bond_dev)
>
> /*---------------------------------- IOCTL --------------------------=
--------*/
>
>-static int bond_sethwaddr(struct net_device *bond_dev,
>-			  struct net_device *slave_dev)
>+static void bond_set_dev_addr(struct net_device *bond_dev,
>+			      struct net_device *slave_dev)
> {
> 	pr_debug("bond_dev=3D%p\n", bond_dev);
> 	pr_debug("slave_dev=3D%p\n", slave_dev);
> 	pr_debug("slave_dev->addr_len=3D%d\n", slave_dev->addr_len);
> 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len)=
;
>-	return 0;
>+	bond_dev->addr_assign_type =3D NET_ADDR_SET;
> }
>
> static netdev_features_t bond_fix_features(struct net_device *dev,
>@@ -1628,10 +1628,8 @@ int bond_enslave(struct net_device *bond_dev, s=
truct net_device *slave_dev)
>
> 	/* If this is the first slave, then we need to set the master's hard=
ware
> 	 * address to be the same as the slave's. */
>-	if (is_zero_ether_addr(bond->dev->dev_addr))
>-		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
>-		       slave_dev->addr_len);
>-
>+	if (bond->dev->addr_assign_type !=3D NET_ADDR_SET)
>+		bond_set_dev_addr(bond->dev, slave_dev);
>
> 	new_slave =3D kzalloc(sizeof(struct slave), GFP_KERNEL);
> 	if (!new_slave) {
>@@ -2049,11 +2047,11 @@ int bond_release(struct net_device *bond_dev, =
struct net_device *slave_dev)
> 	if (bond->slave_cnt =3D=3D 0) {
> 		bond_set_carrier(bond);
>
>-		/* if the last slave was removed, zero the mac address
>-		 * of the master so it will be set by the application
>-		 * to the mac address of the first slave
>+		/* If the last slave was removed, set random mac address
>+		 * of the master so it will be set by bond_enslave()
>+		 * to the mac address of the first slave.
> 		 */
>-		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
>+		eth_hw_addr_random(bond_dev);
>
> 		if (bond_vlan_used(bond)) {
> 			pr_warning("%s: Warning: clearing HW address of %s while it still =
has VLANs.\n",
>@@ -3708,7 +3706,8 @@ static int bond_do_ioctl(struct net_device *bond=
_dev, struct ifreq *ifr, int cmd
> 			break;
> 		case BOND_SETHWADDR_OLD:
> 		case SIOCBONDSETHWADDR:
>-			res =3D bond_sethwaddr(bond_dev, slave_dev);
>+			bond_set_dev_addr(bond_dev, slave_dev);
>+			res =3D 0;
> 			break;
> 		case BOND_CHANGE_ACTIVE_OLD:
> 		case SIOCBONDCHANGEACTIVE:
>@@ -4858,6 +4857,11 @@ static int bond_init(struct net_device *bond_de=
v)
>
> 	bond_debug_register(bond);
>
>+	/* Ensure valid dev_addr */
>+	if (is_zero_ether_addr(bond_dev->dev_addr) &&
>+	    bond_dev->addr_assign_type =3D=3D NET_ADDR_PERM)
>+		eth_hw_addr_random(bond_dev);
>+
> 	__hw_addr_init(&bond->mc_list);
> 	return 0;
> }
>--=20
>1.8.1
>
