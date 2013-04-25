From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: getting VF link info seems to be broken in 3.9-rc8
Date: Thu, 25 Apr 2013 13:20:24 -0700
Message-ID: <51799008.60507@intel.com>
References: <5177D946.9080704@mellanox.com> <AAEA33E297BCAC4B9BB20A7C2DF0AB8D339CC001@FMSMSX113.amr.corp.intel.com> <517975F0.60003@intel.com> <20130425.152431.1753713368050789406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	gregory.v.rose@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, ronye@mellanox.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6109 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932087Ab3DYUUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 16:20:51 -0400
In-Reply-To: <20130425.152431.1753713368050789406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2013 12:24 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Thu, 25 Apr 2013 11:29:04 -0700
>
>> I did a bit of digging and it looks like the issue is that the
>> ext_filter_mask is not being found in the message received in
>> rtnl_dump_ifinfo.  I'm still trying to figure out why the kernel isn't
>> finding the flag when it was finding it previously, but I'm not much of
>> a netlink expert.
> I wonder if this has something to do with this commit:
>
> ====================
> From 88c5b5ce5cb57af6ca2a7cf4d5715fa320448ff9 Mon Sep 17 00:00:00 2001
> From: Michael Riesch <michael.riesch@omicron.at>
> Date: Mon, 8 Apr 2013 05:45:26 +0000
> Subject: [PATCH] rtnetlink: Call nlmsg_parse() with correct header length
>
> Signed-off-by: Michael Riesch <michael.riesch@omicron.at>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Jiri Benc <jbenc@redhat.com>
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Cc: linux-kernel@vger.kernel.org
> Acked-by: Mark Rustad <mark.d.rustad@intel.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/rtnetlink.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index b65441d..23854b5 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1072,7 +1072,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
>  	rcu_read_lock();
>  	cb->seq = net->dev_base_seq;
>  
> -	if (nlmsg_parse(cb->nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
> +	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
>  			ifla_policy) >= 0) {
>  
>  		if (tb[IFLA_EXT_MASK])
> @@ -1922,7 +1922,7 @@ static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	u32 ext_filter_mask = 0;
>  	u16 min_ifinfo_dump_size = 0;
>  
> -	if (nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
> +	if (nlmsg_parse(nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
>  			ifla_policy) >= 0) {
>  		if (tb[IFLA_EXT_MASK])
>  			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);

I thought that as well.  I tried reverting it and the issue is still there.

However, I do think this may be part of the issue since I added a printk
to dump nlmsg_attrlen before going into the nlmsg_parse and with
ifinfomsg the attrlen is -12, with rtgenmsg it is 0.

Thanks,

Alex
