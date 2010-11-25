From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 1/1] NET: wan/x25_asy, move lapb_unregister to x25_asy_close_tty
Date: Thu, 25 Nov 2010 22:37:44 +1100
Message-ID: <AANLkTi=DEHOKkrvzHUBnW+rAkGz-uhizRqZb2PAuh4k-@mail.gmail.com>
References: <1290642894-4577-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, slapin@ossfans.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290642894-4577-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry I haven't used this driver so can't fully test it. Looks
straightforward and compile tested ok.

On Thu, Nov 25, 2010 at 10:54 AM, Jiri Slaby <jslaby@suse.cz> wrote:
> We register lapb when tty is created, but unregister it only when the
> device is UP. So move the lapb_unregister to x25_asy_close_tty after
> the device is down.
>
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Reported-by: Sergey Lapin <slapin@ossfans.org>
> Cc: Andrew Hendry <andrew.hendry@gmail.com>
> ---
> =A0drivers/net/wan/x25_asy.c | =A0 11 ++++++-----
> =A01 files changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
> index 66cda25..24297b2 100644
> --- a/drivers/net/wan/x25_asy.c
> +++ b/drivers/net/wan/x25_asy.c
> @@ -498,7 +498,6 @@ norbuff:
> =A0static int x25_asy_close(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct x25_asy *sl =3D netdev_priv(dev);
> - =A0 =A0 =A0 int err;
>
> =A0 =A0 =A0 =A0spin_lock(&sl->lock);
> =A0 =A0 =A0 =A0if (sl->tty)
> @@ -507,10 +506,6 @@ static int x25_asy_close(struct net_device *dev)
> =A0 =A0 =A0 =A0netif_stop_queue(dev);
> =A0 =A0 =A0 =A0sl->rcount =3D 0;
> =A0 =A0 =A0 =A0sl->xleft =A0=3D 0;
> - =A0 =A0 =A0 err =3D lapb_unregister(dev);
> - =A0 =A0 =A0 if (err !=3D LAPB_OK)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "x25_asy_close: lapb_un=
register error -%d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err);
> =A0 =A0 =A0 =A0spin_unlock(&sl->lock);
> =A0 =A0 =A0 =A0return 0;
> =A0}
> @@ -595,6 +590,7 @@ static int x25_asy_open_tty(struct tty_struct *tt=
y)
> =A0static void x25_asy_close_tty(struct tty_struct *tty)
> =A0{
> =A0 =A0 =A0 =A0struct x25_asy *sl =3D tty->disc_data;
> + =A0 =A0 =A0 int err;
>
> =A0 =A0 =A0 =A0/* First make sure we're connected. */
> =A0 =A0 =A0 =A0if (!sl || sl->magic !=3D X25_ASY_MAGIC)
> @@ -605,6 +601,11 @@ static void x25_asy_close_tty(struct tty_struct =
*tty)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_close(sl->dev);
> =A0 =A0 =A0 =A0rtnl_unlock();
>
> + =A0 =A0 =A0 err =3D lapb_unregister(sl->dev);
> + =A0 =A0 =A0 if (err !=3D LAPB_OK)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "x25_asy_close: lapb_un=
register error -%d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err);
> +
> =A0 =A0 =A0 =A0tty->disc_data =3D NULL;
> =A0 =A0 =A0 =A0sl->tty =3D NULL;
> =A0 =A0 =A0 =A0x25_asy_free(sl);
> --
> 1.7.3.1
>
>
>
