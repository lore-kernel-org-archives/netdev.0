From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/13]: netdev: netdev_priv() can now be sane again.
Date: Thu, 10 Jul 2008 03:56:55 -0700 (PDT)
Message-ID: <20080710.035655.91915636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60719
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754065AbYGJK4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:56:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id AE5ABC8C17F
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 03:56:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The private area of a netdev is now at a fixed offset once more.

Unfortunately, some assumptions that netdev_priv() == netdev->priv
crept back into the tree.  In particular this happened in the
loopback driver.  Make it use netdev->ml_priv.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/loopback.c    |    8 ++++----
 include/linux/netdevice.h |    4 +++-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 41b774b..49f6bc0 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -153,7 +153,7 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->last_rx = jiffies;
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
-	pcpu_lstats = netdev_priv(dev);
+	pcpu_lstats = dev->ml_priv;
 	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
 	lb_stats->bytes += skb->len;
 	lb_stats->packets++;
@@ -171,7 +171,7 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 	unsigned long packets = 0;
 	int i;
 
-	pcpu_lstats = netdev_priv(dev);
+	pcpu_lstats = dev->ml_priv;
 	for_each_possible_cpu(i) {
 		const struct pcpu_lstats *lb_stats;
 
@@ -207,13 +207,13 @@ static int loopback_dev_init(struct net_device *dev)
 	if (!lstats)
 		return -ENOMEM;
 
-	dev->priv = lstats;
+	dev->ml_priv = lstats;
 	return 0;
 }
 
 static void loopback_dev_free(struct net_device *dev)
 {
-	struct pcpu_lstats *lstats = netdev_priv(dev);
+	struct pcpu_lstats *lstats = dev->ml_priv;
 
 	free_percpu(lstats);
 	free_netdev(dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 661fe81..b580331 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -807,7 +807,9 @@ void dev_net_set(struct net_device *dev, struct net *net)
  */
 static inline void *netdev_priv(const struct net_device *dev)
 {
-	return dev->priv;
+	return (char *)dev + ((sizeof(struct net_device)
+			       + NETDEV_ALIGN_CONST)
+			      & ~NETDEV_ALIGN_CONST);
 }
 
 /* Set the sysfs physical device reference for the network logical device
-- 
1.5.6.2.255.gbed62

