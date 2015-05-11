From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] net: deinline netif_tx_stop_all_queues(), remove WARN_ON in netif_tx_stop_queue()
Date: Mon, 11 May 2015 21:17:53 +0200
Message-ID: <1431371873-26969-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jpirko@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752374AbbEKTR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2015 15:17:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions compile to 60 bytes of machine code each.
With this .config: http://busybox.net/~vda/kernel_config
there are 617 calls of netif_tx_stop_queue()
and 49 calls of netif_tx_stop_all_queues() in vmlinux.

To fix this, remove WARN_ON in netif_tx_stop_queue()
as suggested by davem, and deinline netif_tx_stop_all_queues().

Change in code size is about 20k:

   text      data      bss       dec     hex filename
82426986 22255416 20627456 125309858 77813a2 vmlinux.before
82406248 22255416 20627456 125289120 777c2a0 vmlinux

gcc-4.7.2 still creates deinlined version of netif_tx_stop_queue
sometimes:

$ nm --size-sort vmlinux | grep netif_tx_stop_queue | wc -l
190

ffffffff81b558a8 <netif_tx_stop_queue>:
ffffffff81b558a8:       55                      push   %rbp
ffffffff81b558a9:       48 89 e5                mov    %rsp,%rbp
ffffffff81b558ac:       f0 80 8f e0 01 00 00    lock orb $0x1,0x1e0(%rdi)
ffffffff81b558b3:       01
ffffffff81b558b4:       5d                      pop    %rbp
ffffffff81b558b5:       c3                      retq

This needs additional fixing.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: Alexei Starovoitov <alexei.starovoitov@gmail.com>
CC: Alexander Duyck <alexander.duyck@gmail.com>
CC: Joe Perches <joe@perches.com>
CC: David S. Miller <davem@davemloft.net>
CC: Jiri Pirko <jpirko@redhat.com>
CC: linux-kernel@vger.kernel.org
CC: netdev@vger.kernel.org
CC: netfilter-devel@vger.kernel.org
---
 include/linux/netdevice.h | 14 +-------------
 net/core/dev.c            | 11 +++++++++++
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dcf6ec2..536169e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2548,10 +2548,6 @@ static inline void netif_tx_wake_all_queues(struct net_device *dev)
 
 static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
 {
-	if (WARN_ON(!dev_queue)) {
-		pr_info("netif_stop_queue() cannot be called before register_netdev()\n");
-		return;
-	}
 	set_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
 }
 
@@ -2567,15 +2563,7 @@ static inline void netif_stop_queue(struct net_device *dev)
 	netif_tx_stop_queue(netdev_get_tx_queue(dev, 0));
 }
 
-static inline void netif_tx_stop_all_queues(struct net_device *dev)
-{
-	unsigned int i;
-
-	for (i = 0; i < dev->num_tx_queues; i++) {
-		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		netif_tx_stop_queue(txq);
-	}
-}
+void netif_tx_stop_all_queues(struct net_device *dev);
 
 static inline bool netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 962ee9d..11e0128 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6261,6 +6261,17 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	return 0;
 }
 
+void netif_tx_stop_all_queues(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		netif_tx_stop_queue(txq);
+	}
+}
+EXPORT_SYMBOL(netif_tx_stop_all_queues);
+
 /**
  *	register_netdevice	- register a network device
  *	@dev: device to register
-- 
1.8.1.4
