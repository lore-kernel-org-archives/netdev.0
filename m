From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/3] skb_partial_csum_set
Date: Tue, 15 Jan 2008 21:41:55 +1100
Message-ID: <200801152141.56172.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54865 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751451AbYAOKmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 05:42:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement skb_partial_csum_set, for setting partial csums on untrusted packets.

Use it in virtio_net (replacing buggy version there), it's also going
to be used by TAP for partial csum support.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   11 +----------
 include/linux/skbuff.h   |    1 +
 net/core/skbuff.c        |   29 +++++++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 10 deletions(-)

diff -r 72be3d596d31 include/linux/skbuff.h
--- a/include/linux/skbuff.h	Wed Jan 09 15:57:40 2008 +1100
+++ b/include/linux/skbuff.h	Wed Jan 09 16:56:41 2008 +1100
@@ -1804,5 +1804,6 @@ static inline void skb_forward_csum(stru
 		skb->ip_summed = CHECKSUM_NONE;
 }
 
+bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff -r 72be3d596d31 net/core/skbuff.c
--- a/net/core/skbuff.c	Wed Jan 09 15:57:40 2008 +1100
+++ b/net/core/skbuff.c	Wed Jan 09 16:56:41 2008 +1100
@@ -2214,6 +2214,34 @@ int skb_cow_data(struct sk_buff *skb, in
 	return elt;
 }
 
+/**
+ * skb_partial_csum_set - set up and verify partial csum values for packet
+ * @skb: the skb to set
+ * @start: the number of bytes after skb->data to start checksumming.
+ * @off: the offset from start to place the checksum.
+ *
+ * For untrusted partially-checksummed packets, we need to make sure the values
+ * for skb->csum_start and skb->csum_offset are valid so we don't oops.
+ *
+ * This function checks and sets those values and skb->ip_summed: if this
+ * returns false you should drop the packet.
+ */
+bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off)
+{
+	if (unlikely(start > skb->len - 2) || 
+	    unlikely((int)start + off > skb->len - 2)) {
+		if (net_ratelimit())
+			printk(KERN_WARNING
+			       "bad partial csum: csum=%u/%u len=%u\n",
+			       start, off, skb->len);
+		return false;
+	}
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	skb->csum_start = skb_headroom(skb) + start;
+	skb->csum_offset = off;
+	return true;
+}
+
 EXPORT_SYMBOL(___pskb_trim);
 EXPORT_SYMBOL(__kfree_skb);
 EXPORT_SYMBOL(kfree_skb);
@@ -2250,3 +2278,4 @@ EXPORT_SYMBOL(skb_append_datato_frags);
 
 EXPORT_SYMBOL_GPL(skb_to_sgvec);
 EXPORT_SYMBOL_GPL(skb_cow_data);
+EXPORT_SYMBOL_GPL(skb_partial_csum_set);
diff -r 72be3d596d31 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Wed Jan 09 15:57:40 2008 +1100
+++ b/drivers/net/virtio_net.c	Wed Jan 09 16:56:41 2008 +1100
@@ -89,17 +89,8 @@ static void receive_skb(struct net_devic
 
 	if (hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
 		pr_debug("Needs csum!\n");
-		skb->ip_summed = CHECKSUM_PARTIAL;
-		skb->csum_start = hdr->csum_start;
-		skb->csum_offset = hdr->csum_offset;
-		if (skb->csum_start > skb->len - 2
-		    || skb->csum_offset > skb->len - 2) {
-			if (net_ratelimit())
-				printk(KERN_WARNING "%s: csum=%u/%u len=%u\n",
-				       dev->name, skb->csum_start,
-				       skb->csum_offset, skb->len);
+		if (!skb_partial_csum_set(skb,hdr->csum_start,hdr->csum_offset))
 			goto frame_err;
-		}
 	}
 
 	if (hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
