From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Patch 13/16 2.5] ixgb: ethtool_ops support
Date: Fri, 15 Oct 2004 19:54:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015175426.GA2878@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.44.0410150639340.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0410150639340.31227-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ganesh Venkatesan <ganesh.venkatesan@intel.com> :
[...]
> @@ -94,9 +55,11 @@ struct ixgb_stats {
>  #define IXGB_STATS_LEN	\
>  	sizeof(ixgb_gstrings_stats) / sizeof(struct ixgb_stats)
>  
> -static void
> -ixgb_ethtool_gset(struct ixgb_adapter *adapter, struct ethtool_cmd *ecmd)
> +static int
> +ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
>  {
> +	struct ixgb_adapter *adapter = netdev->priv;
> +
>  	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
>  	ecmd->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
>  	ecmd->port = PORT_FIBRE;

What about simply naming the net_device 'dev' and make use of netdev_priv()
in this patch ?

It is not a big issue but your editor shows a trend to eat lines after the
declaration of variables and to crunch spaces after 'if' and 'for'.

[...]
> +static int 
> +ixgb_set_ringparam(struct net_device *netdev,
> +		   struct ethtool_ringparam *ring)
> +{
> +	struct ixgb_adapter *adapter = netdev->priv;
> +	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
> +	struct ixgb_desc_ring *rxdr = &adapter->rx_ring;
> +	struct ixgb_desc_ring tx_old, tx_new, rx_old, rx_new;
> +	int err;
> +
> +	tx_old = adapter->tx_ring;
> +	rx_old = adapter->rx_ring;
> +
> +	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending)) 
> +		return -EINVAL;
> +
> +	if(netif_running(adapter->netdev))
> +		ixgb_down(adapter,TRUE);
> +
[...]
> +	if(netif_running(adapter->netdev)) {
> +		/* Try to get new resources before deleting old */
> +		if((err = ixgb_setup_rx_resources(adapter)))
> +			goto err_setup_rx;
> +		if((err = ixgb_setup_tx_resources(adapter)))
> +			goto err_setup_tx;
> +
> +		/* save the new, restore the old in order to free it,
> +		 * then restore the new back again */
> +
> +		rx_new = adapter->rx_ring;
> +		tx_new = adapter->tx_ring;
> +		adapter->rx_ring = rx_old;
> +		adapter->tx_ring = tx_old;
> +		ixgb_free_rx_resources(adapter);
> +		ixgb_free_tx_resources(adapter);
> +		adapter->rx_ring = rx_new;
> +		adapter->tx_ring = tx_new;
> +		if((err = ixgb_up(adapter)))
> +			return err;

-> ixgb_up() failed and netif_running() is true.

   If dev_close() (or a call to set_ringparam()) is issued by the user
   once rtnl_lock() is released, it will trigger a second call to
   ixgb_down().

--
Ueimor
