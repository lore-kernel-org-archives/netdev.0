From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 02/23 v3] mlx4_core: add multi-function communication
 channel
Date: Tue, 09 Feb 2010 14:37:09 +0000
Message-ID: <1265726229.2126.73.camel@achroite.uk.solarflarecom.com>
References: <49BFC313.1030901@mellanox.co.il>
	 <4B6AEDBA.6040403@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, general@lists.openfabrics.org,
	netdev@vger.kernel.org, liranl@mellanox.co.il,
	tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:48518 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290Ab0BIOhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 09:37:12 -0500
In-Reply-To: <4B6AEDBA.6040403@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-04 at 17:54 +0200, Yevgeny Petrilin wrote:
> The communication channel consists of 2 registers per vf (a slave function)
> that are shared with the pf (the master function), as well as a new command for
> inter-function memory copying (only exposed to the master).
> 
> The communication channel is used to establish a Virtual HCA Command Register
> (vHCR) in each slave function, which allows it to pass FW commands to the master
> function for execution.
> The slave also uses the vHCR to pull slave-specific events from the master.
> 
> Signed-off-by: Liran Liss <liranl@mellanox.co.il>
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/mlx4/cmd.c      |  746 ++++++++++++++++++++++++++++++++++++++++++-
>  drivers/net/mlx4/en_port.h  |    5 -
>  drivers/net/mlx4/eq.c       |   67 ++++
>  drivers/net/mlx4/fw.c       |    8 +
>  drivers/net/mlx4/mlx4.h     |   72 ++++-
>  include/linux/mlx4/cmd.h    |   12 +-
>  include/linux/mlx4/device.h |    3 +-
>  7 files changed, 895 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
> index 65ec77d..6c3d25c 100644
> --- a/drivers/net/mlx4/cmd.c
> +++ b/drivers/net/mlx4/cmd.c
> @@ -140,6 +140,46 @@ static int mlx4_status_to_errno(u8 status)
>  	return trans_table[status];
>  }
>  
> +static int comm_pending(struct mlx4_dev *dev)
> +{
> +	struct mlx4_priv *priv = mlx4_priv(dev);
> +	u32 status = readl(&priv->mfunc.comm->slave_read);
> +
> +	return (swab32(status) >> 30) != priv->cmd.comm_toggle;
> +}
> +
> +int mlx4_comm_cmd(struct mlx4_dev *dev, u8 cmd, u16 param, unsigned long timeout)
> +{
> +	struct mlx4_priv *priv = mlx4_priv(dev);
> +	unsigned long end;
> +	u32 val;
> +
> +	/* First, verify that the master reports correct status */
> +	if (comm_pending(dev)) {
> +		mlx4_warn(dev, "Communication channel is not idle\n");
> +		return -EAGAIN;
> +	}
> +
> +	/* Write command */
> +	if (cmd == MLX4_COMM_CMD_RESET)
> +		priv->cmd.comm_toggle = 0;
> +	else if (++priv->cmd.comm_toggle > 2)
> +		priv->cmd.comm_toggle = 1;
> +	val = param | (cmd << 16) | (priv->cmd.comm_toggle << 30);
> +	__raw_writel((__force u32) cpu_to_be32(val), &priv->mfunc.comm->slave_write);
> +	wmb();

I think you need a wmb() *before* writing the command, so that its
parameters are visible.  I don't see why you would need a wmb()
afterward; maybe you want mmiowb()?

I also suggest you encapsulate this byte-swapping in inline functions:

static inline u32 comm_read(void __iomem *addr)
{
	return be32_to_cpu((__force __be32) __raw_readl(addr));
}

static inline void comm_write(u32 val, void __iomem *addr)
{
	__raw_writel((__force u32) cpu_to_be32(val), addr);
	mmiowb();
}

[...]
> +static struct mlx4_cmd_info {
> +	u16 opcode;
> +	bool has_inbox;
> +	bool has_outbox;
> +	bool out_is_imm;
> +	int (*verify)(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
> +					    struct mlx4_cmd_mailbox *inbox);
> +	int (*wrapper)(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
> +					     struct mlx4_cmd_mailbox *inbox,
> +					     struct mlx4_cmd_mailbox *outbox);
> +} cmd_info[] = {
[...]
> +	{
> +		.opcode = MLX4_CMD_SW2HW_EQ,
> +		.has_inbox = true,
> +		.has_outbox = false,
> +		.out_is_imm = false,
> +		.verify = NULL, /*need verifier */
> +		.wrapper = NULL
> +	},

What does 'need verifier' mean?  Is this implementation incomplete?

> +static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave)
> +{
[...]
> +	/* Execute the command! */
> +	if (cmd->wrapper)
> +		vhcr->errno = cmd->wrapper(dev, slave, vhcr, inbox, outbox);
> +	else {
> +		in_param = cmd->has_inbox ? (u64) inbox->dma : vhcr->in_param;
> +		out_param = cmd->has_outbox ? (u64) outbox->dma : vhcr->out_param;
> +		vhcr->errno = __mlx4_cmd(dev, in_param, &out_param,
> +							cmd->out_is_imm,
> +							vhcr->in_modifier,
> +							vhcr->op_modifier,
> +							vhcr->op,
> +							vhcr->timeout);
> +		if (cmd->out_is_imm)
> +			vhcr->out_param = out_param;
> +	}

Both branches should be bracketed.

[...]
> +static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd, u16 param, u8 toggle)
> +{
[...]
> +reset_slave:
> +	/* FIXME: cleanup any slave resources */
[...]

Maybe you should do that in the next version then?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

