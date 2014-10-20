From: roy.qing.li@gmail.com
Subject: [PATCH 2/2] xfrm6: fix a potential use after free in xfrm6_policy.c
Date: Mon, 20 Oct 2014 16:49:14 +0800
Message-ID: <1413794954-16967-2-git-send-email-roy.qing.li@gmail.com>
References: <1413794954-16967-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:53153 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904AbaJTItY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 04:49:24 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so4597323pdj.12
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 01:49:23 -0700 (PDT)
In-Reply-To: <1413794954-16967-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull() maybe change skb->data and make nh and exthdr pointer
oboslete, so recompute the nd and exthdr

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/xfrm6_policy.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index ac49f84..115fd3b 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -170,8 +170,10 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_DCCP:
 			if (!onlyproto && (nh + offset + 4 < skb->data ||
 			     pskb_may_pull(skb, nh + offset + 4 - skb->data))) {
-				__be16 *ports = (__be16 *)exthdr;
+				__be16 *ports;
 
+				nh = skb_network_header(skb);
+				ports = (__be16*)(nh + offset);
 				fl6->fl6_sport = ports[!!reverse];
 				fl6->fl6_dport = ports[!reverse];
 			}
@@ -180,8 +182,10 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 		case IPPROTO_ICMPV6:
 			if (!onlyproto && pskb_may_pull(skb, nh + offset + 2 - skb->data)) {
-				u8 *icmp = (u8 *)exthdr;
+				u8 *icmp;
 
+				nh = skb_network_header(skb);
+				icmp = (u8*)(nh + offset);
 				fl6->fl6_icmp_type = icmp[0];
 				fl6->fl6_icmp_code = icmp[1];
 			}
@@ -192,8 +196,9 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_MH:
 			if (!onlyproto && pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
 				struct ip6_mh *mh;
-				mh = (struct ip6_mh *)exthdr;
 
+				nh = skb_network_header(skb);
+				mh = (struct ip6_mh*)(nh + offset);
 				fl6->fl6_mh_type = mh->ip6mh_type;
 			}
 			fl6->flowi6_proto = nexthdr;
-- 
1.7.10.4
