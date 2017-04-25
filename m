From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH 7/7] liquidio: use pcie_flr instead of duplicating it
Date: Mon, 24 Apr 2017 18:53:11 -0700
Message-ID: <20170425015311.GA1020@felix-thinkpad.cavium.com>
References: <20170414191131.14286-1-hch@lst.de>
 <20170414191131.14286-8-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>,
        Giovanni Cabiddu <giovanni.cabiddu@intel.com>,
        Salvatore Benedetto <salvatore.benedetto@intel.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        linux-pci@vger.kernel.org, qat-linux@intel.com,
        linux-crypto@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170414191131.14286-8-hch@lst.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de> 
Date: Fri, 14 Apr 2017 21:11:31 +0200

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 15 +--------------
>  1 file changed, 1 insertion(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> index 9d5e03502c76..afdbf7fa016e 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> @@ -869,20 +869,7 @@ static void octeon_pci_flr(struct octeon_device *oct)
>  	pci_write_config_word(oct->pci_dev, PCI_COMMAND,
>  			      PCI_COMMAND_INTX_DISABLE);
>  
> -	/* Wait for Transaction Pending bit clean */
> -	msleep(100);
> -	pcie_capability_read_word(oct->pci_dev, PCI_EXP_DEVSTA, &status);
> -	if (status & PCI_EXP_DEVSTA_TRPND) {
> -		dev_info(&oct->pci_dev->dev, "Function reset incomplete after 100ms, sleeping for 5 seconds\n");
> -		ssleep(5);
> -		pcie_capability_read_word(oct->pci_dev, PCI_EXP_DEVSTA,
> -					  &status);
> -		if (status & PCI_EXP_DEVSTA_TRPND)
> -			dev_info(&oct->pci_dev->dev, "Function reset still incomplete after 5s, reset anyway\n");
> -	}
> -	pcie_capability_set_word(oct->pci_dev, PCI_EXP_DEVCTL,
> -				 PCI_EXP_DEVCTL_BCR_FLR);
> -	mdelay(100);
> +	pcie_flr(oct->pci_dev);
>  
>  	pci_cfg_access_unlock(oct->pci_dev);
>  
> -- 
> 2.11.0
> 

This patch works.  I tested it on a LiquidIO NIC and the "next" branch of the
PCI git tree.

But the patch causes a gcc warning:

    .../lio_vf_main.c: In function 'octeon_pci_flr':
    .../lio_vf_main.c:862:6: warning: unused variable 'status' [-Wunused-variable]

Can you rework the patch to get rid of the warning?  Thanks.
