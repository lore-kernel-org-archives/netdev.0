From: Pavel Fedin <p.fedin@samsung.com>
Subject: RE: [PATCH 5/6] net: thunderx: Switchon carrier only upon interface
 link up
Date: Tue, 01 Dec 2015 18:32:36 +0300
Message-ID: <01d701d12c4d$81f58430$85e08c90$@samsung.com>
References: <y@samsung.com>
 <1448961223-41888-6-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	'Sunil Goutham' <sgoutham@cavium.com>
To: 'Sunil Goutham' <sunil.kovvuri@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1448961223-41888-6-git-send-email-sunil.kovvuri@gmail.com>
Content-language: ru
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello!

 This one causes the network to stop working on Fedora 21. Probably has to do with NetworkManager, which sees something unexpected.
IP address is never set up and connection is never activated, despite it has UP flag.

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Sunil
> Goutham
> Sent: Tuesday, December 01, 2015 12:14 PM
> To: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
> Sunil.Goutham@caviumnetworks.com; Sunil Goutham
> Subject: [PATCH 5/6] net: thunderx: Switchon carrier only upon interface link up
> 
> From: Sunil Goutham <sgoutham@cavium.com>
> 
> Call netif_carrier_on() only if interface's link is up. Switching this on
> upon IFF_UP by default, is causing issues with ethernet channel bonding
> in LACP mode. Initial NETDEV_CHANGE notification was being skipped.
> 
> Also fixed some issues with link/speed/duplex reporting via ethtool.
> 
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
> ---
>  .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |   16 +++++++++++++++-
>  drivers/net/ethernet/cavium/thunder/nicvf_main.c   |    4 +---
>  drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |    2 ++
>  3 files changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
> b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
> index af54c10..a12b2e3 100644
> --- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
> +++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
> @@ -112,6 +112,13 @@ static int nicvf_get_settings(struct net_device *netdev,
> 
>  	cmd->supported = 0;
>  	cmd->transceiver = XCVR_EXTERNAL;
> +
> +	if (!nic->link_up) {
> +		cmd->duplex = DUPLEX_UNKNOWN;
> +		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
> +		return 0;
> +	}
> +
>  	if (nic->speed <= 1000) {
>  		cmd->port = PORT_MII;
>  		cmd->autoneg = AUTONEG_ENABLE;
> @@ -125,6 +132,13 @@ static int nicvf_get_settings(struct net_device *netdev,
>  	return 0;
>  }
> 
> +static u32 nicvf_get_link(struct net_device *netdev)
> +{
> +	struct nicvf *nic = netdev_priv(netdev);
> +
> +	return nic->link_up;
> +}
> +
>  static void nicvf_get_drvinfo(struct net_device *netdev,
>  			      struct ethtool_drvinfo *info)
>  {
> @@ -660,7 +674,7 @@ static int nicvf_set_channels(struct net_device *dev,
> 
>  static const struct ethtool_ops nicvf_ethtool_ops = {
>  	.get_settings		= nicvf_get_settings,
> -	.get_link		= ethtool_op_get_link,
> +	.get_link		= nicvf_get_link,
>  	.get_drvinfo		= nicvf_get_drvinfo,
>  	.get_msglevel		= nicvf_get_msglevel,
>  	.set_msglevel		= nicvf_set_msglevel,
> diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
> b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
> index 7f709cb..dde8dc7 100644
> --- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
> +++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
> @@ -1057,6 +1057,7 @@ int nicvf_stop(struct net_device *netdev)
> 
>  	netif_carrier_off(netdev);
>  	netif_tx_stop_all_queues(nic->netdev);
> +	nic->link_up = false;
> 
>  	/* Teardown secondary qsets first */
>  	if (!nic->sqs_mode) {
> @@ -1211,9 +1212,6 @@ int nicvf_open(struct net_device *netdev)
>  	nic->drv_stats.txq_stop = 0;
>  	nic->drv_stats.txq_wake = 0;
> 
> -	netif_carrier_on(netdev);
> -	netif_tx_start_all_queues(netdev);
> -
>  	return 0;
>  cleanup:
>  	nicvf_disable_intr(nic, NICVF_INTR_MBOX, 0);
> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> index 2076ac3..d9f27ad 100644
> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> @@ -612,6 +612,8 @@ static void bgx_poll_for_link(struct work_struct *work)
>  		lmac->last_duplex = 1;
>  	} else {
>  		lmac->link_up = 0;
> +		lmac->last_speed = SPEED_UNKNOWN;
> +		lmac->last_duplex = DUPLEX_UNKNOWN;
>  	}
> 
>  	if (lmac->last_link != lmac->link_up) {
> --
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
