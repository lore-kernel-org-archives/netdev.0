From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net V2 2/2] macvtap: limit head length of skb allocated
Date: Wed, 13 Nov 2013 14:00:40 +0800
Message-ID: <1384322440-29038-2-git-send-email-jasowang@redhat.com>
References: <1384322440-29038-1-git-send-email-jasowang@redhat.com>
Cc: gregory.v.rose@intel.com, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7708 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357Ab3KMGA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 01:00:59 -0500
In-Reply-To: <1384322440-29038-1-git-send-email-jasowang@redhat.com>
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
- Check the linear size in macvtap_get_user() to avoid iov_pages() under
  estimation.
---
 drivers/net/macvtap.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 9dccb1e..dc76670 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -628,6 +628,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 				const struct iovec *iv, unsigned long total_len,
 				size_t count, int noblock)
 {
+	int good_linear = SKB_MAX_HEAD(NET_IP_ALIGN);
 	struct sk_buff *skb;
 	struct macvlan_dev *vlan;
 	unsigned long len = total_len;
@@ -670,6 +671,8 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 
 	if (m && m->msg_control && sock_flag(&q->sk, SOCK_ZEROCOPY)) {
 		copylen = vnet_hdr.hdr_len ? vnet_hdr.hdr_len : GOODCOPY_LEN;
+		if (copylen > good_linear)
+			copylen = good_linear;
 		linear = copylen;
 		if (iov_pages(iv, vnet_hdr_len + copylen, count)
 		    <= MAX_SKB_FRAGS)
@@ -678,7 +681,10 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 
 	if (!zerocopy) {
 		copylen = len;
-		linear = vnet_hdr.hdr_len;
+		if (vnet_hdr.hdr_len > good_linear)
+			linear = good_linear;
+		else
+			linear = vnet_hdr.hdr_len;
 	}
 
 	skb = macvtap_alloc_skb(&q->sk, NET_IP_ALIGN, copylen,
-- 
1.8.3.2
