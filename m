From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH for-2.6.35] virtio_net: fix oom handling on tx
Date: Mon, 21 Jun 2010 12:13:49 +0930
Message-ID: <201006211213.49600.rusty@rustcorp.com.au>
References: <20100610152041.GA3480@redhat.com> <20100610104653.1aed2ecc@nehalam> <20100610190343.GC4044@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	virtualization@lists.linux-foundation.org,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59714 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755962Ab0FUCn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jun 2010 22:43:56 -0400
In-Reply-To: <20100610190343.GC4044@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jun 2010 04:33:43 am Michael S. Tsirkin wrote:
> > > > @@ -572,12 +571,14 @@ again:
> > > > 
> > > >  	/* This can happen with OOM and indirect buffers. */
> > > >  	if (unlikely(capacity < 0)) {
> > > > -		netif_stop_queue(dev);
> > > > -		dev_warn(&dev->dev, "Unexpected full queue\n");
> > > > -		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
> > > > -			virtqueue_disable_cb(vi->svq);
> > > > -			netif_start_queue(dev);
> > > > -			goto again;
> > > > +		if (net_ratelimit()) {
> > > > +			if (likely(capacity == -ENOMEM))
> > > > +				dev_warn(&dev->dev,
> > > > +					 "TX queue failure: out of memory\n");
> > > > +			else
> > > > +				dev_warn(&dev->dev,
> > > > +					 "Unexpected TX queue failure: %d\n",
> > > > +					 capacity);
...
> 
> Well, I only keep the existing behaviour around.

Actually, it *does* change behavior, as the comment indicates.  So let's
fix the whole thing.  AFAICT wth TX_BUSY we'll get called again RSN, and
that's not really useful for OOM.

This is what I have:

Subject: virtio_net: fix oom handling on tx
Date: Thu, 10 Jun 2010 18:20:41 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>

virtio net will never try to overflow the TX ring, so the only reason
add_buf may fail is out of memory. Thus, we can not stop the
device until some request completes - there's no guarantee anything
at all is outstanding.

Make the error message clearer as well: error here does not
indicate queue full.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (...and avoid TX_BUSY)
Cc: stable@kernel.org
---
 drivers/net/virtio_net.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -562,7 +562,6 @@ static netdev_tx_t start_xmit(struct sk_
 	struct virtnet_info *vi = netdev_priv(dev);
 	int capacity;
 
-again:
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(vi);
 
@@ -571,14 +570,17 @@ again:
 
 	/* This can happen with OOM and indirect buffers. */
 	if (unlikely(capacity < 0)) {
-		netif_stop_queue(dev);
-		dev_warn(&dev->dev, "Unexpected full queue\n");
-		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
-			virtqueue_disable_cb(vi->svq);
-			netif_start_queue(dev);
-			goto again;
+		if (net_ratelimit()) {
+			if (likely(capacity == -ENOMEM))
+				dev_warn(&dev->dev,
+					 "TX queue failure: out of memory\n");
+			else
+				dev_warn(&dev->dev,
+					 "Unexpected TX queue failure: %d\n",
+					 capacity);
 		}
-		return NETDEV_TX_BUSY;
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
 	}
 	virtqueue_kick(vi->svq);
 
