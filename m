From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Cache route in IP tunnels
Date: Thu, 12 Dec 2013 14:54:13 -0800
Message-ID: <CA+mtBx9umr3CPysnKYPCv0NqJicg6rEo6Cg-scUTZWaya-Fz5A@mail.gmail.com>
References: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
	<1386833838.19078.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131212.135433.87781160683841713.davem@davemloft.net>
	<CA+mtBx9GNG3XuyczBAJT4o2FnRBbHTV5U6PYnAJA1gf84ExeNQ@mail.gmail.com>
	<1386880196.19078.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx-hCve-NXDkQLv0bVrrESLOKPH17nzbhMAPORweFr11Og@mail.gmail.com>
	<1386882665.19078.97.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:38926 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab3LLXAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:00:02 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so1742743iec.37
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 15:00:01 -0800 (PST)
In-Reply-To: <1386882665.19078.97.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 1:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-12-12 at 12:56 -0800, Tom Herbert wrote:
>
>> Reverting that patch doesn't fix the problem. We are hitting the
>> spinlock in gro_cells_receive a lot though.
>
> Well, something broke then.
>

The test I'm running is over a single tunnel between two hosts, so all
packets will be hitting the same RX queue since we only steer by
3-tuple hash. Clearing or not clearing hash will have no effect.

Nevertheless, I don't see how code how gro_cells_receive (called via
ip_tunnel_rcv) could have ever have worked right for tunnels. By the
time this function is called, we've probably already spread the
packets from RX queue across multiple CPUs via RPS/RFS. So putting
them back on a queue based on RX queue would be a source of
contention.  It seems like we should be using another per CPU backlog.

> I was able to reach line rate at the time I did this work.
>
>
>
