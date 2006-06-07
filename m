From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Wed, 7 Jun 2006 14:54:44 -0400
Message-ID: <20060607185440.GC26702@tuxdriver.com>
References: <1149611965.13635.19.camel@strongmad> <20060606170513.GB21969@hmsreliant.homelinux.net> <4485B8EC.4090603@intel.com> <x494pyyw5sr.fsf@segfault.boston.redhat.com> <4485BCA2.5070904@intel.com> <x49zmgquqn0.fsf@segfault.boston.redhat.com> <20060606231727.GK24227@waste.org> <20060607150522.GA24608@hmsreliant.homelinux.net> <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, "Garzik, Jeff" <jgarzik@pobox.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:26886 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932228AbWFGS4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 14:56:55 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <44871A19.7080805@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2006 at 11:25:29AM -0700, Auke Kok wrote:

> @@ -4584,10 +4584,25 @@ static void
>  e1000_netpoll(struct net_device *netdev)
>  {
>         struct e1000_adapter *adapter = netdev_priv(netdev);
> +#ifdef CONFIG_E1000_NAPI
> +       int budget = 0;
> +
> +       disable_irq(adapter->pdev->irq);
> +       if (likely(netif_rx_schedule_prep(&adapter->polling_netdev[0]))) {
> +               if (spin_trylock(&adapter->tx_queue_lock)) {
> +                       e1000_clean_tx_irq(adapter, &adapter->tx_ring[0]);
> +                       spin_unlock(&adapter->tx_queue_lock);
> +               }
> +               adapter->clean_rx(adapter, adapter->rx_ring,
> +                               &budget, netdev->weight);
> +               clear_bit(__LINK_STATE_RX_SCHED,
> +                               &adapter->polling_netdev[0].state);
> +       }
> +#else
> +
>         disable_irq(adapter->pdev->irq);

Pedantic objection, but I think this would read easier w/o the extra
newline before disable_irq.

John
-- 
John W. Linville
linville@tuxdriver.com
