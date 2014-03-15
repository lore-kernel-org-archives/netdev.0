From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 05/10] netpoll: Add netpoll_rx_processing
Date: Fri, 14 Mar 2014 20:47:49 -0700
Message-ID: <87eh24p1ga.fsf_-_@xmission.com>
References: <87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
	<87eh24uu3d.fsf_-_@xmission.com>
	<20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51454 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755570AbaCODr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 23:47:56 -0400
In-Reply-To: <877g7wqg8e.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 20:43:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add a helper netpoll_rx_processing that reports when netpoll has
receive side processing to perform.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netpoll.h |   18 ++++++++++++++----
 net/core/netpoll.c      |    4 ++--
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index fbfdb9d8d3a7..479d15c97770 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -82,14 +82,24 @@ static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 	local_irq_restore(flags);
 }
 
-
+#ifdef CONFIG_NETPOLL_TRAP
+static inline bool netpoll_rx_processing(struct netpoll_info *npinfo)
+{
+	return !list_empty(&npinfo->rx_np);
+}
+#else
+static inline bool netpoll_rx_processing(struct netpoll_info *npinfo)
+{
+	return false;
+}
+#endif
 
 #ifdef CONFIG_NETPOLL
 static inline bool netpoll_rx_on(struct sk_buff *skb)
 {
 	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
 
-	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
+	return npinfo && (netpoll_rx_processing(npinfo) || npinfo->rx_flags);
 }
 
 static inline bool netpoll_rx(struct sk_buff *skb)
@@ -105,8 +115,8 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 
 	npinfo = rcu_dereference_bh(skb->dev->npinfo);
 	spin_lock(&npinfo->rx_lock);
-	/* check rx_flags again with the lock held */
-	if (npinfo->rx_flags && __netpoll_rx(skb, npinfo))
+	/* check rx_processing again with the lock held */
+	if (netpoll_rx_processing(npinfo) && __netpoll_rx(skb, npinfo))
 		ret = true;
 	spin_unlock(&npinfo->rx_lock);
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 2ad330e02967..ef83a2530e98 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -538,7 +538,7 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 	int hlen, tlen;
 	int hits = 0, proto;
 
-	if (list_empty(&npinfo->rx_np))
+	if (!netpoll_rx_processing(npinfo))
 		return;
 
 	/* Before checking the packet, we do some early
@@ -770,7 +770,7 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 	struct netpoll *np, *tmp;
 	uint16_t source;
 
-	if (list_empty(&npinfo->rx_np))
+	if (!netpoll_rx_processing(npinfo))
 		goto out;
 
 	if (skb->dev->type != ARPHRD_ETHER)
-- 
1.7.5.4
