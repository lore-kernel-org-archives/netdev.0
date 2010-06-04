From: "Bruce Rogers" <brogers@novell.com>
Subject: [PATCH] KVM: add schedule check to napi_enable call
Date: Thu, 03 Jun 2010 18:48:31 -0600
Message-ID: <4C07F8FF0200004800097554@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <rusty@rustcorp.com.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please consider this patch for the 2.6.32, 2.6.33, and 2.6.34 stable trees as well as current development trees. (I've only tested on 2.6.32 however)

    virtio_net: Add schedule check to napi_enable call
    Under harsh testing conditions, including low memory, the guest would
    stop receiving packets. With this patch applied we no longer see any
    problems in the driver while performing these tests for extended periods
    of time.

    Make sure napi is scheduled subsequent to each napi_enable.

    Signed-off-by: Bruce Rogers <brogers@novell.com>
    Signed-off-by: Olaf Kirch <okir@suse.de>
    Acked-by: Rusty Russell <rusty@rustcorp.com.au>
    Cc: stable@kernel.org

--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -388,6 +388,20 @@ static void skb_recv_done(struct virtque
        }
 }

+static void virtnet_napi_enable(struct virtnet_info *vi)
+{
+       napi_enable(&vi->napi);
+
+       /* If all buffers were filled by other side before we napi_enabled, we
+        * won't get another interrupt, so process any outstanding packets
+        * now.  virtnet_poll wants re-enable the queue, so we disable here.
+        * We synchronize against interrupts via NAPI_STATE_SCHED */
+       if (napi_schedule_prep(&vi->napi)) {
+               vi->rvq->vq_ops->disable_cb(vi->rvq);
+               __napi_schedule(&vi->napi);
+       }
+}
+
 static void refill_work(struct work_struct *work)
 {
        struct virtnet_info *vi;
@@ -397,7 +411,7 @@ static void refill_work(struct work_stru
        napi_disable(&vi->napi);
        try_fill_recv(vi, GFP_KERNEL);
        still_empty = (vi->num == 0);
-       napi_enable(&vi->napi);
+       virtnet_napi_enable(vi);

        /* In theory, this can happen: if we don't get any buffers in
         * we will *never* try to fill again. */
@@ -589,16 +603,7 @@ static int virtnet_open(struct net_devic
 {
        struct virtnet_info *vi = netdev_priv(dev);

-       napi_enable(&vi->napi);
-
-       /* If all buffers were filled by other side before we napi_enabled, we
-        * won't get another interrupt, so process any outstanding packets
-        * now.  virtnet_poll wants re-enable the queue, so we disable here.
-        * We synchronize against interrupts via NAPI_STATE_SCHED */
-       if (napi_schedule_prep(&vi->napi)) {
-               vi->rvq->vq_ops->disable_cb(vi->rvq);
-               __napi_schedule(&vi->napi);
-       }
+       virtnet_napi_enable(vi);
        return 0;
 }







