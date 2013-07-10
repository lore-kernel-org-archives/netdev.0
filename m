From: Annie Li <annie.li@oracle.com>
Subject: [PATCH v2 1/1] xen/netback: correctly calculate required slots of skb.
Date: Wed, 10 Jul 2013 17:15:11 +0800
Message-ID: <1373447711-31303-1-git-send-email-annie.li@oracle.com>
Cc: konrad.wilk@oracle.com, annie.li@oracle.com, msw@amazon.com
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	Ian.Campbell@citrix.com, wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44213 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179Ab3GJJUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 05:20:24 -0400
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
 drivers/net/xen-netback/netback.c |   98 ++++++++++++++++++++++++-------------
 1 files changed, 63 insertions(+), 35 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 8c20935..d2a9478 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -354,56 +354,84 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
 	return false;
 }
 
-/*
- * Figure out how many ring slots we're going to need to send @skb to
- * the guest. This function is essentially a dry run of
- * netbk_gop_frag_copy.
- */
-unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
+static int netbk_count_slots(struct xenvif *vif, struct sk_buff *skb,
+			    int *copy_off, unsigned long size,
+			    unsigned long offset, int *head)
 {
-	unsigned int count;
-	int i, copy_off;
+	unsigned long bytes;
+	int count = 0;
 
-	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
+	offset &= ~PAGE_MASK;
 
-	copy_off = skb_headlen(skb) % PAGE_SIZE;
+	while (size > 0) {
+		BUG_ON(offset >= PAGE_SIZE);
+		BUG_ON(*copy_off > MAX_BUFFER_OFFSET);
 
-	if (skb_shinfo(skb)->gso_size)
-		count++;
+		bytes = PAGE_SIZE - offset;
 
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
-		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
-		unsigned long bytes;
+		if (bytes > size)
+			bytes = size;
 
-		offset &= ~PAGE_MASK;
+		if (start_new_rx_buffer(*copy_off, bytes, *head)) {
+			count++;
+			*copy_off = 0;
+		}
 
-		while (size > 0) {
-			BUG_ON(offset >= PAGE_SIZE);
-			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
+		if (*copy_off + bytes > MAX_BUFFER_OFFSET)
+			bytes = MAX_BUFFER_OFFSET - *copy_off;
 
-			bytes = PAGE_SIZE - offset;
+		*copy_off += bytes;
 
-			if (bytes > size)
-				bytes = size;
+		offset += bytes;
+		size -= bytes;
 
-			if (start_new_rx_buffer(copy_off, bytes, 0)) {
-				count++;
-				copy_off = 0;
-			}
+		/* Next frame */
+		if (offset == PAGE_SIZE && size)
+			offset = 0;
+
+		if (*head)
+			count++;
+		*head = 0; /* There must be something in this buffer now. */
+	}
+
+	return count;
+}
 
-			if (copy_off + bytes > MAX_BUFFER_OFFSET)
-				bytes = MAX_BUFFER_OFFSET - copy_off;
+/*
+ * Figure out how many ring slots we're going to need to send @skb to
+ * the guest. This function is essentially a dry run of
+ * netbk_gop_frag_copy.
+ */
+unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
+{
+	int i, copy_off = 0;
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	unsigned char *data;
+	int head = 1;
+	unsigned int count = 0;
 
-			copy_off += bytes;
+	if (skb_shinfo(skb)->gso_size && !vif->gso_prefix)
+		count++;
 
-			offset += bytes;
-			size -= bytes;
+	data = skb->data;
+	while (data < skb_tail_pointer(skb)) {
+		unsigned int offset = offset_in_page(data);
+		unsigned int len = PAGE_SIZE - offset;
 
-			if (offset == PAGE_SIZE)
-				offset = 0;
-		}
+		if (data + len > skb_tail_pointer(skb))
+			len = skb_tail_pointer(skb) - data;
+
+		count += netbk_count_slots(vif, skb, &copy_off, len,
+					   offset, &head);
+		data += len;
+	}
+
+	for (i = 0; i < nr_frags; i++) {
+		count += netbk_count_slots(vif, skb, &copy_off,
+				skb_frag_size(&skb_shinfo(skb)->frags[i]),
+				skb_shinfo(skb)->frags[i].page_offset, &head);
 	}
+
 	return count;
 }
 
-- 
1.7.3.4
