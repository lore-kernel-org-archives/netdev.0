From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] net: avoid reference counter overflows on fib_rules in multicast forwarding
Date: Mon, 13 Jan 2014 02:45:22 +0100
Message-ID: <20140113014522.GH6586@order.stressinduktion.org>
References: <20140109201411.317040@gmx.com> <20140110063638.GA17866@order.stressinduktion.org> <1389337306.31367.94.camel@edumazet-glaptop2.roam.corp.google.com> <20140110071049.GB17866@order.stressinduktion.org> <1389339179.31367.98.camel@edumazet-glaptop2.roam.corp.google.com> <20140110074325.GC17866@order.stressinduktion.org> <20140110075005.GD17866@order.stressinduktion.org> <20140112074245.GF6586@order.stressinduktion.org> <1389574560.31367.197.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59244 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaAMBpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 20:45:24 -0500
Content-Disposition: inline
In-Reply-To: <1389574560.31367.197.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bob Falken reported that after 4G packets, multicast forwarding stopped
working. This was because of a rule reference counter overflow which
freed the rule as soon as the overflow happend.

This patch solves this by adding the FIB_LOOKUP_NOREF flag to
fib_rules_lookup calls. This is safe even from non-rcu locked sections
as in this case the flag only implies not taking a reference to the rule,
which we don't need at all.

Rules only hold references to the namespace, which are guaranteed to be
available during the call of the non-rcu protected function reg_vif_xmit
because of the interface reference which itself holds a reference to
the net namespace.

Fixes: f0ad0860d01e47 ("ipv4: ipmr: support multiple tables")
Fixes: d1db275dd3f6e4 ("ipv6: ip6mr: support multiple tables")
Reported-by: Bob Falken <NetFestivalHaveFun@gmx.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Bob Falken already tested this patch, as it is similar to my first
attempt but the additional and similar fix for ipv6.

We need an additional fix for kernels without FIB_LOOKUP_NOREF, but I'll
move that to tomorrow, as it is already late here.

 net/ipv4/ipmr.c  | 7 +++++--
 net/ipv6/ip6mr.c | 7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 421a249..b9b3472 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -157,9 +157,12 @@ static struct mr_table *ipmr_get_table(struct net *net, u32 id)
 static int ipmr_fib_lookup(struct net *net, struct flowi4 *flp4,
 			   struct mr_table **mrt)
 {
-	struct ipmr_result res;
-	struct fib_lookup_arg arg = { .result = &res, };
 	int err;
+	struct ipmr_result res;
+	struct fib_lookup_arg arg = {
+		.result = &res,
+		.flags = FIB_LOOKUP_NOREF,
+	};
 
 	err = fib_rules_lookup(net->ipv4.mr_rules_ops,
 			       flowi4_to_flowi(flp4), 0, &arg);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f365310..0eb4038 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -141,9 +141,12 @@ static struct mr6_table *ip6mr_get_table(struct net *net, u32 id)
 static int ip6mr_fib_lookup(struct net *net, struct flowi6 *flp6,
 			    struct mr6_table **mrt)
 {
-	struct ip6mr_result res;
-	struct fib_lookup_arg arg = { .result = &res, };
 	int err;
+	struct ip6mr_result res;
+	struct fib_lookup_arg arg = {
+		.result = &res,
+		.flags = FIB_LOOKUP_NOREF,
+	};
 
 	err = fib_rules_lookup(net->ipv6.mr6_rules_ops,
 			       flowi6_to_flowi(flp6), 0, &arg);
-- 
1.8.4.2
