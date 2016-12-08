From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sh_eth: add wake-on-lan support via magic packet
Date: Thu, 8 Dec 2016 14:22:44 +0100
Message-ID: <20161208132241.GA7150@verge.net.au>
References: <20161207162843.4731-1-niklas.soderlund+renesas@ragnatech.se>
 <CAMuHMdVK1DtJMajqD-eZ82QSP2ZRozwaR4zNc0ae1YT21Exq0w@mail.gmail.com>
 <20161208071620.GG21834@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Niklas =?utf-8?Q?S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60801 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751487AbcLHNWw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 08:22:52 -0500
Content-Disposition: inline
In-Reply-To: <20161208071620.GG21834@bigcity.dyn.berto.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On do, dec 08, 2016 at 08:16:20 +0100, Niklas Söderlund wrote:
> Hi Geert,
> 
> Thanks for testing and your feedback.
> 
> On 2016-12-07 19:14:40 +0100, Geert Uytterhoeven wrote:
> > Hi Niklas,
> > 
> > On Wed, Dec 7, 2016 at 5:28 PM, Niklas Söderlund
> > <niklas.soderlund+renesas@ragnatech.se> wrote:
> > > Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> > 
> > Thanks, works fine on r8a7791/koelsch!
> > 
> > Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>
> > 
> > > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> > > @@ -624,7 +624,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
> > >
> > >         .register_type  = SH_ETH_REG_FAST_RCAR,
> > >
> > > -       .ecsr_value     = ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
> > > +       .ecsr_value     = ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD | ECSR_MPD,
> > 
> > Interestingly, the ECSR_MPD bit is already set for several SoCs.
> 
> Yes, I noticed that and my assumption was that it was set 'just in case' 
> to clear any MagicPacket interrupts at probe time.
> 
> > 
> > Hence adding ".magic = 1" to the entry for r8a7740 instantly gave me working
> > WoL support on r8a7740/armadillo. Cool!
> 
> Cool, I will set ".magic = 1" for r8a7740 in v2.
> 
> > 
> > > --- a/drivers/net/ethernet/renesas/sh_eth.h
> > > +++ b/drivers/net/ethernet/renesas/sh_eth.h
> > > @@ -493,6 +493,7 @@ struct sh_eth_cpu_data {
> > >         unsigned shift_rd0:1;   /* shift Rx descriptor word 0 right by 16 */
> > >         unsigned rmiimode:1;    /* EtherC has RMIIMODE register */
> > >         unsigned rtrate:1;      /* EtherC has RTRATE register */
> > > +       unsigned magic:1;       /* EtherC have PMDE in ECMR and MPDIP in ECSIPR */
> > 
> > Instead of adding a new flag, perhaps you can just check for the ECSR_MPD flag
> > in ecsr_value?
> 
> I briefly considered this but decided against it since I do not have 
> documentation for all versions of the device and no way to test it. You 
> tested and confirmed functionality on r8a7740, which leaves:
> 
> - sh7734-gether
> - sh7763-gether
> - sh7757-gether
> 
> To figure out if they support MagicPacket in the same fashion as r8a7740 
> and r8a779x. If anyone have access to documentation or hardware to 
> confirm this I be more then happy to get rid of the magic flag in favor 
> och checking for ECSR_MPD in ecsr_value.

Perhaps documentation can be found but if not I wonder if we can use some
other mechanism to blacklist SoC which we are unsure about.

>From my POV it would be very nice if things just worked™ on SoCs where
the feature has been verified.

> > > @@ -529,6 +530,9 @@ struct sh_eth_private {
> > >         unsigned no_ether_link:1;
> > >         unsigned ether_link_active_low:1;
> > >         unsigned is_opened:1;
> > > +
> > > +       bool wol_enabled;
> > 
> > "unsigned wol_enabled:1", to merge with the bitfield above?
> 
> Thanks, looking it it now I don't know what I was thinking. I will 
> changes it for v2.
> 
> > 
> > > +       struct clk *clk;
> > 
> > It's a good practice to keep all pointers at the top of the struct, to avoid
> > gaps due to alignment restrictions, especially on 64-bit (I know that's not
> > the case here).
> 
> Thanks, you learn new things everyday. I will move it for v2.
> 
> > 
> > Gr{oetje,eeting}s,
> > 
> >                         Geert
> > 
> > --
> > Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> > 
> > In personal conversations with technical people, I call myself a hacker. But
> > when I'm talking to journalists I just say "programmer" or something like that.
> >                                 -- Linus Torvalds
> 
> -- 
> Regards,
> Niklas Söderlund
> 
