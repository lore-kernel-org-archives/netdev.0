From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [RFC PATCH net] IPv6: Fix broken IPv6 routing table after loopback
 down-up
Date: Thu, 23 Jan 2014 08:56:37 +0800
Message-ID: <52E068C5.2050405@cn.fujitsu.com>
References: <1390404908-3914-1-git-send-email-sd@queasysnail.net> <20140122213446.GD7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:13096 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752862AbaAWAzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 19:55:43 -0500
In-Reply-To: <20140122213446.GD7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2014 05:34 AM, Hannes Frederic Sowa wrote:
> On Wed, Jan 22, 2014 at 04:35:08PM +0100, Sabrina Dubroca wrote:
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 4b6b720..b2eb653 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -2578,6 +2578,23 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
>>  }
>>  #endif
>>  
>> +struct rt6_info *addrconf_dst_alloc_once(struct inet6_dev *idev,
>> +					 const struct in6_addr *addr,
>> +					 bool anycast)
>> +{
>> +	struct net *net = dev_net(idev->dev);
>> +	struct rt6_info *rt = rt6_lookup(net, addr, NULL, 0, 0);
> 
> We should use addrconf_get_prefix_route here. Eric's comment applies
> here, too, we do a dst_hold in addrconf_get_prefix_route and thus must
> decrease the reference counter with ip6_rt_put then, too.
> 
>> +	if (rt == NULL)
>> +		return addrconf_dst_alloc(idev, addr, anycast);
>> +	else if (!(rt->rt6i_flags & RTF_NONEXTHOP &&
>> +		   ((anycast && rt->rt6i_flags & RTF_ANYCAST) ||
>> +		    (!anycast && rt->rt6i_flags & RTF_LOCAL))))
>> +		return addrconf_dst_alloc(idev, addr, anycast);
> 
> The necessary flags can be given to addrconf_get_prefix_route, then.
> 
>> +	return ERR_PTR(-EEXIST);
>> +}
>> +
>>  static void init_loopback(struct net_device *dev)
>>  {
>>  	struct inet6_dev  *idev;
>> @@ -2611,10 +2628,7 @@ static void init_loopback(struct net_device *dev)
>>  			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
>>  				continue;
>>  
>> -			if (sp_ifa->rt)
>> -				continue;
> 
> We should try to clean sp_ifa->rt on ifdown so we don't have dangling
> pointer to it if it is already in dst gc queue and obsolete. So even if
> we leave this code in there we would never hit the continue (it seems we
> have to decrease the reference counter in addrconf_ifdown before setting
> sp_ifa->rt to NULL).
> 
>> -
>> -			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, false);
>> +			sp_rt = addrconf_dst_alloc_once(idev, &sp_ifa->addr, false);
>>  
>>  			/* Failure cases are ignored */
>>  			if (!IS_ERR(sp_rt)) {
> 
> I am fine if we get this fix in for 3.14 because it solves a real problem.
> I'll already work on the full route preserving logic on ifdown/up and
> would build this on this patch then.
> 
> I currently wonder if we need the relookup logic at all as we currently
> remove the prefix routes in all cases (in rt6_ifdown, which iterates
> over all routing tables). So we always have a obsolete dst which we
> just need to clean up in addrconf_ifdown and just allocate the prefix
> route in init_loopback in all cases. We just have to steal some code
> from inet6_rtm_newaddr to calculate the appropriate flags from the
> inet6_ifaddr's ifa_flags (e.g. RTF_EXPIRES).
> 

I still prefer the patch I send before. I don't like the rt6i_flags,
it is not clear and easy to misunderstand.

But if you all think this one is good, I'm ok, but I don't have enough
time to review it deeply.

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1a341f7..4dca886 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2610,8 +2610,16 @@ static void init_loopback(struct net_device *dev)
                        if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
                                continue;

-                       if (sp_ifa->rt)
-                               continue;
+                       if (sp_ifa->rt) {
+                               /* This dst has been added to garbage list when
+                                * lo device down, delete this obsolete dst and
+                                * reallocate new router for ifa. */
+                               if (sp_ifa->rt->dst.obsolete > 0) {
+                                       ip6_del_rt(sp_ifa->rt);
+                                       sp_ifa->rt = NULL;
+                               } else
+                                       continue;
+                       }

                        sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, false);
