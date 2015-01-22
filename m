From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH net 4/4] sh_eth: Fix serialisation of interrupt disable
 with interrupt & NAPI handlers
Date: Thu, 22 Jan 2015 17:59:41 +0000
Message-ID: <1421949581.1222.309.camel@xylophone.i.decadent.org.uk>
References: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
		 <1421930648.1222.289.camel@xylophone.i.decadent.org.uk>
		 <54C1002D.7090508@cogentembedded.com>
	 <1421939177.1222.298.camel@xylophone.i.decadent.org.uk>
	 <54C126BA.4030807@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S.Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:51429 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249AbbAVR7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 12:59:42 -0500
In-Reply-To: <54C126BA.4030807@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-22 at 19:35 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/22/2015 06:06 PM, Ben Hutchings wrote:
> 
> >>> In order to stop the RX path accessing the RX ring while it's being
> >>> stopped or resized, we clear the interrupt mask (EESIPR) and then call
> >>> free_irq() or synchronise_irq().  This is insufficient because the
> >>> interrupt handler or NAPI poller may set EESIPR again after we clear
> >>> it.
> 
> >>      Hm, how come the interrupt handler gets called when we have disabled all
> >> interrupts?
> 
> > It may be running on another processor and racing with the function that
> > clears EESIPR.
> 
>     Ah, I didn't think about SMP... but then we need more spinlock protection 
> instead, no?

That's what I tried first.  As we need to serialise with NAPI as well,
and napi_disable() may sleep, we need to call that first, so I ended up
with:

               napi_disable(&mdp->napi);
               spin_lock_irq(&mdp->lock);
               sh_eth_write(ndev, 0x0000, EESIPR);
               spin_unlock_irq(&mdp->lock);
               napi_enable(&mdp->napi);

But after napi_disable() sets the NAPI_STATE_DISABLE bit,
napi_schedule_prep() will return false and so the interrupt handler will
not clear the EESR_RX_CHECK bit any more.  This can leave the interrupt
screaming and prevent the NAPI handler from ever completing, so the
system is livelocked.

> >> Is it unmaskable EESR.ECI interrupt? BTW, I'm not seeing where the
> >> interrupt handler enables interrupts again; only NAPI poller does that AFAIK.
> 
> > Normally it only clears EESR_RX_CHECK, but as it cannot atomically clear
> > a single bit of EESIPR this can result in setting other bits.
> 
>     This is again only possible on SMP kernel, right?

Yes.

Ben.
