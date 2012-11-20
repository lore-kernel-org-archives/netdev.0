From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2] xen/netfront: handle compound page fragments on
 transmit
Date: Tue, 20 Nov 2012 08:27:24 -0800
Message-ID: <1353428844.2590.17.camel@edumazet-glaptop>
References: <1353427257-16789-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	ANNIE LI <annie.li@oracle.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Stefan Bader <stefan.bader@canonical.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:35010 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923Ab2KTQ12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 11:27:28 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1306004dak.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 08:27:27 -0800 (PST)
In-Reply-To: <1353427257-16789-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-20 at 16:00 +0000, Ian Campbell wrote:
> An SKB paged fragment can consist of a compound page with order > 0.
> However the netchannel protocol deals only in PAGE_SIZE frames.
> 
> Handle this in xennet_make_frags by iterating over the frames which
> make up the page.
> 
> This is the netfront equivalent to 6a8ed462f16b for netback.
...

> -	frags += DIV_ROUND_UP(offset + len, PAGE_SIZE);
> -	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
> -		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
> -		       frags);
> -		dump_stack();
> +	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
> +		xennet_count_skb_frag_slots(skb);
> +	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> +		printk(KERN_ALERT "xennet: skb rides the rocket: %d slots\n",
> +		       slots);

I think this is wrong.

You should change netfront_tx_slot_available() to stop the queue before
this can happen.

Yes, you dont hit this on your tests, but a driver should not drop a
good packet.

>  		goto drop;
>  	}
>  
>  	spin_lock_irqsave(&np->tx_lock, flags);
>  
>  	if (unlikely(!netif_carrier_ok(dev) ||
> -		     (frags > 1 && !xennet_can_sg(dev)) ||
> +		     (slots > 1 && !xennet_can_sg(dev)) ||
>  		     netif_needs_gso(skb, netif_skb_features(skb)))) {
>  		spin_unlock_irqrestore(&np->tx_lock, flags);
>  		goto drop;


diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index caa0110..cb1e605 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -215,10 +215,13 @@ static void rx_refill_timeout(unsigned long data)
        napi_schedule(&np->napi);
 }
 
+/* Considering a 64Kb packet of 16 frags, each frag can be mapped
+ * to 3 order-0 parts on pathological cases
+ */
 static int netfront_tx_slot_available(struct netfront_info *np)
 {
        return (np->tx.req_prod_pvt - np->tx.rsp_cons) <
-               (TX_MAX_TARGET - MAX_SKB_FRAGS - 2);
+               (TX_MAX_TARGET - 3*MAX_SKB_FRAGS - 2);
 }
 
 static void xennet_maybe_wake_tx(struct net_device *dev)
