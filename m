From: Jason Wang <jasowang@redhat.com>
Subject: [V2 PATCH 5/9] macvtap: zerocopy: validate vectors before building
 skb
Date: Wed, 02 May 2012 11:42:15 +0800
Message-ID: <20120502034215.11782.9051.stgit@amd-6168-8-1.englab.nay.redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22403 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758669Ab2EBDrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 23:47:31 -0400
In-Reply-To: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There're several reasons that the vectors need to be validated:

- Return error when caller provides vectors whose num is greater than UIO_MAXIOV.
- Linearize part of skb when userspace provides vectors grater than MAX_SKB_FRAGS.
- Return error when userspace provides vectors whose total length may exceed
- MAX_SKB_FRAGS * PAGE_SIZE.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |   25 +++++++++++++++++++++----
 1 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a4ff694..163559c 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -529,9 +529,10 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		}
 		base = (unsigned long)from->iov_base + offset;
 		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
+		if (i + size > MAX_SKB_FRAGS)
+			return -EMSGSIZE;
 		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
-		if ((num_pages != size) ||
-		    (num_pages > MAX_SKB_FRAGS - skb_shinfo(skb)->nr_frags)) {
+		if (num_pages != size) {
 			for (i = 0; i < num_pages; i++)
 				put_page(page[i]);
 			return -EFAULT;
@@ -651,7 +652,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	int err;
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int vnet_hdr_len = 0;
-	int copylen;
+	int copylen = 0;
 	bool zerocopy = false;
 
 	if (q->flags & IFF_VNET_HDR) {
@@ -680,15 +681,31 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	if (unlikely(len < ETH_HLEN))
 		goto err;
 
+	err = -EMSGSIZE;
+	if (unlikely(count > UIO_MAXIOV))
+		goto err;
+
 	if (m && m->msg_control && sock_flag(&q->sk, SOCK_ZEROCOPY))
 		zerocopy = true;
 
 	if (zerocopy) {
+		/* Userspace may produce vectors with count greater than
+		 * MAX_SKB_FRAGS, so we need to linearize parts of the skb
+		 * to let the rest of data to be fit in the frags.
+		 */
+		if (count > MAX_SKB_FRAGS) {
+			copylen = iov_length(iv, count - MAX_SKB_FRAGS);
+			if (copylen < vnet_hdr_len)
+				copylen = 0;
+			else
+				copylen -= vnet_hdr_len;
+		}
 		/* There are 256 bytes to be copied in skb, so there is enough
 		 * room for skb expand head in case it is used.
 		 * The rest buffer is mapped from userspace.
 		 */
-		copylen = vnet_hdr.hdr_len;
+		if (copylen < vnet_hdr.hdr_len)
+			copylen = vnet_hdr.hdr_len;
 		if (!copylen)
 			copylen = GOODCOPY_LEN;
 	} else
