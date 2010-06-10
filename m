From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH for-2.6.35] virtio_net: do not reschedule rx refill forever
Date: Thu, 10 Jun 2010 18:18:27 +0300
Message-ID: <20100610151827.GA3452@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54948 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791Ab0FJPXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 11:23:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently fill all of RX ring, then add_buf
returns ENOSPC, which gets mis-detected as an out of
memory condition and causes us to reschedule the work,
and so on forever. Fix this by oom = err == -ENOMEM;

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Rusty, please review the following patch for 2.6.35.

 drivers/net/virtio_net.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

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
-- 
1.7.1.12.g42b7f
