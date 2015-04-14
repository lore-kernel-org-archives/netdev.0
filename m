From: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] hso: fix refcnt leak in recent patch.
Date: Tue, 14 Apr 2015 08:50:01 +0200
Message-ID: <20150414065001.GA23791@thinkoso.home>
References: <20150414093634.4fe24ba3@notabene.brown>
 <20150414110303.66edcfee@notabene.brown>
Reply-To: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	GTA04 owners <gta04-owner-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
To: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150414110303.66edcfee-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Neil,

On Tue, Apr 14, 2015 at 11:03:03AM +1000, NeilBrown wrote:
> On Tue, 14 Apr 2015 09:36:34 +1000 NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org> wrote:
> 
> > 
> > 
> > Prior to
> > commit 29bd3bc1194c624ce863cab2a7da9bc1f0c3b47b
> >     hso: fix crash when device disappears while serial port is open
> > 
> > hso_serial_open would always kref_get(&serial->parent->ref) before
> > returning zero.
> > Since that commit, it only calls kref_get when returning 0 if
> > serial->port.count was zero.
> > 
> > This results in calls to
> >        kref_put(&serial->parent->ref, hso_serial_ref_free);
> > 
> > after hso_serial_ref_free has been called, which dereferences a freed
> > pointer.
> > 
> > This patch adds the missing kref_get().
> > 
> > Fixes: commit 29bd3bc1194c624ce863cab2a7da9bc1f0c3b47b
> > Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (v4.0)
> > Cc: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
> > Signed-off-by: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
> > 
> > diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> > index 75befc1bd816..6848fc903340 100644
> > --- a/drivers/net/usb/hso.c
> > +++ b/drivers/net/usb/hso.c
> > @@ -1299,6 +1299,7 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
> >  		}
> >  	} else {
> >  		D1("Port was already open");
> > +		kref_get(&serial->parent->ref);
> >  	}
> >  
> >  	usb_autopm_put_interface(serial->parent->interface);
> 
> 
> Sorry - that was wrong.
> I'm getting crashes which strongly suggest the kref_put is being called extra
> times, but I misunderstood the code and was hasty.
> 
> Maybe this instead?

Indeed, if I undestand correctly the code in tty_io.c, cleanup() method
is also called when the open fails while kref_get is only done if the
open succeeds. Sorry for that mess.
I assume you get that crash when hso_start_serial_device() returns
an error?

At first sight, the patch below looks good to me.
I'll test it in the next days.

Thank you,

Olivier

> 
> Thanks,
> NeilBrown
> 
> From: NeilBrown <neil-+NVA1uvv1dVBDLzU/O5InQ@public.gmane.org>
> Date: Tue, 14 Apr 2015 09:33:03 +1000
> Subject: [PATCH] hso: fix refcnt leak in recent patch.
> 
> Prior to
> commit 29bd3bc1194c624ce863cab2a7da9bc1f0c3b47b
>     hso: fix crash when device disappears while serial port is open
> 
> a kref_get on serial->parent->ref would be taken on each open,
> and it would be kref_put on each close.
> 
> Now the kref_put happens when the tty_struct is finally put (via
> the 'cleanup') providing tty->driver_data has been set.
> So the kref_get must be called exact once when tty->driver_data is
> set.
> 
> With the current code, if the first open fails the kref_get() is never
> called, but the kref_put() is called, leaving to a crash.
> 
> So change the kref_get call to happen exactly when ->driver_data is
> changed from NULL to non-NULL.
> 
> Fixes: commit 29bd3bc1194c624ce863cab2a7da9bc1f0c3b47b
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (v4.0)
> Cc: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
> Signed-off-by: NeilBrown <neil-+NVA1uvv1dVBDLzU/O5InQ@public.gmane.org>
> 
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 75befc1bd816..17fd3820263a 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -1278,6 +1278,8 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
>  	D1("Opening %d", serial->minor);
>  
>  	/* setup */
> +	if (tty->driver_data == NULL)
> +		kref_get(&serial->parent->ref);
>  	tty->driver_data = serial;
>  	tty_port_tty_set(&serial->port, tty);
>  
> @@ -1294,8 +1296,6 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
>  		if (result) {
>  			hso_stop_serial_device(serial->parent);
>  			serial->port.count--;
> -		} else {
> -			kref_get(&serial->parent->ref);
>  		}
>  	} else {
>  		D1("Port was already open");



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
