From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 -next] net: fib: use fib result when zero-length prefix
 aliases exist
Date: Sat, 18 Jul 2015 01:47:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507180045330.2410@ja.home.ssi.bg>
References: <1437154621-18180-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59876 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751190AbbGQWsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 18:48:08 -0400
In-Reply-To: <1437154621-18180-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 17 Jul 2015, Florian Westphal wrote:

> default route selection is not deterministic when TOS keys are used:

	In fact, TOS should be matched just like in
fib_table_lookup but it is not.

> This changes fib_select_default to not change the FIB chosen result EXCEPT
> if this nexthop appears to be unreachable.
> 
> fib_detect_death() logic is reversed -- we consider a nexthop 'dead' only
> if it has a neigh entry in unreachable state.

	The only difference I see is that NUD_NODE is
declared by fib_nud_is_unreach() as reachable. May be
it is better, for example, new route in NUD_NONE state
will be tried for a while, until its state is determined.

> +	if (likely(!fib_nud_is_unreach(res->fi)))
> +		return;

	here first is unreachable...

> +
> +	/* attempt to pick another nexthop */
>  	hlist_for_each_entry_rcu(fa, fa_head, fa_list) {
>  		struct fib_info *next_fi = fa->fa_info;
>  
> @@ -1223,38 +1223,30 @@ void fib_select_default(struct fib_result *res)
>  		    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
>  			continue;
>  
> +		order++;
> +
> +		if (next_fi == res->fi) /* already tested, not reachable */
> +			continue;
> +
>  		fib_alias_accessed(fa);
>  
> -		if (!fi) {
> -			if (next_fi != res->fi)
> +		if (fib_nud_is_unreach(next_fi))

			all others are unreachable too...

> +			continue;
> +
> +		/* try to round-robin among all fa_aliases in case
> +		 * res->fi nexthop is unreachable.

	round-robin only among reachables? But original algorithm
can round-robin among unreachables. State will not change
without trying some packets to unreachable dests.

> +		 */
> +		if (fi == NULL || order > tb->tb_default) {
> +			fi = next_fi;
> +			fi_idx = order;
> +			if (order > tb->tb_default)
>  				break;

	1=unreac, 2=reach, 3=tb_default(reach), 4=reach.
We like 2 (fi == NULL), why we continue after 2, skip
default 3 (because order > tb->tb_default is false) and
finally select 4 (order=4 > tb->tb_default=3)?

> +	tb->tb_default = fi_idx;

	And we do not round-robin if all look unreachable?

	I'm not yet sure if fib_detect_death logic should
be changed. What is strange is that we can switch between
two NUD_VALID entries...

	The __neigh_lookup_noref usage looks ok.
Not sure about the NUD_NODE change, may be it is ok to
be added in fib_detect_death. As for fib_select_default,
may be only change like below is needed. It additionally
restricts the alternative routes to same prefix, same TOS.
The TOS restriction was missing from long time but the
prefix check was lost recently when fa_head was changed
to contain aliases from different prefixes.

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 49c142b..0b1af68 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -290,7 +290,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb);
 int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 			u8 tos, int oif, struct net_device *dev,
 			struct in_device *idev, u32 *itag);
-void fib_select_default(struct fib_result *res);
+void fib_select_default(const struct flowi4 *flp, struct fib_result *res);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 static inline int fib_num_tclassid_users(struct net *net)
 {
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c7358ea..088b2a5 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1202,21 +1202,29 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
 }
 
 /* Must be invoked inside of an RCU protected region.  */
-void fib_select_default(struct fib_result *res)
+void fib_select_default(const struct flowi4 *flp, struct fib_result *res)
 {
 	struct fib_info *fi = NULL, *last_resort = NULL;
 	struct hlist_head *fa_head = res->fa_head;
 	struct fib_table *tb = res->table;
+	u8 slen = 32 - res->prefixlen;
 	int order = -1, last_idx = -1;
 	struct fib_alias *fa;
 
 	hlist_for_each_entry_rcu(fa, fa_head, fa_list) {
 		struct fib_info *next_fi = fa->fa_info;
 
+		if (fa->fa_slen != slen)
+			continue;
 		if (next_fi->fib_scope != res->scope ||
 		    fa->fa_type != RTN_UNICAST)
 			continue;
 
+		if (fa->tb_id != tb->tb_id)
+			continue;
+		if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
+			continue;
+
 		if (next_fi->fib_priority > res->fi->fib_priority)
 			break;
 		if (!next_fi->fib_nh[0].nh_gw ||
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d0362a2..e681b85 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2176,7 +2176,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	if (!res.prefixlen &&
 	    res.table->tb_num_default > 1 &&
 	    res.type == RTN_UNICAST && !fl4->flowi4_oif)
-		fib_select_default(&res);
+		fib_select_default(fl4, &res);
 
 	if (!fl4->saddr)
 		fl4->saddr = FIB_RES_PREFSRC(net, res);

Regards

--
Julian Anastasov <ja@ssi.bg>
