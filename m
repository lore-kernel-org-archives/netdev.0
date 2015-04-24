From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH] net/tg3: Release IRQs on permanent error
Date: Fri, 24 Apr 2015 14:59:19 -0700
Message-ID: <1429912759.26841.1.camel@prashant>
References: <1429852943-28953-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<mchan@broadcom.com>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:52561 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965837AbbDXWJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 18:09:01 -0400
In-Reply-To: <1429852943-28953-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-24 at 15:22 +1000, Gavin Shan wrote:
> When having permanent EEH error, the PCI device will be removed
> from the system. For this case, we shouldn't set pcierr_recovery
> to true wrongly, which blocks the driver to release the allocated
> interrupts and their handlers. Eventually, we can't disable MSI
> or MSIx successfully because of the MSI or MSIx interrupts still
> have associated interrupt actions, which is turned into following
> stack dump.
> 
> Oops: Exception in kernel mode, sig: 5 [#1]
>         :
> [c0000000003b76a8] .free_msi_irqs+0x80/0x1a0 (unreliable)
> [c00000000039f388] .pci_remove_bus_device+0x98/0x110
> [c0000000000790f4] .pcibios_remove_pci_devices+0x9c/0x128
> [c000000000077b98] .handle_eeh_events+0x2d8/0x4b0
> [c0000000000782d0] .eeh_event_handler+0x130/0x1c0
> [c000000000022bd4] .kernel_thread+0x54/0x70
> 
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 1270b18..069952f 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -18129,7 +18129,9 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
>  
>  	rtnl_lock();
>  
> -	tp->pcierr_recovery = true;
> +	/* We needn't recover from permanent error */
> +	if (state == pci_channel_io_frozen)
> +		tp->pcierr_recovery = true;
>  
>  	/* We probably don't have netdev yet */
>  	if (!netdev || !netif_running(netdev))

Acked-by: Prashant Sreedharan <prashant@broadcom.com>
