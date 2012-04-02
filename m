From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 32/51] can: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:22 -0400
Message-ID: <1333335521-1348-33-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458Ab2DBDAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:03 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/can/dev.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index c5fe3a3..f03d7a4 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -687,18 +687,19 @@ static int can_fill_info(struct sk_buff *skb, const struct net_device *dev)
 
 	if (priv->do_get_state)
 		priv->do_get_state(dev, &state);
-	NLA_PUT_U32(skb, IFLA_CAN_STATE, state);
-	NLA_PUT(skb, IFLA_CAN_CTRLMODE, sizeof(cm), &cm);
-	NLA_PUT_U32(skb, IFLA_CAN_RESTART_MS, priv->restart_ms);
-	NLA_PUT(skb, IFLA_CAN_BITTIMING,
-		sizeof(priv->bittiming), &priv->bittiming);
-	NLA_PUT(skb, IFLA_CAN_CLOCK, sizeof(cm), &priv->clock);
-	if (priv->do_get_berr_counter && !priv->do_get_berr_counter(dev, &bec))
-		NLA_PUT(skb, IFLA_CAN_BERR_COUNTER, sizeof(bec), &bec);
-	if (priv->bittiming_const)
-		NLA_PUT(skb, IFLA_CAN_BITTIMING_CONST,
-			sizeof(*priv->bittiming_const), priv->bittiming_const);
-
+	if (nla_put_u32(skb, IFLA_CAN_STATE, state) ||
+	    nla_put(skb, IFLA_CAN_CTRLMODE, sizeof(cm), &cm) ||
+	    nla_put_u32(skb, IFLA_CAN_RESTART_MS, priv->restart_ms) ||
+	    nla_put(skb, IFLA_CAN_BITTIMING,
+		    sizeof(priv->bittiming), &priv->bittiming) ||
+	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(cm), &priv->clock) ||
+	    (priv->do_get_berr_counter &&
+	     !priv->do_get_berr_counter(dev, &bec) &&
+	     nla_put(skb, IFLA_CAN_BERR_COUNTER, sizeof(bec), &bec)) ||
+	    (priv->bittiming_const &&
+	     nla_put(skb, IFLA_CAN_BITTIMING_CONST,
+		     sizeof(*priv->bittiming_const), priv->bittiming_const)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -714,9 +715,9 @@ static int can_fill_xstats(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct can_priv *priv = netdev_priv(dev);
 
-	NLA_PUT(skb, IFLA_INFO_XSTATS,
-		sizeof(priv->can_stats), &priv->can_stats);
-
+	if (nla_put(skb, IFLA_INFO_XSTATS,
+		    sizeof(priv->can_stats), &priv->can_stats))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
