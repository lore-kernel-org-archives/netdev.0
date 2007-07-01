From: Michael Buesch <mb@bu3sch.de>
Subject: Re: RESEND [PATCH 2/3] NetXen: Support per PCI-function interrupt mask registers
Date: Sun, 1 Jul 2007 11:27:49 +0200
Message-ID: <200707011127.49766.mb@bu3sch.de>
References: <20070701024325.287283308@netxen.com> <20070701024730.494758559@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@netxen.com
To: dhananjay.phadke@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54076
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161AbXGAJ2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 05:28:37 -0400
In-Reply-To: <20070701024730.494758559@netxen.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 01 July 2007 04:43:27 dhananjay.phadke@gmail.com wrote:
> This patch updates the various access routines to access different
> control and status settings present in different register locations.
> This will fix problems related to working of different ports in
> multi Port card.
> 
> Signed-off by: Dhananjay Phadke <dhananjay@netxen.com>
> Signed-off by: Milan Bag <mbag@netxen.com>
> 
> Index: netdev-2.6/drivers/net/netxen/netxen_nic.h
> ===================================================================
> --- netdev-2.6.orig/drivers/net/netxen/netxen_nic.h
> +++ netdev-2.6/drivers/net/netxen/netxen_nic.h
> @@ -937,6 +937,7 @@ struct netxen_adapter {
>  	struct netxen_ring_ctx *ctx_desc;
>  	struct pci_dev *ctx_desc_pdev;
>  	dma_addr_t ctx_desc_phys_addr;
> +	int intr_scheme;
>  	int (*enable_phy_interrupts) (struct netxen_adapter *);
>  	int (*disable_phy_interrupts) (struct netxen_adapter *);
>  	void (*handle_phy_intr) (struct netxen_adapter *);
> @@ -1080,37 +1081,103 @@ struct net_device_stats *netxen_nic_get_
>  
>  static inline void netxen_nic_disable_int(struct netxen_adapter *adapter)
>  {
> -	/*
> -	 * ISR_INT_MASK: Can be read from window 0 or 1.
> -	 */
> -	writel(0x7ff, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
> +	uint32_t	mask = 0x7ff;
> +	int count = 0;
>  
> +	DPRINTK(1, INFO, "Entered ISR Disable \n");
> +
> +	switch (adapter->portnum) {
> +	case 0:
> +		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
> +		break;
> +	case 1:
> +		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
> +		break;
> +	case 2:
> +		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
> +		break;
> +	case 3:
> +		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
> +		break;
> +	}
> +
> +	if (adapter->intr_scheme != -1 &&
> +		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
> +		writel(mask,
> +			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
> +	}
> +
> +	/* Window = 0 or 1 */
> +	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
> +		do {
> +			writel(0xffffffff, (void *)
> +				(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_STATUS)));
> +			mask = readl((void *)
> +					(pci_base_offset(adapter, ISR_INT_VECTOR)));
> +			udelay(10);

This needlessly always delays at least 10 uS, even if it succeed on the
first attempt.
Better do it like I suggested to avoid that.

-- 
Greetings Michael.
