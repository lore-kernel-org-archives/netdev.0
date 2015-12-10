From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net 4/4] mpls: make via address optional for multipath routes
Date: Thu, 10 Dec 2015 19:30:51 +0000
Message-ID: <1449775851-20758-5-git-send-email-rshearma@brocade.com>
References: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<sam.h.russell@gmail.com>, Robert Shearman <rshearma@brocade.com>
To: <ebiederm@xmission.com>, <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:65074 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751467AbbLJTcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 14:32:09 -0500
In-Reply-To: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The via address is optional for a single path route, yet is mandatory
when the multipath attribute is used:

  # ip -f mpls route add 100 dev lo
  # ip -f mpls route add 101 nexthop dev lo
  RTNETLINK answers: Invalid argument

Make them consistent by making the via address optional when the
RTA_MULTIPATH attribute is being parsed so that both forms of
specifying the route work.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 7bfc85f52ca8..c32fc411a911 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -604,10 +604,14 @@ static int mpls_nh_build(struct net *net, struct mpls_route *rt,
 			goto errout;
 	}
 
-	err = nla_get_via(via, &nh->nh_via_alen, &nh->nh_via_table,
-			  __mpls_nh_via(rt, nh));
-	if (err)
-		goto errout;
+	if (via) {
+		err = nla_get_via(via, &nh->nh_via_alen, &nh->nh_via_table,
+				  __mpls_nh_via(rt, nh));
+		if (err)
+			goto errout;
+	} else {
+		nh->nh_via_table = MPLS_NEIGH_TABLE_UNSPEC;
+	}
 
 	err = mpls_nh_assign_dev(net, rt, nh, oif);
 	if (err)
@@ -689,9 +693,6 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 			nla_newdst = nla_find(attrs, attrlen, RTA_NEWDST);
 		}
 
-		if (!nla_via)
-			goto errout;
-
 		err = mpls_nh_build(cfg->rc_nlinfo.nl_net, rt, nh,
 				    rtnh->rtnh_ifindex, nla_via,
 				    nla_newdst);
@@ -1271,7 +1272,8 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 							    nh->nh_labels,
 							    nh->nh_label))
 				goto nla_put_failure;
-			if (nla_put_via(skb, nh->nh_via_table,
+			if (nh->nh_via_table != MPLS_NEIGH_TABLE_UNSPEC &&
+			    nla_put_via(skb, nh->nh_via_table,
 					mpls_nh_via(rt, nh),
 					nh->nh_via_alen))
 				goto nla_put_failure;
@@ -1343,7 +1345,9 @@ static inline size_t lfib_nlmsg_size(struct mpls_route *rt)
 
 		for_nexthops(rt) {
 			nhsize += nla_total_size(sizeof(struct rtnexthop));
-			nhsize += nla_total_size(2 + nh->nh_via_alen);
+			/* RTA_VIA */
+			if (nh->nh_via_table != MPLS_NEIGH_TABLE_UNSPEC)
+				nhsize += nla_total_size(2 + nh->nh_via_alen);
 			if (nh->nh_labels)
 				nhsize += nla_total_size(nh->nh_labels * 4);
 		} endfor_nexthops(rt);
-- 
2.1.4
