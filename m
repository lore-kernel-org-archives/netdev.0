From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] mlx4_core: fix race on comm channel
Date: Sun, 18 Mar 2012 05:55:51 -0700
Message-ID: <1332075351.3722.38.camel@edumazet-laptop>
References: <4F65D27F.7010102@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eugenia@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:55350 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab2CRMzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 08:55:54 -0400
Received: by dajr28 with SMTP id r28so8534881daj.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 05:55:54 -0700 (PDT)
In-Reply-To: <4F65D27F.7010102@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 mars 2012 =C3=A0 14:18 +0200, Yevgeny Petrilin a =C3=A9c=
rit :
> From: Eugenia Emantayev <eugenia@mellanox.co.il>
>=20
> Prevent race condition between commands on comm channel.
> Happened while unloading the driver when switching from
> event to polling mode. VF got completion on the last command
> before switching to polling mode, but toggle was not changed.
> After the fix - VF will not write the next command before
> toggle is updated.
>=20
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
> ---
>  drivers/net/ethernet/mellanox/mlx4/cmd.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/e=
thernet/mellanox/mlx4/cmd.c
> index eaf09d4..2f1f4a1 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> @@ -239,6 +239,7 @@ static int mlx4_comm_cmd_wait(struct mlx4_dev *de=
v, u8 op,
>  {
>  	struct mlx4_cmd *cmd =3D &mlx4_priv(dev)->cmd;
>  	struct mlx4_cmd_context *context;
> +	unsigned long end;
>  	int err =3D 0;
> =20
>  	down(&cmd->event_sem);
> @@ -268,6 +269,13 @@ static int mlx4_comm_cmd_wait(struct mlx4_dev *d=
ev, u8 op,
>  	}
> =20
>  out:
> +	/* wait for comm channel ready
> +	   this is necessary for prevention the race
> +	   when switching between event to polling mode */
> +	end =3D msecs_to_jiffies(timeout) + jiffies;
> +	while (comm_pending(dev) && time_before(jiffies, end))
> +		cond_resched();
> +
>  	spin_lock(&cmd->context_lock);
>  	context->next =3D cmd->free_head;
>  	cmd->free_head =3D context - cmd->context;

David wants your comment like this :

	/* dfgdgg rertert cxvcvcxv=20
	 * sddsf sdfsdfdsf sfddfd dfdfd fdfdfdfd df
	 * bxvqir sdjqpo cqljcdlskjs d.
	 */

(I wont comment on the grammar)
