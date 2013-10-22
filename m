From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
Date: Tue, 22 Oct 2013 10:48:35 +0200
Message-ID: <1382431715-3128-1-git-send-email-antonio@meshcoding.com>
References: <20131022.025038.1046903740187748879.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Antonio Quartulli <antonio@meshcoding.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:22410 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab3JVItf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 04:49:35 -0400
In-Reply-To: <20131022.025038.1046903740187748879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now skb->data is passed to rx_hook() even if the skb
has not been linearised and without giving rx_hook() a way
to linearise it.

Change the rx_hook() interface and make it accept the skb
as argument. In this way users implementing rx_hook() can
perform all the needed operations to properly (and safely)
access the skb data.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 include/linux/netpoll.h |  2 +-
 net/core/netpoll.c      | 10 ++++------
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index f3c7c24..5352160 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -24,7 +24,7 @@ struct netpoll {
 	struct net_device *dev;
 	char dev_name[IFNAMSIZ];
 	const char *name;
-	void (*rx_hook)(struct netpoll *, int, char *, int);
+	void (*rx_hook)(struct netpoll *np, struct sk_buff *skb, int offset);
 
 	union inet_addr local_ip, remote_ip;
 	bool ipv6;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index fc75c9e..b415437 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -834,9 +834,8 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 			if (np->local_port && np->local_port != ntohs(uh->dest))
 				continue;
 
-			np->rx_hook(np, ntohs(uh->source),
-				       (char *)(uh+1),
-				       ulen - sizeof(struct udphdr));
+			np->rx_hook(np, skb,
+				    (unsigned char *)(uh + 1) - skb->data);
 			hits++;
 		}
 	} else {
@@ -872,9 +871,8 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 			if (np->local_port && np->local_port != ntohs(uh->dest))
 				continue;
 
-			np->rx_hook(np, ntohs(uh->source),
-				       (char *)(uh+1),
-				       ulen - sizeof(struct udphdr));
+			np->rx_hook(np, skb,
+				    (unsigned char *)(uh + 1) - skb->data);
 			hits++;
 		}
 #endif
-- 
1.8.4
