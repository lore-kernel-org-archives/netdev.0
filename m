From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH 1/2] net/tg3: Fix kernel crash
Date: Wed, 24 Jul 2013 05:27:44 -0700
Message-ID: <51EFC840.4010307@broadcom.com>
References: <1374657909-26929-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, davem@davemloft.net
To: "Gavin Shan" <shangw@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3146 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963Ab3GXM1x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 08:27:53 -0400
In-Reply-To: <1374657909-26929-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 7/24/2013 2:25 AM, Gavin Shan wrote:
> While EEH error happens, we might not have network device instance
> (struct net_device) yet. So we can't access the instance safely and
> check its link state, which causes kernel crash. The patch fixes it.
>
> EEH: Frozen PE#2 on PHB#3 detected
> EEH: This PCI device has failed 1 times in the last hour
> EEH: Notify device drivers to shutdown
> (NULL net_device): PCI I/O error detected
> Unable to handle kernel paging request for data at address 0x00000048
> Faulting instruction address: 0xd00000001c9387a8
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=1024 NUMA PowerNV
> :
> NIP [d00000001c9387a8] .tg3_io_error_detected+0x78/0x2a0 [tg3]
> LR [d00000001c9387a4] .tg3_io_error_detected+0x74/0x2a0 [tg3]
> Call Trace:
> [c000003f93a0f960] [d00000001c9387a4] .tg3_io_error_detected+0x74/0x2a0 [tg3]
> [c000003f93a0fa30] [c00000000003844c] .eeh_report_error+0xac/0x120
> [c000003f93a0fac0] [c0000000000371bc] .eeh_pe_dev_traverse+0x8c/0x150
> [c000003f93a0fb60] [c000000000038858] .eeh_handle_normal_event+0x128/0x3d0
> [c000003f93a0fbf0] [c000000000038db8] .eeh_handle_event+0x2b8/0x2c0
> [c000003f93a0fc90] [c000000000038e80] .eeh_event_handler+0xc0/0x170
> [c000003f93a0fd30] [c0000000000cc000] .kthread+0xf0/0x100
> [c000003f93a0fe30] [c00000000000a0dc] .ret_from_kernel_thread+0x5c/0x80
>
> Reported-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>   drivers/net/ethernet/broadcom/tg3.c |    3 ++-
>   1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index d964f30..aee1b9a 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -17773,7 +17773,8 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
>
>   	rtnl_lock();
>
> -	if (!netif_running(netdev))
> +	/* We probably don't have netdev yet */
> +	if (!netdev || !netif_running(netdev))
>   		goto done;
>
>   	tg3_phy_stop(tp);
>

Acked-by: Nithin Nayak Sujir <nsujir@broadcom.com>
