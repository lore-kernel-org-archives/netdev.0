From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] virtio_net: Add schedule check to napi_enable call
Date: Thu, 10 Feb 2011 12:32:50 +1030
Message-ID: <201102101232.50526.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	virtualization@lists.linux-foundation.org,
	Ken Stailey <kstailey@yahoo.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46124 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806Ab1BJCCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Feb 2011 21:02:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Bruce Rogers" <brogers@novell.com>

Under harsh testing conditions, including low memory, the guest would
stop receiving packets. With this patch applied we no longer see any
problems in the driver while performing these tests for extended periods
of time.

Make sure napi is scheduled subsequent to each napi_enable.

Signed-off-by: Bruce Rogers <brogers@novell.com>
Signed-off-by: Olaf Kirch <okir@suse.de>
Cc: stable@kernel.org
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -446,6 +446,20 @@ static void skb_recv_done(struct virtque
 	}
 }
 
+static void virtnet_napi_enable(struct virtnet_info *vi)
+{
+	napi_enable(&vi->napi);
+
+	/* If all buffers were filled by other side before we napi_enabled, we
+	 * won't get another interrupt, so process any outstanding packets
+	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
+	 * We synchronize against interrupts via NAPI_STATE_SCHED */
+	if (napi_schedule_prep(&vi->napi)) {
+		virtqueue_disable_cb(vi->rvq);
+		__napi_schedule(&vi->napi);
+	}
+}
+
 static void refill_work(struct work_struct *work)
 {
 	struct virtnet_info *vi;
@@ -454,7 +468,7 @@ static void refill_work(struct work_stru
 	vi = container_of(work, struct virtnet_info, refill.work);
 	napi_disable(&vi->napi);
 	still_empty = !try_fill_recv(vi, GFP_KERNEL);
-	napi_enable(&vi->napi);
+	virtnet_napi_enable(vi);
 
 	/* In theory, this can happen: if we don't get any buffers in
 	 * we will *never* try to fill again. */
@@ -638,16 +652,7 @@ static int virtnet_open(struct net_devic
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
-	napi_enable(&vi->napi);
-
-	/* If all buffers were filled by other side before we napi_enabled, we
-	 * won't get another interrupt, so process any outstanding packets
-	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
-	 * We synchronize against interrupts via NAPI_STATE_SCHED */
-	if (napi_schedule_prep(&vi->napi)) {
-		virtqueue_disable_cb(vi->rvq);
-		__napi_schedule(&vi->napi);
-	}
+	virtnet_napi_enable(vi);
 	return 0;
 }
 
