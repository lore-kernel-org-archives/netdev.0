From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next] bond: have random dev address by default instead of zeroes
Date: Thu, 24 Jan 2013 09:12:49 -0800
Message-ID: <7112.1359047569@death.nxdomain>
References: <1359022329-6919-1-git-send-email-jiri@resnulli.us>
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:35073 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab3AXRN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 12:13:58 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 24 Jan 2013 10:13:57 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 5E4E83E4003E
	for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 10:13:45 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0OHDaNq083060
	for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 10:13:41 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0OHFLHA009372
	for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 10:15:26 -0700
In-reply-to: <1359022329-6919-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> wrote:

>Makes more sense to have randomly generated address by default than to
>have all zeroes. It also allows user to for example put the bond into
>bridge without need to have any slaves in it.
>
>Also, fix dev_assign_type values on the way.
>
>Signed-off-by: Jiri Pirko <jiri@resnulli.us>

	This patch appears to provide a random MAC, which is then
replaced with the first slave's MAC at enslavement time.  A more in
depth commit message would be helpful here; I presumed from the above
that the bond's MAC was being set to a random MAC and the first slave
behavior was changing, but inspection of the code suggests otherwise.

	Does this have any practical change other than permitting
enslavement to a bridge prior to the bond having any slaves?

	I also have one code comment, below.

> drivers/net/bonding/bond_main.c | 28 ++++++++++++++++------------
> 1 file changed, 16 insertions(+), 12 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 564cf42..af3a777 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1320,14 +1320,14 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
>
> /*---------------------------------- IOCTL ----------------------------------*/
>
>-static int bond_sethwaddr(struct net_device *bond_dev,
>-			  struct net_device *slave_dev)
>+static void bond_set_dev_addr(struct net_device *bond_dev,
>+			      struct net_device *slave_dev)
> {
> 	pr_debug("bond_dev=%p\n", bond_dev);
> 	pr_debug("slave_dev=%p\n", slave_dev);
> 	pr_debug("slave_dev->addr_len=%d\n", slave_dev->addr_len);
> 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
>-	return 0;
>+	bond_dev->addr_assign_type |= NET_ADDR_SET;

	This is a bitwise assignment, but addr_assign_type is not a
bitmask.  If addr_assign_type is not 0 prior to this, this will create
an illegal value in the field.

	-J

> }
>
> static netdev_features_t bond_fix_features(struct net_device *dev,
>@@ -1628,10 +1628,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>
> 	/* If this is the first slave, then we need to set the master's hardware
> 	 * address to be the same as the slave's. */
>-	if (is_zero_ether_addr(bond->dev->dev_addr))
>-		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
>-		       slave_dev->addr_len);
>-
>+	if (bond->dev->addr_assign_type != NET_ADDR_SET)
>+		bond_set_dev_addr(bond->dev, slave_dev);
>
> 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
> 	if (!new_slave) {
>@@ -2049,11 +2047,11 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
> 	if (bond->slave_cnt == 0) {
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
> 			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
>@@ -3708,7 +3706,8 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
> 			break;
> 		case BOND_SETHWADDR_OLD:
> 		case SIOCBONDSETHWADDR:
>-			res = bond_sethwaddr(bond_dev, slave_dev);
>+			bond_set_dev_addr(bond_dev, slave_dev);
>+			res = 0;
> 			break;
> 		case BOND_CHANGE_ACTIVE_OLD:
> 		case SIOCBONDCHANGEACTIVE:
>@@ -4858,6 +4857,11 @@ static int bond_init(struct net_device *bond_dev)
>
> 	bond_debug_register(bond);
>
>+	/* Ensure valid dev_addr */
>+	if (is_zero_ether_addr(bond_dev->dev_addr) &&
>+	    bond_dev->addr_assign_type == NET_ADDR_PERM)
>+		eth_hw_addr_random(bond_dev);
>+
> 	__hw_addr_init(&bond->mc_list);
> 	return 0;
> }
>-- 
>1.8.1
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
