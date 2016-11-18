From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next v2 1/5] virtio_net: Simplify call sites for virtio_net_hdr_{from,to}_skb().
Date: Fri, 18 Nov 2016 15:40:38 -0800
Message-ID: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:38965 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752496AbcKRXk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 18:40:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No point storing the return value of virtio_net_hdr_to_skb() or
virtio_net_hdr_from_skb() to a variable when the value is used only
once as a boolean in an immediately following if statement.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 drivers/net/macvtap.c | 5 ++---
 drivers/net/tun.c     | 8 +++-----
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 070e329..5da9861 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -821,9 +821,8 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		if (iov_iter_count(iter) < vnet_hdr_len)
 			return -EINVAL;
 
-		ret = virtio_net_hdr_from_skb(skb, &vnet_hdr,
-					      macvtap_is_little_endian(q));
-		if (ret)
+		if (virtio_net_hdr_from_skb(skb, &vnet_hdr,
+					    macvtap_is_little_endian(q)))
 			BUG();
 
 		if (copy_to_iter(&vnet_hdr, sizeof(vnet_hdr), iter) !=
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 1588469..3b8d8cc 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1252,8 +1252,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		return -EFAULT;
 	}
 
-	err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
-	if (err) {
+	if (virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun))) {
 		this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
 		kfree_skb(skb);
 		return -EINVAL;
@@ -1367,9 +1366,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		if (iov_iter_count(iter) < vnet_hdr_sz)
 			return -EINVAL;
 
-		ret = virtio_net_hdr_from_skb(skb, &gso,
-					      tun_is_little_endian(tun));
-		if (ret) {
+		if (virtio_net_hdr_from_skb(skb, &gso,
+					    tun_is_little_endian(tun))) {
 			struct skb_shared_info *sinfo = skb_shinfo(skb);
 			pr_err("unexpected GSO type: "
 			       "0x%x, gso_size %d, hdr_len %d\n",
-- 
2.1.4
