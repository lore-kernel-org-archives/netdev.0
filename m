From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net/mlx4_en: Doorbell is byteswapped in Little Endian
 archs
Date: Sun, 21 Dec 2014 22:53:50 +0300
Message-ID: <5497254E.6090603@cogentembedded.com>
References: <1419185938-28987-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Wei Yang <weiyang@linux.vnet.ibm.com>,
	David Laight <david.laight@aculab.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:47458 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbaLUTxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 14:53:52 -0500
Received: by mail-la0-f47.google.com with SMTP id hz20so3021899lab.6
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 11:53:50 -0800 (PST)
In-Reply-To: <1419185938-28987-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/21/2014 9:18 PM, Amir Vadai wrote:

> iowrite32() will byteswap it's argument on big endian archs.
> iowrite32be() will byteswap on little endian archs.
> Since we don't want to do this unnecessary byteswap on the fast path,
> doorbell is stored in the NIC's native endianness. Using the right
> iowrite() according to the arch endianness.

> CC: Wei Yang <weiyang@linux.vnet.ibm.com>
> CC: David Laight <david.laight@aculab.com>
> Fixes: 6a4e812 ("net/mlx4_en: Avoid calling bswap in tx fast path")
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c | 11 ++++++++++-
>   1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index a308d41..6477cc7 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -962,7 +962,16 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>   		tx_desc->ctrl.owner_opcode = op_own;
>   		if (send_doorbell) {
>   			wmb();
> -			iowrite32(ring->doorbell_qpn,
> +		/* Since there is no iowrite*_native() that writes the value
> +		 * as is, without byteswapping - using the one the doesn't do
> +		 * byteswapping in the relevant arch endianness.
> +		 */

    Why the comment is not aligned with the code?

> +#if defined(__LITTLE_ENDIAN)
> +			iowrite32(
> +#else
> +			iowrite32be(
> +#endif

    Ugh...

> +				  ring->doorbell_qpn,
>   				  ring->bf.uar->map + MLX4_SEND_DOORBELL);
[...]

WBR, Sergei
