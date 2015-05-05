From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 0/5] replace skb tc_verd member with 3 dedicated
 bit flags
Date: Tue, 5 May 2015 15:06:08 +0200
Message-ID: <20150505130608.GF17061@breakpoint.cc>
References: <1430765318-13788-1-git-send-email-fw@strlen.de>
 <5548ABF8.5080806@mojatatu.com>
 <20150505114733.GE17061@breakpoint.cc>
 <5548B070.80502@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48898 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161299AbbEENGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 09:06:09 -0400
Content-Disposition: inline
In-Reply-To: <5548B070.80502@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> It is borderline questionable for 1 bit but for consistency i
> suggest you do what was there before. I pointed to nocls but
> i meant the comment generically because previous code you are
> changing intended to use the macros.

True.

> In any case I will leave it up to you.

Okay, thanks Jamal.

I'll have to think about this wrt. how to proceed.

> >>- We need two bits for the location (ingress, egress, from stack)
> >>from stack being 0 i.e when it is not set implicitly it is from the
> >>host stack then we can check for ingress or egress when we choose.
> >
> >Hmm, are you sure?  How is that used?
> >
> 
> As example, when something like
> if (!(at & AT_EGRESS))
> implies it is either from ingress or the stack.
> It does not only from ingress.
> >In fact ifb will BUG() if neither AT_INGRESS or AT_EGRESS was set
> >in G_TC_FROM().
> >
> 
> Yes, because you cant send directly from the stack host to ifb. You
> can only redirect to it. If we ever end there from the host we should
> bug()

$ git grep G_TC_FROM | nl
1  drivers/net/ifb.c:              u32 from = G_TC_FROM(skb->tc_verd);
2  drivers/net/ifb.c:      u32 from = G_TC_FROM(skb->tc_verd);
3  include/uapi/linux/pkt_cls.h:#define G_TC_FROM(x)       _TC_GETVALUE(x,S_TC_FROM,M_TC_FROM)
4  net/sched/sch_netem.c:                  if (G_TC_FROM(skb->tc_verd) & AT_INGRESS)

#1 will BUG() if G_TC_FROM yields 0
#4 only cares about AT_INGRESS

I can indeed get #2 to return 'from 0', via:

ip link set dev ifb0 up
ip addr add  10.2.1.1/8 dev ifb0
ping 10.2.1.2

However, there is no user-visible behaviour change since skb->iif is 0 for locally generated
skb.  Since we do '(from == 0 || skb->iif == 0) -> drop' ifb will still be a /dev/null sink
without skb coming in via mirred action.

This also seems to work:
ip link set dev ifb0 up
ip link set dev eth1 up
ip addr add  192.168.42.1/24 dev eth1
tc qdisc add dev eth1 root handle 1: htb default 1
tc filter add dev eth1 parent 1: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0
ping -c 1 -b 192.168.42.255

iif is set to eth1 iif by the mirred action, so its nonzero by the time skb ends up in ifb and is redirected.

I fully admit that I did not consider this beforehand though ;)

Is there anything else I am missing?

Cheers,
Florian
