From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 1/3] vhost-net: check the support of mergeable buffer outside
	the receive loop
Date: Mon, 17 Jan 2011 16:10:59 +0800
Message-ID: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61591 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526Ab1AQIMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jan 2011 03:12:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to check the support of mergeable buffer inside the recevie
loop as the whole handle_rx()_xx is in the read critical region.  So
this patch move it ahead of the receiving loop.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 14fc189..95e49de 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -411,7 +411,7 @@ static void handle_rx_mergeable(struct vhost_net *net)
 	};
 
 	size_t total_len = 0;
-	int err, headcount;
+	int err, headcount, mergeable;
 	size_t vhost_hlen, sock_hlen;
 	size_t vhost_len, sock_len;
 	struct socket *sock = rcu_dereference(vq->private_data);
@@ -425,6 +425,7 @@ static void handle_rx_mergeable(struct vhost_net *net)
 
 	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
 		vq->log : NULL;
+	mergeable = vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF);
 
 	while ((sock_len = peek_head_len(sock->sk))) {
 		sock_len += sock_hlen;
@@ -474,7 +475,7 @@ static void handle_rx_mergeable(struct vhost_net *net)
 			break;
 		}
 		/* TODO: Should check and handle checksum. */
-		if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF) &&
+		if (likely(mergeable) &&
 		    memcpy_toiovecend(vq->hdr, (unsigned char *)&headcount,
 				      offsetof(typeof(hdr), num_buffers),
 				      sizeof hdr.num_buffers)) {

