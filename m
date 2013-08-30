From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v3 1/8] i40e: main driver core
Date: Fri, 30 Aug 2013 09:32:48 -0700
Message-ID: <1377880368.2070.26.camel@joe-AO722>
References: <1377866347-23846-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377866347-23846-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:32963 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756314Ab3H3Qct (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 12:32:49 -0400
In-Reply-To: <1377866347-23846-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-30 at 05:39 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>

trivial comments only:

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c

> +#define DRV_KERN "-k"
> +
> +#define DRV_VERSION_MAJOR 0
> +#define DRV_VERSION_MINOR 3
> +#define DRV_VERSION_BUILD 8
> +#define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
> +	     __stringify(DRV_VERSION_MINOR) "." \
> +	     __stringify(DRV_VERSION_BUILD)    DRV_KERN

does "-k" add/signify anything useful?

> +/* a bit of forward declarations */
> +static void i40e_vsi_reinit_locked(struct i40e_vsi *vsi);
> +static void i40e_handle_reset_warning(struct i40e_pf *pf);
> +static s32 i40e_add_vsi(struct i40e_vsi *vsi);
> +static s32 i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi);
> +static s32 i40e_setup_pf_switch(struct i40e_pf *pf);
> +static int i40e_setup_misc_vector(struct i40e_pf *pf);
> +static i40e_status i40e_determine_queue_usage(struct i40e_pf *pf);
> +static int i40e_setup_pf_filter_control(struct i40e_pf *pf);

pity about these.


> +static int debug = -1;
> +module_param(debug, int, 0);
> +MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");

Maybe make debug a bitfield instead?

> +/**
> + * i40e_allocate_dma_mem_d - OS specific memory alloc for shared code
> + * @hw:   pointer to the HW structure
> + * @mem:  ptr to mem struct to fill out
> + * @size: size of memory requested
> + * @alignment: what to align the allocation to
> + **/
> +i40e_status i40e_allocate_dma_mem_d(struct i40e_hw *hw,
> +				    struct i40e_dma_mem *mem,
> +				    u64 size, u32 alignment)
> +{
> +	struct i40e_pf *pf = (struct i40e_pf *)hw->back;
> +
> +	if (!mem)
> +		return I40E_ERR_PARAM;
> +
> +	mem->size = ALIGN(size, alignment);
> +	mem->va = dma_zalloc_coherent(&pf->pdev->dev, mem->size,
> +				      &mem->pa, GFP_KERNEL);
> +	if (mem->va)
> +		return I40E_SUCCESS;
> +	else
> +		return I40E_ERR_NO_MEMORY;
> +}

I would have written

	if (!mem->va)
		return I40E_ERR_NO_MEMORY;

	return I40E_SUCCESS;
}

so the error checks have the same style and if
ever there's a need to do some other initialization
then it can be done in the normal column.

> +/**
> + * i40e_allocate_virt_mem_d - OS specific memory alloc for shared code
> + * @hw:   pointer to the HW structure
> + * @mem:  ptr to mem struct to fill out
> + * @size: size of memory requested
> + **/
> +i40e_status i40e_allocate_virt_mem_d(struct i40e_hw *hw, struct i40e_virt_mem *mem,
> +				     u32 size)
> +{
> +	if (!mem)
> +		return I40E_ERR_PARAM;
> +
> +	mem->size = size;
> +	mem->va = kzalloc(size, GFP_KERNEL);
> +
> +	if (mem->va)
> +		return I40E_SUCCESS;
> +	else
> +		return I40E_ERR_NO_MEMORY;
> +}

Same style comment as above.

[]

> +/**
> + * i40e_get_netdev_stats_struct - Get statistics for netdev interface
> + * @netdev: network interface device structure
> + *
> + * Returns the address of the device statistics structure.
> + * The statistics are actually updated from the service task.
> + **/
> +static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
> +					     struct net_device *netdev,
> +					     struct rtnl_link_stats64 *storage)

An alternative bsd declaration style might be
more readable for these very long types and names.

static struct rtnl_link_stats64 *
i40e_get_netdev_stats_struct(struct net_device *netdev,
			     struct rtnl_link_stats64 *storage)

> +{
> +	memcpy(storage,
> +	       i40e_get_vsi_stats_struct(
> +			((struct i40e_netdev_priv *)netdev_priv(netdev))->vsi),

temporaries might help.

> +	       sizeof(*storage));
> +
> +	return storage;
> +}

