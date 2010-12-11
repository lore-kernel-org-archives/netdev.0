From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 2/7] vxge: fix crash of VF when unloading PF
Date: Fri, 10 Dec 2010 17:04:41 -0800
Message-ID: <20101211010441.GI4040@sequoia.sous-sol.org>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
 <1292025782-16372-2-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:43754 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750769Ab0LKBcd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 20:32:33 -0500
Content-Disposition: inline
In-Reply-To: <1292025782-16372-2-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jon Mason (jon.mason@exar.com) wrote:
> +static int __devinit is_sriov_initialized(struct pci_dev *pdev)
> +{
> +	int pos;
> +	u16 ctrl;
> +
> +	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
> +	if (pos) {
> +		pci_read_config_word(pdev, pos + PCI_SRIOV_CTRL, &ctrl);
> +		if (ctrl & PCI_SRIOV_CTRL_VFE)
> +			return 1;
> +	}
> +	return 0;
> +}

This is a helper that should go in drivers/pci/iov.c (it's a pure
pci thing).

> +
>  /**
>   * vxge_probe
>   * @pdev : structure containing the PCI related information of the device.
> @@ -4370,14 +4384,13 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
>  		num_vfs = vxge_get_num_vfs(function_mode) - 1;
>  
>  	/* Enable SRIOV mode, if firmware has SRIOV support and if it is a PF */
> -	if (is_sriov(function_mode) && (max_config_dev > 1) &&
> -		(ll_config->intr_type != INTA) &&
> -		(is_privileged == VXGE_HW_OK)) {
> -		ret = pci_enable_sriov(pdev, ((max_config_dev - 1) < num_vfs)
> -			? (max_config_dev - 1) : num_vfs);
> +	if (is_sriov(function_mode) && !is_sriov_initialized(pdev) &&
> +	   (ll_config->intr_type != INTA)) {
> +		ret = pci_enable_sriov(pdev, num_vfs);

This fundamentally changes the way VF's are allocated.  Now you cannot
specifiy the number of vfs to allocate with max_config_dev module
parameter.

>  		if (ret)
>  			vxge_debug_ll_config(VXGE_ERR,
>  				"Failed in enabling SRIOV mode: %d\n", ret);
> +			/* No need to fail out, as an error here is non-fatal */
>  	}
>  
>  	/*
> @@ -4673,8 +4686,6 @@ static void __devexit vxge_remove(struct pci_dev *pdev)
>  
>  	iounmap(vdev->bar0);
>  
> -	pci_disable_sriov(pdev);
> -

And you can never disable sriov.

This doesn't look like the right behaviour.

thanks,
-chris
