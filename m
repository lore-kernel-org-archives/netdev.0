From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Cache route in IP tunnels
Date: Thu, 12 Dec 2013 15:24:23 -0800
Message-ID: <1386890663.19078.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
	 <1386833838.19078.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131212.135433.87781160683841713.davem@davemloft.net>
	 <CA+mtBx9GNG3XuyczBAJT4o2FnRBbHTV5U6PYnAJA1gf84ExeNQ@mail.gmail.com>
	 <1386880196.19078.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx-hCve-NXDkQLv0bVrrESLOKPH17nzbhMAPORweFr11Og@mail.gmail.com>
	 <1386882665.19078.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx9umr3CPysnKYPCv0NqJicg6rEo6Cg-scUTZWaya-Fz5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:41959 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579Ab3LLXY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:24:27 -0500
Received: by mail-qc0-f178.google.com with SMTP id i17so946674qcy.9
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 15:24:26 -0800 (PST)
In-Reply-To: <CA+mtBx9umr3CPysnKYPCv0NqJicg6rEo6Cg-scUTZWaya-Fz5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-12 at 14:54 -0800, Tom Herbert wrote:

> 
> The test I'm running is over a single tunnel between two hosts, so all
> packets will be hitting the same RX queue since we only steer by
> 3-tuple hash. Clearing or not clearing hash will have no effect.

If a single RX queue is used, how can you have contention on a
spinlock ? A single CPU should be used.


> 
> Nevertheless, I don't see how code how gro_cells_receive (called via
> ip_tunnel_rcv) could have ever have worked right for tunnels. By the
> time this function is called, we've probably already spread the
> packets from RX queue across multiple CPUs via RPS/RFS. So putting
> them back on a queue based on RX queue would be a source of
> contention.  It seems like we should be using another per CPU backlog.

This is explained in c9e6bc644e557338221e75c242ab12c275a67d1b changelog

I explicitly explained all this.

The NAPI _is_ the backlog. But you need to avoid crossing cpus,
obviously.

If you spread the load on multiple cpus, you need to instruct the
gro_cell layer to use a proper key to spread the load on different NAPI
cells.

At the time I did this work, I stated the best performance would be
reached without playing with RPS and these awful IPI. Scheduler guys
have hard time with RPS/RFS.

This is all moot, as Jerry is working to do the GRO without having this
extra layer.

And RPS being done _after_ GRO, if you receive traffic on a single RX
queue, you are stuck. Its actually easy to play on outer IP headers
to get proper hash dispersion.
