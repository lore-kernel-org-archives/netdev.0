From: Don Dutile <ddutile@redhat.com>
Subject: Re: [PATCH RFC] pci: Control whether VFs are probed on pci_enable_sriov
Date: Fri, 09 Jan 2015 13:38:08 -0500
Message-ID: <54B02010.5050602@redhat.com>
References: <1417957693-24979-1-git-send-email-eli@mellanox.com> <20150109182546.GG6575@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: Bjorn Helgaas <bhelgaas@google.com>,
	Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20150109182546.GG6575@google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/2015 01:25 PM, Bjorn Helgaas wrote:
> On Sun, Dec 07, 2014 at 03:08:13PM +0200, Eli Cohen wrote:
>> Sometimes it is not desirable to probe the virtual fuctions right away,
>> but rather leave the decision to the host's administrator.
>>
>> This can save host side resource usage by VF instances which would be
>> eventually probed to VMs.
>>
>> Use a parameter to pci_enable_sriov to control that policy, and modify
>> all current callers such that they retain the same functionality.
>>
>> Use a one shot flag on struct pci_device which is cleared after the
>> first probe is ignored so subsequent attempts go through.
>>
>> Cc: Donald Dutile <ddutile@redhat.com>
>> Signed-off-by: Eli Cohen <eli@mellanox.com>
>
> Seems like we never really reached a consensus here.  Please repost if you
> want to continue down this path.
>
> Bjorn
>
hmmm, seems like I have to increase the power on my nack-phaser.
-dd

