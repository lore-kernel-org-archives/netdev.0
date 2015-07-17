From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 06/22] ipv4: redirect dst output to lwtunnel output
Date: Fri, 17 Jul 2015 14:55:25 +0200
Message-ID: <b1dfe2fda87e5929f9f73b1ac3d6f56e73a8ff15.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	ast@plumgrid.com, weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49442 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757919AbbGQMzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 08:55:53 -0400
In-Reply-To: <cover.1437137396.git.tgraf@suug.ch>
In-Reply-To: <cover.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

For input routes with tunnel encap state this patch redirects
dst output functions to lwtunnel_output which later resolves to
the corresponding lwtunnel output function.

This has been tested to work with mpls ip tunnels.

Open items: Support for tunnel mtu, pmtu, fragmentation can be
added by hooking into the corresponding (ipv4, ipv6) dst ops.
We may do this differently when lwtstate moves to dst or dst_metadata
as per upstream discussions.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv4/route.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 226570b..cd3157c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1633,6 +1633,8 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.output = ip_output;
 
 	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
+	if (lwtunnel_output_redirect(rth->rt_lwtstate))
+		rth->dst.output = lwtunnel_output;
 	skb_dst_set(skb, &rth->dst);
 out:
 	err = 0;
-- 
2.4.3
