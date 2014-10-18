From: roy.qing.li@gmail.com
Subject: [PATCH] ipv4: fix a potential use after free in gre_offload.c
Date: Sat, 18 Oct 2014 17:26:04 +0800
Message-ID: <1413624364-12944-1-git-send-email-roy.qing.li@gmail.com>
Cc: weichunc@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:56010 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaJRJ0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 05:26:11 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so2226035pad.17
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 02:26:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull() may change skb->data and make greh pointer oboslete;
so need to reassign greh;
but since first calling pskb_may_pull already ensured that skb->data
has enough space for greh, so move the reference of greh before second
calling pskb_may_pull(), to avoid reassign greh.

Fixes: 7a7ffbabf9("ipv4: fix tunneled VM traffic over hw VXLAN/GRE GSO NIC")
Cc: Wei-Chun Chao <weichunc@plumgrid.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/gre_offload.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index a777295..ccda096 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -55,13 +55,13 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	if (csum)
 		skb->encap_hdr_csum = 1;
 
-	if (unlikely(!pskb_may_pull(skb, ghl)))
-		goto out;
-
 	/* setup inner skb. */
 	skb->protocol = greh->protocol;
 	skb->encapsulation = 0;
 
+	if (unlikely(!pskb_may_pull(skb, ghl)))
+		goto out;
+
 	__skb_pull(skb, ghl);
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
-- 
1.7.10.4
