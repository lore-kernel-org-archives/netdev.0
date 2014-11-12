From: Andrey Panin <pazke@centrinvest.ru>
Subject: Re: [PATCH v2] VNIC: Adding support for Cavium ThunderX network
 controller
Date: Wed, 12 Nov 2014 17:52:25 +0300
Message-ID: <20141112145225.GD12592@pazechnik.unix.domaincib.ru>
References: <1415596445-10061-1-git-send-email-rric@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rrichter@cavium.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Stephen Hemminger <stephen@networkplumber.org>,
 Stefan Assmann <sassmann@redhat.com>, Sunil Goutham <sgoutham@cavium.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Robert Richter <rric@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1415596445-10061-1-git-send-email-rric@kernel.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 313, 11 09, 2014 at 09:14:05PM -0800, Robert Richter wrote:

I apologize for possibly repeated mail, my mailsystem was misconfigured :(

Some comments from quick look are below.


> +static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> +{
> +	struct device *dev = &pdev->dev;
> +	struct net_device *netdev;
> +	struct nicpf *nic;
> +	int    err;
> +
> +	netdev = alloc_etherdev(sizeof(struct nicpf));
> +	if (!netdev)
> +		return -ENOMEM;
> +
> +	pci_set_drvdata(pdev, netdev);
> +
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +
> +	nic = netdev_priv(netdev);
> +	nic->netdev = netdev;
> +	nic->pdev = pdev;
> +
> +	err = pci_enable_device(pdev);
> +	if (err) {
> +		dev_err(dev, "Failed to enable PCI device\n");
> +		goto exit;

Looks like you leaked netdev here.

> +	}
> +
> +	err = pci_request_regions(pdev, DRV_NAME);
> +	if (err) {
> +		dev_err(dev, "PCI request regions failed 0x%x\n", err);
> +		goto err_disable_device;
> +	}
> +
> +	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(48));
> +	if (err) {
> +		dev_err(dev, "Unable to get usable DMA configuration\n");
> +		goto err_release_regions;
> +	}
> +
> +	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(48));
> +	if (err) {
> +		dev_err(dev, "unable to get 48-bit DMA for consistent allocations\n");
> +		goto err_release_regions;
> +	}
> +
> +	/* MAP PF's configuration registers */
> +	nic->reg_base = (uint64_t)pci_ioremap_bar(pdev, PCI_CFG_REG_BAR_NUM);
> +	if (!nic->reg_base) {
> +		dev_err(dev, "Cannot map config register space, aborting\n");
> +		err = -ENOMEM;
> +		goto err_release_regions;
> +	}
> +	nic->node = NIC_NODE_ID(pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM));
> +
> +	/* By default set NIC in TNS bypass mode */
> +	nic->flags &= ~NIC_TNS_ENABLED;
> +	nic_set_lmac_vf_mapping(nic);
> +
> +	/* Initialize hardware */
> +	nic_init_hw(nic);
> +
> +	/* Set RSS TBL size for each VF */
> +	nic->rss_ind_tbl_size = max((NIC_RSSI_COUNT / nic->num_vf_en),
> +				    NIC_MAX_RSS_IDR_TBL_SIZE);
> +	nic->rss_ind_tbl_size = rounddown_pow_of_two(nic->rss_ind_tbl_size);
> +
> +	/* Register interrupts */
> +	if (nic_register_interrupts(nic))
> +		goto err_unmap_resources;
> +
> +	/* Configure SRIOV */
> +	if (!nic_sriov_init(pdev, nic))
> +		goto err_unmap_resources;
> +
> +	goto exit;

Why not simply return 0; ?

> +
> +err_unmap_resources:
> +	if (nic->reg_base)

This check looks unnecessary.

> +		iounmap((void *)nic->reg_base);
> +err_release_regions:
> +	pci_release_regions(pdev);
> +err_disable_device:
> +	pci_disable_device(pdev);
> +exit:
> +	return err;
> +}


