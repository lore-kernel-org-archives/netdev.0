From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH v2 1/6] net: Add functions for handling padding frame and
 adding to length
Date: Wed, 03 Dec 2014 08:17:33 -0800
Message-ID: <20141203161733.9223.11891.stgit@ahduyck-vm-fedora20>
References: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709AbaLCQRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 11:17:35 -0500
In-Reply-To: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds two new helper functions skb_put_padto and eth_skb_pad.
These functions deviate from the standard skb_pad or skb_padto in that they
will also update the length and tail pointers so that they reflect the
padding added to the frame.

The eth_skb_pad helper is meant to be used with Ethernet devices to update
either Rx or Tx frames so that they report the correct size.  The
skb_put_padto helper is meant to be used primarily in the transmit path for
network devices that need frames to be padded up to some minimum size and
don't wish to simply update the length somewhere external to the frame.

The motivation behind this is that there are a number of implementations
throughout the network device drivers that are all doing the same thing,
but each a little bit differently and as a result several implementations
contain bugs such as updating the length without updating the tail offset
and other similar issues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/etherdevice.h |   12 ++++++++++++
 include/linux/skbuff.h      |   24 +++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 1 deletion(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 733980f..41c891d 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -392,4 +392,16 @@ static inline unsigned long compare_ether_header(const void *a, const void *b)
 #endif
 }
 
+/**
+ * eth_skb_pad - Pad buffer to mininum number of octets for Ethernet frame
+ * @skb: Buffer to pad
+ *
+ * An Ethernet frame should have a minimum size of 60 bytes.  This function
+ * takes short frames and pads them with zeros up to the 60 byte limit.
+ */
+static inline int eth_skb_pad(struct sk_buff *skb)
+{
+	return skb_put_padto(skb, ETH_ZLEN);
+}
+
 #endif	/* _LINUX_ETHERDEVICE_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7691ad5..d1e25750 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2461,7 +2461,6 @@ static inline int skb_cow_head(struct sk_buff *skb, unsigned int headroom)
  *	is untouched. Otherwise it is extended. Returns zero on
  *	success. The skb is freed on error.
  */
- 
 static inline int skb_padto(struct sk_buff *skb, unsigned int len)
 {
 	unsigned int size = skb->len;
@@ -2470,6 +2469,29 @@ static inline int skb_padto(struct sk_buff *skb, unsigned int len)
 	return skb_pad(skb, len - size);
 }
 
+/**
+ *	skb_put_padto - increase size and pad an skbuff up to a minimal size
+ *	@skb: buffer to pad
+ *	@len: minimal length
+ *
+ *	Pads up a buffer to ensure the trailing bytes exist and are
+ *	blanked. If the buffer already contains sufficient data it
+ *	is untouched. Otherwise it is extended. Returns zero on
+ *	success. The skb is freed on error.
+ */
+static inline int skb_put_padto(struct sk_buff *skb, unsigned int len)
+{
+	unsigned int size = skb->len;
+
+	if (unlikely(size < len)) {
+		len -= size;
+		if (skb_pad(skb, len))
+			return -ENOMEM;
+		__skb_put(skb, len);
+	}
+	return 0;
+}
+
 static inline int skb_add_data(struct sk_buff *skb,
 			       char __user *from, int copy)
 {
