From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [RFC 5/5] i40e/ethtool: support coalesce setting by queue
Date: Thu, 17 Dec 2015 22:47:17 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFD1CAC@fmsmsx115.amr.corp.intel.com>
References: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
 <1450335081-3012-5-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"cascardo@redhat.com" <cascardo@redhat.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"ben@decadent.org.uk" <ben@decadent.org
To: "Liang, Kan" <kan.liang@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28972 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965128AbbLQWrT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 17:47:19 -0500
In-Reply-To: <1450335081-3012-5-git-send-email-kan.liang@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Kan Liang <kan.liang@intel.com>
> 
> This patch implements set_per_queue_coalesce for i40e driver.
> For i40e driver, only rx and tx usecs has per queue value. Changing
> these two parameters only impact the specific queue. For other interrupt
> coalescing parameters, they are shared among queues. The change to one
> queue will impact all queues.
> 
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 55 +++++++++++++++++++--
> -----
>  1 file changed, 41 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> index b41f0be..5a35fdb 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -1901,14 +1901,29 @@ static int i40e_get_per_queue_coalesce(struct
> net_device *netdev, int queue,
>  	return __i40e_get_coalesce(netdev, ec, queue);
>  }
> 
> -static int i40e_set_coalesce(struct net_device *netdev,
> -			     struct ethtool_coalesce *ec)
> +static void i40e_set_itr_for_queue(struct i40e_vsi *vsi, int queue, u16
> vector)
>  {
> -	struct i40e_netdev_priv *np = netdev_priv(netdev);
>  	struct i40e_q_vector *q_vector;
> -	struct i40e_vsi *vsi = np->vsi;
>  	struct i40e_pf *pf = vsi->back;
>  	struct i40e_hw *hw = &pf->hw;
> +	u16 intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
> +
> +	q_vector = vsi->q_vectors[queue];

Again, the problem here is that there can be more queues than vectors, so you'll need to check the requested queue number against vsi->num_queue_pairs for the max queue check, then look at vsi->tx_rings[queue].q_vector and/or vsi->rx_rings[queue].q_vector to find the actual q_vector for the requested queue.

Also, this means that it would be possible for the user to try to assign different values to queues on the same vector.  How do you want to handle that?  My first inclination is to not do anything and just let the last value assigned win.

sln

> +	q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
> +	wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector->rx.itr);
> +	q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
> +	wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector->tx.itr);
> +	wr32(hw, I40E_PFINT_RATEN(vector - 1), intrl);
> +	i40e_flush(hw);
> +}
> +
> +static int __i40e_set_coalesce(struct net_device *netdev,
> +			       struct ethtool_coalesce *ec,
> +			       int queue)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_vsi *vsi = np->vsi;
> +	struct i40e_pf *pf = vsi->back;
>  	u16 vector;
>  	int i;
> 
> @@ -1964,21 +1979,32 @@ static int i40e_set_coalesce(struct net_device
> *netdev,
>  	else
>  		vsi->tx_itr_setting &= ~I40E_ITR_DYNAMIC;
> 
> -	for (i = 0; i < vsi->num_q_vectors; i++, vector++) {
> -		u16 intrl = INTRL_USEC_TO_REG(vsi->int_rate_limit);
> -
> -		q_vector = vsi->q_vectors[i];
> -		q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
> -		wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector->rx.itr);
> -		q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
> -		wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector->tx.itr);
> -		wr32(hw, I40E_PFINT_RATEN(vector - 1), intrl);
> -		i40e_flush(hw);
> +	if (queue < 0) {
> +		for (i = 0; i < vsi->num_q_vectors; i++, vector++)
> +			i40e_set_itr_for_queue(vsi, i, vector);
> +	} else {
> +		if (queue >= vsi->num_q_vectors) {
> +			netif_info(pf, drv, netdev, "Invalid queue value, queue
> range is 0 - %d\n", vsi->num_q_vectors - 1);
> +			return -EINVAL;
> +		}
> +		i40e_set_itr_for_queue(vsi, queue, vector + queue);
>  	}
> 
>  	return 0;
>  }
> 
> +static int i40e_set_coalesce(struct net_device *netdev,
> +			     struct ethtool_coalesce *ec)
> +{
> +	return __i40e_set_coalesce(netdev, ec, -1);
> +}
> +
> +static int i40e_set_per_queue_coalesce(struct net_device *netdev, int
> queue,
> +				       struct ethtool_coalesce *ec)
> +{
> +	return __i40e_set_coalesce(netdev, ec, queue);
> +}
> +
>  /**
>   * i40e_get_rss_hash_opts - Get RSS hash Input Set for each flow type
>   * @pf: pointer to the physical function struct
> @@ -2818,6 +2844,7 @@ static const struct ethtool_ops i40e_ethtool_ops = {
>  	.get_priv_flags		= i40e_get_priv_flags,
>  	.set_priv_flags		= i40e_set_priv_flags,
>  	.get_per_queue_coalesce	= i40e_get_per_queue_coalesce,
> +	.set_per_queue_coalesce	= i40e_set_per_queue_coalesce,
>  };
> 
>  void i40e_set_ethtool_ops(struct net_device *netdev)
> --
> 1.7.11.7
