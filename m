From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH v2 2/2] net: ixgbe: implement af_packet direct queue
 mappings
Date: Tue, 13 Jan 2015 13:05:30 +0100
Message-ID: <1421150730.13626.14.camel@stressinduktion.org>
References: <20150113043509.29985.33515.stgit@nitbit.x32>
	 <20150113043542.29985.15658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, dborkman@redhat.com, john.ronciak@intel.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:49744 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751347AbbAMMFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 07:05:34 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id D0FB020A06
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 07:05:33 -0500 (EST)
In-Reply-To: <20150113043542.29985.15658.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2015-01-12 at 20:35 -0800, John Fastabend wrote:
> +static int
> +ixgbe_ndo_qpair_page_map(struct vm_area_struct *vma, struct net_device *dev)
> +{
> +	struct ixgbe_adapter *adapter = netdev_priv(dev);
> +	phys_addr_t phy_addr = pci_resource_start(adapter->pdev, 0);
> +	unsigned long pfn_rx = (phy_addr + RX_DESC_ADDR_OFFSET) >> PAGE_SHIFT;
> +	unsigned long pfn_tx = (phy_addr + TX_DESC_ADDR_OFFSET) >> PAGE_SHIFT;
> +	unsigned long dummy_page_phy;
> +	pgprot_t pre_vm_page_prot;
> +	unsigned long start;
> +	unsigned int i;
> +	int err;
> +
> +	if (!dummy_page_buf) {
> +		dummy_page_buf = kzalloc(PAGE_SIZE_4K, GFP_KERNEL);
> +		if (!dummy_page_buf)
> +			return -ENOMEM;
> +
> +		for (i = 0; i < PAGE_SIZE_4K / sizeof(unsigned int); i++)
> +			dummy_page_buf[i] = 0xdeadbeef;
> +	}
> +
> +	dummy_page_phy = virt_to_phys(dummy_page_buf);
> +	pre_vm_page_prot = vma->vm_page_prot;
> +	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> +
> +	/* assume the vm_start is 4K aligned address */
> +	for (start = vma->vm_start;
> +	     start < vma->vm_end;
> +	     start += PAGE_SIZE_4K) {
> +		if (start == vma->vm_start + RX_DESC_ADDR_OFFSET) {
> +			err = remap_pfn_range(vma, start, pfn_rx, PAGE_SIZE_4K,
> +					      vma->vm_page_prot);
> +			if (err)
> +				return -EAGAIN;
> +		} else if (start == vma->vm_start + TX_DESC_ADDR_OFFSET) {
> +			err = remap_pfn_range(vma, start, pfn_tx, PAGE_SIZE_4K,
> +					      vma->vm_page_prot);
> +			if (err)
> +				return -EAGAIN;
> +		} else {
> +			unsigned long addr = dummy_page_phy > PAGE_SHIFT;

I guess you have forgotten to delete this line?

> +
> +			err = remap_pfn_range(vma, start, addr, PAGE_SIZE_4K,
> +					      pre_vm_page_prot);
> +			if (err)
> +				return -EAGAIN;
> +		}
> +	}
> +	return 0;
> +}
