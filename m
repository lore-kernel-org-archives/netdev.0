From: Ben Dooks <ben@fluff.org>
Subject: Re: [PATCH] DM9000: fix interface hang under load
Date: Thu, 23 Aug 2007 10:37:49 +0100
Message-ID: <20070823093749.GE12547@fluff.org.uk>
References: <20070820233342.GG9315@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:57441 "EHLO
	aeryn.fluff.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755673AbXHWJi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 05:38:27 -0400
Content-Disposition: inline
In-Reply-To: <20070820233342.GG9315@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 21, 2007 at 01:33:42AM +0200, Florian Westphal wrote:
> When transferring data at full speed, the DM9000 network interface
> sometimes stops sending/receiving data. Worse, ksoftirqd consumes
> 100% cpu and the net tx watchdog never triggers.

A newline here would have helped readability.

> Fix by spin_lock_irqsave() in dm9000_start_xmit() to prevent the
> interrupt handler from interfering.

I personally have not come across this during any of our testing,
but it is possible that an ARM9 has slightly different interrupt
behaviour to the PXAs.

Changing to use spin_lock_irqsave() is probably a much safer
way of stopping this happening than trying to disable the
interrupts comming from the chip, and spin_lock_irqsave() is
not exactly expensive. This will also stop dm9000_start_xmit from
being interrupted by the watchdog.

I will update my local DM9000 patch set for after the 2.6.23 release.

> Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Ben Dooks <ben-linux@fluff.org>
> ---
>  Actually the comments ('Disable all interrupts, iow(db, DM9000_IMR, IMR_PAR) etc)
>  give the impression that the interrupt handler cannot run during dm9000_start_xmit(),
>  however this isn't correct (perhaps the chipset has some weird timing issues?).
>  The interface lockup usually occurs between 30 and 360 seconds after starting transmitting
>  data (netcat /dev/zero) at full speed; with this patch applied I haven't been able
>  to reproduce hangs yet (ran for > 2h).
>  FTR: This is a dm9000 on XScale-PXA255 rev 6 (ARMv5TE)/Compulab CM-x255, i.e.
>  a module not supported by the vanilla kernel. Tested on (patched) 2.6.18.
> 
>  dm9000.c |   25 +++++++------------------
>  1 file changed, 7 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index c3de81b..738aa59 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -700,6 +700,7 @@ dm9000_init_dm9000(struct net_device *dev)
>  static int
>  dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
> +	unsigned long flags;
>  	board_info_t *db = (board_info_t *) dev->priv;
>  
>  	PRINTK3("dm9000_start_xmit\n");
> @@ -707,10 +708,7 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (db->tx_pkt_cnt > 1)
>  		return 1;
>  
> -	netif_stop_queue(dev);
> -
> -	/* Disable all interrupts */
> -	iow(db, DM9000_IMR, IMR_PAR);
> +	spin_lock_irqsave(&db->lock, flags);
>  
>  	/* Move data to DM9000 TX RAM */
>  	writeb(DM9000_MWCMD, db->io_addr);
> @@ -718,12 +716,9 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	(db->outblk)(db->io_data, skb->data, skb->len);
>  	db->stats.tx_bytes += skb->len;
>  
> +	db->tx_pkt_cnt++;
>  	/* TX control: First packet immediately send, second packet queue */
> -	if (db->tx_pkt_cnt == 0) {
> -
> -		/* First Packet */
> -		db->tx_pkt_cnt++;
> -
> +	if (db->tx_pkt_cnt == 1) {
>  		/* Set TX length to DM9000 */
>  		iow(db, DM9000_TXPLL, skb->len & 0xff);
>  		iow(db, DM9000_TXPLH, (skb->len >> 8) & 0xff);
> @@ -732,23 +727,17 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		iow(db, DM9000_TCR, TCR_TXREQ);	/* Cleared after TX complete */
>  
>  		dev->trans_start = jiffies;	/* save the time stamp */
> -
>  	} else {
>  		/* Second packet */
> -		db->tx_pkt_cnt++;
>  		db->queue_pkt_len = skb->len;
> +		netif_stop_queue(dev);
>  	}
>  
> +	spin_unlock_irqrestore(&db->lock, flags);
> +
>  	/* free this SKB */
>  	dev_kfree_skb(skb);
>  
> -	/* Re-enable resource check */
> -	if (db->tx_pkt_cnt == 1)
> -		netif_wake_queue(dev);
> -
> -	/* Re-enable interrupt */
> -	iow(db, DM9000_IMR, IMR_PAR | IMR_PTM | IMR_PRM);
> -
>  	return 0;
>  }

If I read this correctly, you've moved the netif_{stop,start}_queue()
calls so that the queue is only stopped if we have loaded 2 packets
into the chip instead of stopping and starting each time.
  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
