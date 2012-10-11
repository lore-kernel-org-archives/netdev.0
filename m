From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 15:47:07 +0200
Message-ID: <1349963227.21172.9188.camel@edumazet-glaptop>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	 <20121011103257.GO4625@n2100.arm.linux.org.uk>
	 <1349952574.21172.8604.camel@edumazet-glaptop>
	 <201210111228.25995.arnd@arndb.de>
	 <1349959248.21172.8970.camel@edumazet-glaptop> <5076C78E.1020408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jon Masters <jonathan@jonmasters.org>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55031 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138Ab2JKNrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 09:47:13 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so992169bkc.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 06:47:11 -0700 (PDT)
In-Reply-To: <5076C78E.1020408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 08:20 -0500, Rob Herring wrote:
> On 10/11/2012 07:40 AM, Eric Dumazet wrote:
> > On Thu, 2012-10-11 at 12:28 +0000, Arnd Bergmann wrote:
> > 
> >>
> >> Rob Herring as the original reporter has dropped off the Cc list, adding
> >> him back.
> >>
> >> I assume that the calxeda xgmac driver is the culprit then. It uses
> >> netdev_alloc_skb() rather than netdev_alloc_skb_ip_align() in
> >> xgmac_rx_refill but it is not clear whether it does so intentionally
> >> or by accident.
> 
> This in fact does work and eliminates the unaligned traps. However, not
> all h/w can do IP aligned DMA (i.MX FEC for example), so I still think
> this is a questionable optimization by the compiler. We're saving 1 load
> instruction here for data that is likely already in the cache. It may be
> legal per the ABI, but the downside of this optimization is much greater
> than the upside.

Compiler is asked to perform a 32bit load, it does it.

There is no questionable optimization here. Really.
Please stop pretending this, this makes no sense.

As I said, if some h/w cannot do IP aligned DMA, driver can use a
workaround, or a plain memmove() (some drivers seems to do this to work
around this h/w limitation, just grep for memmove() in drivers/net)

> 
> > 
> > Thanks Arnd
> > 
> > It seems an accident, since driver doesnt check skb->data alignment at
> > all (this can change with SLAB debug on/off)
> > 
> > It also incorrectly adds 64 bytes to bfsize, there is no need for this.
> 
> I'm pretty sure this was needed as the h/w writes out full bursts of
> data, but I'll go back and check.

Maybe the ALIGN() was needed then. But the 64 + NE_IP_ALIGN sounds like
the head room that we allocate/reserve in netdev_alloc_skb_ip_align()

So you allocate this extra room twice.

Thanks
