From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: netif_tx_queue_stopped too expensive
Date: Tue, 28 Apr 2009 11:32:20 +0200
Message-ID: <49F6CD24.5080000@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53582 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374AbZD1Jfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 05:35:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_tx_queue_stopped(txq) is most of the time false.

Yet its cost is very expensive on SMP.

static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
{
	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
}

I saw this on oprofile hunting and bnx2 driver bnx2_tx_int().

We probably should split "struct netdev_queue" in two parts, one
being read mostly.

__netif_tx_lock() touches _xmit_lock & xmit_lock_owner, these
deserve a separate cache line.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e7783f..1caaebb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -447,12 +447,18 @@ enum netdev_queue_state_t
 };
 
 struct netdev_queue {
+/*
+ * read mostly part
+ */
 	struct net_device	*dev;
 	struct Qdisc		*qdisc;
 	unsigned long		state;
-	spinlock_t		_xmit_lock;
-	int			xmit_lock_owner;
 	struct Qdisc		*qdisc_sleeping;
+/*
+ * write mostly part
+ */
+	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
+	int			xmit_lock_owner;
 } ____cacheline_aligned_in_smp;
 
 
