From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 22/58] net: can: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:06 -0700
Message-ID: <1508200182-104605-23-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Oliver Hartkopp <socketcan@hartkopp.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-can@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/can/af_can.c | 4 ++--
 net/can/af_can.h | 2 +-
 net/can/proc.c   | 8 ++++----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 88edac0f3e36..1f75e11ac35a 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -882,8 +882,8 @@ static int can_pernet_init(struct net *net)
 	if (IS_ENABLED(CONFIG_PROC_FS)) {
 		/* the statistics are updated every second (timer triggered) */
 		if (stats_timer) {
-			setup_timer(&net->can.can_stattimer, can_stat_update,
-				    (unsigned long)net);
+			timer_setup(&net->can.can_stattimer, can_stat_update,
+				    0);
 			mod_timer(&net->can.can_stattimer,
 				  round_jiffies(jiffies + HZ));
 		}
diff --git a/net/can/af_can.h b/net/can/af_can.h
index d0ef45bb2a72..eca6463c6213 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -113,6 +113,6 @@ struct s_pstats {
 /* function prototypes for the CAN networklayer procfs (proc.c) */
 void can_init_proc(struct net *net);
 void can_remove_proc(struct net *net);
-void can_stat_update(unsigned long data);
+void can_stat_update(struct timer_list *t);
 
 #endif /* AF_CAN_H */
diff --git a/net/can/proc.c b/net/can/proc.c
index 83045f00c63c..d979b3dc49a6 100644
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -115,9 +115,9 @@ static unsigned long calc_rate(unsigned long oldjif, unsigned long newjif,
 	return rate;
 }
 
-void can_stat_update(unsigned long data)
+void can_stat_update(struct timer_list *t)
 {
-	struct net *net = (struct net *)data;
+	struct net *net = from_timer(net, t, can.can_stattimer);
 	struct s_stats *can_stats = net->can.can_stats;
 	unsigned long j = jiffies; /* snapshot */
 
@@ -221,7 +221,7 @@ static int can_stats_proc_show(struct seq_file *m, void *v)
 
 	seq_putc(m, '\n');
 
-	if (net->can.can_stattimer.function == can_stat_update) {
+	if (net->can.can_stattimer.function == (TIMER_FUNC_TYPE)can_stat_update) {
 		seq_printf(m, " %8ld %% total match ratio (RXMR)\n",
 				can_stats->total_rx_match_ratio);
 
@@ -291,7 +291,7 @@ static int can_reset_stats_proc_show(struct seq_file *m, void *v)
 
 	user_reset = 1;
 
-	if (net->can.can_stattimer.function == can_stat_update) {
+	if (net->can.can_stattimer.function == (TIMER_FUNC_TYPE)can_stat_update) {
 		seq_printf(m, "Scheduled statistic reset #%ld.\n",
 				can_pstats->stats_reset + 1);
 	} else {
-- 
2.7.4
