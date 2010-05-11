From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] fix non-mergeable buffers packet too large error handling
Date: Tue, 11 May 2010 08:52:47 -0700
Message-ID: <1273593167.30010.8.camel@w-dls.beaverton.ibm.com>
Reply-To: dlstevens@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:59719 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755444Ab0EKPwv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 11:52:51 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4BFe6eq023528
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 11:40:06 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4BFqnjH174228
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 11:52:49 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4BFqnPJ028287
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 12:52:49 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enforces single-buffer allocation when
mergeable rx buffers is not enabled.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 309c570..c346304 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -361,13 +361,21 @@ static void handle_rx(struct vhost_net *net)
 			break;
 		}
 		/* TODO: Should check and handle checksum. */
-		if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF) &&
-		    memcpy_toiovecend(vq->hdr, (unsigned char *)&headcount,
-				      offsetof(typeof(hdr), num_buffers),
-				      sizeof hdr.num_buffers)) {
-			vq_err(vq, "Failed num_buffers write");
+		if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) {
+			if (memcpy_toiovecend(vq->hdr,
+					      (unsigned char *)&headcount,
+					      offsetof(typeof(hdr),
+					      num_buffers),
+					      sizeof hdr.num_buffers)) {
+				vq_err(vq, "Failed num_buffers write");
+				vhost_discard_desc(vq, headcount);
+				break;
+			}
+		} else if (headcount > 1) {
+			vq_err(vq, "rx packet too large (%d) for guest",
+			       sock_len);
 			vhost_discard_desc(vq, headcount);
-			break;
+			continue;
 		}
 		vhost_add_used_and_signal_n(&net->dev, vq, vq->heads,
 					    headcount);


