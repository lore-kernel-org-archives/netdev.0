From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next v2 1/8] i40e: main driver core
Date: Fri, 23 Aug 2013 18:35:33 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416C615CEA@FMSMSX102.amr.corp.intel.com>
References: <1377224142-25160-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1377224142-25160-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <52174988.2060708@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Stefan Assmann <sassmann@kpanic.de>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16751 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755640Ab3HWSfg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 14:35:36 -0400
In-Reply-To: <52174988.2060708@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stefan Assmann [mailto:sassmann@kpanic.de]
> Sent: Friday, August 23, 2013 4:38 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Brandeburg, Jesse; netdev@vger.kernel.org;
> gospo@redhat.com; Nelson, Shannon; Waskiewicz Jr, Peter P; e1000-
> devel@lists.sourceforge.net
> Subject: Re: [net-next v2 1/8] i40e: main driver core

Thanks, Stefan, for your time and comments on this and on the following postings.  We appreciate the detailed feedback.

> 
> On 23.08.2013 04:15, Jeff Kirsher wrote:
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >
> > This is the driver for the Intel(R) Ethernet Controller XL710 Family.
> >
> > This driver is targeted at basic ethernet functionality only, and will
> be
> > improved upon further as time goes on.
> >
> > This patch mail contains the driver entry points but does not include
> transmit
> > and receive (see the next patch in the series) routines.
> 
> [...]
> 
> I see the term VSI a lot in the code, what exactly does it mean?

VSI is short for Virtual Station Interface - essentially a generic name for VMDq and VF type virtual interfaces into a network device.  It's part of the nomenclature coming from the IEEE 802.1Qbg work.  In our driver, a VSI is how we collect sets of Tx/Rx queues and mac address filters for HW offloading of network virtualization.  Not every VSI will have a netdev associated to it, tho' it is a handy way to think about how they are used.

