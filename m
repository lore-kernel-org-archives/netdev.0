From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH] hso: fix refcnt leak in recent patch.
Date: Thu, 16 Apr 2015 15:21:42 +0200
Message-ID: <20150416132142.GA19956@thinkoso.home>
References: <20150414093634.4fe24ba3@notabene.brown>
 <20150414110303.66edcfee@notabene.brown>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jan Dumon <j.dumon@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	GTA04 owners <gta04-owner@goldelico.com>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150414110303.66edcfee@notabene.brown>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 14, 2015 at 11:03:03AM +1000, NeilBrown wrote:
> On Tue, 14 Apr 2015 09:36:34 +1000 NeilBrown <neilb@suse.de> wrote:
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
> > Cc: stable@vger.kernel.org (v4.0)
> > Cc: Olivier Sobrie <olivier@sobrie.be>
> > Signed-off-by: NeilBrown <neilb@suse.de>
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

I tested the patch and it looks fine :-)
Thank you,
Olivier

> 
> Thanks,
> NeilBrown
> 
> From: NeilBrown <neil@brown.name>
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
> Cc: stable@vger.kernel.org (v4.0)
> Cc: Olivier Sobrie <olivier@sobrie.be>

Tested-by: Olivier Sobrie <olivier@sobrie.be>

> Signed-off-by: NeilBrown <neil@brown.name>
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
Olivier
