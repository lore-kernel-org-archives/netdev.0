From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/2] xdp: disallow use of native and generic hook
 at once
Date: Thu, 11 May 2017 00:24:56 +0200
Message-ID: <59139338.5020405@iogearbox.net>
References: <cover.1494379046.git.daniel@iogearbox.net> <f8405a8769dca09a0f21d11eab3793e30f608531.1494379046.git.daniel@iogearbox.net>  <20170509201842.2ed5e330@cakuba.netronome.com>  <5912DF16.7050603@iogearbox.net> <20170510140754.739e4123@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.fastabend@gmail.com, netdev@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48849 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753151AbdEJWZE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 18:25:04 -0400
In-Reply-To: <20170510140754.739e4123@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 11:07 PM, Jakub Kicinski wrote:
> On Wed, 10 May 2017 11:36:22 +0200, Daniel Borkmann wrote:
>> On 05/10/2017 05:18 AM, Jakub Kicinski wrote:
>>> On Wed, 10 May 2017 03:31:31 +0200, Daniel Borkmann wrote:
[...]
>>>>    	xdp = nla_nest_start(skb, IFLA_XDP);
>>>>    	if (!xdp)
>>>>    		return -EMSGSIZE;
>>>> +
>>>>    	if (rcu_access_pointer(dev->xdp_prog)) {
>>>>    		xdp_flags = XDP_FLAGS_SKB_MODE;
>>>>    		val = 1;
>>>> -	} else if (dev->netdev_ops->ndo_xdp) {
>>>> -		struct netdev_xdp xdp_op = {};
>>>> -
>>>> -		xdp_op.command = XDP_QUERY_PROG;
>>>> -		err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
>>>> -		if (err)
>>>> -			goto err_cancel;
>>>> -		val = xdp_op.prog_attached;
>>>> +	} else {
>>>> +		val = dev_xdp_attached(dev);
>>>> 	}
>>>
>>> Would it make sense to set xdp_flags to XDP_FLAGS_DRV_MODE here to keep
>>> things symmetrical?  I know you are just preserving existing behaviour
>>> but it may seem slightly arbitrary to a new comer to report one of the
>>> very similarly named flags in the dump but not the other.
>>
>> I thought about it, it's kind of redundant information since
>> IFLA_XDP_ATTACHED attribute w/o IFLA_XDP_FLAGS attribute today
>> says that it's native already. It might look strange if we add
>> also XDP_FLAGS_DRV_MODE there, since it doesn't give anything
>> new. I rather see it similar to XDP_FLAGS_UPDATE_IF_NOEXIST flag
>> that is for updating fd only, but I don't really have a strong
>> opinion on this though. I could add it to the respin if preferred.
>
> XDP_FLAGS_UPDATE_IF_NOEXIST is indeed the precedent which makes things
> a bit murky.  There are no reasonably useful semantics for IF_NOEXIST
> on dump :(  Note that meaning of SKB_MODE flag shifts slightly between
> set and dump IIUC.  At set time it means:
>   "force installation at the generic hook",
> at dump time it means:
>   "installed at generic hook - regardless of whether the flag was set at
>    installation time",
>
> So I would argue that DRV_MODE flag is closer to SKB_MODE not only by
> name but also by semantics, and it would be cool if we could keep the
> semantics close on dump as well as set.

Right.

> I understand the counter argument that from user space perspective it
> would make things slightly more complicated because there would be two
> conditions in which driver hook is used:
>   1) DRV_MODE set on dump;
>   2) flags attribute not present (old kernel).
>
> I'm concerned about number 2).  We can't simply depend on SKB_MODE
> not being set because we may add more *_MODE flags in the future.  So
> doing:
>
> if (flags & SKB_MODE)
> 	printf("skb-mode");
> else
> 	printf("drv-mode");
>
> is not correct.  The flags attribute must not be present at all (think
> HW_MODE flag).  But going further there can also be non-MODE flags,
> like, say.. NEVER_TX, and then there may be flags present in dump,
> and if SKB_MODE isn't be set, the mode could be some new MODE user space
> doesn't understand, or it could be DRV_MODE+a new non-MODE flag... no
> way to tell :S

Yep, I see your point. Additionally, if we use XDP_FLAGS_* again for
dumping we're wasting bit space for flags we would never dump back
such as mentioned XDP_FLAGS_UPDATE_IF_NOEXIST (or any other future
flags that are only relevant for loading, but never for dumping).
Given dumping IFLA_XDP_FLAGS was added due to XDP_FLAGS_SKB_MODE,
we can still change this, since it's not too late.

How about the following proposal: IFLA_XDP_ATTACHED we have as-is
(need to keep that anyway), if that is true, it means "something
is attached at XDP layer". Then, we add a new attribute IFLA_XDP_MODE
(enum as type), which can contain XDP_DRV_MODE (0), XDP_SKB_MODE (1).
I don't think there's a strict requirement to really dump IFLA_XDP_FLAGS
back, separating both attrs would avoid this hassle of what current
or future load flag fits for dump as well and which not. Wdyt?

Thanks,
Daniel
