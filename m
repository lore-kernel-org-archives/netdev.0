From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/6] [RFC] qlge: New Driver: Adding main driver file qlge_main.c.
Date: Tue, 26 Aug 2008 12:24:21 +0100
Message-ID: <20080826112420.GY7908@solarflare.com>
References: <20080822200906.GD2551@susedev.qlogic.org> <12194364662050-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:40589 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752641AbYHZLYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:24:25 -0400
Content-Disposition: inline
In-Reply-To: <12194364662050-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer wrote:
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qlge/qlge_main.c | 4350 ++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 4350 insertions(+), 0 deletions(-)
>  create mode 100755 drivers/net/qlge/qlge_main.c
> 
> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> new file mode 100755
> index 0000000..0aa472f
> --- /dev/null
> +++ b/drivers/net/qlge/qlge_main.c
[...]
> +#include <linux/version.h>

Should never be used in an in-tree driver.  (Doesn't checkpatch.pl warn
about this?)

[...]
> +#if 0
> +static int ql_update_ring_coalescing(struct ql_adapter *qdev)
> +{

Why are all the ethtool operation implementations disabled?  If they are
broken in some way, I think they should be left out now and added later.

[...]
> +static void ql_update_buffer_queues(struct ql_adapter *qdev,
> +				    struct rx_ring *rx_ring)
> +{
> +	if (rx_ring->sbq_len) ql_update_sbq(qdev, rx_ring);
> +	if (rx_ring->lbq_len) ql_update_lbq(qdev, rx_ring);
> +}

The body of an if-statement always starts on the next line, as checkpatch.pl
will tell you.

[...]
> +static void ql_enable_msix(struct ql_adapter *qdev)
> +{
> +	int i;
> +
> +	qdev->intr_count = 1;
> +	/* Get the MSIX vectors. */
> +	if (irq_type == MSIX_IRQ) {
> +		/* Try to alloc space for the msix struct,
> +		 * if it fails then go to MSI/legacy.
> +		 */
> +		qdev->msi_x_entry = kcalloc(qdev->rx_ring_count,
> +					    sizeof(struct msix_entry),
> +					    GFP_KERNEL);
> +		if (!qdev->msi_x_entry) {
> +			irq_type = MSI_IRQ;
> +			goto msi;
> +		}
> +
> +		for (i = 0; i < qdev->rx_ring_count; i++)
> +			qdev->msi_x_entry[i].entry = i;
> +
> +		if (!pci_enable_msix
> +		    (qdev->pdev, qdev->msi_x_entry, qdev->rx_ring_count)) {
> +			set_bit(QL_MSIX_ENABLED, &qdev->flags);
> +			qdev->intr_count = qdev->rx_ring_count;
> +			QPRINTK(IFUP, INFO,
> +				"MSI-X Enabled, got %d vectors.\n",
> +				qdev->intr_count);
> +			return;
> +		} else {
> +			kfree(qdev->msi_x_entry);
> +			qdev->msi_x_entry = NULL;
> +			QPRINTK(IFUP, WARNING,
> +				"MSI-X Enable failed, trying MSI.\n");
> +			irq_type = MSI_IRQ;

If pci_enable_msix() returns a positive number, that's a hint as to how
many IRQs you should be able to allocate.  It may be worth retrying with
that number.

[...]
> +static int ql_adapter_initialize(struct ql_adapter *qdev)
> +{
> +	u32 value, mask;
> +	int i;
> +	int status = 0;
> +
> +	/*
> +	 * Set up the System register to halt on errors.
> +	 */
> +	value = SYS_EFE | SYS_FAE;
> +	mask = value << 16;
> +	ql_write32(qdev, SYS, mask | value);
> +
> +	/* Set the default queue. */
> +	value = NIC_RCV_CFG_DFQ;
> +	mask = NIC_RCV_CFG_DFQ_MASK;
> +	ql_write32(qdev, NIC_RCV_CFG, (mask | value));
> +
> +	/* Set the MPI interrupt to enabled. */
> +	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16) | INTR_MASK_PI);
> +
> +	/* Enable the function, set pagesize, enable error checking. */
> +	value = FSC_FE | FSC_EPC_INBOUND | FSC_EPC_OUTBOUND | FSC_EC;
> +
> +	if (PAGE_SHIFT == 12)	/* 4k pages */
> +		value |= FSC_VM_PAGE_4K;
> +	else if (PAGE_SHIFT == 13)	/* 8k pages */
> +		value |= FSC_VM_PAGE_8K;
> +	else if (PAGE_SHIFT == 16)	/* 64k pages */
> +		value |= FSC_VM_PAGE_64K;
> +	else {
> +		QPRINTK(IFUP, ERR, "Invalid page size of %d.\n",
> +			1 << PAGE_SHIFT);

You can use
	BUILD_BUG_ON(PAGE_SHIFT != 12 && PAGE_SHIFT != 13 && PAGE_SHIFT != 16);
to detect this problem at compile time.

Why doesn't this function do any cleanup in case of failure part way
through?

[...]
> +static int ql_configure_rings(struct ql_adapter *qdev)
> +{
> +	int i;
> +	struct rx_ring *rx_ring;
> +	struct tx_ring *tx_ring;
> +	int cpu_cnt = num_online_cpus();
> +
> +	/*
> +	 * For each processor present we allocate one
> +	 * rx_ring for outbound completions, and one

Typo: should be "tx_ring".

[...]
> +static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
> +{
> +	struct ql_adapter *qdev = netdev_priv(ndev);
> +
> +	if (ndev->mtu == 1500 && new_mtu == 9000) {
> +		QPRINTK(IFUP, ERR, "Turning on split headers.\n");
> +		ql_write32(qdev, FSC, (FSC_SH << 16) | FSC_SH);
> +		if (ql_set_framesize(qdev, JUMBO_FRAME_SIZE))
> +			return -EIO;
> +	} else if (ndev->mtu == 9000 && new_mtu == 1500) {
> +		QPRINTK(IFUP, ERR, "Turning off split headers.\n");
> +		ql_write32(qdev, FSC, (FSC_SH << 16));
> +		if (ql_set_framesize(qdev, NORMAL_FRAME_SIZE))
> +			return -EIO;
> +	} else if ((ndev->mtu == 1500 && new_mtu == 1500) ||
> +		   (ndev->mtu == 9000 && new_mtu == 9000)) {
> +		return 0;
> +	} else
> +		return -EINVAL;
[...]

This would be a whole lot easier to follow if written as:

	if (ndev->mtu == new_mtu)
		return 0;
	else if (new_mtu == 1500)
		...
	else if (new_mtu == 9000)
		...
	else
		return -EINVAL;

But why don't you support MTUs other than 1500 and 9000?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
