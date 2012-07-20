From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/6] team: add multiqueue support
Date: Fri, 20 Jul 2012 14:28:51 +0200
Message-ID: <1342787331-1866-7-git-send-email-jiri@resnulli.us>
References: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, shemminger@vyatta.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34608 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab2GTM3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 08:29:13 -0400
Received: by mail-we0-f174.google.com with SMTP id x8so2559855wey.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 05:29:12 -0700 (PDT)
In-Reply-To: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Largely copied from bonding code.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c |   65 +++++++++++++++++++++++++++++++++++++++++++----
 include/linux/if_team.h |    8 ++++++
 2 files changed, 68 insertions(+), 5 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 813e131..b104c05 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -27,6 +27,7 @@
 #include <net/rtnetlink.h>
 #include <net/genetlink.h>
 #include <net/netlink.h>
+#include <net/sch_generic.h>
 #include <linux/if_team.h>
 
 #define DRV_NAME "team"
@@ -1121,6 +1122,22 @@ static const struct team_option team_options[] = {
 	},
 };
 
+static struct lock_class_key team_netdev_xmit_lock_key;
+static struct lock_class_key team_netdev_addr_lock_key;
+
+static void team_set_lockdep_class_one(struct net_device *dev,
+				       struct netdev_queue *txq,
+				       void *unused)
+{
+	lockdep_set_class(&txq->_xmit_lock, &team_netdev_xmit_lock_key);
+}
+
+static void team_set_lockdep_class(struct net_device *dev)
+{
+	lockdep_set_class(&dev->addr_list_lock, &team_netdev_addr_lock_key);
+	netdev_for_each_tx_queue(dev, team_set_lockdep_class_one, NULL);
+}
+
 static int team_init(struct net_device *dev)
 {
 	struct team *team = netdev_priv(dev);
@@ -1148,6 +1165,8 @@ static int team_init(struct net_device *dev)
 		goto err_options_register;
 	netif_carrier_off(dev);
 
+	team_set_lockdep_class(dev);
+
 	return 0;
 
 err_options_register:
@@ -1216,6 +1235,29 @@ static netdev_tx_t team_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static u16 team_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	/*
+	 * This helper function exists to help dev_pick_tx get the correct
+	 * destination queue.  Using a helper function skips a call to
+	 * skb_tx_hash and will put the skbs in the queue we expect on their
+	 * way down to the team driver.
+	 */
+	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
+
+	/*
+	 * Save the original txq to restore before passing to the driver
+	 */
+	qdisc_skb_cb(skb)->slave_dev_queue_mapping = skb->queue_mapping;
+
+	if (unlikely(txq >= dev->real_num_tx_queues)) {
+		do {
+			txq -= dev->real_num_tx_queues;
+		} while (txq >= dev->real_num_tx_queues);
+	}
+	return txq;
+}
+
 static void team_change_rx_flags(struct net_device *dev, int change)
 {
 	struct team *team = netdev_priv(dev);
@@ -1469,6 +1511,7 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_open		= team_open,
 	.ndo_stop		= team_close,
 	.ndo_start_xmit		= team_xmit,
+	.ndo_select_queue	= team_select_queue,
 	.ndo_change_rx_flags	= team_change_rx_flags,
 	.ndo_set_rx_mode	= team_set_rx_mode,
 	.ndo_set_mac_address	= team_set_mac_address,
@@ -1543,12 +1586,24 @@ static int team_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static unsigned int team_get_num_tx_queues(void)
+{
+	return TEAM_DEFAULT_NUM_TX_QUEUES;
+}
+
+static unsigned int team_get_num_rx_queues(void)
+{
+	return TEAM_DEFAULT_NUM_RX_QUEUES;
+}
+
 static struct rtnl_link_ops team_link_ops __read_mostly = {
-	.kind		= DRV_NAME,
-	.priv_size	= sizeof(struct team),
-	.setup		= team_setup,
-	.newlink	= team_newlink,
-	.validate	= team_validate,
+	.kind			= DRV_NAME,
+	.priv_size		= sizeof(struct team),
+	.setup			= team_setup,
+	.newlink		= team_newlink,
+	.validate		= team_validate,
+	.get_num_tx_queues	= team_get_num_tx_queues,
+	.get_num_rx_queues	= team_get_num_rx_queues,
 };
 
 
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 7fd0cde..6960fc1 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -14,6 +14,7 @@
 #ifdef __KERNEL__
 
 #include <linux/netpoll.h>
+#include <net/sch_generic.h>
 
 struct team_pcpu_stats {
 	u64			rx_packets;
@@ -98,6 +99,10 @@ static inline void team_netpoll_send_skb(struct team_port *port,
 static inline int team_dev_queue_xmit(struct team *team, struct team_port *port,
 				      struct sk_buff *skb)
 {
+	BUILD_BUG_ON(sizeof(skb->queue_mapping) !=
+		     sizeof(qdisc_skb_cb(skb)->slave_dev_queue_mapping));
+	skb_set_queue_mapping(skb, qdisc_skb_cb(skb)->slave_dev_queue_mapping);
+
 	skb->dev = port->dev;
 	if (unlikely(netpoll_tx_running(port->dev))) {
 		team_netpoll_send_skb(port, skb);
@@ -236,6 +241,9 @@ extern void team_options_unregister(struct team *team,
 extern int team_mode_register(const struct team_mode *mode);
 extern void team_mode_unregister(const struct team_mode *mode);
 
+#define TEAM_DEFAULT_NUM_TX_QUEUES 16
+#define TEAM_DEFAULT_NUM_RX_QUEUES 16
+
 #endif /* __KERNEL__ */
 
 #define TEAM_STRING_MAX_LEN 32
-- 
1.7.10.4
