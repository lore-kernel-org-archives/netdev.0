From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: fix data corruption with OOM
Date: Mon, 26 Oct 2009 12:11:51 +1030
Message-ID: <200910261211.52148.rusty@rustcorp.com.au>
References: <20091025170340.GA22099@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20091025170340.GA22099@redhat.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Oct 2009 03:33:40 am Michael S. Tsirkin wrote:
> virtio net used to unlink skbs from send queues on error,
> but ever since 48925e372f04f5e35fec6269127c62b2c71ab794
> we do not do this. This causes guest data corruption and crashes
> with vhost since net core can requeue the skb or free it without
> it being taken off the list.
> 
> This patch fixes this by queueing the skb after successfull
> transmit.

I originally thought that this was racy: as soon as we do add_buf, we need to
make sure we're ready for the callback (for virtio_pci, it's ->kick, but we
shouldn't rely on that).

So a comment would be nice.  How's this?

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

Rusty, here's a fix for another data corrupter I saw.
This fixes a regression from 2.6.31, so definitely
2.6.32 I think. Comments?

 drivers/net/virtio_net.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

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
