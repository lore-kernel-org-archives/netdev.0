From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] net/mlx4_en: Doorbell is byteswapped in Little
 Endian archs
Date: Mon, 5 Jan 2015 09:46:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC06FE@AcuExch.aculab.com>
References: <1419185938-28987-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: 'Amir Vadai' <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:64311 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979AbbAELiP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 06:38:15 -0500
In-Reply-To: <1419185938-28987-1-git-send-email-amirv@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> iowrite32() will byteswap it's argument on big endian archs.
> iowrite32be() will byteswap on little endian archs.
> Since we don't want to do this unnecessary byteswap on the fast path,
> doorbell is stored in the NIC's native endianness. Using the right
> iowrite() according to the arch endianness.

Someone seems to have forgotten that the byteswap within iowrite32()
on ppc (and more recent sparc) is almost certainly 'free'.
So the value ought to be stored in the byte order required by iowrite32().

	David

> Fixes: 6a4e812 ("net/mlx4_en: Avoid calling bswap in tx fast path")
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index a308d41..6477cc7 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -962,7 +962,16 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>  		tx_desc->ctrl.owner_opcode = op_own;
>  		if (send_doorbell) {
>  			wmb();
> -			iowrite32(ring->doorbell_qpn,
> +		/* Since there is no iowrite*_native() that writes the value
> +		 * as is, without byteswapping - using the one the doesn't do
> +		 * byteswapping in the relevant arch endianness.
> +		 */
> +#if defined(__LITTLE_ENDIAN)
> +			iowrite32(
> +#else
> +			iowrite32be(
> +#endif
> +				  ring->doorbell_qpn,
>  				  ring->bf.uar->map + MLX4_SEND_DOORBELL);
>  		} else {
>  			ring->xmit_more++;
> --
> 1.9.3
