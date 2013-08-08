From: "Nithin Sujir" <nsujir@broadcom.com>
Subject: RE: [PATCH] net/tg3: Support shutdown on PCI device
Date: Thu, 8 Aug 2013 14:44:32 +0000
Message-ID: <DAAFBCC105999F468732FA900576CB451048E8E0@IRVEXCHMB08.corp.ad.broadcom.com>
References: <1375946769-22814-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: "Gavin Shan" <shangw@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1518 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752006Ab3HHOoi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 10:44:38 -0400
In-Reply-To: <1375946769-22814-1-git-send-email-shangw@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> The patch adds the shutdown interface for the PCI device to make
> things more robust. The PCI device can be put to silent state before
> loading the new kernel and to avoid unnecessary EEH errors.
> 
[Nithin Sujir] 
Hi Gavin,
The shutdown handler implementation was recently merged into net-next.

Can you try these 2 patches from net-next? 

commit 4c305fa2cbe2a85c34899763fcefb843c87b591d
Author: Nithin Sujir <nsujir@broadcom.com>
Date:   Mon Jul 29 13:58:37 2013 -0700

    tg3: Implement the shutdown handler

    Also remove the call to tg3_power_down_prepare() in tg3_power_down()
    since tg3_close() calls it.

commit 5137a2ee2007d9cbbbeebd14abe08357a079b607
Author: Nithin Sujir <nsujir@broadcom.com>
Date:   Mon Jul 29 13:58:36 2013 -0700

    tg3: Allow NVRAM programming when interface is down


Thanks,
Nithin.


> Reported-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c |   12 ++++++++++++
>  1 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c
> b/drivers/net/ethernet/broadcom/tg3.c
> index ddebc7a..dc6178b 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -17663,6 +17663,17 @@ static void tg3_remove_one(struct pci_dev *pdev)
>  	}
>  }
> 
> +static void tg3_shutdown_one(struct pci_dev *pdev)
> +{
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +
> +	if (!dev)
> +		return;
> +
> +	netif_device_detach(dev);
> +	tg3_remove_one(pdev);
> +}
> +
>  #ifdef CONFIG_PM_SLEEP
>  static int tg3_suspend(struct device *device)
>  {
> @@ -17909,6 +17920,7 @@ static struct pci_driver tg3_driver = {
>  	.id_table	= tg3_pci_tbl,
>  	.probe		= tg3_init_one,
>  	.remove		= tg3_remove_one,
> +	.shutdown	= tg3_shutdown_one,
>  	.err_handler	= &tg3_err_handler,
>  	.driver.pm	= &tg3_pm_ops,
>  };
> --
> 1.7.5.4
> 
