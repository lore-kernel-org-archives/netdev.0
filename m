From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v3 1/4] route: Set orig_output when redirecting to lwt on locally generated traffic
Date: Tue, 29 Nov 2016 14:21:20 +0100
Message-ID: <1e9928e5798fed084c4cbf26fc7e9abb251a4403.1480424542.git.tgraf@suug.ch>
References: <cover.1480424542.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com,
        roopa@cumulusnetworks.com, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38880 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755456AbcK2NVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 08:21:32 -0500
In-Reply-To: <cover.1480424542.git.tgraf@suug.ch>
In-Reply-To: <cover.1480424542.git.tgraf@suug.ch>
References: <cover.1480424542.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

orig_output for IPv4 was only set for dsts which hit an input route.
Set it consistently for locally generated traffic as well to allow
lwt to continue the dst_output() path as configured by the nexthop.

Fixes: 2536862311d ("lwt: Add support to redirect dst.input")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/route.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d37fc6f..0c39b62 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2154,8 +2154,10 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	}
 
 	rt_set_nexthop(rth, fl4->daddr, res, fnhe, fi, type, 0);
-	if (lwtunnel_output_redirect(rth->dst.lwtstate))
+	if (lwtunnel_output_redirect(rth->dst.lwtstate)) {
+		rth->dst.lwtstate->orig_output = rth->dst.output;
 		rth->dst.output = lwtunnel_output;
+	}
 
 	return rth;
 }
-- 
2.7.4
