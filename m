From: Patrick Rabau <pr2345@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2: Save statistics during reset.
Date: Mon, 18 Jan 2010 22:41:14 -0600
Message-ID: <719756751001182041wbb1f648r3f02d1b4366b8fa1@mail.gmail.com>
References: <719756751001182031i50981b30y4dd9c3beea3785de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:64115 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754779Ab0ASElP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 23:41:15 -0500
Received: by ey-out-2122.google.com with SMTP id d26so876240eyd.19
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 20:41:14 -0800 (PST)
In-Reply-To: <719756751001182031i50981b30y4dd9c3beea3785de@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch has already been applied, but seems to have a problem.

> MTU changes, ring size changes, etc cause the chip to be reset and th=
e
> statisctics flushed. =A0To keep track of the accumulated statistics, =
we
> add code to save the whole statistics block before reset. =A0We also
> modify the macros and statistics functions to return the sum of the
> saved and current counters.
>
> Based on original patch by Breno Leitao <leitao@xxxxxxxxxxxxxxxxxx>
>
> Signed-off-by: Michael Chan <mchan@xxxxxxxxxxxx>
> ---
> =A0drivers/net/bnx2.c | =A0 64 ++++++++++++++++++++++++++++++++++++++=
+++++++------
> =A0drivers/net/bnx2.h | =A0 =A01 +
> =A02 files changed, 57 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 47fb508..d83512d 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c

=2E..

> @@ -6542,6 +6544,30 @@ bnx2_close(struct net_device *dev)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static void
> +bnx2_save_stats(struct bnx2 *bp)
> +{
> + =A0 =A0 =A0 u32 *hw_stats =3D (u32 *) bp->stats_blk;
> + =A0 =A0 =A0 u32 *temp_stats =3D (u32 *) bp->temp_stats_blk;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 /* The 1st 10 counters are 64-bit counters */
> + =A0 =A0 =A0 for (i =3D 0; i < 20; i +=3D 2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 hi;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 lo;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hi =3D *(temp_stats + i) + *(hw_stats +=
 i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo =3D *(temp_stats + i + 1) + *(hw_sta=
ts + i + 1);

The rhs of the assignment above will always have type u32,
because temp_stats and hw_stats have type pointer to u32.
Would need to cast before doing the addition, otherwise
declaring lo as u64 is not doing anything.

I think it would also be more readable to use array indexing
notation in various places.  For example:
  hi =3D temp_stats[i] + hs_stats[i];
  lo =3D (u64)temp_stats[i + 1] + (u64)hw_stats[i + 1];

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lo > 0xffffffff)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hi++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *(temp_stats + i) =3D hi;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *(temp_stats + i + 1) =3D lo & 0xffffff=
ff;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 for ( ; i < sizeof(struct statistics_block) / 4; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *(temp_stats + i) =3D *(temp_stats + i)=
 + *(hw_stats + i);
> +}
>

-- PR
