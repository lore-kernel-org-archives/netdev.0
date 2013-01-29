From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next V3] bond: have random dev address by default instead of zeroes
Date: Tue, 29 Jan 2013 14:17:49 -0800
Message-ID: <1471.1359497869@death.nxdomain>
References: <1359458351-6842-1-git-send-email-jiri@resnulli.us> <31155.1359484356@death.nxdomain> <20130129190601.GD7571@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, psimerda@redhat.com, dcbw@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:46035 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591Ab3A2WT4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 17:19:56 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 29 Jan 2013 15:19:52 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id F0EA719D8045
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 15:19:48 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0TMJTvC040780
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 15:19:31 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0TMHvOT027630
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 15:18:00 -0700
In-reply-to: <20130129190601.GD7571@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> wrote:

>Tue, Jan 29, 2013 at 07:32:36PM CET, fubar@us.ibm.com wrote:
>>Jiri Pirko <jiri@resnulli.us> wrote:
>>
>>>Makes more sense to have randomly generated address by default than =
to
>>>have all zeroes. It also allows user to for example put the bond int=
o
>>>bridge without need to have any slaves in it.
>>>
>>>Also note that this changes only behaviour of bonds with no slaves. =
Once
>>>the first slave device is enslaved, its address will be used (no cha=
nge
>>>here).
>>>
>>>Also, fix dev_assign_type values on the way.
>>>
>>>Reported-by: Pavel =C5=A0imerda <psimerda@redhat.com>
>>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>---
>>>
>>>v2->v3:
>>>- call_netdevice_notifiers is called after dev_addr change.
>>>- use bond->get_dev_addr_from_first_slave to know when to get addr f=
rom the
>>>  first slave
>>
>>	Was there a problem with using the dev_addr_type to determine
>>this?  If it's really necessary, I think the name of this field is
>>really verbose; even "addr_from_first" should be sufficient in my min=
d.
>
>It is necessary. Bridge call dev_set_mac_address() which sets
>dev->addr_assign_type =3D NET_ADDR_SET and that causes unwanted behavi=
our.

	Ok.

>And as for the verbosity thing, I like more verbose better in situatio=
ns
>like this. Zero room for confusion.

	Fair enough, but the name doesn't need to be a whole sentence.
