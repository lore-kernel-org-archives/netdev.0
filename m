From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 3/8] i40evf: core ethtool functionality
Date: Wed, 8 Jan 2014 14:14:14 +0000
Message-ID: <1389190454.2728.56.camel@deadeye.wl.decadent.org.uk>
References: <1388537594-24601-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1388537594-24601-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Greg Rose <gregory.v.rose@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>,
	"Mitch Williams" <mitch.a.williams@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29423 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756593AbaAHOOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 09:14:19 -0500
In-Reply-To: <1388537594-24601-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-31 at 16:53 -0800, Jeff Kirsher wrote:
[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
[...]
> +#define I40EVF_QUEUE_STATS_LEN \
> +	(((struct i40evf_adapter *) \
> +		netdev_priv(netdev))->vsi_res->num_queue_pairs * 4)

netdev should be a macro parameter, not just assumed as a local
variable.

[...]
> +static int i40evf_get_settings(struct net_device *netdev,
> +			       struct ethtool_cmd *ecmd)
> +{
> +	/* In the future the VF will be able to query the PF for
> +	 * some information - for now use a dummy value
> +	 */
> +	ecmd->supported = SUPPORTED_10000baseT_Full;
> +	ecmd->autoneg = AUTONEG_DISABLE;
> +	ecmd->transceiver = XCVR_DUMMY1;
> +	ecmd->port = PORT_NONE;

This is not even consistent, as its claims that 1000BASE-T is supported
but speed/duplex are always set to 0.  Why not set supported = 0?

> +	return 0;
> +}
[...]
> +static int i40evf_get_sset_count(struct net_device *netdev, int sset)
> +{
> +	if (sset == ETH_SS_STATS)
> +		return I40EVF_STATS_LEN;
> +	else
> +		return -ENOTSUPP;

-EINVAL

> +}
[...]
> +static int i40evf_set_coalesce(struct net_device *netdev,
> +			     struct ethtool_coalesce *ec)
> +{
> +	struct i40evf_adapter *adapter = netdev_priv(netdev);
> +	struct i40e_hw *hw = &adapter->hw;
> +	struct i40e_vsi *vsi = &adapter->vsi;
> +	struct i40e_q_vector *q_vector;
> +	int i;
> +
> +	if (ec->tx_max_coalesced_frames || ec->rx_max_coalesced_frames)
> +		vsi->work_limit = ec->tx_max_coalesced_frames;

Why is the actual value of ec->rx_max_coalesced_frames ignored here?
Should this be min() or max() of the two fields?

> +	switch (ec->rx_coalesce_usecs) {
> +	case 0:
> +		vsi->rx_itr_setting = 0;
> +		break;
> +	case 1:
> +		vsi->rx_itr_setting = (I40E_ITR_DYNAMIC
> +				       | ITR_REG_TO_USEC(I40E_ITR_RX_DEF));
> +		break;

This looks a bit magic; why is 1 us interpreted as 'dynamic' (adaptive?)
when there is a separate flag for enabling adaptive moderation?

[...]
> +static struct ethtool_ops i40evf_ethtool_ops = {
[...]

Should be const.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
