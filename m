From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH next v3 2/6] bonding: implement bond_poll_controller()
Date: Thu, 12 Feb 2015 13:45:44 -0800
Message-ID: <23063.1423777544@famine>
References: <1423715065-9304-1-git-send-email-maheshb@google.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:54800 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbBLVpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 16:45:53 -0500
In-reply-to: <1423715065-9304-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar <maheshb@google.com> wrote:

>This patches implements the poll_controller support for all
>bonding driver. If the slaves have poll_controller net_op defined,
>this implementation calls them. This is mode agnostic implementation
>and iterates through all slaves (based on mode) and calls respective
>handler.
>
>Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>---
>v1:
>   Initial version
>v2:
>   Eliminate bool variable.
>v3:
>   Rebase
>
> drivers/net/bonding/bond_3ad.c  | 24 ++++++++++++++++++++++++
> drivers/net/bonding/bond_main.c | 33 +++++++++++++++++++++++++++++++++
> include/net/bond_3ad.h          |  1 +
> 3 files changed, 58 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 9b436696b95e..14f2ebe786c5 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -2477,6 +2477,30 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
> 	return ret;
> }
> 
>+#define BOND_3AD_PORT_OPERATIONAL \
>+		(AD_STATE_DISTRIBUTING | AD_STATE_COLLECTING | \
>+		 AD_STATE_SYNCHRONIZATION | AD_STATE_AGGREGATION)
>+
>+static int bond_3ad_port_operational(struct slave *slave)
>+{
>+	port_t *port = &SLAVE_AD_INFO(slave)->port;
>+
>+	return bond_slave_can_tx(slave) &&
>+	       (port->actor_oper_port_state & port->partner_oper.port_state &
>+		BOND_3AD_PORT_OPERATIONAL) == BOND_3AD_PORT_OPERATIONAL;
>+}
>+
>+/* bond_3ad_port_is_active - check if a slave port is active or not. A port
>+ * is active when it can forward traffic.
>+ *
>+ * @slave: slave port to check state for.
>+ * Returns: 0 if not active else is active.
>+ */
>+int bond_3ad_port_is_active(struct slave *slave)
>+{
>+	return bond_3ad_port_operational(slave);
>+}
>+

	Why the nesting here?  I don't see other users of
bond_3ad_port_operational, so why not move that logic to
bond_3ad_port_is_active and eliminate the extra level of function call?

	Also, the test in bond_3ad_port_operational will exclude the
case that the active agg port is Individual (e.g., link partner is not
LACP-capable) as that case won't run the state machine to coll-dist
state, but the agg is still available for TX/RX.

	-J


> int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
> 			 struct slave *slave)
> {
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index b979c265fc51..8433fe464f95 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -928,6 +928,39 @@ static inline void slave_disable_netpoll(struct slave *slave)
> 
> static void bond_poll_controller(struct net_device *bond_dev)
> {
>+	struct bonding *bond = netdev_priv(bond_dev);
>+	struct slave *slave = NULL;
>+	struct list_head *iter;
>+	struct ad_info ad_info;
>+	struct netpoll_info *ni;
>+	const struct net_device_ops *ops;
>+
>+	if (BOND_MODE(bond) == BOND_MODE_8023AD)
>+		if (bond_3ad_get_active_agg_info(bond, &ad_info))
>+			return;
>+
>+	bond_for_each_slave(bond, slave, iter) {
>+		ops = slave->dev->netdev_ops;
>+		if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
>+			continue;
>+
>+		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>+			struct aggregator *agg =
>+			    SLAVE_AD_INFO(slave)->port.aggregator;
>+
>+			if (agg && agg->aggregator_identifier !=
>+				   ad_info.aggregator_id)
>+				continue;
>+		    if (!bond_3ad_port_is_active(slave) || ad_info.ports != 1)
>+				continue;

	The above will exclude slaves that are in an aggregator with
more than one member, which is likely to be the usual case.  Is that
intentional?

	Also, if this will only accept slaves from the active
aggregator, and we're limiting it to case that the active agg has
exactly one slave, why do we need to loop through all slaves of the
bond?  Could we do something (inside an "if (mode == 8023AD)" block)
like:

	first_slave = bond_first_slave_rcu(bond);
	[...]
	agg = __get_active_agg(&(SLAVE_AD_INFO(first_slave)->aggregator));
	if (agg->num_of_ports != 1)
		return;
	slave = agg->lag_ports->slave;
	if (!bond_3ad_port_is_active(slave)
		return;
	[...]
	ops->ndo_poll_controller(slave->dev);

	That would need some checks, but, basically, go from the active
aggregator directly to its list of slaves.

	-J

>+		}
>+
>+		ni = rcu_dereference_bh(slave->dev->npinfo);
>+		if (down_trylock(&ni->dev_lock))
>+			continue;
>+		ops->ndo_poll_controller(slave->dev);
>+		up(&ni->dev_lock);
>+	}
> }
> 
> static void bond_netpoll_cleanup(struct net_device *bond_dev)
>diff --git a/include/net/bond_3ad.h b/include/net/bond_3ad.h
>index f04cdbb7848e..6c455c646d61 100644
>--- a/include/net/bond_3ad.h
>+++ b/include/net/bond_3ad.h
>@@ -278,5 +278,6 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
> 			 struct slave *slave);
> int bond_3ad_set_carrier(struct bonding *bond);
> void bond_3ad_update_lacp_rate(struct bonding *bond);
>+int bond_3ad_port_is_active(struct slave *slave);
> #endif /* _NET_BOND_3AD_H */
> 
>-- 
>2.2.0.rc0.207.ga3a616c

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
