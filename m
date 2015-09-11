From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH] xfrm6: Fix ICMPv6 and MH header checks in _decode_session6
Date: Fri, 11 Sep 2015 09:57:20 +0200
Message-ID: <1441958240-29679-1-git-send-email-minipli@googlemail.com>
Cc: Marcin Jurkowski <marcin1j@gmail.com>, satmd@lain.at,
	netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>,
	Mathias Krause <mathias.krause@secunet.com>,
	PaX Team <pageexec@freemail.hu>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f196.google.com ([209.85.212.196]:35944 "EHLO
	mail-wi0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbbIKH5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 03:57:44 -0400
Received: by wicmn1 with SMTP id mn1so8805593wic.3
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 00:57:42 -0700 (PDT)
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
---
 net/ipv6/xfrm6_policy.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index ed0583c1b9fc..c988c3f033cf 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -174,7 +174,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 			return;
 
 		case IPPROTO_ICMPV6:
-			if (!onlyproto && pskb_may_pull(skb, nh + offset + 2 - skb->data)) {
+			if (!onlyproto && (nh + offset + 2 < skb->data ||
+			    pskb_may_pull(skb, nh + offset + 2 - skb->data))) {
 				u8 *icmp;
 
 				nh = skb_network_header(skb);
@@ -188,7 +189,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 		case IPPROTO_MH:
 			offset += ipv6_optlen(exthdr);
-			if (!onlyproto && pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
+			if (!onlyproto && (nh + offset + 3 < skb->data ||
+			    pskb_may_pull(skb, nh + offset + 3 - skb->data))) {
 				struct ip6_mh *mh;
 
 				nh = skb_network_header(skb);
-- 
2.1.4
