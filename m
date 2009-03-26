From: Adam Richter <adam_richter2004@yahoo.com>
Subject: Re: 2.6.29 forcedeth hang W/O NAPI enabled
Date: Wed, 25 Mar 2009 18:20:22 -0700 (PDT)
Message-ID: <810119.61814.qm@web57701.mail.re3.yahoo.com>
References: <20090325.170515.175107737.davem@davemloft.net>
Reply-To: adam_richter2004@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, berkley@cs.wustl.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web57701.mail.re3.yahoo.com ([68.142.236.53]:34670 "HELO
	web57701.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752826AbZCZBUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 21:20:25 -0400
In-Reply-To: <20090325.170515.175107737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello David,

The patch you forwarded to me seems to work.  Thank you for bringing it
to my attention.

In particular linux-2.6.29 with your patch applied with CONFIG_FORCEDETH_NAPI disabled has been doing "ping -f" on the same
local computer I was tested with before for more than 5 minutes with
no problem.  I am able to surf the web and compose this email in the
meantime.  In the past, "ping -f" with NAPI disabled would produce the problem within about 30 seconds (with NAPI enabled, it did not seem to reproduce the problem, but I am pretty sure that the problem did happen once with with forcedeth module compiled with NAPI, although my quick
efforts to reproduce the problem that way did not immediately succeed).

I have appended the patch you sent, just to be clear, since there are a few patches being discussed in the thread you referred to.  If I have anything else to add, I will follow-up in that thread.

Thank you for your help!

Adam


--- On Wed, 3/25/09, David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Subject: Re: 2.6.29 forcedeth hang W/O NAPI enabled
> To: adam_richter2004@yahoo.com
> Cc: netdev@vger.kernel.org, berkley@cs.wustl.edu
> Date: Wednesday, March 25, 2009, 5:05 PM
> From: Adam Richter <adam_richter2004@yahoo.com>
> Date: Wed, 25 Mar 2009 16:24:47 -0700 (PDT)
> 
> > 	When I can find some time, I plan to try to narrow
> the problem
> > with git bisect, but that may not be today.
> 
> We're pretty sure we know exactly what commit causes
> this.
> 
> Can you try playing with a patch Jarek P. just posted in
> the thread where this bug is being discussed?  (Subject:
> Revert "gro: Fix legacy path napi_complete
> crash"):
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index e3fe5c7..cf53c24 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2589,7 +2589,11 @@ static int process_backlog(struct
> napi_struct *napi, int quota)
>  		skb = __skb_dequeue(&queue->input_pkt_queue);
>  		if (!skb) {
>  			local_irq_enable();
> -			napi_complete(napi);
> +			napi_gro_flush(napi);
> +			local_irq_disable();
> +			if (skb_queue_empty(&queue->input_pkt_queue))
> +				__napi_complete(napi);
> +			local_irq_enable();
>  			goto out;
>  		}
>  		local_irq_enable();


      
