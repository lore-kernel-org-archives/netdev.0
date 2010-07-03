From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/2] virtio_net: do not reschedule rx refill forever
Date: Sat, 3 Jul 2010 12:32:55 +1000
Message-ID: <201007031232.56510.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46154 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756911Ab0GCCdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jul 2010 22:33:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>

We currently fill all of RX ring, then add_buf
returns ENOSPC, which gets mis-detected as an out of
memory condition and causes us to reschedule the work,
and so on forever. Fix this by oom = err == -ENOMEM;

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Cc: stable@kernel.org # .34.x
---
 drivers/net/virtio_net.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 06c30df..85615a3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -416,7 +416,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
 static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 {
 	int err;
-	bool oom = false;
+	bool oom;
 
 	do {
 		if (vi->mergeable_rx_bufs)
@@ -426,10 +426,9 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 		else
 			err = add_recvbuf_small(vi, gfp);
 
-		if (err < 0) {
-			oom = true;
+		oom = err == -ENOMEM;
+		if (err < 0)
 			break;
-		}
 		++vi->num;
 	} while (err > 0);
 	if (unlikely(vi->num > vi->max))
