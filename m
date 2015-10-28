From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/4] sfc: set and clear interrupt affinity hints
Date: Wed, 28 Oct 2015 21:15:57 +0300
Message-ID: <563110DD.8040606@cogentembedded.com>
References: <5630E2FD.3070609@solarflare.com>
 <5630E36B.2030501@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Shradha Shah <sshah@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36682 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbbJ1SQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 14:16:01 -0400
Received: by lbjm5 with SMTP id m5so11966040lbj.3
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 11:15:59 -0700 (PDT)
In-Reply-To: <5630E36B.2030501@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/28/2015 06:02 PM, Shradha Shah wrote:

> From: Bert Kenward <bkenward@solarflare.com>
>
> Use cpumask_local_spread to provide interrupt affinity hints
> for each queue. This will spread interrupts across NUMA local
> CPUs first, extending to remote nodes if needed.
>
> Signed-off-by: Shradha Shah <sshah@solarflare.com>
> ---
>   drivers/net/ethernet/sfc/efx.c | 35 +++++++++++++++++++++++++++++++++++
>   1 file changed, 35 insertions(+)
>
> diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
> index 84f9e90..93c4c0e 100644
> --- a/drivers/net/ethernet/sfc/efx.c
> +++ b/drivers/net/ethernet/sfc/efx.c
> @@ -1489,6 +1489,30 @@ static int efx_probe_interrupts(struct efx_nic *efx)
>   	return 0;
>   }
>
> +#if defined(CONFIG_SMP)
> +static void efx_set_interrupt_affinity(struct efx_nic *efx)
> +{
> +	struct efx_channel *channel;
> +	unsigned int cpu;
> +
> +	efx_for_each_channel(channel, efx) {
> +		cpu = cpumask_local_spread(channel->channel,
> +					   pcibus_to_node(efx->pci_dev->bus));
> +
> +		irq_set_affinity_hint(channel->irq, cpumask_of(cpu));
> +		channel->irq_mem_node = cpu_to_mem(cpu);
> +	}
> +}
> +
> +static void efx_clear_interrupt_affinity(struct efx_nic *efx)
> +{
> +	struct efx_channel *channel;
> +
> +	efx_for_each_channel(channel, efx)
> +		irq_set_affinity_hint(channel->irq, NULL);
> +}
> +#endif /* CONFIG_SMP */
> +
>   static int efx_soft_enable_interrupts(struct efx_nic *efx)
>   {
>   	struct efx_channel *channel, *end_channel;
> @@ -2932,6 +2956,9 @@ static void efx_pci_remove_main(struct efx_nic *efx)
>   	cancel_work_sync(&efx->reset_work);
>
>   	efx_disable_interrupts(efx);
> +#if defined(CONFIG_SMP)
> +	efx_clear_interrupt_affinity(efx);
> +#endif

    Please just define empty function for !SMP case instead of the ugly 
#ifdef'fery in the functiojn bodies.

[...]

MBR, Sergei
