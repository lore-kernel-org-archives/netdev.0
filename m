From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: Regression: ixgb warning on MTU change
Date: Wed, 01 Oct 2008 11:32:45 -0300
Message-ID: <48E38A0D.6090308@linux.vnet.ibm.com>
References: <48DAAFE2.1050607@linux.vnet.ibm.com> <Pine.WNT.4.63.0809301603030.2188@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	Rafael Lorandi <rafael.lorandi@linux.vnet.ibm.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.br.ibm.com ([32.104.18.25]:54713 "EHLO igw2.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbYJAOcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 10:32:48 -0400
Received: from d24relay01.br.ibm.com (unknown [9.8.31.16])
	by igw2.br.ibm.com (Postfix) with ESMTP id 3B05417F616
	for <netdev@vger.kernel.org>; Wed,  1 Oct 2008 11:16:48 -0300 (BRT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91EWdTj901340
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 11:32:39 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91EWjs0006832
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 11:32:46 -0300
In-Reply-To: <Pine.WNT.4.63.0809301603030.2188@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse, 

Brandeburg, Jesse wrote:
> On Wed, 24 Sep 2008, Breno Leitao wrote:
> Thanks for the report, I think this patch should fix it.  Please test and 
> let us know.  This was compile tested only.
I just tested this patch and it fixed that problem.  

Thanks

> ----
> 
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> ixgb: fix bug when freeing resources
> 
> It was pointed out by Breno Leitao <leitao@linux.vnet.ibm.com> that
> ixgb would crash on PPC when an IOMMU was in use, if change_mtu was
> called.
> 
> It appears to be a pretty simple issue in the driver that wasn't discovered
> because most systems don't run with an IOMMU.  The driver needs to only unmap
> buffers that are mapped (duh).
> 
> CC: Breno Leitao <leitao@linux.vnet.ibm.com>
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> ---
>  drivers/net/ixgb/ixgb_main.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
> index aa75385..be3c7dc 100644
> --- a/drivers/net/ixgb/ixgb_main.c
> +++ b/drivers/net/ixgb/ixgb_main.c
> @@ -977,15 +977,17 @@ ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
> 
>  	for (i = 0; i < rx_ring->count; i++) {
>  		buffer_info = &rx_ring->buffer_info[i];
> -		if (buffer_info->skb) {
> -
> +		if (buffer_info->dma) {
>  			pci_unmap_single(pdev,
>  					 buffer_info->dma,
>  					 buffer_info->length,
>  					 PCI_DMA_FROMDEVICE);
> +			buffer_info->dma = 0;
> +			buffer_info->length = 0;
> +		}
> 
> +		if (buffer_info->skb) {
>  			dev_kfree_skb(buffer_info->skb);
> -
>  			buffer_info->skb = NULL;
>  		}
>  	}
> 