>> ---
>> This approach is used by the mlx5 driver SRIOV implementation, so
>> sending this to get feedback from the PCI and networking folks.
>>
>>   drivers/misc/genwqe/card_base.c                      |  2 +-
>>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c    |  2 +-
>>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |  2 +-
>>   drivers/net/ethernet/cisco/enic/enic_main.c          |  2 +-
>>   drivers/net/ethernet/emulex/benet/be_main.c          |  2 +-
>>   drivers/net/ethernet/intel/fm10k/fm10k_iov.c         |  2 +-
>>   drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c   |  2 +-
>>   drivers/net/ethernet/intel/igb/igb_main.c            |  2 +-
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c       |  4 ++--
>>   drivers/net/ethernet/mellanox/mlx4/main.c            |  2 +-
>>   drivers/net/ethernet/neterion/vxge/vxge-main.c       |  2 +-
>>   drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c |  2 +-
>>   drivers/net/ethernet/sfc/siena_sriov.c               |  2 +-
>>   drivers/pci/iov.c                                    | 12 +++++++-----
>>   drivers/pci/pci-driver.c                             | 11 ++++++++---
>>   drivers/scsi/lpfc/lpfc_init.c                        |  2 +-
>>   include/linux/pci.h                                  |  5 +++--
>>   17 files changed, 33 insertions(+), 25 deletions(-)
>>
>> diff --git a/drivers/misc/genwqe/card_base.c b/drivers/misc/genwqe/card_base.c
>> index 4cf8f82cfca2..69253ca17506 100644
>> --- a/drivers/misc/genwqe/card_base.c
>> +++ b/drivers/misc/genwqe/card_base.c
>> @@ -1325,7 +1325,7 @@ static int genwqe_sriov_configure(struct pci_dev *dev, int numvfs)
>>
>>   	if (numvfs > 0) {
>>   		genwqe_setup_vf_jtimer(cd);
>> -		rc = pci_enable_sriov(dev, numvfs);
>> +		rc = pci_enable_sriov(dev, numvfs, 1);
>>   		if (rc < 0)
>>   			return rc;
>>   		return numvfs;
>> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
>> index c88b20af87df..773b20224a47 100644
>> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
>> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
>> @@ -2570,7 +2570,7 @@ int bnx2x_enable_sriov(struct bnx2x *bp)
>>   	if (rc)
>>   		return rc;
>>
>> -	rc = pci_enable_sriov(bp->pdev, req_vfs);
>> +	rc = pci_enable_sriov(bp->pdev, req_vfs, 1);
>>   	if (rc) {
>>   		BNX2X_ERR("pci_enable_sriov failed with %d\n", rc);
>>   		return rc;
>> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>> index 3aea82bb9039..6e8afbfd3eba 100644
>> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>> @@ -6597,7 +6597,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>   sriov:
>>   #ifdef CONFIG_PCI_IOV
>>   	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
>> -		if (pci_enable_sriov(pdev, num_vf[func]) == 0)
>> +		if (pci_enable_sriov(pdev, num_vf[func], 1) == 0)
>>   			dev_info(&pdev->dev,
>>   				 "instantiated %u virtual functions\n",
>>   				 num_vf[func]);
>> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
>> index 86ee350e57f0..8a8b1d86f18a 100644
>> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
>> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
>> @@ -2421,7 +2421,7 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>>   		pci_read_config_word(pdev, pos + PCI_SRIOV_TOTAL_VF,
>>   			&enic->num_vfs);
>>   		if (enic->num_vfs) {
>> -			err = pci_enable_sriov(pdev, enic->num_vfs);
>> +			err = pci_enable_sriov(pdev, enic->num_vfs, 1);
>>   			if (err) {
>>   				dev_err(dev, "SRIOV enable failed, aborting."
>>   					" pci_enable_sriov() returned %d\n",
>> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
>> index dc77ec2bdafd..a96491777ac4 100644
>> --- a/drivers/net/ethernet/emulex/benet/be_main.c
>> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
>> @@ -3274,7 +3274,7 @@ static int be_vf_setup(struct be_adapter *adapter)
>>   	}
>>
>>   	if (!old_vfs) {
>> -		status = pci_enable_sriov(adapter->pdev, adapter->num_vfs);
>> +		status = pci_enable_sriov(adapter->pdev, adapter->num_vfs, 1);
>>   		if (status) {
>>   			dev_err(dev, "SRIOV enable failed\n");
>>   			adapter->num_vfs = 0;
>> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
>> index 060190864238..04a3dc5acc28 100644
>> --- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
>> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
>> @@ -408,7 +408,7 @@ int fm10k_iov_configure(struct pci_dev *pdev, int num_vfs)
>>   		 */
>>   		fm10k_disable_aer_comp_abort(pdev);
>>
>> -		err = pci_enable_sriov(pdev, num_vfs);
>> +		err = pci_enable_sriov(pdev, num_vfs, 1);
>>   		if (err) {
>>   			dev_err(&pdev->dev,
>>   				"Enable PCI SR-IOV failed: %d\n", err);
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>> index 668d860275d6..fe56e09725f2 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>> @@ -852,7 +852,7 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
>>
>>   	/* Check to see if we're just allocating resources for extant VFs */
>>   	if (pci_num_vf(pf->pdev) != num_alloc_vfs) {
>> -		ret = pci_enable_sriov(pf->pdev, num_alloc_vfs);
>> +		ret = pci_enable_sriov(pf->pdev, num_alloc_vfs, 1);
>>   		if (ret) {
>>   			dev_err(&pf->pdev->dev,
>>   				"Failed to enable SR-IOV, error %d.\n", ret);
>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
>> index 3c0221620c9d..da01326ef550 100644
>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>> @@ -2742,7 +2742,7 @@ static int igb_enable_sriov(struct pci_dev *pdev, int num_vfs)
>>
>>   	/* only call pci_enable_sriov() if no VFs are allocated already */
>>   	if (!old_vfs) {
>> -		err = pci_enable_sriov(pdev, adapter->vfs_allocated_count);
>> +		err = pci_enable_sriov(pdev, adapter->vfs_allocated_count, 1);
>>   		if (err)
>>   			goto err_out;
>>   	}
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>> index 04eee7c7b653..74b33483a0d1 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>> @@ -149,7 +149,7 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
>>   		 */
>>   		adapter->num_vfs = min_t(unsigned int, adapter->num_vfs, IXGBE_MAX_VFS_DRV_LIMIT);
>>
>> -		err = pci_enable_sriov(adapter->pdev, adapter->num_vfs);
>> +		err = pci_enable_sriov(adapter->pdev, adapter->num_vfs, 1);
>>   		if (err) {
>>   			e_err(probe, "Failed to enable PCI sriov: %d\n", err);
>>   			adapter->num_vfs = 0;
>> @@ -270,7 +270,7 @@ static int ixgbe_pci_sriov_enable(struct pci_dev *dev, int num_vfs)
>>   	for (i = 0; i < adapter->num_vfs; i++)
>>   		ixgbe_vf_configuration(dev, (i | 0x10000000));
>>
>> -	err = pci_enable_sriov(dev, num_vfs);
>> +	err = pci_enable_sriov(dev, num_vfs, 1);
>>   	if (err) {
>>   		e_dev_warn("Failed to enable PCI sriov: %d\n", err);
>>   		return err;
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>> index 3044f9e623cb..ae38b556ec13 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>> @@ -2350,7 +2350,7 @@ static u64 mlx4_enable_sriov(struct mlx4_dev *dev, struct pci_dev *pdev,
>>   					 existing_vfs, total_vfs);
>>   		} else {
>>   			mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n", total_vfs);
>> -			err = pci_enable_sriov(pdev, total_vfs);
>> +			err = pci_enable_sriov(pdev, total_vfs, 1);
>>   		}
>>   		if (err) {
>>   			mlx4_err(dev, "Failed to enable SR-IOV, continuing without SR-IOV (err = %d)\n",
>> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
>> index cc0485e3c621..c341e73fc68c 100644
>> --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
>> +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
>> @@ -4495,7 +4495,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
>>   	/* Enable SRIOV mode, if firmware has SRIOV support and if it is a PF */
>>   	if (is_sriov(function_mode) && !is_sriov_initialized(pdev) &&
>>   	   (ll_config->intr_type != INTA)) {
>> -		ret = pci_enable_sriov(pdev, num_vfs);
>> +		ret = pci_enable_sriov(pdev, num_vfs, 1);
>>   		if (ret)
>>   			vxge_debug_ll_config(VXGE_ERR,
>>   				"Failed in enabling SRIOV mode: %d\n", ret);
>> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
>> index a29538b86edf..b483705a1ef1 100644
>> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
>> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
>> @@ -570,7 +570,7 @@ static int qlcnic_sriov_pf_enable(struct qlcnic_adapter *adapter, int num_vfs)
>>   	if (!qlcnic_sriov_enable_check(adapter))
>>   		return 0;
>>
>> -	err = pci_enable_sriov(adapter->pdev, num_vfs);
>> +	err = pci_enable_sriov(adapter->pdev, num_vfs, 1);
>>   	if (err)
>>   		qlcnic_sriov_pf_cleanup(adapter);
>>
>> diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
>> index a8bbbad68a88..6804ed04cfcd 100644
>> --- a/drivers/net/ethernet/sfc/siena_sriov.c
>> +++ b/drivers/net/ethernet/sfc/siena_sriov.c
>> @@ -1332,7 +1332,7 @@ int efx_siena_sriov_init(struct efx_nic *efx)
>>
>>   	/* At this point we must be ready to accept VFDI requests */
>>
>> -	rc = pci_enable_sriov(efx->pci_dev, efx->vf_count);
>> +	rc = pci_enable_sriov(efx->pci_dev, efx->vf_count, 1);
>>   	if (rc)
>>   		goto fail_pci;
>>
>> diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
>> index 4d109c07294a..f6aba5beea78 100644
>> --- a/drivers/pci/iov.c
>> +++ b/drivers/pci/iov.c
>> @@ -57,7 +57,7 @@ static void virtfn_remove_bus(struct pci_bus *physbus, struct pci_bus *virtbus)
>>   		pci_remove_bus(virtbus);
>>   }
>>
>> -static int virtfn_add(struct pci_dev *dev, int id, int reset)
>> +static int virtfn_add(struct pci_dev *dev, int id, int reset, int probe)
>>   {
>>   	int i;
>>   	int rc = -ENOMEM;
>> @@ -85,6 +85,7 @@ static int virtfn_add(struct pci_dev *dev, int id, int reset)
>>   	virtfn->physfn = pci_dev_get(dev);
>>   	virtfn->is_virtfn = 1;
>>   	virtfn->multifunction = 0;
>> +	virtfn->probe_vf = probe;
>>
>>   	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
>>   		res = dev->resource + PCI_IOV_RESOURCES + i;
>> @@ -170,7 +171,7 @@ static void virtfn_remove(struct pci_dev *dev, int id, int reset)
>>   	pci_dev_put(dev);
>>   }
>>
>> -static int sriov_enable(struct pci_dev *dev, int nr_virtfn)
>> +static int sriov_enable(struct pci_dev *dev, int nr_virtfn, int probe_vfs)
>>   {
>>   	int rc;
>>   	int i, j;
>> @@ -255,7 +256,7 @@ static int sriov_enable(struct pci_dev *dev, int nr_virtfn)
>>   		initial = nr_virtfn;
>>
>>   	for (i = 0; i < initial; i++) {
>> -		rc = virtfn_add(dev, i, 0);
>> +		rc = virtfn_add(dev, i, 0, probe_vfs);
>>   		if (rc)
>>   			goto failed;
>>   	}
>> @@ -558,17 +559,18 @@ int pci_iov_bus_range(struct pci_bus *bus)
>>    * pci_enable_sriov - enable the SR-IOV capability
>>    * @dev: the PCI device
>>    * @nr_virtfn: number of virtual functions to enable
>> + * @probe_vfs: in zero, don't probe new VFs, otherwise probe if suitable driver available
>>    *
>>    * Returns 0 on success, or negative on failure.
>>    */
>> -int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn)
>> +int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn, int probe_vfs)
>>   {
>>   	might_sleep();
>>
>>   	if (!dev->is_physfn)
>>   		return -ENOSYS;
>>
>> -	return sriov_enable(dev, nr_virtfn);
>> +	return sriov_enable(dev, nr_virtfn, probe_vfs);
>>   }
>>   EXPORT_SYMBOL_GPL(pci_enable_sriov);
>>
>> diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
>> index 2b3c89425bb5..d5b93339b8a4 100644
>> --- a/drivers/pci/pci-driver.c
>> +++ b/drivers/pci/pci-driver.c
>> @@ -397,9 +397,14 @@ static int pci_device_probe(struct device *dev)
>>   	drv = to_pci_driver(dev->driver);
>>   	pci_dev = to_pci_dev(dev);
>>   	pci_dev_get(pci_dev);
>> -	error = __pci_device_probe(drv, pci_dev);
>> -	if (error)
>> -		pci_dev_put(pci_dev);
>> +	if (!pci_dev->is_virtfn || pci_dev->probe_vf) {
>> +		error = __pci_device_probe(drv, pci_dev);
>> +		if (error)
>> +			pci_dev_put(pci_dev);
>> +	}
>> +	/* one shot blocking of probe */
>> +	if (pci_dev->is_virtfn && !pci_dev->probe_vf)
>> +		pci_dev->probe_vf = 1;
>>
>>   	return error;
>>   }
>> diff --git a/drivers/scsi/lpfc/lpfc_init.c b/drivers/scsi/lpfc/lpfc_init.c
>> index 0b2c53af85c7..2f81f471b8f3 100644
>> --- a/drivers/scsi/lpfc/lpfc_init.c
>> +++ b/drivers/scsi/lpfc/lpfc_init.c
>> @@ -4797,7 +4797,7 @@ lpfc_sli_probe_sriov_nr_virtfn(struct lpfc_hba *phba, int nr_vfn)
>>   		return -EINVAL;
>>   	}
>>
>> -	rc = pci_enable_sriov(pdev, nr_vfn);
>> +	rc = pci_enable_sriov(pdev, nr_vfn, 1);
>>   	if (rc) {
>>   		lpfc_printf_log(phba, KERN_WARNING, LOG_INIT,
>>   				"2806 Failed to enable sriov on this device "
>> diff --git a/include/linux/pci.h b/include/linux/pci.h
>> index 4c8ac5fcc224..beb2640ba18d 100644
>> --- a/include/linux/pci.h
>> +++ b/include/linux/pci.h
>> @@ -373,6 +373,7 @@ struct pci_dev {
>>   	phys_addr_t rom; /* Physical address of ROM if it's not from the BAR */
>>   	size_t romlen; /* Length of ROM if it's not from the BAR */
>>   	char *driver_override; /* Driver name to force a match */
>> +	int probe_vf; /* probe this device */
>>   };
>>
>>   static inline struct pci_dev *pci_physfn(struct pci_dev *dev)
>> @@ -1655,14 +1656,14 @@ int pci_ext_cfg_avail(void);
>>   void __iomem *pci_ioremap_bar(struct pci_dev *pdev, int bar);
>>
>>   #ifdef CONFIG_PCI_IOV
>> -int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
>> +int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn, int probe_vfs);
>>   void pci_disable_sriov(struct pci_dev *dev);
>>   int pci_num_vf(struct pci_dev *dev);
>>   int pci_vfs_assigned(struct pci_dev *dev);
>>   int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs);
>>   int pci_sriov_get_totalvfs(struct pci_dev *dev);
>>   #else
>> -static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn)
>> +static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn, int nr_virt_probe)
>>   { return -ENODEV; }
>>   static inline void pci_disable_sriov(struct pci_dev *dev) { }
>>   static inline int pci_num_vf(struct pci_dev *dev) { return 0; }
>> --
>> 2.1.3
>>
