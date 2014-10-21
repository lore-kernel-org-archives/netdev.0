From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/5] stmmac: pci: use managed resources
Date: Wed, 22 Oct 2014 00:55:03 +0400
Message-ID: <5446C827.2040801@cogentembedded.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com> <1413909333-16380-3-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:40185 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932723AbaJUUzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 16:55:08 -0400
Received: by mail-lb0-f169.google.com with SMTP id 10so1745876lbg.14
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 13:55:06 -0700 (PDT)
In-Reply-To: <1413909333-16380-3-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/21/2014 08:35 PM, Andy Shevchenko wrote:

> Migrate pci driver to managed resources to reduce boilerplate error handling
> code.

> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 46 +++++-------------------
>   1 file changed, 8 insertions(+), 38 deletions(-)

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index 5459a4e..f8d4ce2 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -65,45 +65,29 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
>   			    const struct pci_device_id *id)
>   {
>   	int ret = 0;
> -	void __iomem *addr = NULL;
>   	struct stmmac_priv *priv = NULL;
> -	int i;
> +	int pci_bar = 0;

    I don't see this variable changing anywhere...

>   	/* Enable pci device */
> -	ret = pci_enable_device(pdev);
> +	ret = pcim_enable_device(pdev);
>   	if (ret) {
>   		pr_err("%s : ERROR: failed to enable %s device\n", __func__,
>   		       pci_name(pdev));
>   		return ret;
>   	}
> -	if (pci_request_regions(pdev, STMMAC_RESOURCE_NAME)) {
> -		pr_err("%s: ERROR: failed to get PCI region\n", __func__);
> -		ret = -ENODEV;
> -		goto err_out_req_reg_failed;
> -	}
> +	ret = pcim_iomap_regions(pdev, BIT(pci_bar), pci_name(pdev));
> +	if (ret)
> +		return ret;
>
> -	/* Get the base address of device */
> -	for (i = 0; i <= 5; i++) {
> -		if (pci_resource_len(pdev, i) == 0)
> -			continue;
> -		addr = pci_iomap(pdev, i, 0);
> -		if (addr == NULL) {
> -			pr_err("%s: ERROR: cannot map register memory aborting",
> -			       __func__);
> -			ret = -EIO;
> -			goto err_out_map_failed;
> -		}
> -		break;
> -	}

    It's not an equivalent change: the old code mapped a first existing BAR, 
you always map BAR0. Are you sure that's what you meant? If so, wouldn't hurt 
to describe this in the changelog...

WBR, Sergei
