From: Andrei Warkentin <andrey.warkentin@gmail.com>
Subject: [PATCH 1/2] NETPOLL: Extend rx_hook support.
Date: Fri, 24 Feb 2012 21:44:10 -0500
Message-ID: <1330137851-4716-2-git-send-email-andrey.warkentin@gmail.com>
References: <1330137851-4716-1-git-send-email-andrey.warkentin@gmail.com>
Cc: Andrei Warkentin <andreiw@vmware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:46164 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157Ab2BYDo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 22:44:29 -0500
Received: by qcqw6 with SMTP id w6so160599qcq.19
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2012 19:44:28 -0800 (PST)
In-Reply-To: <1330137851-4716-1-git-send-email-andrey.warkentin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Warkentin <andreiw@vmware.com>

Pass down source information to rx_hook, useful
for accepting connections from unspecified clients.

Signed-off-by: Andrei Warkentin <andreiw@vmware.com>
---
 include/linux/netpoll.h |   10 +++++++++-
 net/core/netpoll.c      |   10 ++++------
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 5dfa091..9a9cfa1 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -11,12 +11,19 @@
 #include <linux/interrupt.h>
 #include <linux/rcupdate.h>
 #include <linux/list.h>
+#include <linux/if_ether.h>
+#include <net/tcp.h>
+#include <net/udp.h>
 
 struct netpoll {
 	struct net_device *dev;
 	char dev_name[IFNAMSIZ];
 	const char *name;
-	void (*rx_hook)(struct netpoll *, int, char *, int);
+	void (*rx_hook)(struct netpoll *,
+			u8 *h_source,
+			__be32 saddr,
+			struct udphdr *,
+			char *, int);
 
 	__be32 local_ip, remote_ip;
 	u16 local_port, remote_port;
@@ -40,6 +47,7 @@ struct netpoll_info {
 	struct netpoll *netpoll;
 };
 
+void netpoll_poll_dev(struct net_device *dev);
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 3d84fb9..c182bb2 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -26,8 +26,6 @@
 #include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <linux/export.h>
-#include <net/tcp.h>
-#include <net/udp.h>
 #include <asm/unaligned.h>
 #include <trace/events/napi.h>
 
@@ -189,7 +187,7 @@ static void service_arp_queue(struct netpoll_info *npi)
 	}
 }
 
-static void netpoll_poll_dev(struct net_device *dev)
+void netpoll_poll_dev(struct net_device *dev)
 {
 	const struct net_device_ops *ops;
 
@@ -615,9 +613,9 @@ int __netpoll_rx(struct sk_buff *skb)
 		if (np->local_port && np->local_port != ntohs(uh->dest))
 			continue;
 
-		np->rx_hook(np, ntohs(uh->source),
-			       (char *)(uh+1),
-			       ulen - sizeof(struct udphdr));
+		np->rx_hook(np, eth_hdr(skb)->h_source,
+			    iph->saddr, uh, (char *)(uh+1),
+			    ulen - sizeof(struct udphdr));
 		hits++;
 	}
 
-- 
1.7.8.3