I think something like "mac_from_first_slave" is just as clear, and I'd
even go as far as "mac_from_first".  If it's really that complicated
(and I don't think this is), add a comment somewhere.

	-J


>>	-J
>>
>>---
>>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>>
>>
>>>v1->v2:
>>>- fixed assign value of bond_dev->addr_assign_type in bond_set_dev_a=
ddr()
>>>- added note to patch description
>>>
>>> drivers/net/bonding/bond_main.c | 38 +++++++++++++++++++-----------=
--------
>>> drivers/net/bonding/bonding.h   |  1 +
>>> 2 files changed, 20 insertions(+), 19 deletions(-)
>>>
>>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>>>index 564cf42..8692df8 100644
>>>--- a/drivers/net/bonding/bond_main.c
>>>+++ b/drivers/net/bonding/bond_main.c
>>>@@ -1320,14 +1320,15 @@ static void bond_netpoll_cleanup(struct net_=
device *bond_dev)
>>>
>>> /*---------------------------------- IOCTL ------------------------=
----------*/
>>>
>>>-static int bond_sethwaddr(struct net_device *bond_dev,
>>>-			  struct net_device *slave_dev)
>>>+static void bond_set_dev_addr(struct net_device *bond_dev,
>>>+			      struct net_device *slave_dev)
>>> {
>>> 	pr_debug("bond_dev=3D%p\n", bond_dev);
>>> 	pr_debug("slave_dev=3D%p\n", slave_dev);
>>> 	pr_debug("slave_dev->addr_len=3D%d\n", slave_dev->addr_len);
>>> 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_le=
n);
>>>-	return 0;
>>>+	bond_dev->addr_assign_type =3D NET_ADDR_SET;
>>>+	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
>>> }
>>>
>>> static netdev_features_t bond_fix_features(struct net_device *dev,
>>>@@ -1628,10 +1629,8 @@ int bond_enslave(struct net_device *bond_dev,=
 struct net_device *slave_dev)
>>>
>>> 	/* If this is the first slave, then we need to set the master's ha=
rdware
>>> 	 * address to be the same as the slave's. */
>>>-	if (is_zero_ether_addr(bond->dev->dev_addr))
>>>-		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
>>>-		       slave_dev->addr_len);
>>>-
>>>+	if (bond->get_dev_addr_from_first_slave)
>>>+		bond_set_dev_addr(bond->dev, slave_dev);
>>>
>>> 	new_slave =3D kzalloc(sizeof(struct slave), GFP_KERNEL);
>>> 	if (!new_slave) {
>>>@@ -2048,12 +2047,8 @@ int bond_release(struct net_device *bond_dev,=
 struct net_device *slave_dev)
>>>
>>> 	if (bond->slave_cnt =3D=3D 0) {
>>> 		bond_set_carrier(bond);
>>>-
>>>-		/* if the last slave was removed, zero the mac address
>>>-		 * of the master so it will be set by the application
>>>-		 * to the mac address of the first slave
>>>-		 */
>>>-		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
>>>+		eth_hw_addr_random(bond_dev);
>>>+		bond->get_dev_addr_from_first_slave =3D true;
>>>
>>> 		if (bond_vlan_used(bond)) {
>>> 			pr_warning("%s: Warning: clearing HW address of %s while it stil=
l has VLANs.\n",
>>>@@ -2234,11 +2229,8 @@ static int bond_release_all(struct net_device=
 *bond_dev)
>>> 		write_lock_bh(&bond->lock);
>>> 	}
>>>
>>>-	/* zero the mac address of the master so it will be
>>>-	 * set by the application to the mac address of the
>>>-	 * first slave
>>>-	 */
>>>-	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
>>>+	eth_hw_addr_random(bond_dev);
>>>+	bond->get_dev_addr_from_first_slave =3D true;
>>>
>>> 	if (bond_vlan_used(bond)) {
>>> 		pr_warning("%s: Warning: clearing HW address of %s while it still=
 has VLANs.\n",
>>>@@ -3708,7 +3700,8 @@ static int bond_do_ioctl(struct net_device *bo=
nd_dev, struct ifreq *ifr, int cmd
>>> 			break;
>>> 		case BOND_SETHWADDR_OLD:
>>> 		case SIOCBONDSETHWADDR:
>>>-			res =3D bond_sethwaddr(bond_dev, slave_dev);
>>>+			bond_set_dev_addr(bond_dev, slave_dev);
>>>+			res =3D 0;
>>> 			break;
>>> 		case BOND_CHANGE_ACTIVE_OLD:
>>> 		case SIOCBONDCHANGEACTIVE:
>>>@@ -4858,6 +4851,13 @@ static int bond_init(struct net_device *bond_=
dev)
>>>
>>> 	bond_debug_register(bond);
>>>
>>>+	/* Ensure valid dev_addr */
>>>+	if (is_zero_ether_addr(bond_dev->dev_addr) &&
>>>+	    bond_dev->addr_assign_type =3D=3D NET_ADDR_PERM) {
>>>+		eth_hw_addr_random(bond_dev);
>>>+		bond->get_dev_addr_from_first_slave =3D true;
>>>+	}
>>>+
>>> 	__hw_addr_init(&bond->mc_list);
>>> 	return 0;
>>> }
>>>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bon=
ding.h
>>>index 0d282d2..3200638 100644
>>>--- a/drivers/net/bonding/bonding.h
>>>+++ b/drivers/net/bonding/bonding.h
>>>@@ -248,6 +248,7 @@ struct bonding {
>>> 	/* debugging support via debugfs */
>>> 	struct	 dentry *debug_dir;
>>> #endif /* CONFIG_DEBUG_FS */
>>>+	bool	get_dev_addr_from_first_slave;
>>> };
>>>
>>> static inline bool bond_vlan_used(struct bonding *bond)
>>>--=20
>>>1.8.1
>>>
>>
>>--
>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
