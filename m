From: vkolluri <vkolluri@cisco.com>
Subject: Re: [patch net-next-2.6 16/47] enic: do vlan cleanup
Date: Wed, 20 Jul 2011 14:59:27 -0700
Message-ID: <CA4C9DCF.82E8%vkolluri@cisco.com>
References: <1311173689-17419-17-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <shemminger@linux-foundation.org>,
	<eric.dumazet@gmail.com>, <greearb@candelatech.com>,
	<mirqus@gmail.com>, <benve@cisco.com>, <roprabhu@cisco.com>,
	"David (dwang2)" <dwang2@cisco.com>
To: Jiri Pirko <jpirko@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-5.cisco.com ([173.37.86.76]:24546 "EHLO
	rcdn-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691Ab1GTWIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 18:08:53 -0400
In-Reply-To: <1311173689-17419-17-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes look good. Thanks Jiri.

-Vasanthy


On 7/20/11 7:54 AM, "Jiri Pirko" <jpirko@redhat.com> wrote:

> - unify vlan and nonvlan rx path
> - kill enic->vlan_group and enic_vlan_rx_register
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  drivers/net/enic/enic.h      |    1 -
>  drivers/net/enic/enic_main.c |   32 ++++++--------------------------
>  2 files changed, 6 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
> index f0b062b..ce76d9a 100644
> --- a/drivers/net/enic/enic.h
> +++ b/drivers/net/enic/enic.h
> @@ -94,7 +94,6 @@ struct enic {
> ____cacheline_aligned struct vnic_wq wq[ENIC_WQ_MAX];
> spinlock_t wq_lock[ENIC_WQ_MAX];
> unsigned int wq_count;
> - struct vlan_group *vlan_group;
> u16 loop_enable;
> u16 loop_tag;
>  
> diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
> index e25800f..67a27cd 100644
> --- a/drivers/net/enic/enic_main.c
> +++ b/drivers/net/enic/enic_main.c
> @@ -1029,14 +1029,6 @@ static void enic_set_rx_mode(struct net_device *netdev)
> }
>  }
>  
> -/* rtnl lock is held */
> -static void enic_vlan_rx_register(struct net_device *netdev,
> - struct vlan_group *vlan_group)
> -{
> - struct enic *enic = netdev_priv(netdev);
> - enic->vlan_group = vlan_group;
> -}
> -
>  /* netif_tx_lock held, BHs disabled */
>  static void enic_tx_timeout(struct net_device *netdev)
>  {
> @@ -1264,23 +1256,13 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
>  
> skb->dev = netdev;
>  
> -  if (vlan_stripped) {
> -
> -   if (netdev->features & NETIF_F_GRO)
> -    vlan_gro_receive(&enic->napi[q_number],
> -     enic->vlan_group, vlan_tci, skb);
> -   else
> -    vlan_hwaccel_receive_skb(skb,
> -     enic->vlan_group, vlan_tci);
> +  if (vlan_stripped)
> +   __vlan_hwaccel_put_tag(skb, vlan_tci);
>  
> -  } else {
> -
> -   if (netdev->features & NETIF_F_GRO)
> -    napi_gro_receive(&enic->napi[q_number], skb);
> -   else
> -    netif_receive_skb(skb);
> -
> -  }
> +  if (netdev->features & NETIF_F_GRO)
> +   napi_gro_receive(&enic->napi[q_number], skb);
> +  else
> +   netif_receive_skb(skb);
> } else {
>  
> /* Buffer overflow
> @@ -2124,7 +2106,6 @@ static const struct net_device_ops
> enic_netdev_dynamic_ops = {
> .ndo_set_multicast_list = enic_set_rx_mode,
> .ndo_set_mac_address = enic_set_mac_address_dynamic,
> .ndo_change_mtu  = enic_change_mtu,
> - .ndo_vlan_rx_register = enic_vlan_rx_register,
> .ndo_vlan_rx_add_vid = enic_vlan_rx_add_vid,
> .ndo_vlan_rx_kill_vid = enic_vlan_rx_kill_vid,
> .ndo_tx_timeout  = enic_tx_timeout,
> @@ -2146,7 +2127,6 @@ static const struct net_device_ops enic_netdev_ops = {
> .ndo_set_rx_mode = enic_set_rx_mode,
> .ndo_set_multicast_list = enic_set_rx_mode,
> .ndo_change_mtu  = enic_change_mtu,
> - .ndo_vlan_rx_register = enic_vlan_rx_register,
> .ndo_vlan_rx_add_vid = enic_vlan_rx_add_vid,
> .ndo_vlan_rx_kill_vid = enic_vlan_rx_kill_vid,
> .ndo_tx_timeout  = enic_tx_timeout,

