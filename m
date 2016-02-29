From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net v2] net: fix double free issue of skbuff
Date: Mon, 29 Feb 2016 14:31:31 +0000
Message-ID: <1456756291-23950-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:5356 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbcB2Oak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 09:30:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If skb_reorder_vlan_header() failed, skb is freed and NULL is returned.
Then at skb_vlan_untag(), it will free skbuff again which cause double free.

This patch removes kfree_skb() call in function skb_reorder_vlan_header().

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/core/skbuff.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 488566b..a5f2401 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4349,10 +4349,8 @@ EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
 
 static struct sk_buff *skb_reorder_vlan_header(struct sk_buff *skb)
 {
-	if (skb_cow(skb, skb_headroom(skb)) < 0) {
-		kfree_skb(skb);
+	if (skb_cow(skb, skb_headroom(skb)) < 0)
 		return NULL;
-	}
 
 	memmove(skb->data - ETH_HLEN, skb->data - skb->mac_len - VLAN_HLEN,
 		2 * ETH_ALEN);
-- 
1.8.3.1
