From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 5/7] netpoll: add optional dropping and queueing support
Date: Thu, 03 Mar 2005 14:46:32 -0600
Message-ID: <6.454130102@selenic.com>
References: <5.454130102@selenic.com>
Cc: netdev@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <5.454130102@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This adds a callback for packets we can't deliver immediately and a
helper function for clients to queue such packets to the device
post-interrupt. 

Netconsole is modified to use the queueing function for best-effort
delivery.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: rc4/drivers/net/netconsole.c
===================================================================
--- rc4.orig/drivers/net/netconsole.c	2005-02-17 22:39:29.000000000 -0600
+++ rc4/drivers/net/netconsole.c	2005-02-17 22:40:05.000000000 -0600
@@ -60,6 +60,7 @@
 	.local_port = 6665,
 	.remote_port = 6666,
 	.remote_mac = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
+	.drop = netpoll_queue,
 };
 static int configured = 0;
 
Index: rc4/net/core/netpoll.c
===================================================================
--- rc4.orig/net/core/netpoll.c	2005-02-17 22:40:02.000000000 -0600
+++ rc4/net/core/netpoll.c	2005-02-17 22:40:05.000000000 -0600
@@ -19,6 +19,7 @@
 #include <linux/netpoll.h>
 #include <linux/sched.h>
 #include <linux/rcupdate.h>
+#include <linux/workqueue.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <asm/unaligned.h>
@@ -28,13 +29,18 @@
  * message gets out even in extreme OOM situations.
  */
 
-#define MAX_SKBS 32
 #define MAX_UDP_CHUNK 1460
+#define MAX_SKBS 32
+#define MAX_QUEUE_DEPTH (MAX_SKBS / 2)
 
 static DEFINE_SPINLOCK(skb_list_lock);
 static int nr_skbs;
 static struct sk_buff *skbs;
 
+static DEFINE_SPINLOCK(queue_lock);
+static int queue_depth;
+static struct sk_buff *queue_head, *queue_tail;
+
 static atomic_t trapped;
 
 #define NETPOLL_RX_ENABLED  1
@@ -46,6 +52,50 @@
 
 static void zap_completion_queue(void);
 
+static void queue_process(void *p)
+{
+	unsigned long flags;
+	struct sk_buff *skb;
+
+	while (queue_head) {
+		spin_lock_irqsave(&queue_lock, flags);
+
+		skb = queue_head;
+		queue_head = skb->next;
+		if (skb == queue_tail)
+			queue_head = NULL;
+
+		queue_depth--;
+
+		spin_unlock_irqrestore(&queue_lock, flags);
+
+		dev_queue_xmit(skb);
+	}
+}
+
+static DECLARE_WORK(send_queue, queue_process, NULL);
+
+void netpoll_queue(struct sk_buff *skb)
+{
+	unsigned long flags;
+
+	if (queue_depth == MAX_QUEUE_DEPTH) {
+		__kfree_skb(skb);
+		return;
+	}
+
+	spin_lock_irqsave(&queue_lock, flags);
+	if (!queue_head)
+		queue_head = skb;
+	else
+		queue_tail->next = skb;
+	queue_tail = skb;
+	queue_depth++;
+	spin_unlock_irqrestore(&queue_lock, flags);
+
+	schedule_work(&send_queue);
+}
+
 static int checksum_udp(struct sk_buff *skb, struct udphdr *uh,
 			     unsigned short ulen, u32 saddr, u32 daddr)
 {
@@ -199,7 +249,10 @@
 
 	/* avoid ->poll recursion */
 	if(np->poll_owner == __smp_processor_id()) {
-		__kfree_skb(skb);
+		if (np->drop)
+			np->drop(skb);
+		else
+			__kfree_skb(skb);
 		return;
 	}
 
@@ -275,6 +328,8 @@
 	memcpy(eth->h_source, np->local_mac, 6);
 	memcpy(eth->h_dest, np->remote_mac, 6);
 
+	skb->dev = np->dev;
+
 	netpoll_send_skb(np, skb);
 }
 
Index: rc4/include/linux/netpoll.h
===================================================================
--- rc4.orig/include/linux/netpoll.h	2005-02-17 22:40:02.000000000 -0600
+++ rc4/include/linux/netpoll.h	2005-02-17 22:40:05.000000000 -0600
@@ -18,6 +18,7 @@
 	char dev_name[16], *name;
 	int rx_flags;
 	void (*rx_hook)(struct netpoll *, int, char *, int);
+	void (*drop)(struct sk_buff *skb);
 	u32 local_ip, remote_ip;
 	u16 local_port, remote_port;
 	unsigned char local_mac[6], remote_mac[6];
@@ -33,6 +34,7 @@
 void netpoll_set_trap(int trap);
 void netpoll_cleanup(struct netpoll *np);
 int __netpoll_rx(struct sk_buff *skb);
+void netpoll_queue(struct sk_buff *skb);
 
 #ifdef CONFIG_NETPOLL
 static inline int netpoll_rx(struct sk_buff *skb)
