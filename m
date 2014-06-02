From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [net-next PATCH 2/2] enic: Update driver to use __dev_uc/mc_sync/unsync
 calls
Date: Mon, 2 Jun 2014 16:25:24 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1406021610240.6244@ws.cisco>
References: <20140529013440.21464.2499.stgit@ahduyck-cp2.jf.intel.com> <20140529014452.21464.21673.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: ssujith@cisco.com, neepatel@cisco.com, davem@davemloft.net,
	_govind@gmx.com, benve@cisco.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:51065 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752258AbaFBK4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2014 06:56:12 -0400
In-Reply-To: <20140529014452.21464.21673.stgit@ahduyck-cp2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 28 May 2014, Alexander Duyck wrote:

> This change updates the enic driver to make use of __dev_uc_sync and
> __dev_mc_sync calls.  Previously the driver was doing its own list
> management by storing the mc_addr and uc_addr list in a 32 address array.
> With this change the sync data is stored in the netdev_addr_list structures
> and instead we just track how many addresses we have written to the device.
> When we encounter 32 we stop and print a message as occurred previously with
> the old approach.
>
> Other than the core change the only other bit needed was to propagate the
> constant attribute with the MAC address as there were several spots where
> is twas only passed as a u8 * instead of a const u8 *.
>
> This patch is meant to maintain the original functionality without the use
> of the mc_addr and uc_addr arrays.
>

Tested on enic hw. No problem seen. Thanks.

