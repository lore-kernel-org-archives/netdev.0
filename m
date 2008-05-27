From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 1/3] virtio: fix virtio_net xmit of freed skb bug
Date: Tue, 27 May 2008 12:06:26 +0100
Message-ID: <1211886386.3637.48.camel@muff>
References: <200805261742.43215.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38931 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756617AbYE0LGi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 07:06:38 -0400
In-Reply-To: <200805261742.43215.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-05-26 at 17:42 +1000, Rusty Russell wrote:
> If we fail to transmit a packet, we assume the queue is full and put
> the skb into last_xmit_skb.  However, if more space frees up before we
> xmit it, we loop, and the result can be transmitting the same skb twice.
> 
> Fix is simple: set skb to NULL if we've used it in some way, and check
> before sending.
...
> diff -r 564237b31993 drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c	Mon May 19 12:22:00 2008 +1000
> +++ b/drivers/net/virtio_net.c	Mon May 19 12:24:58 2008 +1000
> @@ -287,21 +287,25 @@ again:
>  	free_old_xmit_skbs(vi);
>  
>  	/* If we has a buffer left over from last time, send it now. */
> -	if (vi->last_xmit_skb) {
> +	if (unlikely(vi->last_xmit_skb)) {
>  		if (xmit_skb(vi, vi->last_xmit_skb) != 0) {
>  			/* Drop this skb: we only queue one. */
>  			vi->dev->stats.tx_dropped++;
>  			kfree_skb(skb);
> +			skb = NULL;
>  			goto stop_queue;
>  		}
>  		vi->last_xmit_skb = NULL;

With this, may drop an skb and then later in the function discover that
we could have sent it after all. Poor wee skb :)

How about the incremental patch below?

Cheers,
Mark.

Subject: [PATCH] virtio_net: Delay dropping tx skbs

Currently we drop the skb in start_xmit() if we have a
queued buffer and fail to transmit it.

However, if we delay dropping it until we've stopped the
queue and enabled the tx notification callback, then there
is a chance space might become available for it.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/virtio_net.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d50f4fe..30af05c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -287,16 +287,11 @@ again:
 	free_old_xmit_skbs(vi);
 
 	/* If we has a buffer left over from last time, send it now. */
-	if (unlikely(vi->last_xmit_skb)) {
-		if (xmit_skb(vi, vi->last_xmit_skb) != 0) {
-			/* Drop this skb: we only queue one. */
-			vi->dev->stats.tx_dropped++;
-			kfree_skb(skb);
-			skb = NULL;
-			goto stop_queue;
-		}
-		vi->last_xmit_skb = NULL;
-	}
+	if (unlikely(vi->last_xmit_skb) &&
+	    xmit_skb(vi, vi->last_xmit_skb) != 0)
+		goto stop_queue;
+
+	vi->last_xmit_skb = NULL;
 
 	/* Put new one in send queue and do transmit */
 	if (likely(skb)) {
@@ -322,6 +317,11 @@ stop_queue:
 		netif_start_queue(dev);
 		goto again;
 	}
+	if (skb) {
+		/* Drop this skb: we only queue one. */
+		vi->dev->stats.tx_dropped++;
+		kfree_skb(skb);
+	}
 	goto done;
 }
 


