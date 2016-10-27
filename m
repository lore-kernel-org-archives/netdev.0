From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Thu, 27 Oct 2016 10:40:14 +0200
Message-ID: <c9683122-d770-355b-e275-7c446e6d1d0f@zonque.org>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
 <20161026195933.GA2031@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161026195933.GA2031@salvia>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/26/2016 09:59 PM, Pablo Neira Ayuso wrote:
> On Tue, Oct 25, 2016 at 12:14:08PM +0200, Daniel Mack wrote:
> [...]
>>   Dumping programs once they are installed is problematic because of
>>   the internal optimizations done to the eBPF program during its
>>   lifetime. Also, the references to maps etc. would need to be
>>   restored during the dump.
>>
>>   Just exposing whether or not a program is attached would be
>>   trivial to do, however, most easily through another bpf(2)
>>   command. That can be added later on though.
> 
> I don't know if anyone told you, but during last netconf, this topic
> took a bit of time of discussion and it was controversial, I would say
> 1/3 of netdev hackers there showed their concerns, and that's
> something that should not be skipped IMO.
> 
> While xdp is pushing bpf programs at the very early packet path, not
> interfering with the stack, before even entering the generic ingress
> path. But this is adding hooks to push bpf programs in the middle of
> our generic stack, this is way different domain.

It's not anything new. These hooks live on the very same level as
SO_ATTACH_FILTER. The only differences are that the BPF programs are
stored in the cgroup, and not in the socket, and that they exist for
egress as well.

> I would really like to explore way earlier filtering, by extending
> socket lookup facilities. So far the problem seems to be that we need
> to lookup for broadcast/multicast UDP sockets and those cannot be
> attach via the usual skb->sk.

We've been there. We've discussed all that. And we concluded that doing
early demux in the input filter path is not the right approach. That was
my very first take on that issue back in June 2015 (!), and it was
rightfully turned down for good reasons.

Adding it there would mean we need to early-demux *every* packet as soon
as there is *any* such rule installed, and that renders many
optimizations in the kernel to drop traffic that has no local receiver
useless.

> I think it would be possible to wrap
> around this socket code in functions so we can invoke it. I guess
> filtering of UDP and TCP should be good for you at this stage. This
> would require more work though, but this would come with no hooks in
> the stack and packets will not have to consume *lots of cycles* just
> to be dropped before entering the socket queue.
>
> How useful can be to drop lots of unwanted traffic at such a late
> stage? How would the performance numbers to drop packets would look
> like? Extremely bad, I predict.

I fear I'm repeating myself here, but this is unfounded. I'm not sure
why you keep bringing it up. As I said weeks ago - just loading the
netfilter modules without any rules deployed has more impact than
running the example program in 6/6 on every packet in the test traffic.
Please give it a shot yourself.

Also, the eBPF programs can well be used in combination with existing
netfilter setups. There is no reason to not combine the two levels of
filtering. Both have their right to exist, and nobody is taking anything
away.


Thanks,
Daniel
