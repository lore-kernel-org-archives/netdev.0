From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH net 4/4] sh_eth: Fix serialisation of interrupt disable
 with interrupt & NAPI handlers
Date: Thu, 22 Jan 2015 15:06:17 +0000
Message-ID: <1421939177.1222.298.camel@xylophone.i.decadent.org.uk>
References: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
	 <1421930648.1222.289.camel@xylophone.i.decadent.org.uk>
	 <54C1002D.7090508@cogentembedded.com>
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
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:45158 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbbAVPGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 10:06:19 -0500
In-Reply-To: <54C1002D.7090508@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-22 at 16:50 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 1/22/2015 3:44 PM, Ben Hutchings wrote:
> 
> > In order to stop the RX path accessing the RX ring while it's being
> > stopped or resized, we clear the interrupt mask (EESIPR) and then call
> > free_irq() or synchronise_irq().  This is insufficient because the
> > interrupt handler or NAPI poller may set EESIPR again after we clear
> > it.
> 
>     Hm, how come the interrupt handler gets called when we have disabled all 
> interrupts?

It may be running on another processor and racing with the function that
clears EESIPR.

> Is it unmaskable EESR.ECI interrupt? BTW, I'm not seeing where the 
> interrupt handler enables interrupts again; only NAPI poller does that AFAIK.

Normally it only clears EESR_RX_CHECK, but as it cannot atomically clear
a single bit of EESIPR this can result in setting other bits.

> > Also, in sh_eth_set_ringparam() we currently don't disable NAPI
> > polling at all.
> 
> > I could easily trigger a crash by running the loop:
> 
> >     while ethtool -G eth0 rx 128 && ethtool -G eth0 rx 64; do echo -n .; done
> 
>     Oh, never done any 'ethtool' tests...

You should also be able to trigger this by bringing the device up and
down, but you have to wait for the PHY to bring the link up before any
packets will be received in between.  Thus each cycle takes longer.

[...]
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> > index 7bfaf1c..259d03f 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.h
> > +++ b/drivers/net/ethernet/renesas/sh_eth.h
> > @@ -513,6 +513,7 @@ struct sh_eth_private {
> >   	u32 rx_buf_sz;			/* Based on MTU+slack. */
> >   	int edmac_endian;
> >   	struct napi_struct napi;
> > +	bool irq_enabled;
> >   	/* MII transceiver section. */
> >   	u32 phy_id;			/* PHY ID */
> >   	struct mii_bus *mii_bus;	/* MDIO bus control */
> 
>     In order to conserve space, I'd have added that field after 
> 'vlan_num_ids', just before the 1-bit fields...

I don't think it's worth micro-optimising the size of a per-device
structure.

Ben.
