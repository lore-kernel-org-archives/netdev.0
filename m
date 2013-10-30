From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 4/4] 6lowpan: cleanup skb copy data
Date: Wed, 30 Oct 2013 09:18:24 +0100
Message-ID: <1383121104-2515-5-git-send-email-alex.aring@gmail.com>
References: <1383121104-2515-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:58050 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401Ab3J3ISj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 04:18:39 -0400
Received: by mail-ee0-f53.google.com with SMTP id e51so435643eek.40
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 01:18:38 -0700 (PDT)
In-Reply-To: <1383121104-2515-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch drops the direct memcpy on skb and uses the right skb
memcpy functions. Also remove an unnecessary check if plen is non zero.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Reviewed-by: Werner Almesberger <werner@almesberger.net>
---
 net/ieee802154/6lowpan.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 58c07fd..9497c6f 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1122,12 +1122,15 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
 	frag->priority = skb->priority;
 
 	/* copy header, MFR and payload */
-	memcpy(skb_put(frag, mlen), skb->data, mlen);
-	memcpy(skb_put(frag, hlen), head, hlen);
+	skb_put(frag, mlen);
+	skb_copy_to_linear_data(frag, skb_mac_header(skb), mlen);
 
-	if (plen)
-		skb_copy_from_linear_data_offset(skb, offset + mlen,
-					skb_put(frag, plen), plen);
+	skb_put(frag, hlen);
+	skb_copy_to_linear_data_offset(frag, mlen, head, hlen);
+
+	skb_put(frag, plen);
+	skb_copy_to_linear_data_offset(frag, mlen + hlen,
+				       skb_network_header(skb) + offset, plen);
 
 	lowpan_raw_dump_table(__func__, " raw fragment dump", frag->data,
 								frag->len);
-- 
1.8.4.2
