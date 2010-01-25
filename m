From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/8] percpu: add __percpu sparse annotations to net drivers
Date: Tue, 26 Jan 2010 00:22:11 +0900
Message-ID: <1264432935-10453-5-git-send-email-tj__32644.4030892619$1264432897$gmane$org@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42974 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908Ab0AYPTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 10:19:09 -0500
In-Reply-To: <1264432935-10453-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __percpu sparse annotations to net drivers.

These annotations are to make sparse consider percpu variables to be
in a different address space and warn if accessed without going
through percpu accessors.  This patch doesn't affect normal builds.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/chelsio/sge.c |    2 +-
 drivers/net/loopback.c    |   16 +++++++++-------
 drivers/net/macvlan.c     |    2 +-
 drivers/net/veth.c        |    4 ++--
 4 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 109d278..8e12505 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -267,7 +267,7 @@ struct sge {
 	struct sk_buff	*espibug_skb[MAX_NPORTS];
 	u32		sge_control;	/* shadow value of sge control reg */
 	struct sge_intr_counts stats;
-	struct sge_port_stats *port_stats[MAX_NPORTS];
+	struct sge_port_stats __percpu *port_stats[MAX_NPORTS];
 	struct sched	*tx_sched;
 	struct cmdQ cmdQ[SGE_CMDQ_N] ____cacheline_aligned_in_smp;
 };
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b9fcc98..72b7949 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -72,7 +72,8 @@ struct pcpu_lstats {
 static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 				 struct net_device *dev)
 {
-	struct pcpu_lstats *pcpu_lstats, *lb_stats;
+	struct pcpu_lstats __percpu *pcpu_lstats;
+	struct pcpu_lstats *lb_stats;
 	int len;
 
 	skb_orphan(skb);
@@ -80,7 +81,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 	skb->protocol = eth_type_trans(skb, dev);
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
-	pcpu_lstats = dev->ml_priv;
+	pcpu_lstats = (void __percpu __force *)dev->ml_priv;
 	lb_stats = this_cpu_ptr(pcpu_lstats);
 
 	len = skb->len;
@@ -95,14 +96,14 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 
 static struct net_device_stats *loopback_get_stats(struct net_device *dev)
 {
-	const struct pcpu_lstats *pcpu_lstats;
+	const struct pcpu_lstats __percpu *pcpu_lstats;
 	struct net_device_stats *stats = &dev->stats;
 	unsigned long bytes = 0;
 	unsigned long packets = 0;
 	unsigned long drops = 0;
 	int i;
 
-	pcpu_lstats = dev->ml_priv;
+	pcpu_lstats = (void __percpu __force *)dev->ml_priv;
 	for_each_possible_cpu(i) {
 		const struct pcpu_lstats *lb_stats;
 
@@ -135,19 +136,20 @@ static const struct ethtool_ops loopback_ethtool_ops = {
 
 static int loopback_dev_init(struct net_device *dev)
 {
-	struct pcpu_lstats *lstats;
+	struct pcpu_lstats __percpu *lstats;
 
 	lstats = alloc_percpu(struct pcpu_lstats);
 	if (!lstats)
 		return -ENOMEM;
 
-	dev->ml_priv = lstats;
+	dev->ml_priv = (void __force *)lstats;
 	return 0;
 }
 
 static void loopback_dev_free(struct net_device *dev)
 {
-	struct pcpu_lstats *lstats = dev->ml_priv;
+	struct pcpu_lstats __percpu *lstats =
+		(void __percpu __force *)dev->ml_priv;
 
 	free_percpu(lstats);
 	free_netdev(dev);
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 21a9c9a..4d2040c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -59,7 +59,7 @@ struct macvlan_dev {
 	struct hlist_node	hlist;
 	struct macvlan_port	*port;
 	struct net_device	*lowerdev;
-	struct macvlan_rx_stats *rx_stats;
+	struct macvlan_rx_stats __percpu *rx_stats;
 	enum macvlan_mode	mode;
 };
 
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 3a15de5..35609e6 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -34,7 +34,7 @@ struct veth_net_stats {
 
 struct veth_priv {
 	struct net_device *peer;
-	struct veth_net_stats *stats;
+	struct veth_net_stats __percpu *stats;
 	unsigned ip_summed;
 };
 
@@ -263,7 +263,7 @@ static int veth_change_mtu(struct net_device *dev, int new_mtu)
 
 static int veth_dev_init(struct net_device *dev)
 {
-	struct veth_net_stats *stats;
+	struct veth_net_stats __percpu *stats;
 	struct veth_priv *priv;
 
 	stats = alloc_percpu(struct veth_net_stats);
-- 
1.6.4.2

