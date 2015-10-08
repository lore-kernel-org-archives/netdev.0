From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: SO_INCOMING_CPU setsockopt() support
Date: Thu, 08 Oct 2015 09:29:35 -0700
Message-ID: <1444321775.27760.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
	 <1444318627-27883-2-git-send-email-edumazet@google.com>
	 <CALx6S35jNA8sQ_yibFK-eL-asbNP9BieRvTcKkM3-CNarKJMDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34585 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933014AbbJHQ3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 12:29:37 -0400
Received: by padhy16 with SMTP id hy16so59188073pad.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 09:29:37 -0700 (PDT)
In-Reply-To: <CALx6S35jNA8sQ_yibFK-eL-asbNP9BieRvTcKkM3-CNarKJMDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-08 at 09:03 -0700, Tom Herbert wrote:
> On Thu, Oct 8, 2015 at 8:37 AM, Eric Dumazet <edumazet@google.com> wrote:
> > SO_INCOMING_CPU as added in commit 2c8c56e15df3 was a getsockopt() command
> > to fetch incoming cpu handling a particular TCP flow after accept()
> >
> > This commits adds setsockopt() support and extends SO_REUSEPORT selection
> > logic : If a TCP listener or UDP socket has this option set, a packet is
> > delivered to this socket only if CPU handling the packet matches the specified one.
> >
> > This allows to build very efficient TCP servers, using one thread per cpu,
> > as the associated TCP listener should only accept flows handled in softirq
> > by the same cpu. This provides optimal NUMA/SMP behavior and keep cpu caches hot.
> >
> Please look again at my SO_INCOMING_CPU_MASK patches to see it these
> will work. I believe SO_INCOMING_CPU setsockopt is probably a subset
> of that functionality. A single CPU assigned to socket forces an
> application design to have one thread per CPU-- this may be overkill.
> It's probably be sufficient in many cases to have just one listener
> thread per NUMA node.


I think you misunderstood my patch.

For optimal behavior against DDOS, you need one TCP _listener_ per RX
queue on the NIC.

Not one listener per cpu !

You can then have multiple threads servicing requests coming for a
particular listener. Or one thread (cpu) servicing requests coming from
multiple TCP listeners. It's as you said an application choice/design.

Say you have 32 cpu (hyper threads) and 8 RX queues, you can create
groups of 4 threads per RX queue. Or one thread servicing all accept()

If you use 2 listeners (one per NUMA node), performance is not so good,
and SO_INCOMING_CPU_MASK adds an extra indirection, scaling poorly with
say 64 listeners.

Ying Cai has a patch to add an array selection (instead of having to
parse the list, yet to be rebased) 

I am afraid your choice of SO_INCOMING_CPU_MASK might have been driven
by the necessity of keeping the list short, but this is about to be a
non issue.

Thanks.
