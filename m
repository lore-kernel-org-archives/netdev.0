From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 02 Oct 2012 17:48:39 +0200
Message-ID: <1349192919.12401.778.camel@edumazet-glaptop>
References: <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>
	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>
	 <1349192133.12401.768.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chris2553@googlemail.com, netdev@vger.kernel.org, gpiez@web.de,
	Dave Jones <davej@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61656 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222Ab2JBPsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 11:48:46 -0400
Received: by bkcjk13 with SMTP id jk13so5597491bkc.19
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2012 08:48:45 -0700 (PDT)
In-Reply-To: <1349192133.12401.768.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Tue, 2012-10-02 at 17:35 +0200, Eric Dumazet wrote:
> On Mon, 2012-10-01 at 22:04 +0200, Eric Dumazet wrote:
> > On Mon, 2012-10-01 at 16:01 -0400, David Miller wrote:
> 
> > > If you can find a way to more reliably trigger the case, that would
> > > help us immensely.
> > 
> > I am building a KMEMCHECK kernel, as a last try before my night ;)
> 
> This was a total disaster. KMEMCHECK dies horribly on my machine
> 
> David, shouldnt we use a nh_rth_forward instead of a nh_rth_input in
> __mkroute_input() ?
> 
> (And change rt_cache_route() as well ?)
> 
> I am testing a patch right now.

Yeah, this patch seems to fix the bug for me.

[PATCH] ipv4: properly cache forward routes

commit d2d68ba9fe8 (ipv4: Cache input routes in fib_info nexthops.)
introduced a regression for forwarding.

This was hard to reproduce but the symptom was that packets were
delivered to local host instead of being forwarded.

Add a separate cache (nh_rth_forward) to solve the problem.

Many thanks to Chris Clayton for his patience and help.

Reported-by: Chris Clayton <chris2553@googlemail.com>
Bisected-by: Chris Clayton <chris2553@googlemail.com>
Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip_fib.h     |    1 +
 net/ipv4/fib_semantics.c |    1 +
 net/ipv4/route.c         |   16 ++++++++--------
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 926142e..ce7ffe9 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -85,6 +85,7 @@ struct fib_nh {
 	int			nh_saddr_genid;
 	struct rtable __rcu * __percpu *nh_pcpu_rth_output;
 	struct rtable __rcu	*nh_rth_input;
+	struct rtable __rcu	*nh_rth_forward;
 	struct fnhe_hash_bucket	*nh_exceptions;
 };
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3509065..45b5d1d 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -208,6 +208,7 @@ static void free_fib_info_rcu(struct rcu_head *head)
 			free_nh_exceptions(nexthop_nh);
 		rt_fibinfo_free_cpus(nexthop_nh->nh_pcpu_rth_output);
 		rt_fibinfo_free(&nexthop_nh->nh_rth_input);
+		rt_fibinfo_free(&nexthop_nh->nh_rth_forward);
 	} endfor_nexthops(fi);
 
 	release_net(fi->fib_net);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ff62206..50898d6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1193,14 +1193,12 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 	return ret;
 }
 
-static bool rt_cache_route(struct fib_nh *nh, struct rtable *rt)
+static bool rt_cache_route(struct fib_nh *nh, struct rtable *rt, struct rtable **p)
 {
-	struct rtable *orig, *prev, **p;
+	struct rtable *orig, *prev;
 	bool ret = true;
 
-	if (rt_is_input_route(rt)) {
-		p = (struct rtable **)&nh->nh_rth_input;
-	} else {
+	if (!p) {
 		if (!nh->nh_pcpu_rth_output)
 			goto nocache;
 		p = (struct rtable **)__this_cpu_ptr(nh->nh_pcpu_rth_output);
@@ -1290,7 +1288,7 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 		if (unlikely(fnhe))
 			cached = rt_bind_exception(rt, fnhe, daddr);
 		else if (!(rt->dst.flags & DST_NOCACHE))
-			cached = rt_cache_route(nh, rt);
+			cached = rt_cache_route(nh, rt, NULL);
 	}
 	if (unlikely(!cached))
 		rt_add_uncached_list(rt);
@@ -1462,7 +1460,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	do_cache = false;
 	if (res->fi) {
 		if (!itag) {
-			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
+			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_forward);
 			if (rt_cache_valid(rth)) {
 				skb_dst_set_noref(skb, &rth->dst);
 				goto out;
@@ -1493,6 +1491,8 @@ static int __mkroute_input(struct sk_buff *skb,
 
 	rt_set_nexthop(rth, daddr, res, NULL, res->fi, res->type, itag);
 	skb_dst_set(skb, &rth->dst);
+	if (do_cache)
+		rt_cache_route(&FIB_RES_NH(*res), rth, &FIB_RES_NH(*res).nh_rth_forward);
 out:
 	err = 0;
  cleanup:
@@ -1663,7 +1663,7 @@ local_input:
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
 	if (do_cache)
-		rt_cache_route(&FIB_RES_NH(res), rth);
+		rt_cache_route(&FIB_RES_NH(res), rth, &FIB_RES_NH(res).nh_rth_input);
 	skb_dst_set(skb, &rth->dst);
 	err = 0;
 	goto out;
