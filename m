From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Fix deadlock in netconsole with no carrier
Date: Tue, 19 Apr 2005 10:06:50 -0700
Message-ID: <20050419170650.GW21897@waste.org>
References: <20050419135350.GH7715@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20050419135350.GH7715@wotan.suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 19, 2005 at 03:53:50PM +0200, Andi Kleen wrote:
> 
> I got a deadlock at boot with netconsole when the netword card
> did not have a cable connected. This patch fixes this by limiting
> the number of retries. 

It should be waiting for carrier detect before proceeding. What NIC is that?
I'm sure five retries is not enough.

> Also when we run into the device spinlock dont poll all the time,
> just spin.

Two patches? Again, I don't think we should give up so easily.

> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> 
> diff -u net/core/netpoll.c-o net/core/netpoll.c
> --- net/core/netpoll.c-o	2005-03-02 08:38:32.000000000 +0100
> +++ net/core/netpoll.c	2005-04-19 15:50:42.959142733 +0200
> @@ -190,9 +190,10 @@
>  static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
>  {
>  	int status;
> +	int try = 5; 
>  
>  repeat:
> -	if(!np || !np->dev || !netif_running(np->dev)) {
> +	if(try-- == 0 || !np || !np->dev || !netif_running(np->dev)) {
>  		__kfree_skb(skb);
>  		return;
>  	}
> @@ -218,6 +219,10 @@
>  
>  	/* transmit busy */
>  	if(status) {
> +		if (status == NETDEV_TX_LOCKED) {
> +			try++;
> +			goto repeat;
> +		}
>  		netpoll_poll(np);
>  		goto repeat;
>  	}

-- 
Mathematics is the supreme nostalgia of our time.
