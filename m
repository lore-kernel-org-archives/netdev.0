From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fix deadlock between boomerang_interrupt and
 boomerang_start_tx in 3c59x
Date: Mon, 23 Aug 2010 22:01:34 +0200
Message-ID: <1282593694.2378.230.camel@edumazet-laptop>
References: <20100811151257.GB23317@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52018 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621Ab0HWUBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 16:01:38 -0400
Received: by wwe15 with SMTP id 15so576425wwe.1
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 13:01:37 -0700 (PDT)
In-Reply-To: <20100811151257.GB23317@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 11 ao=C3=BBt 2010 =C3=A0 11:12 -0400, Neil Horman a =C3=A9c=
rit :
> If netconsole is in use, there is a possibility for deadlock in 3c59x=
 between
> boomerang_interrupt and boomerang_start_xmit.  Both routines take the=
 vp->lock,
> and if netconsole is in use, a pr_* call from the boomerang_interrupt=
 routine
> will result in the netconsole code attempting to trnasmit an skb, whi=
ch can try
> to take the same spin lock, resulting in deadlock.
>=20
> The fix is pretty straightforward.  This patch allocats a bit in the =
3c59x
> private structure to indicate that its handling an interrupt.  If we =
get into
> the transmit routine and that bit is set, we can be sure that we have=
 recursed
> and will deadlock if we continue, so instead we just return NETDEV_TX=
_BUSY, so
> the stack requeues the skb to try again later.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> ---
>  drivers/net/3c59x.c |   15 ++++++++++++++-
>  1 files changed, 14 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> index c754d88..c685a55 100644
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
> @@ -633,7 +633,8 @@ struct vortex_private {
>  		open:1,
>  		medialock:1,
>  		must_free_region:1,				/* Flag: if zero, Cardbus owns the I/O regi=
on */
> -		large_frames:1;			/* accept large frames */
> +		large_frames:1,			/* accept large frames */
> +		handling_irq:1;			/* private in_irq indicator */


It would be safer and faster to use a dedicated 'int' instead of a
bitfield.



