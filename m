From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [PATCH] Wireless / ath5k: Simplify suspend and
	resume callbacks
Date: Mon, 5 Oct 2009 21:40:47 +0200
Message-ID: <200910052140.47372.rjw@sisk.pl>
References: <200910050052.09085.rjw@sisk.pl>
	<43e72e890910050921q7f516c67ofe17603d6d873c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org, "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	pm list <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
In-Reply-To: <43e72e890910050921q7f516c67ofe17603d6d873c4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 05 October 2009, Luis R. Rodriguez wrote:
> On Sun, Oct 4, 2009 at 10:52 PM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> > From: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> >
> > Simplify the suspend and resume callbacks of ath5k by converting the
> > driver to struct dev_pm_ops and allowing the PCI PM core to do the
> > PCI-specific suspend/resume handling.
> >
> > Signed-off-by: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> 
> Do you happen to know if the new dev_pm_ops thing handle WOL / WoW [1]?
> 
> [1] http://wireless.kernel.org/en/users/Documentation/WoW

It does enable wake-up at the PCI level if so configured, so in principle it
should handle it.  However, for WoL to work there are some things that the
drivers is reponsible for, so I guess it will be analogous for WoW.

Anyway, the PCI-specific mechanics is there.

> >  #ifdef CONFIG_PM
> > -static int
> > -ath5k_pci_suspend(struct pci_dev *pdev, pm_message_t state)
> > +static int ath5k_pci_suspend(struct device *dev)
> >  {
> > -       struct ieee80211_hw *hw = pci_get_drvdata(pdev);
> > +       struct ieee80211_hw *hw = pci_get_drvdata(to_pci_dev(dev));
> >        struct ath5k_softc *sc = hw->priv;
> >
> >        ath5k_led_off(sc);
> > -
> > -       pci_save_state(pdev);
> > -       pci_disable_device(pdev);
> 
> For WoW right here we'd do
> 
> pci_prepare_to_sleep(pdev) and bail out.
> 
> > -       pci_set_power_state(pdev, PCI_D3hot);
> 
> And here we'd call something like this:
> 
> pci_wake_from_d3(pdev, !!sc->wow_triggers_enabled);

All of this is unnecessary, the PCI PM core should take care of this just
fine.  In case it doesn't, it has to be fixed.

> > -
> >        return 0;
> >  }
> 
> Are all drivers being converted?

Generally, yes, but that's not a priority work for me.  I've just happened to
have the patch ready, so here it goes.

They should be converted, though, to be able to support PCI run-time PM.

> It'll be a while before we get WoW enabled on ath5k but it is
> technically possible, the work was tested for ath9k back in July [2]
> but I never submitted this to be merged due to some inconsistent
> issues I was noticing with the hardware.
> 
> [2] http://kernel.org/pub/linux/kernel/people/mcgrof/patches/wow-07-21.patch

Thanks,
Rafael
