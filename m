From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 3/4] net: ipv6: convert to SKB frag APIs
Date: Tue, 23 Aug 2011 10:45:00 +0100
Message-ID: <1314092701-4347-3-git-send-email-ian.campbell@citrix.com>
References: <1314092683.10283.21.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:7385 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754898Ab1HWJpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Aug 2011 05:45:12 -0400
In-Reply-To: <1314092683.10283.21.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
---
 net/ipv6/ip6_output.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4c882cf..835c04b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1480,13 +1480,13 @@ alloc_new_skb:
 			if (page && (left = PAGE_SIZE - off) > 0) {
 				if (copy >= left)
 					copy = left;
-				if (page != frag->page) {
+				if (page != skb_frag_page(frag)) {
 					if (i == MAX_SKB_FRAGS) {
 						err = -EMSGSIZE;
 						goto error;
 					}
-					get_page(page);
 					skb_fill_page_desc(skb, i, page, sk->sk_sndmsg_off, 0);
+					skb_frag_ref(skb, i);
 					frag = &skb_shinfo(skb)->frags[i];
 				}
 			} else if(i < MAX_SKB_FRAGS) {
@@ -1506,7 +1506,8 @@ alloc_new_skb:
 				err = -EMSGSIZE;
 				goto error;
 			}
-			if (getfrag(from, page_address(frag->page)+frag->page_offset+frag->size, offset, copy, skb->len, skb) < 0) {
+			if (getfrag(from, skb_frag_address(frag)+frag->size,
+				    offset, copy, skb->len, skb) < 0) {
 				err = -EFAULT;
 				goto error;
 			}
-- 
1.7.2.5

