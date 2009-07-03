From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH 1/2] xfrm4: fix the ports decode of sctp protocol
Date: Fri, 03 Jul 2009 10:57:23 +0800
Message-ID: <4A4D7393.1060303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54542 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756638AbZGCC6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 22:58:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SCTP pushed the skb data above the sctp chunk header, so the check
of pskb_may_pull(skb, xprth + 4 - skb->data) in _decode_session4() will
never return 0 because xprth + 4 - skb->data < 0, the ports decode of
sctp will always fail.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv4/xfrm4_policy.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 60d918c..0071ee6 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -136,7 +136,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_TCP:
 		case IPPROTO_SCTP:
 		case IPPROTO_DCCP:
-			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
+			if (xprth + 4 < skb->data ||
+			    pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be16 *ports = (__be16 *)xprth;
 
 				fl->fl_ip_sport = ports[!!reverse];
-- 
1.6.2.2




