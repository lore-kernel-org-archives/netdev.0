From: "Jann Traschewski" <jann@gmx.de>
Subject: Re: [PATCH][AX25] ax25_ds_timer: use mod_timer instead of add_timer
Date: Sun, 10 Feb 2008 19:23:24 +0100
Message-ID: <000801c86c12$076bde20$453c822c@dg8ngn>
References: <20080206074529.GC4496@ff.dom.local> <20080206081509.GD4496@ff.dom.local> <20080206091413.GE4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Ralf Baechle'" <ralf@linux-mips.org>,
	"'David Miller'" <davem@davemloft.net>
To: "'Jarek Poplawski'" <jarkao2@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:52301 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751934AbYBJSX3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 13:23:29 -0500
In-Reply-To: <20080206091413.GE4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches from Jarek applied (incl. both "testing" patches). Machine is s=
table
since 2 days now.
Regards,
Jann

> -----Urspr=FCngliche Nachricht-----
> Von: Jarek Poplawski [mailto:jarkao2@gmail.com]=20
> Gesendet: Mittwoch, 6. Februar 2008 10:14
> An: netdev@vger.kernel.org
> Cc: Ralf Baechle; Jann Traschewski; David Miller
> Betreff: [PATCH][AX25] ax25_ds_timer: use mod_timer instead=20
> of add_timer
>=20
> On Wed, Feb 06, 2008 at 08:15:09AM +0000, Jarek Poplawski wrote:
> > On Wed, Feb 06, 2008 at 07:45:29AM +0000, Jarek Poplawski wrote:
> > ...
> > > From: Jann Traschewski <jann@gmx.de>
> > > Subject: SMP with AX.25
> ...
>=20
>=20
> [AX25] ax25_ds_timer: use mod_timer instead of add_timer
>=20
> This patch changes current use of: init_timer(), add_timer()=20
> and del_timer() to setup_timer() with mod_timer(), which=20
> should be safer anyway.
>=20
>=20
> Reported-by: Jann Traschewski <jann@gmx.de>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>=20
> ---
>=20
>  include/net/ax25.h       |    1 +
>  net/ax25/ax25_dev.c      |    2 +-
>  net/ax25/ax25_ds_timer.c |   12 ++++--------
>  3 files changed, 6 insertions(+), 9 deletions(-)
>=20
> diff --git a/include/net/ax25.h b/include/net/ax25.h index=20
> 3f0236f..717e219 100644
> --- a/include/net/ax25.h
> +++ b/include/net/ax25.h
> @@ -324,6 +324,7 @@ extern void ax25_dama_on(ax25_cb *); =20
> extern void ax25_dama_off(ax25_cb *);
> =20
>  /* ax25_ds_timer.c */
> +extern void ax25_ds_setup_timer(ax25_dev *);
>  extern void ax25_ds_set_timer(ax25_dev *);  extern void=20
> ax25_ds_del_timer(ax25_dev *);  extern void=20
> ax25_ds_timer(ax25_cb *); diff --git a/net/ax25/ax25_dev.c=20
> b/net/ax25/ax25_dev.c index 528c874..a7a0e0c 100644
> --- a/net/ax25/ax25_dev.c
> +++ b/net/ax25/ax25_dev.c
> @@ -82,7 +82,7 @@ void ax25_dev_device_up(struct net_device *dev)
>  	ax25_dev->values[AX25_VALUES_DS_TIMEOUT]=3D AX25_DEF_DS_TIMEOUT;
> =20
>  #if defined(CONFIG_AX25_DAMA_SLAVE) ||=20
> defined(CONFIG_AX25_DAMA_MASTER)
> -	init_timer(&ax25_dev->dama.slave_timer);
> +	ax25_ds_setup_timer(ax25_dev);
>  #endif
> =20
>  	spin_lock_bh(&ax25_dev_lock);
> diff --git a/net/ax25/ax25_ds_timer.c=20
> b/net/ax25/ax25_ds_timer.c index c4e3b02..2ce79df 100644
> --- a/net/ax25/ax25_ds_timer.c
> +++ b/net/ax25/ax25_ds_timer.c
> @@ -40,13 +40,10 @@ static void ax25_ds_timeout(unsigned long);
>   *	1/10th of a second.
>   */
> =20
> -static void ax25_ds_add_timer(ax25_dev *ax25_dev)
> +void ax25_ds_setup_timer(ax25_dev *ax25_dev)
>  {
> -	struct timer_list *t =3D &ax25_dev->dama.slave_timer;
> -	t->data		=3D (unsigned long) ax25_dev;
> -	t->function	=3D &ax25_ds_timeout;
> -	t->expires	=3D jiffies + HZ;
> -	add_timer(t);
> +	setup_timer(&ax25_dev->dama.slave_timer, ax25_ds_timeout,
> +		    (unsigned long)ax25_dev);
>  }
> =20
>  void ax25_ds_del_timer(ax25_dev *ax25_dev) @@ -60,10 +57,9=20
> @@ void ax25_ds_set_timer(ax25_dev *ax25_dev)
>  	if (ax25_dev =3D=3D NULL)		/* paranoia */
>  		return;
> =20
> -	del_timer(&ax25_dev->dama.slave_timer);
>  	ax25_dev->dama.slave_timeout =3D
>  	=09
> msecs_to_jiffies(ax25_dev->values[AX25_VALUES_DS_TIMEOUT]) / 10;
> -	ax25_ds_add_timer(ax25_dev);
> +	mod_timer(&ax25_dev->dama.slave_timer, jiffies + HZ);
>  }
> =20
>  /*

