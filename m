From: "Niklas =?iso-8859-1?Q?S=F6derlund?=" <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCH v2] ravb: add wake-on-lan support via magic packet
Date: Tue, 1 Aug 2017 12:13:52 +0200
Message-ID: <20170801101352.GN1382@bigcity.dyn.berto.se>
References: <20170730140646.11781-1-niklas.soderlund+renesas@ragnatech.se>
 <111b5ae4-5517-7a07-3077-96ced89db407@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:34581 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751375AbdHAKN4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 06:13:56 -0400
Received: by mail-lf0-f42.google.com with SMTP id g25so4914882lfh.1
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 03:13:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <111b5ae4-5517-7a07-3077-96ced89db407@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

Thanks for your feedback!

On 2017-07-31 22:47:12 +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 07/30/2017 05:06 PM, Niklas Söderlund wrote:
> 
> > WoL is enabled in the suspend callback by setting MagicPacket detection
> > and disabling all interrupts expect MagicPacket. In the resume path the
> > driver needs to reset the hardware to rearm the WoL logic, this prevents
> > the driver from simply restoring the registers and to take advantage of
> > that ravb was not suspended to reduce resume time. To reset the
> > hardware the driver closes the device, sets it in reset mode and reopens
> > the device just like it would do in a normal suspend/resume scenario
> > without WoL enabled, but it both closes and opens the device in the
> > resume callback since the device needs to be reset for WoL to work.
> 
> > One quirk needed for WoL is that the module clock needs to be prevented
> > from being switched off by Runtime PM. To keep the clock alive the
> > suspend callback need to call clk_enable() directly to increase the
> > usage count of the clock. Then when Runtime PM decreases the clock usage
> > count it won't reach 0 and be switched off.
> > 
> > Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> [...]
> > diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> > index 5931e859876c2aee..3d399f85417a83cf 100644
> > --- a/drivers/net/ethernet/renesas/ravb_main.c
> > +++ b/drivers/net/ethernet/renesas/ravb_main.c
> [...]
> > @@ -2179,6 +2270,32 @@ static int __maybe_unused ravb_resume(struct device *dev)
> >   	struct ravb_private *priv = netdev_priv(ndev);
> >   	int ret = 0;
> > +	/* Reduce the usecount of the clock to zero and then
> > +	 * restore it to its original value. This is done to force
> > +	 * the clock to be re-enabled which is a workaround
> > +	 * for renesas-cpg-mssr driver which do not enable clocks
> > +	 * when resuming from PSCI suspend/resume.
> > +	 *
> > +	 * Without this workaround the driver fails to communicate
> > +	 * with the hardware if WoL was enabled when the system
> > +	 * entered PSCI suspend. This is due to that if WoL is enabled
> > +	 * we explicitly keep the clock from being turned off when
> > +	 * suspending, but in PSCI sleep power is cut so the clock
> > +	 * is disabled anyhow, the clock driver is not aware of this
> > +	 * so the clock is not turned back on when resuming.
> > +	 *
> > +	 * TODO: once the renesas-cpg-mssr suspend/resume is working
> > +	 *       this clock dance should be removed.
> > +	 */
> > +	clk_disable(priv->clk);
> > +	clk_disable(priv->clk);
> > +	clk_enable(priv->clk);
> > +	clk_enable(priv->clk);
> 
>    After a small chat with Niklas, it became clear that this dance should be
> behind the *if* that follows. I'd also like to see this workaround as a
> separate patch since the isse it addresses is R-Car gen3 specific (and thus
> can be reverted once the CPG/MMSR driver is fixed)...

Thanks for spotting my mistake! I will fix this and break out the 
workaround in a separate patch and send a v3.

> 
> > +
> > +	/* If WoL is enabled set reset mode to rearm the WoL logic */
> > +	if (priv->wol_enabled)
> > +		ravb_write(ndev, CCC_OPC_RESET, CCC);
> > +
> >   	/* All register have been reset to default values.
> >   	 * Restore all registers which where setup at probe time and
> >   	 * reopen device if it was running before system suspended.
> > @@ -2202,6 +2319,11 @@ static int __maybe_unused ravb_resume(struct device *dev)
> >  	ravb_write(ndev, priv->desc_bat_dma, DBAT);
> >  	if (netif_running(ndev)) {
> > +		if (priv->wol_enabled) {
> > +			ret = ravb_wol_restore(ndev);
> > +			if (ret)
> > +				return ret;
> > +		}
> >  		ret = ravb_open(ndev);
> 
>    Hm, perhaps worth calling sh_eth_open() outside sh_eth_wol_restore() as well?

Worth looking at, but this is outside the scope of this series as it 
touches the sh_eth driver :-)

> 
> MBR, Sergei

-- 
Regards,
Niklas Söderlund
