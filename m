From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 2/4] route: Set lwtstate for local traffic and cached input dsts
Date: Sun, 30 Oct 2016 12:58:03 +0100
Message-ID: <95388adeb3a4c6bdb08971b3e979aa8ef2f296e2.1477827877.git.tgraf@suug.ch>
References: <cover.1477827877.git.tgraf@suug.ch>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        tom@herbertland.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:50734 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753776AbcJ3L6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 07:58:18 -0400
In-Reply-To: <cover.1477827877.git.tgraf@suug.ch>
In-Reply-To: <cover.1477827877.git.tgraf@suug.ch>
References: <cover.1477827877.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A route on the output path hitting a RTN_LOCAL route will keep the dst
associated on its way through the loopback device. On the receive path,
the dst_input() call will thus invoke the input handler of the route
created in the output path. Thus, lwt redirection for input must be done
for dsts allocated in the otuput path as well.

Also, if a route is cached in the input path, the allocated dst should
respect lwtunnel configuration on the nexthop as well.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/route.c | 39 ++++++++++++++++++++++++++-------------
 1 file changed, 26 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7da886e..44f5403 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1596,6 +1596,19 @@ static void ip_del_fnhe(struct fib_nh *nh, __be32 daddr)
 	spin_unlock_bh(&fnhe_lock);
 }
 
+static void set_lwt_redirect(struct rtable *rth)
+{
+	if (lwtunnel_output_redirect(rth->dst.lwtstate)) {
+		rth->dst.lwtstate->orig_output = rth->dst.output;
+		rth->dst.output = lwtunnel_output;
+	}
+
+	if (lwtunnel_input_redirect(rth->dst.lwtstate)) {
+		rth->dst.lwtstate->orig_input = rth->dst.input;
+		rth->dst.input = lwtunnel_input;
+	}
+}
+
 /* called in rcu_read_lock() section */
 static int __mkroute_input(struct sk_buff *skb,
 			   const struct fib_result *res,
@@ -1685,14 +1698,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.input = ip_forward;
 
 	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
-	if (lwtunnel_output_redirect(rth->dst.lwtstate)) {
-		rth->dst.lwtstate->orig_output = rth->dst.output;
-		rth->dst.output = lwtunnel_output;
-	}
-	if (lwtunnel_input_redirect(rth->dst.lwtstate)) {
-		rth->dst.lwtstate->orig_input = rth->dst.input;
-		rth->dst.input = lwtunnel_input;
-	}
+	set_lwt_redirect(rth);
 	skb_dst_set(skb, &rth->dst);
 out:
 	err = 0;
@@ -1919,8 +1925,18 @@ out:	return err;
 		rth->dst.error= -err;
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
+
 	if (do_cache) {
-		if (unlikely(!rt_cache_route(&FIB_RES_NH(res), rth))) {
+		struct fib_nh *nh = &FIB_RES_NH(res);
+
+		rth->dst.lwtstate = lwtstate_get(nh->nh_lwtstate);
+		if (lwtunnel_input_redirect(rth->dst.lwtstate)) {
+			WARN_ON(rth->dst.input == lwtunnel_input);
+			rth->dst.lwtstate->orig_input = rth->dst.input;
+			rth->dst.input = lwtunnel_input;
+		}
+
+		if (unlikely(!rt_cache_route(nh, rth))) {
 			rth->dst.flags |= DST_NOCACHE;
 			rt_add_uncached_list(rth);
 		}
@@ -2138,10 +2154,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	}
 
 	rt_set_nexthop(rth, fl4->daddr, res, fnhe, fi, type, 0);
-	if (lwtunnel_output_redirect(rth->dst.lwtstate)) {
-		rth->dst.lwtstate->orig_output = rth->dst.output;
-		rth->dst.output = lwtunnel_output;
-	}
+	set_lwt_redirect(rth);
 
 	return rth;
 }
-- 
2.7.4
