From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH RFC net-next] virtio_net: refill buffer right after
 being used
Date: Fri, 29 Jul 2011 15:55:31 -0700
Message-ID: <1311980131.24300.30.camel@localhost.localdomain>
References: <1311979448.24300.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:56588 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752838Ab1G2W4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 18:56:55 -0400
In-Reply-To: <1311979448.24300.28.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resubmit it with a typo fix.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0c7321c..c8201d4 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -429,6 +429,22 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
 	return err;
 }
 
+static int fill_one(struct virtnet_info *vi, gfp_t gfp)
+{
+	int err;
+
+	if (vi->mergeable_rx_bufs)
+		err = add_recvbuf_mergeable(vi, gfp);
+	else if (vi->big_packets)
+		err = add_recvbuf_big(vi, gfp);
+	else
+		err = add_recvbuf_small(vi, gfp);
+
+	if (err >= 0)
+		++vi->num;
+	return err;
+}
+
 /* Returns false if we couldn't fill entirely (OOM). */
 static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 {
@@ -436,17 +452,10 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 	bool oom;
 
 	do {
-		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(vi, gfp);
-		else if (vi->big_packets)
-			err = add_recvbuf_big(vi, gfp);
-		else
-			err = add_recvbuf_small(vi, gfp);
-
+		err = fill_one(vi, gfp);
 		oom = err == -ENOMEM;
 		if (err < 0)
 			break;
-		++vi->num;
 	} while (err > 0);
 	if (unlikely(vi->num > vi->max))
 		vi->max = vi->num;
@@ -506,13 +515,13 @@ again:
 		receive_buf(vi->dev, buf, len);
 		--vi->num;
 		received++;
-	}
-
-	if (vi->num < vi->max / 2) {
-		if (!try_fill_recv(vi, GFP_ATOMIC))
+		if (fill_one(vi, GFP_ATOMIC) < 0)
 			schedule_delayed_work(&vi->refill, 0);
 	}
 
+	/* notify buffers are refilled */
+	virtqueue_kick(vi->rvq);
+
 	/* Out of packets? */
 	if (received < budget) {
 		napi_complete(napi);


