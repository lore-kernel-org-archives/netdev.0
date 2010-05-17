From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] [resend] fix non-mergeable buffers packet too large error
 handling
Date: Mon, 17 May 2010 14:16:36 -0700
Message-ID: <1274130996.8492.7.camel@w-dls.beaverton.ibm.com>
Reply-To: dlstevens@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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


