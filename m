From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net 1/4] mpls: validate L2 via address length
Date: Thu, 10 Dec 2015 19:30:48 +0000
Message-ID: <1449775851-20758-2-git-send-email-rshearma@brocade.com>
References: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<sam.h.russell@gmail.com>, Robert Shearman <rshearma@brocade.com>
To: <ebiederm@xmission.com>, <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:32757 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750888AbbLJTbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 14:31:45 -0500
In-Reply-To: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an L2 via address for an mpls nexthop is specified, the length of
the L2 address must match that expected by the output device,
otherwise it could access memory beyond the end of the via address
buffer in the route.

This check was present prior to commit f8efb73c97e2 ("mpls: multipath
route support"), but got lost in the refactoring, so add it back,
applying it to all nexthops in multipath routes.

Fixes: f8efb73c97e2 ("mpls: multipath route support")
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c70d750148b6..3be29cb1f658 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -534,6 +534,10 @@ static int mpls_nh_assign_dev(struct net *net, struct mpls_route *rt,
 	if (!mpls_dev_get(dev))
 		goto errout;
 
+	if ((nh->nh_via_table == NEIGH_LINK_TABLE) &&
+	    (dev->addr_len != nh->nh_via_alen))
+		goto errout;
+
 	RCU_INIT_POINTER(nh->nh_dev, dev);
 
 	return 0;
-- 
2.1.4
