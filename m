From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 4/5] net: add skb_pop_rcv_encapsulation
Date: Sat, 14 Jun 2014 23:24:28 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406142315470.17603@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:50673 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092AbaFOGYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 02:24:30 -0400
Received: by mail-ve0-f201.google.com with SMTP id jz11so641509veb.2
        for <netdev@vger.kernel.org>; Sat, 14 Jun 2014 23:24:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is used by UDP encapsulation protocols in RX when
crossing encapsulation boundary. If ip_summed is set to
CHECKSUM_UNNECESSARY and encapsulation is not set, change to
CHECKSUM_NONE since the checksum has not been validated within the
encapsulation. Clears csum_valid by the same rationale.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e13ed90..ec89301 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1854,6 +1854,18 @@ static inline int pskb_network_may_pull(struct sk_buff *skb, unsigned int len)
 	return pskb_may_pull(skb, skb_network_offset(skb) + len);
 }
 
+static inline void skb_pop_rcv_encapsulation(struct sk_buff *skb)
+{
+	/* Only continue with checksum unnecessary if device indicated
+	 * it is valid across encapsulation (skb->encapsulation was set).
+	 */
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY && !skb->encapsulation)
+		skb->ip_summed = CHECKSUM_NONE;
+
+	skb->encapsulation = 0;
+	skb->csum_valid = 0;
+}
+
 /*
  * CPUs often take a performance hit when accessing unaligned memory
  * locations. The actual performance hit varies, it can be small if the
-- 
2.0.0.526.g5318336
