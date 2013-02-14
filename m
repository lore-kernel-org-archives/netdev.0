From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next] net: Don't write to current task flags on every
 packet received.
Date: Thu, 14 Feb 2013 15:58:23 -0500 (EST)
Message-ID: <20130214.155823.2119249078866607548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758193Ab3BNU61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 15:58:27 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3B5BB5813B9
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 12:58:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Even for non-pfmalloc SKBs, __netif_receive_skb() will do a
tsk_restore_flags() on current unconditionally.

Make __netif_receive_skb() a shim around the existing code, renamed to
__netif_receive_skb_core().  Let __netif_receive_skb() wrap the
__netif_receive_skb_core() call with the task flag modifications, if
necessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

I'll commit this after I do a bunch of tests.

 net/core/dev.c | 46 ++++++++++++++++++++++++++++------------------
 1 file changed, 28 insertions(+), 18 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2f31bf9..f444736 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3457,7 +3457,7 @@ static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
 	}
 }
 
-static int __netif_receive_skb(struct sk_buff *skb)
+static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 {
 	struct packet_type *ptype, *pt_prev;
 	rx_handler_func_t *rx_handler;
@@ -3466,24 +3466,11 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	bool deliver_exact = false;
 	int ret = NET_RX_DROP;
 	__be16 type;
-	unsigned long pflags = current->flags;
 
 	net_timestamp_check(!netdev_tstamp_prequeue, skb);
 
 	trace_netif_receive_skb(skb);
 
-	/*
-	 * PFMEMALLOC skbs are special, they should
-	 * - be delivered to SOCK_MEMALLOC sockets only
-	 * - stay away from userspace
-	 * - have bounded memory usage
-	 *
-	 * Use PF_MEMALLOC as this saves us from propagating the allocation
-	 * context down to all allocation sites.
-	 */
-	if (sk_memalloc_socks() && skb_pfmemalloc(skb))
-		current->flags |= PF_MEMALLOC;
-
 	/* if we've gotten here through NAPI, check netpoll */
 	if (netpoll_receive_skb(skb))
 		goto out;
@@ -3517,7 +3504,7 @@ another_round:
 	}
 #endif
 
-	if (sk_memalloc_socks() && skb_pfmemalloc(skb))
+	if (pfmemalloc)
 		goto skip_taps;
 
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
@@ -3536,8 +3523,7 @@ skip_taps:
 ncls:
 #endif
 
-	if (sk_memalloc_socks() && skb_pfmemalloc(skb)
-				&& !skb_pfmemalloc_protocol(skb))
+	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
 
 	if (vlan_tx_tag_present(skb)) {
@@ -3607,7 +3593,31 @@ drop:
 unlock:
 	rcu_read_unlock();
 out:
-	tsk_restore_flags(current, pflags, PF_MEMALLOC);
+	return ret;
+}
+
+static int __netif_receive_skb(struct sk_buff *skb)
+{
+	int ret;
+
+	if (sk_memalloc_socks() && skb_pfmemalloc(skb)) {
+		unsigned long pflags = current->flags;
+
+		/*
+		 * PFMEMALLOC skbs are special, they should
+		 * - be delivered to SOCK_MEMALLOC sockets only
+		 * - stay away from userspace
+		 * - have bounded memory usage
+		 *
+		 * Use PF_MEMALLOC as this saves us from propagating the allocation
+		 * context down to all allocation sites.
+		 */
+		current->flags |= PF_MEMALLOC;
+		ret = __netif_receive_skb_core(skb, true);
+		tsk_restore_flags(current, pflags, PF_MEMALLOC);
+	} else
+		ret = __netif_receive_skb_core(skb, false);
+
 	return ret;
 }
 
-- 
1.7.11.7
