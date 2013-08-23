From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 1/8] i40e: main driver core
Date: Fri, 23 Aug 2013 00:28:05 -0700 (PDT)
Message-ID: <20130823.002805.1975660490102085087.davem@davemloft.net>
References: <1377224142-25160-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1377224142-25160-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, shannon.nelson@intel.com,
	peter.p.waskiewicz.jr@intel.com, e1000-devel@lists.sourceforge.net
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58319 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350Ab3HWH2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 03:28:08 -0400
In-Reply-To: <1377224142-25160-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 22 Aug 2013 19:15:35 -0700

> +enum i40e_status_code i40e_allocate_dma_mem_d(struct i40e_hw *hw,
> +					      struct i40e_dma_mem *mem,
> +					      u64 size, u32 alignment)
> +{
 ...
> +	mem->va = dma_alloc_coherent(&pf->pdev->dev, mem->size,
> +				     &mem->pa, GFP_ATOMIC | __GFP_ZERO);

First, I see no reason to specify GFP_ATOMIC here, code paths that
call this thing even have comments above them like:

--------------------
+ *  Do *NOT* hold the lock when calling this as the memory allocation routines
+ *  called are not going to be atomic context safe
--------------------

Secondly, use dma_zalloc_coherent() if you want __GFP_ZERO.

> +static int i40e_get_lump(struct i40e_lump_tracking *pile, u16 needed, u16 id)
> +{
> +	int i = 0, j = 0;
> +	int ret = I40E_ERR_NO_MEMORY;
> +
> +	if (pile == NULL || needed == 0 || id >= I40E_PILE_VALID_BIT) {
> +		pr_info("%s: param err: pile=%p needed=%d id=0x%04x\n",
> +		       __func__, pile, needed, id);
> +		return I40E_ERR_PARAM;

Since there is absolutely no context passed into these helper routines,
the log messages are less useful than they could be.  If you did this
right you could use netdev_info() or dev_info() here.

> +void i40e_pf_reset_stats(struct i40e_pf *pf)
> +{
> +	memset(&pf->stats, 0, sizeof(struct i40e_hw_port_stats));
> +	memset(&pf->stats_offsets, 0, sizeof(struct i40e_hw_port_stats));
> +	pf->stat_offsets_loaded = false;
> +
> +}

Spurious empty line at end of that function.

> +		flush(hw);

I think this brief and common name is asking for namespace collision
problems.  Maybe name it i40e_flush or i40e_hw_flush or something like
that.

> +{
> +	int i;
> +	struct i40e_pf *pf = vsi->back;

Please order local variable declarations from longest line to shortest.

> +static void i40e_vsi_map_rings_to_vectors(struct i40e_vsi *vsi)
> +{
> +	int q_vectors = vsi->num_q_vectors;
> +	int qp_remaining = vsi->num_queue_pairs, qp_idx = 0;
> +	int v_start = 0;
> +

Likewise.

> +static void i40e_vsi_free_irq(struct i40e_vsi *vsi)
> +{
> +	struct i40e_pf *pf = vsi->back;
> +	struct i40e_hw *hw = &pf->hw;
> +	int base = vsi->base_vector;
> +	int i;
> +	u32 val, qp;

Likewise.

> +static u8 i40e_dcb_get_num_tc(struct i40e_dcbx_config *dcbcfg)
> +{
> +	int num_tc = 0, i;
> +	/* Scan the ETS Config Priority Table to find
> +	 * traffic class enabled for a given priority
> +	 * and use the traffic class index to get the
> +	 * number of traffic classes enabled
> +	 */

Please put an empty line between the local variables and
the rest of the function.

> +static u8 i40e_dcb_get_enabled_tc(struct i40e_dcbx_config *dcbcfg)
> +{
> +	u8 enabled_tc = 1;
> +	u8 i;
> +	u8 num_tc = i40e_dcb_get_num_tc(dcbcfg);

Please order local variables longest to shortest line.

> +static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
> +{
> +	struct i40e_hw *hw = &pf->hw;
> +	struct i40e_dcbx_config *dcbcfg = &hw->local_dcbx_config;
> +	u8 i, enabled_tc;
> +	u8 num_tc = 0;

Likewise.
> +static s32 i40e_vsi_get_bw_info(struct i40e_vsi *vsi)
> +{
> +	int ret = I40E_ERR_NOT_IMPLEMENTED;
> +	struct i40e_pf *pf = vsi->back;
> +	struct i40e_hw *hw = &pf->hw;
> +	struct i40e_aqc_query_vsi_bw_config_resp bw_config = {0};
> +	struct i40e_aqc_query_vsi_ets_sla_config_resp bw_ets_config = {0};
> +	u32 tc_bw_max;
> +	int i;

Likewise.

> +static s32 i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi,
> +				       u8 enabled_tc,
> +				       u8 *bw_share)
> +{
> +	int i, ret = 0;
> +	struct i40e_aqc_configure_vsi_tc_bw_data bw_data;

Likewise.  I'm not going to quote the other ones, there are so many, just
audit the entire code base for this, thanks.

> +static inline int i40e_prev_power_of_2(int n)
> +{
> +	int p = n;
> +	--p;
> +	p |= p >> 1;
> +	p |= p >> 2;
> +	p |= p >> 4;
> +	p |= p >> 8;
> +	p |= p >> 16;
> +	if (p == (n - 1))
> +		return n;  /* it was already a power of 2 */
> +	p >>= 1;
> +	return ++p;
> +}

I think something using rounddown_pow_of_two() would accomplish this.

Perhaps:

	if (!is_power_of_2(x))
		x = rounddown_pow_of_two(x);
