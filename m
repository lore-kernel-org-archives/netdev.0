From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [e1000_netpoll] BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Thu, 28 Jul 2016 12:19:58 +0200
Message-ID: <20160728101958.GA26846@bistromath.localdomain>
References: <20160726035003.GA15095@wfg-t540p.sh.intel.com>
 <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <1469655487.2232.49.camel@intel.com>
 <1469684635.9389.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Satyam Sharma <satyam@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	intel-wired-lan@lists.osuosl.org,
	Ye Xiaolong <xiaolong.ye@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1469684635.9389.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-07-28, 07:43:55 +0200, Eric Dumazet wrote:
> On Wed, 2016-07-27 at 14:38 -0700, Jeff Kirsher wrote:
> > On Tue, 2016-07-26 at 11:14 +0200, Eric Dumazet wrote:
> > > Could you try this ?
> > > 
> > > diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c
> > > b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > > index
> > > f42129d09e2c23ba9fdb5cde890d50ecb7166a42..a53c41c4c4f7d1fe52f95a2cab8784a
> > > 938b3820b 100644
> > > --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> > > +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > > @@ -5257,9 +5257,13 @@ static void e1000_netpoll(struct net_device
> > > *netdev)
> > >  {
> > >         struct e1000_adapter *adapter = netdev_priv(netdev);
> > >  
> > > -       disable_irq(adapter->pdev->irq);
> > > -       e1000_intr(adapter->pdev->irq, netdev);
> > > -       enable_irq(adapter->pdev->irq);
> > > +       if (napi_schedule_prep(&adapter->napi)) {
> > > +               adapter->total_tx_bytes = 0;
> > > +               adapter->total_tx_packets = 0;
> > > +               adapter->total_rx_bytes = 0;
> > > +               adapter->total_rx_packets = 0;
> > > +               __napi_schedule(&adapter->napi);
> > > +       }
> > >  }
> > >  #endif
> > >  
> > 
> > Since this fixes the issue Fengguang saw, will you be submitting a formal
> > patch Eric? (please) I can get this queued up for Dave's net tree as soon
> > as I receive the formal patch.
> 
> I would prefer having a definitive advice from Thomas Gleixner and/or
> others if disable_irq() is forbidden from IRQ path.
> 
> As I said, about all netpoll() methods in net drivers use disable_irq()
> so a lot of patches would be needed.
> 
> disable_irq() should then test this condition earlier, so that we can
> detect potential bug, even if the IRQ is not (yet) threaded.

The idea when this first came up was to skip the sleeping part of
disable_irq():

http://marc.info/?l=linux-netdev&m=142314159626052

This fell off my todolist and I didn't send the conversion patches,
which would basically look like this:


diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 41f32c0b341e..b022691e680b 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6713,20 +6713,20 @@ static irqreturn_t e1000_intr_msix(int __always_unused irq, void *data)
 
 		vector = 0;
 		msix_irq = adapter->msix_entries[vector].vector;
-		disable_irq(msix_irq);
-		e1000_intr_msix_rx(msix_irq, netdev);
+		if (disable_hardirq(msix_irq))
+			e1000_intr_msix_rx(msix_irq, netdev);
 		enable_irq(msix_irq);
 
 		vector++;
 		msix_irq = adapter->msix_entries[vector].vector;
-		disable_irq(msix_irq);
-		e1000_intr_msix_tx(msix_irq, netdev);
+		if (disable_hardirq(msix_irq))
+			e1000_intr_msix_tx(msix_irq, netdev);
 		enable_irq(msix_irq);
 
 		vector++;
 		msix_irq = adapter->msix_entries[vector].vector;
-		disable_irq(msix_irq);
-		e1000_msix_other(msix_irq, netdev);
+		if (disable_hardirq(msix_irq))
+			e1000_msix_other(msix_irq, netdev);
 		enable_irq(msix_irq);
 	}
 
@@ -6750,13 +6750,13 @@ static void e1000_netpoll(struct net_device *netdev)
 		e1000_intr_msix(adapter->pdev->irq, netdev);
 		break;
 	case E1000E_INT_MODE_MSI:
-		disable_irq(adapter->pdev->irq);
-		e1000_intr_msi(adapter->pdev->irq, netdev);
+		if (disable_hardirq(adapter->pdev->irq))
+			e1000_intr_msi(adapter->pdev->irq, netdev);
 		enable_irq(adapter->pdev->irq);
 		break;
 	default:		/* E1000E_INT_MODE_LEGACY */
-		disable_irq(adapter->pdev->irq);
-		e1000_intr(adapter->pdev->irq, netdev);
+		if (disable_hardirq(adapter->pdev->irq))
+			e1000_intr(adapter->pdev->irq, netdev);
 		enable_irq(adapter->pdev->irq);
 		break;
 	}


-- 
Sabrina
