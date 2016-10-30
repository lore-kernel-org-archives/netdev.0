From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 1/4] route: Set orig_output when redirecting to lwt on locally generated traffic
Date: Sun, 30 Oct 2016 12:58:02 +0100
Message-ID: <8e1079873c6199bf0afb7caf21376a260fcef80b.1477827877.git.tgraf@suug.ch>
References: <cover.1477827877.git.tgraf@suug.ch>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        tom@herbertland.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:50732 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbcJ3L6R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 07:58:17 -0400
In-Reply-To: <cover.1477827877.git.tgraf@suug.ch>
In-Reply-To: <cover.1477827877.git.tgraf@suug.ch>
References: <cover.1477827877.git.tgraf@suug.ch>
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
index 62d4d90..7da886e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2138,8 +2138,10 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
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
