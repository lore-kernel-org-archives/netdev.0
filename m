From: Christoph Lameter <cl@linux-foundation.org>
Subject: IPoIB: Fix multicast packet drops before join is complete
Date: Tue, 2 Jun 2009 10:49:21 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0906021044430.15692@gentwo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Yossi Etigin <yosefe@Voltaire.COM>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:35314 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753227AbZFBOt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 10:49:27 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AB98382CA4C
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2009 11:04:11 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bzqg1lkEY5zw for <netdev@vger.kernel.org>;
	Tue,  2 Jun 2009 11:04:07 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0E17482C95A
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2009 11:04:07 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: IPoIB: Fix multicast packet drops before join is complete

The IPoIB layer drops multicast packets after queueing 3 as long as a
multicast group is not ready. The multicast group not being ready may
occur on first use or after a period of silence on a MC group.

What should happen is that packet are queued up until the maximum queue
size is reached (set by sk_sndbuf). Then the socket layer would put
the sending process to sleep until space in the queue becomes available
(after the multicast group becomes ready and after the initial messages
have been sent).

With the IPoIB layer dropping packets this does not occur. The process
can continue sending multicast packets and they are all dropped until
the multicast group becomes ready. The receiver will see the initial 3
multicast packets that have been significantly delayed, then a large
gap of missing packet before getting packets that have not been delayed.

After this patch the socket queue will build up and the sender will be
throttled until the MC group becomes ready.

If old behavior is desired then the application can configure
the send queue size to only allow 3 packet and specify MSG_DONTWAIT
for send operations.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 drivers/infiniband/ulp/ipoib/ipoib.h           |    1 -
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    7 +------
 2 files changed, 1 insertion(+), 7 deletions(-)

Index: linux-2.6/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib_multicast.c	2009-05-28 15:50:56.000000000 -0500
+++ linux-2.6/drivers/infiniband/ulp/ipoib/ipoib_multicast.c	2009-06-02 09:27:40.000000000 -0500
@@ -685,12 +685,7 @@ void ipoib_mcast_send(struct net_device
 	}

 	if (!mcast->ah) {
-		if (skb_queue_len(&mcast->pkt_queue) < IPOIB_MAX_MCAST_QUEUE)
-			skb_queue_tail(&mcast->pkt_queue, skb);
-		else {
-			++dev->stats.tx_dropped;
-			dev_kfree_skb_any(skb);
-		}
+		skb_queue_tail(&mcast->pkt_queue, skb);

 		if (test_bit(IPOIB_MCAST_FLAG_BUSY, &mcast->flags))
 			ipoib_dbg_mcast(priv, "no address vector, "
Index: linux-2.6/drivers/infiniband/ulp/ipoib/ipoib.h
===================================================================
--- linux-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib.h	2009-05-28 15:50:56.000000000 -0500
+++ linux-2.6/drivers/infiniband/ulp/ipoib/ipoib.h	2009-06-02 09:27:40.000000000 -0500
@@ -79,7 +79,6 @@ enum {
 	IPOIB_NUM_WC		  = 4,

 	IPOIB_MAX_PATH_REC_QUEUE  = 3,
-	IPOIB_MAX_MCAST_QUEUE	  = 3,

 	IPOIB_FLAG_OPER_UP	  = 0,
 	IPOIB_FLAG_INITIALIZED	  = 1,
