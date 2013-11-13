From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net V2 1/2] tuntap: limit head length of skb allocated
Date: Wed, 13 Nov 2013 14:00:39 +0800
Message-ID: <1384322440-29038-1-git-send-email-jasowang@redhat.com>
Cc: gregory.v.rose@intel.com, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717Ab3KMGBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 01:01:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently use hdr_len as a hint of head length which is advertised by
guest. But when guest advertise a very big value, it can lead to an 64K+
allocating of kmalloc() which has a very high possibility of failure when host
memory is fragmented or under heavy stress. The huge hdr_len also reduce the
effect of zerocopy or even disable if a gso skb is linearized in guest.

To solves those issues, this patch introduces an upper limit (PAGE_SIZE) of the
head, which guarantees an order 0 allocation each time.

Cc: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
The patch was needed for stable.
Changes from V1:
- check the linear size in tun_get_user() to avoid iov_pages() under estimation
---
 drivers/net/tun.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 7cb105c..782e38b 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -981,6 +981,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	struct sk_buff *skb;
 	size_t len = total_len, align = NET_SKB_PAD, linear;
 	struct virtio_net_hdr gso = { 0 };
+	int good_linear;
 	int offset = 0;
 	int copylen;
 	bool zerocopy = false;
@@ -1021,12 +1022,16 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 			return -EINVAL;
 	}
 
+	good_linear = SKB_MAX_HEAD(align);
+
 	if (msg_control) {
 		/* There are 256 bytes to be copied in skb, so there is
 		 * enough room for skb expand head in case it is used.
 		 * The rest of the buffer is mapped from userspace.
 		 */
 		copylen = gso.hdr_len ? gso.hdr_len : GOODCOPY_LEN;
+		if (copylen > good_linear)
+			copylen = good_linear;
 		linear = copylen;
 		if (iov_pages(iv, offset + copylen, count) <= MAX_SKB_FRAGS)
 			zerocopy = true;
@@ -1034,7 +1039,10 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 
 	if (!zerocopy) {
 		copylen = len;
-		linear = gso.hdr_len;
+		if (gso.hdr_len > good_linear)
+			linear = good_linear;
+		else
+			linear = gso.hdr_len;
 	}
 
 	skb = tun_alloc_skb(tfile, align, copylen, linear, noblock);
-- 
1.8.3.2
