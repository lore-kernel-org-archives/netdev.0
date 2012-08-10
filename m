From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 09/15] netpoll: check netpoll tx status on the right device
Date: Fri, 10 Aug 2012 19:24:45 +0800
Message-ID: <1344597891-32242-10-git-send-email-amwang@redhat.com>
References: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952Ab2HJLZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 07:25:45 -0400
In-Reply-To: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although this doesn't matter actually, because netpoll_tx_running()
doesn't use the parameter, the code will be more readable.

For team_dev_queue_xmit() we have to move it down to avoid
compile errors.

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 include/linux/if_team.h         |   30 +++++++++++++++---------------
 net/bridge/br_forward.c         |    2 +-
 3 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e428916..d688a8a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -398,7 +398,7 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 		     sizeof(qdisc_skb_cb(skb)->slave_dev_queue_mapping));
 	skb->queue_mapping = qdisc_skb_cb(skb)->slave_dev_queue_mapping;
 
-	if (unlikely(netpoll_tx_running(slave_dev)))
+	if (unlikely(netpoll_tx_running(bond->dev)))
 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
 	else
 		dev_queue_xmit(skb);
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 6960fc1..aa2e167 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -96,21 +96,6 @@ static inline void team_netpoll_send_skb(struct team_port *port,
 }
 #endif
 
-static inline int team_dev_queue_xmit(struct team *team, struct team_port *port,
-				      struct sk_buff *skb)
-{
-	BUILD_BUG_ON(sizeof(skb->queue_mapping) !=
-		     sizeof(qdisc_skb_cb(skb)->slave_dev_queue_mapping));
-	skb_set_queue_mapping(skb, qdisc_skb_cb(skb)->slave_dev_queue_mapping);
-
-	skb->dev = port->dev;
-	if (unlikely(netpoll_tx_running(port->dev))) {
-		team_netpoll_send_skb(port, skb);
-		return 0;
-	}
-	return dev_queue_xmit(skb);
-}
-
 struct team_mode_ops {
 	int (*init)(struct team *team);
 	void (*exit)(struct team *team);
@@ -200,6 +185,21 @@ struct team {
 	long mode_priv[TEAM_MODE_PRIV_LONGS];
 };
 
+static inline int team_dev_queue_xmit(struct team *team, struct team_port *port,
+				      struct sk_buff *skb)
+{
+	BUILD_BUG_ON(sizeof(skb->queue_mapping) !=
+		     sizeof(qdisc_skb_cb(skb)->slave_dev_queue_mapping));
+	skb_set_queue_mapping(skb, qdisc_skb_cb(skb)->slave_dev_queue_mapping);
+
+	skb->dev = port->dev;
+	if (unlikely(netpoll_tx_running(team->dev))) {
+		team_netpoll_send_skb(port, skb);
+		return 0;
+	}
+	return dev_queue_xmit(skb);
+}
+
 static inline struct hlist_head *team_port_index_hash(struct team *team,
 						      int port_index)
 {
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index e9466d4..02015a5 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -65,7 +65,7 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	skb->dev = to->dev;
 
-	if (unlikely(netpoll_tx_running(to->dev))) {
+	if (unlikely(netpoll_tx_running(to->br->dev))) {
 		if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
 			kfree_skb(skb);
 		else {
-- 
1.7.7.6
