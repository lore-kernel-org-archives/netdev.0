From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 04/19] team: lb: push hash counting into separate function
Date: Tue, 19 Jun 2012 17:54:06 +0200
Message-ID: <1340121261-2966-5-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60802 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab2FSPyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:31 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also squash hash into one byte

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team_mode_loadbalance.c |   23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 6452428..a475b13 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -27,18 +27,27 @@ static struct lb_priv *lb_priv(struct team *team)
 	return (struct lb_priv *) &team->mode_priv;
 }
 
-static bool lb_transmit(struct team *team, struct sk_buff *skb)
+static unsigned char lb_get_skb_hash(struct lb_priv *lb_priv,
+				     struct sk_buff *skb)
 {
 	struct sk_filter *fp;
+	uint32_t lhash;
+	unsigned char *c;
+
+	fp = rcu_dereference(lb_priv->fp);
+	if (unlikely(!fp))
+		return 0;
+	lhash = SK_RUN_FILTER(fp, skb);
+	c = (char *) &lhash;
+	return c[0] ^ c[1] ^ c[2] ^ c[3];
+}
+
+static bool lb_transmit(struct team *team, struct sk_buff *skb)
+{
 	struct team_port *port;
-	unsigned int hash;
 	int port_index;
 
-	fp = rcu_dereference(lb_priv(team)->fp);
-	if (unlikely(!fp))
-		goto drop;
-	hash = SK_RUN_FILTER(fp, skb);
-	port_index = hash % team->en_port_count;
+	port_index = lb_get_skb_hash(lb_priv(team), skb) % team->en_port_count;
 	port = team_get_port_by_index_rcu(team, port_index);
 	if (unlikely(!port))
 		goto drop;
-- 
1.7.10.2
