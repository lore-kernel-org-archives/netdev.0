From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] bonding: add slave_changelink support and use it for queue_id
Date: Wed, 27 Aug 2014 16:06:46 +0200
Message-ID: <1409148406-5576-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934604AbaH0OII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 10:08:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for slave_changelink to the bonding and uses it
to give the ability to change the queue_id of the enslaved devices via
netlink. It sets slave_maxtype and uses bond_changelink as a prototype for
bond_slave_changelink.
Example/test command after the iproute2 patch:
 ip link set eth0 type bond_slave queue_id 10

CC: David S. Miller <davem@davemloft.net>
CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>

Suggested-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
note: I intend to add a new option flag to indicate it's a slave option
      so a new netdev notifier can be called (NETDEV_CHANGESLAVEINFODATA).
      I believe the bonding is the first user of slave_changelink so I hope
      I haven't missed anything. Once this patch is accepted in some form
      I'll post the iproute2 one.

 drivers/net/bonding/bond_netlink.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index d163e112f04c..1570deab112e 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -107,6 +107,33 @@ static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static int bond_slave_changelink(struct net_device *bond_dev,
+				 struct net_device *slave_dev,
+				 struct nlattr *tb[], struct nlattr *data[])
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct bond_opt_value newval;
+	int err;
+
+	if (!data)
+		return 0;
+
+	if (data[IFLA_BOND_SLAVE_QUEUE_ID]) {
+		u16 queue_id = nla_get_u16(data[IFLA_BOND_SLAVE_QUEUE_ID]);
+		char queue_id_str[IFNAMSIZ + 7];
+
+		/* queue_id option setting expects slave_name:queue_id */
+		snprintf(queue_id_str, sizeof(queue_id_str), "%s:%u\n",
+			 slave_dev->name, queue_id);
+		bond_opt_initstr(&newval, queue_id_str);
+		err = __bond_opt_set(bond, BOND_OPT_QUEUE_ID, &newval);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int bond_changelink(struct net_device *bond_dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
@@ -553,10 +580,12 @@ struct rtnl_link_ops bond_link_ops __read_mostly = {
 	.priv_size		= sizeof(struct bonding),
 	.setup			= bond_setup,
 	.maxtype		= IFLA_BOND_MAX,
+	.slave_maxtype		= IFLA_BOND_SLAVE_MAX,
 	.policy			= bond_policy,
 	.validate		= bond_validate,
 	.newlink		= bond_newlink,
 	.changelink		= bond_changelink,
+	.slave_changelink	= bond_slave_changelink,
 	.get_size		= bond_get_size,
 	.fill_info		= bond_fill_info,
 	.get_num_tx_queues	= bond_get_num_tx_queues,
-- 
1.9.3
