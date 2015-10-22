From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] xfrm6: Fix ICMPv6 and MH header checks in _decode_session6
Date: Thu, 22 Oct 2015 08:07:17 +0200
Message-ID: <1445494039-2612-3-git-send-email-steffen.klassert@secunet.com>
References: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50530 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751381AbbJVGH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 02:07:29 -0400
In-Reply-To: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <mathias.krause@secunet.com>

Ensure there's enough data left prior calling pskb_may_pull(). If
skb->data was already advanced, we'll call pskb_may_pull() with a
negative value converted to unsigned int -- leading to a huge
positive value. That won't matter in practice as pskb_may_pull()
will likely fail in this case, but it leads to underflow reports on
kernels handling such kind of over-/underflows, e.g. a PaX enabled
kernel instrumented with the size_overflow plugin.

Reported-by: satmd <satmd@lain.at>
Reported-and-tested-by: Marcin Jurkowski <marcin1j@gmail.com>
Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
Cc: PaX Team <pageexec@freemail.hu>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_policy.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 30caa28..f10b940 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -178,7 +178,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 			return;
 
 		case IPPROTO_ICMPV6:
-			if (!onlyproto && pskb_may_pull(skb, nh + offset + 2 - skb->data)) {
+			if (!onlyproto && (nh + offset + 2 < skb->data ||
+			    pskb_may_pull(skb, nh + offset + 2 - skb->data))) {
 				u8 *icmp;
 
 				nh = skb_network_header(skb);
@@ -192,7 +193,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 		case IPPROTO_MH:
 			offset += ipv6_optlen(exthdr);
-			if (!onlyproto && pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
+			if (!onlyproto && (nh + offset + 3 < skb->data ||
+			    pskb_may_pull(skb, nh + offset + 3 - skb->data))) {
 				struct ip6_mh *mh;
 
 				nh = skb_network_header(skb);
-- 
1.9.1
