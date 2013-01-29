From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next V3] bond: have random dev address by default
 instead of zeroes
Date: Tue, 29 Jan 2013 20:06:01 +0100
Message-ID: <20130129190601.GD7571@minipsycho.orion>
References: <1359458351-6842-1-git-send-email-jiri@resnulli.us>
 <31155.1359484356@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, psimerda@redhat.com, dcbw@redhat.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:59809 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754324Ab3A2TGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 14:06:11 -0500
Received: by mail-we0-f175.google.com with SMTP id x8so571675wey.20
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 11:06:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <31155.1359484356@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 29, 2013 at 07:32:36PM CET, fubar@us.ibm.com wrote:
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
>>---
>>
>>v2->v3:
>>- call_netdevice_notifiers is called after dev_addr change.
>>- use bond->get_dev_addr_from_first_slave to know when to get addr fr=
om the
>>  first slave
>
>	Was there a problem with using the dev_addr_type to determine
>this?  If it's really necessary, I think the name of this field is
>really verbose; even "addr_from_first" should be sufficient in my mind=
=2E

It is necessary. Bridge call dev_set_mac_address() which sets
dev->addr_assign_type =3D NET_ADDR_SET and that causes unwanted behavio=
ur.

And as for the verbosity thing, I like more verbose better in situation=
s
like this. Zero room for confusion.


>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
>
>>v1->v2:
>>- fixed assign value of bond_dev->addr_assign_type in bond_set_dev_ad=
dr()
>>- added note to patch description
>>
>> drivers/net/bonding/bond_main.c | 38 +++++++++++++++++++------------=
-------
>> drivers/net/bonding/bonding.h   |  1 +
>> 2 files changed, 20 insertions(+), 19 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
>>index 564cf42..8692df8 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -1320,14 +1320,15 @@ static void bond_netpoll_cleanup(struct net_d=
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
>>+	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
>> }
>>
>> static netdev_features_t bond_fix_features(struct net_device *dev,
>>@@ -1628,10 +1629,8 @@ int bond_enslave(struct net_device *bond_dev, =
struct net_device *slave_dev)
>>
>> 	/* If this is the first slave, then we need to set the master's har=
dware
>> 	 * address to be the same as the slave's. */
>>-	if (is_zero_ether_addr(bond->dev->dev_addr))
>>-		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
>>-		       slave_dev->addr_len);
>>-
>>+	if (bond->get_dev_addr_from_first_slave)
>>+		bond_set_dev_addr(bond->dev, slave_dev);
>>
>> 	new_slave =3D kzalloc(sizeof(struct slave), GFP_KERNEL);
>> 	if (!new_slave) {
>>@@ -2048,12 +2047,8 @@ int bond_release(struct net_device *bond_dev, =
struct net_device *slave_dev)
>>
>> 	if (bond->slave_cnt =3D=3D 0) {
>> 		bond_set_carrier(bond);
>>-
>>-		/* if the last slave was removed, zero the mac address
>>-		 * of the master so it will be set by the application
>>-		 * to the mac address of the first slave
>>-		 */
>>-		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
>>+		eth_hw_addr_random(bond_dev);
>>+		bond->get_dev_addr_from_first_slave =3D true;
>>
>> 		if (bond_vlan_used(bond)) {
>> 			pr_warning("%s: Warning: clearing HW address of %s while it still=
 has VLANs.\n",
>>@@ -2234,11 +2229,8 @@ static int bond_release_all(struct net_device =
*bond_dev)
>> 		write_lock_bh(&bond->lock);
>> 	}
>>
>>-	/* zero the mac address of the master so it will be
>>-	 * set by the application to the mac address of the
>>-	 * first slave
>>-	 */
>>-	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
>>+	eth_hw_addr_random(bond_dev);
>>+	bond->get_dev_addr_from_first_slave =3D true;
>>
>> 	if (bond_vlan_used(bond)) {
>> 		pr_warning("%s: Warning: clearing HW address of %s while it still =
has VLANs.\n",
>>@@ -3708,7 +3700,8 @@ static int bond_do_ioctl(struct net_device *bon=
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
>>@@ -4858,6 +4851,13 @@ static int bond_init(struct net_device *bond_d=
ev)
>>
>> 	bond_debug_register(bond);
>>
>>+	/* Ensure valid dev_addr */
>>+	if (is_zero_ether_addr(bond_dev->dev_addr) &&
>>+	    bond_dev->addr_assign_type =3D=3D NET_ADDR_PERM) {
>>+		eth_hw_addr_random(bond_dev);
>>+		bond->get_dev_addr_from_first_slave =3D true;
>>+	}
>>+
>> 	__hw_addr_init(&bond->mc_list);
>> 	return 0;
>> }
>>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bond=
ing.h
>>index 0d282d2..3200638 100644
>>--- a/drivers/net/bonding/bonding.h
>>+++ b/drivers/net/bonding/bonding.h
>>@@ -248,6 +248,7 @@ struct bonding {
>> 	/* debugging support via debugfs */
>> 	struct	 dentry *debug_dir;
>> #endif /* CONFIG_DEBUG_FS */
>>+	bool	get_dev_addr_from_first_slave;
>> };
>>
>> static inline bool bond_vlan_used(struct bonding *bond)
>>--=20
>>1.8.1
>>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
