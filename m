From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 2/6] netpoll: filter inlines
Date: Thu, 17 Feb 2005 23:25:18 -0600
Message-ID: <3.378217222@selenic.com>
References: <2.378217222@selenic.com>
Cc: netdev@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <2.378217222@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add netpoll rx helpers 
Move skb_free for rx into __netpoll_rx

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: rc4bk2/net/core/netpoll.c
===================================================================
--- rc4bk2.orig/net/core/netpoll.c	2005-02-14 10:34:12.000000000 -0800
+++ rc4bk2/net/core/netpoll.c	2005-02-14 17:10:34.000000000 -0800
@@ -368,7 +368,7 @@
 	netpoll_send_skb(np, send_skb);
 }
 
-int netpoll_rx(struct sk_buff *skb)
+int __netpoll_rx(struct sk_buff *skb)
 {
 	int proto, len, ulen;
 	struct iphdr *iph;
@@ -440,12 +440,18 @@
 				    (char *)(uh+1),
 				    ulen - sizeof(struct udphdr));
 
+		kfree_skb(skb);
 		return 1;
 	}
 	spin_unlock_irqrestore(&rx_list_lock, flags);
 
 out:
-	return atomic_read(&trapped);
+	if (atomic_read(&trapped)) {
+		kfree_skb(skb);
+		return 1;
+	}
+
+	return 0;
 }
 
 int netpoll_parse_options(struct netpoll *np, char *opt)
Index: rc4bk2/include/linux/netpoll.h
===================================================================
--- rc4bk2.orig/include/linux/netpoll.h	2005-02-14 10:34:08.000000000 -0800
+++ rc4bk2/include/linux/netpoll.h	2005-02-14 17:10:34.000000000 -0800
@@ -30,7 +30,15 @@
 int netpoll_trap(void);
 void netpoll_set_trap(int trap);
 void netpoll_cleanup(struct netpoll *np);
-int netpoll_rx(struct sk_buff *skb);
+int __netpoll_rx(struct sk_buff *skb);
 
+#ifdef CONFIG_NETPOLL
+static inline int netpoll_rx(struct sk_buff *skb)
+{
+	return skb->dev->netpoll_rx && __netpoll_rx(skb);
+}
+#else
+#define netpoll_rx(a) 0
+#endif
 
 #endif
Index: rc4bk2/net/core/dev.c
===================================================================
--- rc4bk2.orig/net/core/dev.c	2005-02-14 10:34:12.000000000 -0800
+++ rc4bk2/net/core/dev.c	2005-02-14 17:10:34.000000000 -0800
@@ -1427,13 +1427,10 @@
 	struct softnet_data *queue;
 	unsigned long flags;
 
-#ifdef CONFIG_NETPOLL
-	if (skb->dev->netpoll_rx && netpoll_rx(skb)) {
-		kfree_skb(skb);
+	/* if netpoll wants it, pretend we never saw it */
+	if (netpoll_rx(skb))
 		return NET_RX_DROP;
-	}
-#endif
-	
+
 	if (!skb->stamp.tv_sec)
 		net_timestamp(&skb->stamp);
 
@@ -1629,12 +1626,9 @@
 	int ret = NET_RX_DROP;
 	unsigned short type;
 
-#ifdef CONFIG_NETPOLL
-	if (skb->dev->netpoll_rx && skb->dev->poll && netpoll_rx(skb)) {
-		kfree_skb(skb);
+	/* if we've gotten here through NAPI, check netpoll */
+	if (skb->dev->poll && netpoll_rx(skb))
 		return NET_RX_DROP;
-	}
-#endif
 
 	if (!skb->stamp.tv_sec)
 		net_timestamp(&skb->stamp);
