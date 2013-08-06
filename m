From: Jason Wang <jasowang@redhat.com>
Subject: [net-next 6/6] net: use skb_copy_datagram_from_iovec() in zerocopy_sg_from_iovec()
Date: Tue,  6 Aug 2013 17:45:08 +0800
Message-ID: <1375782308-10565-7-git-send-email-jasowang@redhat.com>
References: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4730 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755901Ab3HFJ4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 05:56:37 -0400
In-Reply-To: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb_copy_datagram_from_iovec() to avoid code duplication and make it easy to
be read. Also we can do the skipping inside the zero-copy loop.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net/core/datagram.c |   37 ++++++++++---------------------------
 1 files changed, 10 insertions(+), 27 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index badcd93..af814e7 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -591,48 +591,31 @@ int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 				  int offset, size_t count)
 {
 	int len = iov_length(from, count) - offset;
-	int copy = skb_headlen(skb);
-	int size, offset1 = 0;
+	int copy = min_t(int, skb_headlen(skb), len);
+	int size;
 	int i = 0;
 
-	/* Skip over from offset */
-	while (count && (offset >= from->iov_len)) {
-		offset -= from->iov_len;
-		++from;
-		--count;
-	}
-
 	/* copy up to skb headlen */
-	while (count && (copy > 0)) {
-		size = min_t(unsigned int, copy, from->iov_len - offset);
-		if (copy_from_user(skb->data + offset1, from->iov_base + offset,
-				   size))
-			return -EFAULT;
-		if (copy > size) {
-			++from;
-			--count;
-			offset = 0;
-		} else
-			offset += size;
-		copy -= size;
-		offset1 += size;
-	}
+	if (skb_copy_datagram_from_iovec(skb, 0, from, offset, copy))
+		return -EFAULT;
 
-	if (len == offset1)
+	if (len == copy)
 		return 0;
 
+	offset += copy;
 	while (count--) {
 		struct page *page[MAX_SKB_FRAGS];
 		int num_pages;
 		unsigned long base;
 		unsigned long truesize;
 
-		len = from->iov_len - offset;
-		if (!len) {
-			offset = 0;
+		/* Skip over from offset and copied */
+		if (offset >= from->iov_len) {
+			offset -= from->iov_len;
 			++from;
 			continue;
 		}
+		len = from->iov_len - offset;
 		base = (unsigned long)from->iov_base + offset;
 		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
 		if (i + size > MAX_SKB_FRAGS)
-- 
1.7.1
