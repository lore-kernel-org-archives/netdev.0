From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Thu, 6 Nov 2008 22:40:32 +0300
Message-ID: <20081106194032.GB31673@ioremap.net>
References: <1225450706.5301.94.camel@localhost> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com> <1225838743.6116.20.camel@fry> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com> <20081106080316.GA32337@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:37869 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348AbYKFTkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 14:40:36 -0500
Content-Disposition: inline
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali.

On Thu, Nov 06, 2008 at 10:49:36AM -0800, Lovich, Vitali (vlovich@qualcomm.com) wrote:
> > What if skb was queued in hardware or qdisk and userspace rewrites
> > mapped page placed in fraglist?
> Can you please clarify what you mean?  Are you talking about the user changing the status field after the skb was queued?  Or are you saying that the user may ask the kernel to resize the ring buffer while the skb is queued?
> 
> In the first case, I don't think we don't really care - the user is breaking their side of the contract, but we'll still have a valid address since the page pointer should still be valid.
> 
> In the second case, the behaviour is undefined because the hardware would use those page pointers for its scatter-gather which would, best case, cause the skb to fail (kernel oops is more likely I think).  We can add this to the documentation, but in the end there's nothing we can really do outside of copying data from the ring buffer into the skb, which defeats the point of doing this.

I'm not sure that it is allowed to fail even for root. System could
sleep and not permit the resize until all skbs are freed though.

> > It is not allowed to store something in cb block which is intended to
> > live while skb is processed on different layers. In this particular
> > case
> > qdisk engine will overwrite skb's cb.
> > 
> That's what I figured - however, I was wondering if we even need to go through the qdisc engine.  Couldn't we just bypass it and send out packets directly through the card (i.e. dev_hard_start_xmit) similar to how pktgen does this?  I haven't looked at the documentation (I'm not actually sure with which to start), but are there any caveats that need to be considered (e.g. must be called outside of an interrupt, can't be interruptible, etc.)
> 
> The reason I'm thinking we'd want to bypass the qdisc engine is that the idea is that you would use this method only if you want the most performance possible, so why is packet scheduling even needed?  The approach I'm thinking is that if the tx-ring buffer is implemented, we can even get rid of the in-kernel pktgen and port it over to user-space as an example of how to utilize the tx-ring buffer.

I can not say if it is good or bad idea, it is not my project :)
But existing packet socket does not bypass qdisc, so users may expect
the same from the new interface. Overall idea of storing something in cb
and expect it to live there between layers is very subtle: what if
tomorrow we will gen new layer between driver and qdisc? Or if we will
start updating cb in the driver itself when it owns skb?

-- 
	Evgeniy Polyakov
