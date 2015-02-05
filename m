From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/3] IB/mlx4: Always use the correct port for
 mirrored multicast attachments
Date: Thu, 05 Feb 2015 17:04:44 +0300
Message-ID: <54D3787C.3030603@cogentembedded.com>
References: <1423144366-11814-1-git-send-email-ogerlitz@mellanox.com> <1423144366-11814-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:52171 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbbBEOEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 09:04:48 -0500
Received: by mail-lb0-f170.google.com with SMTP id w7so7494997lbi.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 06:04:46 -0800 (PST)
In-Reply-To: <1423144366-11814-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/5/2015 4:52 PM, Or Gerlitz wrote:

> From: Moni Shoua <monis@mellanox.com>

> When attaching a QP to a multicast address in bonded mode, there was an
> assumption that the port of the QP must be #1. This assumption isn't the
> case under the flow which enables maximal usage of the physical ports.

> Fix it by always checking the port of the original flow and create the
> mirrored flow on the other port.

> Fixes: c6215745b66a ("IB/mlx4: Load balance ports in port aggregation mode")
> Signed-off-by: Moni Shoua <monis@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>   drivers/infiniband/hw/mlx4/main.c |    8 ++++++--
>   1 files changed, 6 insertions(+), 2 deletions(-)

> diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
> index 2ed5b99..271d3f1 100644
> --- a/drivers/infiniband/hw/mlx4/main.c
> +++ b/drivers/infiniband/hw/mlx4/main.c
> @@ -1186,6 +1186,9 @@ static struct ib_flow *mlx4_ib_create_flow(struct ib_qp *qp,
>   			goto err_create_flow;
>   		i++;
>   		if (is_bonded) {
> +			/* Application always sees one port so the mirror rule
> +			 * must be on port #2
> +			 */

    Unrelated change?

>   			flow_attr->port = 2;
>   			err = __mlx4_ib_create_flow(qp, flow_attr,
>   						    domain, type[j],
> @@ -1279,14 +1282,15 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
>
>   	err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw, mqp->port,
>   				    !!(mqp->flags &
> -				       MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
> +				    MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),

    This change is both unrelated and unneeded.

>   				    prot, &reg_id.id);
>   	if (err)
>   		goto err_malloc;
>
>   	reg_id.mirror = 0;
>   	if (mlx4_is_bonded(dev)) {
> -		err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw, 2,
> +		err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw,
> +					    (mqp->port == 1) ? 2 : 1,

    I doubt that these parens are needed.

WBR, Sergei
