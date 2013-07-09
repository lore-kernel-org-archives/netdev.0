From: Annie Li <annie.li@oracle.com>
Subject: [PATCH 1/1] xen/netback: correctly calculate required slots of skb.
Date: Tue,  9 Jul 2013 14:15:20 +0800
Message-ID: <1373350520-19985-1-git-send-email-annie.li@oracle.com>
Cc: konrad.wilk@oracle.com, wei.liu2@citrix.com, annie.li@oracle.com
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33361 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272Ab3GIGUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 02:20:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When counting required slots for skb, netback directly uses DIV_ROUND_UP to get
slots required by header data. This is wrong when offset in the page of header
data is not zero, and is also inconsistent with following calculation for
required slot in netbk_gop_skb.

In netbk_gop_skb, required slots are calculated based on offset and len in page
of header data. It is possible that required slots here is larger than the one
calculated in earlier netbk_count_requests. This inconsistency directly results
in rx_req_cons_peek and xen_netbk_rx_ring_full judgement are wrong.

Then it comes to situation the ring is actually full, but netback thinks it is
not and continues to create responses. This results in response overlaps request
in the ring, then grantcopy gets wrong grant reference and throws out error,
for example "(XEN) grant_table.c:1763:d0 Bad grant reference 2949120", the
grant reference is invalid value here. Netback returns XEN_NETIF_RSP_ERROR(-1)
to netfront when grant copy status is error, then netfront gets rx->status
(the status is -1, not really data size now), and throws out error,
"kernel: net eth1: rx->offset: 0, size: 4294967295". This issue can be reproduced
by doing gzip/gunzip in nfs share with mtu = 9000, the guest would panic after
running such test for a while.

This patch is based on 3.10-rc7.

Signed-off-by: Annie Li <annie.li@oracle.com>
---
 drivers/net/xen-netback/netback.c |   97 +++++++++++++++++++++++++-----------
 1 files changed, 67 insertions(+), 30 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 8c20935..7ff9333 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -359,51 +359,88 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
  * the guest. This function is essentially a dry run of
  * netbk_gop_frag_copy.
  */
-unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
+static void netbk_get_slots(struct xenvif *vif, struct sk_buff *skb,
+			    struct page *page, int *copy_off,
+			    unsigned long size, unsigned long offset,
+			    int *head, int *count)
 {
-	unsigned int count;
-	int i, copy_off;
+	unsigned long bytes;
 
-	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
+	/* Data must not cross a page boundary. */
+	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
 
-	copy_off = skb_headlen(skb) % PAGE_SIZE;
+	/* Skip unused frames from start of page */
+	page += offset >> PAGE_SHIFT;
+	offset &= ~PAGE_MASK;
 
-	if (skb_shinfo(skb)->gso_size)
-		count++;
+	while (size > 0) {
+		BUG_ON(offset >= PAGE_SIZE);
+		BUG_ON(*copy_off > MAX_BUFFER_OFFSET);
 
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
-		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
-		unsigned long bytes;
+		bytes = PAGE_SIZE - offset;
 
-		offset &= ~PAGE_MASK;
+		if (bytes > size)
+			bytes = size;
 
-		while (size > 0) {
-			BUG_ON(offset >= PAGE_SIZE);
-			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
+		if (start_new_rx_buffer(*copy_off, bytes, *head)) {
+			*count = *count + 1;
+			*copy_off = 0;
+		}
 
-			bytes = PAGE_SIZE - offset;
+		if (*copy_off + bytes > MAX_BUFFER_OFFSET)
+			bytes = MAX_BUFFER_OFFSET - *copy_off;
 
-			if (bytes > size)
-				bytes = size;
+		*copy_off += bytes;
 
-			if (start_new_rx_buffer(copy_off, bytes, 0)) {
-				count++;
-				copy_off = 0;
-			}
+		offset += bytes;
+		size -= bytes;
 
-			if (copy_off + bytes > MAX_BUFFER_OFFSET)
-				bytes = MAX_BUFFER_OFFSET - copy_off;
+		/* Next frame */
+		if (offset == PAGE_SIZE && size) {
+			BUG_ON(!PageCompound(page));
+			page++;
+			offset = 0;
+		}
 
-			copy_off += bytes;
+		if (*head)
+			*count = *count + 1;
+		*head = 0; /* There must be something in this buffer now. */
+	}
+}
+
+unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
+{
+	int i, copy_off = 0;
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	unsigned char *data;
+	int head = 1;
+	unsigned int count = 0;
 
-			offset += bytes;
-			size -= bytes;
+	if (skb_shinfo(skb)->gso_size)
+		count++;
 
-			if (offset == PAGE_SIZE)
-				offset = 0;
-		}
+	data = skb->data;
+	while (data < skb_tail_pointer(skb)) {
+		unsigned int offset = offset_in_page(data);
+		unsigned int len = PAGE_SIZE - offset;
+
+		if (data + len > skb_tail_pointer(skb))
+			len = skb_tail_pointer(skb) - data;
+
+		netbk_get_slots(vif, skb, virt_to_page(data), &copy_off,
+				len, offset, &head, &count);
+		data += len;
+	}
+
+	for (i = 0; i < nr_frags; i++) {
+		netbk_get_slots(vif, skb,
+				skb_frag_page(&skb_shinfo(skb)->frags[i]),
+				&copy_off,
+				skb_frag_size(&skb_shinfo(skb)->frags[i]),
+				skb_shinfo(skb)->frags[i].page_offset,
+				&head, &count);
 	}
+
 	return count;
 }
 
-- 
1.7.3.4
