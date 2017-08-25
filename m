From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [RFC PATCH] net: limit maximum number of packets to mark with xmit_more
Date: Fri, 25 Aug 2017 08:24:49 -0700
Message-ID: <20170825152449.29790-1-jacob.e.keller@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38164 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933386AbdHYPY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 11:24:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under some circumstances, such as with many stacked devices, it is
possible that dev_hard_start_xmit will bundle many packets together, and
mark them all with xmit_more.

Most drivers respond to xmit_more by skipping tail bumps on packet
rings, or similar behavior as long as xmit_more is set. This is
a performance win since it means drivers can avoid notifying hardware of
new packets repeat daily, and thus avoid wasting unnecessary PCIe or other
bandwidth.

This use of xmit_more comes with a trade off because bundling too many
packets can increase latency of the Tx packets. To avoid this, we should
limit the maximum number of packets with xmit_more.

Driver authors could modify their drivers to check for some determined
limit, but this requires all drivers to be modified in order to gain
advantage.

Instead, add a sysctl "xmit_more_max" which can be used to configure the
maximum number of xmit_more skbs to send in a sequence. This ensures
that all drivers benefit, and allows system administrators the option to
tune the value to their environment.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---

Stray thoughts and further questions....

Is this the right approach? Did I miss any other places where we should
limit? Does the limit make sense? Should it instead be a per-device
tuning nob instead of a global? Is 32 a good default?

 Documentation/sysctl/net.txt |  6 ++++++
 include/linux/netdevice.h    |  2 ++
 net/core/dev.c               | 10 +++++++++-
 net/core/sysctl_net_core.c   |  7 +++++++
 4 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index b67044a2575f..3d995e8f4448 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -230,6 +230,12 @@ netdev_max_backlog
 Maximum number  of  packets,  queued  on  the  INPUT  side, when the interface
 receives packets faster than kernel can process them.
 
+xmit_more_max
+-------------
+
+Maximum number of packets in a row to mark with skb->xmit_more. A value of zero
+indicates no limit.
+
 netdev_rss_key
 --------------
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c5475b37a631..6341452aed09 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3321,6 +3321,8 @@ void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
 extern int		netdev_budget;
 extern unsigned int	netdev_budget_usecs;
 
+extern unsigned int sysctl_xmit_more_max;
+
 /* Called by rtnetlink.c:rtnl_unlock() */
 void netdev_run_todo(void);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 270b54754821..d9946d29c3a5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2983,12 +2983,19 @@ struct sk_buff *dev_hard_start_xmit(struct sk_buff *first, struct net_device *de
 {
 	struct sk_buff *skb = first;
 	int rc = NETDEV_TX_OK;
+	int xmit_count = 0;
+	bool more = true;
 
 	while (skb) {
 		struct sk_buff *next = skb->next;
 
+		if (sysctl_xmit_more_max)
+			more = xmit_count++ < sysctl_xmit_more_max;
+		if (!more)
+			xmit_count = 0;
+
 		skb->next = NULL;
-		rc = xmit_one(skb, dev, txq, next != NULL);
+		rc = xmit_one(skb, dev, txq, more && next != NULL);
 		if (unlikely(!dev_xmit_complete(rc))) {
 			skb->next = next;
 			goto out;
@@ -3523,6 +3530,7 @@ EXPORT_SYMBOL(netdev_max_backlog);
 int netdev_tstamp_prequeue __read_mostly = 1;
 int netdev_budget __read_mostly = 300;
 unsigned int __read_mostly netdev_budget_usecs = 2000;
+unsigned int __read_mostly sysctl_xmit_more_max = 32;
 int weight_p __read_mostly = 64;           /* old backlog weight */
 int dev_weight_rx_bias __read_mostly = 1;  /* bias for backlog weight */
 int dev_weight_tx_bias __read_mostly = 1;  /* bias for output_queue quota */
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index b7cd9aafe99e..6950e702e101 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -460,6 +460,13 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero,
 	},
+	{
+		.procname	= "xmit_more_max",
+		.data		= &sysctl_xmit_more_max,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.prox_handler	= proc_dointvec
+	},
 	{ }
 };
 
-- 
2.14.1.436.g33e61a4f0239
