From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next 1/2] xen-netback: split event channels
 feature support
Date: Tue, 21 May 2013 14:34:19 +0100
Message-ID: <519B77DB.3040901@citrix.com>
References: <1369090931-27306-1-git-send-email-wei.liu2@citrix.com> <1369090931-27306-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:34500 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754431Ab3EUNeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 09:34:22 -0400
In-Reply-To: <1369090931-27306-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/05/13 00:02, Wei Liu wrote:
> Netback and netfront only use one event channel to do TX / RX notification,
> which may cause unnecessary wake-up of processing routines. This patch adds a
> new feature called feature-split-event-channels to netback, enabling it to
> handle TX and RX events separately.
> 
> Netback will use tx_irq to notify guest for TX completion, rx_irq for RX
> notification.
> 
> If frontend doesn't support this feature, tx_irq is equal to rx_irq.
[...]
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -69,12 +69,35 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
>  
>  	xen_netbk_schedule_xenvif(vif);
>  
> +	return IRQ_HANDLED;
> +}
> +
> +static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
> +{
> +	struct xenvif *vif = dev_id;
> +
> +	if (vif->netbk == NULL)
> +		return IRQ_NONE;

I know the original code had this but this looks suspect to me.  Event
channels are never shared so it does not make sense to ever return IRQ_NONE.

Suggest making this return IRQ_HANDLED instead (and similarly in
xenvif_tx_interrupt()) and...

> +static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
> +{
> +	struct xenvif *vif = dev_id;
> +
> +	if (vif->netbk == NULL)
> +		return IRQ_NONE;

... then you can remove this test.

> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -114,6 +114,15 @@ static int netback_probe(struct xenbus_device *dev,
>  			goto abort_transaction;
>  		}
>  
> +		/* Split event channels support */
> +		err = xenbus_printf(xbt, dev->nodename,
> +				"feature-split-event-channels",
> +				"%u", 1);
> +		if (err) {
> +			message = "writing feature-split-event-channels";
> +			goto abort_transaction;
> +		}
> +

Event channels are currently a limited resource.  Do we want to have a
knob to disable this feature?

David
