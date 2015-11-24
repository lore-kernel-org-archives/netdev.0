From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH V2 3/3] Ixgbevf: Add migration support for ixgbevf
 driver
Date: Tue, 24 Nov 2015 23:20:04 +0200
Message-ID: <20151124230551-mutt-send-email-mst@redhat.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
 <1448372298-28386-4-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: a.motakis@virtualopensystems.com, alex.williamson@redhat.com,
	b.reynal@virtualopensystems.com, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com, agraf@suse.de,
	kvm@vger.kernel.org, pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, gerlitz.or@gmail.com,
	mark.d.rustad@intel.com, eric.auger@linaro.org,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	netdev@vger.kernel.org, shannon.nelson@intel.com,
	weiyang@linux.vnet.ibm.com, zajec5@gmail.com
To: Lan Tianyu <tianyu.lan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448372298-28386-4-git-send-email-tianyu.lan@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2015 at 09:38:18PM +0800, Lan Tianyu wrote:
> This patch is to add migration support for ixgbevf driver. Using
> faked PCI migration capability table communicates with Qemu to
> share migration status and mailbox irq vector index.
> 
> Qemu will notify VF via sending MSIX msg to trigger mailbox
> vector during migration and store migration status in the
> PCI_VF_MIGRATION_VMM_STATUS regs in the new capability table.
> The mailbox irq will be triggered just befoe stop-and-copy stage
> and after migration on the target machine.
> 
> VF driver will put down net when detect migration and tell
> Qemu it's ready for migration via writing PCI_VF_MIGRATION_VF_STATUS
> reg. After migration, put up net again.
> 
> Qemu will in charge of migrating PCI config space regs and MSIX config.
> 
> The patch is to dedicate on the normal case that net traffic works
> when mailbox irq is enabled. For other cases(such as the driver
> isn't loaded, adapter is suspended or closed), mailbox irq won't be
> triggered and VF driver will disable it via PCI_VF_MIGRATION_CAP
> reg. These case will be resolved later.
> 
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>

I have to say, I was much more interested in the idea
of tracking dirty memory. I have some thoughts about
that one - did you give up on it then?



> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   5 ++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 102 ++++++++++++++++++++++
>  2 files changed, 107 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> index 775d089..4b8ba2f 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> @@ -438,6 +438,11 @@ struct ixgbevf_adapter {
>  	u64 bp_tx_missed;
>  #endif
>  
> +	u8 migration_cap;
> +	u8 last_migration_reg;
> +	unsigned long migration_status;
> +	struct work_struct migration_task;
> +
>  	u8 __iomem *io_addr; /* Mainly for iounmap use */
>  	u32 link_speed;
>  	bool link_up;
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index a16d267..95860c2 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -96,6 +96,8 @@ static int debug = -1;
>  module_param(debug, int, 0);
>  MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
>  
> +#define MIGRATION_IN_PROGRESS		0
> +
>  static void ixgbevf_service_event_schedule(struct ixgbevf_adapter *adapter)
>  {
>  	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
> @@ -1262,6 +1264,22 @@ static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector)
>  	}
>  }
>  
> +static void ixgbevf_migration_check(struct ixgbevf_adapter *adapter) 
> +{
> +	struct pci_dev *pdev = adapter->pdev;
> +	u8 val;
> +
> +	pci_read_config_byte(pdev,
> +		     adapter->migration_cap + PCI_VF_MIGRATION_VMM_STATUS,
> +		     &val);
> +
> +	if (val != adapter->last_migration_reg) {
> +		schedule_work(&adapter->migration_task);
> +		adapter->last_migration_reg = val;
> +	}
> +
> +}
> +
>  static irqreturn_t ixgbevf_msix_other(int irq, void *data)
>  {
>  	struct ixgbevf_adapter *adapter = data;
> @@ -1269,6 +1287,7 @@ static irqreturn_t ixgbevf_msix_other(int irq, void *data)
>  
>  	hw->mac.get_link_status = 1;
>  
> +	ixgbevf_migration_check(adapter);
>  	ixgbevf_service_event_schedule(adapter);
>  
>  	IXGBE_WRITE_REG(hw, IXGBE_VTEIMS, adapter->eims_other);
> @@ -1383,6 +1402,7 @@ out:
>  static int ixgbevf_request_msix_irqs(struct ixgbevf_adapter *adapter)
>  {
>  	struct net_device *netdev = adapter->netdev;
> +	struct pci_dev *pdev = adapter->pdev;
>  	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
>  	int vector, err;
>  	int ri = 0, ti = 0;
> @@ -1423,6 +1443,12 @@ static int ixgbevf_request_msix_irqs(struct ixgbevf_adapter *adapter)
>  		goto free_queue_irqs;
>  	}
>  
> +	if (adapter->migration_cap) {
> +		pci_write_config_byte(pdev,
> +			adapter->migration_cap + PCI_VF_MIGRATION_IRQ,
> +			vector);
> +	}
> +
>  	return 0;
>  
>  free_queue_irqs:
> @@ -2891,6 +2917,59 @@ static void ixgbevf_watchdog_subtask(struct ixgbevf_adapter *adapter)
>  	ixgbevf_update_stats(adapter);
>  }
>  
> +static void ixgbevf_migration_task(struct work_struct *work)
> +{
> +	struct ixgbevf_adapter *adapter = container_of(work,
> +			struct ixgbevf_adapter,
> +			migration_task);
> +	struct pci_dev *pdev = adapter->pdev;
> +	struct net_device *netdev = adapter->netdev;
> +	u8 val;
> +
> +	if (!test_bit(MIGRATION_IN_PROGRESS, &adapter->migration_status)) {
> +		pci_read_config_byte(pdev,
> +		     adapter->migration_cap + PCI_VF_MIGRATION_VMM_STATUS,
> +		     &val);
> +		if (val != VMM_MIGRATION_START)
> +			return;
> +
> +		pr_info("migration start\n");
> +		set_bit(MIGRATION_IN_PROGRESS, &adapter->migration_status);
> +		netif_device_detach(netdev);
> +
> +		if (netif_running(netdev)) {
> +			rtnl_lock();
> +			ixgbevf_down(adapter);
> +			rtnl_unlock();
> +		}
> +		pci_save_state(pdev);
> +
> +		/* Tell Qemu VF is ready for migration. */
> +		pci_write_config_byte(pdev,
> +			     adapter->migration_cap + PCI_VF_MIGRATION_VF_STATUS,
> +			     PCI_VF_READY_FOR_MIGRATION);
> +	} else {
> +		pci_read_config_byte(pdev,
> +		     adapter->migration_cap + PCI_VF_MIGRATION_VMM_STATUS,
> +		     &val);
> +		if (val != VMM_MIGRATION_END)
> +			return;
> +
> +		pci_restore_state(pdev);
> +
> +		if (netif_running(netdev)) {
> +			ixgbevf_reset(adapter);
> +			ixgbevf_up(adapter);
> +		}
> +
> +		netif_device_attach(netdev);
> +
> +		clear_bit(MIGRATION_IN_PROGRESS, &adapter->migration_status);
> +		pr_info("migration end\n");
> +	}
> +
> +}
> +
>  /**
>   * ixgbevf_service_task - manages and runs subtasks
>   * @work: pointer to work_struct containing our data
> @@ -3122,6 +3201,7 @@ static int ixgbevf_open(struct net_device *netdev)
>  {
>  	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
>  	struct ixgbe_hw *hw = &adapter->hw;
> +	struct pci_dev *pdev = adapter->pdev;
>  	int err;
>  
>  	/* A previous failure to open the device because of a lack of
> @@ -3175,6 +3255,13 @@ static int ixgbevf_open(struct net_device *netdev)
>  
>  	ixgbevf_up_complete(adapter);
>  
> +	if (adapter->migration_cap) {
> +		pci_write_config_byte(pdev,
> +			     adapter->migration_cap + PCI_VF_MIGRATION_CAP,
> +			     PCI_VF_MIGRATION_ENABLE);
> +		adapter->last_migration_reg = 0;
> +	}
> +
>  	return 0;
>  
>  err_req_irq:
> @@ -3204,6 +3291,13 @@ err_setup_reset:
>  static int ixgbevf_close(struct net_device *netdev)
>  {
>  	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +	struct pci_dev *pdev = adapter->pdev;
> +	
> +	if (adapter->migration_cap) {
> +		pci_write_config_byte(pdev,
> +			     adapter->migration_cap + PCI_VF_MIGRATION_CAP,
> +			     PCI_VF_MIGRATION_DISABLE);
> +	}
>  
>  	ixgbevf_down(adapter);
>  	ixgbevf_free_irq(adapter);
> @@ -3764,6 +3858,12 @@ static int ixgbevf_suspend(struct pci_dev *pdev, pm_message_t state)
>  	int retval = 0;
>  #endif
>  
> +	if (adapter->migration_cap) {
> +		pci_write_config_byte(pdev,
> +			     adapter->migration_cap + PCI_VF_MIGRATION_CAP,
> +			     PCI_VF_MIGRATION_DISABLE);
> +	}
> +
>  	netif_device_detach(netdev);
>  
>  	if (netif_running(netdev)) {
> @@ -4029,6 +4129,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		    (unsigned long)adapter);
>  
>  	INIT_WORK(&adapter->service_task, ixgbevf_service_task);
> +	INIT_WORK(&adapter->migration_task, ixgbevf_migration_task);
>  	set_bit(__IXGBEVF_SERVICE_INITED, &adapter->state);
>  	clear_bit(__IXGBEVF_SERVICE_SCHED, &adapter->state);
>  
> @@ -4064,6 +4165,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		break;
>  	}
>  
> +	adapter->migration_cap = pci_find_capability(pdev, PCI_CAP_ID_MIGRATION);
>  	return 0;
>  
>  err_register:
> -- 
> 1.8.4.rc0.1.g8f6a3e5.dirty
