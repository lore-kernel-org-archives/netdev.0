From: Jim Hanko <hanko@drivescale.com>
Subject: [patch net-next] team: fall back to hash if table entry is empty
Date: Thu,  7 Sep 2017 19:25:12 -0700
Message-ID: <1504837512-16395-1-git-send-email-hanko@drivescale.com>
Cc: Jim Hanko <hanko@drivescale.com>
To: jiri@resnulli.us, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f100.google.com ([209.85.218.100]:37982 "EHLO
        mail-oi0-f100.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752093AbdIHC0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 22:26:32 -0400
Received: by mail-oi0-f100.google.com with SMTP id a197so389299oib.5
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 19:26:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the hash to port mapping table does not have a valid port (i.e. when
a port goes down), fall back to the simple hashing mechanism to avoid
dropping packets.

Signed-off-by: Jim Hanko <hanko@drivescale.com>
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
