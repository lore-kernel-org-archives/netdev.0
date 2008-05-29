From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/3] virtio: fix virtio_net xmit of freed skb bug
Date: Thu, 29 May 2008 16:34:18 +1000
Message-ID: <200805291634.18224.rusty@rustcorp.com.au>
References: <200805261742.43215.rusty@rustcorp.com.au> <1211886386.3637.48.camel@muff>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57159 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbYE2Gf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 02:35:59 -0400
In-Reply-To: <1211886386.3637.48.camel@muff>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 May 2008 21:06:26 Mark McLoughlin wrote:
> On Mon, 2008-05-26 at 17:42 +1000, Rusty Russell wrote:
> > If we fail to transmit a packet, we assume the queue is full and put
> > the skb into last_xmit_skb.  However, if more space frees up before we
> > xmit it, we loop, and the result can be transmitting the same skb twice.
> >
> > Fix is simple: set skb to NULL if we've used it in some way, and check
> > before sending.

Great! It's a corner case, but it's no more complicated to do it your way.

Minor mod, I find it clearer to have the vi->last_xmit_skb = NULL; under
the branch:

Subject: [PATCH] virtio_net: Delay dropping tx skbs
Date: Tue, 27 May 2008 12:06:26 +0100
From: Mark McLoughlin <markmc@redhat.com>

Currently we drop the skb in start_xmit() if we have a
queued buffer and fail to transmit it.

However, if we delay dropping it until we've stopped the
queue and enabled the tx notification callback, then there
is a chance space might become available for it.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (move last_xmit_skb = NULL)
---
 drivers/net/virtio_net.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -308,13 +308,8 @@ again:
 
 	/* If we has a buffer left over from last time, send it now. */
 	if (unlikely(vi->last_xmit_skb)) {
-		if (xmit_skb(vi, vi->last_xmit_skb) != 0) {
-			/* Drop this skb: we only queue one. */
-			vi->dev->stats.tx_dropped++;
-			kfree_skb(skb);
-			skb = NULL;
+		if (xmit_skb(vi, vi->last_xmit_skb) != 0)
 			goto stop_queue;
-		}
 		vi->last_xmit_skb = NULL;
 	}
 
@@ -341,6 +336,11 @@ stop_queue:
 		vi->svq->vq_ops->disable_cb(vi->svq);
 		netif_start_queue(dev);
 		goto again;
+	}
+	if (skb) {
+		/* Drop this skb: we only queue one. */
+		vi->dev->stats.tx_dropped++;
+		kfree_skb(skb);
 	}
 	goto done;
 }
