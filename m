From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/6] rtnl: allow to specify different num for rx and tx queue count
Date: Fri, 20 Jul 2012 14:28:47 +0200
Message-ID: <1342787331-1866-3-git-send-email-jiri@resnulli.us>
References: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, shemminger@vyatta.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:40446 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab2GTM3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 08:29:03 -0400
Received: by wgbfm10 with SMTP id fm10so489884wgb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 05:29:01 -0700 (PDT)
In-Reply-To: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also cut out unused function parameters and possible err in return
value.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c |   14 ++++++++------
 include/net/rtnetlink.h         |   10 ++++++----
 net/core/rtnetlink.c            |   16 ++++++++--------
 3 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3960b1b..f41ddc2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4845,17 +4845,19 @@ static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int bond_get_tx_queues(struct net *net, struct nlattr *tb[])
+static unsigned int bond_get_num_tx_queues(void)
 {
 	return tx_queues;
 }
 
 static struct rtnl_link_ops bond_link_ops __read_mostly = {
-	.kind		= "bond",
-	.priv_size	= sizeof(struct bonding),
-	.setup		= bond_setup,
-	.validate	= bond_validate,
-	.get_tx_queues	= bond_get_tx_queues,
+	.kind			= "bond",
+	.priv_size		= sizeof(struct bonding),
+	.setup			= bond_setup,
+	.validate		= bond_validate,
+	.get_num_tx_queues	= bond_get_num_tx_queues,
+	.get_num_rx_queues	= bond_get_num_tx_queues, /* Use the same number
+							     as for TX queues */
 };
 
 /* Create a new bond based on the specified name and bonding parameters.
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index bbcfd09..6b00c4f 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -44,8 +44,10 @@ static inline int rtnl_msg_family(const struct nlmsghdr *nlh)
  *	@get_xstats_size: Function to calculate required room for dumping device
  *			  specific statistics
  *	@fill_xstats: Function to dump device specific statistics
- *	@get_tx_queues: Function to determine number of transmit queues to create when
- *		        creating a new device.
+ *	@get_num_tx_queues: Function to determine number of transmit queues
+ *			    to create when creating a new device.
+ *	@get_num_rx_queues: Function to determine number of receive queues
+ *			    to create when creating a new device.
  */
 struct rtnl_link_ops {
 	struct list_head	list;
@@ -77,8 +79,8 @@ struct rtnl_link_ops {
 	size_t			(*get_xstats_size)(const struct net_device *dev);
 	int			(*fill_xstats)(struct sk_buff *skb,
 					       const struct net_device *dev);
-	int			(*get_tx_queues)(struct net *net,
-						 struct nlattr *tb[]);
+	unsigned int		(*get_num_tx_queues)(void);
+	unsigned int		(*get_num_rx_queues)(void);
 };
 
 extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 045db8a..db5a8ad 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1624,17 +1624,17 @@ struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
 {
 	int err;
 	struct net_device *dev;
-	unsigned int num_queues = 1;
+	unsigned int num_tx_queues = 1;
+	unsigned int num_rx_queues = 1;
 
-	if (ops->get_tx_queues) {
-		err = ops->get_tx_queues(src_net, tb);
-		if (err < 0)
-			goto err;
-		num_queues = err;
-	}
+	if (ops->get_num_tx_queues)
+		num_tx_queues = ops->get_num_tx_queues();
+	if (ops->get_num_rx_queues)
+		num_rx_queues = ops->get_num_rx_queues();
 
 	err = -ENOMEM;
-	dev = alloc_netdev_mq(ops->priv_size, ifname, ops->setup, num_queues);
+	dev = alloc_netdev_mqs(ops->priv_size, ifname, ops->setup,
+			       num_tx_queues, num_rx_queues);
 	if (!dev)
 		goto err;
 
-- 
1.7.10.4
