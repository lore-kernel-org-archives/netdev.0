From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] bonding: Added bond_tlb_xmit() for tlb mode.
Date: Mon, 31 Mar 2014 08:52:38 -0700
Message-ID: <1396281158.29410.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396070947-17721-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:42230 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbaCaPwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 11:52:45 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so8420720pbc.10
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 08:52:45 -0700 (PDT)
In-Reply-To: <1396070947-17721-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-28 at 22:29 -0700, Mahesh Bandewar wrote:
> Re-organized the xmit function for the lb mode separating tlb xmit
> from the alb mode. This will enable use of the hashing policies
> like 802.3ad mode. Also extended use of xmit-hash-policy to tlb mode.
> 
> Now the tlb-mode defaults to BOND_XMIT_POLICY_LAYER2 if the xmit policy
> module parameter is not set (just like 802.3ad, or Xor mode).
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_alb.c     | 25 +++++++++++++++++++++++++
>  drivers/net/bonding/bond_alb.h     |  1 +
>  drivers/net/bonding/bond_main.c    |  6 ++++--
>  drivers/net/bonding/bond_options.c |  2 +-
>  4 files changed, 31 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 5cd36016c393..8b7426ce6182 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -1381,6 +1381,31 @@ out:
>  	return NETDEV_TX_OK;
>  }
>  
> +int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
> +{
> +	struct bonding *bond = netdev_priv(bond_dev);
> +	struct ethhdr *eth_data;
> +	struct slave *tx_slave = NULL;
> +	u32 hash_index = 0;
> +
> +	skb_reset_mac_header(skb);
> +	eth_data = eth_hdr(skb);
> +
> +	/* Do not TX balance any multicast or broadcast */
> +	if (!is_multicast_ether_addr(eth_data->h_dest)) {
> +		switch (ntohs(skb->protocol)) {

Nit :

You can avoid the ntohs(skb->protocol)

> +		case ETH_P_IP:

by using "   case htons(ETH_P_IP)


> +		case ETH_P_IPX: /* In case of IPX, it will falback to L2 hash */
> +		case ETH_P_IPV6:
> +			hash_index = bond_xmit_hash(bond, skb);
> +			tx_slave = tlb_choose_channel(bond, hash_index & 0xFF, skb->len);
> +			break;
> +		}
> +	}
