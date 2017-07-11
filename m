From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Tue, 11 Jul 2017 21:19:42 +0200
Message-ID: <20170711211942.08fdd2f9@redhat.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <595FC974.9030807@gmail.com>
        <20170708.104618.2149883426031901592.davem@davemloft.net>
        <20170708210617.249059b9@redhat.com>
        <20170711173658.6188b0a2@redhat.com>
        <59650F6D.4070202@gmail.com>
        <20170711200136.46ab5687@redhat.com>
        <20170711204405.2f6b033c@redhat.com>
        <59651F55.9050203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        andy@greyhouse.net, daniel@iogearbox.net, ast@fb.com,
        alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com,
        brouer@redhat.com, Andi Kleen <andi@firstfloor.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53644 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933570AbdGKTTw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 15:19:52 -0400
In-Reply-To: <59651F55.9050203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Jul 2017 11:56:21 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 07/11/2017 11:44 AM, Jesper Dangaard Brouer wrote:
> > On Tue, 11 Jul 2017 20:01:36 +0200
> > Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> >   
> >> On Tue, 11 Jul 2017 10:48:29 -0700
> >> John Fastabend <john.fastabend@gmail.com> wrote:
> >>  
> >>> On 07/11/2017 08:36 AM, Jesper Dangaard Brouer wrote:    
> >>>> On Sat, 8 Jul 2017 21:06:17 +0200
> >>>> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> >>>>       
> >>>>> My plan is to test this latest patchset again, Monday and Tuesday.
> >>>>> I'll try to assess stability and provide some performance numbers.      
> >>>>
> >>>> Performance numbers:
> >>>>
> >>>>  14378479 pkt/s = XDP_DROP without touching memory
> >>>>   9222401 pkt/s = xdp1: XDP_DROP with reading packet data
> >>>>   6344472 pkt/s = xdp2: XDP_TX   with swap mac (writes into pkt)
> >>>>   4595574 pkt/s = xdp_redirect:     XDP_REDIRECT with swap mac (simulate XDP_TX)
> >>>>   5066243 pkt/s = xdp_redirect_map: XDP_REDIRECT with swap mac + devmap
> >>>>
> >>>> The performance drop between xdp2 and xdp_redirect, was expected due
> >>>> to the HW-tailptr flush per packet, which is costly.
> >>>>
> >>>>  (1/6344472-1/4595574)*10^9 = -59.98 ns
> >>>>
> >>>> The performance drop between xdp2 and xdp_redirect_map, is higher than
> >>>> I expected, which is not good!  The avoidance of the tailptr flush per
> >>>> packet was expected to give a higher boost.  The cost increased with
> >>>> 40 ns, which is too high compared to the code added (on a 4GHz machine
> >>>> approx 160 cycles).
> >>>>
> >>>>  (1/6344472-1/5066243)*10^9 = -39.77 ns
> >>>>
> >>>> This system doesn't have DDIO, thus we are stalling on cache-misses,
> >>>> but I was actually expecting that the added code could "hide" behind
> >>>> these cache-misses.
> >>>>
> >>>> I'm somewhat surprised to see this large a performance drop.
> >>>>       
> >>>
> >>> Yep, although there is room for optimizations in the code path for sure. And
> >>> 5mpps is not horrible my preference is to get this series in plus any
> >>> small optimization we come up with while the merge window is closed. Then
> >>> follow up patches can do optimizations.    
> >>
> >> IMHO 5Mpps is a very bad number for XDP.
> >>  
> >>> One easy optimization is to get rid of the atomic bitops. They are not needed
> >>> here we have a per cpu unsigned long. Another easy one would be to move
> >>> some of the checks out of the hotpath. For example checking for ndo_xdp_xmit
> >>> and flush ops on the net device in the hotpath really should be done in the
> >>> slow path.    
> >>
> >> I'm already running with a similar patch as below, but it
> >> (surprisingly) only gave my 3 ns improvement.  I also tried a
> >> prefetchw() on xdp.data that gave me 10 ns (which is quite good).
> >>
> >> I'm booting up another system with a CPU E5-1650 v4 @ 3.60GHz, which
> >> have DDIO ... I have high hopes for this, as the major bottleneck on
> >> this CPU i7-4790K CPU @ 4.00GHz is clearly cache-misses.
> >>
> >> Something is definitely wrong on this CPU, as perf stats shows, a very
> >> bad utilization of the CPU pipeline with 0.89 insn per cycle.  
> > 
> > Wow, getting DDIO working and avoiding the cache-miss, was really
> > _the_ issue.  On this CPU E5-1650 v4 @ 3.60GHz things look really
> > really good for XDP_REDIRECT with maps. (p.s. with __set_bit()
> > optimization)
> >   
> 
> Very nice :) this was with the prefecthw() removed right?

