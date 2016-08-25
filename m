From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2] team: loadbalance: push lacpdus to exact delivery
Date: Thu, 25 Aug 2016 18:30:52 +0200
Message-ID: <1472142652-15004-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36025 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751884AbcHYReF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 13:34:05 -0400
Received: by mail-wm0-f46.google.com with SMTP id q128so248506951wma.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 10:33:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

When team is in bridge and LACP is utilized, LACPDU packets are pushed
to userspace using raw socket and there they are processed. However,
since 8626c56c8279b, LACPDU skbs are dropped by bridge rx_handler so
they never reach packet handlers in rx path. Fix this by explicity treat
LACPDUs to be pushed to exact delivery in team rx_handler.

Reported-by: Ido Schimmel <idosch@mellanox.com>
Fixes: 8626c56c8279b ("bridge: fix potential use-after-free when hook returns QUEUE or STOLEN verdict")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- added forgotten include
---
 drivers/net/team/team_mode_loadbalance.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index cdb19b3..b228bea 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -14,9 +14,23 @@
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/filter.h>
 #include <linux/if_team.h>
 
+static rx_handler_result_t lb_receive(struct team *team, struct team_port *port,
+				      struct sk_buff *skb)
+{
+	if (unlikely(skb->protocol == htons(ETH_P_SLOW))) {
+		/* LACPDU packets should go to exact delivery */
+		const unsigned char *dest = eth_hdr(skb)->h_dest;
+
+		if (is_link_local_ether_addr(dest) && dest[5] == 0x02)
+			return RX_HANDLER_EXACT;
+	}
+	return RX_HANDLER_ANOTHER;
+}
+
 struct lb_priv;
 
 typedef struct team_port *lb_select_tx_port_func_t(struct team *,
@@ -652,6 +666,7 @@ static const struct team_mode_ops lb_mode_ops = {
 	.port_enter		= lb_port_enter,
 	.port_leave		= lb_port_leave,
 	.port_disabled		= lb_port_disabled,
+	.receive		= lb_receive,
 	.transmit		= lb_transmit,
 };
 
-- 
2.5.5