> 
> > ---
> >  drivers/net/ethernet/intel/i40e/i40e_main.c | 7520
> +++++++++++++++++++++++++++
> >  1 file changed, 7520 insertions(+)
> >  create mode 100644 drivers/net/ethernet/intel/i40e/i40e_main.c
> >
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > new file mode 100644
> > index 0000000..c2a79b5
> > --- /dev/null
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> 
> [...]
> 
> > +/**
> > + * i40e_allocate_dma_mem_d - OS specific memory alloc for shared code
> > + * @hw:   pointer to the HW structure
> > + * @mem:  ptr to mem struct to fill out
> > + * @size: size of memory requested
> > + * @alignment: what to align the allocation to
> > + **/
> > +enum i40e_status_code i40e_allocate_dma_mem_d(struct i40e_hw *hw,
> 
> If you want to use an enum I suggest you shorten the name to something
> like i40e_sc, otherwise the function declaration lines will become
> longer than needed and we'll have to split the arguments across multiple
> lines more than necessary.

This is where I whine about it being too late to change such a basic datatype in all the shared code of our other OS drivers that use it, and no one wants to hear it.  You're right, of course, and we'll see what we can do about compressing it a little.

> 
> > +					      struct i40e_dma_mem *mem,
> > +					      u64 size, u32 alignment)
> > +{
> > +	struct i40e_pf *pf = (struct i40e_pf *)hw->back;
> > +
> > +	if (!mem)
> > +		return I40E_ERR_PARAM;
> > +
> > +	mem->size = ALIGN(size, alignment);
> > +	/* GFP_ZERO zeros the memory */
> > +	mem->va = dma_alloc_coherent(&pf->pdev->dev, mem->size,
> > +				     &mem->pa, GFP_ATOMIC | __GFP_ZERO);
> > +	if (mem->va)
> > +		return I40E_SUCCESS;
> > +	else
> > +		return I40E_ERR_NO_MEMORY;
> 
> Just wondering why you don't use the standard error codes like ENOMEM?

Some of these choices are driven by our use of code that is shared with other OSs.

> 
> > +}
> > +
> > +/**
> > + * i40e_free_dma_mem_d - OS specific memory free for shared code
> > + * @hw:   pointer to the HW structure
> > + * @mem:  ptr to mem struct to free
> > + **/
> > +enum i40e_status_code i40e_free_dma_mem_d(struct i40e_hw *hw,
> > +					  struct i40e_dma_mem *mem)
> > +{
> > +	struct i40e_pf *pf = (struct i40e_pf *)hw->back;
> > +
> > +	if (!mem || !mem->va)
> > +		return I40E_ERR_PARAM;
> > +	dma_free_coherent(&pf->pdev->dev, mem->size, mem->va, mem->pa);
> > +	mem->va = NULL;
> > +	mem->pa = (dma_addr_t)NULL;
> 
> Missing a blank line here.

Thanks.

> 
> [...]
> 
> > +/**
> > + * i40e_get_lump - find a lump of free generic resource
> > + * @pile: the pile of resource to search
> > + * @needed: the number of items needed
> > + * @id: an owner id to stick on the items assigned
> > + *
> > + * Returns the base item index of the lump, or negative for error
> > + *
> > + * The search_hint trick and lack of advanced fit-finding only work
> > + * because we're highly likely to have all the same size lump
> requests.
> > + * Linear search time and any fragmentation should be minimal.
> > + **/
> > +static int i40e_get_lump(struct i40e_lump_tracking *pile, u16 needed,
> u16 id)
> > +{
> > +	int i = 0, j = 0;
> > +	int ret = I40E_ERR_NO_MEMORY;
> > +
> > +	if (pile == NULL || needed == 0 || id >= I40E_PILE_VALID_BIT) {
> > +		pr_info("%s: param err: pile=%p needed=%d id=0x%04x\n",
> > +		       __func__, pile, needed, id);
> 
> Shouldn't this be indented by another tab instead of the spaces? Maybe
> you could use netdev_info() instead of pr_info() so it's easier to
> understand which device is meant.

Arf, where'd those spaces come from?  Will fix.

Yeah, Dave mentioned the dev_info() need as well.

> 
> > +		return I40E_ERR_PARAM;
> > +	}
> > +
> > +	/* start the linear search with an imperfect hint */
> > +	i = pile->search_hint;
> > +	while (i < pile->num_entries && ret < 0) {
> > +		/* skip already allocated entries */
> > +		if (pile->list[i] & I40E_PILE_VALID_BIT) {
> > +			i++;
> > +			continue;
> > +		}
> > +
> > +		/* do we have enough in this lump? */
> > +		for (j = 0; (j < needed) && ((i+j) < pile->num_entries); j++)
> {
> > +			if (pile->list[i+j] & I40E_PILE_VALID_BIT)
> > +				break;
> > +		}
> > +
> > +		if (j == needed) {
> > +			/* there was enough, so assign it to the requestor */
> > +			for (j = 0; j < needed; j++)
> > +				pile->list[i+j] = id | I40E_PILE_VALID_BIT;
> > +			ret = i;
> > +			pile->search_hint = i + j;
> > +		} else {
> > +			/* not enough, so skip over it and continue looking */
> > +			i += j;
> > +		}
> > +	}
> > +
> > +	return ret;
> > +}
> > +
> > +/**
> > + * i40e_put_lump - return a lump of generic resource
> > + * @pile: the pile of resource to search
> > + * @index: the base item index
> > + * @id: the owner id of the items assigned
> > + *
> > + * Returns the count of items in the lump
> > + **/
> > +static int i40e_put_lump(struct i40e_lump_tracking *pile, u16 index,
> u16 id)
> > +{
> > +	int i = index;
> > +	int count = 0;
> > +
> > +	if (pile == NULL || index >= pile->num_entries)
> > +		return I40E_ERR_PARAM;
> > +
> > +	for (i = index;
> > +	     i < pile->num_entries && pile->list[i] ==
> (id|I40E_PILE_VALID_BIT);
> 
> Missing spaces around |.

Got it.

> 
> [...]
> 
> > +static void i40e_tx_timeout(struct net_device *netdev)
> > +{
> > +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> > +	struct i40e_vsi *vsi = np->vsi;
> > +	struct i40e_pf *pf = vsi->back;
> > +
> > +	pf->tx_timeout_count++;
> > +
> > +	if (time_after(jiffies, (pf->tx_timeout_last_recovery + HZ*20)))
> > +		pf->tx_timeout_recovery_level = 0;
> > +	pf->tx_timeout_last_recovery = jiffies;
> > +	netdev_info(netdev, "%s: recovery level %d\n",
> > +		    __func__, pf->tx_timeout_recovery_level);
> > +
> > +	switch (pf->tx_timeout_recovery_level) {
> > +	case 0:
> > +		/* disable and re-enable queues for the VSI */
> > +		if (in_interrupt()) {
> > +			set_bit(__I40E_REINIT_REQUESTED, &pf->state);
> > +			set_bit(__I40E_REINIT_REQUESTED, &vsi->state);
> > +		} else {
> > +			i40e_vsi_reinit_locked(vsi);
> > +		}
> > +		break;
> > +	case 1:
> > +		set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
> > +		break;
> > +	case 2:
> > +		set_bit(__I40E_CORE_RESET_REQUESTED, &pf->state);
> > +		break;
> > +	case 3:
> > +		set_bit(__I40E_GLOBAL_RESET_REQUESTED, &pf->state);
> > +		break;
> > +	default:
> > +		netdev_err(netdev, "%s: recovery unsuccessful\n", __func__);
> > +		i40e_down(vsi);
> > +		break;
> > +	}
> > +	i40e_service_event_schedule(pf);
> > +	pf->tx_timeout_recovery_level++;
> > +
> > +	return;
> 
> Function is void, no need for return.

Thanks.

> 
> > +}
> > +
> > +/**
> > + * i40e_release_rx_desc - Store the new tail and head values
> > + * @rx_ring: ring to bump
> > + * @val: new head index
> > + **/
> > +static inline void i40e_release_rx_desc(struct i40e_ring *rx_ring,
> u32 val)
> > +{
> > +	rx_ring->next_to_use = val;
> > +	/* Force memory writes to complete before letting h/w
> > +	 * know there are new descriptors to fetch.  (Only
> > +	 * applicable for weak-ordered memory model archs,
> > +	 * such as IA-64).
> > +	 */
> > +	wmb();
> > +	writel(val, rx_ring->tail);
> > +}
> > +
> > +/**
> > + * i40e_get_vsi_stats_struct - Get System Network Statistics
> > + * @vsi: the VSI we care about
> > + *
> > + * Returns the address of the device statistics structure.
> > + * The statistics are actually updated from the service task.
> > + **/
> > +struct rtnl_link_stats64 *i40e_get_vsi_stats_struct(struct i40e_vsi
> *vsi)
> > +{
> > +	return &vsi->net_stats;
> > +}
> > +
> > +/**
> > + * i40e_get_netdev_stats_struct - Get statistics for netdev interface
> > + * @netdev: network interface device structure
> > + *
> > + * Returns the address of the device statistics structure.
> > + * The statistics are actually updated from the service task.
> > + **/
> > +static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
> > +					     struct net_device *netdev,
> > +					     struct rtnl_link_stats64 *storage)
> > +{
> > +	memcpy(storage,
> > +	       i40e_get_vsi_stats_struct(
> > +			((struct i40e_netdev_priv *)netdev_priv(netdev))->vsi),
> > +	       sizeof(*storage));
> 
> Missing a blank line.

Sure.

> 
> > +	return storage;
> > +}
> > +
> > +/**
> > + * i40e_vsi_reset_stats - Resets all stats of the given vsi
> > + * @vsi: the VSI to have its stats reset
> > + **/
> > +void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
> > +{
> > +	int i;
> > +	struct rtnl_link_stats64 *ns;
> > +
> > +	if (!vsi)
> > +		return;
> > +
> > +	ns = i40e_get_vsi_stats_struct(vsi);
> > +	memset(ns, 0, sizeof(struct net_device_stats));
> > +	memset(&vsi->net_stats_offsets, 0, sizeof(struct
> net_device_stats));
> > +	memset(&vsi->eth_stats, 0, sizeof(struct i40e_eth_stats));
> > +	memset(&vsi->eth_stats_offsets, 0, sizeof(struct i40e_eth_stats));
> > +	if (vsi->rx_rings)
> > +		for (i = 0; i < vsi->num_queue_pairs; i++) {
> > +			memset(&vsi->rx_rings[i].rx_stats, 0 ,
> > +				sizeof(struct i40e_rx_queue_stats));
> > +			memset(&vsi->tx_rings[i].tx_stats, 0,
> > +				sizeof(struct i40e_tx_queue_stats));
> > +		}
> > +	vsi->stat_offsets_loaded = false;
> > +}
> > +
> > +/**
> > + * i40e_pf_reset_stats - Reset all of the stats for the given pf
> > + * @pf: the PF to be reset
> > + **/
> > +void i40e_pf_reset_stats(struct i40e_pf *pf)
> > +{
> > +	memset(&pf->stats, 0, sizeof(struct i40e_hw_port_stats));
> > +	memset(&pf->stats_offsets, 0, sizeof(struct i40e_hw_port_stats));
> > +	pf->stat_offsets_loaded = false;
> > +
> 
> Remove blank line above.

Yep.

> 
> > +}
> > +
> > +/**
> > + * i40e_stat_update48 - read and update a 48 bit stat from the chip
> > + * @hw: ptr to the hardware info
> > + * @hireg: the high 32 bit reg to read
> > + * @loreg: the low 32 bit reg to read
> > + * @offset_loaded: has the initial offset been loaded yet
> > + * @offset: ptr to current offset value
> > + * @stat: ptr to the stat
> > + *
> > + * Since the device stats are not reset at PFReset, they likely will
> not
> > + * be zeroed when the driver starts.  We'll save the first values
> read
> > + * and use them as offsets to be subtracted from the raw values in
> order
> > + * to report stats that count from zero.  In the process, we also
> manage
> > + * the potential roll-over.
> > + **/
> > +static void i40e_stat_update48(struct i40e_hw *hw, u32 hireg, u32
> loreg,
> > +			       bool offset_loaded, u64 *offset, u64 *stat)
> > +{
> > +	u64 new_data;
> 
> Missing a blank line.

Yep.

> 
> > +	if (hw->device_id == I40E_QEMU_DEVICE_ID) {
> > +		new_data = rd32(hw, loreg);
> > +		new_data |= ((u64)(rd32(hw, hireg) & 0xFFFF)) << 32;
> > +	} else {
> > +		new_data = rd64(hw, loreg);
> > +	}
> > +	if (!offset_loaded)
> > +		*offset = new_data;
> > +	if (likely(new_data >= *offset))
> > +		*stat = new_data - *offset;
> > +	else
> > +		*stat = (new_data + ((u64)1 << 48)) - *offset;
> > +	*stat &= 0xFFFFFFFFFFFFULL;
> > +}
> > +
> > +/**
> > + * i40e_stat_update32 - read and update a 32 bit stat from the chip
> > + * @hw: ptr to the hardware info
> > + * @reg: the hw reg to read
> > + * @offset_loaded: has the initial offset been loaded yet
> > + * @offset: ptr to current offset value
> > + * @stat: ptr to the stat
> > + **/
> > +static void i40e_stat_update32(struct i40e_hw *hw, u32 reg,
> > +			       bool offset_loaded, u64 *offset, u64 *stat)
> > +{
> > +	u32 new_data;
> 
> Missing a blank line.

Yep.

> 
> > +	new_data = rd32(hw, reg);
> > +	if (!offset_loaded)
> > +		*offset = new_data;
> > +	if (likely(new_data >= *offset))
> > +		*stat = (u32)(new_data - *offset);
> > +	else
> > +		*stat = (u32)((new_data + ((u64)1 << 32)) - *offset);
> > +}
> 
> [...]
> 
> > +/**
> > + * i40e_is_vsi_in_vlan - Check if VSI is in vlan mode
> > + * @vsi: the VSI to be searched
> > + *
> > + * Returns true if VSI is in vlan mode or false otherwise
> > + **/
> > +bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi)
> > +{
> > +	struct i40e_mac_filter *f;
> > +
> > +	/* Only -1 for all the filters denotes not in vlan mode
> > +	 * so we have to go through all the list in order to make sure
> > +	 */
> > +	list_for_each_entry(f, &vsi->mac_filter_list, list) {
> > +		if (f->vlan < 0)
> > +			return false;
> > +	}
> > +
> > +	return true;
> > +}
> > +
> > +/**
> > + * i40e_put_mac_in_vlan - Goes through all the macvlan filters and
> adds a
> > + *  macvlan filter for each unique vlan that already exists
> 
> Superfluous space at the beginning.

Even better, that needs to be reworked to be a single line description.

> 
> > + * @vsi: the VSI to be searched
> > + * @macaddr: the mac address to be filtered
> > + * @is_vf: true if it is a vf
> > + * @is_netdev: true if it is a netdev
> > + *
> > + * Returns I40E_SUCCESS on success or -ENOMEM if it could not add a
> filter
> > + **/
> > +enum i40e_status_code i40e_put_mac_in_vlan(struct i40e_vsi *vsi,
> > +						  u8 *macaddr,
> > +						  bool is_vf, bool is_netdev)
> 
> This could be better indented, aligned with the struct i40e_vsi.

Yep.

> 
> > +{
> > +	struct i40e_mac_filter *f, *add_f;
> > +
> > +	list_for_each_entry(f, &vsi->mac_filter_list, list) {
> > +		if (!i40e_find_filter(vsi, macaddr, f->vlan,
> > +				      is_vf, is_netdev)) {
> > +			add_f = i40e_add_filter(vsi, macaddr, f->vlan,
> > +						is_vf, is_netdev);
> > +
> > +			if (NULL == add_f) {
> > +				dev_info(&vsi->back->pdev->dev, "%s: Could not add
> filter %d for %pM\n",
> > +					 __func__, f->vlan, f->macaddr);
> > +				return -ENOMEM;
> > +			}
> > +		}
> > +	}
> > +	return I40E_SUCCESS;
> > +}
> > +
> > +/**
> > + * i40e_add_filter - Add a mac/vlan filter to the VSI
> > + * @vsi: the VSI to be searched
> > + * @macaddr: the MAC address
> > + * @vlan: the vlan
> > + * @is_vf: make sure its a vf filter, else doesn't matter
> > + * @is_netdev: make sure its a netdev filter, else doesn't matter
> > + *
> > + * Returns ptr to the filter object or NULL when no memory available.
> > + **/
> > +struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
> > +					u8 *macaddr, s16 vlan,
> > +					bool is_vf, bool is_netdev)
> > +{
> > +	struct i40e_mac_filter *f;
> 
> Just f seems to be a bad naming, can we come up with a more fitting
> name for this?

It seemed like a reasonable choice for an often-referenced object and the primary focus of the function.  I understand your concern, but I think when used consistently it's not quite the problem that some other willy-nilly single letter variables can be.

> 
> > +
> > +	if (!vsi || !macaddr)
> > +		return NULL;
> > +
> > +	f = i40e_find_filter(vsi, macaddr, vlan, is_vf, is_netdev);
> > +	if (NULL == f) {
> > +		f = kzalloc(sizeof(*f), GFP_ATOMIC);
> > +		if (NULL == f)
> > +			goto add_filter_out;
> > +
> > +		memcpy(f->macaddr, macaddr, ETH_ALEN);
> > +		f->vlan = vlan;
> > +		f->changed = true;
> > +
> > +		INIT_LIST_HEAD(&f->list);
> > +		list_add(&f->list, &vsi->mac_filter_list);
> > +	}
> > +
> > +	/* increment counter and add a new flag if needed */
> > +	if (is_vf) {
> > +		if (!f->is_vf) {
> > +			f->is_vf = true;
> > +			f->counter++;
> > +		}
> > +	} else if (is_netdev) {
> > +		if (!f->is_netdev) {
> > +			f->is_netdev = true;
> > +			f->counter++;
> > +		}
> > +	} else {
> > +		f->counter++;
> > +	}
> > +
> > +	/* changed tells sync_filters_subtask to
> > +	 * push the filter down to the firmware
> > +	 */
> > +	if (f->changed) {
> > +		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
> > +		vsi->back->flags |= I40E_FLAG_FILTER_SYNC;
> > +	}
> > +
> > +add_filter_out:
> > +	return f;
> > +}
> > +
> > +/**
> > + * i40e_del_filter - Remove a mac/vlan filter from the VSI
> > + * @vsi: the VSI to be searched
> > + * @macaddr: the MAC address
> > + * @vlan: the vlan
> > + * @is_vf: make sure it's a vf filter, else doesn't matter
> > + * @is_netdev: make sure it's a netdev filter, else doesn't matter
> > + **/
> > +void i40e_del_filter(struct i40e_vsi *vsi,
> > +		     u8 *macaddr, s16 vlan,
> > +		     bool is_vf, bool is_netdev)
> 
> Again, please indent properly. I'm not going to make further comments
> about this.

