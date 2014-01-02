From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH, RFC 21/30] isdn: divert, hysdn: fix interruptible_sleep_on race
Date: Thu, 02 Jan 2014 17:48:47 +0100
Message-ID: <3610183.tucaANtxQk@wuerfel>
References: <1388664474-1710039-1-git-send-email-arnd@arndb.de> <1388664474-1710039-22-git-send-email-arnd@arndb.de> <52C57F3B.9070509@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52C57F3B.9070509@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 02 January 2014 19:01:15 Sergei Shtylyov wrote:
> > diff --git a/drivers/isdn/divert/divert_procfs.c b/drivers/isdn/divert/divert_procfs.c
> > index fb4f1ba..1c5dc34 100644
> > --- a/drivers/isdn/divert/divert_procfs.c
> > +++ b/drivers/isdn/divert/divert_procfs.c
> > @@ -86,12 +86,13 @@ isdn_divert_read(struct file *file, char __user *buf, size_t count, loff_t *off)
> >       struct divert_info *inf;
> >       int len;
> >
> > -     if (!*((struct divert_info **) file->private_data)) {
> > +     if (!(inf = *((struct divert_info **) file->private_data))) {
> 
>     checkpatch.pl shouldn't approve assignment inside *if*. Though you're 
> moving it from the existing code, it wouldn't hurt to fix it.

I tried to touch as little as possible, and while I wouldn't use that
style myself, it is applied consistently in this driver, including the
wait_event line I'm adding, where I feel it actually makes sense.

> >               if (file->f_flags & O_NONBLOCK)
> >                       return -EAGAIN;
> > -             interruptible_sleep_on(&(rd_queue));
> > +             wait_event_interruptible(rd_queue, (inf =
> > +                     *((struct divert_info **) file->private_data)));
> 
>     Parens around assignment are hardly useful.

We get a gcc warning without them:

drivers/isdn/divert/divert_procfs.c:95:14: warning: suggest parentheses around assignment used as truth value [-Wparentheses]
    *((struct divert_info **) file->private_data));


I can still change the first one (in both files) if you think it's important,
but I'd rather not spend too much energy at coding style changes.

Thanks for taking a look.

	Arnd
