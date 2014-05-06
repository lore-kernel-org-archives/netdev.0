From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] sfc: fix calling of free_irq with 0 argument
Date: Tue, 06 May 2014 17:34:38 +0200
Message-ID: <5369010E.2060908@redhat.com>
References: <1399380556-25797-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3376 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755170AbaEFPj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 11:39:29 -0400
In-Reply-To: <1399380556-25797-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2014 02:49 PM, Nikolay Aleksandrov wrote:
> If the sfc driver is in legacy interrupt mode (either explicitly by
> using interrupt_mode module param or by falling back to it) it will
> hit a warning at kernel/irq/manage.c because it will try to free irq 0
> in efx_nic_fini_interrupt() since the MSI interrupts were freed always,
> but in legacy irq mode they're == 0. So fix it by checking if we
> actually have an interrupt allocated and only then free it.
> 
> CC: <linux-net-drivers@solarflare.com>
> CC: Shradha Shah <sshah@solarflare.com>
> CC: David S. Miller <davem@davemloft.net>
> 
> Reported-by: Zenghui Shi <zshi@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> There're other ways to fix this as well, but I chose this one as it follows
> the logic in the code. Also I saw it used in a few places to check if
> there's an IRQ allocated for that channel.
> 
>  drivers/net/ethernet/sfc/nic.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
> index 32d969e857f7..cab627defbc3 100644
> --- a/drivers/net/ethernet/sfc/nic.c
> +++ b/drivers/net/ethernet/sfc/nic.c
> @@ -158,7 +158,9 @@ void efx_nic_fini_interrupt(struct efx_nic *efx)
>  
>  	/* Disable MSI/MSI-X interrupts */
>  	efx_for_each_channel(channel, efx)
> -		free_irq(channel->irq, &efx->msi_context[channel->channel]);
> +		if (channel->irq)
> +			free_irq(channel->irq,
> +				 &efx->msi_context[channel->channel]);
>  
>  	/* Disable legacy interrupt */
>  	if (efx->legacy_irq)
> 
And of course if I had looked deeper in the history of that function I would've
seen that the code was like that before commit
1899c111a535e43046b14ae13639747d9d2544d6 ("sfc: Fix IRQ cleanup in case of a
probe failure"). So including Ben on the CC list as he's the author of that commit.

Cheers,
 Nik
