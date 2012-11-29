From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Thu, 29 Nov 2012 11:57:15 +0100
Message-ID: <20121129105715.GA10226@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
 <1354141115.21562.101.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354141115.21562.101.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2012 at 10:18:35PM +0000, David Woodhouse wrote:
> On Wed, 2012-11-28 at 09:21 +0000, David Laight wrote:
> > Even when it might make sense to sleep in close until tx drains
> > there needs to be a finite timeout before it become abortive.
> 
> You are, of course, right. We should never wait for hardware for ever.
> And just to serve me right, I seem to have hit a bug in the latest Solos
> firmware (1.11) which makes it sometimes lock up when I reboot. So it
> never responds to the PKT_PCLOSE packet... and thus it deadlocks when I
> try to kill pppd and unload the module to reset it :)
> 
> New version...
> 
> From 53dd01c08fec5b26006a009b25e4210127fdb27a Mon Sep 17 00:00:00 2001
> From: David Woodhouse <David.Woodhouse@intel.com>
> Date: Tue, 27 Nov 2012 23:49:24 +0000
> Subject: [PATCH] solos-pci: Wait for pending TX to complete when releasing
>  vcc
> 
> We should no longer be calling the old pop routine for the vcc, after
> vcc_release() has completed. Make sure we wait for any pending TX skbs
> to complete, by waiting for our own PKT_PCLOSE control skb to be sent.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> ---
>  drivers/atm/solos-pci.c | 17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
> index 9851093..3720670 100644
> --- a/drivers/atm/solos-pci.c
> +++ b/drivers/atm/solos-pci.c
> @@ -92,6 +92,7 @@ struct pkt_hdr {
>  };
>  
>  struct solos_skb_cb {
> +	struct completion c;
>  	struct atm_vcc *vcc;
>  	uint32_t dma_addr;
>  };
> @@ -881,11 +882,18 @@ static void pclose(struct atm_vcc *vcc)
>  	header->vci = cpu_to_le16(vcc->vci);
>  	header->type = cpu_to_le16(PKT_PCLOSE);
>  
> +	init_completion(&SKB_CB(skb)->c);
> +
>  	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, NULL);
>  
>  	clear_bit(ATM_VF_ADDR, &vcc->flags);
>  	clear_bit(ATM_VF_READY, &vcc->flags);
>  
> +	if (!wait_for_completion_timeout(&SKB_CB(skb)->c,
> +					 jiffies + msecs_to_jiffies(5000)))
> +		dev_warn(&card->dev->dev, "Timeout waiting for VCC close on port %d\n",
> +			 SOLOS_CHAN(vcc->dev));
> +

do we really need to wait here?

Why don't just do something like that:

	tasklet_disable(&card->tlet);
	spin_lock(&card->tx_queue_lock);
	for each skb in queue
		SKB_CB(skb)->vcc = NULL;
	spin_unlock(&card->tx_queue_lock);
	tasklet_enable(&card->tlet);

or if we really want to call vcc->pop() for such skbs:

	tasklet_disable(&card->tlet);
	spin_lock(&card->tx_queue_lock);
	for each skb in queue {
		skb_get(skb);
		solos_pop(SKB_CB(skb)->vcc, skb);
		SKB_CB(skb)->vcc = NULL;
	}
	spin_unlock(&card->tx_queue_lock);
	tasklet_enable(&card->tlet);

Krzysiek
