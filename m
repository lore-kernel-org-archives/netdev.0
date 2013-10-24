From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 16% regression on 10G caused by TCP small queues
Date: Wed, 23 Oct 2013 23:10:11 -0700
Message-ID: <1382595011.7572.36.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131023192954.3dd9c784@nehalam.linuxnetplumber.net>
	 <CADVnQymDr2K7z3yfKpW-H3R3W3NP+iuPQF2eMfeyS6dn-szdgA@mail.gmail.com>
	 <CAOaVG15indAxBz7E-T+9MK03indiXBa0UhQZ5j6K5DxYP44Mxg@mail.gmail.com>
	 <20131023.233816.1396918839771657154.davem@davemloft.net>
	 <20131023214557.386aad1a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ncardwell@google.com,
	dave.taht@bufferbloat.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:57534 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380Ab3JXGKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 02:10:15 -0400
Received: by mail-ea0-f173.google.com with SMTP id g10so927070eak.4
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 23:10:14 -0700 (PDT)
In-Reply-To: <20131023214557.386aad1a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-23 at 21:45 -0700, Stephen Hemminger wrote:
> On Wed, 23 Oct 2013 23:38:16 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <stephen@networkplumber.org>
> > Date: Wed, 23 Oct 2013 20:09:49 -0700
> > 
> > > I will check 3.12, but what about users on 3.10 which is the LTS
> > > kernel used by most distros?
> 
> 3.12-rc6 gets line rate again (9.41 Gbit/sec)
> 
> > The fix will be backported to -stable, relax Stephen.
> 
> Sorry, thought sk_pacing_rate depended on FQ qdisc but it is other way around.
> In which case doing merge of these two was sufficient to fix the problem.
> With a minor manual fix up to tcp.h.

Btw what is the NIC you are using ?

I also had to patch mlx4 driver because it had too big coalescing
parameters, it was before TCP Small Queue dynamic sizing, but its worth
noting that for the initial ramp up (when flow sk_pacing_rate is low
because initial cwin is 10), it might make a difference

This was 

commit ecfd2ce1a9d5e6376ff5c00b366345160abdbbb7
Author: Eric Dumazet <edumazet@google.com>
Date:   Mon Nov 5 16:20:42 2012 +0000

    mlx4: change TX coalescing defaults
    
    mlx4 currently uses a too high tx coalescing setting, deferring
    TX completion interrupts by up to 128 us.
    
    With the recent skb_orphan() removal in commit 8112ec3b872,
    performance of a single TCP flow is capped to ~4 Gbps, unless
    we increase tcp_limit_output_bytes.
    
    I suggest using 16 us instead of 128 us, allowing a finer control.
    
    Performance of a single TCP flow is restored to previous levels,
    while keeping TCP small queues fully enabled with default sysctl.
    
    This patch is also a BQL prereq.
