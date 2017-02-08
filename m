From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 net-next] enic: add vxlan offload on tx path
Date: Wed, 08 Feb 2017 14:57:05 -0500 (EST)
Message-ID: <20170208.145705.1739874934577587584.davem@davemloft.net>
References: <20170208072825.3144-1-gvaradar@cisco.com>
        <20170208072825.3144-4-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58770 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751942AbdBHUu4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:50:56 -0500
In-Reply-To: <20170208072825.3144-4-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Date: Tue,  7 Feb 2017 23:28:25 -0800

> Define ndo_features_check. Hw supports offload only for ipv4 inner and
> ipv4 outer pkt.
> 
> Code refactor for setting inner tcp pseudo csum.
> 
> Signed-off-by: Govindarajulu Varadarajan <gvaradar@cisco.com>
> ---
>  drivers/net/ethernet/cisco/enic/enic_main.c | 126 +++++++++++++++++++++++++---
>  1 file changed, 114 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index ce5ce394a810..9cfebdb22e81 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -263,6 +263,48 @@ static void enic_udp_tunnel_del(struct net_device *netdev,
>  	spin_unlock_bh(&enic->devcmd_lock);
>  }
>  
> +static netdev_features_t enic_features_check(struct sk_buff *skb,
> +					     struct net_device *dev,
> +					     netdev_features_t features)
> +{
> +	struct enic *enic = netdev_priv(dev);
> +	struct udphdr *udph;
> +	u16 proto;
> +	u16 port = 0;
> +	const struct ethhdr *eth = (struct ethhdr *)skb_inner_mac_header(skb);

Order variables from longest to shortest line.

> +static int enic_queue_wq_skb_tso(struct enic *enic, struct vnic_wq *wq,
> +				 struct sk_buff *skb, unsigned int mss,
> +				 int vlan_tag_insert, unsigned int vlan_tag,
> +				 int loopback)
> +{
> +	unsigned int frag_len_left = skb_headlen(skb);
> +	unsigned int len_left = skb->len - frag_len_left;
> +	unsigned int hdr_len;
> +	int eop = (len_left == 0);
> +	unsigned int len;
> +	dma_addr_t dma_addr;
> +	unsigned int offset = 0;
> +	skb_frag_t *frag;

Likewise.
