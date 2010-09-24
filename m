From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: loopback driver cleanup
Date: Fri, 24 Sep 2010 11:51:51 +0200
Message-ID: <1285321911.2503.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39225 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230Ab0IXJv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 05:51:56 -0400
Received: by fxm3 with SMTP id 3so602269fxm.19
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 02:51:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

loopback driver uses dev->ml_priv to store its percpu stats pointer.
It uses ugly casts "(void __percpu __force *)" to shut up sparse
complains.

Define an union to better document we use ml_priv in loopback driver and
define a lstats field with appropriate types.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/loopback.c    |   20 +++++---------------
 include/linux/netdevice.h |    6 ++++--
 2 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 9a09967..4b0e30b 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -74,7 +74,6 @@ struct pcpu_lstats {
 static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 				 struct net_device *dev)
 {
-	struct pcpu_lstats __percpu *pcpu_lstats;
 	struct pcpu_lstats *lb_stats;
 	int len;
 
@@ -83,8 +82,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 	skb->protocol = eth_type_trans(skb, dev);
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
-	pcpu_lstats = (void __percpu __force *)dev->ml_priv;
-	lb_stats = this_cpu_ptr(pcpu_lstats);
+	lb_stats = this_cpu_ptr(dev->lstats);
 
 	len = skb->len;
 	if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
@@ -101,19 +99,17 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 static struct rtnl_link_stats64 *loopback_get_stats64(struct net_device *dev,
 						      struct rtnl_link_stats64 *stats)
 {
-	const struct pcpu_lstats __percpu *pcpu_lstats;
 	u64 bytes = 0;
 	u64 packets = 0;
 	u64 drops = 0;
 	int i;
 
-	pcpu_lstats = (void __percpu __force *)dev->ml_priv;
 	for_each_possible_cpu(i) {
 		const struct pcpu_lstats *lb_stats;
 		u64 tbytes, tpackets;
 		unsigned int start;
 
-		lb_stats = per_cpu_ptr(pcpu_lstats, i);
+		lb_stats = per_cpu_ptr(dev->lstats, i);
 		do {
 			start = u64_stats_fetch_begin(&lb_stats->syncp);
 			tbytes = lb_stats->bytes;
@@ -147,22 +143,16 @@ static const struct ethtool_ops loopback_ethtool_ops = {
 
 static int loopback_dev_init(struct net_device *dev)
 {
-	struct pcpu_lstats __percpu *lstats;
-
-	lstats = alloc_percpu(struct pcpu_lstats);
-	if (!lstats)
+	dev->lstats = alloc_percpu(struct pcpu_lstats);
+	if (!dev->lstats)
 		return -ENOMEM;
 
-	dev->ml_priv = (void __force *)lstats;
 	return 0;
 }
 
 static void loopback_dev_free(struct net_device *dev)
 {
-	struct pcpu_lstats __percpu *lstats =
-		(void __percpu __force *)dev->ml_priv;
-
-	free_percpu(lstats);
+	free_percpu(dev->lstats);
 	free_netdev(dev);
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f7f1302..65ae79c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1050,8 +1050,10 @@ struct net_device {
 #endif
 
 	/* mid-layer private */
-	void			*ml_priv;
-
+	union {
+		void				*ml_priv;
+		struct pcpu_lstats __percpu	*lstats; /* loopback stats */
+	};
 	/* GARP */
 	struct garp_port	*garp_port;
 


