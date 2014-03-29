From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: respect devices with LLTX flag in
 direct xmit
Date: Sat, 29 Mar 2014 08:02:30 -0700
Message-ID: <1396105350.21428.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395934710-29182-1-git-send-email-dborkman@redhat.com>
	 <20140328.165058.1610297081920676758.davem@davemloft.net>
	 <5335E604.4020105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	brouer@redhat.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:44817 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbaC2PCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 11:02:32 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so6266405pad.21
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2014 08:02:32 -0700 (PDT)
In-Reply-To: <5335E604.4020105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-28 at 22:13 +0100, Daniel Borkmann wrote:
> On 03/28/2014 09:50 PM, David Miller wrote:

> > The only remaining issue is that Eric seems to suggest that a tx
> > dropped counter bump should be added.  Please submit that as a
> > follow-on if my reading of his feedback is accurate.
> 
> Yes, will do next week. I think at time of submission we didn't
> have that yet. :)

BTW, how direct xmit performs in case of BQL enabled driver ?

dummy is nice, but not really representative of real device ;)

netif_xmit_frozen_or_stopped() tests (dev_queue->state &
QUEUE_STATE_ANY_XOFF_OR_FROZEN), so will not fill TX ring.

Since you have no queue, I would rather use a test without
BQL bit (1 << __QUEUE_STATE_STACK_XOFF), so that you can absorb bursts
into TX ring ...

 include/linux/netdevice.h |   21 ++++++++++++++++-----
 net/packet/af_packet.c    |    2 +-
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 159c7e7945f8..ed71a2cc1f66 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -526,11 +526,15 @@ enum netdev_queue_state_t {
 	__QUEUE_STATE_DRV_XOFF,
 	__QUEUE_STATE_STACK_XOFF,
 	__QUEUE_STATE_FROZEN,
-#define QUEUE_STATE_ANY_XOFF ((1 << __QUEUE_STATE_DRV_XOFF)		| \
-			      (1 << __QUEUE_STATE_STACK_XOFF))
-#define QUEUE_STATE_ANY_XOFF_OR_FROZEN (QUEUE_STATE_ANY_XOFF		| \
-					(1 << __QUEUE_STATE_FROZEN))
 };
+#define QUEUE_STATE_DRV_XOFF	(1 << __QUEUE_STATE_DRV_XOFF)
+#define QUEUE_STATE_STACK_XOFF	(1 << __QUEUE_STATE_STACK_XOFF)
+#define QUEUE_STATE_FROZEN	(1 << __QUEUE_STATE_FROZEN)
+
+#define QUEUE_STATE_ANY_XOFF	(QUEUE_STATE_DRV_XOFF | QUEUE_STATE_STACK_XOFF)
+#define QUEUE_STATE_ANY_XOFF_OR_FROZEN (QUEUE_STATE_ANY_XOFF | \
+					QUEUE_STATE_FROZEN)
+
 /*
  * __QUEUE_STATE_DRV_XOFF is used by drivers to stop the transmit queue.  The
  * netif_tx_* functions below are used to manipulate this flag.  The
@@ -2262,11 +2266,18 @@ static inline bool netif_xmit_stopped(const struct netdev_queue *dev_queue)
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
+	return dev_queue->state & (QUEUE_STATE_FROZEN | QUEUE_STATE_DRV_XOFF);
+}
+
 static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
 					unsigned int bytes)
 {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 01039d2b1695..c8d50690b619 100644
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
