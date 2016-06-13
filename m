From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] tun: fix csum generation for tap devices
Date: Tue, 14 Jun 2016 00:00:04 +0200
Message-ID: <b4a4ba554658d07e8213e1e57cddef2f9485cc1b.1465854647.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422700AbcFMWBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 18:01:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 34166093639b ("tuntap: use common code for virtio_net_hdr
and skb GSO conversion") replaced the tun code for header manipulation
with the generic helpers. While doing so, it implictly moved the
skb_partial_csum_set() invocation after eth_type_trans(), which
invalidate the current gso start/offset values.
Fix it by moving the helper invocation before the mac pulling.

Fixes: 34166093639 ("tuntap: use common code for virtio_net_hdr and skb GSO conversion")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 drivers/net/tun.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8cc6bf4..4884802 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1254,6 +1254,13 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		return -EFAULT;
 	}
 
+	err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
+	if (err) {
+		this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case IFF_TUN:
 		if (tun->flags & IFF_NO_PI) {
@@ -1280,13 +1287,6 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		break;
 	}
 
-	err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
-	if (err) {
-		this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
-		kfree_skb(skb);
-		return -EINVAL;
-	}
-
 	/* copy skb_ubuf_info for callback when skb has no error */
 	if (zerocopy) {
 		skb_shinfo(skb)->destructor_arg = msg_control;
-- 
1.8.3.1
