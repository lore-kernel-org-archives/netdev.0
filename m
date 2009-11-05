From: "Liran Liss" <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: RE: [PATCH 03/25] mlx4_core: add multi-function communicationchannel
Date: Thu, 5 Nov 2009 15:06:58 +0200
Message-ID: <2ED289D4E09FBD4D92D911E869B97FDD0166C9B7@mtlexch01.mtl.com>
References: <4AF19E14.5070107@mellanox.co.il> <adaiqdq17zo.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Tziporet Koren" <tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: "Roland Dreier" <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"Yevgeny Petrilin" <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-reply-to: <adaiqdq17zo.fsf-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

S.B.
--Liran

 > --- a/drivers/net/mlx4/cmd.c
 > +++ b/drivers/net/mlx4/cmd.c
 > @@ -41,6 +41,7 @@
 >  #include <asm/io.h>
 >
 >  #include "mlx4.h"
 > +#include "en_port.h"

Why does core mlx4 command handling end up depending on stuff from
en_port.h?

LL: some of the FW commands (e.g., MLX4_CMD_SET_VLAN_FLTR) are defined
here and are used in cmd.h. We will move these definitions to cmd.h.

 > +	__be32 status = readl(&priv->mfunc.comm->slave_read);

This can't be endian-clean, can it?  What does sparse with
-D__CHECK_ENDIAN__ say?
LL: will fix.

 > +	queue_delayed_work(priv->mfunc.comm_wq, &priv->mfunc.comm_work,
 > +						polled ? HZ / 1000 : HZ
/ 10);

So this is always running at least 10 times a second?  That's a lot of
wakeups on an idle system.  Is there no way to make this event-driven?
LL: events are not implemented yet - this is the next step.

And HZ/1000 is going to be 0 if HZ is less than 1000 ... so this is just
going to run continuously in the polling case.
LL: This is what we want as long as there are more pending commands.

 > +	/* Write command */
 > +	if (cmd == MLX4_COMM_CMD_RESET)
 > +		priv->cmd.comm_toggle = 0;
 > +	else if (++priv->cmd.comm_toggle > 2)
 > +		priv->cmd.comm_toggle = 1;

Is this right?  comm_toggle goes 0, 1, 2, 1, 2, ...?

LL: Yes - we need to distinguish the reset state from all other states
to support asych reset (e.g., FLR). The only way to continue from this
state
is a new boot sequence.

 > +static struct mlx4_cmd_info {
 > +	u8 opcode;
 > +	u8 has_inbox;
 > +	u8 has_outbox;
 > +	u8 out_is_imm;
 > +	int (*verify)(struct mlx4_dev *dev, int slave, struct mlx4_vhcr
*vhcr,
 > +					    struct mlx4_cmd_mailbox
*inbox);
 > +	int (*wrapper)(struct mlx4_dev *dev, int slave, struct mlx4_vhcr
*vhcr,
 > +					     struct mlx4_cmd_mailbox
*inbox,
 > +					     struct mlx4_cmd_mailbox
*outbox);
 > +} cmd_info[] = {
 > +	{MLX4_CMD_QUERY_FW,        0, 1, 0, NULL, NULL},
 > +	{MLX4_CMD_QUERY_ADAPTER,   0, 1, 0, NULL, NULL},

This big structure would be better with designated initializers.  Also
instead of u8 for the flags bool would be better probably.  Then it
becomes more self documenting, ie

	{ .opcode = MLX4_CMD_QUERY_FW, .has_outbox = true }, ...

LL: OK. 10x.

 > +struct mlx4_vhcr {
 > +	u64 in_param;
 > +	u64 out_param;
 > +	u32 in_modifier;
 > +	u32 timeout;
 > +	u16 op;
 > +	u16 token;
 > +	u8 op_modifier;
 > +	int errno;
 > +};

trivial but can you use tabs to line up the structure field names the
way the rest of the mlx4 declarations do?
LL: Ack.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
