From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Tue, 11 Jul 2017 11:29:32 -0700
Message-ID: <5965190C.6080707@gmail.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810> <595FC974.9030807@gmail.com>    <20170708.104618.2149883426031901592.davem@davemloft.net>       <20170708210617.249059b9@redhat.com>    <20170711173658.6188b0a2@redhat.com>    <59650F6D.4070202@gmail.com> <20170711200136.46ab5687@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        andy@greyhouse.net, daniel@iogearbox.net, ast@fb.com,
        alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35896 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756430AbdGKS3u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 14:29:50 -0400
Received: by mail-pf0-f195.google.com with SMTP id z6so40929pfk.3
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 11:29:49 -0700 (PDT)
In-Reply-To: <20170711200136.46ab5687@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2017 11:01 AM, Jesper Dangaard Brouer wrote:
> On Tue, 11 Jul 2017 10:48:29 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> On 07/11/2017 08:36 AM, Jesper Dangaard Brouer wrote:
>>> On Sat, 8 Jul 2017 21:06:17 +0200
>>> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
>>>   
>>>> My plan is to test this latest patchset again, Monday and Tuesday.
>>>> I'll try to assess stability and provide some performance numbers.  
>>>
>>> Performance numbers:
>>>
>>>  14378479 pkt/s = XDP_DROP without touching memory
>>>   9222401 pkt/s = xdp1: XDP_DROP with reading packet data
>>>   6344472 pkt/s = xdp2: XDP_TX   with swap mac (writes into pkt)
>>>   4595574 pkt/s = xdp_redirect:     XDP_REDIRECT with swap mac (simulate XDP_TX)
>>>   5066243 pkt/s = xdp_redirect_map: XDP_REDIRECT with swap mac + devmap
>>>
>>> The performance drop between xdp2 and xdp_redirect, was expected due
>>> to the HW-tailptr flush per packet, which is costly.
>>>
>>>  (1/6344472-1/4595574)*10^9 = -59.98 ns
>>>
>>> The performance drop between xdp2 and xdp_redirect_map, is higher than
>>> I expected, which is not good!  The avoidance of the tailptr flush per
>>> packet was expected to give a higher boost.  The cost increased with
>>> 40 ns, which is too high compared to the code added (on a 4GHz machine
>>> approx 160 cycles).
>>>
>>>  (1/6344472-1/5066243)*10^9 = -39.77 ns
>>>
>>> This system doesn't have DDIO, thus we are stalling on cache-misses,
>>> but I was actually expecting that the added code could "hide" behind
>>> these cache-misses.
>>>
>>> I'm somewhat surprised to see this large a performance drop.
>>>   
>>
>> Yep, although there is room for optimizations in the code path for sure. And
>> 5mpps is not horrible my preference is to get this series in plus any
>> small optimization we come up with while the merge window is closed. Then
>> follow up patches can do optimizations.
> 
> IMHO 5Mpps is a very bad number for XDP.
> 
>> One easy optimization is to get rid of the atomic bitops. They are not needed
>> here we have a per cpu unsigned long. Another easy one would be to move
>> some of the checks out of the hotpath. For example checking for ndo_xdp_xmit
>> and flush ops on the net device in the hotpath really should be done in the
>> slow path.
> 
> I'm already running with a similar patch as below, but it
> (surprisingly) only gave my 3 ns improvement.  I also tried a
> prefetchw() on xdp.data that gave me 10 ns (which is quite good).
> 

Ah OK good, do the above numbers use the both the bitops changes and the
prefechw?

> I'm booting up another system with a CPU E5-1650 v4 @ 3.60GHz, which
> have DDIO ... I have high hopes for this, as the major bottleneck on
> this CPU i7-4790K CPU @ 4.00GHz is clearly cache-misses.
> 
> Something is definitely wrong on this CPU, as perf stats shows, a very
> bad utilization of the CPU pipeline with 0.89 insn per cycle.
> 

Interesting, the E5-1650 numbers will be good to know. If you have the
perf trace to posting might help track down some hot spots.

.John
