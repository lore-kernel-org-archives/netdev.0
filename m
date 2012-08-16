From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: turn off the network statck during
 initialization
Date: Thu, 16 Aug 2012 11:57:11 -0700
Message-ID: <1345143431.6916.36.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1345141295-7589-1-git-send-email-Jiang.Wang@riverbed.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	clala@riverbed.com, Francis.St.Amant@riverbed.com,
	"Jiang Wang" <jwang@riverbed.com>
To: "Jiang Wang" <Jiang.Wang@riverbed.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345141295-7589-1-git-send-email-Jiang.Wang@riverbed.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-16 at 11:21 -0700, Jiang Wang wrote: 
> The initialization state of bnx2 driver is wrong. It does not turn
> of the Linux network stack using netif_carrier_off. This may lead to
> inconsistent report from ethtool as the link is up but speed is
> unknown when the cable is not plugged in.
> 
> E.g.
>         Speed: Unknown! (0)<--------------------------------------
>         Duplex: Half       <--------------------------------------
>         MDI: Unknown! (0)
>         Port: Twisted Pair
>         PHYAD: 1
>         Transceiver: internal
>         Auto-negotiation: on
>         Supports Wake-on: g
>         Wake-on: d
>         Link detected: yes <---------------------------------------
> 
> This patches fixed the problem by turning off the network stack
> during initialization.
> 
> Signed-off-by: Jiang Wang <jwang@riverbed.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index ac7b744..ce4548d 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -8463,6 +8463,10 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	dev->features |= dev->hw_features;
>  	dev->priv_flags |= IFF_UNICAST_FLT;
>  
> +	/* tell the stack to leave us alone until bnx2_open() is called */
> +	netif_carrier_off(dev);

We have tried this before and this didn't work.  netif_carrier_off()
calls linkwatch_fire_event() to schedule the event.  If
register_netdev() fails for whatever reason, the netdev will be freed
but the link_watch event may still be scheduled.

Calling netif_carrier_off() after register_netdev() returns successfully
also may not work as it will race with bnx2_open() which enables IRQ.
An linkup IRQ can happen at time and we may end up with the wrong
carrier state because of the race condition.

> +	netif_stop_queue(dev);
> +
>  	if ((rc = register_netdev(dev))) {
>  		dev_err(&pdev->dev, "Cannot register net device\n");
>  		goto error;
