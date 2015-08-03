From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 2/2] ipv4: apply lwtunnel encap for locally-generated packets
Date: Mon, 3 Aug 2015 17:39:21 +0100
Message-ID: <1438619961-15919-3-git-send-email-rshearma@brocade.com>
References: <1438619961-15919-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:14406 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754009AbbHCQke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 12:40:34 -0400
In-Reply-To: <1438619961-15919-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lwtunnel encap is applied for forwarded packets, but not for
locally-generated packets. This is because the output function is not
overridden in __mkroute_output, unlike it is in __mkroute_input.

The lwtunnel state is correctly set on the rth through the call to
rt_set_nexthop, so all that needs to be done is to override the dst
output function to be lwtunnel_output if there is lwtunnel state
present and it requires output redirection.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/ipv4/route.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 908f7ef2f12a..18fd7c9095c7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2022,6 +2022,8 @@ add:
 	}
 
 	rt_set_nexthop(rth, fl4->daddr, res, fnhe, fi, type, 0);
+	if (lwtunnel_output_redirect(rth->rt_lwtstate))
+		rth->dst.output = lwtunnel_output;
 
 	return rth;
 }
-- 
2.1.4
