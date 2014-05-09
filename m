From: Shradha Shah <sshah@solarflare.com>
Subject: Re: [PATCH net v3] sfc: fix calling of free_irq with already free
 vector
Date: Fri, 9 May 2014 10:25:21 +0100
Message-ID: <536C9F01.6080708@solarflare.com>
References: <1399626699-7181-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Zenghui Shi <zshi@redhat.com>, Ben Hutchings <ben@decadent.org.uk>,
	<linux-net-drivers@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31730 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102AbaEIJZ0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 05:25:26 -0400
In-Reply-To: <1399626699-7181-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/14 10:11, Nikolay Aleksandrov wrote:
> If the sfc driver is in legacy interrupt mode (either explicitly by
> using interrupt_mode module param or by falling back to it) it will
> hit a warning at kernel/irq/manage.c because it will try to free an irq
> which wasn't allocated by it in the first place because the MSI(X) irqs are
> zero and it'll try to free them unconditionally. So fix it by checking if
> we're in legacy mode and freeing the appropriate irqs.
>
> CC: Zenghui Shi <zshi@redhat.com>
> CC: Ben Hutchings <ben@decadent.org.uk>
> CC: <linux-net-drivers@solarflare.com>
> CC: Shradha Shah <sshah@solarflare.com>
> CC: David S. Miller <davem@davemloft.net>
>
> Fixes: 1899c111a535 ("sfc: Fix IRQ cleanup in case of a probe failure")
> Reported-by: Zenghui Shi <zshi@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Acked-by: Shradha Shah <sshah@solarflare.com>

> ---
> v3: Use the EFX_INT_MODE_USE_MSI macro instead of direct check
> as suggested by Ben
> v2: Change the fix to check for the interrupt mode and adjust the
> commit message.
>
>  drivers/net/ethernet/sfc/nic.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
> index 32d969e857f7..89b83e59e1dc 100644
> --- a/drivers/net/ethernet/sfc/nic.c
> +++ b/drivers/net/ethernet/sfc/nic.c
> @@ -156,13 +156,15 @@ void efx_nic_fini_interrupt(struct efx_nic *efx)
>       efx->net_dev->rx_cpu_rmap = NULL;
>  #endif
>
> -     /* Disable MSI/MSI-X interrupts */
> -     efx_for_each_channel(channel, efx)
> -             free_irq(channel->irq, &efx->msi_context[channel->channel]);
> -
> -     /* Disable legacy interrupt */
> -     if (efx->legacy_irq)
> +     if (EFX_INT_MODE_USE_MSI(efx)) {
> +             /* Disable MSI/MSI-X interrupts */
> +             efx_for_each_channel(channel, efx)
> +                     free_irq(channel->irq,
> +                              &efx->msi_context[channel->channel]);
> +     } else {
> +             /* Disable legacy interrupt */
>               free_irq(efx->legacy_irq, efx);
> +     }
>  }
>
>  /* Register dump */
>
The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.
