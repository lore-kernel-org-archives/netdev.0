From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] don't allow / in class device names
Date: Fri, 13 Feb 2004 12:34:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213203448.GB14048@kroah.com>
References: <20040213102755.27cf4fcd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tommi Virtanen <tv@tv.debian.net>, Leann Ogasawara <ogasawara@osdl.org>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040213102755.27cf4fcd.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 13, 2004 at 10:27:55AM -0800, Stephen Hemminger wrote:
> 
> > [0 tv@tao /sys/class/misc]$ uname -a
> > Linux tao 2.6.2-rc2 #6 Mon Jan 26 10:54:50 EET 2004 i686 GNU/Linux
> > [0 tv@tao /sys/class/misc]$ echo *
> > intermezzo net/tun psaux rtc uinput
> > [0 tv@tao /sys/class/misc]$
> >
> > Seems like that's all because of this:
> >
> > static struct miscdevice tun_miscdev = {
> >         .minor = TUN_MINOR,
> >         .name = "net/tun",
> >         .fops = &tun_fops
> > };
> >
> > Name is apparently meant to be a filename, not a path.
> > Don't know what should be done to it; maybe
> >
> > static struct miscdevice tun_miscdev = {
> >         .minor = TUN_MINOR,
> >         .name = "tun",
> >         .fops = &tun_fops,
> >         .devfs_name = "misc/net/tun",
> > };
> >
> > But I havent tried that out.
> >
> > I'd suggest this, to flush out all the problems. Later,
> > it can be changed to return -EINVAL or BUG_ON.
> >
> > --- 1.26/drivers/char/misc.c    Thu Jan 15 13:05:56 2004
> > +++ edited/misc.c       Fri Feb 13 19:35:45 2004
> > @@ -212,6 +212,9 @@
> >  int misc_register(struct miscdevice * misc)
> >  {
> >         struct miscdevice *c;
> > +
> > +       if (misc->name && strchr(misc->name, '/'))
> > +         printk("%s: name contains slash when registering %s.\n", __func__, misc->name);
> >
> >         down(&misc_sem);
> >         list_for_each_entry(c, &misc_list, list) {
> >
> Don't fix it just for misc_register, the fix needs to go into class_device.

No, the "fix" is to just not do this in the driver.  I'm not going to
apply this patch, sorry.

thanks,

greg k-h