> +static int bgx_register_interrupts(struct bgx *bgx, uint8_t lmac)
> +{
> +	int irq, ret = 0;
> +
> +	/* Register only link interrupts now */
> +	irq = SPUX_INT + (lmac * BGX_LMAC_VEC_OFFSET);
> +	sprintf(bgx->irq_name[irq], "LMAC%d", lmac);
> +	ret = request_irq(bgx->msix_entries[irq].vector,
> +			  bgx_lmac_intr_handler, 0, bgx->irq_name[irq], bgx);
> +	if (ret)
> +		goto fail;
> +	else

This else just hurts readability.

> +		bgx->irq_allocated[irq] = 1;
> +
> +	/* Enable link interrupt */
> +	bgx_enable_link_intr(bgx, lmac);
> +	return 0;
> +
> +fail:

The code below copypasted from bgx_unregister_interrupts()
Looks like good candidate for helper function.

> +	dev_err(&bgx->pdev->dev, "Request irq failed\n");
> +	for (irq = 0; irq < bgx->num_vec; irq++) {
> +		if (bgx->irq_allocated[irq])
> +			free_irq(bgx->msix_entries[irq].vector, bgx);
> +		bgx->irq_allocated[irq] = 0;
> +	}
> +	return 1;
> +}
> +
> +static void bgx_unregister_interrupts(struct bgx *bgx)
> +{
> +	int irq;
> +	/* Free registered interrupts */
> +	for (irq = 0; irq < bgx->num_vec; irq++) {
> +		if (bgx->irq_allocated[irq])
> +			free_irq(bgx->msix_entries[irq].vector, bgx);
> +		bgx->irq_allocated[irq] = 0;
> +	}
> +	/* Disable MSI-X */
> +	bgx_disable_msix(bgx);
> +}
> +

> +void bgx_lmac_enable(struct bgx *bgx, int8_t lmac)
> +{
> +	uint64_t dmac_bcast = (1ULL << 48) - 1;
> +
> +	bgx_reg_write(bgx, lmac, BGX_CMRX_CFG,
> +		      (1 << 15) | (1 << 14) | (1 << 13));
> +
> +	/* Register interrupts */
> +	bgx_register_interrupts(bgx, lmac);

bgx_register_interrupts() can fail (due to request_irq), but it's return
value is not checked.

> +
> +	/* Add broadcast MAC into all LMAC's DMAC filters */
> +	for (lmac = 0; lmac < bgx->lmac_count; lmac++)
> +		bgx_add_dmac_addr(dmac_bcast, 0, bgx->bgx_id, lmac);
> +}

> +static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> +{
> +	struct device *dev = &pdev->dev;
> +	struct bgx *bgx;
> +	int    err;
> +	uint8_t lmac = 0;
> +
> +	bgx = kzalloc(sizeof(*bgx), GFP_KERNEL);

kzalloc() return value not checked

> +	bgx->pdev = pdev;
> +
> +	pci_set_drvdata(pdev, bgx);
> +
> +	err = pci_enable_device(pdev);
> +	if (err) {
> +		dev_err(dev, "Failed to enable PCI device\n");
> +		goto exit;

bgx is leaked here.

> +	}
> +
> +	err = pci_request_regions(pdev, DRV_NAME);
> +	if (err) {
> +		dev_err(dev, "PCI request regions failed 0x%x\n", err);
> +		goto err_disable_device;
> +	}
> +
> +	/* MAP configuration registers */
> +	bgx->reg_base = (uint64_t)pci_ioremap_bar(pdev, PCI_CFG_REG_BAR_NUM);
> +	if (!bgx->reg_base) {
> +		dev_err(dev, "BGX: Cannot map CSR memory space, aborting\n");
> +		err = -ENOMEM;
> +		goto err_release_regions;
> +	}
> +	bgx->bgx_id = (pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM) >> 24) & 1;
> +	bgx->bgx_id += NODE_ID(pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM))
> +							* MAX_BGX_PER_CN88XX;
> +	bgx_vnic[bgx->bgx_id] = bgx;
> +
> +	/* Initialize BGX hardware */
> +	bgx_init_hw(bgx);
> +	/* Enable MSI-X */
> +	if (!bgx_enable_msix(bgx))
> +		return 1;

Massive resource leak here.

> +	/* Enable all LMACs */
> +	for (lmac = 0; lmac < bgx->lmac_count; lmac++)
> +		bgx_lmac_enable(bgx, lmac);

See comment about bgx_lmac_enable() above.

> +	goto exit;
> +

Lines below are unreachable.

> +	if (bgx->reg_base)
> +		iounmap((void *)bgx->reg_base);
> +err_release_regions:
> +	pci_release_regions(pdev);
> +err_disable_device:
> +	pci_disable_device(pdev);
> +exit:
> +	return err;
> +}
