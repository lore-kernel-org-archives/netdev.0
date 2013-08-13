From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH 6/6] 6lowpan: handle context based source address
Date: Tue, 13 Aug 2013 23:53:33 +0200
Message-ID: <1376430813-30982-8-git-send-email-alex.aring@gmail.com>
References: <1376430813-30982-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:62881 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758641Ab3HMVtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:49:55 -0400
Received: by mail-ee0-f48.google.com with SMTP id l10so4412459eei.21
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 14:49:54 -0700 (PDT)
In-Reply-To: <1376430813-30982-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle context based address when a unspecific address is specified.
For other context based address we print a warning and drop the packet
currently because we don't support it right now.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/6lowpan.c | 48 +++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 45 insertions(+), 3 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index d299560..90eddce 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -243,6 +243,39 @@ lowpan_uncompress_addr(struct sk_buff *skb,
 	return 0;
 }
 
+/* Uncompress address function for source context
+ * based address(non-multicast).
+ */
+static int
+lowpan_uncompress_context_based_src_addr(struct sk_buff *skb,
+		struct in6_addr *ipaddr,
+		const u8 sam)
+{
+	switch (sam) {
+	case LOWPAN_IPHC_ADDR_00:
+		/* unspec address ::
+		 * Do nothing, address is already ::
+		 */
+		break;
+	case LOWPAN_IPHC_ADDR_01:
+		/* TODO */
+	case LOWPAN_IPHC_ADDR_02:
+		/* TODO */
+	case LOWPAN_IPHC_ADDR_03:
+		/* TODO */
+		netdev_warn(skb->dev, "SAM value 0x%x not supported\n", sam);
+		return -EINVAL;
+	default:
+		pr_debug("Invalid sam value: 0x%x\n", sam);
+		return -EINVAL;
+	}
+
+	pr_debug("Reconstructed context based ipv6 src addr is:\n");
+	lowpan_raw_dump_inline(NULL, NULL, ipaddr->s6_addr, 16);
+
+	return 0;
+}
+
 /* Uncompress function for multicast destination address,
  * when M bit is set.
  */
@@ -971,9 +1004,18 @@ lowpan_process_data(struct sk_buff *skb)
 	/* Extract SAM to the tmp variable */
 	tmp = ((iphc1 & LOWPAN_IPHC_SAM) >> LOWPAN_IPHC_SAM_BIT) & 0x03;
 
-	/* Source address uncompression */
-	pr_debug("source address stateless compression\n");
-	err = lowpan_uncompress_addr(skb, &hdr.saddr, tmp, _saddr);
+	if (iphc1 & LOWPAN_IPHC_SAC) {
+		/* Source address context based uncompression */
+		pr_debug("SAC bit is set. Handle context based source address.\n");
+		err = lowpan_uncompress_context_based_src_addr(
+				skb, &hdr.saddr, tmp);
+	} else {
+		/* Source address uncompression */
+		pr_debug("source address stateless compression\n");
+		err = lowpan_uncompress_addr(skb, &hdr.saddr, tmp, _saddr);
+	}
+
+	/* Check on error of previous branch */
 	if (err)
 		goto drop;
 
-- 
1.8.3.3
