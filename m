From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/2] xdp: disallow use of native and generic hook
 at once
Date: Wed, 10 May 2017 11:36:22 +0200
Message-ID: <5912DF16.7050603@iogearbox.net>
References: <cover.1494379046.git.daniel@iogearbox.net>        <f8405a8769dca09a0f21d11eab3793e30f608531.1494379046.git.daniel@iogearbox.net> <20170509201842.2ed5e330@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.fastabend@gmail.com, netdev@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58866 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751724AbdEJJgl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 05:36:41 -0400
In-Reply-To: <20170509201842.2ed5e330@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 05:18 AM, Jakub Kicinski wrote:
> On Wed, 10 May 2017 03:31:31 +0200, Daniel Borkmann wrote:
>> While working on the iproute2 generic XDP frontend, I noticed that
>> as of right now it's possible to have native *and* generic XDP
>> programs loaded both at the same time for the case when a driver
>> supports native XDP.
>
> Nice improvement!  A couple of absolute nitpicks below..
>
>> The intended model for generic XDP from b5cdae3291f7 ("net: Generic
>> XDP") is, however, that only one out of the two can be present at
>> once which is also indicated as such in the XPD netlink dump part.
>                                                ^^^
>                                                   XDP

Good point.

>> @@ -6851,6 +6851,32 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
>>   }
>>   EXPORT_SYMBOL(dev_change_proto_down);
>>
>> +bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)
>
> Out of curiosity - the leading underscores refer to caller having to
> hold rtnl?  I assume they are not needed in the function below because
> it's static?

I think I don't quite follow the last question, but it probably makes
sense to add an ASSERT_RTNL() into dev_xdp_attached() inline helper to
make it clearly visible to callers of this api.

>> +{
>> +	struct netdev_xdp xdp;
>> +
>> +	memset(&xdp, 0, sizeof(xdp));
>> +	xdp.command = XDP_QUERY_PROG;
>
> Probably personal preference, but seems like designated struct
> initializer would do quite nicely here and save the memset :)

I had that initially, but I recalled that gcc < 4.6 does not handle this
style for the initialization of anonymous struct/union properly (e.g.,
we fixed that in iproute2 as well). Andrew Morton still uses gcc 4.4.4
and occasionally sends kernel fixes, so we might end up like this anyway.

>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index dda9f16..99320f0 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -1251,24 +1251,20 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
>>   {
>>   	struct nlattr *xdp;
>>   	u32 xdp_flags = 0;
>> -	u8 val = 0;
>>   	int err;
>> +	u8 val;
>>
>>   	xdp = nla_nest_start(skb, IFLA_XDP);
>>   	if (!xdp)
>>   		return -EMSGSIZE;
>> +
>>   	if (rcu_access_pointer(dev->xdp_prog)) {
>>   		xdp_flags = XDP_FLAGS_SKB_MODE;
>>   		val = 1;
>> -	} else if (dev->netdev_ops->ndo_xdp) {
>> -		struct netdev_xdp xdp_op = {};
>> -
>> -		xdp_op.command = XDP_QUERY_PROG;
>> -		err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
>> -		if (err)
>> -			goto err_cancel;
>> -		val = xdp_op.prog_attached;
>> +	} else {
>> +		val = dev_xdp_attached(dev);
>> 	}
>
> Would it make sense to set xdp_flags to XDP_FLAGS_DRV_MODE here to keep
> things symmetrical?  I know you are just preserving existing behaviour
> but it may seem slightly arbitrary to a new comer to report one of the
> very similarly named flags in the dump but not the other.

I thought about it, it's kind of redundant information since
IFLA_XDP_ATTACHED attribute w/o IFLA_XDP_FLAGS attribute today
says that it's native already. It might look strange if we add
also XDP_FLAGS_DRV_MODE there, since it doesn't give anything
new. I rather see it similar to XDP_FLAGS_UPDATE_IF_NOEXIST flag
that is for updating fd only, but I don't really have a strong
opinion on this though. I could add it to the respin if preferred.
