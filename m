From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] gianfar: Fix crashes on RX path (Was Re: [Bugme-new] [Bug
	19692] New: linux-2.6.36-rc5 crash with gianfar ethernet at full
	line rate traffic)
Date: Tue, 19 Oct 2010 10:06:36 +0000
Message-ID: <20101019100636.GA9246@ff.dom.local>
References: <20101010103236.GA1919@del.dom.local> <20101015085853.GA8091@ff.dom.local> <AANLkTinAj=9-RqNA6xKc_5ONz2hPMRGM8uJ2Xy7XJVdr@mail.gmail.com> <20101016194815.GA1894@del.dom.local> <AANLkTi=08Myz1=XOHkGJWTdyC8vK+y+zf0UQhjxUi=qC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: emin ak <eminak71@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Anton Vorontsov <avorontsov@mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55241 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933868Ab0JSKGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 06:06:44 -0400
Received: by bwz10 with SMTP id 10so131483bwz.19
        for <netdev@vger.kernel.org>; Tue, 19 Oct 2010 03:06:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTi=08Myz1=XOHkGJWTdyC8vK+y+zf0UQhjxUi=qC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 19, 2010 at 09:44:33AM +0300, emin ak wrote:
> Hi Jarek;
> After 5 days and more then 20 billion packets passed without crash, it
> seems that this patch is working for me, at least for crash type 2.
> (For type 1, it only occured once and I can never reproduce this
> again, but still trying. I think with this patch is also lowers the
> risk for type 1.

It would be interesting to have a look if it's exactly type 1, because
skb_over_panic can happen for different reasons, e.g. like here:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=63b88b9041ceef8217f34de71a2e96f0c3f0fd3b

> For adding a new bug entry for skb_over_panic, before that I think I
> must find a reliable way to make this type of crash reproducable,
> otherwise I don't know how to test it if it solved or not.

Maybe for now let's try to get and see this type 1 again? Since the
recycle path is suspicious a bit to me, probably limiting memory or
slowing tx (maybe different mtus on eth0 and 1) under heavy multi cpu
load might help.

> Lastly, thanks a lot for your valuable help to overcome this problem
> and also is there anything that I can do  for testing / commiting this
> patch to mainline?

Here it is for David to handle the rest.

Thanks a lot for such an intense testing,
Jarek P.
--------------------------->

The rx_recycle queue is global per device but can be accesed by many
napi handlers at the same time, so it needs full skb_queue primitives
(with locking). Otherwise, various crashes caused by broken skbs are
possible.

This patch resolves, at least partly, bugzilla bug 19692. (Because of
some doubts that there could be still something around which is hard
to reproduce my proposal is to leave this bug opened for a month.)

Fixes commit: 0fd56bb5be6455d0d42241e65aed057244665e5e

Reported-by: emin ak <eminak71@gmail.com>
Tested-by: emin ak <eminak71@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
CC: Andy Fleming <afleming@freescale.com>
---
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4f7c3f3..db47b55 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2515,7 +2515,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 				skb_recycle_check(skb, priv->rx_buffer_size +
 					RXBUF_ALIGNMENT)) {
 			gfar_align_skb(skb);
-			__skb_queue_head(&priv->rx_recycle, skb);
+			skb_queue_head(&priv->rx_recycle, skb);
 		} else
 			dev_kfree_skb_any(skb);
 
@@ -2598,7 +2598,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 	struct sk_buff *skb = NULL;
 
-	skb = __skb_dequeue(&priv->rx_recycle);
+	skb = skb_dequeue(&priv->rx_recycle);
 	if (!skb)
 		skb = gfar_alloc_skb(dev);
 
@@ -2754,7 +2754,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 			if (unlikely(!newskb))
 				newskb = skb;
 			else if (skb)
-				__skb_queue_head(&priv->rx_recycle, skb);
+				skb_queue_head(&priv->rx_recycle, skb);
 		} else {
 			/* Increment the number of packets */
 			rx_queue->stats.rx_packets++;
