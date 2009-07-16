From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: clean muticast addresses when bevice changes type
Date: Thu, 16 Jul 2009 13:57:59 -0700
Message-ID: <29772.1247777879@death.nxdomain.ibm.com>
References: <4A5DEE1F.4090707@Voltaire.COM>
Cc: David Miller <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	bonding-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Moni Shoua <monis@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:35277 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933357AbZGPU56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 16:57:58 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6GKroJ3014006
	for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 14:53:50 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6GKvvp7213934
	for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 14:57:57 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6GKvuQ4007814
	for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 14:57:57 -0600
In-reply-to: <4A5DEE1F.4090707@Voltaire.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moni Shoua <monis@voltaire.com> wrote:

>Bonding device  forbids slave device of different types under the same master.
>However, it is possible for a bonding master to change  type during its lifetime. 
>This can be either from ARPHRD_ETHER to ARPHRD_INFINIBAND or the other way arround.  
>The change of type requires device level multicast address cleanup because device
>level multicast addresses depend on the device type. 
>
>The patch adds a call to dev_close() before the bonding master changes type and 
>dev_open() just after that.
>
>In the example below I enslaved an IPoIB device (ib0) under bond0. Since
>each bonding master starts as device of type ARPHRD_ETHER by default, a change
>of type occurs when ib0 is enslaved.
>
>This is how /proc/net/dev_mcast looks like without the patch
>
>5    bond0           1     0     00ffffffff12601bffff000000000001ff96ca05
>5    bond0           1     0     01005e000116
>5    bond0           1     0     01005e7ffffd
>5    bond0           1     0     01005e000001
>5    bond0           1     0     333300000001
>6    ib0             1     0     00ffffffff12601bffff000000000001ff96ca05
>6    ib0             1     0     333300000001
>6    ib0             1     0     01005e000001
>6    ib0             1     0     01005e7ffffd
>6    ib0             1     0     01005e000116
>6    ib0             1     0     00ffffffff12401bffff00000000000000000001
>6    ib0             1     0     00ffffffff12601bffff00000000000000000001
>
>and this is how it looks like after the patch.
>
>5    bond0           1     0     00ffffffff12601bffff000000000001ff96ca05
>5    bond0           1     0     00ffffffff12601bffff00000000000000000001
>5    bond0           1     0     00ffffffff12401bffff0000000000000ffffffd
>5    bond0           1     0     00ffffffff12401bffff00000000000000000116
>5    bond0           1     0     00ffffffff12401bffff00000000000000000001
>6    ib0             1     0     00ffffffff12601bffff000000000001ff96ca05
>6    ib0             1     0     00ffffffff12401bffff00000000000000000116
>6    ib0             1     0     00ffffffff12401bffff0000000000000ffffffd
>6    ib0             2     0     00ffffffff12401bffff00000000000000000001
>6    ib0             2     0     00ffffffff12601bffff00000000000000000001
>
>Signed-off-by: Moni Shoua <monis@voltaire.com>

	I checked the discussion noted in a separate email, and the
rationale seems reasonable.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>
> drivers/net/bonding/bond_main.c |   12 ++++++++++--
> 1 file changed, 10 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index d927f71..aa1be1f 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1459,8 +1459,16 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 	 * ether type (eg ARPHRD_ETHER and ARPHRD_INFINIBAND) share the same bond
> 	 */
> 	if (bond->slave_cnt == 0) {
>-		if (slave_dev->type != ARPHRD_ETHER)
>-			bond_setup_by_slave(bond_dev, slave_dev);
>+		if (bond_dev->type != slave_dev->type) {
>+			dev_close(bond_dev);
>+			pr_debug("%s: change device type from %d to %d\n",
>+				bond_dev->name, bond_dev->type, slave_dev->type);
>+			if (slave_dev->type != ARPHRD_ETHER)
>+				bond_setup_by_slave(bond_dev, slave_dev);
>+			else
>+				ether_setup(bond_dev);
>+			dev_open(bond_dev);
>+		}
> 	} else if (bond_dev->type != slave_dev->type) {
> 		pr_err(DRV_NAME ": %s ether type (%d) is different "
> 			"from other slaves (%d), can not enslave it.\n",
