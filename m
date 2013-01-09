From: John Greene <jogreene@redhat.com>
Subject: Re: [PATCH] 8139cp: Prevent dev_close/cp_interrupt race on MTU change
Date: Wed, 09 Jan 2013 14:58:02 -0500
Message-ID: <50EDCBCA.8080601@redhat.com>
References: <1355946468-3290-1-git-send-email-jogreene@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	David Woodhouse <David.Woodhouse@intel.com>
To: John Greene <jogreene@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24223 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932439Ab3AIT6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 14:58:09 -0500
In-Reply-To: <1355946468-3290-1-git-send-email-jogreene@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2012 02:47 PM, John Greene wrote:
> commit:  cb64edb6b89491edfdbae52ba7db9a8b8391d339 upstream
>
> Above commit may introduce a race between cp_interrupt and dev_close
> / change MTU / dev_open up state. Changes cp_interrupt to tolerate
> this.  Change spin_locking in cp_interrupt to avoid possible
> but unobserved race.
>
> Reported-by: "Francois Romieu" <romieu@fr.zoreil.com>
>
> Tested on virtual hardware, Tx MTU size up to 4096, max tx payload
>      was ping -s 4068 for MTU of 4096. No real hardware, need test
>      assist.
>
> Signed-off-by: "John Greene" <jogreene@redhat.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: "David Woodhouse" <David.Woodhouse@intel.com>
> ---
>   drivers/net/ethernet/realtek/8139cp.c | 18 +++++++++++-------
>   1 file changed, 11 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> index 0da3f5e..585c35c 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
> @@ -577,28 +577,30 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
>   {
>   	struct net_device *dev = dev_instance;
>   	struct cp_private *cp;
> +	int handled = 0;
>   	u16 status;
>
>   	if (unlikely(dev == NULL))
>   		return IRQ_NONE;
>   	cp = netdev_priv(dev);
>
> +	spin_lock(&cp->lock);
> +
>   	status = cpr16(IntrStatus);
>   	if (!status || (status == 0xFFFF))
> -		return IRQ_NONE;
> +		goto out_unlock;
> +
> +	handled = 1;
>
>   	netif_dbg(cp, intr, dev, "intr, status %04x cmd %02x cpcmd %04x\n",
>   		  status, cpr8(Cmd), cpr16(CpCmd));
>
>   	cpw16(IntrStatus, status & ~cp_rx_intr_mask);
>
> -	spin_lock(&cp->lock);
> -
>   	/* close possible race's with dev_close */
>   	if (unlikely(!netif_running(dev))) {
>   		cpw16(IntrMask, 0);
> -		spin_unlock(&cp->lock);
> -		return IRQ_HANDLED;
> +		goto out_unlock;
>   	}
>
>   	if (status & (RxOK | RxErr | RxEmpty | RxFIFOOvr))
> @@ -612,7 +614,6 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
>   	if (status & LinkChg)
>   		mii_check_media(&cp->mii_if, netif_msg_link(cp), false);
>
> -	spin_unlock(&cp->lock);
>
>   	if (status & PciErr) {
>   		u16 pci_status;
> @@ -625,7 +626,10 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
>   		/* TODO: reset hardware */
>   	}
>
> -	return IRQ_HANDLED;
> +out_unlock:
> +	spin_unlock(&cp->lock);
> +
> +	return IRQ_RETVAL(handled);
>   }
>
>   #ifdef CONFIG_NET_POLL_CONTROLLER
>
Can I get a quick update on this? Seems to have fallen thru the cracks. 
  Thanks.

-- 
John Greene
