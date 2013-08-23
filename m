From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next v2 3/8] i40e: driver ethtool core
Date: Fri, 23 Aug 2013 18:40:43 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416C615D2E@FMSMSX102.amr.corp.intel.com>
References: <1377224142-25160-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1377224142-25160-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <52179717.20301@kpanic.de>
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
Received: from mga09.intel.com ([134.134.136.24]:60325 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754659Ab3HWSkp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 14:40:45 -0400
In-Reply-To: <52179717.20301@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stefan Assmann [mailto:sassmann@kpanic.de]
> Sent: Friday, August 23, 2013 10:09 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Brandeburg, Jesse; netdev@vger.kernel.org;
> gospo@redhat.com; Nelson, Shannon; Waskiewicz Jr, Peter P; e1000-
> devel@lists.sourceforge.net
> Subject: Re: [net-next v2 3/8] i40e: driver ethtool core
> 
> On 23.08.2013 04:15, Jeff Kirsher wrote:
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >
> > This patch contains the ethtool interface and implementation.
> >
> > The goal in this patch series is minimal functionality while not
> > including much in the way of "set support."
> 
> [...]
> 
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> 
> [...]
> 
> > +#define I40E_QUEUE_STATS_LEN(n) \
> > +  ((((struct i40e_netdev_priv *)netdev_priv((n)))->vsi-
> >num_queue_pairs + \
> > +    ((struct i40e_netdev_priv *)netdev_priv((n)))->vsi-
> >num_queue_pairs) * 2)
> > +#define I40E_GLOBAL_STATS_LEN	ARRAY_SIZE(i40e_gstrings_stats)
> > +#define I40E_NETDEV_STATS_LEN   ARRAY_SIZE(i40e_gstrings_net_stats)
> > +#define I40E_VSI_STATS_LEN(n)   (I40E_NETDEV_STATS_LEN + \
> 
> Please use tabs for spacing here.

Yep.

> 
> > +				 I40E_QUEUE_STATS_LEN((n)))
> > +#define I40E_PFC_STATS_LEN ( \
> > +		(FIELD_SIZEOF(struct i40e_pf, stats.priority_xoff_rx) + \
> > +		 FIELD_SIZEOF(struct i40e_pf, stats.priority_xon_rx) + \
> > +		 FIELD_SIZEOF(struct i40e_pf, stats.priority_xoff_tx) + \
> > +		 FIELD_SIZEOF(struct i40e_pf, stats.priority_xon_tx) + \
> > +		 FIELD_SIZEOF(struct i40e_pf, stats.priority_xon_2_xoff)) \
> > +		 / sizeof(u64))
> > +#define I40E_PF_STATS_LEN(n)    (I40E_GLOBAL_STATS_LEN + \
> 
> Here as well.

Yep.

