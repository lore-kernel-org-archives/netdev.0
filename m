From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Thu, 6 Nov 2008 10:49:36 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
 <1225838743.6116.20.camel@fry>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
 <20081106080316.GA32337@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:58324 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbYKFStj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 13:49:39 -0500
In-Reply-To: <20081106080316.GA32337@ioremap.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

> -----Original Message-----
> From: Evgeniy Polyakov [mailto:zbr@ioremap.net]
> Sent: November-06-08 12:03 AM
> To: Lovich, Vitali
> Cc: Johann Baudy; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> Hi Vitali.
> 
> On Wed, Nov 05, 2008 at 04:47:03PM -0800, Lovich, Vitali
> (vlovich@qualcomm.com) wrote:
> > In either case, the skb given to the destructor will still have the
> correct values for fragments we specified.  Of course, this is based on
> 2 assumptions:
> >
> > 1.  Nothing further down the line won't add fragments, thereby
> overwriting frags[0]
> > 2.  No-one writes to frags[0].page & frags[0].page_offset
> >
> > 1 is reasonable because since the only reason we would be linearizing
> in the first place is if the device doesn't support scatter/gather, so
> it would be strange for something down the line to add more fragments
> that would have to be linearized anyways.
> >
> > 2 is reasonable since it would only make sense if something down the
> line used this as a temporary variable storage, which again should be
> unlikely.
> 
> What if skb was queued in hardware or qdisk and userspace rewrites
> mapped page placed in fraglist?
Can you please clarify what you mean?  Are you talking about the user changing the status field after the skb was queued?  Or are you saying that the user may ask the kernel to resize the ring buffer while the skb is queued?

In the first case, I don't think we don't really care - the user is breaking their side of the contract, but we'll still have a valid address since the page pointer should still be valid.

In the second case, the behaviour is undefined because the hardware would use those page pointers for its scatter-gather which would, best case, cause the skb to fail (kernel oops is more likely I think).  We can add this to the documentation, but in the end there's nothing we can really do outside of copying data from the ring buffer into the skb, which defeats the point of doing this.

Or am I completely missing your point?
> 
> > Another approach may be to store it in the cb as we had done so
> originally, except with skb_clone to ensure no other layers overwrite
> it, although I'm not 100% sure of the implications of skb_clone has for
> things like the cb & users fields and kfree_skb.
> 
> It is not allowed to store something in cb block which is intended to
> live while skb is processed on different layers. In this particular
> case
> qdisk engine will overwrite skb's cb.
> 
That's what I figured - however, I was wondering if we even need to go through the qdisc engine.  Couldn't we just bypass it and send out packets directly through the card (i.e. dev_hard_start_xmit) similar to how pktgen does this?  I haven't looked at the documentation (I'm not actually sure with which to start), but are there any caveats that need to be considered (e.g. must be called outside of an interrupt, can't be interruptible, etc.)

The reason I'm thinking we'd want to bypass the qdisc engine is that the idea is that you would use this method only if you want the most performance possible, so why is packet scheduling even needed?  The approach I'm thinking is that if the tx-ring buffer is implemented, we can even get rid of the in-kernel pktgen and port it over to user-space as an example of how to utilize the tx-ring buffer.

Thanks,
Vitali
