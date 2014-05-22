From: huizhang <huizhang@marvell.com>
Subject: [PATCH] net: ipv6: Fixed up ipsec packet be re-routing issue
Date: Thu, 22 May 2014 15:05:46 +0800
Message-ID: <1400742346-24727-1-git-send-email-huizhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huizhang@marvell.com>, <alan@lxorguk.ukuu.org.uk>,
	<nickcave.zhang@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:21994 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750931AbaEVHGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 03:06:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hui Zhang <huizhang@marvell.com>

    Bug report on https://bugzilla.kernel.org/show_bug.cgi?id=75781

    When a local output ipsec packet match the mangle table rule,
    and be set mark value, the packet will be route again in
    route_me_harder -> _session_decoder6

    In this case, the nhoff in CB of skb was still the default
    value 0. So the protocal match can't success and the packet can't match
    correct SA rule,and then the packet be send out in plaintext.

    To fixed up the issue. The CB->nhoff must be set.

Signed-off-by: huizhang <huizhang@marvell.com>
---
 net/ipv6/xfrm6_policy.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 5f8e128..869b68b 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -134,6 +134,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	const struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct ipv6_opt_hdr *exthdr;
 	const unsigned char *nh = skb_network_header(skb);
+	if(IP6CB(skb)->nhoff==0)
+		IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
 	int oif = 0;
 
-- 
1.7.9.5
