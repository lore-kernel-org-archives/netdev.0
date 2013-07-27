From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] fib_rules: add .suppress operation
Date: Sat, 27 Jul 2013 08:08:02 +0200
Message-ID: <20130727060802.GD20273@order.stressinduktion.org>
References: <20130725221116.GC10216@zirkel.wertarbyte.de> <20130726104657.GF10216@zirkel.wertarbyte.de> <20130726170556.GA11434@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>,
	netdev@vger.kernel.org, Andrew Collins <bsderandrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:42658 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721Ab3G0GIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 02:08:04 -0400
Content-Disposition: inline
In-Reply-To: <20130726170556.GA11434@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 07:05:56PM +0200, Hannes Frederic Sowa wrote:
> On Fri, Jul 26, 2013 at 12:46:57PM +0200, Stefan Tomanek wrote:
> >  		if (err != -EAGAIN) {
> > +			if (ops->suppress && ops->suppress(rule, arg)) {
> > +				continue;
> > +			}

We need to make sure route lookup succeeded:

			if (!err && ops->suppress && ops->suppress(rule, arg))

> > +static int fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg) {
> > +	struct rt6_info *rt = (struct rt6_info *) arg->result;
> > +	/*
> > +	 * do not accept result if the route does
> > +	 * not meet the required prefix length
> > +	 */
> > +	if (rt->rt6i_dst.plen < rule->table_prefixlen_min) {
> > +		return 1;
> > +	}
> > +	return 0;
> > +}
> 
> Urks, fib6_rule_action is broken. The switch (rule->action) does update the rt
> entry but does not signal the correct error code to stop iterating the rules
> in case it finds a blackhole, prohibit etc. action (it always signals
> -EAGAIN).

I have to take back that fib6_rule_action is broken, it just showes some
unwanted side effects in this constalation.

> A change in this logic could have impact to your patch as I currently
> don't know how the null handling of arg->result will turn out. IPv6 does not
> preinitialize arg->result as IPv4 does.
> 
> I am looking for a solution.

This compile-only-tested patch would make the error reporting consistent
with its ipv4 counterpart. arg->result should only be NULL iff the
function returns -EAGAIN. So we are clean here.

(It seems this patch also fixes a potential nullptr dereference.)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 2e1a432..4c8bac7 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -55,26 +55,33 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 	struct fib6_table *table;
 	struct net *net = rule->fr_net;
 	pol_lookup_t lookup = arg->lookup_ptr;
+	int err = 0;
 
 	switch (rule->action) {
 	case FR_ACT_TO_TBL:
 		break;
 	case FR_ACT_UNREACHABLE:
+		err = -ENETUNREACH;
 		rt = net->ipv6.ip6_null_entry;
 		goto discard_pkt;
 	default:
 	case FR_ACT_BLACKHOLE:
+		err = -EINVAL;
 		rt = net->ipv6.ip6_blk_hole_entry;
 		goto discard_pkt;
 	case FR_ACT_PROHIBIT:
+		err = -EACCES;
 		rt = net->ipv6.ip6_prohibit_entry;
 		goto discard_pkt;
 	}
 
 	table = fib6_get_table(net, rule->table);
-	if (table)
-		rt = lookup(net, table, flp6, flags);
+	if (!table) {
+		err = -EAGAIN;
+		goto out;
+	}
 
+	rt = lookup(net, table, flp6, flags);
 	if (rt != net->ipv6.ip6_null_entry) {
 		struct fib6_rule *r = (struct fib6_rule *)rule;
 
@@ -101,6 +108,7 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 	}
 again:
 	ip6_rt_put(rt);
+	err = -EAGAIN;
 	rt = NULL;
 	goto out;
 
@@ -108,7 +116,7 @@ discard_pkt:
 	dst_hold(&rt->dst);
 out:
 	arg->result = rt;
-	return rt == NULL ? -EAGAIN : 0;
+	return err;
 }
 
 
