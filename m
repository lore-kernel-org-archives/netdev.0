From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] e1000: the power down when running ifdown
	command
Date: Mon, 02 Nov 2009 16:56:33 -0800
Message-ID: <1257209793.18754.4.camel@localhost.localdomain>
References: <4AEC05E8.40600@miraclelinux.com>
	<9929d2390911021626j4a2e4a96neaba49ffd8775dc9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Naohiro Ooiwa <nooiwa@miraclelinux.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Andrew Morton <akpm@linux-foundation.org>,
	svaidy@linux.vnet.ibm.com, davem@davemloft.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9929d2390911021626j4a2e4a96neaba49ffd8775dc9@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2009-11-02 at 16:26 -0800, Jeff Kirsher wrote:
> 2009/10/31 Naohiro Ooiwa <nooiwa@miraclelinux.com>:
> > Hi All
> >
> > I resend my patch.
> > Sorry, my previous mail lacked an explanation.
> >
> >
> > The e1000 driver doesn't let the power down when running ifdown command.
> > So, I set to the D3hot state of a PCI device at the end of e1000_close().
> >
> > With this modification, e1000 driver reduces power by ifdown.
> > It's about 6 watts when I measured a total power of one server machine
> > in my environment.
> >
> > I tested this patch. The result is good enough to me.
> >
> > Could you please check my patch ?
> > If I should have other considerations, please tell me.
> >
> >
> > Thanks you.
> > Naohiro Ooiwa
> >
> >
> >
> > Signed-off-by: Naohiro Ooiwa <nooiwa@miraclelinux.com>
> > ---
> >  drivers/net/e1000/e1000_main.c |   32 ++++++++++++++++++++++++++++++++
> >  1 files changed, 32 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> > index bcd192c..12e1a42 100644
> > --- a/drivers/net/e1000/e1000_main.c
> > +++ b/drivers/net/e1000/e1000_main.c
> > @@ -26,6 +26,11 @@
> >
> >  *******************************************************************************/
> >
> > +/*
> > + * define this if you want pci save power while ifdown.
> > + */
> > +#define E1000_PCI_POWER_SAVE
> > +
> >  #include "e1000.h"
> >  #include <net/ip6_checksum.h>
> >
> > @@ -1248,6 +1253,23 @@ static int e1000_open(struct net_device *netdev)
> >        struct e1000_hw *hw = &adapter->hw;
> >        int err;
> >
> > +#ifdef E1000_PCI_POWER_SAVE
> > +       struct pci_dev *pdev = adapter->pdev;
> > +
> > +       pci_set_power_state(pdev, PCI_D0);
> > +       pci_restore_state(pdev);
> > +
> > +       if (adapter->need_ioport)
> > +               err = pci_enable_device(pdev);
> > +       else
> > +               err = pci_enable_device_mem(pdev);
> > +       if (err) {
> > +               printk(KERN_ERR "e1000: Cannot enable PCI device from power-save\n");
> > +               return err;
> > +       }
> > +       pci_set_master(pdev);
> > +#endif
> > +
> >        /* disallow open during test */
> >        if (test_bit(__E1000_TESTING, &adapter->flags))
> >                return -EBUSY;
> > @@ -1265,6 +1287,7 @@ static int e1000_open(struct net_device *netdev)
> >                goto err_setup_rx;
> >
> >        e1000_power_up_phy(adapter);
> > +       e1000_reset(adapter);
> >
> >        adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
> >        if ((hw->mng_cookie.status &
> > @@ -1341,6 +1364,15 @@ static int e1000_close(struct net_device *netdev)
> >                e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
> >        }
> >
> > +#ifdef E1000_PCI_POWER_SAVE
> > +#ifdef CONFIG_PM
> > +       pci_save_state(adapter->pdev);
> > +#endif
> > +       pci_disable_device(adapter->pdev);
> > +       pci_wake_from_d3(adapter->pdev, true);
> > +       pci_set_power_state(adapter->pdev, PCI_D3hot);
> > +#endif
> > +
> >        return 0;
> >  }
> >
> 
> I have added this patch to my tree for testing.  This patch requires a
> fair amount of regression testing, so once its passed testing I will
> push the patch to David/netdev.

Can we get rid of E1000_PCI_POWER_SAVE and just enable this
unconditionally once it's baked?  Having the define there is pretty
superfluous right now.  Either that, or make it
CONFIG_E1000_PCI_POWER_SAVE and make a Kconfig option for it that
depends on experimental or something.  Or a module parameter.  Or
something other than a dangling #define :)

Dan



------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
