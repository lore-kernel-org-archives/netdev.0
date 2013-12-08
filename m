From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 10/12] net/mlx4_en: Add NAPI support for
 transmit side
Date: Sun, 08 Dec 2013 11:22:16 -0800
Message-ID: <1386530536.30495.287.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
	 <1386506152-10298-11-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:49362 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248Ab3LHTWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 14:22:19 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so3883377pde.21
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 11:22:19 -0800 (PST)
In-Reply-To: <1386506152-10298-11-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-08 at 14:35 +0200, Amir Vadai wrote:
> From: Eugenia Emantayev <eugenia@mellanox.com>
> 
> Add NAPI for TX side,
> implement its support and provide NAPI callback.
> 
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_cq.c   | 12 ++++++---
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 39 +++++++++++++++++++++++-----
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  3 +++
>  3 files changed, 43 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
> index 3a098cc..2c60f0c 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
> @@ -161,12 +161,16 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
>  	cq->mcq.comp  = cq->is_tx ? mlx4_en_tx_irq : mlx4_en_rx_irq;
>  	cq->mcq.event = mlx4_en_cq_event;
>  
> -	if (!cq->is_tx) {
> +	if (cq->is_tx) {
> +		netif_napi_add(cq->dev, &cq->napi, mlx4_en_poll_tx_cq,
> +			       MLX4_EN_TX_BUDGET);
> +	} else {

TX completion is not supposed to have a 'budget'.

You should consume all completed descriptors.

BQL should already drive the dynamic of the TX queue.
