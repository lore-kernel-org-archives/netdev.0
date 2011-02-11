From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next-2.6 3/4] bond: implement slave management operations
Date: Fri, 11 Feb 2011 09:19:50 -0800
Message-ID: <22104.1297444790@death>
References: <20110211152125.GA2763@psychotron.brq.redhat.com> <20110211152257.GC2763@psychotron.brq.redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:33249 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757852Ab1BKRT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 12:19:56 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1BD0DIg026817
	for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 08:01:44 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D374972805B
	for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 12:19:54 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1BHJsCK383608
	for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 12:19:54 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1BHJrLp028658
	for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 15:19:54 -0200
In-reply-to: <20110211152257.GC2763@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>---
> drivers/net/bonding/bond_main.c |   38 ++++++++++++++++++++++++++++++++++++++
> 1 files changed, 38 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 1df9f0e..f8e59f9 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c

	I think this would be better served by a new bond_netlink.c
file instead of cramming this into (the already huge) bond_main.c.  In
the long run, there will be a lot more netlink related code in bonding,
so I think it makes sense to give it a file of its own from the
beginning.

>@@ -4285,6 +4285,40 @@ unwind:
> 	return res;
> }
>
>+static int bond_add_slave(struct net_device *bond_dev,
>+			  struct net_device *slave_dev)
>+{
>+	return bond_enslave(bond_dev, slave_dev);
>+}
>+
>+static int bond_del_slave(struct net_device *bond_dev,
>+			  struct net_device *slave_dev)
>+{
>+	return bond_release(bond_dev, slave_dev);
>+}
>+
>+static int bond_get_slave_count(const struct net_device *bond_dev)
>+{
>+	struct bonding *bond = netdev_priv(bond_dev);
>+
>+	return bond->slave_cnt;
>+}
>+
>+static struct net_device *bond_get_slave(const struct net_device *bond_dev,
>+					 int slave_index)
>+{
>+	struct bonding *bond = netdev_priv(bond_dev);
>+	struct slave *slave;
>+	int i;
>+
>+	/* no need to hold bond->lock here, protected against writers by rtnl */
>+	bond_for_each_slave(bond, slave, i) {
>+		if (slave_index == i)
>+			return slave->dev;
>+	}
>+	return NULL;

	I think using the name "slave_index" for this variable is
confusing, since it isn't the ifindex of the slave.  This "index" is
used to iterate through the list of slaves, so perhaps "slave_num" or
"slave_position" is clearer.  The same comment applies to the equivalent
code for bridge.

	-J

>+}
>+
> static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev)
> {
> 	struct bonding *bond = netdev_priv(bond_dev);
>@@ -4657,6 +4691,10 @@ static const struct net_device_ops bond_netdev_ops = {
> 	.ndo_netpoll_cleanup	= bond_netpoll_cleanup,
> 	.ndo_poll_controller	= bond_poll_controller,
> #endif
>+	.ndo_add_slave		= bond_add_slave,
>+	.ndo_del_slave		= bond_del_slave,
>+	.ndo_get_slave_count	= bond_get_slave_count,
>+	.ndo_get_slave		= bond_get_slave,
> };
>
> static void bond_destructor(struct net_device *bond_dev)
>-- 
>1.7.3.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
