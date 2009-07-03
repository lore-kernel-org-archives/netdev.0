From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH 2/2] xfrm6: fix the proto and ports decode of sctp protocol
Date: Fri, 03 Jul 2009 10:59:49 +0800
Message-ID: <4A4D7425.7080005@cn.fujitsu.com>
References: <4A4D7393.1060303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51590 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754248AbZGCDAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 23:00:41 -0400
In-Reply-To: <4A4D7393.1060303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SCTP pushed the skb above the sctp chunk header, so the
check of pskb_may_pull(skb, nh + offset + 1 - skb->data) in
_decode_session6() will never return 0 and the ports decode
of sctp will always fail. (nh + offset + 1 - skb->data < 0)

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv6/xfrm6_policy.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index b4b16a4..3a3c677 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -157,7 +157,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	ipv6_addr_copy(&fl->fl6_dst, reverse ? &hdr->saddr : &hdr->daddr);
 	ipv6_addr_copy(&fl->fl6_src, reverse ? &hdr->daddr : &hdr->saddr);
 
-	while (pskb_may_pull(skb, nh + offset + 1 - skb->data)) {
+	while (nh + offset + 1 < skb->data ||
+	       pskb_may_pull(skb, nh + offset + 1 - skb->data)) {
 		nh = skb_network_header(skb);
 		exthdr = (struct ipv6_opt_hdr *)(nh + offset);
 
@@ -177,7 +178,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_TCP:
 		case IPPROTO_SCTP:
 		case IPPROTO_DCCP:
-			if (!onlyproto && pskb_may_pull(skb, nh + offset + 4 - skb->data)) {
+			if (!onlyproto && (nh + offset + 4 < skb->data ||
+			     pskb_may_pull(skb, nh + offset + 4 - skb->data))) {
 				__be16 *ports = (__be16 *)exthdr;
 
 				fl->fl_ip_sport = ports[!!reverse];
-- 
1.6.2.2




