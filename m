From: David Miller <davem@davemloft.net>
Subject: Re: pch_gbe: set dma mask to only 32 bit
Date: Wed, 08 Feb 2012 20:06:02 -0500 (EST)
Message-ID: <20120208.200602.200734891435792991.davem@davemloft.net>
References: <20120207192354.GA7770@darkmag.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, toshiharu-linux@dsn.okisemi.com,
	paul.gortmaker@windriver.com, mirq-linux@rere.qmqm.pl
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757943Ab2BIBHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 20:07:13 -0500
In-Reply-To: <20120207192354.GA7770@darkmag.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 7 Feb 2012 20:23:54 +0100

> Because pch_gbe_rx_desc->buffer_addr is u32, we cannot set dma mask to 64
> bit or otherwise we could end up loosing the higher 32 bit from the return
> of dma_map_single(). Removing DMA_BIT_MASK(64) setting will solve it.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

The logic here makes no sense.

> -	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64))
> -		|| pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
> -		ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
> +	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
> +		ret = pci_set_consistent_dma_mask(pdev,
> +						  DMA_BIT_MASK(32));

You want to take this branch on success, not failure.  pci_set_dma_mask()
returns 0 on success.

Something like:

	ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
	if (ret ||
	    (ret = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))) {
		dev_err(&pdev->dev, "ERR: No usable DMA "
			"configuration, aborting\n");
		goto err_disable_device;
	}