Huh, odd, most of these are correct on my side - I'll have to look into how they got messed up on the way out.

> 
> > +{
> > +	struct i40e_mac_filter *f;
> > +
> > +	if (!vsi || !macaddr)
> > +		return;
> > +
> > +	f = i40e_find_filter(vsi, macaddr, vlan, is_vf, is_netdev);
> > +	if (NULL == f || f->counter == 0)
> > +		goto del_filter_out;
> > +
> > +	if (is_vf) {
> > +		if (f->is_vf) {
> > +			f->is_vf = false;
> > +			f->counter--;
> > +		}
> > +	} else if (is_netdev) {
> > +		if (f->is_netdev) {
> > +			f->is_netdev = false;
> > +			f->counter--;
> > +		}
> > +	} else {
> > +		/* make sure we don't remove a filter in use by vf or netdev
> */
> > +		int min_f = 0;
> > +		min_f += (f->is_vf ? 1 : 0);
> > +		min_f += (f->is_netdev ? 1 : 0);
> > +
> > +		if (f->counter > min_f)
> > +			f->counter--;
> > +	}
> > +
> > +	/* counter == 0 tells sync_filters_subtask to
> > +	 * remove the filter from the firmware's list
> > +	 */
> > +	if (f->counter == 0) {
> > +		f->changed = true;
> > +		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
> > +		vsi->back->flags |= I40E_FLAG_FILTER_SYNC;
> > +	}
> > +
> > +del_filter_out:
> > +	return;
> 
> [...]
> 
> > +/**
> > + * i40e_sync_vsi_filters - Update the VSI filter list to the HW
> > + * @vsi: ptr to the VSI
> > + *
> > + * Push any outstanding VSI filter changes through the AdminQ.
> > + *
> > + * Returns I40E_SUCCESS or error value
> > + **/
> > +enum i40e_status_code i40e_sync_vsi_filters(struct i40e_vsi *vsi)
> > +{
> > +	struct i40e_mac_filter *f, *ftmp;
> > +	struct i40e_pf *pf;
> > +	int num_add = 0;
> > +	int num_del = 0;
> > +	u32 changed_flags = 0;
> > +	bool add_happened = false;
> > +	bool promisc_forced_on = false;
> > +	enum i40e_status_code ret = I40E_SUCCESS;
> > +	u16 cmd_flags;
> > +
> > +#define FILTER_LIST_LEN 30
> 
> Having the defines in one place at the top of the file would be nice,
> unless there's a special reason to have it here.

The reason is that it isn't needed/used anywhere else, it is simply a constant used in this function to set an arbitrary list length for processing the filters.  However, since it is slightly related to the amount of data we can send down in the AQ request, perhaps we can compute a useful constant based on buffer size rather than using a random #define.

> 
> > +	/* empty array typed pointers, kcalloc later */
> > +	struct i40e_aqc_add_macvlan_element_data *add_list;
> > +	struct i40e_aqc_remove_macvlan_element_data *del_list;
> > +
> > +	if (!vsi)
> > +		return I40E_ERR_PARAM;
> > +	while (test_and_set_bit(__I40E_CONFIG_BUSY, &vsi->state))
> > +		usleep_range(1000, 2000);
> > +	pf = vsi->back;
> > +
> > +	if (vsi->netdev) {
> > +		changed_flags = vsi->current_netdev_flags ^ vsi->netdev-
> >flags;
> > +		vsi->current_netdev_flags = vsi->netdev->flags;
> > +	}
> > +
> > +	if (vsi->flags & I40E_VSI_FLAG_FILTER_CHANGED) {
> > +		vsi->flags &= ~I40E_VSI_FLAG_FILTER_CHANGED;
> > +
> > +		del_list = kcalloc(FILTER_LIST_LEN,
> > +			    sizeof(struct i40e_aqc_remove_macvlan_element_data),
> > +			    GFP_KERNEL);
> > +		if (!del_list)
> > +			return I40E_ERR_NO_MEMORY;
> > +
> > +		list_for_each_entry_safe(f, ftmp, &vsi->mac_filter_list,
> list) {
> > +			if (!f->changed)
> > +				continue;
> > +
> > +			if (f->counter != 0)
> > +				continue;
> > +			f->changed = false;
> > +			cmd_flags = 0;
> > +
> > +			/* add to delete list */
> > +			memcpy(del_list[num_del].mac_addr,
> > +			       f->macaddr, ETH_ALEN);
> > +			del_list[num_del].vlan_tag =
> > +				cpu_to_le16((u16)(f->vlan ==
> > +					    I40E_VLAN_ANY ? 0 : f->vlan));
> > +
> > +			/* vlan0 as wild card to allow packets from all vlans */
> > +			if (f->vlan == I40E_VLAN_ANY ||
> > +			    (vsi->netdev && !(vsi->netdev->features &
> > +					      NETIF_F_HW_VLAN_CTAG_FILTER)))
> > +				cmd_flags |= I40E_AQC_MACVLAN_DEL_IGNORE_VLAN;
> > +			cmd_flags |= I40E_AQC_MACVLAN_DEL_PERFECT_MATCH;
> > +			del_list[num_del].flags = cpu_to_le16(cmd_flags);
> > +			num_del++;
> > +
> > +			/* unlink from filter list */
> > +			list_del(&f->list);
> > +			kfree(f);
> > +
> > +			/* flush a full buffer */
> > +			if (num_del == FILTER_LIST_LEN) {
> > +				ret = i40e_aq_remove_macvlan(&pf->hw,
> > +					    vsi->seid, del_list, num_del,
> > +					    NULL);
> > +				num_del = 0;
> > +				memset(del_list, 0, sizeof(*del_list));
> > +
> > +				if (ret != I40E_SUCCESS)
> > +					dev_info(&pf->pdev->dev,
> 
> Maybe use netdev_info() instead of dev_info() in the whole driver? Would
> be nice if this was consistent.

We have to be careful about our use of netdev_info() because not always is there a netdev related to the operation.  For example, if we're adding filters on behalf of one of our VFs, the netdev is in the VF context and we don't have access to it.

> 
> [...]
> 
> > +/**
> > + * i40e_change_mtu - NDO callback to change the Maximum Transfer Unit
> > + * @netdev: network interface device structure
> > + * @new_mtu: new value for maximum frame size
> > + *
> > + * Returns 0 on success, negative on failure
> > + **/
> > +static int i40e_change_mtu(struct net_device *netdev, int new_mtu)
> > +{
> > +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> > +	struct i40e_vsi *vsi = np->vsi;
> > +	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
> > +
> > +	/* MTU < 68 is an error and causes problems on some kernels */
> > +	if ((new_mtu < 68) || (max_frame > I40E_MAX_RXBUFFER))
> 
> Maybe add another netdev_info that MTU < 68 is not supported? Not sure
> if it makes sense to set it that low. Never mind if it's just a corner
> case.

Yes, this is a seldom used corner case, and we're using the same check as in our other drivers.

> 
> > +		return -EINVAL;
> > +
> > +	netdev_info(netdev, "%s: changing MTU from %d to %d\n",
> > +		    __func__, netdev->mtu, new_mtu);
> > +	netdev->mtu = new_mtu;
> > +	if (netif_running(netdev))
> > +		i40e_vsi_reinit_locked(vsi);
> > +
> > +	return 0;
> > +}
> 
> [...]
> 
> > +/**
> > + * i40e_enable_misc_int_causes - enable the non-queue interrupts
> > + * @hw: ptr to the hardware info
> > + **/
> > +static void i40e_enable_misc_int_causes(struct i40e_hw *hw)
> > +{
> > +	u32 val;
> > +
> > +	/* clear things first */
> > +	wr32(hw, I40E_PFINT_ICR0_ENA, 0);  /* disable all */
> > +	rd32(hw, I40E_PFINT_ICR0);         /* read to clear */
> > +
> > +	val = I40E_PFINT_ICR0_ENA_ECC_ERR_MASK	     |
> > +	      I40E_PFINT_ICR0_ENA_MAL_DETECT_MASK    |
> > +	      I40E_PFINT_ICR0_ENA_GRST_MASK	     |
> > +	      I40E_PFINT_ICR0_ENA_PCI_EXCEPTION_MASK |
> > +	      I40E_PFINT_ICR0_ENA_GPIO_MASK	     |
> > +	      I40E_PFINT_ICR0_ENA_STORM_DETECT_MASK  |
> > +	      I40E_PFINT_ICR0_ENA_HMC_ERR_MASK	     |
> > +	      I40E_PFINT_ICR0_ENA_VFLR_MASK          |
> > +	      I40E_PFINT_ICR0_ENA_ADMINQ_MASK;
> 
> Inconsistent mix of tabs and whitespaces in the lines above. I guess you
> just missed the tab at the end of I40E_PFINT_ICR0_ENA_VFLR_MASK.

We'll tweak that.

> 
> > +
> > +	wr32(hw, I40E_PFINT_ICR0_ENA, val);
> > +
> > +	/* SW_ITR_IDX = 0, but don't change INTENA */
> > +	wr32(hw, I40E_PFINT_DYN_CTL0, I40E_PFINT_DYN_CTLN_SW_ITR_INDX_MASK
> |
> > +					I40E_PFINT_DYN_CTLN_INTENA_MSK_MASK);
> > +
> > +	/* OTHER_ITR_IDX = 0 */
> > +	wr32(hw, I40E_PFINT_STAT_CTL0, 0);
> > +}
> 
> [...]
> 
> > +/**
> > + * i40e_vsi_configure_bw_alloc - Configure VSI BW allocation per TC
> > + * @vsi: the VSI being configured
> > + * @enabled_tc: TC bitmap
> > + * @bw_credits: BW shared credits per TC
> > + *
> > + * Returns 0 on success, negative value on failure
> > + **/
> > +static s32 i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi,
> > +				       u8 enabled_tc,
> > +				       u8 *bw_share)
> > +{
> > +	int i, ret = 0;
> > +	struct i40e_aqc_configure_vsi_tc_bw_data bw_data;
> > +
> > +	bw_data.tc_valid_bits = enabled_tc;
> > +	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++)
> > +		bw_data.tc_bw_credits[i] = bw_share[i];
> > +
> > +	ret = i40e_aq_config_vsi_tc_bw(&vsi->back->hw, vsi->seid,
> > +				       &bw_data, NULL);
> > +	if (ret != I40E_SUCCESS) {
> > +		dev_info(&vsi->back->pdev->dev,
> > +			 "%s: AQ command Config VSI BW allocation per TC failed
> = %d\n",
> > +			  __func__, vsi->back->hw.aq.asq_last_status);
> > +		return ret;
> > +	}
> > +
> > +	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++)
> > +		vsi->info.qs_handle[i] = bw_data.qs_handles[i];
> > +
> > +	return ret;
> > +
> 
> superfluous blank line.

Yep.

> 
> > +}
> 
> [...]
> 
> > +/**
> > + * i40e_do_reset - Start a PF or Core Reset sequence
> > + * @pf: board private structure
> > + * @reset_flags: which reset is requested
> > + *
> > + * The essential difference in resets is that the PF Reset
> > + * doesn't clear the packet buffers, doesn't reset the PE
> > + * firmware, and doesn't bother the other PFs on the chip.
> > + **/
> > +void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
> > +{
> > +	u32 val;
> > +
> > +	WARN_ON(in_interrupt());
> > +
> > +	/* do the biggest reset indicated */
> > +	if (reset_flags & (1 << __I40E_GLOBAL_RESET_REQUESTED)) {
> > +
> > +		/* Request a Global Reset
> > +		 *
> > +		 * This will start the chip's countdown to the actual full
> > +		 * chip reset event, and a warning interrupt to be sent
> > +		 * to all PFs, including the requestor.  Our handler
> > +		 * for the warning interrupt will deal with the shutdown
> > +		 * and recovery of the switch setup.
> > +		 *
> > +		 * GlobR includes the MAC/PHY in the reset.
> > +		 */
> > +		dev_info(&pf->pdev->dev, "%s: GlobalR requested\n",
> __func__);
> > +		val = rd32(&pf->hw, I40E_GLGEN_RTRIG);
> > +		val |= I40E_GLGEN_RTRIG_GLOBR_MASK;
> > +		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
> > +
> > +	} else if (reset_flags & (1 << __I40E_CORE_RESET_REQUESTED)) {
> > +
> > +		/* Request a Core Reset
> > +		 *
> > +		 * This will start the chip's countdown to the actual full
> > +		 * chip reset event, and a warning interrupt to be sent
> > +		 * to all PFs, including the requestor.  Our handler
> > +		 * for the warning interrupt will deal with the shutdown
> > +		 * and recovery of the switch setup.
> > +		 */
> 
> Both comments for global and core reset are identical except for one
> more line. Could you change the core reset comment to something like:
> "Same as Global Reset excluding MAC/PHY" ?

Sure.

> 
> > +		dev_info(&pf->pdev->dev, "%s: CoreR requested\n", __func__);
> > +		val = rd32(&pf->hw, I40E_GLGEN_RTRIG);
> > +		val |= I40E_GLGEN_RTRIG_CORER_MASK;
> > +		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
> > +		flush(&pf->hw);
> > +
> > +	} else if (reset_flags & (1 << __I40E_PF_RESET_REQUESTED)) {
> > +
> > +		/* Request a PF Reset
> > +		 *
> > +		 * This goes directly to the tear-down and rebuild of
> > +		 * the switch, since we need to do the same recovery as
> > +		 * for the Core Reset.
> > +		 */
> > +		dev_info(&pf->pdev->dev, "%s: PFR requested\n", __func__);
> > +		i40e_handle_reset_warning(pf);
> > +
> > +	} else if (reset_flags & (1 << __I40E_REINIT_REQUESTED)) {
> > +		int v;
> > +
> > +		/* Find the VSI(s) that requested a re-init */
> > +		dev_info(&pf->pdev->dev,
> > +			 "%s: VSI reinit requested\n", __func__);
> > +		for (v = 0; v < pf->hw.func_caps.num_vsis; v++) {
> > +			struct i40e_vsi *vsi = pf->vsi[v];
> > +			if (vsi != NULL &&
> > +			    test_bit(__I40E_REINIT_REQUESTED, &vsi->state)) {
> > +				i40e_vsi_reinit_locked(pf->vsi[v]);
> > +				clear_bit(__I40E_REINIT_REQUESTED, &vsi->state);
> > +			}
> > +		}
> > +
> > +		/* no further action needed, so return now */
> > +		return;
> > +	} else {
> > +		dev_info(&pf->pdev->dev,
> > +			 "%s: bad reset request 0x%08x\n",
> > +			 __func__, reset_flags);
> > +		return;
> > +	}
> > +
> 
> superfluous blank line.

Got it.

> 
> > +}
> 
> [...]
> 
> > +/**
> > + * i40e_link_event - Update netif_carrier status
> > + * @pf: board private structure
> > + **/
> > +static void i40e_link_event(struct i40e_pf *pf)
> > +{
> > +	bool new_link, old_link;
> > +
> > +	new_link = (pf->hw.phy.link_info.link_info & I40E_AQ_LINK_UP);
> > +	old_link = (pf->hw.phy.link_info_old.link_info & I40E_AQ_LINK_UP);
> > +
> > +	if (new_link == old_link)
> > +		return;
> > +
> > +	netdev_info(pf->vsi[pf->lan_vsi]->netdev,
> > +		    "%s: NIC Link is %s\n",
> > +		    __func__, (new_link ? "Up" : "Down"));
> > +
> > +	/* Notify the base of the switch tree connected to
> > +	 * the link.  Floating VEBs are not notified.
> 
> What's a floating VEB?

VEBs usually have an uplink to the physical MAC port, and act as a physical bridge for offloading bridging and filtering duties.  A floating VEB is essentially a bridge with no link to the outside, useful for offloading internal (private) bridging between VMs.  With the lack of support in the kernel and userspace at this time for this offload concept, this comment may not be useful, and we can make it disappear for now.

> 
> > +	 */
> > +	if (pf->lan_veb != I40E_NO_VEB && pf->veb[pf->lan_veb])
> > +		i40e_veb_link_event(pf->veb[pf->lan_veb], new_link);
> > +	else
> > +		i40e_vsi_link_event(pf->vsi[pf->lan_vsi], new_link);
> > +
> > +	if (pf->vf)
> > +		i40e_vc_notify_link_state(pf);
> > +}
> 
> [...]
> 
> > +/**
> > + * i40e_watchdog_subtask - Check and bring link up
> > + * @pf: board private structure
> > + **/
> > +static void i40e_watchdog_subtask(struct i40e_pf *pf)
> > +{
> > +	int v;
> 
> Why did you call the variable v and not i?

No good reason other than it is indexing the vsi array; we can change that name.

> 
> > +
> > +	/* if interface is down do nothing */
> > +	if (test_bit(__I40E_DOWN, &pf->state) ||
> > +	    test_bit(__I40E_CONFIG_BUSY, &pf->state))
> > +		return;
> > +
> > +	/* Update the stats for active netdevs so the network stack
> > +	 * can look at updated numbers whenever it cares to
> > +	 */
> > +	for (v = 0; v < pf->hw.func_caps.num_vsis; v++)
> > +		if (pf->vsi[v] && pf->vsi[v]->netdev)
> > +			i40e_update_stats(pf->vsi[v]);
> > +
> > +	/* Update the stats for the active switching components */
> > +	for (v = 0; v < I40E_MAX_VEB; v++)
> > +		if (pf->veb[v])
> > +			i40e_update_veb_stats(pf->veb[v]);
> > +}
> 
> [...]
> 
> > +/**
> > + * i40e_handle_reset_warning - prep for the core to reset
> > + * @pf: board private structure
> > + *
> > + * Close up the VFs and other things in prep for a Core Reset,
> > + * then get ready to rebuild the world.
> > + **/
> > +static void i40e_handle_reset_warning(struct i40e_pf *pf)
> > +{
> 
> [...]
> 
> > +	/* reinit the misc interrupt */
> > +	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
> 
> Did I understand this right, the misc interrupt is now handled by the
> legacy IRQ handler?

If MSIX setup failed, then we'll be using the misc handler for either MSI or Legacy IRQ.  This is not intended to be the normal case.  Usually the misc handler will be dealing with our 0-th MSIX vector.

> 
> [...]
> 
> > +/**
> > + * i40e_service_task - Run the driver's async subtasks
> > + * @work: pointer to work_struct containing our data
> > + **/
> > +static void i40e_service_task(struct work_struct *work)
> > +{
> > +	struct i40e_pf *pf = container_of(work,
> > +					  struct i40e_pf,
> > +					  service_task);
> > +	unsigned long start_time = jiffies;
> > +
> > +	i40e_reset_subtask(pf);
> > +	i40e_handle_mdd_event(pf);
> > +	i40e_vc_process_vflr_event(pf);
> > +	i40e_watchdog_subtask(pf);
> > +	i40e_fdir_reinit_subtask(pf);
> > +	i40e_check_hang_subtask(pf);
> > +	i40e_sync_filters_subtask(pf);
> > +	i40e_clean_adminq_subtask(pf);
> > +
> 
> This blank line could probably removed as well or did you add it for a
> special reason?

It was added to separate the subtask operations from the "I'm done" routine.

> 
> > +	i40e_service_event_complete(pf);
> > +
> > +	/* If the tasks have taken longer than one timer cycle or there
> > +	 * is more work to be done, reschedule the service task now
> > +	 * rather than wait for the timer to tick again.
> > +	 */
> > +	if (time_after(jiffies, (start_time + pf->service_timer_period)) ||
> > +	    test_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state)		 ||
> > +	    test_bit(__I40E_MDD_EVENT_PENDING, &pf->state)		 ||
> > +	    test_bit(__I40E_VFLR_EVENT_PENDING, &pf->state))
> > +		i40e_service_event_schedule(pf);
> > +}
> 
> [...]
> 
> > +	/* prep for VF support */
> > +	if ((pf->flags & I40E_FLAG_SRIOV_ENABLED) &&
> > +	    (pf->flags & I40E_FLAG_MSIX_ENABLED)) {
> > +		u32 val;
> > +
> > +		/* disable link interrupts for VFs */
> > +		val = rd32(hw, I40E_PFGEN_PORTMDIO_NUM);
> > +		val &= ~I40E_PFGEN_PORTMDIO_NUM_VFLINK_STAT_ENA_MASK;
> > +		wr32(hw, I40E_PFGEN_PORTMDIO_NUM, val);
> > +		flush(hw);
> > +
> 
> superfluous blank line.

Thanks.

> 
> > +	}
> 
>   Stefan
