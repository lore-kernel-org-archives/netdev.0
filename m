From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: lwtunnel: Handle lwtunnel_fill_encap failure
Date: Wed, 11 Jan 2017 14:29:54 -0800
Message-ID: <1484173794-7777-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33060 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754574AbdAKWaA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 17:30:00 -0500
Received: by mail-pf0-f172.google.com with SMTP id y143so1050397pfb.0
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 14:30:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle failure in lwtunnel_fill_encap adding attributes to skb.

Fixes: 571e722676fe ("ipv4: support for fib route lwtunnel encap attributes")
Fixes: 19e42e451506 ("ipv6: support for fib route lwtunnel encap attributes")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_semantics.c | 11 +++++++----
 net/ipv6/route.c         |  3 ++-
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index eba1546b5031..9a375b908d01 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1279,8 +1279,9 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		    nla_put_u32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid))
 			goto nla_put_failure;
 #endif
-		if (fi->fib_nh->nh_lwtstate)
-			lwtunnel_fill_encap(skb, fi->fib_nh->nh_lwtstate);
+		if (fi->fib_nh->nh_lwtstate &&
+		    lwtunnel_fill_encap(skb, fi->fib_nh->nh_lwtstate) < 0)
+			goto nla_put_failure;
 	}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (fi->fib_nhs > 1) {
@@ -1316,8 +1317,10 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			    nla_put_u32(skb, RTA_FLOW, nh->nh_tclassid))
 				goto nla_put_failure;
 #endif
-			if (nh->nh_lwtstate)
-				lwtunnel_fill_encap(skb, nh->nh_lwtstate);
+			if (nh->nh_lwtstate &&
+			    lwtunnel_fill_encap(skb, nh->nh_lwtstate) < 0)
+				goto nla_put_failure;
+
 			/* length of rtnetlink header + attributes */
 			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *) rtnh;
 		} endfor_nexthops(fi);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ce5aaf448c54..4f6b067c8753 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3317,7 +3317,8 @@ static int rt6_fill_node(struct net *net,
 	if (nla_put_u8(skb, RTA_PREF, IPV6_EXTRACT_PREF(rt->rt6i_flags)))
 		goto nla_put_failure;
 
-	lwtunnel_fill_encap(skb, rt->dst.lwtstate);
+	if (lwtunnel_fill_encap(skb, rt->dst.lwtstate) < 0)
+		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
 	return 0;
-- 
2.1.4
