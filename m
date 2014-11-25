From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 1/5] etherdevice: Add function for handling padding
 frame to ETH_ZLEN
Date: Tue, 25 Nov 2014 14:44:00 -0800
Message-ID: <20141125224400.1867.48907.stgit@ahduyck-vm-fedora20>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbaKYWoC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 17:44:02 -0500
In-Reply-To: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a simple function for padding a frame up to the minimum
size for for Ethernet.  The motivation behind it is that there are a number
of implementations throughout the network device drivers that are all doing
the same thing, but each a little bit differently and as a result several
implementations contain bugs such as updating the length without updating
the tail offset and other similar issues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/etherdevice.h |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 733980f..7e436f3 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -392,4 +392,25 @@ static inline unsigned long compare_ether_header(const void *a, const void *b)
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
+	unsigned int size = skb->len;
+
+	if (unlikely(size < ETH_ZLEN)) {
+		size = ETH_ZLEN - size;
+		if (skb_pad(skb, size))
+			return -ENOMEM;
+		__skb_put(skb, size);
+	}
+
+	return 0;
+}
+
 #endif	/* _LINUX_ETHERDEVICE_H */
