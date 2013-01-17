From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] net/mlx4_en: Fix bridged vSwitch configuration
 for non SRIOV mode
Date: Thu, 17 Jan 2013 08:21:48 -0800
Message-ID: <1358439708.29723.55.camel@edumazet-glaptop>
References: <1358436643-1326-1-git-send-email-ogerlitz@mellanox.com>
	 <1358436643-1326-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.com,
	Yan Burman <yanb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:47106 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757082Ab3AQQVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 11:21:52 -0500
Received: by mail-pb0-f41.google.com with SMTP id xa7so1502382pbc.28
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 08:21:51 -0800 (PST)
In-Reply-To: <1358436643-1326-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-17 at 17:30 +0200, Or Gerlitz wrote:
> From: Yan Burman <yanb@mellanox.com>
> 
> Commit 5b4c4d36860e "mlx4_en: Allow communication between functions on
> same host" introduced a regression under which a bridge acting as vSwitch
> whose uplink is an mlx4 Ethernet device become non-operative in native
> (non sriov) mode. This happens since broadcast ARP requests sent by VMs
> were loopback-ed by the HW and hence the bridge learned VM source MACs
> on both the VM and the uplink ports.
> 
> The fix is to place the DMAC in the send WQE only under SRIOV/eSwitch
> configuration or when the device is in selftest.
> 
> Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Yan Burman <yanb@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c |   13 +++++++++----
>  1 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 2b799f4..6771b69 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -630,10 +630,15 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>  		ring->tx_csum++;
>  	}
>  
> -	/* Copy dst mac address to wqe */
> -	ethh = (struct ethhdr *)skb->data;
> -	tx_desc->ctrl.srcrb_flags16[0] = get_unaligned((__be16 *)ethh->h_dest);
> -	tx_desc->ctrl.imm = get_unaligned((__be32 *)(ethh->h_dest + 2));
> +	if (mlx4_is_mfunc(mdev->dev) || priv->validate_loopback) {
> +		/* Copy dst mac address to wqe. This allows loopback in eSwitch,
> +		 * so that VFs and PF can communicate with each other
> +		 */
> +		ethh = (struct ethhdr *)skb->data;
> +		tx_desc->ctrl.srcrb_flags16[0] = get_unaligned((__be16 *)ethh->h_dest);
> +		tx_desc->ctrl.imm = get_unaligned((__be32 *)(ethh->h_dest + 2));
> +	}
> +
>  	/* Handle LSO (TSO) packets */
>  	if (lso_header_size) {
>  		/* Mark opcode as LSO */

Isn't this bug could explain why mlx4 had to filter incoming frames ?

It seems you also could remove this chunk ?

(I don't really understand why mlx4_en_mac_to_u64() is done... its
horribly expensive...). 
matching 6 bytes can be done in 3 x86_64 instructions using the right
helper (ether_addr_equal_64bits())

vi +613 drivers/net/ethernet/mellanox/mlx4/en_rx.c

               ethh = (struct ethhdr *)(page_address(frags[0].page) +
                                         frags[0].offset);
                s_mac = mlx4_en_mac_to_u64(ethh->h_source);

                /* If source MAC is equal to our own MAC and not performing
                 * the selftest or flb disabled - drop the packet */
                if (s_mac == priv->mac &&
                    !((dev->features & NETIF_F_LOOPBACK) ||
                      priv->validate_loopback))
                        goto next;
