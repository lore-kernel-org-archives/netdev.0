From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 08/11] can: af_can: do not access proto_tab directly use rcu_access_pointer instead
Date: Thu, 19 Oct 2017 13:19:42 +0200
Message-ID: <20171019111945.13580-9-mkl@pengutronix.de>
References: <20171019111945.13580-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:60751 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752967AbdJSLT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:19:56 -0400
In-Reply-To: <20171019111945.13580-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"proto_tab" is a RCU protected array, when directly accessing the array,
sparse throws these warnings:

  CHECK   /srv/work/frogger/socketcan/linux/net/can/af_can.c
net/can/af_can.c:115:14: error: incompatible types in comparison expression (different address spaces)
net/can/af_can.c:795:17: error: incompatible types in comparison expression (different address spaces)
net/can/af_can.c:816:9: error: incompatible types in comparison expression (different address spaces)

This patch fixes the problem by using rcu_access_pointer() and
annotating "proto_tab" array as __rcu.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 net/can/af_can.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 88edac0f3e36..eb1ad74b40f4 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -78,7 +78,7 @@ MODULE_PARM_DESC(stats_timer, "enable timer for statistics (default:on)");
 static struct kmem_cache *rcv_cache __read_mostly;
 
 /* table of registered CAN protocols */
-static const struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
+static const struct can_proto __rcu *proto_tab[CAN_NPROTO] __read_mostly;
 static DEFINE_MUTEX(proto_tab_lock);
 
 static atomic_t skbcounter = ATOMIC_INIT(0);
@@ -788,7 +788,7 @@ int can_proto_register(const struct can_proto *cp)
 
 	mutex_lock(&proto_tab_lock);
 
-	if (proto_tab[proto]) {
+	if (rcu_access_pointer(proto_tab[proto])) {
 		pr_err("can: protocol %d already registered\n", proto);
 		err = -EBUSY;
 	} else
@@ -812,7 +812,7 @@ void can_proto_unregister(const struct can_proto *cp)
 	int proto = cp->protocol;
 
 	mutex_lock(&proto_tab_lock);
-	BUG_ON(proto_tab[proto] != cp);
+	BUG_ON(rcu_access_pointer(proto_tab[proto]) != cp);
 	RCU_INIT_POINTER(proto_tab[proto], NULL);
 	mutex_unlock(&proto_tab_lock);
 
-- 
2.14.2
