From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 09/12] IXGBEVF: Add live migration support for VF
 driver
Date: Wed, 21 Oct 2015 14:48:35 -0700
Message-ID: <56280833.9030004@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <1445445464-5056-10-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-10-git-send-email-tianyu.lan@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 09:37 AM, Lan Tianyu wrote:
> To let VF driver in the guest to know migration status, Qemu will
> fake PCI configure reg 0xF0 and 0xF1 to show migrate status and
> get ack from VF driver.
>
> When migration starts, Qemu will set reg "0xF0" to 1, notify
> VF driver via triggering mail box msg and wait for VF driver to tell
> it's ready for migration(set reg "0xF1" to 1). After migration, Qemu
> will set reg "0xF0" to 0 and notify VF driver by mail box irq. VF
> driver begins to restore tx/rx function after detecting sttatus change.
>
> When VF receives mail box irq, it will check reg "0xF0" in the service
> task function to get migration status and performs related operations
> according its value.
>
> Steps of restarting receive and transmit function
> 1) Restore VF status in the PF driver via sending mail event to PF driver
> 2) Write back reg values recorded by self emulation layer
> 3) Restart rx/tx ring
> 4) Recovery interrupt
>
> Transmit/Receive descriptor head regs are read-only and can't
> be restored via writing back recording reg value directly and they
> are set to 0 during VF reset. To reuse original tx/rx rings, shift
> desc ring in order to move the desc pointed by original head reg to
> first entry of the ring and then enable tx/rx rings. VF restarts to
> receive and transmit from original head desc.
>
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbevf/defines.h       |   6 ++
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |   7 +-
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  | 115 ++++++++++++++++++++-
>   .../net/ethernet/intel/ixgbevf/self-emulation.c    | 107 +++++++++++++++++++
>   4 files changed, 232 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
> index 770e21a..113efd2 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/defines.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
> @@ -239,6 +239,12 @@ struct ixgbe_adv_tx_context_desc {
>   	__le32 mss_l4len_idx;
>   };
>
> +union ixgbevf_desc {
> +	union ixgbe_adv_tx_desc rx_desc;
> +	union ixgbe_adv_rx_desc tx_desc;
> +	struct ixgbe_adv_tx_context_desc tx_context_desc;
> +};
> +
>   /* Adv Transmit Descriptor Config Masks */
>   #define IXGBE_ADVTXD_DTYP_MASK	0x00F00000 /* DTYP mask */
>   #define IXGBE_ADVTXD_DTYP_CTXT	0x00200000 /* Advanced Context Desc */
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> index c823616..6eab402e 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> @@ -109,7 +109,7 @@ struct ixgbevf_ring {
>   	struct ixgbevf_ring *next;
>   	struct net_device *netdev;
>   	struct device *dev;
> -	void *desc;			/* descriptor ring memory */
> +	union ixgbevf_desc *desc;	/* descriptor ring memory */
>   	dma_addr_t dma;			/* phys. address of descriptor ring */
>   	unsigned int size;		/* length in bytes */
>   	u16 count;			/* amount of descriptors */
> @@ -493,6 +493,11 @@ extern void ixgbevf_write_eitr(struct ixgbevf_q_vector *q_vector);
>
>   void ixgbe_napi_add_all(struct ixgbevf_adapter *adapter);
>   void ixgbe_napi_del_all(struct ixgbevf_adapter *adapter);
> +int ixgbevf_tx_ring_shift(struct ixgbevf_ring *r, u32 head);
> +int ixgbevf_rx_ring_shift(struct ixgbevf_ring *r, u32 head);
> +void ixgbevf_restore_state(struct ixgbevf_adapter *adapter);
> +inline void ixgbevf_irq_enable(struct ixgbevf_adapter *adapter);
> +
>
>   #ifdef DEBUG
>   char *ixgbevf_get_hw_dev_name(struct ixgbe_hw *hw);
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index 056841c..15ec361 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -91,6 +91,10 @@ MODULE_DESCRIPTION("Intel(R) 10 Gigabit Virtual Function Network Driver");
>   MODULE_LICENSE("GPL");
>   MODULE_VERSION(DRV_VERSION);
>
> +
> +#define MIGRATION_COMPLETED   0x00
> +#define MIGRATION_IN_PROGRESS 0x01
> +
>   #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
>   static int debug = -1;
>   module_param(debug, int, 0);
> @@ -221,6 +225,78 @@ static u64 ixgbevf_get_tx_completed(struct ixgbevf_ring *ring)
>   	return ring->stats.packets;
>   }
>
> +int ixgbevf_tx_ring_shift(struct ixgbevf_ring *r, u32 head)
> +{
> +	struct ixgbevf_tx_buffer *tx_buffer = NULL;
> +	static union ixgbevf_desc *tx_desc = NULL;
> +
> +	tx_buffer = vmalloc(sizeof(struct ixgbevf_tx_buffer) * (r->count));
> +	if (!tx_buffer)
> +		return -ENOMEM;
> +
> +	tx_desc = vmalloc(sizeof(union ixgbevf_desc) * r->count);
> +	if (!tx_desc)
> +		return -ENOMEM;
> +
> +	memcpy(tx_desc, r->desc, sizeof(union ixgbevf_desc) * r->count);
> +	memcpy(r->desc, &tx_desc[head], sizeof(union ixgbevf_desc) * (r->count - head));
> +	memcpy(&r->desc[r->count - head], tx_desc, sizeof(union ixgbevf_desc) * head);
> +
> +	memcpy(tx_buffer, r->tx_buffer_info, sizeof(struct ixgbevf_tx_buffer) * r->count);
> +	memcpy(r->tx_buffer_info, &tx_buffer[head], sizeof(struct ixgbevf_tx_buffer) * (r->count - head));
> +	memcpy(&r->tx_buffer_info[r->count - head], tx_buffer, sizeof(struct ixgbevf_tx_buffer) * head);
> +
> +	if (r->next_to_clean >= head)
> +		r->next_to_clean -= head;
> +	else
> +		r->next_to_clean += (r->count - head);
> +
> +	if (r->next_to_use >= head)
> +		r->next_to_use -= head;
> +	else
> +		r->next_to_use += (r->count - head);
> +
> +	vfree(tx_buffer);
> +	vfree(tx_desc);
> +	return 0;
> +}
> +
> +int ixgbevf_rx_ring_shift(struct ixgbevf_ring *r, u32 head)
> +{
> +	struct ixgbevf_rx_buffer *rx_buffer = NULL;
> +	static union ixgbevf_desc *rx_desc = NULL;
> +
> +	rx_buffer = vmalloc(sizeof(struct ixgbevf_rx_buffer) * (r->count));
> +	if (!rx_buffer)
> +		return -ENOMEM;
> +
> +	rx_desc = vmalloc(sizeof(union ixgbevf_desc) * (r->count));
> +	if (!rx_desc)
> +		return -ENOMEM;
> +
> +	memcpy(rx_desc, r->desc, sizeof(union ixgbevf_desc) * (r->count));
> +	memcpy(r->desc, &rx_desc[head], sizeof(union ixgbevf_desc) * (r->count - head));
> +	memcpy(&r->desc[r->count - head], rx_desc, sizeof(union ixgbevf_desc) * head);
> +
> +	memcpy(rx_buffer, r->rx_buffer_info, sizeof(struct ixgbevf_rx_buffer) * (r->count));
> +	memcpy(r->rx_buffer_info, &rx_buffer[head], sizeof(struct ixgbevf_rx_buffer) * (r->count - head));
> +	memcpy(&r->rx_buffer_info[r->count - head], rx_buffer, sizeof(struct ixgbevf_rx_buffer) * head);
> +
> +	if (r->next_to_clean >= head)
> +		r->next_to_clean -= head;
> +	else
> +		r->next_to_clean += (r->count - head);
> +
> +	if (r->next_to_use >= head)
> +		r->next_to_use -= head;
> +	else
> +		r->next_to_use += (r->count - head);
> +
> +	vfree(rx_buffer);
> +	vfree(rx_desc);
> +	return 0;
> +}
> +
>   static u32 ixgbevf_get_tx_pending(struct ixgbevf_ring *ring)
>   {
>   	struct ixgbevf_adapter *adapter = netdev_priv(ring->netdev);
> @@ -1122,7 +1198,7 @@ static int ixgbevf_busy_poll_recv(struct napi_struct *napi)
>    * ixgbevf_configure_msix sets up the hardware to properly generate MSI-X
>    * interrupts.
>    **/
> -static void ixgbevf_configure_msix(struct ixgbevf_adapter *adapter)
> +static  void ixgbevf_configure_msix(struct ixgbevf_adapter *adapter)
>   {
>   	struct ixgbevf_q_vector *q_vector;
>   	int q_vectors, v_idx;
> @@ -1534,7 +1610,7 @@ static inline void ixgbevf_irq_disable(struct ixgbevf_adapter *adapter)
>    * ixgbevf_irq_enable - Enable default interrupt generation settings
>    * @adapter: board private structure
>    **/
> -static inline void ixgbevf_irq_enable(struct ixgbevf_adapter *adapter)
> +inline void ixgbevf_irq_enable(struct ixgbevf_adapter *adapter)
>   {
>   	struct ixgbe_hw *hw = &adapter->hw;
>
> @@ -2901,6 +2977,36 @@ static void ixgbevf_watchdog_subtask(struct ixgbevf_adapter *adapter)
>   	ixgbevf_update_stats(adapter);
>   }
>
> +int ixgbevf_live_mg(struct ixgbevf_adapter *adapter)
> +{
> +	struct pci_dev *pdev = adapter->pdev;
> + 	static int migration_status = MIGRATION_COMPLETED;
> +	u8 val;
> +
> +	if (migration_status == MIGRATION_COMPLETED) {
> +		pci_read_config_byte(pdev, 0xf0, &val);
> +		if (!val)
> +			return 0;
> +
> +		del_timer_sync(&adapter->service_timer);
> +		pr_info("migration start\n");
> +		migration_status = MIGRATION_IN_PROGRESS;
> +
> +		/* Tell Qemu VF is ready for migration. */
> +		pci_write_config_byte(pdev, 0xf1, 0x1);
> +		return 1;
> +	} else {
> +		pci_read_config_byte(pdev, 0xf0, &val);
> +		if (val)
> +			return 1;
> +
> +		ixgbevf_restore_state(adapter);
> +		migration_status = MIGRATION_COMPLETED;
> +		pr_info("migration end\n");
> +		return 0;
> +	}
> +}
> +

Correct me if I'm wrong but isn't migration_status going to affect all 
VFs on a given system?  Seems like that might be a bit racy if you were 
to have a VM with more than one VF present.  It seems to me 
migration_status should probably be a part of the adapter or hw structs.

>   /**
>    * ixgbevf_service_task - manages and runs subtasks
>    * @work: pointer to work_struct containing our data
> @@ -2912,6 +3018,11 @@ static void ixgbevf_service_task(struct work_struct *work)
>   						       service_task);
>   	struct ixgbe_hw *hw = &adapter->hw;
>
> +	if (ixgbevf_live_mg(adapter)) {
> +		ixgbevf_service_event_complete(adapter);
> +		return;
> +	}
> +
>   	if (IXGBE_REMOVED(hw->hw_addr)) {
>   		if (!test_bit(__IXGBEVF_DOWN, &adapter->state)) {
>   			rtnl_lock();
> diff --git a/drivers/net/ethernet/intel/ixgbevf/self-emulation.c b/drivers/net/ethernet/intel/ixgbevf/self-emulation.c
> index d74b2da..4476428 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/self-emulation.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/self-emulation.c
> @@ -9,6 +9,8 @@
>
>   static u32 hw_regs[0x4000];
>
> +#define RESTORE_REG(hw, reg) IXGBE_WRITE_REG(hw, reg, hw_regs[reg])
> +
>   u32 ixgbe_self_emul_readl(volatile void __iomem *base, u32 addr)
>   {
>   	u32 tmp;
> @@ -24,3 +26,108 @@ void ixgbe_self_emul_writel(u32 val, volatile void __iomem *base, u32  addr)
>   	hw_regs[(unsigned long)addr] = val;
>   	writel(val, (volatile void __iomem *)(base + addr));
>   }
> +
> +static u32 restore_regs[] = {
> +	IXGBE_VTIVAR(0),
> +	IXGBE_VTIVAR(1),
> +	IXGBE_VTIVAR(2),
> +	IXGBE_VTIVAR(3),
> +	IXGBE_VTIVAR_MISC,
> +	IXGBE_VTEITR(0),
> +	IXGBE_VTEITR(1),
> +	IXGBE_VFPSRTYPE,
> +};
> +

Most of these registers don't need to be copied over.  They can just be 
configured from their existing values.  For example the IVARs have a 
function that already exist to configure them.  You could probably get 
away with just calling ixgbevf_configure_msix to restore most of that 
information.  Same thing for EITR and PSRTYPE.  The fact is most of this 
doesn't need to be saved and could just be reconfigured based on 
power-on values.

> +void ixgbevf_restore_state(struct ixgbevf_adapter *adapter)
> +{
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	struct ixgbe_mbx_info *mbx = &hw->mbx;
> +	int i;
> +	u32 timeout = IXGBE_VF_INIT_TIMEOUT, rdh, tdh, 	rxdctl, txdctl;
> +	u32 wait_loop = 10;
> +
> +	/* VF resetting */
> +	IXGBE_WRITE_REG(hw, IXGBE_VFCTRL, IXGBE_CTRL_RST);
> +	IXGBE_WRITE_FLUSH(hw);
> +
> +	while (!mbx->ops.check_for_rst(hw) && timeout) {
> +		timeout--;
> +		udelay(5);
> +	}
> +	if (!timeout)
> +		printk(KERN_ERR "[IXGBEVF] Unable to reset VF.\n");
> +
> +	/* Restoring VF status in the status */
> +	hw->mac.ops.notify_resume(hw);
> +

This seems like a recipe for putting the VF in a bad state.  It seems 
like if you are going to go though the process here you might was well 
just call the ixgbevf_reset function and wait.  Doing your own hand 
coded version of the reset_hw function seems like a recipe for disaster.

> +	/* Restoring regs value */
> +	for (i = 0; i < sizeof(restore_regs)/sizeof(u32); i++)
> +		writel(hw_regs[restore_regs[i]], (volatile void *)(restore_regs[i] + hw->hw_addr));
> +
> +	/* Restoring rx ring */
> +	for (i = 0; i < adapter->num_rx_queues; i++) {
> +		if (hw_regs[IXGBE_VFRXDCTL(i)] & IXGBE_RXDCTL_ENABLE) {
> +			RESTORE_REG(hw, IXGBE_VFRDBAL(i));
> +			RESTORE_REG(hw, IXGBE_VFRDBAH(i));
> +			RESTORE_REG(hw, IXGBE_VFRDLEN(i));
> +			RESTORE_REG(hw, IXGBE_VFDCA_RXCTRL(i));
> +			RESTORE_REG(hw, IXGBE_VFSRRCTL(i));
> +
> +			rdh = adapter->rx_ring[i]->next_to_clean;
> +			while (IXGBEVF_RX_DESC(adapter->rx_ring[i], rdh)->wb.upper.status_error
> +			       & cpu_to_le32(IXGBE_RXD_STAT_DD))
> +				rdh = (rdh + 1) % adapter->rx_ring[i]->count;
> +
> +			ixgbevf_rx_ring_shift(adapter->rx_ring[i], rdh);
> +
> +			wait_loop = 10;
> +			RESTORE_REG(hw, IXGBE_VFRXDCTL(i));
> +			do {
> +				udelay(10);
> +				rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(i));
> +			} while (--wait_loop && !(rxdctl & IXGBE_RXDCTL_ENABLE));
> +
> +			if (!wait_loop)
> +				pr_err("RXDCTL.ENABLE queue %d not cleared while polling\n",
> +				       i);
> +
> +			IXGBE_WRITE_REG(hw, IXGBE_VFRDT(i), adapter->rx_ring[i]->next_to_use);
> +		}
> +	}

This could probably be replaced with ixgbevf_configure_rx_ring().  You 
would just need to pull out ixgbevf_alloc_rx_buffers from the call and 
handle that in ixgbevf_configure_rx instead.

Also you probably don't need to check the RXDCTL_ENABLE flag, instead 
you could just check for netif_running().


> +	/* Restoring tx ring */
> +	for (i = 0; i < adapter->num_tx_queues; i++) {
> +		if (hw_regs[IXGBE_VFTXDCTL(i)] & IXGBE_TXDCTL_ENABLE) {
> +			RESTORE_REG(hw, IXGBE_VFTDBAL(i));
> +			RESTORE_REG(hw, IXGBE_VFTDBAH(i));
> +			RESTORE_REG(hw, IXGBE_VFTDLEN(i));
> +			RESTORE_REG(hw, IXGBE_VFDCA_TXCTRL(i));
> +
> +			tdh = adapter->tx_ring[i]->next_to_clean;
> +			while (IXGBEVF_TX_DESC(adapter->tx_ring[i], tdh)->wb.status
> +			       & cpu_to_le32(IXGBE_TXD_STAT_DD))
> +				tdh = (tdh + 1) % adapter->rx_ring[i]->count;
> +			ixgbevf_tx_ring_shift(adapter->tx_ring[i], tdh);
> +
> +			wait_loop = 10;
> +			RESTORE_REG(hw, IXGBE_VFTXDCTL(i));
> +			do {
> +				udelay(2000);
> +				txdctl = IXGBE_READ_REG(hw, IXGBE_VFTXDCTL(i));
> +			} while (--wait_loop && !(txdctl & IXGBE_TXDCTL_ENABLE));
> +
> +			if (!wait_loop)
> +				pr_err("Could not enable Tx Queue %d\n", i);
> +	
> +			IXGBE_WRITE_REG(hw, IXGBE_VFTDT(i), adapter->tx_ring[i]->next_to_use);
> +		}
> +	}
> +

Same here.  You are adding a bunch of code that already exists at other 
places in the driver.

> +	/* Restore irq */
> +	IXGBE_WRITE_REG(hw, IXGBE_VTEIMS, hw_regs[IXGBE_VTEIMS] & 0x7);
> +	IXGBE_WRITE_REG(hw, IXGBE_VTEIMC, (~hw_regs[IXGBE_VTEIMS]) & 0x7);


You might just want to clear all possible interrupts first, and then 
just enable the ones already set in EIMS.

> +	IXGBE_WRITE_REG(hw, IXGBE_VTEICS, hw_regs[IXGBE_VTEICS]);


As far as EICS you would probably want to just fire every interrupt once 
to flush them out.  No point in only enabling what is in EICS.

> +	ixgbevf_irq_enable(adapter);
> +}
> +
>

Why bother with all that when you could have just called 
ixgbevf_irq_enable in the first place.  You end up writing the same 
registers twice when you could have saved yourself the trouble and 
probably just called ixgbevf_irq_enable which will already take care of 
enabling everything and it will do it correctly.
