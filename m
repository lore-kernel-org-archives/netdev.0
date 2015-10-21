From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 03/12] IXGBE: Add sysfs interface for Qemu to migrate
 VF status in the PF driver
Date: Wed, 21 Oct 2015 13:45:45 -0700
Message-ID: <5627F979.8070104@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <1445445464-5056-4-git-send-email-tianyu.lan@intel.com>
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
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-4-git-send-email-tianyu.lan@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 09:37 AM, Lan Tianyu wrote:
> This patch is to add sysfs interface state_in_pf under sysfs directory
> of VF PCI device for Qemu to get and put VF status in the PF driver during
> migration.
>
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 156 ++++++++++++++++++++++++-
>   1 file changed, 155 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> index ab2a2e2..89671eb 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> @@ -124,6 +124,157 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
>   	return -ENOMEM;
>   }
>   
> +#define IXGBE_PCI_VFCOMMAND   0x4
> +#define IXGBE_PCI_VFMSIXMC    0x72
> +#define IXGBE_SRIOV_VF_OFFSET 0x180
> +#define IXGBE_SRIOV_VF_STRIDE 0x2
> +
> +#define to_adapter(dev) ((struct ixgbe_adapter *)(pci_get_drvdata(to_pci_dev(dev)->physfn)))
> +
> +struct state_in_pf {
> +	u16 command;
> +	u16 msix_message_control;
> +	struct vf_data_storage vf_data;
> +};
> +
> +static struct pci_dev *ixgbe_get_virtfn_dev(struct pci_dev *pdev, int vfn)
> +{
> +	u16 rid = pdev->devfn + IXGBE_SRIOV_VF_OFFSET + IXGBE_SRIOV_VF_STRIDE * vfn;
> +	return pci_get_bus_and_slot(pdev->bus->number + (rid >> 8), rid & 0xff);
> +}
> +
> +static ssize_t ixgbe_show_state_in_pf(struct device *dev,
> +				      struct device_attribute *attr, char *buf)
> +{
> +	struct ixgbe_adapter *adapter = to_adapter(dev);
> +	struct pci_dev *pdev = adapter->pdev, *vdev;
> +	struct pci_dev *vf_pdev = to_pci_dev(dev);
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	struct state_in_pf *state = (struct state_in_pf *)buf;
> +	int vfn = vf_pdev->virtfn_index;
> +	u32 reg, reg_offset, vf_shift;
> +
> +	/* Clear VF mac and disable VF */
> +	ixgbe_del_mac_filter(adapter, adapter->vfinfo[vfn].vf_mac_addresses, vfn);
> +
> +	/* Record PCI configurations */
> +	vdev = ixgbe_get_virtfn_dev(pdev, vfn);
> +	if (vdev) {
> +		pci_read_config_word(vdev, IXGBE_PCI_VFCOMMAND, &state->command);
> +		pci_read_config_word(vdev, IXGBE_PCI_VFMSIXMC, &state->msix_message_control);
> +	}
> +	else
> +		printk(KERN_WARNING "Unable to find VF device.\n");
> +

Formatting for the if/else is incorrect.  The else condition should be 
in brackets as well.

> +	/* Record states hold by PF */
> +	memcpy(&state->vf_data, &adapter->vfinfo[vfn], sizeof(struct vf_data_storage));
> +
> +	vf_shift = vfn % 32;
> +	reg_offset = vfn / 32;
> +
> +	reg = IXGBE_READ_REG(hw, IXGBE_VFTE(reg_offset));
> +	reg &= ~(1 << vf_shift);
> +	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), reg);
> +
> +	reg = IXGBE_READ_REG(hw, IXGBE_VFRE(reg_offset));
> +	reg &= ~(1 << vf_shift);
> +	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), reg);
> +
> +	reg = IXGBE_READ_REG(hw, IXGBE_VMECM(reg_offset));
> +	reg &= ~(1 << vf_shift);
> +	IXGBE_WRITE_REG(hw, IXGBE_VMECM(reg_offset), reg);
> +
> +	return sizeof(struct state_in_pf);
> +}
> +

This is a read.  Why does it need to switch off the VF?  Also why turn 
of the anti-spoof, it doesn't make much sense.

