From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 3/4] bond: implement slave management
 operations
Date: Fri, 11 Feb 2011 18:51:40 +0100
Message-ID: <20110211175139.GB2578@psychotron.redhat.com>
References: <20110211152125.GA2763@psychotron.brq.redhat.com>
 <20110211152257.GC2763@psychotron.brq.redhat.com>
 <22104.1297444790@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51914 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757887Ab1BKS2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 13:28:24 -0500
Content-Disposition: inline
In-Reply-To: <22104.1297444790@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 11, 2011 at 06:19:50PM CET, fubar@us.ibm.com wrote:
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>---
>> drivers/net/bonding/bond_main.c |   38 ++++++++++++++++++++++++++++++++++++++
>> 1 files changed, 38 insertions(+), 0 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>index 1df9f0e..f8e59f9 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>
>	I think this would be better served by a new bond_netlink.c
>file instead of cramming this into (the already huge) bond_main.c.  In
>the long run, there will be a lot more netlink related code in bonding,
>so I think it makes sense to give it a file of its own from the
>beginning.

Well technically is not netlink code so givin it into *netlink* file
would imho make no sense.

>
>>@@ -4285,6 +4285,40 @@ unwind:
>> 	return res;
>> }
>>
>>+static int bond_add_slave(struct net_device *bond_dev,
>>+			  struct net_device *slave_dev)
>>+{
>>+	return bond_enslave(bond_dev, slave_dev);
>>+}
>>+
>>+static int bond_del_slave(struct net_device *bond_dev,
>>+			  struct net_device *slave_dev)
>>+{
>>+	return bond_release(bond_dev, slave_dev);
>>+}
>>+
>>+static int bond_get_slave_count(const struct net_device *bond_dev)
>>+{
>>+	struct bonding *bond = netdev_priv(bond_dev);
>>+
>>+	return bond->slave_cnt;
>>+}
>>+
>>+static struct net_device *bond_get_slave(const struct net_device *bond_dev,
>>+					 int slave_index)
>>+{
>>+	struct bonding *bond = netdev_priv(bond_dev);
>>+	struct slave *slave;
>>+	int i;
>>+
>>+	/* no need to hold bond->lock here, protected against writers by rtnl */
>>+	bond_for_each_slave(bond, slave, i) {
>>+		if (slave_index == i)
>>+			return slave->dev;
>>+	}
>>+	return NULL;
>
>	I think using the name "slave_index" for this variable is
>confusing, since it isn't the ifindex of the slave.  This "index" is
>used to iterate through the list of slaves, so perhaps "slave_num" or
>"slave_position" is clearer.  The same comment applies to the equivalent
>code for bridge.
>
>	-J
>
>>+}
>>+
>> static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev)
>> {
>> 	struct bonding *bond = netdev_priv(bond_dev);
>>@@ -4657,6 +4691,10 @@ static const struct net_device_ops bond_netdev_ops = {
>> 	.ndo_netpoll_cleanup	= bond_netpoll_cleanup,
>> 	.ndo_poll_controller	= bond_poll_controller,
>> #endif
>>+	.ndo_add_slave		= bond_add_slave,
>>+	.ndo_del_slave		= bond_del_slave,
>>+	.ndo_get_slave_count	= bond_get_slave_count,
>>+	.ndo_get_slave		= bond_get_slave,
>> };
>>
>> static void bond_destructor(struct net_device *bond_dev)
>>-- 
>>1.7.3.4
>>
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
