From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [PATCH] Make e100 suspend handler support PCI
	cards lacking PM	capability
Date: Sun, 14 Jun 2009 18:46:04 +0200
Message-ID: <20090614164604.GA19746@rhlx01.hs-esslingen.de>
References: <20081229102515.GA17171@rhlx01.hs-esslingen.de>
	<200906140028.16025.rjw@sisk.pl>
	<20090614125128.GA32034@rhlx01.hs-esslingen.de>
	<200906141606.29754.rjw@sisk.pl>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org, andi@lisas.de
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <200906141606.29754.rjw@sisk.pl>
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

On Sun, Jun 14, 2009 at 04:06:29PM +0200, Rafael J. Wysocki wrote:
> On Sunday 14 June 2009, Andreas Mohr wrote:
> > Hi,
> > 
> > On Sun, Jun 14, 2009 at 12:28:15AM +0200, Rafael J. Wysocki wrote:
> > > On Saturday 13 June 2009, Andreas Mohr wrote:
> > > > +
> > > >  	if (wake) {
> > > >  		return pci_prepare_to_sleep(pdev);
> > > 
> > > pci_prepare_to_sleep() is supposed to return 0 for your device.  I'll have a
> > > look at it.
> > 
> > No, wake is false for my card, thus that's not the branch to
> > investigate.
> 
> Ah.  The problem is, then, that we try to put the device into D3, which it
> cannot do and error code is correctly returned from pci_set_power_state().
> 
> I would use the appended patch in that case and the patch sent previously
> is necessary for the 'wake = true' case.

OK, as said I cannot test this right now, but I'm _damn_ sure it would
work. Thus I'd say your equivalent patch posted a bit later can be
committed already.

But what about the wake = true case?
I'm not affected by this since my card doesn't have any wake capa,
thus it's your call of whether that pci core code part really was broken
and needed fixing.

So, for the patch in your next mail:
Acked-by: Andreas Mohr <andi@lisas.de>


BTW, that patch was (pasted):

 static int __e100_power_off(struct pci_dev *pdev, bool wake)
 {
-       if (wake) {
+       if (wake)
                return pci_prepare_to_sleep(pdev);
-       } else {
-               pci_wake_from_d3(pdev, false);
-               return pci_set_power_state(pdev, PCI_D3hot);
-       }
+
+       pci_wake_from_d3(pdev, false);
+       pci_set_power_state(pdev, PCI_D3hot);
+
+       return 0;
 }


Couple questions still:
- why do we call pci_wake_from_d3(...false) only!?
  Wouldn't this break WoL after one iteration back and forth,
  due to missing 'true' case?
- why do we call netif_device_detach() _after_ doing hardware shutdown
  of the network controller? I'd guess this can cause huge issues?
  Someone told me he had rtnl lock issues upon S2D with e100
  (very similar to my rtnl issues during aborted .suspend),
  and that might possibly be the reason?

So few lines of code, so many questions...

Thanks,

Andreas Mohr

------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables unlimited
royalty-free distribution of the report engine for externally facing 
server and web deployment.
http://p.sf.net/sfu/businessobjects
