From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: fix data corruption with OOM
Date: Wed, 28 Oct 2009 21:26:58 +1030
Message-ID: <200910282126.58902.rusty@rustcorp.com.au>
References: <20091025170340.GA22099@redhat.com> <20091026090713.GA23510@redhat.com> <20091026.182720.81248604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51259 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbZJ1K44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 06:56:56 -0400
In-Reply-To: <20091026.182720.81248604.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Oct 2009 11:57:20 am you wrote:
> Anything in a reply to a patch that looks like a signoff or ACK,
> patchwork adds to the commit message in the mbox blob it spits out for
> me.

In case this got lost in the meta-discussion:

Subject: virtio-net: fix data corruption with OOM
Date: Sun, 25 Oct 2009 19:03:40 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>

virtio net used to unlink skbs from send queues on error,
but ever since 48925e372f04f5e35fec6269127c62b2c71ab794
we do not do this. This causes guest data corruption and crashes
with vhost since net core can requeue the skb or free it without
it being taken off the list.

This patch fixes this by queueing the skb after successful
transmit.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (+ comment)
---
 drivers/net/virtio_net.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -516,8 +516,7 @@ again:
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(vi);
 
-	/* Put new one in send queue and do transmit */
-	__skb_queue_head(&vi->send, skb);
+	/* Try to transmit */
 	capacity = xmit_skb(vi, skb);
 
 	/* This can happen with OOM and indirect buffers. */
@@ -531,8 +530,17 @@ again:
 		}
 		return NETDEV_TX_BUSY;
 	}
+	vi->svq->vq_ops->kick(vi->svq);
 
-	vi->svq->vq_ops->kick(vi->svq);
+	/*
+	 * Put new one in send queue.  You'd expect we'd need this before
+	 * xmit_skb calls add_buf(), since the callback can be triggered
+	 * immediately after that.  But since the callback just triggers
+	 * another call back here, normal network xmit locking prevents the
+	 * race.
+	 */
+	__skb_queue_head(&vi->send, skb);
+
 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
 	nf_reset(skb);