> +/**
> + * i40e_stat_update48 - read and update a 48 bit stat from the chip
> + * @hw: ptr to the hardware info
> + * @hireg: the high 32 bit reg to read
> + * @loreg: the low 32 bit reg to read
> + * @offset_loaded: has the initial offset been loaded yet
> + * @offset: ptr to current offset value
> + * @stat: ptr to the stat
> + *
> + * Since the device stats are not reset at PFReset, they likely will not
> + * be zeroed when the driver starts.  We'll save the first values read
> + * and use them as offsets to be subtracted from the raw values in order
> + * to report stats that count from zero.  In the process, we also manage
> + * the potential roll-over.
> + **/
> +static void i40e_stat_update48(struct i40e_hw *hw, u32 hireg, u32 loreg,
> +			       bool offset_loaded, u64 *offset, u64 *stat)
> +{
> +	u64 new_data;
> +
> +	if (hw->device_id == I40E_QEMU_DEVICE_ID) {
> +		new_data = rd32(hw, loreg);
> +		new_data |= ((u64)(rd32(hw, hireg) & 0xFFFF)) << 32;
> +	} else {
> +		new_data = rd64(hw, loreg);
> +	}

Not that I expect to see this hardware on arm64,
but are there any endian issues here?

[]

> +static int i40e_set_mac(struct net_device *netdev, void *p)
> +{
[]
> +	if (!memcmp(netdev->dev_addr, addr->sa_data, netdev->addr_len))
> +		return 0;

ether_addr_equal?

[]

> +int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
> +{
> +	struct i40e_mac_filter *f, *add_f;
> +	bool is_netdev, is_vf;
> +	i40e_status ret;
> +
> +	is_vf = (vsi->type == I40E_VSI_SRIOV);
> +	is_netdev = !!(vsi->netdev);

unnecessary !!
[]
> +	if (vid > 0) {
> +		if (is_netdev && i40e_find_filter(
> +						  vsi, vsi->netdev->dev_addr,
> +						  I40E_VLAN_ANY,
> +						  is_vf, is_netdev)) {

Odd linebreak after i40e_find_filter

> +			i40e_del_filter(vsi, vsi->netdev->dev_addr,
> +					I40E_VLAN_ANY, is_vf, is_netdev);
> +			add_f = i40e_add_filter(vsi, vsi->netdev->dev_addr, 0,
> +					    is_vf, is_netdev);

nicer to align to open parenthesis

> +			if (add_f == NULL) {

nicer to test
			if (!add_f)
[]
> +	list_for_each_entry(f, &vsi->mac_filter_list, list) {
> +		if (is_netdev) {
> +			if (f->vlan &&
> +			    !memcmp(netdev->dev_addr, f->macaddr,
> +				    netdev->addr_len))

another ether_addr_equal? (last mention)

> +static void i40e_vsi_free_rx_resources(struct i40e_vsi *vsi)
> +{
> +	int i;
> +
> +	for (i = 0; i < vsi->num_queue_pairs; i++)
> +		if (vsi->rx_rings[i].desc)
> +			i40e_free_rx_resources(&vsi->rx_rings[i]);
> +}

maybe add braces to the for loop

> +
> +/**
> + * i40e_configure_tx_ring - Configure a transmit ring context and rest
> + * @ring: The Tx ring to configure
> + *
> + * Configure the Tx descriptor ring in the HMC context.
> + **/
> +static s32 i40e_configure_tx_ring(struct i40e_ring *ring)
> +{
> +	struct i40e_vsi *vsi = ring->vsi;
> +	u16 pf_q = vsi->base_queue + ring->queue_index;
> +	struct i40e_hw *hw = &vsi->back->hw;
> +	struct i40e_hmc_obj_txq tx_ctx;
> +	i40e_status err = I40E_SUCCESS;
> +	u32 qtx_ctl = 0;
> +
> +	/* some ATR related tx ring init */
> +	if (vsi->back->flags & I40E_FLAG_FDIR_ATR_ENABLED) {
> +		ring->atr_sample_rate = vsi->back->atr_sample_rate;
> +		ring->atr_count = 0;
> +	} else {
> +		ring->atr_sample_rate = 0;
> +	}
> +
> +	/* clear the context structure first */
> +	memset(&tx_ctx, 0, sizeof(struct i40e_hmc_obj_txq));

	memset(&tx_ctx, 0, sizeof(tx_ctx));

(too long, stopped reading)