Acked-by: Govindarajulu Varadarajan <_govind@gmx.com>

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> drivers/net/ethernet/cisco/enic/enic.h      |    2
> drivers/net/ethernet/cisco/enic/enic_dev.c  |    4 -
> drivers/net/ethernet/cisco/enic/enic_dev.h  |    4 -
> drivers/net/ethernet/cisco/enic/enic_main.c |  173 ++++++++++-----------------
> drivers/net/ethernet/cisco/enic/vnic_dev.c  |    4 -
> drivers/net/ethernet/cisco/enic/vnic_dev.h  |    4 -
> 6 files changed, 73 insertions(+), 118 deletions(-)
>
> diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
> index f23ef32..14f465f 100644
> --- a/drivers/net/ethernet/cisco/enic/enic.h
> +++ b/drivers/net/ethernet/cisco/enic/enic.h
> @@ -114,8 +114,6 @@ struct enic {
> 	u32 msg_enable;
> 	spinlock_t devcmd_lock;
> 	u8 mac_addr[ETH_ALEN];
> -	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
> -	u8 uc_addr[ENIC_UNICAST_PERFECT_FILTERS][ETH_ALEN];
> 	unsigned int flags;
> 	unsigned int priv_flags;
> 	unsigned int mc_count;
> diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.c b/drivers/net/ethernet/cisco/enic/enic_dev.c
> index 4b6e569..3e27df5 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_dev.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_dev.c
> @@ -88,7 +88,7 @@ int enic_dev_packet_filter(struct enic *enic, int directed, int multicast,
> 	return err;
> }
>
> -int enic_dev_add_addr(struct enic *enic, u8 *addr)
> +int enic_dev_add_addr(struct enic *enic, const u8 *addr)
> {
> 	int err;
>
> @@ -99,7 +99,7 @@ int enic_dev_add_addr(struct enic *enic, u8 *addr)
> 	return err;
> }
>
> -int enic_dev_del_addr(struct enic *enic, u8 *addr)
> +int enic_dev_del_addr(struct enic *enic, const u8 *addr)
> {
> 	int err;
>
> diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.h b/drivers/net/ethernet/cisco/enic/enic_dev.h
> index 129b14a..36ea1ab 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_dev.h
> +++ b/drivers/net/ethernet/cisco/enic/enic_dev.h
> @@ -45,8 +45,8 @@ int enic_dev_add_station_addr(struct enic *enic);
> int enic_dev_del_station_addr(struct enic *enic);
> int enic_dev_packet_filter(struct enic *enic, int directed, int multicast,
> 	int broadcast, int promisc, int allmulti);
> -int enic_dev_add_addr(struct enic *enic, u8 *addr);
> -int enic_dev_del_addr(struct enic *enic, u8 *addr);
> +int enic_dev_add_addr(struct enic *enic, const u8 *addr);
> +int enic_dev_del_addr(struct enic *enic, const u8 *addr);
> int enic_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16 vid);
> int enic_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid);
> int enic_dev_notify_unset(struct enic *enic);
> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index 0d8995c..6439c82 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -616,8 +616,71 @@ static struct rtnl_link_stats64 *enic_get_stats(struct net_device *netdev,
> 	return net_stats;
> }
>
> +static int enic_mc_sync(struct net_device *netdev, const u8 *mc_addr)
> +{
> +	struct enic *enic = netdev_priv(netdev);
> +
> +	if (enic->mc_count == ENIC_MULTICAST_PERFECT_FILTERS) {
> +		unsigned int mc_count = netdev_mc_count(netdev);
> +
> +		netdev_warn(netdev, "Registering only %d out of %d multicast addresses\n",
> +			    ENIC_MULTICAST_PERFECT_FILTERS, mc_count);
> +
> +		return -ENOSPC;
> +	}
> +
> +	enic_dev_add_addr(enic, mc_addr);
> +	enic->mc_count++;
> +
> +	return 0;
> +}
> +
> +static int enic_mc_unsync(struct net_device *netdev, const u8 *mc_addr)
> +{
> +	struct enic *enic = netdev_priv(netdev);
> +
> +	enic_dev_del_addr(enic, mc_addr);
> +	enic->mc_count--;
> +
> +	return 0;
> +}
> +
> +static int enic_uc_sync(struct net_device *netdev, const u8 *uc_addr)
> +{
> +	struct enic *enic = netdev_priv(netdev);
> +
> +	if (enic->uc_count == ENIC_UNICAST_PERFECT_FILTERS) {
> +		unsigned int uc_count = netdev_uc_count(netdev);
> +
> +		netdev_warn(netdev, "Registering only %d out of %d unicast addresses\n",
> +			    ENIC_UNICAST_PERFECT_FILTERS, uc_count);
> +
> +		return -ENOSPC;
> +	}
> +
> +	enic_dev_add_addr(enic, uc_addr);
> +	enic->uc_count++;
> +
> +	return 0;
> +}
> +
> +static int enic_uc_unsync(struct net_device *netdev, const u8 *uc_addr)
> +{
> +	struct enic *enic = netdev_priv(netdev);
> +
> +	enic_dev_del_addr(enic, uc_addr);
> +	enic->uc_count--;
> +
> +	return 0;
> +}
> +
> void enic_reset_addr_lists(struct enic *enic)
> {
> +	struct net_device *netdev = enic->netdev;
> +
> +	__dev_uc_unsync(netdev, NULL);
> +	__dev_mc_unsync(netdev, NULL);
> +
> 	enic->mc_count = 0;
> 	enic->uc_count = 0;
> 	enic->flags = 0;
> @@ -684,112 +747,6 @@ static int enic_set_mac_address(struct net_device *netdev, void *p)
> 	return enic_dev_add_station_addr(enic);
> }
>
> -static void enic_update_multicast_addr_list(struct enic *enic)
> -{
> -	struct net_device *netdev = enic->netdev;
> -	struct netdev_hw_addr *ha;
> -	unsigned int mc_count = netdev_mc_count(netdev);
> -	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
> -	unsigned int i, j;
> -
> -	if (mc_count > ENIC_MULTICAST_PERFECT_FILTERS) {
> -		netdev_warn(netdev, "Registering only %d out of %d "
> -			"multicast addresses\n",
> -			ENIC_MULTICAST_PERFECT_FILTERS, mc_count);
> -		mc_count = ENIC_MULTICAST_PERFECT_FILTERS;
> -	}
> -
> -	/* Is there an easier way?  Trying to minimize to
> -	 * calls to add/del multicast addrs.  We keep the
> -	 * addrs from the last call in enic->mc_addr and
> -	 * look for changes to add/del.
> -	 */
> -
> -	i = 0;
> -	netdev_for_each_mc_addr(ha, netdev) {
> -		if (i == mc_count)
> -			break;
> -		memcpy(mc_addr[i++], ha->addr, ETH_ALEN);
> -	}
> -
> -	for (i = 0; i < enic->mc_count; i++) {
> -		for (j = 0; j < mc_count; j++)
> -			if (ether_addr_equal(enic->mc_addr[i], mc_addr[j]))
> -				break;
> -		if (j == mc_count)
> -			enic_dev_del_addr(enic, enic->mc_addr[i]);
> -	}
> -
> -	for (i = 0; i < mc_count; i++) {
> -		for (j = 0; j < enic->mc_count; j++)
> -			if (ether_addr_equal(mc_addr[i], enic->mc_addr[j]))
> -				break;
> -		if (j == enic->mc_count)
> -			enic_dev_add_addr(enic, mc_addr[i]);
> -	}
> -
> -	/* Save the list to compare against next time
> -	 */
> -
> -	for (i = 0; i < mc_count; i++)
> -		memcpy(enic->mc_addr[i], mc_addr[i], ETH_ALEN);
> -
> -	enic->mc_count = mc_count;
> -}
> -
> -static void enic_update_unicast_addr_list(struct enic *enic)
> -{
> -	struct net_device *netdev = enic->netdev;
> -	struct netdev_hw_addr *ha;
> -	unsigned int uc_count = netdev_uc_count(netdev);
> -	u8 uc_addr[ENIC_UNICAST_PERFECT_FILTERS][ETH_ALEN];
> -	unsigned int i, j;
> -
> -	if (uc_count > ENIC_UNICAST_PERFECT_FILTERS) {
> -		netdev_warn(netdev, "Registering only %d out of %d "
> -			"unicast addresses\n",
> -			ENIC_UNICAST_PERFECT_FILTERS, uc_count);
> -		uc_count = ENIC_UNICAST_PERFECT_FILTERS;
> -	}
> -
> -	/* Is there an easier way?  Trying to minimize to
> -	 * calls to add/del unicast addrs.  We keep the
> -	 * addrs from the last call in enic->uc_addr and
> -	 * look for changes to add/del.
> -	 */
> -
> -	i = 0;
> -	netdev_for_each_uc_addr(ha, netdev) {
> -		if (i == uc_count)
> -			break;
> -		memcpy(uc_addr[i++], ha->addr, ETH_ALEN);
> -	}
> -
> -	for (i = 0; i < enic->uc_count; i++) {
> -		for (j = 0; j < uc_count; j++)
> -			if (ether_addr_equal(enic->uc_addr[i], uc_addr[j]))
> -				break;
> -		if (j == uc_count)
> -			enic_dev_del_addr(enic, enic->uc_addr[i]);
> -	}
> -
> -	for (i = 0; i < uc_count; i++) {
> -		for (j = 0; j < enic->uc_count; j++)
> -			if (ether_addr_equal(uc_addr[i], enic->uc_addr[j]))
> -				break;
> -		if (j == enic->uc_count)
> -			enic_dev_add_addr(enic, uc_addr[i]);
> -	}
> -
> -	/* Save the list to compare against next time
> -	 */
> -
> -	for (i = 0; i < uc_count; i++)
> -		memcpy(enic->uc_addr[i], uc_addr[i], ETH_ALEN);
> -
> -	enic->uc_count = uc_count;
> -}
> -
> /* netif_tx_lock held, BHs disabled */
> static void enic_set_rx_mode(struct net_device *netdev)
> {
> @@ -812,9 +769,9 @@ static void enic_set_rx_mode(struct net_device *netdev)
> 	}
>
> 	if (!promisc) {
> -		enic_update_unicast_addr_list(enic);
> +		__dev_uc_sync(netdev, enic_uc_sync, enic_uc_unsync);
> 		if (!allmulti)
> -			enic_update_multicast_addr_list(enic);
> +			__dev_mc_sync(netdev, enic_mc_sync, enic_mc_unsync);
> 	}
> }
>
> diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
> index 69dd925..e86a45c 100644
> --- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
> +++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
> @@ -657,7 +657,7 @@ int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
> 	return err;
> }
>
> -int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
> +int vnic_dev_add_addr(struct vnic_dev *vdev, const u8 *addr)
> {
> 	u64 a0 = 0, a1 = 0;
> 	int wait = 1000;
> @@ -674,7 +674,7 @@ int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
> 	return err;
> }
>
> -int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
> +int vnic_dev_del_addr(struct vnic_dev *vdev, const u8 *addr)
> {
> 	u64 a0 = 0, a1 = 0;
> 	int wait = 1000;
> diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
> index e670029..1f3b301 100644
> --- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
> +++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
> @@ -95,8 +95,8 @@ int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats);
> int vnic_dev_hang_notify(struct vnic_dev *vdev);
> int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
> 	int broadcast, int promisc, int allmulti);
> -int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
> -int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
> +int vnic_dev_add_addr(struct vnic_dev *vdev, const u8 *addr);
> +int vnic_dev_del_addr(struct vnic_dev *vdev, const u8 *addr);
> int vnic_dev_get_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
> int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr);
> int vnic_dev_notify_unset(struct vnic_dev *vdev);
>
>
