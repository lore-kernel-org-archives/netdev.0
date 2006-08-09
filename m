From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [RFC] [GIT PATCH] IPv6 Routing / Ndisc Fixes
Date: Thu, 10 Aug 2006 00:37:14 +0300
Message-ID: <44DA558A.1080706@tcs.hut.fi>
References: <20060809.195627.59155708.yoshfuji@linux-ipv6.org> <44D9D431.10101@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:58889 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1751383AbWHIVhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 17:37:16 -0400
To: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
In-Reply-To: <44D9D431.10101@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I still seem to have serious problems with my mailer. Despite numerous
resends, I still haven't seen my reply on netdev. Hopefully it finally
gets through, sorry for any possible duplicates.


Ville Nuorvala wrote:
> YOSHIFUJI Hideaki wrote:
>> Hello.
> 
> Hello Yoshifuji-san!
> 
>> Here's a set of changesets (on top of net-2.6.19 tree) to fix routing / ndisc.
>> Changesets are available at:
>> 	git://git.skbuff.net/gitroot/yoshfuji/net-2.6.19-20060809-polroute-fixes/
> 
> I'd like to comment some of the NDISC patches a bit (comments inline),
> but all other changes looked good.
> 
>> CHANGESETS
>> ----------
>>
>> commit 4f2956c43d77e1efbf044db305455493276fc6f2
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 16:53:52 2006 +0900
>>
>>     [IPV6] NDISC: Take source address into account for redirects.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
> 
>> ---
>> commit 40ff54178bd3c5dbd80f9422e88f7539727cc4e7
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 16:53:53 2006 +0900
>>
>>     [IPV6] NDISC: Search over all possible rules on receipt of redirect.
>>     
>>     Split up function for finding routes for redirects.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 91c9461..4650787 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1282,19 +1282,18 @@ static int ip6_route_del(struct in6_rtms
>>  /*
>>   *	Handle redirects
>>   */
>> -void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
>> -		  struct in6_addr *saddr,
>> -		  struct neighbour *neigh, u8 *lladdr, int on_link)
>> +struct ip6rd_flowi {
>> +	struct flowi fl;
>> +	struct in6_addr gateway;
>> +};
>> +
>> +static struct rt6_info *__ip6_route_redirect(struct fib6_table *table,
>> +					     struct flowi *fl,
>> +					     int flags)
>>  {
>> -	struct rt6_info *rt, *nrt = NULL;
>> +	struct ip6rd_flowi *rdfl = (struct ip6rd_flowi *)fl;
>> +	struct rt6_info *rt;
>>  	struct fib6_node *fn;
>> -	struct fib6_table *table;
>> -	struct netevent_redirect netevent;
>> -
>> -	/* TODO: Very lazy, might need to check all tables */
>> -	table = fib6_get_table(RT6_TABLE_MAIN);
>> -	if (table == NULL)
>> -		return;
>>  
>>  	/*
>>  	 * Get the "current" route for this destination and
>> @@ -1308,7 +1307,7 @@ void rt6_redirect(struct in6_addr *dest,
>>  	 */
>>  
>>  	read_lock_bh(&table->tb6_lock);
>> -	fn = fib6_lookup(&table->tb6_root, dest, src);
>> +	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
>>  restart:
>>  	for (rt = fn->leaf; rt; rt = rt->u.next) {
>>  		/*
>> @@ -1323,29 +1322,67 @@ restart:
>>  			continue;
>>  		if (!(rt->rt6i_flags & RTF_GATEWAY))
>>  			continue;
>> -		if (neigh->dev != rt->rt6i_dev)
>> +		if (fl->oif != rt->rt6i_dev->ifindex)
>>  			continue;
>> -		if (!ipv6_addr_equal(saddr, &rt->rt6i_gateway))
>> +		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
>>  			continue;
>>  		break;
>>  	}
>> -	if (rt)
>> -		dst_hold(&rt->u.dst);
>> -	else if (rt6_need_strict(dest)) {
>> -		while ((fn = fn->parent) != NULL) {
>> -			if (fn->fn_flags & RTN_ROOT)
>> -				break;
>> -			if (fn->fn_flags & RTN_RTINFO)
>> -				goto restart;
>> +
>> +	if (!rt) {
>> +		if (rt6_need_strict(&fl->fl6_dst)) {
>> +			while ((fn = fn->parent) != NULL) {
>> +				if (fn->fn_flags & RTN_ROOT)
>> +					break;
>> +				if (fn->fn_flags & RTN_RTINFO)
>> +					goto restart;
>> +			}
>>  		}
>> +		rt = &ip6_null_entry;
>>  	}
>> +	dst_hold(&rt->u.dst);
>> +
>>  	read_unlock_bh(&table->tb6_lock);
>>  
>> -	if (!rt) {
>> +	return rt;
>> +};
>> +
>> +static struct rt6_info *ip6_route_redirect(struct in6_addr *dest,
>> +					   struct in6_addr *src,
>> +					   struct in6_addr *gateway,
>> +					   struct net_device *dev)
>> +{
>> +	struct ip6rd_flowi rdfl = {
>> +		.fl = {
>> +			.oif = dev->ifindex,
>> +			.nl_u = {
>> +				.ip6_u = {
>> +					.daddr = *dest,
>> +					.saddr = *src,
>> +				},
>> +			},
>> +		},
>> +		.gateway = *gateway,
>> +	};
>> +	int flags = rt6_need_strict(dest) ? RT6_F_STRICT : 0;
>> +
>> +	return (struct rt6_info *)fib6_rule_lookup((struct flowi *)&rdfl, flags, __ip6_route_redirect);
>> +}
>> +
>> +void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
>> +		  struct in6_addr *saddr,
>> +		  struct neighbour *neigh, u8 *lladdr, int on_link)
>> +{
>> +	struct rt6_info *rt, *nrt = NULL;
>> +	struct netevent_redirect netevent;
>> +
>> +	rt = ip6_route_redirect(dest, src, saddr, neigh->dev);
>> +
>> +	if (rt == &ip6_null_entry) {
>>  		if (net_ratelimit())
>>  			printk(KERN_DEBUG "rt6_redirect: source isn't a valid nexthop "
>>  			       "for redirect target\n");
>> -		return;
>> +		goto out;
>>  	}
>>  
>>  	/*
> 
> This might work correctly, but I'd like to make sure. If it works, I'd
> like to know this is by choice and not by chance.
> 
> As ip6_route_redirect can't possibly know the (possible) incoming
> interface of the original redirected packet it can't set fl.iif. This
> means the the route lookup result might differ from the original route
> lookup. However, a situation like this doesn't arise unless the node
> functions as a router.
> 
> According to the RFC 2461 a router MUST NOT change its routing behavior
> as the result of an ICMPv6 redirect, i.e. it has to ignore the message.
> In reality things are not always as clear cut as this. The Mobile Router
> defined in RFC 3963 acts as a router between its virtual tunnel
> interface and its ingress interface, but in practice acts as a host on
> its egress interface. That being said, I think your code works ok even
> in this case, but I'd have to test this to make sure.
> 
>> ---
>> commit e0ad64d5b44179ea1296d737dec23279c72c9636
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:08:33 2006 +0900
>>
>>     [IPV6] NDISC: Allow redirects from other interfaces if it is not strict.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 4650787..1698fec 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1322,7 +1322,7 @@ restart:
>>  			continue;
>>  		if (!(rt->rt6i_flags & RTF_GATEWAY))
>>  			continue;
>> -		if (fl->oif != rt->rt6i_dev->ifindex)
>> +		if ((flags & RT6_F_STRICT) && fl->oif != rt->rt6i_dev->ifindex)
>>  			continue;
>>  		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
>>  			continue;
>>
> 
> Is this absolutely safe? Doesn't this enable a malicious node on another
> link to make a bogus redirect if it uses same link-local source address
> as the real router on the other link. Keep in mind that the RT6_F_STRICT
> flag is set based on the destination of the original redirected packet
> and doesn't in any way depend on the router or source address.
> 
> Without SEND, similar attacks are of course possible when the attacker
> is on the same link as the router, but I suspect we are opening up a new
> hole here.
> 
>> ---
>> commit 67539e5824106359507ea462035fa8bb57c20d4c
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:08:41 2006 +0900
>>
>>     [IPV6] NDISC: Initialize fl with outbound interface to lookup rules properly.
>>     
>>     Based on MIPL2 kernel patch.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
>> ---
>> commit 8fc359533dbc3962f32ef2cf39f1e0bf1f5be33b
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:09:13 2006 +0900
>>
>>     [IPV6] ROUTE: Introduce a helper to check route validity.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Acked-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
>> ---
>> commit 25ee62e8a25adfbb2d64c4b54a759d4fbf5be9d8
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:14:39 2006 +0900
>>
>>     [IPV6]: Cache source address as well in ipv6_pinfo{}.
>>     
>>     Based on MIPL2 kernel patch.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
>> ---
>> commit 61391ed3da4ba78353febdb69e9faa9832479425
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:17:47 2006 +0900
>>
>>     [IPV6] ROUTE: Make sure we have fn->leaf when adding a node on subtree.
>>     
>>     Based on MIPL2 kernel patch.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
>> ---
>> commit 7c191ae22dee4465fffd8603429385fbea518faa
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:18:06 2006 +0900
>>
>>     [IPV6] ROUTE: Prune clones from main tree as well.
>>     
>>     Based on MIPL2 kernel patch.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
>> ---
>> commit 7e7d663f87c72805f68317d402107e81ff309c0d
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:18:31 2006 +0900
>>
>>     [IPV6] ROUTE: Fix looking up a route on subtree.
>>     
>>     Even on RTN_ROOT node, we need to process its subtree first.
>>     Fix NULL pointer dereference in fib6_locate().
>>     
>>     Based on MIPL2 kernel patch.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
>> ---
>> commit 1b5fab0cbe09e9aa00ff1c7f13aa204aca8c4b29
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:18:56 2006 +0900
>>
>>     [IPV6] ROUTE: Make sure we do not exceed args in fib6_lookup_1().
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Acked-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
>> ---
>> commit eec98f168a438781c133270dfdf456b345fd48d2
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:19:15 2006 +0900
>>
>>     [IPV6] ROUTE: Allow searching subtree only.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>>
>> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
>> index b24b6a4..3d45a44 100644
>> --- a/net/ipv6/ip6_fib.c
>> +++ b/net/ipv6/ip6_fib.c
>> @@ -753,7 +753,7 @@ #endif
>>  		}
>>  	};
>>  
>> -	fn = fib6_lookup_1(root, args);
>> +	fn = fib6_lookup_1(root, daddr ? args : args + 1);
>>  
>>  	if (fn == NULL || fn->fn_flags & RTN_TL_ROOT)
>>  		fn = root;
>>
> 
> Acked-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
>> ---
>> commit 450a6aa5da9a8ffba9a9e462183b0ab76bbfd40c
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:19:37 2006 +0900
>>
>>     [IPV6] ROUTE: Put SUBTREE() as FIB6_SUBTREE() into ip6_fib.h for future use.
>>     
>>     Based on MIPL2 kernel patch.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
>> ---
>> commit 09aa35ff359e520abb11b6f71deb21f79da30a52
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:29:18 2006 +0900
>>
>>     [IPV6] ROUTE: Search subtree when backtracking.
>>     
>>     Based on MIPL2 kernel patch.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
>> ---
>> commit a75bc4c27c306402d721310e92060969e6e5a031
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:29:33 2006 +0900
>>
>>     [IPV6] ROUTE: Purge clones on other trees when deleting a route.
>>     
>>     Based on MIPL2 kernel patch.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi
> 
>> ---
>> commit 5cb675bce7549177c09ad42e48e07a59df5e0c3f
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:33:35 2006 +0900
>>
>>     [IPV6] NDISC: Search subtrees when backtracking on receipt of redirects.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Acked-by: Ville Nuorvala <vnuorval@tcs.hut.fi
> 
>> ---
>> commit 9458f9452e16b5ef6c0c70e0e134513a5f07632b
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 17:37:16 2006 +0900
>>
>>     [IPV6] KCONFIG: Add subtrees support.
>>     
>>     This is for developers only.
>>     Based on MIPL2 kernel patch.
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi
> 
>> ---
>> commit 218aaaf16e581fce753fcf581d40915da1e23b06
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Wed Aug 9 18:05:02 2006 +0900
>>
>>     [IPV6] ROUTE: Unify RT6_F_xxx and RT6_SELECT_F_xxx flags
>>     
>>     Unify RT6_F_xxx and RT6_SELECT_F_xxx flags into
>>     RT6_LOOKUP_F_xxx flags, and put them into ip6_route.h
>>     
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Acked-by: Ville Nuorvala <vnuorval@tcs.hut.fi
> 
> Regards,
> Ville
> 

