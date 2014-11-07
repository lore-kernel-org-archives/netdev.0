From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: gro: add a per device gro flush timer
Date: Thu, 06 Nov 2014 20:15:14 -0800
Message-ID: <1415333714.13896.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141106.162516.1083429539800319166.davem@davemloft.net>
	 <1415311880.13896.85.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141106.223603.678182467467024928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:50010 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbaKGEPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 23:15:22 -0500
Received: by mail-ie0-f182.google.com with SMTP id rd18so4450677iec.27
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 20:15:21 -0800 (PST)
In-Reply-To: <20141106.223603.678182467467024928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-06 at 22:36 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 06 Nov 2014 14:11:20 -0800
> 
> > My goal was to not change any driver, doing a generic change.
> > 
> > Drivers call napi_complete() in their rx napi handler without giving us
> > the 'work_done' value which tells us if a packet was processed.
> > 
> > So I added a counter that is increased for every packet given to GRO
> > engine (napi_rx_count), so that napi_complete() has a clue if a packet
> > was received in _this_ NAPI run.
> > 
> > If at least one packet was received (and we still have packets in
> > gro_list) -> We ream the 'timer'
> > If not, we flush packets in GRO engine.
> > 
> > In order to avoid this state, I would have to add a new method, like
> > napi_complete_done(napi, work_done), and change drivers. I am not sure
> > its worth the effort ?
> 
> I think for such a critical path in the kernel it's worth it to avoid
> these increments for every packet, just to compute a value that's
> sitting in a register already in the driver's poll routine.
> 
> Eric, you've been trimming cpu IRQ disables from these exact code
> paths, you should know better than me :-)
> 
> I'm willing to do some of the monkey work of converting as many
> drivers as can be trivially done if you want.  Almost all of the
> ones I looked at have the work_done variable right there at the
> napi_complete() call site.
> 
> The rest can stay unconverted and not get access to this new facility.

This is your call. I actually did this in my first implementation,
because I was not using a timer but rescheduling NAPI and not
re-enabling interrupts.

http://www.spinics.net/lists/netdev/msg302474.html

(This is why I had to cook "d75b1ade567 net: less interrupt masking in
NAPI")

Given the cost of GRO processing, setting a bool (this is all I need
actually) is really pure noise.
