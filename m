From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 1/6] net: fix a double free issue for neighbour entry
Date: Fri, 15 May 2015 14:55:41 +0800
Message-ID: <1431672946-300-2-git-send-email-ying.xue@windriver.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <alexei@purestorage.com>,
	<joern@purestorage.com>, <ja@ssi.bg>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35249 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061AbbEOG4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 02:56:05 -0400
In-Reply-To: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling __ipv4_neigh_lookup_noref() inside rcu_read_lock_bh() can
guarantee that its searched neighbour entry is not freed before RCU
grace period, but it cannot ensure that its obtained neighbour will
be freed shortly. Exactly saying, it cannot prevent neigh_destroy()
from being executed on another context at the same time. For example,
if ip_finish_output2() continues to deliver a SKB with a neighbour
entry whose refcount is zero, neigh_add_timer() may be called in
neigh_resolve_output() subsequently. As a result, neigh_add_timer()
takes refcount on the neighbour that already had a refcount of zero.
When the neighbour refcount is put before the timer's handler is
exited, neigh_destroy() is called again, meaning crash happens at the
moment.

To prevent the issue from occurring, we must check whether the refcount
of a neighbour searched by __ipv4_neigh_lookup_noref() is decremented
to zero or not. If it's zero, we should create a new one.

Reported-by: Joern Engel <joern@logfs.org>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/ipv4/ip_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 2acc5dc..580dd4d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -200,7 +200,7 @@ static inline int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
 	rcu_read_lock_bh();
 	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
 	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
-	if (unlikely(!neigh))
+	if (unlikely(!neigh || !atomic_read(&neigh->refcnt)))
 		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
 	if (!IS_ERR(neigh)) {
 		int res = dst_neigh_output(dst, neigh, skb);
-- 
1.7.9.5
