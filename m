From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 07:49:54 -0800
Message-ID: <1448380194.22599.303.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
	 <1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
	 <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
	 <20151123.145433.1554000376541433305.davem@davemloft.net>
	 <20151124152744.GB20972@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tom@herbertland.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	kernel-team@fb.com, davewatson@fb.com, alexei.starovoitov@gmail.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33310 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575AbbKXPt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 10:49:56 -0500
Received: by pabfh17 with SMTP id fh17so26778185pab.0
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 07:49:56 -0800 (PST)
In-Reply-To: <20151124152744.GB20972@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-24 at 16:27 +0100, Florian Westphal wrote:
> David Miller <davem@davemloft.net> wrote:
> > From: Tom Herbert <tom@herbertland.com>
> > Date: Mon, 23 Nov 2015 09:33:44 -0800
> > 
> > > The TCP PSH flag is not defined for message delineation (neither is
> > > urgent pointer). We can't change that (many people have tried to add
> > > message semantics to TCP protocol but have always failed miserably).
> >
> > Agreed.
> >
> > My only gripe with kcm right now is a lack of a native sendpage.
> 
> Aside from Hannes comment -- KCM seems to be tied to the TLS work, i.e.
> I have the impression that KCM without ability to do TLS in the kernel
> is pretty much useless for whatever use case Tom has in mind.
> 
> And that ktls thing just gives me the creeps.
> 
> For KCM itself I don't even get the use case -- its in the 'yeah, you
> can do that, but... why?' category 8-/

Note that I also played with a similar idea in TCP stack, trying to
wakeup the receiver only full RPC was present in the receive queue.

(When dealing with our internal Google RPC format, we can easily delimit
RPC boundaries)

But in the end, latencies were bigger, because the application had to
copy from kernel to user (read()) the full message in one go. While if
you wake up application for every incoming GRO message, we prefill cpu
caches, and the last read() only has to copy the remaining part and
benefit from hot caches (RFS up2date state, TCP socket structure, but
also data in the application)

I focused on making TSO/GRO more effective, and had better results.

One nice idea was to mark the PSH flag for every TSO packet we send.
(One line patch in TCP senders)

This had the nice effect of keeping the number of flows in the receiver
GRO engine as small as possible, avoiding the evictions that we do when
we reach 8 flows per RX queue (This is because the PSH flag tells GRO to
immediately complete the GRO packet to upper stacks)

-> Less cpu spent in GRO engine, as the gro_list is kept small,
better aggregation efficiency.
