From: "Niklas =?iso-8859-1?Q?S=F6derlund?=" <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCHv2 1/5] sh_eth: add generic wake-on-lan support via magic
 packet
Date: Tue, 13 Dec 2016 17:27:17 +0100
Message-ID: <20161213162717.GE24175@bigcity.dyn.berto.se>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
 <20161212160931.6478-2-niklas.soderlund+renesas@ragnatech.se>
 <CAMuHMdV6xrzjBQeVAWK3B_c077O6keWrH7Ndi5CX+2JLqjsL5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        linux-pm@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdV6xrzjBQeVAWK3B_c077O6keWrH7Ndi5CX+2JLqjsL5A@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geert,

Thanks for feedback and testing!

On 2016-12-13 14:03:52 +0100, Geert Uytterhoeven wrote:
> CC linux-pm

I think you forgot to CC linux-pm :-)

> 
> On Mon, Dec 12, 2016 at 5:09 PM, Niklas Söderlund
> <niklas.soderlund+renesas@ragnatech.se> wrote:
> > Add generic functionality to support Wake-on-Lan using MagicPacket which
> > are supported by at least a few versions of sh_eth. Only add
> > functionality for WoL, no specific sh_eth version are marked to support
> > WoL yet.
> >
> > WoL is enabled in the suspend callback by setting MagicPacket detection
> > and disabling all interrupts expect MagicPacket. In the resume path the
> > driver needs to reset the hardware to rearm the WoL logic, this prevents
> > the driver from simply restoring the registers and to take advantage of
> > that sh_eth was not suspended to reduce resume time. To reset the
> > hardware the driver close and reopens the device just like it would do
> > in a normal suspend/resume scenario without WoL enabled, but it both
> > close and open the device in the resume callback since the device needs
> > to be open for WoL to work.
> >
> > One quirk needed for WoL is that the module clock needs to be prevented
> > from being switched off by Runtime PM. To keep the clock alive the
> > suspend callback need to call clk_enable() directly to increase the
> > usage count of the clock. Then when Runtime PM decreases the clock usage
> > count it won't reach 0 and be switched off.
> >
> > Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> 
> Thanks for the update!
> 
> I've verified WoL is working on r8a7791/koelsch and r8a7740/armadillo.
> 
> However, if I look at /sys/kernel/debug/wakeup_sources, "active_count" and
> "event_count" for the Ethernet device do not increase when using WoL, while
> they do for the GPIO keyboard when using the keyboard for wake up.
> So something seems to be missing from a bookkeeping point of view.

Cool, now I know why some net drivers call pm_wakeup_event() if the 
wakeup source was WoL :-) I added this to sh_eth and now the bookkeeping 
seems to work as you describe, "active_count" and "event_count" are 
incremented while waking up from WoL. I will include this in the next 
version, thanks for reporting I had no idea to check for this.

> 
> Interestingly, "wakeup_count" does not increase for both?
> Has this been broken recently?

I had a quick look at this and the 'wakeup_count' is increased in 
wakeup_source_report_event() which is in the call path from 
pm_wakeup_event().

pm_wakeup_event()
  __pm_wakeup_event()
    wakeup_source_report_event()

static void wakeup_source_report_event(struct wakeup_source *ws) 
{
        ws->event_count++;
        /* This is racy, but the counter is approximate anyway. */
        if (events_check_enabled)
                ws->wakeup_count++;

        if (!ws->active)
                wakeup_source_activate(ws);
}

So maybe 'wakeup_count' is not incremented due to the race with 
events_check_enabled? But then again I'm new to PM so I might miss 
something obvious. I'm also not sure if I can do anything in this series 
to improve the behavior of 'wakeup_count' for sh_eth?

