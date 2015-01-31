From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 16/18] vhost: don't bother with copying iovec in handle_tx()
Date: Sat, 31 Jan 2015 03:56:42 +0000
Message-ID: <1422676604-18533-16-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55012 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756597AbbAaD4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 22:56:47 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

just advance the msg.msg_iter and be done with that.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/vhost/net.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 6906f76..d86cc9b 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -336,7 +336,7 @@ static void handle_tx(struct vhost_net *net)
 {
 	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
 	struct vhost_virtqueue *vq = &nvq->vq;
-	unsigned out, in, s;
+	unsigned out, in;
 	int head;
 	struct msghdr msg = {
 		.msg_name = NULL,
@@ -395,16 +395,17 @@ static void handle_tx(struct vhost_net *net)
 			break;
 		}
 		/* Skip header. TODO: support TSO. */
-		s = move_iovec_hdr(vq->iov, nvq->hdr, hdr_size, out);
 		len = iov_length(vq->iov, out);
 		iov_iter_init(&msg.msg_iter, WRITE, vq->iov, out, len);
+		iov_iter_advance(&msg.msg_iter, hdr_size);
 		/* Sanity check */
-		if (!len) {
+		if (!iov_iter_count(&msg.msg_iter)) {
 			vq_err(vq, "Unexpected header len for TX: "
 			       "%zd expected %zd\n",
-			       iov_length(nvq->hdr, s), hdr_size);
+			       len, hdr_size);
 			break;
 		}
+		len = iov_iter_count(&msg.msg_iter);
 
 		zcopy_used = zcopy && len >= VHOST_GOODCOPY_LEN
 				   && (nvq->upend_idx + 1) % UIO_MAXIOV !=
-- 
2.1.4
