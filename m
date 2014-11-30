From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn
 on big endian platform
Date: Sun, 30 Nov 2014 11:27:48 -0800
Message-ID: <1417375668.4442.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, gideonn@mellanox.com,
	Eric Dumazet <edumazet@google.com>,
	Amir Vadai <amirv@mellanox.com>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:40809 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbaK3T1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 14:27:51 -0500
Received: by mail-ie0-f178.google.com with SMTP id tp5so8094935ieb.23
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 11:27:50 -0800 (PST)
In-Reply-To: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-30 at 10:43 +0800, Wei Yang wrote:
> In commit 6a4e812 (net/mlx4_en: Avoid calling bswap in tx fast path), we store
> doorbell_qpn in big endian to avoid bswap(). Then we try to write it directly
> by iowrite32() instead of iowrite32be().
> 
> This works fine on little endian platform, while has some problem on big
> endian platform. Here is the definition in general:
> 
> 	#define iowrite32(v, addr)	writel((v), (addr))
> 	#define writel(b,addr)		__raw_writel(__cpu_to_le32(b),addr)

Oh well...

> 
> On little endian platform, the value is not swapped before write. While on big
> endian platform, the value is swapped. This is not expected to happen.
> 
> This patch does the swap on big endian platform before it is written.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 454d9fe..76f028b 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -954,7 +954,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>  		tx_desc->ctrl.owner_opcode = op_own;
>  		if (send_doorbell) {
>  			wmb();
> -			iowrite32(ring->doorbell_qpn,
> +			iowrite32(__cpu_to_le32(ring->doorbell_qpn),
>  				  ring->bf.uar->map + MLX4_SEND_DOORBELL);
>  		} else {
>  			ring->xmit_more++;

Well, whole idea of the patch was to perform the swap (if any) out of
the fast path.

ring->doorbell_qpn is a cache of whatever value.

Have you tried to convert it to a __le32 instead of __be32 ?

Thanks
