From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] net: Fix GRO for multiple page fragments
Date: Thu, 16 Apr 2009 19:04:20 +0100
Message-ID: <1239905060.3203.28.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:34413 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755559AbZDPSE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 14:04:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This loop over fragments in napi_fraginfo_skb() was "interesting".

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This is not tested, as only cxgb3 will currently pass in multiple
fragments at the same time.  skb_shinfo(skb)->nr_frags would already be
0 but it makes no sense to rely on that.  I hope I'm not missing some
subtlety...

Ben.

 net/core/dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ea8eb22..15ecc51 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2539,9 +2539,9 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 	}
 
 	BUG_ON(info->nr_frags > MAX_SKB_FRAGS);
-	frag = &info->frags[info->nr_frags - 1];
+	frag = info->frags;
 
-	for (i = skb_shinfo(skb)->nr_frags; i < info->nr_frags; i++) {
+	for (i = 0; i < info->nr_frags; i++) {
 		skb_fill_page_desc(skb, i, frag->page, frag->page_offset,
 				   frag->size);
 		frag++;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

