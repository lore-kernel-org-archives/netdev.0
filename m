From: Jim Hanko <hanko@drivescale.com>
Subject: [patch net-next] team: fall back to hash if table entry is empty
Date: Tue, 19 Sep 2017 11:33:39 -0700
Message-ID: <1505846019-6785-1-git-send-email-hanko@drivescale.com>
Cc: Jim Hanko <hanko@drivescale.com>
To: jiri@resnulli.us, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the hash to port mapping table does not have a valid port (i.e. when
a port goes down), fall back to the simple hashing mechanism to avoid
dropping packets.

Signed-off-by: Jim Hanko <hanko@drivescale.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/team/team_mode_loadbalance.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 1468ddf..a5ef970 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -137,7 +137,13 @@ static struct team_port *lb_htpm_select_tx_port(struct team *team,
 						struct sk_buff *skb,
 						unsigned char hash)
 {
-	return rcu_dereference_bh(LB_HTPM_PORT_BY_HASH(lb_priv, hash));
+	struct team_port *port;
+
+	port = rcu_dereference_bh(LB_HTPM_PORT_BY_HASH(lb_priv, hash));
+	if (likely(port))
+		return port;
+	/* If no valid port in the table, fall back to simple hash */
+	return lb_hash_select_tx_port(team, lb_priv, skb, hash);
 }
 
 struct lb_select_tx_port {
-- 
2.7.4
