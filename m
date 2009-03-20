From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] net: release dst entry in dev_queue_xmit()
Date: Fri, 20 Mar 2009 12:40:22 +0100
Message-ID: <49C380A6.4000904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58283 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbZCTMDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 08:03:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One point of contention in high network loads is the dst_release() performed
when a transmited skb is freed. This is because NIC tx completion calls skb free
long after original call to dev_queue_xmit(skb).

CPU cache is cold and the atomic op in dst_release() stalls. On SMP, this is
quite visible if one CPU is 100% handling softirqs for a network device,
since dst_clone() is done by other cpus, involving cache line ping pongs.

I believe we can release dst in dev_queue_xmit(), while cpu cache is hot, since
caller of dev_queue_xmit() had to hold a reference on dst right before. This reduce
work to be done by softirq handler, and decrease cache misses.

I also believe only pktgen can call dev_queue_xmit() with skb which have
a skb->users != 1. But pkthen skbs have a NULL dst entry.

I added a WARN_ON_ONCE() to catch other cases, and not release skb->dst
if skb->users != 1


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


diff --git a/net/core/dev.c b/net/core/dev.c
index f112970..9e0fd01 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1852,6 +1852,20 @@ gso:
 	if (q->enqueue) {
 		spinlock_t *root_lock = qdisc_lock(q);
 
+		/*
+		 * Release dst while its refcnt is hot in CPU cache, instead
+		 * of waiting NIC tx completion
+		 */
+		if (likely(skb->dst)) {
+			if (!WARN_ON_ONCE(atomic_read(&skb->users) != 1)) {
+				int newrefcnt;
+
+				smp_mb__before_atomic_dec();
+				newrefcnt = atomic_dec_return(&skb->dst->__refcnt);
+				WARN_ON(newrefcnt < 0);
+				skb->dst = NULL;
+			}
+		}
 		spin_lock(root_lock);
 
 		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
