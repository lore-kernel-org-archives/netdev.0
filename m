From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: e100 kills S2R on my box, plus network drops dead
Date: Wed, 3 Jun 2009 08:30:25 +0200
Message-ID: <20090603063025.GA32600@rhlx01.hs-esslingen.de>
References: <20081228.000118.121541932.davem@davemloft.net>
	<20081229102515.GA17171@rhlx01.hs-esslingen.de>
	<20081229091728.d869f1c1.akpm@linux-foundation.org>
	<9929d2390812291515y623d6a51yed1bef021ab6847e@mail.gmail.com>
	<20081230120756.GA5393@rhlx01.hs-esslingen.de>
	<20090228203757.GA18850@rhlx01.hs-esslingen.de>
	<9929d2390903010257p7c6fb367ga974767605033bc9@mail.gmail.com>
	<20090301212412.GA13210@rhlx01.hs-esslingen.de>
	<20090602214852.GA3095@rhlx01.hs-esslingen.de>
	<20090603060123.GA17558@rhlx01.hs-esslingen.de>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: andi@lisas.de
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20090603060123.GA17558@rhlx01.hs-esslingen.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Jun 03, 2009 at 08:01:23AM +0200, Andreas Mohr wrote:
> IOW, we have _two_ issues:
> 
> - that PM suspend part here doesn't support non-PM PCI cards
> - PM suspend breaks networking stuff (or is that caused by incomplete reinitialization of my card,
>   thus it's not network-suitable after resume and hangs on some network APIs?)
> 
> What to do?
> 
> (I should have provided some SysRq-T(?) lock traces I guess, will record that now)

Those were not too useful methinks, but I can provide them if need be.

> Oh, and I will test whether eepro100 S2R works on that machine, and if
> so what that driver does to avoid trouble.

Well, yes, eepro100 (2.6.28.10) does achieve successful S2R,
and I _do_ have working network even after resume (which is not too astonishing
since it almost takes active measures to NOT make this card work,
given that it's fully auto-configuring on the transceiver side)



static int eepro100_suspend(struct pci_dev *pdev, pm_message_t state)
{
        struct net_device *dev = pci_get_drvdata (pdev);
        struct speedo_private *sp = netdev_priv(dev);
        void __iomem *ioaddr = sp->regs;

        pci_save_state(pdev);

        if (!netif_running(dev))
                return 0;

        del_timer_sync(&sp->timer);

        netif_device_detach(dev);
        iowrite32(PortPartialReset, ioaddr + SCBPort);

        /* XXX call pci_set_power_state ()? */
        pci_disable_device(pdev);
        pci_set_power_state (pdev, PCI_D3hot);
        return 0;
}


That's pretty boring code, linearily executing stuff without checking
results, thus it's unsurprising that it does not prevent suspend
on a non-PM PCI card.


So, what to do to fix those suspend issues on the e100 side of things?
And do we perhaps have similar non-PM PCI card support issues
with other drivers?


Thanks,

Andreas Mohr

------------------------------------------------------------------------------
OpenSolaris 2009.06 is a cutting edge operating system for enterprises 
looking to deploy the next generation of Solaris that includes the latest 
innovations from Sun and the OpenSource community. Download a copy and 
enjoy capabilities such as Networking, Storage and Virtualization. 
Go to: http://p.sf.net/sfu/opensolaris-get
