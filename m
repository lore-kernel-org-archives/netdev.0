From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next 5/7] ixgbe: Check register reads for adapter removal
Date: Wed, 8 Jan 2014 00:35:14 -0800
Message-ID: <9C2C4C7C-CF22-4C6B-89B5-583C4C411B21@gmail.com>
References: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com> <1389166847-3780-6-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Mark Rustad <mark.d.rustad@intel.com>,
	Netdev <netdev@vger.kernel.org>, gospo@redhat.com,
	sassmann@redhat.com
To: Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:64004 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbaAHIfT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 03:35:19 -0500
Received: by mail-ig0-f173.google.com with SMTP id ut6so12557238igb.0
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 00:35:19 -0800 (PST)
In-Reply-To: <1389166847-3780-6-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 7, 2014, at 11:40 PM, Aaron Brown <aaron.f.brown@intel.com> wrote:

> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> index 5e157ac..480c5c1 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
> @@ -124,6 +124,11 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw);
> s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw);
> s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw);
> 
> +#define IXGBE_FAILED_READ_REG 0xffffffffU
> +
> +void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg);
> +#define IXGBE_REMOVED(a) unlikely(!(a))

IXGBE_REMOVED seems pretty closely tied to hw->hw_addr, but the macro turns any input into !input.  Maybe an inline that takes a *hw?

> +
> static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 value)
> {
> 	writel(value, hw->hw_addr + reg);
> @@ -144,7 +149,15 @@ static inline void IXGBE_WRITE_REG64(struct ixgbe_hw *hw, u32 reg, u64 value)
> 
> static inline u32 IXGBE_READ_REG(struct ixgbe_hw *hw, u32 reg)
> {
> -	return readl(hw->hw_addr + reg);
> +	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
> +	u32 value;
> +
> +	if (IXGBE_REMOVED(reg_addr))
> +		return IXGBE_FAILED_READ_REG;
> +	value = readl(reg_addr + reg);
> +	if (unlikely(value == IXGBE_FAILED_READ_REG))
> +		ixgbe_check_remove(hw, reg);
> +	return value;
> }
> 
> #define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) \
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 4d71277..896a8b0 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -283,6 +283,35 @@ static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
> 		schedule_work(&adapter->service_task);
> }
> 
> +static void ixgbe_remove_adapter(struct ixgbe_hw *hw)
> +{
> +	struct ixgbe_adapter *adapter = hw->back;
> +
> +	if (!hw->hw_addr)
> +		return;
> +	hw->hw_addr = NULL;
> +	e_dev_err("Adapter removed\n");
> +}
> +
> +void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg)
> +{
> +	u32 value;
> +
> +	/* The following check not only optimizes a bit by not
> +	 * performing a read on the status register when the
> +	 * register just read was a status register read that
> +	 * returned IXGBE_FAILED_READ_REG. It also blocks any
> +	 * potential recursion.
> +	 */
> +	if (reg == IXGBE_STATUS) {
> +		ixgbe_remove_adapter(hw);
> +		return;
> +	}
> +	value = IXGBE_READ_REG(hw, IXGBE_STATUS);
> +	if (value == IXGBE_FAILED_READ_REG)
> +		ixgbe_remove_adapter(hw);
> +}
> +
> static void ixgbe_service_event_complete(struct ixgbe_adapter *adapter)
> {
> 	BUG_ON(!test_bit(__IXGBE_SERVICE_SCHED, &adapter->state));
> @@ -2970,7 +2999,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
> 			ring->count * sizeof(union ixgbe_adv_tx_desc));
> 	IXGBE_WRITE_REG(hw, IXGBE_TDH(reg_idx), 0);
> 	IXGBE_WRITE_REG(hw, IXGBE_TDT(reg_idx), 0);
> -	ring->tail = hw->hw_addr + IXGBE_TDT(reg_idx);
> +	ring->tail = adapter->io_addr + IXGBE_TDT(reg_idx);

How is this related to the commit msg about register reads?  Seems like two patches.

> 
> 	/*
> 	 * set WTHRESH to encourage burst writeback, it should not be set
> @@ -3373,7 +3402,7 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
> 			ring->count * sizeof(union ixgbe_adv_rx_desc));
> 	IXGBE_WRITE_REG(hw, IXGBE_RDH(reg_idx), 0);
> 	IXGBE_WRITE_REG(hw, IXGBE_RDT(reg_idx), 0);
> -	ring->tail = hw->hw_addr + IXGBE_RDT(reg_idx);
> +	ring->tail = adapter->io_addr + IXGBE_RDT(reg_idx);
> 
> 	ixgbe_configure_srrctl(adapter, ring);
> 	ixgbe_configure_rscctl(adapter, ring);
> @@ -7887,6 +7916,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> 
> 	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
> 			      pci_resource_len(pdev, 0));
> +	adapter->io_addr = hw->hw_addr;
> 	if (!hw->hw_addr) {
> 		err = -EIO;
> 		goto err_ioremap;
> @@ -8195,7 +8225,7 @@ err_register:
> err_sw_init:
> 	ixgbe_disable_sriov(adapter);
> 	adapter->flags2 &= ~IXGBE_FLAG2_SEARCH_FOR_SFP;
> -	iounmap(hw->hw_addr);
> +	iounmap(adapter->io_addr);
> err_ioremap:
> 	free_netdev(netdev);
> err_alloc_etherdev:
> @@ -8262,7 +8292,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
> 	kfree(adapter->ixgbe_ieee_ets);
> 
> #endif
> -	iounmap(adapter->hw.hw_addr);
> +	iounmap(adapter->io_addr);
> 	pci_release_selected_regions(pdev, pci_select_bars(pdev,
> 				     IORESOURCE_MEM));
> 
> -- 
> 1.8.5.GIT
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
