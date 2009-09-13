From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH resend] sky2: Account for VLAN tag in tx_le_req
Date: Mon, 14 Sep 2009 08:07:41 +0900
Message-ID: <4AAD7B3D.7010403@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:36809 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbZIMXML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Sep 2009 19:12:11 -0400
Received: by pxi27 with SMTP id 27so1955979pxi.15
        for <netdev@vger.kernel.org>; Sun, 13 Sep 2009 16:12:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With VLAN enabled, tx_le_req could return fewer list elements than required,
 leading to a potential wrap around of the transmit ring buffer.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 00bc65a..c8ebc03 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1563,7 +1563,7 @@ static inline int tx_avail(const struct sky2_port *sky2)
 }
 
 /* Estimate of number of transmit list elements required */
-static unsigned tx_le_req(const struct sk_buff *skb)
+static unsigned tx_le_req(const struct sk_buff *skb, int vlan_tag)
 {
 	unsigned count;
 
@@ -1573,6 +1573,9 @@ static unsigned tx_le_req(const struct sk_buff *skb)
 	if (skb_is_gso(skb))
 		++count;
 
+	else if (sizeof(dma_addr_t) == sizeof(u32) && vlan_tag)
+		++count;
+
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		++count;
 
@@ -1611,8 +1614,13 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 	u16 slot;
 	u16 mss;
 	u8 ctrl;
+	unsigned vlan_tag = 0;
+
+#ifdef SKY2_VLAN_TAG_USED
+	vlan_tag = sky2->vlgrp && vlan_tx_tag_present(skb);
+#endif
 
- 	if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
+ 	if (unlikely(tx_avail(sky2) < tx_le_req(skb, vlan_tag)))
   		return NETDEV_TX_BUSY;
 
 	len = skb_headlen(skb);
@@ -1657,7 +1665,7 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 	ctrl = 0;
 #ifdef SKY2_VLAN_TAG_USED
 	/* Add VLAN tag, can piggyback on LRGLEN or ADDR64 */
-	if (sky2->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tag) {
 		if (!le) {
 			le = get_tx_le(sky2, &slot);
 			le->addr = 0;
-- 
1.5.6.5


