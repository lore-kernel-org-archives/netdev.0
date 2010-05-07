From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] fix multi-buffer logging with mergeable buffers
Date: Fri, 07 May 2010 13:11:08 -0700
Message-ID: <1273263068.24088.1.camel@w-dls.beaverton.ibm.com>
Reply-To: dlstevens@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:48362 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758152Ab0EGULR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 16:11:17 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o47K4s1F017974
	for <netdev@vger.kernel.org>; Fri, 7 May 2010 14:04:54 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o47KBBET243220
	for <netdev@vger.kernel.org>; Fri, 7 May 2010 14:11:11 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o47KBAJj003223
	for <netdev@vger.kernel.org>; Fri, 7 May 2010 14:11:10 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the multibuffer case of logging with
mergeable buffers.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 85519b4..d526b68 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -236,8 +236,9 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 	int seg = 0;
 	int headcount = 0;
 	unsigned d;
-	int r;
+	int r, nlogs;
 
+	nlogs = 0;
 	while (datalen > 0) {
 		if (unlikely(headcount >= VHOST_NET_MAX_SG)) {
 			r = -ENOBUFS;
@@ -245,7 +246,8 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 		}
 		d = vhost_get_desc(vq->dev, vq, vq->iov + seg,
 				   ARRAY_SIZE(vq->iov) - seg, &out,
-				   &in, log, log_num);
+				   &in, log+nlogs, log_num);
+		nlogs += log ? *log_num : 0;
 		if (d == vq->num) {
 			r = 0;
 			goto err;
@@ -263,6 +265,8 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 		seg += in;
 	}
 	*iovcount = seg;
+	if (unlikely(log))
+		*log_num = nlogs;
 	return headcount;
 err:
 	vhost_discard_desc(vq, headcount);


