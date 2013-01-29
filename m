From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] [PATCH v2] vmxnet3: set carrier state properly on probe
Date: Tue, 29 Jan 2013 11:54:43 -0800
Message-ID: <1725516.hP8rSAnB3a@dtor-d630.eng.vmware.com>
References: <1359147253-7204-1-git-send-email-nhorman@tuxdriver.com> <1359484611-23860-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: pv-drivers@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:35512 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753197Ab3A2Tyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 14:54:43 -0500
In-Reply-To: <1359484611-23860-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, January 29, 2013 01:36:51 PM Neil Horman wrote:
> vmxnet3 fails to set netif_carrier_off on probe, meaning that when an
> interface is opened the __LINK_STATE_NOCARRIER bit is already cleared, and
> so /sys/class/net/<ifname>/operstate remains in the unknown state.  Correct
> this by setting netif_carrier_off on probe, like other drivers do.
> 
> Also, while we're at it, lets remove the netif_carrier_ok checks from the
> link_state_update function, as that check is atomically contained within the
> netif_carrier_[on|off] functions anyway
> 
> Tested successfully by myself
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: "VMware, Inc." <pv-drivers@vmware.com>

Acked-by: Dmitry Torokhov <dtor@vmware.com>

> CC: Ben Hutchings <bhutchings@solarflare.com>
> 
> ---
> Change notes:
> 
> v2) Moved netif_carrier_off above register_netdev to prevent race with
> dev_open as per Ben H.
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> b/drivers/net/vmxnet3/vmxnet3_drv.c index b1c90f8..ffb97b2 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -150,8 +150,7 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool
> affectTxQueue) if (ret & 1) { /* Link is up. */
>  		netdev_info(adapter->netdev, "NIC Link is Up %d Mbps\n",
>  			    adapter->link_speed);
> -		if (!netif_carrier_ok(adapter->netdev))
> -			netif_carrier_on(adapter->netdev);
> +		netif_carrier_on(adapter->netdev);
> 
>  		if (affectTxQueue) {
>  			for (i = 0; i < adapter->num_tx_queues; i++)
> @@ -160,8 +159,7 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool
> affectTxQueue) }
>  	} else {
>  		netdev_info(adapter->netdev, "NIC Link is Down\n");
> -		if (netif_carrier_ok(adapter->netdev))
> -			netif_carrier_off(adapter->netdev);
> +		netif_carrier_off(adapter->netdev);
> 
>  		if (affectTxQueue) {
>  			for (i = 0; i < adapter->num_tx_queues; i++)
> @@ -3060,6 +3058,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
>  	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
>  	netif_set_real_num_rx_queues(adapter->netdev, adapter->num_rx_queues);
> 
> +	netif_carrier_off(netdev);
>  	err = register_netdev(netdev);
> 
>  	if (err) {
