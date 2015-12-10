From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net 2/4] mpls: don't dump RTA_VIA attribute if not specified
Date: Thu, 10 Dec 2015 19:30:49 +0000
Message-ID: <1449775851-20758-3-git-send-email-rshearma@brocade.com>
References: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<sam.h.russell@gmail.com>, Robert Shearman <rshearma@brocade.com>
To: <ebiederm@xmission.com>, <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:34105 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751875AbbLJTbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 14:31:48 -0500
In-Reply-To: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem seen is that when adding a route with a nexthop with no
via address specified, iproute2 generates bogus output:

  # ip -f mpls route add 100 dev lo
  # ip -f mpls route list
  100 via inet 0.0.8.0 dev lo

The reason for this is that the kernel generates an RTA_VIA attribute
with the family set to AF_INET, but the via address data having zero
length. The cause of family being AF_INET is that on route insert
cfg->rc_via_table is left set to 0, which just happens to be
NEIGH_ARP_TABLE which is then translated into AF_INET.

iproute2 doesn't validate the length prior to printing and so prints
garbage. Although it could be fixed to do the validation, I would
argue that AF_INET addresses should always be exactly 4 bytes so the
kernel is really giving userspace bogus data.

Therefore, avoid generating the RTA_VIA attribute when dumping the
route if the via address wasn't specified on add/modify. This is
indicated by NEIGH_ARP_TABLE and a zero via address length - if the
user specified a via address the address length would have been
validated such that it was 4 bytes. Although this is a change in
behaviour that is visible to userspace, I believe that what was
generated before was invalid and as such userspace wouldn't be
expecting it.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 3be29cb1f658..ac1c116abaac 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1235,7 +1235,9 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		    nla_put_labels(skb, RTA_NEWDST, nh->nh_labels,
 				   nh->nh_label))
 			goto nla_put_failure;
-		if (nla_put_via(skb, nh->nh_via_table, mpls_nh_via(rt, nh),
+		if ((nh->nh_via_table != NEIGH_ARP_TABLE ||
+		     nh->nh_via_alen != 0) &&
+		    nla_put_via(skb, nh->nh_via_table, mpls_nh_via(rt, nh),
 				nh->nh_via_alen))
 			goto nla_put_failure;
 		dev = rtnl_dereference(nh->nh_dev);
@@ -1323,7 +1325,9 @@ static inline size_t lfib_nlmsg_size(struct mpls_route *rt)
 
 		if (nh->nh_dev)
 			payload += nla_total_size(4); /* RTA_OIF */
-		payload += nla_total_size(2 + nh->nh_via_alen); /* RTA_VIA */
+		if (nh->nh_via_table != NEIGH_ARP_TABLE ||
+		    nh->nh_via_alen != 0) /* RTA_VIA */
+			payload += nla_total_size(2 + nh->nh_via_alen);
 		if (nh->nh_labels) /* RTA_NEWDST */
 			payload += nla_total_size(nh->nh_labels * 4);
 	} else {
-- 
2.1.4
