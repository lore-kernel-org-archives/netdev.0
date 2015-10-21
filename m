From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 05/12] IXGBE: Add new sysfs interface
	of "notify_vf"
Date: Wed, 21 Oct 2015 13:52:48 -0700
Message-ID: <5627FB20.3020003@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
	<1445445464-5056-6-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com, yang.z.zhang@intel.com,
	agraf@suse.de, kvm@vger.kernel.org, pbonzini@redhat.com,
	qemu-devel@nongnu.org, emil.s.tantilov@intel.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	netdev@vger.kernel.org, shannon.nelson@intel.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <1445445464-5056-6-git-send-email-tianyu.lan@intel.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 09:37 AM, Lan Tianyu wrote:
> This patch is to add new sysfs interface of "notify_vf" under sysfs
> directory of VF PCI device for Qemu to notify VF when migration status
> is changed.
>
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 30 ++++++++++++++++++++++++++
>   drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  4 ++++
>   2 files changed, 34 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> index e247d67..5cc7817 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> @@ -217,10 +217,37 @@ static ssize_t ixgbe_store_state_in_pf(struct device *dev,
>   	return count;
>   }
>   
> +static ssize_t ixgbe_store_notify_vf(struct device *dev,
> +				       struct device_attribute *attr,
> +				       const char *buf, size_t count)
> +{
> +	struct ixgbe_adapter *adapter = to_adapter(dev);
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	struct pci_dev *vf_pdev = to_pci_dev(dev);
> +	int vfn = vf_pdev->virtfn_index;
> +	u32 ivar;
> +
> +	/* Enable VF mailbox irq first */
> +	IXGBE_WRITE_REG(hw, IXGBE_PVTEIMS(vfn), 0x4);
> +	IXGBE_WRITE_REG(hw, IXGBE_PVTEIAM(vfn), 0x4);
> +	IXGBE_WRITE_REG(hw, IXGBE_PVTEIAC(vfn), 0x4);
> +
> +	ivar = IXGBE_READ_REG(hw, IXGBE_PVTIVAR_MISC(vfn));
> +	ivar &= ~0xFF;
> +	ivar |= 0x2 | IXGBE_IVAR_ALLOC_VAL;
> +	IXGBE_WRITE_REG(hw, IXGBE_PVTIVAR_MISC(vfn), ivar);
> +
> +	ixgbe_ping_vf(adapter, vfn);
> +	return count;
> +}
> +

NAK, this won't fly.  You can't just go in from the PF and enable 
interrupts on the VF hoping they are configured well enough to handle an 
interrupt you decide to trigger from them.

Also have you even considered the MSI-X configuration on the VF?  I 
haven't seen anything anywhere that would have migrated the VF's MSI-X 
configuration from BAR 3 on one system to the new system.

>   static struct device_attribute ixgbe_per_state_in_pf_attribute =
>   	__ATTR(state_in_pf, S_IRUGO | S_IWUSR,
>   		ixgbe_show_state_in_pf, ixgbe_store_state_in_pf);
>   
> +static struct device_attribute ixgbe_per_notify_vf_attribute =
> +	__ATTR(notify_vf, S_IWUSR, NULL, ixgbe_store_notify_vf);
> +
>   void ixgbe_add_vf_attrib(struct ixgbe_adapter *adapter)
>   {
>   	struct pci_dev *pdev = adapter->pdev;
> @@ -241,6 +268,8 @@ void ixgbe_add_vf_attrib(struct ixgbe_adapter *adapter)
>   		if (vfdev->is_virtfn) {
>   			ret = device_create_file(&vfdev->dev,
>   					&ixgbe_per_state_in_pf_attribute);
> +			ret |= device_create_file(&vfdev->dev,
> +					&ixgbe_per_notify_vf_attribute);
>   			if (ret)
>   				pr_warn("Unable to add VF attribute for dev %s,\n",
>   					dev_name(&vfdev->dev));
> @@ -269,6 +298,7 @@ void ixgbe_remove_vf_attrib(struct ixgbe_adapter *adapter)
>   	while (vfdev) {
>   		if (vfdev->is_virtfn) {
>   			device_remove_file(&vfdev->dev, &ixgbe_per_state_in_pf_attribute);
> +			device_remove_file(&vfdev->dev, &ixgbe_per_notify_vf_attribute);
>   		}
>   
>   		vfdev = pci_get_device(pdev->vendor, vf_id, vfdev);

More driver specific sysfs.  This needs to be moved out of the driver if 
this is to be considered anything more than a proof of concept.

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> index dd6ba59..c6ddb66 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> @@ -2302,6 +2302,10 @@ enum {
>   #define IXGBE_PVFTDT(P)		(0x06018 + (0x40 * (P)))
>   #define IXGBE_PVFTDWBAL(P)	(0x06038 + (0x40 * (P)))
>   #define IXGBE_PVFTDWBAH(P)	(0x0603C + (0x40 * (P)))
> +#define IXGBE_PVTEIMS(P)	(0x00D00 + (4 * (P)))
> +#define IXGBE_PVTIVAR_MISC(P)	(0x04E00 + (4 * (P)))
> +#define IXGBE_PVTEIAC(P)       (0x00F00 + (4 * P))
> +#define IXGBE_PVTEIAM(P)       (0x04D00 + (4 * P))
>   
>   #define IXGBE_PVFTDWBALn(q_per_pool, vf_number, vf_q_index) \
>   		(IXGBE_PVFTDWBAL((q_per_pool)*(vf_number) + (vf_q_index)))
