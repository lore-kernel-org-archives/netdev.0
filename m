From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Break up the single NBD lock into one per NBD device
Date: Thu, 06 Oct 2011 21:53:43 +0200
Message-ID: <1317930823.3457.24.camel@edumazet-laptop>
References: <1317080052-6052-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53259 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935270Ab1JFTxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 15:53:47 -0400
Received: by wyg34 with SMTP id 34so3204763wyg.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 12:53:46 -0700 (PDT)
In-Reply-To: <1317080052-6052-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 septembre 2011 =C3=A0 16:34 -0700, H.K. Jerry Chu a =C3=A9c=
rit :
> From: Jerry Chu <hkchu@google.com>
>=20
> This patch breaks up the single NBD lock into one per
> disk. The single NBD lock has become a serious performance
> bottleneck when multiple NBD disks are being used.
>=20
> The original comment on why a single lock may be ok no
> longer holds for today's much faster NICs.
>=20
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
> ---
>  drivers/block/nbd.c |   22 +++++++++-------------
>  1 files changed, 9 insertions(+), 13 deletions(-)
>=20
> diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
> index f533f33..355e15c 100644
> --- a/drivers/block/nbd.c
> +++ b/drivers/block/nbd.c
> @@ -58,20 +58,9 @@ static unsigned int debugflags;
> =20
>  static unsigned int nbds_max =3D 16;
>  static struct nbd_device *nbd_dev;
> +static spinlock_t *nbd_locks;

static spinlock_t *nbd_locks __read_mostly;

>  static int max_part;
> =20
> -/*
> - * Use just one lock (or at most 1 per NIC). Two arguments for this:
> - * 1. Each NIC is essentially a synchronization point for all server=
s
> - *    accessed through that NIC so there's no need to have more lock=
s
> - *    than NICs anyway.
> - * 2. More locks lead to more "Dirty cache line bouncing" which will=
 slow
> - *    down each lock to the point where they're actually slower than=
 just
> - *    a single lock.
> - * Thanks go to Jens Axboe and Al Viro for their LKML emails explain=
ing this!
> - */
> -static DEFINE_SPINLOCK(nbd_lock);
> -
>  #ifndef NDEBUG
>  static const char *ioctl_cmd_to_ascii(int cmd)
>  {
> @@ -753,6 +742,12 @@ static int __init nbd_init(void)
>  	if (!nbd_dev)
>  		return -ENOMEM;
> =20
> +	nbd_locks =3D kcalloc(nbds_max, sizeof(*nbd_locks), GFP_KERNEL);
> +	if (!nbd_locks) {
> +		kfree(nbd_dev);
> +		return -ENOMEM;
> +	}
> +

	Please add loop to init spinlocks to help LOCKDEP...

	for (i =3D 0; i < nbds_max; i++)
		spin_lock_init(&nbd_locks[i]);

>  	part_shift =3D 0;
>  	if (max_part > 0) {
>  		part_shift =3D fls(max_part);
> @@ -784,7 +779,7 @@ static int __init nbd_init(void)
>  		 * every gendisk to have its very own request_queue struct.
>  		 * These structs are big so we dynamically allocate them.
>  		 */
> -		disk->queue =3D blk_init_queue(do_nbd_request, &nbd_lock);
> +		disk->queue =3D blk_init_queue(do_nbd_request, &nbd_locks[i]);
>  		if (!disk->queue) {
>  			put_disk(disk);
>  			goto out;
> @@ -832,6 +827,7 @@ out:
>  		put_disk(nbd_dev[i].disk);
>  	}
>  	kfree(nbd_dev);
> +	kfree(nbd_locks);
>  	return err;
>  }
> =20
