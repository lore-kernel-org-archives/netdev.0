From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] team: remove synchronize_rcu() called during port disable
Date: Mon, 10 Jun 2013 17:42:25 +0200
Message-ID: <1370878945-9718-4-git-send-email-jiri@resnulli.us>
References: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:45651 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079Ab3FJPnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 11:43:06 -0400
Received: by mail-ea0-f177.google.com with SMTP id j14so5487057eak.36
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 08:43:05 -0700 (PDT)
In-Reply-To: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check the unlikely case of team->en_port_count == 0 before modulo
operation.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c                  | 20 +++++---------------
 drivers/net/team/team_mode_loadbalance.c |  3 +--
 drivers/net/team/team_mode_roundrobin.c  |  3 ++-
 include/linux/if_team.h                  | 10 ++++++++++
 4 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 4982aed..bff7e0b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -525,31 +525,26 @@ static void team_set_no_mode(struct team *team)
 	team->mode = &__team_no_mode;
 }
 
-static void __team_adjust_ops(struct team *team, int en_port_count)
+static void team_adjust_ops(struct team *team)
 {
 	/*
 	 * To avoid checks in rx/tx skb paths, ensure here that non-null and
 	 * correct ops are always set.
 	 */
 
-	if (!en_port_count || !team_is_mode_set(team) ||
+	if (!team->en_port_count || !team_is_mode_set(team) ||
 	    !team->mode->ops->transmit)
 		team->ops.transmit = team_dummy_transmit;
 	else
 		team->ops.transmit = team->mode->ops->transmit;
 
-	if (!en_port_count || !team_is_mode_set(team) ||
+	if (!team->en_port_count || !team_is_mode_set(team) ||
 	    !team->mode->ops->receive)
 		team->ops.receive = team_dummy_receive;
 	else
 		team->ops.receive = team->mode->ops->receive;
 }
 
-static void team_adjust_ops(struct team *team)
-{
-	__team_adjust_ops(team, team->en_port_count);
-}
-
 /*
  * We can benefit from the fact that it's ensured no port is present
  * at the time of mode change. Therefore no packets are in fly so there's no
@@ -877,14 +872,9 @@ static void team_port_disable(struct team *team,
 	hlist_del_rcu(&port->hlist);
 	__reconstruct_port_hlist(team, port->index);
 	port->index = -1;
-	team_queue_override_port_del(team, port);
-	__team_adjust_ops(team, team->en_port_count - 1);
-	/*
-	 * Wait until readers see adjusted ops. This ensures that
-	 * readers never see team->en_port_count == 0
-	 */
-	synchronize_rcu();
 	team->en_port_count--;
+	team_queue_override_port_del(team, port);
+	team_adjust_ops(team);
 }
 
 #define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index cdc31b5..829a9cd 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -112,9 +112,8 @@ static struct team_port *lb_hash_select_tx_port(struct team *team,
 						struct sk_buff *skb,
 						unsigned char hash)
 {
-	int port_index;
+	int port_index = team_num_to_port_index(team, hash);
 
-	port_index = hash % team->en_port_count;
 	return team_get_port_by_index_rcu(team, port_index);
 }
 
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index 472623f..5366585 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -30,7 +30,8 @@ static bool rr_transmit(struct team *team, struct sk_buff *skb)
 	struct team_port *port;
 	int port_index;
 
-	port_index = rr_priv(team)->sent_packets++ % team->en_port_count;
+	port_index = team_num_to_port_index(team,
+					    rr_priv(team)->sent_packets++);
 	port = team_get_port_by_index_rcu(team, port_index);
 	if (unlikely(!port))
 		goto drop;
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 556b791..f6156f9 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -229,6 +229,16 @@ static inline struct team_port *team_get_port_by_index(struct team *team,
 			return port;
 	return NULL;
 }
+
+static inline int team_num_to_port_index(struct team *team, int num)
+{
+	int en_port_count = ACCESS_ONCE(team->en_port_count);
+
+	if (unlikely(!en_port_count))
+		return 0;
+	return num % en_port_count;
+}
+
 static inline struct team_port *team_get_port_by_index_rcu(struct team *team,
 							   int port_index)
 {
-- 
1.8.1.4
