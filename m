From: Matthew Whitehead <tedheadster@gmail.com>
Subject: [PATCH net-next] Replace constant with sysctl netdev_budget_jiffies to enable tuning
Date: Mon, 17 Apr 2017 10:29:09 -0400
Message-ID: <1492439349-21081-1-git-send-email-tedheadster@gmail.com>
Cc: Matthew Whitehead <tedheadster@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33002 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750776AbdDQO3W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 10:29:22 -0400
Received: by mail-qk0-f195.google.com with SMTP id d131so19605210qkc.0
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 07:29:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Constants used for tuning are generally a bad idea, especially as hardware
changes over time. Replace the constant '2' with netdev_budget_jiffies to
enable sysadmins to tune the behavior. Also document the variable.

For example, a very fast machine might tune this to 1, while my regression
testing 486DX-25 needs it to be 4 on a nearly idle network to prevent
time_squeeze from being incremented.

Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
---
 Documentation/sysctl/net.txt | 12 +++++++++++-
 include/linux/netdevice.h    |  1 +
 include/uapi/linux/sysctl.h  |  1 +
 kernel/sysctl_binary.c       |  1 +
 net/core/dev.c               |  3 ++-
 net/core/sysctl_net_core.c   |  7 +++++++
 6 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 2ebabc9..36f8a5b 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -188,7 +188,17 @@ netdev_budget
 
 Maximum number of packets taken from all interfaces in one polling cycle (NAPI
 poll). In one polling cycle interfaces which are registered to polling are
-probed in a round-robin manner.
+probed in a round-robin manner. Also, a polling cycle may not exceed
+netdev_budget_jiffies units of time, even if netdev_budget has not been
+exhausted.
+
+netdev_budget_jiffies
+---------------------
+
+Maximum number of jiffies time units in one NAPI polling cycle. Polling
+will exit when either netdev_budget_jiffies (default 2) time units have
+elapsed during the poll cycle or the number of packets processed
+reaches netdev_budget.
 
 netdev_max_backlog
 ------------------
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97456b25..58f2682 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3305,6 +3305,7 @@ static __always_inline int ____dev_forward_skb(struct net_device *dev,
 void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
 
 extern int		netdev_budget;
+extern int		netdev_budget_jiffies;
 
 /* Called by rtnetlink.c:rtnl_unlock() */
 void netdev_run_todo(void);
diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
index d2b1215..79c0bd7 100644
--- a/include/uapi/linux/sysctl.h
+++ b/include/uapi/linux/sysctl.h
@@ -274,6 +274,7 @@ enum
 	NET_CORE_AEVENT_ETIME=20,
 	NET_CORE_AEVENT_RSEQTH=21,
 	NET_CORE_WARNINGS=22,
+	NET_CORE_BUDGET_JIFFIES=23,
 };
 
 /* /proc/sys/net/ethernet */
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index ece4b17..e38e197 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -197,6 +197,7 @@ struct bin_table {
 	{ CTL_INT,	NET_CORE_AEVENT_ETIME,	"xfrm_aevent_etime" },
 	{ CTL_INT,	NET_CORE_AEVENT_RSEQTH,	"xfrm_aevent_rseqth" },
 	{ CTL_INT,	NET_CORE_WARNINGS,	"warnings" },
+	{ CTL_INT,	NET_CORE_BUDGET_JIFFIES,	"netdev_budget_jiffies" },
 	{},
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 7869ae3..6907a6e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3441,6 +3441,7 @@ int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv)
 
 int netdev_tstamp_prequeue __read_mostly = 1;
 int netdev_budget __read_mostly = 300;
+int netdev_budget_jiffies __read_mostly = 2;
 int weight_p __read_mostly = 64;           /* old backlog weight */
 int dev_weight_rx_bias __read_mostly = 1;  /* bias for backlog weight */
 int dev_weight_tx_bias __read_mostly = 1;  /* bias for output_queue quota */
@@ -5310,7 +5311,7 @@ static int napi_poll(struct napi_struct *n, struct list_head *repoll)
 static __latent_entropy void net_rx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
-	unsigned long time_limit = jiffies + 2;
+	unsigned long time_limit = jiffies + netdev_budget_jiffies;
 	int budget = netdev_budget;
 	LIST_HEAD(list);
 	LIST_HEAD(repoll);
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 7f9cc40..9cd367c 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -452,6 +452,13 @@ static int proc_do_rss_key(struct ctl_table *table, int write,
 		.extra1		= &one,
 		.extra2		= &max_skb_frags,
 	},
+	{
+		.procname	= "netdev_budget_jiffies",
+		.data		= &netdev_budget_jiffies,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
-- 
1.8.3.1
