From: Hui Zhang <huizhang@marvell.com>
Subject: [PATCH] net: ipv6: Fixed up ipsec packet be re-routing issue
Date: Mon, 9 Jun 2014 12:37:25 +0800
Message-ID: <1402288645-6904-1-git-send-email-huizhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alan@lxorguk.ukuu.org.uk>, <davem@davemloft.net>,
	<sergei.shtylyov@cogentembedded.com>, <nickcave.zhang@gmail.com>,
	<huizhang@marvell.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:17962 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751120AbaFIEhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 00:37:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug report on https://bugzilla.kernel.org/show_bug.cgi?id=75781

When a local output ipsec packet match the mangle table rule,
and be set mark value, the packet will be route again in
route_me_harder -> _session_decoder6

In this case, the nhoff in CB of skb was still the default
value 0. So the protocal match can't success and the packet can't match
correct SA rule,and then the packet be send out in plaintext.

To fixed up the issue. The CB->nhoff must be set.

Signed-off-by: Hui Zhang <huizhang@marvell.com>
---
 net/ipv6/output_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 827f795..589f6b9 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -106,6 +106,7 @@ int __ip6_local_out(struct sk_buff *skb)
 	if (len > IPV6_MAXPLEN)
 		len = 0;
 	ipv6_hdr(skb)->payload_len = htons(len);
+	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 
 	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
 		       skb_dst(skb)->dev, dst_output);
-- 
1.7.9.5
