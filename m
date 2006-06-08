From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Thu, 08 Jun 2006 10:19:34 -0700
Message-ID: <1149787174.2928.3.camel@strongmad>
References: <20060605231125.12584.17039.stgit@gitlost.site>
	 <20060606135217.GA21969@hmsreliant.homelinux.net>
	 <1149611965.13635.19.camel@strongmad>
	 <20060606170513.GB21969@hmsreliant.homelinux.net>
	 <4485B8EC.4090603@intel.com><x494pyyw5sr.fsf@segfault.boston.redhat.com>
	 <4485BCA2.5070904@intel.com><x49zmgquqn0.fsf@segfault.boston.redhat.com>
	 <20060606231727.GK24227@waste.org>
	 <20060607150522.GA24608@hmsreliant.homelinux.net>
	 <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com>
	 <x49d5dkvm8p.fsf@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12879 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S964872AbWFHRT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 13:19:56 -0400
To: Jeff Moyer <jmoyer@redhat.com>
In-Reply-To: <x49d5dkvm8p.fsf@segfault.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-07 at 11:44 -0700, Jeff Moyer wrote:

> That patch locks around the tx clean routine.  As such, it doesn't
> prevent
> the problem.

The call to netif_rx_schedule_prep provides locking because it sets the
__LINK_STATE_RX_SCHED bit atomically.  The spinlock around
e1000_clean_tx_irq is to protect it from other calls to the transmit
routine, not NAPI.

-Mitch

> > +     disable_irq(adapter->pdev->irq);
> > +     if
> (likely(netif_rx_schedule_prep(&adapter->polling_netdev[0]))) {
> > +             if (spin_trylock(&adapter->tx_queue_lock)) {
> > +                     e1000_clean_tx_irq(adapter,
> &adapter->tx_ring[0]);
> > +                     spin_unlock(&adapter->tx_queue_lock);
> > +             }
> > +             adapter->clean_rx(adapter, adapter->rx_ring,
> > +                             &budget, netdev->weight);
> > +             clear_bit(__LINK_STATE_RX_SCHED,
> > +                             &adapter->polling_netdev[0].state);
> 
> -Jeff
> 
> 
