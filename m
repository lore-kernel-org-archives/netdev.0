From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 19/19] team: use rcu_dereference_bh() in tx path
Date: Tue, 19 Jun 2012 17:54:21 +0200
Message-ID: <1340121261-2966-20-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754637Ab2FSPyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:55 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should be used instead of rcu_dereference, since rcu_read_lock_bh is
held.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team_mode_activebackup.c |    2 +-
 drivers/net/team/team_mode_loadbalance.c  |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index bcc7d6d..2fe02a8 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -40,7 +40,7 @@ static bool ab_transmit(struct team *team, struct sk_buff *skb)
 {
 	struct team_port *active_port;
 
-	active_port = rcu_dereference(ab_priv(team)->active_port);
+	active_port = rcu_dereference_bh(ab_priv(team)->active_port);
 	if (unlikely(!active_port))
 		goto drop;
 	skb->dev = active_port->dev;
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 33e30ed..45cc095 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -124,7 +124,7 @@ static struct team_port *lb_htpm_select_tx_port(struct team *team,
 						struct sk_buff *skb,
 						unsigned char hash)
 {
-	return rcu_dereference(LB_HTPM_PORT_BY_HASH(lb_priv, hash));
+	return rcu_dereference_bh(LB_HTPM_PORT_BY_HASH(lb_priv, hash));
 }
 
 struct lb_select_tx_port {
@@ -179,7 +179,7 @@ static unsigned int lb_get_skb_hash(struct lb_priv *lb_priv,
 	uint32_t lhash;
 	unsigned char *c;
 
-	fp = rcu_dereference(lb_priv->fp);
+	fp = rcu_dereference_bh(lb_priv->fp);
 	if (unlikely(!fp))
 		return 0;
 	lhash = SK_RUN_FILTER(fp, skb);
@@ -213,7 +213,7 @@ static bool lb_transmit(struct team *team, struct sk_buff *skb)
 	unsigned int tx_bytes = skb->len;
 
 	hash = lb_get_skb_hash(lb_priv, skb);
-	select_tx_port_func = rcu_dereference(lb_priv->select_tx_port_func);
+	select_tx_port_func = rcu_dereference_bh(lb_priv->select_tx_port_func);
 	port = select_tx_port_func(team, lb_priv, skb, hash);
 	if (unlikely(!port))
 		goto drop;
-- 
1.7.10.2
