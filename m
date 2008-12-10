From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 01/11] benet: header and init functions
Date: Thu, 11 Dec 2008 00:03:14 +0100
Message-ID: <20081210230314.GB30537@electric-eye.fr.zoreil.com>
References: <1228832384.6435.94.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, jgarzik@pobox.com,
	jeff@garzik.org, subbu <subbus@serverengines.com>
To: Sathya Perla <sathyap@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58808 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753266AbYLJXDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 18:03:24 -0500
Content-Disposition: inline
In-Reply-To: <1228832384.6435.94.camel@sperla-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sathya Perla <sathyap@serverengines.com> :
[...]
> diff --git a/drivers/net/benet/be_init.c b/drivers/net/benet/be_init.c
> new file mode 100644
> index 0000000..06fb343
> --- /dev/null
> +++ b/drivers/net/benet/be_init.c
[...]
> +static int
> +init_pci_be_function(struct be_adapter *adapter, struct pci_dev *pdev)
> +{
> +	u64 pa;
> +
> +	/* CSR */
> +	pa = pci_resource_start(pdev, 2);
> +	adapter->csr_va = ioremap_nocache(pa, pci_resource_len(pdev, 2));
> +	if (adapter->csr_va == NULL)
> +		return -ENOMEM;
> +
> +	/* Door Bell */
> +	pa = pci_resource_start(pdev, 4);
> +	adapter->db_va = ioremap_nocache(pa, (128 * 1024));
> +	if (adapter->db_va == NULL) {
> +		iounmap(adapter->csr_va);
> +		return -ENOMEM;
> +	}
> +
> +	/* PCI */
> +	pa = pci_resource_start(pdev, 1);
> +	adapter->pci_va = ioremap_nocache(pa, pci_resource_len(pdev, 1));
> +	if (adapter->pci_va == NULL) {
> +		iounmap(adapter->csr_va);
> +		iounmap(adapter->db_va);
> +		return -ENOMEM;
> +	}

This error path could use gotos.

[...]
> +static int be_register_isr(struct be_adapter *adapter,
> +		struct be_net_object *pnob)
> +{
> +	struct net_device *netdev = pnob->netdev;
> +	int intx = 0, r;
> +
> +	netdev->irq = adapter->pdev->irq;
> +	r = be_enable_msix(adapter);
> +
> +	if (r == 0) {
> +		r = request_irq(adapter->msix_entries[0].vector,
> +				be_int, IRQF_SHARED, netdev->name, netdev);
> +		if (r) {
> +			printk(KERN_WARNING
> +				"MSIX Request IRQ failed - Errno %d\n", r);

This printk will be of moderate help in the middle of a kilometer long
dmesg. You may use dev_warn and friends to identify the emitter of the
warning.

> +			intx = 1;
> +			pci_disable_msix(adapter->pdev);
> +			adapter->msix_enabled = 0;
> +		}
> +	} else {
> +		intx = 1;
> +	}
> +
> +	if (intx) {
> +		r = request_irq(netdev->irq, be_int, IRQF_SHARED,
> +				netdev->name, netdev);

be_int is not known in this patch.

> +		if (r) {
> +			printk(KERN_WARNING
> +				"INTx Request IRQ failed - Errno %d\n", r);
> +			return -1;

Please propagate "r" as a status code up to the highest level caller.

If you really need some error status code of you own, you may
consider using Exxx (ENOMEM, EBUSY, etc.) ones.

[...]
> +static void be_rx_q_clean(struct be_net_object *pnob)
> +{
> +	if (pnob->rx_ctxt) {
> +		int i;
> +		struct be_rx_page_info *rx_page_info;
> +		for (i = 0; i < pnob->rx_q_len; i++) {

Please insert a blank line between the declaration and the code.

[...]
> +static int be_nob_ring_alloc(struct be_adapter *adapter,
> +	struct be_net_object *pnob)
> +{
> +	u32 size;
> +
> +	/* Mail box rd; mailbox pointer needs to be 16 byte aligned */
> +	pnob->mb_size = sizeof(struct MCC_MAILBOX_AMAP) + 16;
> +	pnob->mb_ptr = pci_alloc_consistent(adapter->pdev, pnob->mb_size,
> +				&pnob->mb_bus);
> +	if (!pnob->mb_bus)
> +		return -1;

return -ENOMEM ?

[...]
> +static void be_remove(struct pci_dev *pdev)
> +{
> +	struct be_net_object *pnob;
> +	struct be_adapter *adapter;
> +
> +	adapter = pci_get_drvdata(pdev);
> +	if (!adapter)
> +		return;
> +
> +	pci_set_drvdata(pdev, NULL);
> +	pnob = (struct be_net_object *)adapter->net_obj;
> +
> +	flush_scheduled_work();
> +
> +	if (pnob) {
> +		/* Unregister async callback function for link status updates */
> +		if (pnob->mcc_q_created)
> +			be_mcc_add_async_event_callback(&pnob->mcc_q_obj,

be_mcc_add_async_event_callback is not defined in this patch.

[...]
> +static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
> +{
> +	int status = 0;

Useless initialization.

> +	struct be_adapter *adapter;
> +	struct FWCMD_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD get_fwv;
> +	struct be_net_object *pnob;
> +	struct net_device *netdev;
> +
> +	status = pci_enable_device(pdev);
> +	if (status)
> +		goto error;
> +
> +	status = pci_request_regions(pdev, be_driver_name);
> +	if (status)
> +		goto error_pci_req;
> +
> +	pci_set_master(pdev);

The adapter is never used with bioses which could leave it ready
to DMA into memory before linux is started, right ?

Otherwise we are in trouble.

[...]
> +	status = be_register_isr(adapter, pnob);
> +	if (status != 0)
> +		goto cleanup;

I have not seen where the device is reset before registering the irq.

[...]
> +void be_update_link_status(struct be_adapter *adapter)
> +{
> +	int status;
> +	struct be_net_object *pnob = adapter->net_obj;
> +
> +	status = be_rxf_link_status(&pnob->fn_obj, adapter->be_link_sts, NULL,

be_rxf_link_status is not defined in this patch.

[...]
> +static int be_suspend(struct pci_dev *pdev, pm_message_t state)
> +{
> +	struct be_adapter *adapter = pci_get_drvdata(pdev);
> +	struct net_device *netdev =  adapter->netdevp;
> +	struct be_net_object *pnob = (struct be_net_object *)netdev->priv;
> +
> +	adapter->dev_pm_state = adapter->dev_state;
> +	adapter->dev_state = BE_DEV_STATE_SUSPEND;
> +
> +	netif_device_detach(netdev);
> +	if (netif_running(netdev))
> +		be_pm_cleanup(adapter, pnob, netdev);
> +
> +	pci_enable_wake(pdev, 3, 1);
> +	pci_enable_wake(pdev, 4, 1);	/* D3 Cold = 4 */

You can use PCI_D3hot and PCI_D3cold.

-- 
Ueimor