Yes, prefetchw removed.

> > 13,939,674 pkt/s = XDP_DROP without touching memory
> > 14,290,650 pkt/s = xdp1: XDP_DROP with reading packet data
> > 13,221,812 pkt/s = xdp2: XDP_TX   with swap mac (writes into pkt)
> >  7,596,576 pkt/s = xdp_redirect:    XDP_REDIRECT with swap mac (like XDP_TX)
> > 13,058,435 pkt/s = xdp_redirect_map:XDP_REDIRECT with swap mac + devmap
> > 
> > Surprisingly, on this DDIO capable CPU it is slightly slower NOT to
> > read packet memory.
> > 
> > The large performance gap to xdp_redirect is due to the tailptr flush,
> > which really show up on this system.  The CPU efficiency is 1.36 insn
> > per cycle, which for map variant is 2.15 insn per cycle.
> > 
> >  Gap (1/13221812-1/7596576)*10^9 = -56 ns
> > 
> > The xdp_redirect_map performance is really really good, almost 10G
> > wirespeed on a single CPU!!!  This is amazing, and we know that this
> > code is not even optimal yet.  The performance difference to xdp2 is
> > only around 1 ns.
> >   
> 
> Great, yeah there are some more likely()/unlikely() hints we could add and
> also remove some of the checks in the hotpath, etc.

Yes, plus inlining some function call.
 
> Thanks for doing this!

I have a really strange observation... if I change the CPU powersave
settings, then the xdp_redirect_map performance drops in half!  Above
was with "tuned-adm profile powersave" (because, this is a really noisy
server, and I'm sitting next to it).  I can see that the CPU under-load
goes into "turbomode", rest going into low-power, including the
Hyper-thread siblings.

If I change the profile to: # tuned-adm profile network-latency

ifindex 6:   12964879 pkt/s
ifindex 6:   12964683 pkt/s
ifindex 6:   12961497 pkt/s
ifindex 6:   11779966 pkt/s <-- change to tuned-adm profile network-latency
ifindex 6:    6853959 pkt/s
ifindex 6:    6851120 pkt/s
ifindex 6:    6856934 pkt/s
ifindex 6:    6857344 pkt/s
ifindex 6:    6857161 pkt/s

The CPU efficiency goes from 2.35 to 1.24 insn per cycle.

John do you know some Intel people that could help me understand what
is going on?!? This is very strange...

I tried Andi's toplev tool, which AFAIK indicate that this is a
Frontend problem, e.g. in decoding the instructions?!?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer


 sudo  ./toplev.py -I 2000 -l3 -a --core C4  --show-sample

 C4    FE   Frontend_Bound:                               43.45 % Slots [4.80%]
 C4    RET  Retiring:                                     49.27 % Slots [4.80%]
 C4    FE   Frontend_Bound.Frontend_Latency:              33.57 % Slots [4.67%]
 C4    RET  Retiring.Microcode_Sequencer:                  9.05 % Slots [4.67%] BN
 C4-T1 FE   Frontend_Bound.Frontend_Latency.MS_Switches:   1.40 % Clocks[4.67%]
 C4-T1      MUX:                                           4.67 %
 C4-T0 FE   Frontend_Bound.Frontend_Latency.MS_Switches:  33.20 % Clocks[4.67%]
 C4-T0      MUX:                                           4.67 %


[jbrouer@localhost pmu-tools]$ sudo turbostat 
	CPU	Avg_MHz	Busy%	Bzy_MHz	TSC_MHz
	-	322	8.78	3668	3600
	0	61	5.12	1200	3600
	6	0	0.01	1235	3600
	1	1	0.09	1225	3600
	7	0	0.02	1212	3600
	2	0	0.02	1243	3600
	8	0	0.02	1307	3600
	3	0	0.04	1205	3600
	9	0	0.01	1207	3600
	4	0	0.00	3801	3600
	10	3800	100.00	3800	3600
	5	0	0.01	1255	3600
	11	0	0.04	1219	3600


[jbrouer@localhost pmu-tools]$ sudo turbostat 
	CPU	Avg_MHz	Busy%	Bzy_MHz	TSC_MHz
	-	3800	100.00	3800	3600
	0	3800	100.00	3800	3600
	6	3800	100.00	3800	3600
	1	3800	100.00	3800	3600
	7	3800	100.00	3800	3600
	2	3800	100.00	3800	3600
	8	3800	100.00	3800	3600
	3	3800	100.00	3800	3600
	9	3800	100.00	3800	3600
	4	3800	100.00	3800	3600
	10	3800	100.00	3800	3600
	5	3800	100.00	3800	3600
	11	3800	100.00	3800	3600
