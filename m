From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [RFC PATCH v2 5/5] Add sample for adding simple drop program to
 link
Date: Sun, 10 Apr 2016 11:38:11 -0700
Message-ID: <20160410183810.GA18749@gmail.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <1460090930-11219-5-git-send-email-bblanco@plumgrid.com>
 <57091625.1010206@mojatatu.com>
 <20160409164308.GA5750@gmail.com>
 <57093B67.1080604@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, brouer@redhat.com, eric.dumazet@gmail.com,
	ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch,
	johannes@sipsolutions.net, eranlinuxmellanox@gmail.com,
	lorenzo@google.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34161 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756829AbcDJSiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 14:38:15 -0400
Received: by mail-pa0-f49.google.com with SMTP id ot11so23352795pab.1
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 11:38:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57093B67.1080604@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 09, 2016 at 01:27:03PM -0400, Jamal Hadi Salim wrote:
> On 16-04-09 12:43 PM, Brenden Blanco wrote:
> >On Sat, Apr 09, 2016 at 10:48:05AM -0400, Jamal Hadi Salim wrote:
> 
> 
> >>Ok, sorry - should have looked this far before sending earlier email.
> >>So when you run concurently you see about 5Mpps per core but if you
> >>shoot all traffic at a single core you see 20Mpps?
> >No, only sender is multiple, receiver is still single core. The flow is
> >the same in all 4 of the send threads. Note that only ksoftirqd/6 is
> >active.
> 
> Got it.
> The sender was limited to the 20Mpps and you are able to keep up
> if i understand correctly.
Perhaps, though I can't say 100%. The sender is able to do about 21/22
Mpps when pause frames are disabled. The sender is likely CPU limited as
it is an older Xeon.
> 
> 
> >>
> >>Devil's advocate question:
> >>If the bottleneck is the driver - is there an advantage in adding the
> >>bpf code at all in the driver?
> >Only by adding this hook into the driver has it become the bottleneck.
> >
> >Prior to this, the bottleneck was later in the codepath, primarily in
> >allocations.
> >
> 
> Maybe useful in your commit log to show the prior and after.
I can add this, sure.
> Looking at both your and Daniel's profile you show in this email
> mlx4_en_process_rx_cq() seems to be where the action is on both, no?
I don't draw this conclusion. With the phys_dev drop,
mlx4_en_process_rx_cq is the majority time consumer. In the perf output
showing drop in tc, the functions such as dev_gro_receive,
kmem_cache_free, napi_gro_frags, inet_gro_receive, __build_skb, etc
combined add up to 60% of the time spent. None of these are called when
early drop occurs. Just because mlx4_en_process_rx_cq is at the top of
the list doesn't mean it is the lowest hanging fruit.
> 
> >If a packet is to be dropped, and a determination can be made with fewer
> >cpu cycles spent, then there is more time for the goodput.
> >
> 
> Agreed.
> 
> >Beyond that, even if the skb allocation gets 10x or 100x or whatever
> >improvement, there is still a non-zero cost associated, and dropping bad
> >packets with minimal time spent has value. The same argument holds for
> >physical nic forwarding decisions.
> >
> 
> I always go for the lowest hanging fruit.
Which to me is the 60% time spent above the driver level as shown above.
> It seemed it was the driver path in your case. When we removed
> the driver overhead (as demoed at the tc workshop in netdev11) we saw
> __netif_receive_skb_core() at the top of the profile.
> So in this case seems it was mlx4_en_process_rx_cq() - thats why i
> was saying the bottleneck is the driver.
I wouldn't call it a bottleneck when the time spent is additive,
aka run-to-completion.
> Having said that: I agree that early drop is useful if not for anything
> else to avoid the longer code path (but was worried after reading on
> thread this was going to get into a messy stack-in-the-driver and i am
> not sure it is avoidable either given a new ops interface is showing
>  up).
> 
> >>I am curious than before to see the comparison for the same bpf code
> >>running at tc level vs in the driver..
> >Here is a perf report for drop in the clsact qdisc with direct-action,
> >which Daniel earlier showed to have the best performance to-date. On my
> >machine, this gets about 6.5Mpps drop single core. Drop due to failed
> >IP lookup (not shown here) is worse @4.5Mpps.
> >
> 
> Nice.
> However, still for this to be orange/orange comparison you have to
> run it on the _same receiver machine_ as opposed to Daniel doing
> it on his for the one case. And two different kernels booted up
> one patched  with your changes and another virgin without them.
Of course the second perf report is on the same machine as the commit
message. That was generated fresh for this email thread. All of the
numbers I've quoted come from the same single-sender/single-receiver
setup. I did also revert the change the in mlx4 driver and there was no
change in the tc numbers.
> 
> cheers,
> jamal
