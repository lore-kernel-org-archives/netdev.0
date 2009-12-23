From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2 02/12] ixgbevf: 82599 Virtual Function core
	functions and header
Date: Wed, 23 Dec 2009 20:22:26 +0000
Message-ID: <1261599746.2782.66.camel@achroite.uk.solarflarecom.com>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
	 <20091218225123.10698.8625.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20146 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027AbZLWUWa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 15:22:30 -0500
In-Reply-To: <20091218225123.10698.8625.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-18 at 14:51 -0800, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
>=20
> This module and header file contain the core functions for the 82599
> virtual function device.
[...]
> diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/ixgbevf/vf.c
> new file mode 100644
> index 0000000..38784eb
> --- /dev/null
> +++ b/drivers/net/ixgbevf/vf.c
[...]
> +/**
> + *  ixgbevf_set_rar_vf - set device MAC address
> + *  @hw: pointer to hardware structure
> + *  @index: Receive address register to write
> + *  @addr: Address to put into receive address register
> + *  @vmdq: VMDq "set" or "pool" index
> + **/
> +static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *ad=
dr,
> +			      u32 vmdq)
> +{
> +	struct ixgbe_mbx_info *mbx =3D &hw->mbx;
> +	u32 msgbuf[3];
> +	u8 *msg_addr =3D (u8 *)(&msgbuf[1]);
> +	s32 ret_val;
> +
> +	memset(msgbuf, 0, 12);

Seems like it would be clearer to write sizeof(msgbuf) rather than 12.
But does it even matter that you clear the padding bytes?

[...]
> +/**
> + *  ixgbevf_update_mc_addr_list_vf - Update Multicast addresses
> + *  @hw: pointer to the HW structure
> + *  @mc_addr_list: array of multicast addresses to program
> + *  @mc_addr_count: number of multicast addresses to program
> + *  @next: caller supplied function to return next address in list
> + *
> + *  Updates the Multicast Table Array.
> + **/
> +static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw, u8 *m=
c_addr_list,
> +					u32 mc_addr_count,
> +					ixgbe_mc_addr_itr next)
> +{
> +	struct ixgbe_mbx_info *mbx =3D &hw->mbx;
> +	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
> +	u16 *vector_list =3D (u16 *)&msgbuf[1];
> +	u32 vector;
> +	u32 cnt, i;
> +	u32 vmdq;
> +
> +	/* Each entry in the list uses 1 16 bit word.  We have 30
> +	 * 16 bit words available in our HW msg buffer (minus 1 for the
> +	 * msg type).  That's 30 hash values if we pack 'em right.  If
> +	 * there are more than 30 MC addresses to add then punt the
> +	 * extras for now and then add code to handle more than 30 later.
> +	 * It would be unusual for a server to request that many multi-cast
> +	 * addresses except for in large enterprise network environments.
> +	 */
> +	cnt =3D (mc_addr_count > 30) ? 30 : mc_addr_count;

What, you don't want to support large enterprise networks now? ;-)
You should switch to all-multicast behaviour rather than dropping
multicast addresses.

[...]
> +/**
> + *  ixgbevf_get_mac_addr_vf - Read device MAC address
> + *  @hw: pointer to the HW structure

The mac_addr parameter is missing.

> + **/
> +static s32 ixgbevf_get_mac_addr_vf(struct ixgbe_hw *hw, u8 *mac_addr=
)
> +{
> +	int i;
> +
> +	for (i =3D 0; i < IXGBE_ETH_LENGTH_OF_ADDRESS; i++)
> +		mac_addr[i] =3D hw->mac.perm_addr[i];

memcpy()?

[...]
> +/**
> + *  ixgbevf_setup_mac_link_vf - Setup MAC link settings
> + *  @hw: pointer to hardware structure
> + *  @speed: new link speed
> + *  @autoneg: true if autonegotiation enabled
> + *  @autoneg_wait_to_complete: true when waiting for completion is n=
eeded
> + *
> + *  Set the link speed in the AUTOC register and restarts link.
> + **/
=EF=BB=BF
This description is obviously not correct.

> +static s32 ixgbevf_setup_mac_link_vf(struct ixgbe_hw *hw,
> +				     ixgbe_link_speed speed, bool autoneg,
> +				     bool autoneg_wait_to_complete)
> +{
> +	return 0;
> +}
[...]
> diff --git a/drivers/net/ixgbevf/vf.h b/drivers/net/ixgbevf/vf.h
> new file mode 100644
> index 0000000..799600e
> --- /dev/null
> +++ b/drivers/net/ixgbevf/vf.h
[...]
> +struct ixgbe_mac_operations {
> +	s32 (*init_hw)(struct ixgbe_hw *);
> +	s32 (*reset_hw)(struct ixgbe_hw *);
> +	s32 (*start_hw)(struct ixgbe_hw *);
> +	s32 (*clear_hw_cntrs)(struct ixgbe_hw *);
> +	enum ixgbe_media_type (*get_media_type)(struct ixgbe_hw *);
> +	u32 (*get_supported_physical_layer)(struct ixgbe_hw *);
> +	s32 (*get_mac_addr)(struct ixgbe_hw *, u8 *);
> +	s32 (*stop_adapter)(struct ixgbe_hw *);
> +	s32 (*get_bus_info)(struct ixgbe_hw *);
> +
> +	/* Link */
> +	s32 (*setup_link)(struct ixgbe_hw *, ixgbe_link_speed, bool, bool);
> +	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *, bo=
ol);
> +	s32 (*get_link_capabilities)(struct ixgbe_hw *, ixgbe_link_speed *,
> +				     bool *);
> +
> +	/* RAR, Multicast, VLAN */
> +	s32 (*set_rar)(struct ixgbe_hw *, u32, u8 *, u32);
> +	s32 (*init_rx_addrs)(struct ixgbe_hw *);
> +	s32 (*update_mc_addr_list)(struct ixgbe_hw *, u8 *, u32,
> +				   ixgbe_mc_addr_itr);
> +	s32 (*enable_mc)(struct ixgbe_hw *);
> +	s32 (*disable_mc)(struct ixgbe_hw *);
> +	s32 (*clear_vfta)(struct ixgbe_hw *);
> +	s32 (*set_vfta)(struct ixgbe_hw *, u32, u32, bool);
> +};
> +
> +enum ixgbe_mac_type {
> +	ixgbe_mac_unknown =3D 0,
> +	ixgbe_mac_82599_vf,
> +	ixgbe_num_macs
> +};

Is this abstraction really justified, given you have only one
implementation?

[...]
> +struct ixgbe_mbx_operations {
> +	s32 (*init_params)(struct ixgbe_hw *hw);
> +	s32 (*read)(struct ixgbe_hw *, u32 *, u16);
> +	s32 (*write)(struct ixgbe_hw *, u32 *, u16);
> +	s32 (*read_posted)(struct ixgbe_hw *, u32 *, u16);
> +	s32 (*write_posted)(struct ixgbe_hw *, u32 *, u16);
> +	s32 (*check_for_msg)(struct ixgbe_hw *);
> +	s32 (*check_for_ack)(struct ixgbe_hw *);
> +	s32 (*check_for_rst)(struct ixgbe_hw *);
> +};
[...]

Ditto for this.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

