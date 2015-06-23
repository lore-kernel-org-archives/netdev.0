From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: RE: [Intel-wired-lan] [PATCH v6 3/3] ixgbe, ixgbevf: Add new mbox
 API to enable MC promiscuous mode
Date: Tue, 23 Jun 2015 09:27:07 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05EE9A6F@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05EE18CD@BPXM14GP.gisp.nec.co.jp>
 <5581ABD2.9030404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	"David Miller" <davem@davemloft.net>,
	Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([210.143.35.52]:52159 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751AbbFWJ1W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 05:27:22 -0400
In-Reply-To: <5581ABD2.9030404@gmail.com>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: Re: [Intel-wired-lan] [PATCH v6 3/3] ixgbe, ixgbevf: Add new mbox API to enable MC promiscuous mode
> 
> On 06/17/2015 04:45 AM, Hiroshi Shimamoto wrote:
> > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> >
> > The limitation of the number of multicast address for VF is not enough
> > for the large scale server with SR-IOV feature.
> > IPv6 requires the multicast MAC address for each IP address to handle
> > the Neighbor Solicitation message.
> > We couldn't assign over 30 IPv6 addresses to a single VF interface.
> >
> > The easy way to solve this is enabling multicast promiscuous mode.
> > It is good to have a functionality to enable multicast promiscuous mode
> > for each VF from VF driver.
> >
> > This patch introduces the new mbox API, IXGBE_VF_SET_MC_PROMISC, to
> > enable/disable multicast promiscuous mode in VF. If multicast
> > promiscuous mode is enabled the VF can receive all multicast packets.
> >
> > With this patch, the ixgbevf driver automatically enable multicast
> > promiscuous mode when the number of multicast addresses is over than 30
> > if possible.
> >
> > PF only allow to enbale VF multicast promiscuous mode if the VF is trusted.
> > If not trusted, PF returns an error to VF and VF will fallback the previous
> > behavior, that only 30 multicast addresses are registered to the filter.
> >
> > Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> > ---
> >   drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  1 +
> >   drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  2 +
> >   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 55 +++++++++++++++++++++++
> >   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 ++
> >   drivers/net/ethernet/intel/ixgbevf/mbx.h          |  2 +
> >   drivers/net/ethernet/intel/ixgbevf/vf.c           | 49 +++++++++++++++++++-
> >   drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
> >   7 files changed, 112 insertions(+), 1 deletion(-)
> >
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> > index 7f76c12..054db64 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> > @@ -146,6 +146,7 @@ struct vf_data_storage {
> >   	u16 vlans_enabled;
> >   	bool clear_to_send;
> >   	bool pf_set_mac;
> > +	bool mc_promisc;
> >   	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
> >   	u16 pf_qos;
> >   	u16 tx_rate;
> 
> Instead of casting this as a bool I think it might be better served as
> an enum.  You basically have 4 levels you could set:
> DISABLED	No traffic allowed, Rx disabled, PF only
> NONE		only L2 exact match addresses or Flow Director enabled
> MULTI		BAM & ROMPE set
> ALLMULTI	BAM, ROMPE, & MPE set
> PROMISC		BAM, ROMPE, MPE, & UPE (available on x540)
> VLAN_PROMISC	BAM, ROMPE, MPE, UPE, & VPE (available on x540)
> 
> That just leaves AUPE and ROPE which are kind of special cases.  AUPE
> should be set if an port VLAN is not assigned by the PF, and as far as
> ROPE it could be thought of as a poor-mans promiscuous so it might be
> useful for 82599 to possibly try to put together some sort of
> promiscuous mode though I cannot say for certain.
> 
> The idea is to make use of the enum to enable higher or lower levels of
> escalation.  You could then limit a non-trusted VF to MULTI for any
> requests of ALLMULTI, PROMISC, or VLAN_PROMSIC and if the VF is trusted
> it would have access to ALLMULTI on 82599, and potentially PROMISC or
> VLAN_PROMISC on x540 and newer.
> 
> It hadn't occurred to me until just now that the NONE option might be
> desirable to some as well since it is possible that somebody would
> rather use flow director rules to send traffic to a VF rather than have
> it receive broadcast or multicast traffic.  By doing this we enable that
> as a possible use case.  It could all be controlled through the
> IFF_BROADCAST, IFF_MULTICAST, IFF_ALLMULTI, and IFF_PROMISC flags in
> set_rx_mode.
> 
> We did something like this for fm10k as it was a requirement of the
> Switch API.  You could probably do something similar for the
> ixgbe/ixgbevf mailbox interface as it seems like it might be a better
> fit than adding a new message to cover one specific case.

I'm considering and working about the above change.
I agree with having such mode change interface is better than adding a specific
feature message.

thanks,
Hiroshi

> 
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> > index b1e4703..703d40b 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> > @@ -102,6 +102,8 @@ enum ixgbe_pfvf_api_rev {
> >   #define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
> >   #define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS key */
> >
> > +#define IXGBE_VF_SET_MC_PROMISC	0x0c	/* VF requests MC promiscuous */
> > +
> >   /* length of permanent address message returned from PF */
> >   #define IXGBE_VF_PERMADDR_MSG_LEN 4
> >   /* word in permanent address message with the current multicast type */
> 
> You might just want to refer to this as SET_XCAST_MODE since that is
> essentially what this command is doing.
> 
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> > index 826f88e..925d9c6 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> > @@ -119,6 +119,9 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
> >
> >   			/* Untrust all VFs */
> >   			adapter->vfinfo[i].trusted = false;
> > +
> > +			/* Turn multicast promiscuous mode off for all VFs */
> > +			adapter->vfinfo[i].mc_promisc = false;
> >   		}
> >
> >   		return 0;
> 
> This could be defaulted to MULTI since that is the legacy behavior.
> 
> > @@ -335,6 +338,12 @@ static int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
> >   	u32 mta_reg;
> >   	u32 vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
> >
> > +	/* Disable multicast promiscuous first */
> > +	if (adapter->vfinfo[vf].mc_promisc) {
> > +		vmolr &= ~IXGBE_VMOLR_MPE;
> > +		adapter->vfinfo[vf].mc_promisc = false;
> > +	}
> > +
> >   	/* only so many hash values supported */
> >   	entries = min(entries, IXGBE_MAX_VF_MC_ENTRIES);
> >
> 
> This shouldn't alter the promiscuous state.  All this does is program
> multicast addresses and it should be left doing as such.
> 
> > @@ -660,6 +669,7 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
> >   	u32 msgbuf[4] = {0, 0, 0, 0};
> >   	u8 *addr = (u8 *)(&msgbuf[1]);
> >   	u32 q_per_pool = __ALIGN_MASK(1, ~vmdq->mask);
> > +	u32 vmolr;
> >   	int i;
> >
> >   	e_info(probe, "VF Reset msg received from vf %d\n", vf);
> > @@ -721,6 +731,12 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
> >   		IXGBE_WRITE_REG(hw, IXGBE_PVFTDWBALn(q_per_pool, vf, i), 0);
> >   	}
> >
> > +	/* Disable multicast promiscuous on reset */
> > +	vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
> > +	vmolr &= ~IXGBE_VMOLR_MPE;
> > +	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vf), vmolr);
> > +	adapter->vfinfo[vf].mc_promisc = false;
> > +
> >   	/* reply to reset with ack and vf mac address */
> >   	msgbuf[0] = IXGBE_VF_RESET;
> >   	if (!is_zero_ether_addr(vf_mac)) {
> 
> Instead of manipulating individual flags we should probably to through
> and figure out exactly what flags we want enabled and write that value
> to the VMOLR register instead of doing a read/modify/write.
> 
> > @@ -1004,6 +1020,42 @@ static int ixgbe_get_vf_rss_key(struct ixgbe_adapter *adapter,
> >   	return 0;
> >   }
> >
> > +static int ixgbe_set_vf_mc_promisc(struct ixgbe_adapter *adapter,
> > +				   u32 *msgbuf, u32 vf)
> > +{
> > +	bool enable = !!msgbuf[1];	/* msgbuf contains the flag to enable */
> > +	struct ixgbe_hw *hw;
> > +	u32 vmolr;
> > +
> > +	switch (adapter->vfinfo[vf].vf_api) {
> > +	case ixgbe_mbox_api_12:
> > +		break;
> > +	default:
> > +		return -1;
> > +	}
> > +
> > +	if (adapter->vfinfo[vf].mc_promisc == enable)
> > +		return 0;
> > +
> > +	/* Don't enable MC promisc unless VF is trusted */
> > +	if (enable && !adapter->vfinfo[vf].trusted)
> > +		return -1;
> > +
> > +	hw = &adapter->hw;
> > +	vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
> > +
> > +	if (enable)
> > +		vmolr |= IXGBE_VMOLR_MPE;
> > +	else
> > +		vmolr &= ~IXGBE_VMOLR_MPE;
> > +
> > +	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vf), vmolr);
> > +
> > +	adapter->vfinfo[vf].mc_promisc = enable;
> > +
> > +	return 0;
> > +}
> > +
> >   static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
> >   {
> >   	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
> 
> Same thing here.  I realize part of the VMOLR register is labelled as
> reserved, however writing 0 to those reserved bits should cause no more
> harm than doing a read/modify/write to them.
> 
> > @@ -1066,6 +1118,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
> >   	case IXGBE_VF_GET_RSS_KEY:
> >   		retval = ixgbe_get_vf_rss_key(adapter, msgbuf, vf);
> >   		break;
> > +	case IXGBE_VF_SET_MC_PROMISC:
> > +		retval = ixgbe_set_vf_mc_promisc(adapter, msgbuf, vf);
> > +		break;
> >   	default:
> >   		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
> >   		retval = IXGBE_ERR_MBX;
> > diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > index 88298a3..24b15b1 100644
> > --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > @@ -2217,6 +2217,9 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
> >   				IXGBE_TXDCTL_SWFLSH);
> >   	}
> >
> > +	/* drop multicast promiscuous mode flag */
> > +	adapter->hw.mac.mc_promisc = false;
> > +
> >   	if (!pci_channel_offline(adapter->pdev))
> >   		ixgbevf_reset(adapter);
> >
> > diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
> > index 82f44e0..ca6f8e9 100644
> > --- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
> > +++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
> > @@ -112,6 +112,8 @@ enum ixgbe_pfvf_api_rev {
> >   #define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
> >   #define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS hash key */
> >
> > +#define IXGBE_VF_SET_MC_PROMISC	0x0c	/* VF requests MC promiscuous */
> > +
> >   /* length of permanent address message returned from PF */
> >   #define IXGBE_VF_PERMADDR_MSG_LEN	4
> >   /* word in permanent address message with the current multicast type */
> > diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
> > index d1339b0..d98aa8c 100644
> > --- a/drivers/net/ethernet/intel/ixgbevf/vf.c
> > +++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
> > @@ -120,6 +120,9 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
> >   	ether_addr_copy(hw->mac.perm_addr, addr);
> >   	hw->mac.mc_filter_type = msgbuf[IXGBE_VF_MC_TYPE_WORD];
> >
> > +	/* after reset, MC promiscuous mode is disabled */
> > +	hw->mac.mc_promisc = false;
> > +
> >   	return 0;
> >   }
> >
> > @@ -423,6 +426,34 @@ static void ixgbevf_write_msg_read_ack(struct ixgbe_hw *hw,
> >   		mbx->ops.read_posted(hw, retmsg, size);
> >   }
> >
> > +static s32 ixgbevf_request_mc_promisc_vf(struct ixgbe_hw *hw)
> > +{
> > +	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
> > +	int err;
> > +
> > +	memset(msgbuf, 0, sizeof(msgbuf));
> > +
> > +	/* enabling multicast promiscuous */
> > +	msgbuf[0] = IXGBE_VF_SET_MC_PROMISC;
> > +	msgbuf[1] = 1;
> > +
> > +	err = hw->mbx.ops.write_posted(hw, msgbuf, 2);
> > +	if (err)
> > +		return err;
> > +	err = hw->mbx.ops.read_posted(hw, msgbuf, 2);
> > +	if (err)
> > +		return err;
> > +
> > +	msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
> > +
> > +	if (msgbuf[0] == (IXGBE_VF_SET_MC_PROMISC | IXGBE_VT_MSGTYPE_NACK))
> > +		return -EPERM;
> > +
> > +	hw->mac.mc_promisc = true;
> > +
> > +	return 0;
> > +}
> > +
> >   /**
> >    *  ixgbevf_update_mc_addr_list_vf - Update Multicast addresses
> >    *  @hw: pointer to the HW structure
> 
> I would move the API checks up into this call.  You could then just have
> it return -EOPNOTSUPP if the API is not version 1.2 or later.
> 
> > @@ -448,8 +479,22 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
> >   	 */
> >
> >   	cnt = netdev_mc_count(netdev);
> > -	if (cnt > 30)
> > +	if (cnt > 30) {
> > +		/* If the API has the capability to handle MC promiscuous
> > +		 * mode, turn it on.
> > +		 */
> > +		switch (hw->api_version) {
> > +		case ixgbe_mbox_api_12:
> > +			if (hw->mac.mc_promisc ||
> > +			    !ixgbevf_request_mc_promisc_vf(hw)) {
> > +				return 0;
> > +			}
> > +			break;
> > +		default:
> > +			break;
> > +		}
> >   		cnt = 30;
> > +	}
> >   	msgbuf[0] = IXGBE_VF_SET_MULTICAST;
> >   	msgbuf[0] |= cnt << IXGBE_VT_MSGINFO_SHIFT;
> >
> > @@ -465,6 +510,8 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
> >
> >   	ixgbevf_write_msg_read_ack(hw, msgbuf, IXGBE_VFMAILBOX_SIZE);
> >
> > +	hw->mac.mc_promisc = false;
> > +
> >   	return 0;
> >   }
> >
> 
> Rather than burying this inside the ixgbevf_update_mc_addr_list_vf call
> why not provide an interface that allows the netdev to have more direct
> access to the ability to request multicast promiscuous mode?  The fact
> is there is a flag in the netdev (IFF_ALLMULTI) that controls this,
> perhaps it should be used to indicate what it is you are doing here.
> 
> My recommendation would be to pull the logic for setting the mc_promisc
> out into a separate function, and then to update the ixgbevf_set_rx_mode
> call so that you switch over to mutlicast promiscuous if IFF_ALLMULTI is
> set or the number of multicast addresses exceeds 30, else you just fall
> back to writing the value.
> 
> > diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
> > index d40f036..f910b78 100644
> > --- a/drivers/net/ethernet/intel/ixgbevf/vf.h
> > +++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
> > @@ -86,6 +86,7 @@ struct ixgbe_mac_info {
> >   	enum ixgbe_mac_type type;
> >
> >   	s32  mc_filter_type;
> > +	bool mc_promisc;
> >
> >   	bool get_link_status;
> >   	u32  max_tx_queues;
> >
