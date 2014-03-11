From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V1 net-next 2/7] mlx4_core: For RoCE, allow slaves to
 set the GID entry at that slave's index
Date: Tue, 11 Mar 2014 22:12:04 +0300
Message-ID: <531F6004.4070208@cogentembedded.com>
References: <1394542976-20095-1-git-send-email-ogerlitz@mellanox.com> <1394542976-20095-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33770 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbaCKSMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 14:12:10 -0400
Received: by mail-lb0-f170.google.com with SMTP id s7so6012433lbd.29
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 11:12:09 -0700 (PDT)
In-Reply-To: <1394542976-20095-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/11/2014 04:02 PM, Or Gerlitz wrote:

> From: Jack Morgenstein <jackm@dev.mellanox.co.il>

> For IB transport, the host determines the slave GIDs. For ETH (RoCE),
> however, the slave's GID is determined by the IP address that the slave
> itself assigns to the ETH device used by RoCE.

> In this case, the slave must be able to write its GIDs to the HCA gid table
> (at the GID indices that slave "owns").

> This commit adds processing for the SET_PORT_GID_TABLE opcode modifier
> for the SET_PORT command wrapper (so that slaves may modify their GIDS
> for RoCE).

> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/port.c |   27 ++++++++++++++++++++++++++-
>   1 files changed, 26 insertions(+), 1 deletions(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
> index 9c063d6..095f74d 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/port.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/port.c
[...]
> @@ -581,6 +584,28 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
>
>   			gen_context->mtu = cpu_to_be16(master->max_mtu[port]);
>   			break;
> +		case MLX4_SET_PORT_GID_TABLE:
> +			gid_entry = (struct mlx4_roce_gid_entry *)(inbox->buf);
> +			/* check that do not have duplicates */
> +			if (memcmp(gid_entry->raw, zgid_entry.raw, 16)) {
> +				for (i = 0; i < MLX4_ROCE_MAX_GIDS; i++) {
> +					if (slave != i &&
> +					    !memcmp(gid_entry->raw, priv->roce_gids[port - 1][i].raw, 16)) {

    This line is over 80 columns, as checkpatch.pl would have told.

> +						mlx4_warn(dev, "requested gid entry for slave:%d "
> +							  "is a duplicate of slave %d\n",

     checkpatch.pl would have warned not to break up the string literal here 
-- it's an exception from the 80-column rule.

> +							  slave, i);
> +						return -EEXIST;
> +					}
> +				}
> +			}
> +			/* insert slave GID at proper index */
> +			memcpy(priv->roce_gids[port - 1][slave].raw, gid_entry->raw, 16);

    This line is over 80 columns.

> +			/* rewrite roce port gids table to FW */
> +			for (i = 0; i < MLX4_ROCE_MAX_GIDS; i++) {
> +				memcpy(gid_entry->raw, priv->roce_gids[port - 1][i].raw, 16);

    This one too.

> +				gid_entry++;
> +			}
> +			break;

WBR, Sergei
