From: Joe Perches <joe@perches.com>
Subject: Re: [net v7 1/8] i40e: main driver core
Date: Wed, 11 Sep 2013 05:16:38 -0700
Message-ID: <1378901798.606.39.camel@joe-AO722>
References: <1378893056-4821-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378893056-4821-2-git-send-email-jeffrey.t.kirsher@intel.com>
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
Received: from smtprelay0092.hostedemail.com ([216.40.44.92]:38020 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751630Ab3IKMQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 08:16:41 -0400
In-Reply-To: <1378893056-4821-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-11 at 02:50 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> This is the driver for the Intel(R) Ethernet Controller XL710 Family.

trivial:

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
[]
> +int i40e_allocate_dma_mem_d(struct i40e_hw *hw, struct i40e_dma_mem *mem,
> +			    u64 size, u32 alignment)
> +{
> +	struct i40e_pf *pf = (struct i40e_pf *)hw->back;
> +
> +	mem->size = ALIGN(size, alignment);
> +	mem->va = dma_zalloc_coherent(&pf->pdev->dev, mem->size,
> +				      &mem->pa, GFP_KERNEL);
> +	if (mem->va)
> +		return 0;
> +
> +	return -ENOMEM;
> +}

It's much more common to use

	foo = alloc(...)
	if (!foo)
		return -ENOMEM;

	...

	return 0;

[]

> +int i40e_allocate_virt_mem_d(struct i40e_hw *hw, struct i40e_virt_mem *mem,
> +			     u32 size)
> +{
> +	mem->size = size;
> +	mem->va = kzalloc(size, GFP_KERNEL);
> +
> +	if (mem->va)
> +		return 0;
> +
> +	return -ENOMEM;
> +}

here too.

> +static int i40e_get_lump(struct i40e_pf *pf, struct i40e_lump_tracking *pile,
> +			 u16 needed, u16 id)
> +{
> +	int ret = -ENOMEM;
> +	int i = 0;
> +	int j = 0;
> +
> +	if (!pile || needed == 0 || id >= I40E_PILE_VALID_BIT) {
> +		dev_info(&pf->pdev->dev,
> +			 "param err: pile=%p needed=%d id=0x%04x\n",
> +			 pile, needed, id);
> +		return -EINVAL;
> +	}
> +
> +	/* start the linear search with an imperfect hint */
> +	i = pile->search_hint;
> +	while (i < pile->num_entries && ret < 0) {
> +		/* skip already allocated entries */
> +		if (pile->list[i] & I40E_PILE_VALID_BIT) {
> +			i++;
> +			continue;
> +		}
> +
> +		/* do we have enough in this lump? */
> +		for (j = 0; (j < needed) && ((i+j) < pile->num_entries); j++) {
> +			if (pile->list[i+j] & I40E_PILE_VALID_BIT)
> +				break;
> +		}
> +
> +		if (j == needed) {
> +			/* there was enough, so assign it to the requestor */
> +			for (j = 0; j < needed; j++)
> +				pile->list[i+j] = id | I40E_PILE_VALID_BIT;
> +			ret = i;
> +			pile->search_hint = i + j;

I think it'd read better with a break;
removing the ret < 0 test from the while loop above

> +		} else {
> +			/* not enough, so skip over it and continue looking */
> +			i += j;
> +		}
> +	}
> +
> +	return ret;
> +}
> +

[]

> +int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
> +{

[]

> +	while (test_and_set_bit(__I40E_CONFIG_BUSY, &vsi->state))
> +		usleep_range(1000, 2000);

Possible hardware fault sleeps forever?

[]

> +/**
> + * i40e_find_filter - Search VSI filter list for specific mac/vlan filter
> + * @vsi: the VSI to be searched
> + * @macaddr: the MAC address
> + * @vlan: the vlan
> + * @is_vf: make sure its a vf filter, else doesn't matter
> + * @is_netdev: make sure its a netdev filter, else doesn't matter
> + *
> + * Returns ptr to the filter object or NULL

kernel-doc uses a "* Return: " style keyword.
(there are lots of these)

from Documentation/kernel-doc-nano-HOWTO.ext

Example kernel-doc function comment:

/**
 * foobar() - short function description of foobar
 * @arg1:	Describe the first argument to foobar.
 * @arg2:	Describe the second argument to foobar.
 *		One can provide multiple line descriptions
 *		for arguments.
 *
 * A longer description, with more discussion of the function foobar()
 * that might be useful to those using or modifying it.  Begins with
 * empty comment line, and may include additional embedded empty
 * comment lines.
 *
 * The longer description can have multiple paragraphs.
 *
 * Return: Describe the return value of foobar.
 */

[]

> +/**
> + * i40e_vsi_kill_vlan - Remove vsi membership for given vlan
> + * @vsi: the vsi being configured
> + * @vid: vlan id to be removed (0 = untagged only , -1 = any)

* Return: 0 on success or negative error code otherwise

[]

> +/**
> + * i40e_vlan_rx_add_vid - Add a vlan id filter to HW offload
> + * @netdev: network interface to be adjusted
> + * @vid: vlan id to be added
> + **/
> +static int i40e_vlan_rx_add_vid(struct net_device *netdev,
> +				__always_unused __be16 proto, u16 vid)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_vsi *vsi = np->vsi;
> +	int ret;
> +
> +	if (vid > 4095)
> +		return 0;

return -err or...

> +
> +	netdev_info(vsi->netdev, "adding %pM vid=%d\n",
> +		    netdev->dev_addr, vid);
> +	/* If the network stack called us with vid = 0, we should
> +	 * indicate to i40e_vsi_add_vlan() that we want to receive
> +	 * any traffic (i.e. with any vlan tag, or untagged)
> +	 */
> +	ret = i40e_vsi_add_vlan(vsi, vid ? vid : I40E_VLAN_ANY);
> +
> +	if (!ret) {
> +		if (vid < VLAN_N_VID)
> +			set_bit(vid, vsi->active_vlans);
> +	}
> +
> +	return 0;

make it a void return instead?

> +}
> +
> +/**
> + * i40e_vlan_rx_kill_vid - Remove a vlan id filter from HW offload
> + * @netdev: network interface to be adjusted
> + * @vid: vlan id to be removed
> + **/
> +static int i40e_vlan_rx_kill_vid(struct net_device *netdev,
> +				 __always_unused __be16 proto, u16 vid)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_vsi *vsi = np->vsi;
> +
> +	netdev_info(vsi->netdev, "removing %pM vid=%d\n",
> +		    netdev->dev_addr, vid);
> +	/* return code is ignored as there is nothing a user
> +	 * can do about failure to remove and a log message was
> +	 * already printed from another function
> +	 */
> +	i40e_vsi_kill_vlan(vsi, vid);
> +
> +	clear_bit(vid, vsi->active_vlans);
> +	return 0;

here too?  There are others below.
Maybe change all the functions that have
a fixed return 0 to void?

> +/**
> + * i40e_dcb_get_num_tc -  Get the number of TCs from DCBx config
> + * @dcbcfg: the corresponding DCBx configuration structure
> + *
> + * Return the number of TCs from given DCBx configuration
> + **/
> +static u8 i40e_dcb_get_num_tc(struct i40e_dcbx_config *dcbcfg)
> +{
> +	int num_tc = 0, i;
> +
> +	/* Scan the ETS Config Priority Table to find
> +	 * traffic class enabled for a given priority
> +	 * and use the traffic class index to get the
> +	 * number of traffic classes enabled
> +	 */
> +	for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
> +		if (dcbcfg->etscfg.prioritytable[i] > num_tc)
> +			num_tc = dcbcfg->etscfg.prioritytable[i];
> +	}
> +
> +	/* Traffic class index starts from zero so
> +	 * increment to return the actual count
> +	 */
> +	num_tc++;
> +
> +	return num_tc;

There's a possible loss of precision here.
why isn't num_tc u8 like the function below?

> +}
> +
> +/**
> + * i40e_dcb_get_enabled_tc - Get enabled traffic classes
> + * @dcbcfg: the corresponding DCBx configuration structure
> + *
> + * Query the current DCB configuration and return the number of
> + * traffic classes enabled from the given DCBX config
> + **/
> +static u8 i40e_dcb_get_enabled_tc(struct i40e_dcbx_config *dcbcfg)
> +{
> +	u8 num_tc = i40e_dcb_get_num_tc(dcbcfg);
> +	u8 enabled_tc = 1;
> +	u8 i;
> +
> +	for (i = 0; i < num_tc; i++)
> +		enabled_tc |= 1 << i;
> +
> +	return enabled_tc;
> +}
