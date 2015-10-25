From: "Lan, Tianyu" <tianyu.lan@intel.com>
Subject: Re: [RFC Patch 03/12] IXGBE: Add sysfs interface for Qemu to migrate
 VF status in the PF driver
Date: Sun, 25 Oct 2015 15:21:40 +0800
Message-ID: <562C8304.4050104@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com> <1445445464-5056-4-git-send-email-tianyu.lan@intel.com> <5627F979.8070104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, bhelgaas@google.com,
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
In-Reply-To: <5627F979.8070104@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 10/22/2015 4:45 AM, Alexander Duyck wrote:
>> +    /* Record states hold by PF */
>> +    memcpy(&state->vf_data, &adapter->vfinfo[vfn], sizeof(struct
>> vf_data_storage));
>> +
>> +    vf_shift = vfn % 32;
>> +    reg_offset = vfn / 32;
>> +
>> +    reg = IXGBE_READ_REG(hw, IXGBE_VFTE(reg_offset));
>> +    reg &= ~(1 << vf_shift);
>> +    IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), reg);
>> +
>> +    reg = IXGBE_READ_REG(hw, IXGBE_VFRE(reg_offset));
>> +    reg &= ~(1 << vf_shift);
>> +    IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), reg);
>> +
>> +    reg = IXGBE_READ_REG(hw, IXGBE_VMECM(reg_offset));
>> +    reg &= ~(1 << vf_shift);
>> +    IXGBE_WRITE_REG(hw, IXGBE_VMECM(reg_offset), reg);
>> +
>> +    return sizeof(struct state_in_pf);
>> +}
>> +
>
> This is a read.  Why does it need to switch off the VF?  Also why turn
> of the anti-spoof, it doesn't make much sense.

This is to prevent packets which target to VM from delivering to 
original VF after migration. E,G After migration, VM pings the PF of 
original machine and the ping reply packet will forward to original
VF if it wasn't disabled.

BTW, the read is done when VM has been stopped on the source machine.


>
>> +static ssize_t ixgbe_store_state_in_pf(struct device *dev,
>> +                       struct device_attribute *attr,
>> +                       const char *buf, size_t count)
>> +{
>> +    struct ixgbe_adapter *adapter = to_adapter(dev);
>> +    struct pci_dev *pdev = adapter->pdev, *vdev;
>> +    struct pci_dev *vf_pdev = to_pci_dev(dev);
>> +    struct state_in_pf *state = (struct state_in_pf *)buf;
>> +    int vfn = vf_pdev->virtfn_index;
>> +
>> +    /* Check struct size */
>> +    if (count != sizeof(struct state_in_pf)) {
>> +        printk(KERN_ERR "State in PF size does not fit.\n");
>> +        goto out;
>> +    }
>> +
>> +    /* Restore PCI configurations */
>> +    vdev = ixgbe_get_virtfn_dev(pdev, vfn);
>> +    if (vdev) {
>> +        pci_write_config_word(vdev, IXGBE_PCI_VFCOMMAND,
>> state->command);
>> +        pci_write_config_word(vdev, IXGBE_PCI_VFMSIXMC,
>> state->msix_message_control);
>> +    }
>> +
>> +    /* Restore states hold by PF */
>> +    memcpy(&adapter->vfinfo[vfn], &state->vf_data, sizeof(struct
>> vf_data_storage));
>> +
>> +  out:
>> +    return count;
>> +}
>
> Just doing a memcpy to move the vfinfo over adds no value.  The fact is
> there are a number of filters that have to be configured in hardware
> after, and it isn't as simple as just migrating the values stored.

Restoring VF status in the PF is triggered by VF driver via new mailbox
msg and call ixgbe_restore_setting(). Here just copy data into vfinfo.
If configure hardware early, state will be cleared by FLR which is
trigger by restoring operation in the VF driver.


>  As I
> mentioned in the case of the 82598 there is also jumbo frames to take
> into account.  If the first PF didn't have it enabled, but the second
> one does that implies the state of the VF needs to change to account for
> that.

Yes, that will be a problem and VF driver also need to know this change 
after migration and reconfigure jumbo frame

>
> I really think you would be better off only migrating the data related
> to what can be configured using the ip link command and leaving other
> values such as clear_to_send at the reset value of 0. Then you can at
> least restore state from the VF after just a couple of quick messages.

This sounds good. I will try it later.

>
>> +static struct device_attribute ixgbe_per_state_in_pf_attribute =
>> +    __ATTR(state_in_pf, S_IRUGO | S_IWUSR,
>> +        ixgbe_show_state_in_pf, ixgbe_store_state_in_pf);
>> +
>> +void ixgbe_add_vf_attrib(struct ixgbe_adapter *adapter)
>> +{
>> +    struct pci_dev *pdev = adapter->pdev;
>> +    struct pci_dev *vfdev;
>> +    unsigned short vf_id;
>> +    int pos, ret;
>> +
>> +    pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
>> +    if (!pos)
>> +        return;
>> +
>> +    /* get the device ID for the VF */
>> +    pci_read_config_word(pdev, pos + PCI_SRIOV_VF_DID, &vf_id);
>> +
>> +    vfdev = pci_get_device(pdev->vendor, vf_id, NULL);
>> +
>> +    while (vfdev) {
>> +        if (vfdev->is_virtfn) {
>> +            ret = device_create_file(&vfdev->dev,
>> +                    &ixgbe_per_state_in_pf_attribute);
>> +            if (ret)
>> +                pr_warn("Unable to add VF attribute for dev %s,\n",
>> +                    dev_name(&vfdev->dev));
>> +        }
>> +
>> +        vfdev = pci_get_device(pdev->vendor, vf_id, vfdev);
>> +    }
>> +}
>
> Driver specific sysfs is a no-go.  Otherwise we will end up with a
> different implementation of this for every driver.  You will need to
> find a way to make this generic in order to have a hope of getting this
> to be acceptable.

Yes, Alex Williamson proposed to get/put data via VFIO interface. This
will be more general. I will do more research about how to communicate
between PF driver and VFIO subsystem.
