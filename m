From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] net: deinline netif_tx_stop_queue() and netif_tx_stop_all_queues()
Date: Thu,  7 May 2015 13:41:10 +0200
Message-ID: <1430998870-1453-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These functions compile to ~60 bytes of machine code each.

With this .config: http://busybox.net/~vda/kernel_config
there are 617 calls to netif_tx_stop_queue()
and 49 calls to netif_tx_stop_all_queues() in vmlinux.

Code size is reduced by 27 kbytes:

    text     data      bss       dec     hex filename
82426986 22255416 20627456 125309858 77813a2 vmlinux.before
82399481 22255416 20627456 125282353 777a831 vmlinux

It may seem strange that a seemingly simple code like one in
netif_tx_stop_queue() compiles to ~60 bytes of code.
Well, it's true. Here's its disassembly:

    netif_tx_stop_queue:
       e8 b0 15 4d 00          callq  <__fentry__>
       48 85 ff                test   %rdi,%rdi
       75 25                   jne    <netif_tx_stop_queue+0x2f>
       55                      push   %rbp
       be 7a 18 00 00          mov    $0x187a,%esi
       48 c7 c7 50 59 d8 85    mov    $.rodata+0x1d85950,%rdi
       48 89 e5                mov    %rsp,%rbp
       e8 54 5a 7d fd          callq  <warn_slowpath_null>
       48 c7 c7 5f 59 d8 85    mov    $.rodata+0x1d8595f,%rdi
       31 c0                   xor    %eax,%eax
       e8 b0 47 48 00          callq  <printk>
       eb 09                   jmp    <netif_tx_stop_queue+0x38>
       f0 80 8f e0 01 00 00 01 lock orb $0x1,0x1e0(%rdi)
       c3                      retq
       5d                      pop    %rbp
       c3                      retq

This causes gcc to auto-deinline it before this patch, but with 203 separate
copies in each module which uses this function:

$ nm --size-sort vmlinux.before | grep -e ' netif_tx_stop_queue$' | wc -l
203

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: David S. Miller <davem@davemloft.net>
CC: Jiri Pirko <jpirko@redhat.com>
CC: linux-kernel@vger.kernel.org
CC: netdev@vger.kernel.org
CC: netfilter-devel@vger.kernel.org
---
 include/linux/netdevice.h | 19 ++-----------------
 net/core/dev.c            | 21 +++++++++++++++++++++
 2 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dcf6ec2..f650d16 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2546,14 +2546,7 @@ static inline void netif_tx_wake_all_queues(struct net_device *dev)
 	}
 }
 
-static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
-{
-	if (WARN_ON(!dev_queue)) {
-		pr_info("netif_stop_queue() cannot be called before register_netdev()\n");
-		return;
-	}
-	set_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
-}
+void netif_tx_stop_queue(struct netdev_queue *dev_queue);
 
 /**
  *	netif_stop_queue - stop transmitted packets
@@ -2567,15 +2560,7 @@ static inline void netif_stop_queue(struct net_device *dev)
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
index 962ee9d..569031f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6261,6 +6261,27 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	return 0;
 }
 
+void netif_tx_stop_queue(struct netdev_queue *dev_queue)
+{
+	if (WARN_ON(!dev_queue)) {
+		pr_info("netif_stop_queue() cannot be called before register_netdev()\n");
+		return;
+	}
+	set_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
+}
+EXPORT_SYMBOL(netif_tx_stop_queue);
+
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
