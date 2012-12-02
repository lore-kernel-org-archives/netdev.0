From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP and reordering
Date: Sat, 01 Dec 2012 18:40:05 -0800
Message-ID: <1354416005.20109.557.camel@edumazet-glaptop>
References: <20121127.210611.1127622873924794001.davem@davemloft.net>
	 <1354089566.21562.20.camel@shinybook.infradead.org>
	 <CAGK4HS8=NfcyvcNjC3h1wEjgQFCYoNeuWXj8n5Ruukeg+6j=SQ@mail.gmail.com>
	 <1354093703.21562.23.camel@shinybook.infradead.org>
	 <1354100552.14302.78.camel@edumazet-glaptop>
	 <1354103355.21562.46.camel@shinybook.infradead.org>
	 <1354105619.14302.89.camel@edumazet-glaptop>
	 <1354106362.21562.51.camel@shinybook.infradead.org>
	 <1354107140.14302.140.camel@edumazet-glaptop>
	 <1354117635.21562.63.camel@shinybook.infradead.org>
	 <20121128161930.GB19042@kvack.org>
	 <1354120887.21562.87.camel@shinybook.infradead.org>
	 <1354122996.14302.427.camel@edumazet-glaptop>
	 <1354411840.21562.373.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, saku@ytti.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:34599 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089Ab2LBCkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 21:40:11 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so844023vcd.19
        for <netdev@vger.kernel.org>; Sat, 01 Dec 2012 18:40:10 -0800 (PST)
In-Reply-To: <1354411840.21562.373.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-12-02 at 01:30 +0000, David Woodhouse wrote:

> Oh, of *course*... this is why my kernel would panic if I attempted to
> add BQL to BR2684. The ATM low-level driver was pushing a header onto
> the skb, and I ended up calling netdev_completed_queue() with a larger
> 'bytes' value than the one I'd called netdev_sent_queue() with. Which
> leads to a BUG(), which immediately results in a panic. A moderately
> suboptimal failure mode, when a nasty warning and disabling BQL on this
> interface might have been nicer.
> 
> However, *perhaps* it isn't so hard to get a consistent 'bytes' value.
> This version appears to work... can we use something along these lines
> in the general case? What if skb_is_nonlinear()?
> 
> This probably doesn't work for L2TP where it's going to be passed down
> the whole stack and get a new network header and everything. But for
> BR2684 is this at least a salvageable approach?
> 
> --- net/atm/br2684.c~	2012-12-01 16:35:49.000000000 +0000
> +++ net/atm/br2684.c	2012-12-02 01:18:35.216607088 +0000
> @@ -180,6 +180,11 @@ static struct notifier_block atm_dev_not
>  	.notifier_call = atm_dev_event,
>  };
>  
> +static unsigned int skb_acct_len(struct sk_buff *skb)
> +{
> +	return skb_tail_pointer(skb) - skb_network_header(skb);
> +}
> +
>  /* chained vcc->pop function.  Check if we should wake the netif_queue */
>  static void br2684_pop(struct atm_vcc *vcc, struct sk_buff *skb)
>  {
> @@ -191,6 +196,8 @@ static void br2684_pop(struct atm_vcc *v
>  	/* If the queue space just went up from zero, wake */
>  	if (atomic_inc_return(&brvcc->qspace) == 1)
>  		netif_wake_queue(brvcc->device);
> +
> +	netdev_completed_queue(brvcc->device, 1, skb_acct_len(skb));
>  }
>  
>  /*
> @@ -265,6 +272,7 @@ static int br2684_xmit_vcc(struct sk_buf
>  			netif_wake_queue(brvcc->device);
>  	}
>  
> +	netdev_sent_queue(brvcc->device, skb_acct_len(skb));
>  	/* If this fails immediately, the skb will be freed and br2684_pop()
>  	   will wake the queue if appropriate. Just return an error so that
>  	   the stats are updated correctly */
> @@ -710,6 +718,7 @@ static int br2684_create(void __user *ar
>  		return err;
>  	}


Apparently this driver doesnt add any feature at alloc_netdev() time, so
it might work. (no frags in any skb)
