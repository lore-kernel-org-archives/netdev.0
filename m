From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 09/11] can: af_can: can_pernet_init(): add missing error handling for kzalloc returning NULL
Date: Thu, 19 Oct 2017 13:19:43 +0200
Message-ID: <20171019111945.13580-10-mkl@pengutronix.de>
References: <20171019111945.13580-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
        linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20171019111945.13580-1-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the missing check and error handling for out-of-memory
situations, when kzalloc cannot allocate memory.

Fixes: cb5635a36776 ("can: complete initial namespace support")
Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 net/can/af_can.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index eb1ad74b40f4..ecd5c703d11e 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -875,9 +875,14 @@ static int can_pernet_init(struct net *net)
 	spin_lock_init(&net->can.can_rcvlists_lock);
 	net->can.can_rx_alldev_list =
 		kzalloc(sizeof(struct dev_rcv_lists), GFP_KERNEL);
-
+	if (!net->can.can_rx_alldev_list)
+		goto out;
 	net->can.can_stats = kzalloc(sizeof(struct s_stats), GFP_KERNEL);
+	if (!net->can.can_stats)
+		goto out_free_alldev_list;
 	net->can.can_pstats = kzalloc(sizeof(struct s_pstats), GFP_KERNEL);
+	if (!net->can.can_pstats)
+		goto out_free_can_stats;
 
 	if (IS_ENABLED(CONFIG_PROC_FS)) {
 		/* the statistics are updated every second (timer triggered) */
@@ -892,6 +897,13 @@ static int can_pernet_init(struct net *net)
 	}
 
 	return 0;
+
+ out_free_can_stats:
+	kfree(net->can.can_stats);
+ out_free_alldev_list:
+	kfree(net->can.can_rx_alldev_list);
+ out:
+	return -ENOMEM;
 }
 
 static void can_pernet_exit(struct net *net)
-- 
2.14.2
