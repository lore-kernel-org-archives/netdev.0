From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net:  Ensure tx watchdog failures always print.
Date: Tue, 14 Jun 2011 19:14:27 +0200
Message-ID: <1308071667.4870.17.camel@edumazet-laptop>
References: <1308070213-13244-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41219 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420Ab1FNROh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 13:14:37 -0400
Received: by vxi39 with SMTP id 39so4622442vxi.19
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2011 10:14:36 -0700 (PDT)
In-Reply-To: <1308070213-13244-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 juin 2011 =C3=A0 09:50 -0700, greearb@candelatech.com a =C3=
=A9crit :
> From: Ben Greear <greearb@candelatech.com>
>=20
> These are too important to not have some log message
> generated.  But, keep the logic that only prints
> a single stack dump.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 90939ba... fce5558... M	net/sched/sch_generic.c
>  net/sched/sch_generic.c |   16 ++++++++++++++--
>  1 files changed, 14 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 90939ba..fce5558 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -252,8 +252,20 @@ static void dev_watchdog(unsigned long arg)
> =20
>  			if (some_queue_timedout) {
>  				char drivername[64];
> -				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue=
 %u timed out\n",
> -				       dev->name, netdev_drivername(dev, drivername, 64), i);
> +				static bool do_once =3D true;
> +				printk(KERN_INFO "NETDEV WATCHDOG: %s (%s):"
> +				       " transmit queue %u timed out,"
> +				       " trans_start: %lu, wd-timeout: %i"
> +				       " jiffies: %lu tx-queues: %i\n",
> +				       dev->name,
> +				       netdev_drivername(dev, drivername, 64),
> +				       i,
> +				       trans_start, dev->watchdog_timeo,
> +				       jiffies, dev->num_tx_queues);
> +				if (do_once) {
> +					do_once =3D false;
> +					WARN_ON(1);

You could use WARN_ON_ONCE(1) here=20

> +				}
>  				dev->netdev_ops->ndo_tx_timeout(dev);
>  			}
>  			if (!mod_timer(&dev->watchdog_timer,


