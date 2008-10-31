From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH net-next] tg3: inconsistent interrupt value reported
Date: Fri, 31 Oct 2008 12:09:08 -0400
Message-ID: <490B2DA4.30903@garzik.org>
References: <20081031155421.GB6181@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com,
	davem@davemloft.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56313 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016AbYJaQJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 12:09:14 -0400
In-Reply-To: <20081031155421.GB6181@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> Systems that use MSI do not report the correct 'Interrupt' value in
> ifconfig output.  This patch sets dev->irq after initializing the
> interrupt as the value will change when using MSI.
> 
> I suspect this is a problem with a lot of drivers, so I'll snoop around
> and post some more patches if needed.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
> 
>  tg3.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index eb9f8f3..fa95e99 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -7892,6 +7892,7 @@ static int tg3_request_irq(struct tg3 *tp)
>  	irq_handler_t fn;
>  	unsigned long flags;
>  	struct net_device *dev = tp->dev;
> +	int ret;
>  
>  	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
>  		fn = tg3_msi;
> @@ -7904,7 +7905,9 @@ static int tg3_request_irq(struct tg3 *tp)
>  			fn = tg3_interrupt_tagged;
>  		flags = IRQF_SHARED | IRQF_SAMPLE_RANDOM;
>  	}
> -	return (request_irq(tp->pdev->irq, fn, flags, dev->name, dev));
> +	ret = request_irq(tp->pdev->irq, fn, flags, dev->name, dev);
> +	dev->irq = tp->pdev->irq;
> +	return ret;

The ifconfig value is useless, and was never designed to carry and 
display that kind of information (MSI vectors, etc.).

In fact, part of the reason why the ethtool bus-id information was added 
was to give better insight into the hardware attached to the device, 
notably including the interrupt information.

In modern drivers (read: newer than [E]ISA), dev->irq use is 
inconsistent and largely for __best effort__ display purposes only.

I'd argue that a policy of leaving dev->irq at zero might be a better 
idea.  That ensures users do not pay attention to what is already an 
inconsistent/truncate/device-dependent piece of information.

	Jeff




