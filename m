From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] ila: Don't use dest cache when gateway is set
Date: Sun, 16 Oct 2016 21:25:35 -0700
Message-ID: <20161017042535.2167680-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50317 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753791AbcJQEZn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 00:25:43 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9H4NqiC017507
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2016 21:25:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 264dbnxv6f-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2016 21:25:42 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 c316711c942111e6b3b60002c99293a0-74bfaa50 for <netdev@vger.kernel.org>;        Sun,
 16 Oct 2016 21:25:40 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the gateway is set on an ILA route we don't need to bother with using
the destination cache in the ILA route. Translation does not change the
routing in this case so we can stick with orig_output in the lwstate
output function.

Tested: Ran netperf with and without gateway for LWT route.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ila/ila_lwt.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index d0a98d9..9fafba6 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -36,6 +36,7 @@ static inline struct ila_params *ila_params_lwtunnel(
 static int ila_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *orig_dst = skb_dst(skb);
+	struct rt6_info *rt = (struct rt6_info *)orig_dst;
 	struct ila_lwt *ilwt = ila_lwt_lwtunnel(orig_dst->lwtstate);
 	struct dst_entry *dst;
 	int err = -EINVAL;
@@ -46,6 +47,13 @@ static int ila_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	ila_update_ipv6_locator(skb, ila_params_lwtunnel(orig_dst->lwtstate),
 				true);
 
+	if (rt->rt6i_flags & (RTF_GATEWAY | RTF_CACHE)) {
+		/* Already have a next hop address in route, no need for
+		 * dest cache route.
+		 */
+		return orig_dst->lwtstate->orig_output(net, sk, skb);
+	}
+
 	dst = dst_cache_get(&ilwt->dst_cache);
 	if (unlikely(!dst)) {
 		struct ipv6hdr *ip6h = ipv6_hdr(skb);
-- 
2.9.3
