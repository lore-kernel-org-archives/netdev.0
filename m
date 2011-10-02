From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Sun, 2 Oct 2011 08:58:21 +0000
Message-ID: <953B660C027164448AE903364AC447D2235D9A8C@MTLDAG02.mtl.com>
References: <1317388995-411-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:48405 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751661Ab1JBI6Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2011 04:58:25 -0400
In-Reply-To: <1317388995-411-1-git-send-email-cascardo@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> With the addition of Blue Frame support in the network driver for mlx4, the doorbell is not written in the path where blue frame is enabled and the package follows some characteristics.
> 
> The consequence of that is that ICMP ECHO requests, for example, were not transmitted by the device. A ping flood, for example, would make the
> watchdog dispatch, because the ring was full and transmissions have timed out.
> 
> After this fix, I could ping two systems using mlx4_en (both with the fix).
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo
> <cascardo@linux.vnet.ibm.com>
> Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 6e03de0..270da80 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -811,10 +811,11 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb,
> struct net_device *dev)
>  		* before setting ownership of this descriptor to HW */
>  		wmb();
>  		tx_desc->ctrl.owner_opcode = op_own;
> -		wmb();
> -		writel(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
>  	}
> 
> +	wmb();
> +	writel(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
> +
>  	/* Poll CQ here */
>  	mlx4_en_xmit_poll(priv, tx_ind);
> 
> --
> 1.7.4.4

What this patch does is ringing the doorbell unconditionally, whether blue flame is used or not.
The whole idea, is to copy the data to the blueflame register and have the HW take the data from there and save the memory access to the work queue entry.
In this patch you do both, copy the data to the register, and then still the HW accesses the memory to take it.
For some reason Blue flame is not working on your system and we need to understand why, I'll be glad to work with you to debug it.
Anyway, this patch is not the solution (even that it works on your systems) for the problem.

Yevgeny
