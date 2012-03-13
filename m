From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 7/8] net: support tx_ring per UP in HW based QoS mechanism
Date: Tue, 13 Mar 2012 11:23:03 -0700
Message-ID: <4F5F9087.7090607@intel.com>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com> <1331659323-12904-8-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:17197 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758733Ab2CMSXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 14:23:07 -0400
In-Reply-To: <1331659323-12904-8-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/2012 10:22 AM, Amir Vadai wrote:
> From: Amir Vadai <amirv@mellanox.co.il>
> 
> The Current HW based QoS mechanism which was introduced in commit 4f57c087de9
> "net: implement mechanism for HW based QOS" is in orientation to ETS traffic
> class. This patch introduces an approach which allow to use this mechanism also
> with hardware who has queues per user priority (UP). After the change,
> __skb_tx_hash() will direct a flow to a tx ring from a range of tx rings. This
> range is defined by the caller function by the specific HW. If TC based queues,
> the range is by TC number and for UP based queues, the range is by UP.
> 

ETS is one specific use case for mqprio it can easily be used with other
hardware transmission selection algorithms 802.1Q std based or otherwise.

The mapping is really just an skb->priority to group of queues (qoffset and
qcount). I happened to call the queue grouping a traffic class because that
aligns with 802.1Q but it _really_ is just a queue grouping.

In your case what would it mean to change the map and num_tc see 'tc':

[root@jf-dev1-dcblab netperf]# tc qdisc add dev eth3 root mqprio help
Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]
                  [queues count1@offset1 count2@offset2 ...] [hw 1|0]

For example setting 'num_tc 8 map 0 1 2 3 0 1 2 3' looks like it might
not work correctly. Would you end up with an skb tagged with priority
4,5,6,7 being sent out UP queues 0,1,2,3? My quess is that won't work
with PFC or your ETS correctly.

In the canonical iSCSI case we put iscsid in a net_prio cgroup to get the
priority set then use the priority to steer the skb to the correct queue
groupings. In your case I think you can just fail any num_tc != 8 and keep
the dflt map 1:1 then this should work. What did I miss? It looks like you
already fail the num_tc != 8 case so why do we need this change?

At most maybe we need a flag to indicate the mqprio map can't be changed in
some cases.


> CC: John Fastabend <john.r.fastabend@intel.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Eilon Greenstein <eilong@broadcom.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   11 ++++++++++-
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c      |    9 +++------
>  include/linux/netdevice.h                       |   12 +++++++++++-
>  include/linux/skbuff.h                          |    3 ++-
>  net/core/dev.c                                  |   10 +---------
>  5 files changed, 27 insertions(+), 18 deletions(-)
> 

[...]

>  
>  void bnx2x_set_num_queues(struct bnx2x *bp)
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 7a49830..d0d96e3 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -570,18 +570,15 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
>  
>  u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
>  {
> -	struct mlx4_en_priv *priv = netdev_priv(dev);
> -	int up = -1;
> +	int up = 0;
>  
>  	if (vlan_tx_tag_present(skb))
>  		up = (vlan_tx_tag_get(skb) >> 13);

I was trying to avoid logic like this in select_queue().

Can we get the same behavior by keeping the egress map and mqprio
map in sync?

>  	else if (dev->num_tc)
>  		up = netdev_get_prio_tc_map(dev, skb->priority);
>  
> -	if (up >= 0)
> -		return MLX4_EN_NUM_TX_RINGS + up;
> -
> -	return __skb_tx_hash(dev, skb, MLX4_EN_NUM_TX_RINGS);
> +	return __skb_tx_hash(dev, skb, MLX4_EN_NUM_TX_RINGS,
> +			MLX4_EN_NUM_TX_RINGS + up, 1);
>  }
>  

Thanks,
John