> 
> [...]
> 
> > +static void i40e_get_regs(struct net_device *netdev, struct
> ethtool_regs *regs,
> > +			  void *p)
> > +{
> > +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> > +	struct i40e_pf *pf = np->vsi->back;
> > +	struct i40e_hw *hw = &pf->hw;
> > +	u32 *reg_buf = p;
> > +	int i, j, ri;
> > +	u32 reg;
> > +
> > +	/* Tell ethtool which driver-version-specific regs output we have.
> > +	 *
> > +	 * At some point, if we have ethtool doing special formatting of
> > +	 * this data, it will rely on this version number to know how to
> > +	 * interpret things.  Hence, this needs to be updated if/when the
> > +	 * diags register table is changed.
> > +	 */
> > +	regs->version = 1;
> > +
> > +	/* loop through the diags reg table for what to print */
> > +	ri = 0;
> > +	for (i = 0; i40e_reg_list[i].offset != 0; i++) {
> > +		for (j = 0; j < i40e_reg_list[i].elements; j++) {
> > +			reg = i40e_reg_list[i].offset
> > +				+ (j * i40e_reg_list[i].stride);
> > +			reg_buf[ri++] = rd32(hw, reg);
> > +		}
> > +	}
> > +
> > +	return;
> 
> void function, no return necessary.

Thanks

> 
> > +}
> 
> [...]
> 
> > +static void i40e_get_ethtool_stats(struct net_device *netdev,
> > +				   struct ethtool_stats *stats, u64 *data)
> > +{
> > +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> > +	struct i40e_vsi *vsi = np->vsi;
> > +	struct i40e_pf *pf = vsi->back;
> > +	struct rtnl_link_stats64 *net_stats =
> i40e_get_vsi_stats_struct(vsi);
> > +	char *p;
> > +	int i, j;
> > +
> > +	i40e_update_stats(vsi);
> > +
> > +	i = 0;
> 
> This could be avoided by int i = 0 few lines above.

Sure.

> 
> > +	for (j = 0; j < I40E_NETDEV_STATS_LEN; j++) {
> > +		p = (char *)net_stats +
> i40e_gstrings_net_stats[j].stat_offset;
> > +		data[i++] = (i40e_gstrings_net_stats[j].sizeof_stat ==
> > +			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
> > +	}
> > +	for (j = 0; j < vsi->num_queue_pairs; j++) {
> > +		data[i++] = vsi->tx_rings[j].tx_stats.packets;
> > +		data[i++] = vsi->tx_rings[j].tx_stats.bytes;
> > +	}
> > +	for (j = 0; j < vsi->num_queue_pairs; j++) {
> > +		data[i++] = vsi->rx_rings[j].rx_stats.packets;
> > +		data[i++] = vsi->rx_rings[j].rx_stats.bytes;
> > +	}
> > +	if (vsi == pf->vsi[pf->lan_vsi]) {
> > +		for (j = 0; j < I40E_GLOBAL_STATS_LEN; j++) {
> > +			p = (char *)pf + i40e_gstrings_stats[j].stat_offset;
> > +			data[i++] = (i40e_gstrings_stats[j].sizeof_stat ==
> > +				   sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
> > +		}
> > +		for (j = 0; j < I40E_MAX_USER_PRIORITY; j++) {
> > +			data[i++] = pf->stats.priority_xon_tx[j];
> > +			data[i++] = pf->stats.priority_xoff_tx[j];
> > +		}
> > +		for (j = 0; j < I40E_MAX_USER_PRIORITY; j++) {
> > +			data[i++] = pf->stats.priority_xon_rx[j];
> > +			data[i++] = pf->stats.priority_xoff_rx[j];
> > +		}
> > +		for (j = 0; j < I40E_MAX_USER_PRIORITY; j++)
> > +			data[i++] = pf->stats.priority_xon_2_xoff[j];
> > +	}
> > +
> > +	return;
> 
> Another void function.

Yep.

> 
> [...]
> 
> > +static struct ethtool_ops i40e_ethtool_ops = {
> > +	.get_settings           = i40e_get_settings,
> > +	.get_drvinfo            = i40e_get_drvinfo,
> > +	.get_regs_len           = i40e_get_regs_len,
> > +	.get_regs               = i40e_get_regs,
> > +	.nway_reset             = i40e_nway_reset,
> > +	.get_link               = ethtool_op_get_link,
> > +	.get_wol                = i40e_get_wol,
> > +	.get_ringparam          = i40e_get_ringparam,
> > +	.set_ringparam          = i40e_set_ringparam,
> > +	.get_pauseparam         = i40e_get_pauseparam,
> > +	.get_msglevel           = i40e_get_msglevel,
> > +	.set_msglevel           = i40e_set_msglevel,
> > +	.get_rxnfc              = i40e_get_rxnfc,
> > +	.set_rxnfc              = i40e_set_rxnfc,
> > +	.self_test              = i40e_diag_test,
> > +	.get_strings            = i40e_get_strings,
> > +	.set_phys_id            = i40e_set_phys_id,
> > +	.get_sset_count         = i40e_get_sset_count,
> > +	.get_ethtool_stats      = i40e_get_ethtool_stats,
> > +	.get_coalesce           = i40e_get_coalesce,
> > +	.set_coalesce           = i40e_set_coalesce,
> > +	.get_ts_info            = i40e_get_ts_info,
> > +};
> 
> It would be nice if you could use tabs for spacing here.

Sure.

> 
>   Stefan
