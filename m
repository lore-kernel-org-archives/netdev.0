From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] can: only call can_stat_update with procfs
Date: Mon, 20 Jun 2016 17:51:52 +0200
Message-ID: <20160620155234.2414971-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Aring <aar@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The change to leave out procfs support in CAN when CONFIG_PROC_FS
is not set was incomplete and leads to a build error:

net/built-in.o: In function `can_init':
:(.init.text+0x9858): undefined reference to `can_stat_update'
ERROR: "can_stat_update" [net/can/can.ko] undefined!

This tries a better approach, encapsulating all of the calls
within IS_ENABLED(), so we also leave out the timer function
from the object file.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: a20fadf85312 ("can: build proc support only if CONFIG_PROC_FS is activated")
---
 net/can/af_can.c | 22 ++++++++++++----------
 net/can/af_can.h | 11 -----------
 2 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 166d436196c1..1108079d934f 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -911,14 +911,14 @@ static __init int can_init(void)
 	if (!rcv_cache)
 		return -ENOMEM;
 
-	if (stats_timer) {
+	if (IS_ENABLED(CONFIG_PROC_FS)) {
+		if (stats_timer) {
 		/* the statistics are updated every second (timer triggered) */
-		setup_timer(&can_stattimer, can_stat_update, 0);
-		mod_timer(&can_stattimer, round_jiffies(jiffies + HZ));
-	} else
-		can_stattimer.function = NULL;
-
-	can_init_proc();
+			setup_timer(&can_stattimer, can_stat_update, 0);
+			mod_timer(&can_stattimer, round_jiffies(jiffies + HZ));
+		}
+		can_init_proc();
+	}
 
 	/* protocol register */
 	sock_register(&can_family_ops);
@@ -933,10 +933,12 @@ static __exit void can_exit(void)
 {
 	struct net_device *dev;
 
-	if (stats_timer)
-		del_timer_sync(&can_stattimer);
+	if (IS_ENABLED(CONFIG_PROC_FS)) {
+		if (stats_timer)
+			del_timer_sync(&can_stattimer);
 
-	can_remove_proc();
+		can_remove_proc();
+	}
 
 	/* protocol unregister */
 	dev_remove_pack(&canfd_packet);
diff --git a/net/can/af_can.h b/net/can/af_can.h
index 38a79ff20022..fca0fe9fc45a 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -113,19 +113,8 @@ struct s_pstats {
 extern struct dev_rcv_lists can_rx_alldev_list;
 
 /* function prototypes for the CAN networklayer procfs (proc.c) */
-#ifdef CONFIG_PROC_FS
 void can_init_proc(void);
 void can_remove_proc(void);
-#else
-static inline void can_init_proc(void)
-{
-	pr_info("can: Can't create /proc/net/can. CONFIG_PROC_FS missing!\n");
-}
-
-static inline void can_remove_proc(void)
-{
-}
-#endif
 void can_stat_update(unsigned long data);
 
 /* structures and variables from af_can.c needed in proc.c for reading */
-- 
2.9.0
