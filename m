From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 02/12] IXGBE: Add new mail box event to restore VF
 status in the PF driver
Date: Wed, 21 Oct 2015 13:34:46 -0700
Message-ID: <5627F6E6.9070903@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <1445445464-5056-3-git-send-email-tianyu.lan@intel.com>
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
In-Reply-To: <1445445464-5056-3-git-send-email-tianyu.lan@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 09:37 AM, Lan Tianyu wrote:
> This patch is to restore VF status in the PF driver when get event
> from VF.
>
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
>   drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  1 +
>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 40 ++++++++++++++++++++++++++
>   3 files changed, 42 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index 636f9e3..9d5669a 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -148,6 +148,7 @@ struct vf_data_storage {
>   	bool pf_set_mac;
>   	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
>   	u16 pf_qos;
> +	u32 vf_lpe;
>   	u16 tx_rate;
>   	u16 vlan_count;
>   	u8 spoofchk_enabled;
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> index b1e4703..8fdb38d 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> @@ -91,6 +91,7 @@ enum ixgbe_pfvf_api_rev {
>
>   /* mailbox API, version 1.1 VF requests */
>   #define IXGBE_VF_GET_QUEUES	0x09 /* get queue configuration */
> +#define IXGBE_VF_NOTIFY_RESUME    0x0c /* VF notify PF migration finishing */
>
>   /* GET_QUEUES return data indices within the mailbox */
>   #define IXGBE_VF_TX_QUEUES	1	/* number of Tx queues supported */
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> index 1d17b58..ab2a2e2 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> @@ -648,6 +648,42 @@ static inline void ixgbe_write_qde(struct ixgbe_adapter *adapter, u32 vf,
>   	}
>   }
>
> +/**
> + *  Restore the settings by mailbox, after migration
> + **/
> +void ixgbe_restore_setting(struct ixgbe_adapter *adapter, u32 vf)
> +{
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	u32 reg, reg_offset, vf_shift;
> +	int rar_entry = hw->mac.num_rar_entries - (vf + 1);
> +
> +	vf_shift = vf % 32;
> +	reg_offset = vf / 32;
> +
> +	/* enable transmit and receive for vf */
> +	reg = IXGBE_READ_REG(hw, IXGBE_VFTE(reg_offset));
> +	reg |= (1 << vf_shift);
> +	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), reg);
> +
> +	reg = IXGBE_READ_REG(hw, IXGBE_VFRE(reg_offset));
> +	reg |= (1 << vf_shift);
> +	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), reg);
> +

This is just blanket enabling Rx and Tx.  I don't see how this can be 
valid.  It seems like it would result in memory corruption for the guest 
if you are enabling Rx on a device that is not ready.  A perfect example 
is if the guest is not configured to handle jumbo frames and the PF has 
jumbo frames enabled.

> +	reg = IXGBE_READ_REG(hw, IXGBE_VMECM(reg_offset));
> +	reg |= (1 << vf_shift);
> +	IXGBE_WRITE_REG(hw, IXGBE_VMECM(reg_offset), reg);

This assumes that the anti-spoof is enabled.  That may not be the case.

> +	ixgbe_vf_reset_event(adapter, vf);
> +
> +	hw->mac.ops.set_rar(hw, rar_entry,
> +			    adapter->vfinfo[vf].vf_mac_addresses,
> +			    vf, IXGBE_RAH_AV);
> +
> +
> +	if (adapter->vfinfo[vf].vf_lpe)
> +		ixgbe_set_vf_lpe(adapter, &adapter->vfinfo[vf].vf_lpe, vf);
> +}
> +

The function ixgbe_set_vf_lpe also enabled the receive, you should take 
a look at it.  For 82598 you cannot just arbitrarily enable the Rx as 
there is a risk of corrupting guest memory or causing a kernel panic.

>   static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
>   {
>   	struct ixgbe_ring_feature *vmdq = &adapter->ring_feature[RING_F_VMDQ];
> @@ -1047,6 +1083,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
>   		break;
>   	case IXGBE_VF_SET_LPE:
>   		retval = ixgbe_set_vf_lpe(adapter, msgbuf, vf);
> +		adapter->vfinfo[vf].vf_lpe = *msgbuf;
>   		break;

Why not just leave this for the VF to notify us of via a reset.  It 
seems like if the VF is migrated it should start with the cts bits of 
the mailbox cleared as though the PF driver as been reloaded.

>   	case IXGBE_VF_SET_MACVLAN:
>   		retval = ixgbe_set_vf_macvlan_msg(adapter, msgbuf, vf);
> @@ -1063,6 +1100,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
>   	case IXGBE_VF_GET_RSS_KEY:
>   		retval = ixgbe_get_vf_rss_key(adapter, msgbuf, vf);
>   		break;
> +	case IXGBE_VF_NOTIFY_RESUME:
> +		ixgbe_restore_setting(adapter, vf);
> +		break;
>   	default:
>   		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
>   		retval = IXGBE_ERR_MBX;
>

I really don't think the VF should be sending us a message telling us to 
restore settings.  Why not just use the existing messages?

The VF as it is now can survive a suspend/resume cycle for the entire 
system.  That means the VF is reset via a power cycle of the PF.  If we 
can resume our previous state after that we should be able to do so 
without needing to add extra code to the mailbox API.
