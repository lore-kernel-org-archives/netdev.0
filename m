From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] pciaer: report config read/write errors
Date: Tue, 2 Dec 2008 10:41:18 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0812021040480.2280@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20081202004115.12058.64881.stgit@gitlost.lost>
 <20081201174754.2e5ef401@extreme> <20081201.232527.66213356.davem@davemloft.net>
 <20081202092316.7d6b6291@extreme>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20081202092316.7d6b6291@extreme>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 Dec 2008, Stephen Hemminger wrote:

> This patch does more error checking in the Advanced Error Reporting code.
> Since AER needs to access PCI registers > 255, it won't work without MMCONFIG
> and other quirks may stop it as well. The code must check this by looking
> at return values from pci_read/write_config_XXX calls.  
> 
> I don't have any hardware that uses AER routines but discovered this 
> in earlier versions of the sky2 driver that tried to use
> pci AER routines. Ended up just giving up and using other ways to access PCI
> config space on sky2 since there were too many platform glitches.
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/drivers/pci/pcie/aer/aerdrv_core.c	2008-12-02 07:56:08.000000000 -0800
> +++ b/drivers/pci/pcie/aer/aerdrv_core.c	2008-12-02 09:07:32.000000000 -0800
> @@ -31,80 +31,92 @@ module_param(forceload, bool, 0);
>  int pci_enable_pcie_error_reporting(struct pci_dev *dev)
>  {
>  	u16 reg16 = 0;
> -	int pos;
> +	int pos, err;
> +	u32 status;
>  
>  	pos = pci_find_ext_capability(dev, PCI_EXT_CAP_ID_ERR);
>  	if (!pos)
>  		return -EIO;
>  
> +	err = pci_read_config_dword(dev, pos + PCI_ERR_UNCOR_STATUS, &status);
> +	if (err)
> +		return err;
> +
>  	pos = pci_find_capability(dev, PCI_CAP_ID_EXP);
>  	if (!pos)
>  		return -EIO;
>  
> -	pci_read_config_word(dev, pos+PCI_EXP_DEVCTL, &reg16);
> +	err = pci_read_config_word(dev, pos+PCI_EXP_DEVCTL, &reg16);
> +	if (err)
> +		return err;
> +
>  	reg16 = reg16 |
>  		PCI_EXP_DEVCTL_CERE |
>  		PCI_EXP_DEVCTL_NFERE |
>  		PCI_EXP_DEVCTL_FERE |
>  		PCI_EXP_DEVCTL_URRE;
> -	pci_write_config_word(dev, pos+PCI_EXP_DEVCTL,
> -			reg16);
> -	return 0;
> +	return pci_write_config_word(dev, pos+PCI_EXP_DEVCTL, reg16);
>  }
>  
>  int pci_disable_pcie_error_reporting(struct pci_dev *dev)
>  {
>  	u16 reg16 = 0;
> -	int pos;
> +	int pos, err;
>  
>  	pos = pci_find_capability(dev, PCI_CAP_ID_EXP);
>  	if (!pos)
>  		return -EIO;
>  
> -	pci_read_config_word(dev, pos+PCI_EXP_DEVCTL, &reg16);
> +	err = pci_read_config_word(dev, pos+PCI_EXP_DEVCTL, &reg16);
> +	if (err)
> +		return err;
> +
>  	reg16 = reg16 & ~(PCI_EXP_DEVCTL_CERE |
>  			PCI_EXP_DEVCTL_NFERE |
>  			PCI_EXP_DEVCTL_FERE |
>  			PCI_EXP_DEVCTL_URRE);
> -	pci_write_config_word(dev, pos+PCI_EXP_DEVCTL,
> -			reg16);
> -	return 0;
> +	return pci_write_config_word(dev, pos+PCI_EXP_DEVCTL, reg16);
>  }
>  
>  int pci_cleanup_aer_uncorrect_error_status(struct pci_dev *dev)
>  {
> -	int pos;
> +	int pos, err;
>  	u32 status, mask;
>  
>  	pos = pci_find_ext_capability(dev, PCI_EXT_CAP_ID_ERR);
>  	if (!pos)
>  		return -EIO;
>  
> -	pci_read_config_dword(dev, pos + PCI_ERR_UNCOR_STATUS, &status);
> -	pci_read_config_dword(dev, pos + PCI_ERR_UNCOR_SEVER, &mask);
> +	err = pci_read_config_dword(dev, pos + PCI_ERR_UNCOR_STATUS, &status);
> +	if (err)
> +		return err;
> +
> +	err = pci_read_config_dword(dev, pos + PCI_ERR_UNCOR_SEVER, &mask);
> +	if (err)
> +		return err;
> +
>  	if (dev->error_state == pci_channel_io_normal)
>  		status &= ~mask; /* Clear corresponding nonfatal bits */
>  	else
>  		status &= mask; /* Clear corresponding fatal bits */
> -	pci_write_config_dword(dev, pos + PCI_ERR_UNCOR_STATUS, status);
> -
> -	return 0;
> +	return pci_write_config_dword(dev, pos + PCI_ERR_UNCOR_STATUS, status);
>  }
>  
>  #if 0
>  int pci_cleanup_aer_correct_error_status(struct pci_dev *dev)
>  {
> -	int pos;
> +	int pos, err;
>  	u32 status;
>  
>  	pos = pci_find_ext_capability(dev, PCI_EXT_CAP_ID_ERR);
>  	if (!pos)
>  		return -EIO;
>  
> -	pci_read_config_dword(dev, pos + PCI_ERR_COR_STATUS, &status);
> -	pci_write_config_dword(dev, pos + PCI_ERR_COR_STATUS, status);
> +	err = pci_read_config_dword(dev, pos + PCI_ERR_COR_STATUS, &status);
> +	if (err)
> +		return err;
>  
> -	return 0;
> +	return pci_write_config_dword(dev, pos + PCI_ERR_COR_STATUS, status);
>  }
>  #endif  /*  0  */

This looks fine to me.  Thanks very much Stephen.

-PJ Waskiewicz