> 
> > ---
> >  drivers/net/ethernet/renesas/sh_eth.c | 112 +++++++++++++++++++++++++++++++---
> >  drivers/net/ethernet/renesas/sh_eth.h |   3 +
> >  2 files changed, 107 insertions(+), 8 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> > index 05b0dc5..87640b9 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> > @@ -2199,6 +2199,33 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
> >         return 0;
> >  }
> >
> > +static void sh_eth_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
> > +{
> > +       struct sh_eth_private *mdp = netdev_priv(ndev);
> > +
> > +       wol->supported = 0;
> > +       wol->wolopts = 0;
> > +
> > +       if (mdp->cd->magic && mdp->clk) {
> > +               wol->supported = WAKE_MAGIC;
> > +               wol->wolopts = mdp->wol_enabled ? WAKE_MAGIC : 0;
> > +       }
> > +}
> > +
> > +static int sh_eth_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
> > +{
> > +       struct sh_eth_private *mdp = netdev_priv(ndev);
> > +
> > +       if (!mdp->cd->magic || !mdp->clk || wol->wolopts & ~WAKE_MAGIC)
> > +               return -EOPNOTSUPP;
> > +
> > +       mdp->wol_enabled = !!(wol->wolopts & WAKE_MAGIC);
> > +
> > +       device_set_wakeup_enable(&mdp->pdev->dev, mdp->wol_enabled);
> > +
> > +       return 0;
> > +}
> > +
> >  static const struct ethtool_ops sh_eth_ethtool_ops = {
> >         .get_regs_len   = sh_eth_get_regs_len,
> >         .get_regs       = sh_eth_get_regs,
> > @@ -2213,6 +2240,8 @@ static const struct ethtool_ops sh_eth_ethtool_ops = {
> >         .set_ringparam  = sh_eth_set_ringparam,
> >         .get_link_ksettings = sh_eth_get_link_ksettings,
> >         .set_link_ksettings = sh_eth_set_link_ksettings,
> > +       .get_wol        = sh_eth_get_wol,
> > +       .set_wol        = sh_eth_set_wol,
> >  };
> >
> >  /* network device open function */
> > @@ -3017,6 +3046,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
> >                 goto out_release;
> >         }
> >
> > +       /* Get clock, if not found that's OK but Wake-On-Lan is unavailable */
> > +       mdp->clk = devm_clk_get(&pdev->dev, NULL);
> > +       if (IS_ERR(mdp->clk))
> > +               mdp->clk = NULL;
> > +
> >         ndev->base_addr = res->start;
> >
> >         spin_lock_init(&mdp->lock);
> > @@ -3111,6 +3145,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
> >         if (ret)
> >                 goto out_napi_del;
> >
> > +       if (mdp->cd->magic && mdp->clk)
> > +               device_set_wakeup_capable(&pdev->dev, 1);
> > +
> >         /* print device information */
> >         netdev_info(ndev, "Base address at 0x%x, %pM, IRQ %d.\n",
> >                     (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
> > @@ -3150,15 +3187,67 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
> >
> >  #ifdef CONFIG_PM
> >  #ifdef CONFIG_PM_SLEEP
> > +static int sh_eth_wol_setup(struct net_device *ndev)
> > +{
> > +       struct sh_eth_private *mdp = netdev_priv(ndev);
> > +
> > +       /* Only allow ECI interrupts */
> > +       synchronize_irq(ndev->irq);
> > +       napi_disable(&mdp->napi);
> > +       sh_eth_write(ndev, DMAC_M_ECI, EESIPR);
> > +
> > +       /* Enable MagicPacket */
> > +       sh_eth_modify(ndev, ECMR, 0, ECMR_PMDE);
> > +
> > +       /* Increased clock usage so device won't be suspended */
> > +       clk_enable(mdp->clk);
> > +
> > +       return enable_irq_wake(ndev->irq);
> > +}
> > +
> > +static int sh_eth_wol_restore(struct net_device *ndev)
> > +{
> > +       struct sh_eth_private *mdp = netdev_priv(ndev);
> > +       int ret;
> > +
> > +       napi_enable(&mdp->napi);
> > +
> > +       /* Disable MagicPacket */
> > +       sh_eth_modify(ndev, ECMR, ECMR_PMDE, 0);
> > +
> > +       /* The device need to be reset to restore MagicPacket logic
> > +        * for next wakeup. If we close and open the device it will
> > +        * both be reset and all registers restored. This is what
> > +        * happens during suspend and resume without WoL enabled.
> > +        */
> > +       ret = sh_eth_close(ndev);
> > +       if (ret < 0)
> > +               return ret;
> > +       ret = sh_eth_open(ndev);
> > +       if (ret < 0)
> > +               return ret;
> > +
> > +       /* Restore clock usage count */
> > +       clk_disable(mdp->clk);
> > +
> > +       return disable_irq_wake(ndev->irq);
> > +}
> > +
> >  static int sh_eth_suspend(struct device *dev)
> >  {
> >         struct net_device *ndev = dev_get_drvdata(dev);
> > +       struct sh_eth_private *mdp = netdev_priv(ndev);
> >         int ret = 0;
> >
> > -       if (netif_running(ndev)) {
> > -               netif_device_detach(ndev);
> > +       if (!netif_running(ndev))
> > +               return 0;
> > +
> > +       netif_device_detach(ndev);
> > +
> > +       if (mdp->wol_enabled)
> > +               ret = sh_eth_wol_setup(ndev);
> > +       else
> >                 ret = sh_eth_close(ndev);
> > -       }
> >
> >         return ret;
> >  }
> > @@ -3166,14 +3255,21 @@ static int sh_eth_suspend(struct device *dev)
> >  static int sh_eth_resume(struct device *dev)
> >  {
> >         struct net_device *ndev = dev_get_drvdata(dev);
> > +       struct sh_eth_private *mdp = netdev_priv(ndev);
> >         int ret = 0;
> >
> > -       if (netif_running(ndev)) {
> > +       if (!netif_running(ndev))
> > +               return 0;
> > +
> > +       if (mdp->wol_enabled)
> > +               ret = sh_eth_wol_restore(ndev);
> > +       else
> >                 ret = sh_eth_open(ndev);
> > -               if (ret < 0)
> > -                       return ret;
> > -               netif_device_attach(ndev);
> > -       }
> > +
> > +       if (ret < 0)
> > +               return ret;
> > +
> > +       netif_device_attach(ndev);
> >
> >         return ret;
> >  }
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> > index d050f37..4ceed00 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.h
> > +++ b/drivers/net/ethernet/renesas/sh_eth.h
> > @@ -493,6 +493,7 @@ struct sh_eth_cpu_data {
> >         unsigned shift_rd0:1;   /* shift Rx descriptor word 0 right by 16 */
> >         unsigned rmiimode:1;    /* EtherC has RMIIMODE register */
> >         unsigned rtrate:1;      /* EtherC has RTRATE register */
> > +       unsigned magic:1;       /* EtherC has ECMR.PMDE and ECSR.MPD */
> >  };
> >
> >  struct sh_eth_private {
> > @@ -501,6 +502,7 @@ struct sh_eth_private {
> >         const u16 *reg_offset;
> >         void __iomem *addr;
> >         void __iomem *tsu_addr;
> > +       struct clk *clk;
> >         u32 num_rx_ring;
> >         u32 num_tx_ring;
> >         dma_addr_t rx_desc_dma;
> > @@ -529,6 +531,7 @@ struct sh_eth_private {
> >         unsigned no_ether_link:1;
> >         unsigned ether_link_active_low:1;
> >         unsigned is_opened:1;
> > +       unsigned wol_enabled:1;
> >  };
> >
> >  static inline void sh_eth_soft_swap(char *src, int len)
> > --
> > 2.10.2
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds

-- 
Regards,
Niklas Söderlund
