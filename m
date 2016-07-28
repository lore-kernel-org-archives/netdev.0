From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [e1000_netpoll] BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Thu, 28 Jul 2016 07:43:55 +0200
Message-ID: <1469684635.9389.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160726035003.GA15095@wfg-t540p.sh.intel.com>
	 <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1469655487.2232.49.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Satyam Sharma <satyam@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	intel-wired-lan@lists.osuosl.org,
	Ye Xiaolong <xiaolong.ye@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32819 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbcG1FoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 01:44:00 -0400
In-Reply-To: <1469655487.2232.49.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-07-27 at 14:38 -0700, Jeff Kirsher wrote:
> On Tue, 2016-07-26 at 11:14 +0200, Eric Dumazet wrote:
> > Could you try this ?
> > 
> > diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c
> > b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > index
> > f42129d09e2c23ba9fdb5cde890d50ecb7166a42..a53c41c4c4f7d1fe52f95a2cab8784a
> > 938b3820b 100644
> > --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> > +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > @@ -5257,9 +5257,13 @@ static void e1000_netpoll(struct net_device
> > *netdev)
> >  {
> >         struct e1000_adapter *adapter = netdev_priv(netdev);
> >  
> > -       disable_irq(adapter->pdev->irq);
> > -       e1000_intr(adapter->pdev->irq, netdev);
> > -       enable_irq(adapter->pdev->irq);
> > +       if (napi_schedule_prep(&adapter->napi)) {
> > +               adapter->total_tx_bytes = 0;
> > +               adapter->total_tx_packets = 0;
> > +               adapter->total_rx_bytes = 0;
> > +               adapter->total_rx_packets = 0;
> > +               __napi_schedule(&adapter->napi);
> > +       }
> >  }
> >  #endif
> >  
> 
> Since this fixes the issue Fengguang saw, will you be submitting a formal
> patch Eric? (please) I can get this queued up for Dave's net tree as soon
> as I receive the formal patch.

I would prefer having a definitive advice from Thomas Gleixner and/or
others if disable_irq() is forbidden from IRQ path.

As I said, about all netpoll() methods in net drivers use disable_irq()
so a lot of patches would be needed.

disable_irq() should then test this condition earlier, so that we can
detect potential bug, even if the IRQ is not (yet) threaded.

Thanks.
