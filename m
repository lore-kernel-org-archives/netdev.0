From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 03/16] net/mlx5: E-Switch, Add miss rule for
 offloads mode
Date: Mon, 27 Jun 2016 19:53:16 +0300
Message-ID: <8d994e8f-f4bf-f6b3-c47b-c4c4a94da647@cogentembedded.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
 <1467043649-28594-4-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:33095 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbcF0QxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 12:53:21 -0400
Received: by mail-lf0-f46.google.com with SMTP id f6so160079754lfg.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 09:53:20 -0700 (PDT)
In-Reply-To: <1467043649-28594-4-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/27/2016 07:07 PM, Saeed Mahameed wrote:

> From: Or Gerlitz <ogerlitz@mellanox.com>
>
> In the sriov offloads mode, packets that are not matched by any other
> rule should be sent towards the e-switch manager for further processing.
>
> Add such "miss" rule which matches ANY packet as the last rule in the
> e-switch FDB and programs the HW to send the packet to vport 0 where
> the e-switch manager runs.
>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
[...]

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> index c6b28df..9310017 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> @@ -38,6 +38,41 @@
>  #include "mlx5_core.h"
>  #include "eswitch.h"
>
> +static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
> +{
> +	struct mlx5_flow_destination dest;
> +	struct mlx5_flow_rule *flow_rule = NULL;
> +	int match_header = 0;

    This variable doesn't apperar necessary...

> +	u32 *match_v, *match_c;
> +	int err = 0;
> +
> +	match_v = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
> +	match_c = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
> +	if (!match_v || !match_c) {
> +		esw_warn(esw->dev, "FDB: Failed to alloc match parameters\n");
> +		err = -ENOMEM;
> +		goto out;
> +	}
> +
> +	dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
> +	dest.vport_num = 0;
> +
> +	flow_rule = mlx5_add_flow_rule(esw->fdb_table.fdb, match_header, match_c,

    Whu not just pass 0 instead of 'match_header'?

> +				       match_v, MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
> +				       0, &dest);
> +	if (IS_ERR(flow_rule)) {
> +		err = PTR_ERR(flow_rule);
> +		esw_warn(esw->dev,  "FDB: Failed to add miss flow rule err %d\n", err);
> +		goto out;
> +	}
> +
> +	esw->fdb_table.offloads.miss_rule = flow_rule;
> +out:
> +	kfree(match_v);
> +	kfree(match_c);
> +	return err;
> +}
> +
>  #define MAX_PF_SQ 256
>
>  int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
[...]

MBR, Sergei
