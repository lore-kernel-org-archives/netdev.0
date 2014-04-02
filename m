From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH 2/2] packet: fix packet_direct_xmit for BQL enabled drivers
Date: Wed,  2 Apr 2014 20:52:57 +0200
Message-ID: <1396464777-18375-3-git-send-email-dborkman@redhat.com>
References: <1396464777-18375-1-git-send-email-dborkman@redhat.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63054 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932827AbaDBSxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2014 14:53:10 -0400
In-Reply-To: <1396464777-18375-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, in packet_direct_xmit() we test the assigned netdevice queue
for netif_xmit_frozen_or_stopped() before doing an ndo_start_xmit().

This can have the side-effect that BQL enabled drivers which make use
of netdev_tx_sent_queue() internally, set __QUEUE_STATE_STACK_XOFF from
within the stack and would not fully fill the device's TX ring from
packet sockets with PACKET_QDISC_BYPASS enabled.

Instead, use a test without BQL bit so that bursts can be absorbed
into the NICs TX ring. Fix and code suggested by Eric Dumazet, thanks!

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/netdevice.h | 24 +++++++++++++++++++-----
 net/packet/af_packet.c    |  2 +-
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 775cc95..7ed3a3a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -519,11 +519,18 @@ enum netdev_queue_state_t {
 	__QUEUE_STATE_DRV_XOFF,
 	__QUEUE_STATE_STACK_XOFF,
 	__QUEUE_STATE_FROZEN,
-#define QUEUE_STATE_ANY_XOFF ((1 << __QUEUE_STATE_DRV_XOFF)		| \
-			      (1 << __QUEUE_STATE_STACK_XOFF))
-#define QUEUE_STATE_ANY_XOFF_OR_FROZEN (QUEUE_STATE_ANY_XOFF		| \
-					(1 << __QUEUE_STATE_FROZEN))
 };
+
+#define QUEUE_STATE_DRV_XOFF	(1 << __QUEUE_STATE_DRV_XOFF)
+#define QUEUE_STATE_STACK_XOFF	(1 << __QUEUE_STATE_STACK_XOFF)
+#define QUEUE_STATE_FROZEN	(1 << __QUEUE_STATE_FROZEN)
+
+#define QUEUE_STATE_ANY_XOFF	(QUEUE_STATE_DRV_XOFF | QUEUE_STATE_STACK_XOFF)
+#define QUEUE_STATE_ANY_XOFF_OR_FROZEN (QUEUE_STATE_ANY_XOFF | \
+					QUEUE_STATE_FROZEN)
+#define QUEUE_STATE_DRV_XOFF_OR_FROZEN (QUEUE_STATE_DRV_XOFF | \
+					QUEUE_STATE_FROZEN)
+
 /*
  * __QUEUE_STATE_DRV_XOFF is used by drivers to stop the transmit queue.  The
  * netif_tx_* functions below are used to manipulate this flag.  The
@@ -2252,11 +2259,18 @@ static inline bool netif_xmit_stopped(const struct netdev_queue *dev_queue)
 	return dev_queue->state & QUEUE_STATE_ANY_XOFF;
 }
 
-static inline bool netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_queue)
+static inline bool
+netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_queue)
 {
 	return dev_queue->state & QUEUE_STATE_ANY_XOFF_OR_FROZEN;
 }
 
+static inline bool
+netif_xmit_frozen_or_drv_stopped(const struct netdev_queue *dev_queue)
+{
+	return dev_queue->state & QUEUE_STATE_DRV_XOFF_OR_FROZEN;
+}
+
 static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
 					unsigned int bytes)
 {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c81a971..72e0c71 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -261,7 +261,7 @@ static int packet_direct_xmit(struct sk_buff *skb)
 	local_bh_disable();
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_xmit_frozen_or_stopped(txq)) {
+	if (!netif_xmit_frozen_or_drv_stopped(txq)) {
 		ret = ops->ndo_start_xmit(skb, dev);
 		if (ret == NETDEV_TX_OK)
 			txq_trans_update(txq);
-- 
1.7.11.7