> +static ssize_t ixgbe_store_state_in_pf(struct device *dev,
> +				       struct device_attribute *attr,
> +				       const char *buf, size_t count)
> +{
> +	struct ixgbe_adapter *adapter = to_adapter(dev);
> +	struct pci_dev *pdev = adapter->pdev, *vdev;
> +	struct pci_dev *vf_pdev = to_pci_dev(dev);
> +	struct state_in_pf *state = (struct state_in_pf *)buf;
> +	int vfn = vf_pdev->virtfn_index;
> +
> +	/* Check struct size */
> +	if (count != sizeof(struct state_in_pf)) {
> +		printk(KERN_ERR "State in PF size does not fit.\n");
> +		goto out;
> +	}
> +
> +	/* Restore PCI configurations */
> +	vdev = ixgbe_get_virtfn_dev(pdev, vfn);
> +	if (vdev) {
> +		pci_write_config_word(vdev, IXGBE_PCI_VFCOMMAND, state->command);
> +		pci_write_config_word(vdev, IXGBE_PCI_VFMSIXMC, state->msix_message_control);
> +	}
> +
> +	/* Restore states hold by PF */
> +	memcpy(&adapter->vfinfo[vfn], &state->vf_data, sizeof(struct vf_data_storage));
> +
> +  out:
> +	return count;
> +}

Just doing a memcpy to move the vfinfo over adds no value.  The fact is 
there are a number of filters that have to be configured in hardware 
after, and it isn't as simple as just migrating the values stored.  As I 
mentioned in the case of the 82598 there is also jumbo frames to take 
into account.  If the first PF didn't have it enabled, but the second 
one does that implies the state of the VF needs to change to account for 
that.

I really think you would be better off only migrating the data related 
to what can be configured using the ip link command and leaving other 
values such as clear_to_send at the reset value of 0. Then you can at 
least restore state from the VF after just a couple of quick messages.

> +static struct device_attribute ixgbe_per_state_in_pf_attribute =
> +	__ATTR(state_in_pf, S_IRUGO | S_IWUSR,
> +		ixgbe_show_state_in_pf, ixgbe_store_state_in_pf);
> +
> +void ixgbe_add_vf_attrib(struct ixgbe_adapter *adapter)
> +{
> +	struct pci_dev *pdev = adapter->pdev;
> +	struct pci_dev *vfdev;
> +	unsigned short vf_id;
> +	int pos, ret;
> +
> +	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
> +	if (!pos)
> +		return;
> +
> +	/* get the device ID for the VF */
> +	pci_read_config_word(pdev, pos + PCI_SRIOV_VF_DID, &vf_id);
> +
> +	vfdev = pci_get_device(pdev->vendor, vf_id, NULL);
> +
> +	while (vfdev) {
> +		if (vfdev->is_virtfn) {
> +			ret = device_create_file(&vfdev->dev,
> +					&ixgbe_per_state_in_pf_attribute);
> +			if (ret)
> +				pr_warn("Unable to add VF attribute for dev %s,\n",
> +					dev_name(&vfdev->dev));
> +		}
> +
> +		vfdev = pci_get_device(pdev->vendor, vf_id, vfdev);
> +	}
> +}

Driver specific sysfs is a no-go.  Otherwise we will end up with a 
different implementation of this for every driver.  You will need to 
find a way to make this generic in order to have a hope of getting this 
to be acceptable.

> +void ixgbe_remove_vf_attrib(struct ixgbe_adapter *adapter)
> +{
> +	struct pci_dev *pdev = adapter->pdev;
> +	struct pci_dev *vfdev;
> +	unsigned short vf_id;
> +	int pos;
> +
> +	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
> +	if (!pos)
> +		return;
> +
> +	/* get the device ID for the VF */
> +	pci_read_config_word(pdev, pos + PCI_SRIOV_VF_DID, &vf_id);
> +
> +	vfdev = pci_get_device(pdev->vendor, vf_id, NULL);
> +
> +	while (vfdev) {
> +		if (vfdev->is_virtfn) {
> +			device_remove_file(&vfdev->dev, &ixgbe_per_state_in_pf_attribute);
> +		}
> +
> +		vfdev = pci_get_device(pdev->vendor, vf_id, vfdev);
> +	}
> +}
> +
>   /* Note this function is called when the user wants to enable SR-IOV
>    * VFs using the now deprecated module parameter
>    */
> @@ -198,6 +349,9 @@ int ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
>   	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
>   		return 0;
>   
> +
> +	ixgbe_remove_vf_attrib(adapter);
> +
>   #ifdef CONFIG_PCI_IOV
>   	/*
>   	 * If our VFs are assigned we cannot shut down SR-IOV

You can probably drop the extra space you added before the function.

> @@ -284,7 +438,7 @@ static int ixgbe_pci_sriov_enable(struct pci_dev *dev, int num_vfs)
>   		return err;
>   	}
>   	ixgbe_sriov_reinit(adapter);
> -
> +	ixgbe_add_vf_attrib(adapter);
>   	return num_vfs;
>   #else
>   	return 0;

You should probably add a space here before the return.
