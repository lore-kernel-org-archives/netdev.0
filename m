From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Thu, 6 Nov 2008 11:53:35 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
 <1225838743.6116.20.camel@fry>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
 <20081106080316.GA32337@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
 <20081106194032.GB31673@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:1857 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbYKFTxh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 14:53:37 -0500
In-Reply-To: <20081106194032.GB31673@ioremap.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Evgeniy Polyakov [mailto:zbr@ioremap.net]
> Sent: November-06-08 11:41 AM
> To: Lovich, Vitali
> Cc: Johann Baudy; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> Hi Vitali.
> 
> On Thu, Nov 06, 2008 at 10:49:36AM -0800, Lovich, Vitali
> (vlovich@qualcomm.com) wrote:
> > > What if skb was queued in hardware or qdisk and userspace rewrites
> > > mapped page placed in fraglist?
> > Can you please clarify what you mean?  Are you talking about the user
> changing the status field after the skb was queued?  Or are you saying
> that the user may ask the kernel to resize the ring buffer while the
> skb is queued?
> >
> > In the first case, I don't think we don't really care - the user is
> breaking their side of the contract, but we'll still have a valid
> address since the page pointer should still be valid.
> >
> > In the second case, the behaviour is undefined because the hardware
> would use those page pointers for its scatter-gather which would, best
> case, cause the skb to fail (kernel oops is more likely I think).  We
> can add this to the documentation, but in the end there's nothing we
> can really do outside of copying data from the ring buffer into the
> skb, which defeats the point of doing this.
> 
> I'm not sure that it is allowed to fail even for root. System could
> sleep and not permit the resize until all skbs are freed though.
You're right - I think the code needs an additional check for atomic_read(&po->tx_pending_skb) around line 1867 where it's checking the number of mmaps to the ring buffer.

Which brings up a possible bug in the proposed patch - the mapped atomic int field should be part of the struct containing a ring buffer - each ring buffer has a different number of mappings.  Otherwise, there will be issues trying to create both a tx & rx ring.
> 
> > > It is not allowed to store something in cb block which is intended
> to
> > > live while skb is processed on different layers. In this particular
> > > case
> > > qdisk engine will overwrite skb's cb.
> > >
> > That's what I figured - however, I was wondering if we even need to
> go through the qdisc engine.  Couldn't we just bypass it and send out
> packets directly through the card (i.e. dev_hard_start_xmit) similar to
> how pktgen does this?  I haven't looked at the documentation (I'm not
> actually sure with which to start), but are there any caveats that need
> to be considered (e.g. must be called outside of an interrupt, can't be
> interruptible, etc.)
> >
> > The reason I'm thinking we'd want to bypass the qdisc engine is that
> the idea is that you would use this method only if you want the most
> performance possible, so why is packet scheduling even needed?  The
> approach I'm thinking is that if the tx-ring buffer is implemented, we
> can even get rid of the in-kernel pktgen and port it over to user-space
> as an example of how to utilize the tx-ring buffer.
> 
> I can not say if it is good or bad idea, it is not my project :)
> But existing packet socket does not bypass qdisc, so users may expect
> the same from the new interface. Overall idea of storing something in
> cb
> and expect it to live there between layers is very subtle: what if
> tomorrow we will gen new layer between driver and qdisc? Or if we will
> start updating cb in the driver itself when it owns skb?
Are there any consequences to bypassing qdisc (other than not participating in any load balancing)?  Also, since any users using the tx ring approach would have to write new code, it would be part of the documentation that the send behaviour is optimized for the least latency and highest throughput, thus no guarantees and assumptions can be made about the path the data takes through the stack.

I agree with you about not using the cb - I was just looking at all possible alternatives of how this can be solved.  I'm liking my approach of using the frag list because it's the least intrusive (doesn't require modification of the skb_buff structure) and the seems to be the most resilient (trying to hide data in some unused skb field and hope no one overwrites it)

Thanks,
Vitali
