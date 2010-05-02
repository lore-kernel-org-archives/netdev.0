From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
	input_pkt_queue
Date: Sun, 2 May 2010 23:30:52 +0200
Message-ID: <20100502213052.GB2673@gargoyle.fritz.box>
References: <1272568347.2209.11.camel@edumazet-laptop> <20100429214144.GA10663@gargoyle.fritz.box> <20100430.163857.180417789.davem@davemloft.net> <20100501110000.GB9434@gargoyle.fritz.box> <1272783366.2173.13.camel@edumazet-laptop> <20100502092020.GA9655@gargoyle.fritz.box> <1272797690.2173.26.camel@edumazet-laptop> <20100502071324.1a95fdad@infradead.org> <1272810448.2173.31.camel@edumazet-laptop> <20100502105418.7abf83a7@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36361 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756945Ab0EBV2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 17:28:21 -0400
Content-Disposition: inline
In-Reply-To: <20100502105418.7abf83a7@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 02, 2010 at 10:54:18AM -0700, Arjan van de Ven wrote:
> On Sun, 02 May 2010 16:27:28 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > C2 latency seems to be 64  (us ?), while C1 seems to be 1
> 
> the processor_idle module has a "latency_factor" module parameter.
> The default is 2, but sometimes people think 6 is a better value...
> .. any chance you can try that value ?
> 
> Also, I'm starting to wonder if Andi's patch to use io_schedule() needs
> to be replaced with a net_schedule() kind of thing. The cpuidle code
> currently has a weight factor for IO (based on measuring/experiments),
> and maybe networking really needs another factor... so just having a
> parallel concept with a different weight could be the right answer for
> that.

We definitely need a net_schedule() for other reasons too: to avoid the blkio 
wait code and then also because networking needs a short "fast idle" timeout 
because the delays are not bounded.  

Otherwise a sender that suddenly stops sending could break all your power 
saving.

I think the reference count used in io_schedule is not the right model for 
this, probably needs a per cpu timeout ("be fast until this time"). Possibly 
a dynamic one feed by the measured input rate.

-Andi
