From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Questions on XDP
Date: Tue, 21 Feb 2017 21:02:29 -0800
Message-ID: <58AD1B65.6010901@gmail.com>
References: <CAADnVQKmfu8FR3LvKfLbhKaQhXX9g4N=O-MC+K+frM3MF8XaFQ@mail.gmail.com>
 <58A8DD34.5040205@gmail.com>
 <CAKgT0UcpW_MMCgURnB=r5Tezdm9jJSNfOYcNJg8TR1sMKREzPg@mail.gmail.com>
 <58A91589.6050404@gmail.com> <20170220120625.524bc425@cakuba.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34254 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdBVFCq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 00:02:46 -0500
Received: by mail-pg0-f66.google.com with SMTP id s67so203912pgb.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 21:02:46 -0800 (PST)
In-Reply-To: <20170220120625.524bc425@cakuba.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-20 12:06 PM, Jakub Kicinski wrote:
> On Sat, 18 Feb 2017 19:48:25 -0800, John Fastabend wrote:
>> On 17-02-18 06:16 PM, Alexander Duyck wrote:
>>> On Sat, Feb 18, 2017 at 3:48 PM, John Fastabend
>>> <john.fastabend@gmail.com> wrote:  
>>>> On 17-02-18 03:31 PM, Alexei Starovoitov wrote:  
>>>>> On Sat, Feb 18, 2017 at 10:18 AM, Alexander Duyck
>>>>> <alexander.duyck@gmail.com> wrote:  
>>>>>>  
>>>>>>> XDP_DROP does not require having one page per frame.  
>>>>>>
>>>>>> Agreed.  
>>>>>
>>>>> why do you think so?
>>>>> xdp_drop is targeting ddos where in good case
>>>>> all traffic is passed up and in bad case
>>>>> most of the traffic is dropped, but good traffic still needs
>>>>> to be serviced by the layers after. Like other xdp
>>>>> programs and the stack.
>>>>> Say ixgbe+xdp goes with 2k per packet,
>>>>> very soon we will have a bunch of half pages
>>>>> sitting in the stack and other halfs requiring
>>>>> complex refcnting and making the actual
>>>>> ddos mitigation ineffective and forcing nic to drop packets  
>>>>
>>>> I'm not seeing the distinction here. If its a 4k page and
>>>> in the stack the driver will get overrun as well.
>>>>  
>>>>> because it runs out of buffers. Why complicate things?  
>>>>
>>>> It doesn't seem complex to me and the driver already handles this
>>>> case so it actually makes the drivers simpler because there is only
>>>> a single buffer management path.
>>>>  
>>>>> packet per page approach is simple and effective.
>>>>> virtio is different. there we don't have hw that needs
>>>>> to have buffers ready for dma.
>>>>>  
>>>>>> Looking at the Mellanox way of doing it I am not entirely sure it is
>>>>>> useful.  It looks good for benchmarks but that is about it.  Also I  
>>>>>
>>>>> it's the opposite. It already runs very nicely in production.
>>>>> In real life it's always a combination of xdp_drop, xdp_tx and
>>>>> xdp_pass actions.
>>>>> Sounds like ixgbe wants to do things differently because
>>>>> of not-invented-here. That new approach may turn
>>>>> out to be good or bad, but why risk it?
>>>>> mlx4 approach works.
>>>>> mlx5 has few issues though, because page recycling
>>>>> was done too simplistic. Generic page pool/recycling
>>>>> that all drivers will use should solve that. I hope.
>>>>> Is the proposal to have generic split-page recycler ?
>>>>> How that is going to work?
>>>>>  
>>>>
>>>> No, just give the driver a page when it asks for it. How the
>>>> driver uses the page is not the pools concern.
>>>>  
>>>>>> don't see it extending out to the point that we would be able to
>>>>>> exchange packets between interfaces which really seems like it should
>>>>>> be the ultimate goal for XDP_TX.  
>>>>>
>>>>> we don't have a use case for multi-port xdp_tx,
>>>>> but I'm not objecting to doing it in general.
>>>>> Just right now I don't see a need to complicate
>>>>> drivers to do so.  
>>>>
>>>> We are running our vswitch in userspace now for many workloads
>>>> it would be nice to have these in kernel if possible.
>>>>  
>>>>>  
>>>>>> It seems like eventually we want to be able to peel off the buffer and
>>>>>> send it to something other than ourselves.  For example it seems like
>>>>>> it might be useful at some point to use XDP to do traffic
>>>>>> classification and have it route packets between multiple interfaces
>>>>>> on a host and it wouldn't make sense to have all of them map every
>>>>>> page as bidirectional because it starts becoming ridiculous if you
>>>>>> have dozens of interfaces in a system.  
>>>>>
>>>>> dozen interfaces? Like a single nic with dozen ports?
>>>>> or many nics with many ports on the same system?
>>>>> are you trying to build a switch out of x86?
>>>>> I don't think it's realistic to have multi-terrabit x86 box.
>>>>> Is it all because of dpdk/6wind demos?
>>>>> I saw how dpdk was bragging that they can saturate
>>>>> pcie bus. So? Why is this useful?  
>>>
>>> Actually I was thinking more of an OVS, bridge, or routing
>>> replacement.  Basically with a couple of physical interfaces and then
>>> either veth and/or vhost interfaces.
>>>   
>>
>> Yep valid use case for me. We would use this with Intel Clear Linux
>> assuming we can sort it out and perf metrics are good.
> 
> FWIW the limitation of having to remap buffers to TX to other netdev
> also does not apply to NICs which share the same PCI device among all ports
> (mlx4, nfp of the top of my head).  I wonder if it would be worthwhile
> to mentally separate high-performance NICs of which there is a limited
> number from swarms of slow "devices" like VF interfaces, perhaps we
> will want to choose different solutions for the two down the road.
> 
>> Here is XDP extensions for redirect (need to be rebased though)
>>
>>  https://github.com/jrfastab/linux/commit/e78f5425d5e3c305b4170ddd85c61c2e15359fee
>>
>> And here is a sample program,
>>
>>  https://github.com/jrfastab/linux/commit/19d0a5de3f6e934baa8df23d95e766bab7f026d0
>>
>> Probably the most relevant pieces in the above patch is a new ndo op as follows,
>>
>>  +	void			(*ndo_xdp_xmit)(struct net_device *dev,
>>  +						struct xdp_buff *xdp);
>>
>>
>> Then support for redirect in xdp ebpf,
>>
>>  +BPF_CALL_2(bpf_xdp_redirect, u32, ifindex, u64, flags)
>>  +{
>>  +	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
>>  +
>>  +	if (unlikely(flags))
>>  +		return XDP_ABORTED;
>>  +
>>  +	ri->ifindex = ifindex;
>>  +	return XDP_REDIRECT;
>>  +}
>>  +
>>
>> And then a routine for drivers to use to push packets with the XDP_REDIRECT
>> action around,
>>
>> +static int __bpf_tx_xdp(struct net_device *dev, struct xdp_buff *xdp)
>> +{
>> +	if (dev->netdev_ops->ndo_xdp_xmit) {
>> +		dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
>> +		return 0;
>> +	}
>> +	bpf_warn_invalid_xdp_redirect(dev->ifindex);
>> +	return -EOPNOTSUPP;
>> +}
>> +
>> +int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp)
>> +{
>> +	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
>> +
>> +	dev = dev_get_by_index_rcu(dev_net(dev), ri->ifindex);
>> +	ri->ifindex = 0;
>> +	if (unlikely(!dev)) {
>> +		bpf_warn_invalid_xdp_redirect(ri->ifindex);
>> +		return -EINVAL;
>> +	}
>> +
>> +	return __bpf_tx_xdp(dev, xdp);
>> +}
>>
>>
>> Still thinking on it though to see if I might have a better mechanism and
>> need benchmarks to show various metrics.
> 
> Would it perhaps make sense to consider this work as first step on the
> path towards lightweight-skb rather than leaking XDP constructs outside
> of drivers?  If we forced all XDP drivers to produce build_skb-able 
> buffers, we could define the new .ndo as accepting skbs which are not
> fully initialized but can be turned into real skbs if needed?
> 

I believe this is a good idea. But I need a few iterations on existing code
base :) before I can try to realize something like this.

.John
