From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: Re: [PATCH net v2] igb: re-assign hw address pointer on reset after
 PCI error
Date: Fri, 2 Dec 2016 10:55:56 -0200
Message-ID: <58416F5C.20602@linux.vnet.ibm.com>
References: <1478803603-30306-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, todd.fujinaka@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:42585 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753256AbcLBM4F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 07:56:05 -0500
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB2CpomF145890
        for <netdev@vger.kernel.org>; Fri, 2 Dec 2016 07:56:04 -0500
Received: from e24smtp03.br.ibm.com (e24smtp03.br.ibm.com [32.104.18.24])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27393413aw-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 07:56:03 -0500
Received: from localhost
        by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Fri, 2 Dec 2016 10:56:02 -0200
Received: from d24relay04.br.ibm.com (d24relay04.br.ibm.com [9.18.232.146])
        by d24dlp02.br.ibm.com (Postfix) with ESMTP id 5F8731DC006E
        for <netdev@vger.kernel.org>; Fri,  2 Dec 2016 07:56:00 -0500 (EST)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
        by d24relay04.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uB2Cu0nh58654932
        for <netdev@vger.kernel.org>; Fri, 2 Dec 2016 10:56:00 -0200
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
        by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uB2CtxlW019672
        for <netdev@vger.kernel.org>; Fri, 2 Dec 2016 10:56:00 -0200
In-Reply-To: <1478803603-30306-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2016 04:46 PM, Guilherme G. Piccoli wrote:
> Whenever the igb driver detects the result of a read operation returns
> a value composed only by F's (like 0xFFFFFFFF), it will detach the
> net_device, clear the hw_addr pointer and warn to the user that adapter's
> link is lost - those steps happen on igb_rd32().
> 
> In case a PCI error happens on Power architecture, there's a recovery
> mechanism called EEH, that will reset the PCI slot and call driver's
> handlers to reset the adapter and network functionality as well.
> 
> We observed that once hw_addr is NULL after the error is detected on
> igb_rd32(), it's never assigned back, so in the process of resetting
> the network functionality we got a NULL pointer dereference in both
> igb_configure_tx_ring() and igb_configure_rx_ring(). In order to avoid
> such bug, this patch re-assigns the hw_addr value in the slot_reset
> handler.
> 
> Reported-by: Anthony H. Thai <ahthai@us.ibm.com>
> Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index edc9a6a..136ee9e 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -7878,6 +7878,11 @@ static pci_ers_result_t igb_io_slot_reset(struct pci_dev *pdev)
>  		pci_enable_wake(pdev, PCI_D3hot, 0);
>  		pci_enable_wake(pdev, PCI_D3cold, 0);
> 
> +		/* In case of PCI error, adapter lose its HW address
> +		 * so we should re-assign it here.
> +		 */
> +		hw->hw_addr = adapter->io_addr;
> +
>  		igb_reset(adapter);
>  		wr32(E1000_WUS, ~0);
>  		result = PCI_ERS_RESULT_RECOVERED;
> 

Ping?

Sorry to annoy, any news on this?
Thanks in advance!

Cheers,


Guilherme
