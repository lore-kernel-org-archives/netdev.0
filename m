From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: implement rt_genid_bump_ipv6 with
 fn_sernum and remove rt6i_genid
Date: Wed, 10 Sep 2014 15:42:17 +0200
Message-ID: <1410356537.3135.21.camel@localhost>
References: <1410267519.27979.31.camel@localhost>
	 <130f98f49b1b90a30908bfda8f01109c91edfe1c.1410341451.git.hannes@stressinduktion.org>
	 <54105185.7010206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:37623 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751560AbaIJNmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 09:42:20 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 91B6220A43
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 09:42:19 -0400 (EDT)
In-Reply-To: <54105185.7010206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Mi, 2014-09-10 at 09:26 -0400, Vlad Yasevich wrote:
> On 09/10/2014 05:31 AM, Hannes Frederic Sowa wrote:
> > Some special routes will never be cloned in IPv6. Those are mainly
> > DST_HOST routes without RTF_NONEXTHOP or RTF_GATEWAY flags, thus mostly
> > routes handling the input path.
> > 
> > rt_genid depends on rt6_info clones being removed from the trie and
> > recreated with current rt6i_genid, thus bumping the genid would invalidate
> > all routes cached in the sockets and relookup will recreate them.  But in
> > case a non-cloned route ends up in the per-socket cache, it will never
> > be recreated, thus will never get a current rt_genid.
> > 
> > After the rt_genid is incremented for the first time all those routes
> > will always get invalidated by ip6_dst_check on the next check, thus
> > making early socket demultiplexing absolutely pointless for IPv6. It is
> > not possible to solve this with rt6i_genid, thus remove it.
> > 
> > In case we need to force the sockets to relookup the routes we now
> > increase the fn_sernum on all fibnodes in the routing tree. This is a
> > costly operation but should only happen if we have major routing/policy
> > changes in the kernel (e.g. manual route adding/removal, xfrm policy
> > changes). Also this patch optimized the walk over the trie a bit, we
> > don't touch every rt6_info but only touch the fib6_nodes.
> > 
> > Thanks to Eric Dumazet who noticed this problem.
>
> I also noticed the ipv6_ifa_notify() is called a lot with even being
> 0.  This will only trigger rtnl notification, but would not trigger any
> routing table changes, but would trigger a call to bump the gen_id
> which now would perform a rather expensive clean-table operation.
> 
> In particular the loop in manage_tempaddrs() is very scary as it can
> bump the rev multiples times.
> 
> I think it the genid bump in __ipv6_ifa_notify() should only happen
> if there was an actual address change.

Yes, maybe we don't even need to bump id in ipv6_ifa_notify at all, I am
still investigating. :)

Thanks,
Hannes
