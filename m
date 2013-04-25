From: David Miller <davem@davemloft.net>
Subject: Re: getting VF link info seems to be broken in 3.9-rc8
Date: Thu, 25 Apr 2013 16:49:11 -0400 (EDT)
Message-ID: <20130425.164911.746187123714054816.davem@davemloft.net>
References: <20130425.162510.310560314302575352.davem@davemloft.net>
	<517993B6.8040105@intel.com>
	<20130425134513.12720d31@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, mitch.a.williams@intel.com,
	ogerlitz@mellanox.com, gregory.v.rose@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	ronye@mellanox.com, shemminger@vyatta.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759233Ab3DYUtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 16:49:15 -0400
In-Reply-To: <20130425134513.12720d31@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 25 Apr 2013 13:45:13 -0700

> On Thu, 25 Apr 2013 13:36:06 -0700
> Alexander Duyck <alexander.h.duyck@intel.com> wrote:
> 
>> On 04/25/2013 01:25 PM, David Miller wrote:
>> > From: Alexander Duyck <alexander.h.duyck@intel.com>
>> > Date: Thu, 25 Apr 2013 13:20:24 -0700
>> >
>> >> On 04/25/2013 12:24 PM, David Miller wrote:
>> >>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>> >>> Date: Thu, 25 Apr 2013 11:29:04 -0700
>> >>>
>> >>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> >>> index b65441d..23854b5 100644
>> >>> --- a/net/core/rtnetlink.c
>> >>> +++ b/net/core/rtnetlink.c
>> >>> @@ -1072,7 +1072,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
>> >>>  	rcu_read_lock();
>> >>>  	cb->seq = net->dev_base_seq;
>> >>>  
>> >>> -	if (nlmsg_parse(cb->nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
>> >>> +	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
>> >>>  			ifla_policy) >= 0) {
>> >>>  
>> >>>  		if (tb[IFLA_EXT_MASK])
>> >>> @@ -1922,7 +1922,7 @@ static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
>> >>>  	u32 ext_filter_mask = 0;
>> >>>  	u16 min_ifinfo_dump_size = 0;
>> >>>  
>> >>> -	if (nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
>> >>> +	if (nlmsg_parse(nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
>> >>>  			ifla_policy) >= 0) {
>> >>>  		if (tb[IFLA_EXT_MASK])
>> >>>  			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
>> >> I thought that as well.  I tried reverting it and the issue is still there.
>> >>
>> >> However, I do think this may be part of the issue since I added a printk
>> >> to dump nlmsg_attrlen before going into the nlmsg_parse and with
>> >> ifinfomsg the attrlen is -12, with rtgenmsg it is 0.
>> > I wonder if we are seeing two ways tools are making these calls, some are
>> > passing rtgenmsg and some are passing ifinfomsg.  The latter, I am mostly
>> > convinced, is what we must see here from properly written applications.
>> >
>> > That would be really unfortunate, but seeing a nlmsg_attrlen() of -12 would
>> > seem to confirm that a rtgenmsg was used.
>> >
>> > I guess you're using iproute2?
>> 
>> Yes.  All I am doing is ip link show and previously this would display
>> VF info as well as PF.  Now the VF info is not there.
>> 
>> From what I can tell the problem call is rtnl_wilddump_req_filter since
>> it is only passing a rtgenmsg and asking us to dump the link with the
>> RTEXT_FILTER_VF filter mask.
> 
> It looks like a bug in the initial code for filter. in this case, it calls:
>   ip_list_flush_or_save
>      rtnl_wilddump_req_filter
>        which sends 'struct rtgenmsg' 
> 
> This was probably a mistake in the original flags addition, not sure if we can
> fix it now that ABI is set. Probably have to revert the kernel change.

But we know there are tools, just as widely deployed, passing in ifinfomsg.
That's what trigged inclusion of the patch above in the first place.

Let's just declare this an iproute2 bug, fix iproute2 to pass
ifinfomsg too, and keep an eye out for when other folks run into this
problem.
