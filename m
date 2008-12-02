From: Loic Prylli <loic@myri.com>
Subject: Re: [PATCH] pciaer: report config read/write errors
Date: Tue, 02 Dec 2008 14:04:15 -0500
Message-ID: <493586AF.3030402@myri.com>
References: <20081202004115.12058.64881.stgit@gitlost.lost> <20081201174754.2e5ef401@extreme> <20081201.232527.66213356.davem@davemloft.net> <20081202092316.7d6b6291@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org,
	peter.p.waskiewicz.jr@intel.com, linux-pci@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2009 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752566AbYLBTEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 14:04:30 -0500
In-Reply-To: <20081202092316.7d6b6291@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2008 12:23 PM, Stephen Hemminger wrote:
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




When experimenting with sky2 driver, was pci_find_ext_capability() 
returning non-zero although further ext-space accesses were failing?



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
>
>   



For legacy-conf-space, most kernel code assumes success without 
checking. For ext-conf-space, wouldn't it be convenient to be able to 
make the same assumption when pci_find_ext_capability() returns a valid 
offset?

The patch looks good to me, but I am just asking whether there is a 
known case where pcie_find_ext_capability() returns a valid offset, 
although that offset might turn out unusable (it might be worth 
investigating pci_find_ext_capability() then).


Loic


