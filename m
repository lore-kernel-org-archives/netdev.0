From: roy.qing.li@gmail.com
Subject: [PATCH 2/2][V2] xfrm6: fix a potential use after free in xfrm6_policy.c
Date: Tue, 21 Oct 2014 08:34:12 +0800
Message-ID: <1413851652-22553-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:43738 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177AbaJUAeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 20:34:14 -0400
Received: by mail-pa0-f47.google.com with SMTP id kq14so166624pab.20
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 17:34:14 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id uh2sm6185006pbc.81.2014.10.20.17.34.12
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 17:34:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull() maybe change skb->data and make nh and exthdr pointer
oboslete, so recompute the nd and exthdr

V2: insert a space between date type(like __be16) and * as suggested by
Sergei Shtylyov

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
+				ports = (__be16 *)(nh + offset);
 				fl6->fl6_sport = ports[!!reverse];
 				fl6->fl6_dport = ports[!reverse];
 			}
@@ -180,8 +182,10 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 		case IPPROTO_ICMPV6:
 			if (!onlyproto && pskb_may_pull(skb, nh + offset + 2 - skb->data)) {
-				u8 *icmp = (u8 *)exthdr;
+				u8 *icmp;
 
+				nh = skb_network_header(skb);
+				icmp = (u8 *)(nh + offset);
 				fl6->fl6_icmp_type = icmp[0];
 				fl6->fl6_icmp_code = icmp[1];
 			}
@@ -192,8 +196,9 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_MH:
 			if (!onlyproto && pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
 				struct ip6_mh *mh;
-				mh = (struct ip6_mh *)exthdr;
 
+				nh = skb_network_header(skb);
+				mh = (struct ip6_mh *)(nh + offset);
 				fl6->fl6_mh_type = mh->ip6mh_type;
 			}
 			fl6->flowi6_proto = nexthdr;
-- 
1.7.10.4
