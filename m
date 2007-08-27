From: David Miller <davem@davemloft.net>
Subject: Re: [E1000-devel] [PATCH net-2.6.24] e100: fix driver init lockup
 on e100_up()
Date: Mon, 27 Aug 2007 14:18:13 -0700 (PDT)
Message-ID: <20070827.141813.115913906.davem@davemloft.net>
References: <200708271706.l7RH6wT0024567@quickie.katalix.com>
	<46D3055F.5060201@intel.com>
	<46D33C13.7060605@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40343
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753008AbXH0VSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 17:18:15 -0400
In-Reply-To: <46D33C13.7060605@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Mon, 27 Aug 2007 22:03:15 +0100

> Kok, Auke wrote:
> > James Chapman wrote:
> >>      nic = netdev_priv(netdev);
> >> -    netif_napi_add(netdev, &nic->napi, e100_poll, E100_NAPI_WEIGHT);
> >>      nic->netdev = netdev;
> >>      nic->pdev = pdev;
> >>      nic->msg_enable = (1 << debug) - 1;
> >>      pci_set_drvdata(pdev, netdev);
> >> +    netif_napi_add(netdev, &nic->napi, e100_poll, E100_NAPI_WEIGHT);
> >> +    napi_disable(&nic->napi);
> > 
> > Just wondering, could we even reverse this order? IOW disable NAPI 
> > first, then add it ?
> 
> I think the order shouldn't matter. DaveM?

It doesn't matter.

I'm beginning to think maybe we should do an implicit napi_disable()
in netif_napi_add(), then it's easier for drivers to play nice.

On open you do napi_enable(), in close you do napi_disable().
That's it.

And anywhere else in your driver that you have to napi_disable()
(suspend, recovering from hardware errors, etc.) you must be sure to
do the associated napi_enable() later on in order to keep things
balanced.
