From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 1/3] ser_gigaset: fix up NULL checks
Date: Tue, 08 Dec 2015 20:45:13 +0100
Message-ID: <1449603913.2384.16.camel@tiscali.nl>
References: <cover.1449570042.git.tilman@imap.cc>
	 <ed83fae92c8c56e659f59c9a3709c86bd3a7d0c4.1449570042.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ed83fae92c8c56e659f59c9a3709c86bd3a7d0c4.1449570042.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tilman,

On di, 2015-12-08 at 12:00 +0100, Tilman Schmidt wrote:
> Commit f34d7a5b changed tty->driver to tty->ops but left NULL checks

(This makes checkpatch complain, but the correct commit description
style is used in the Fixes: tag, so it's not a big deal.)

> for tty->driver untouched. Fix.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> Fixes: f34d7a5b7010 ("tty: The big operations rework")

Should we backport this all the way to v2.6.32 (currently the oldest
stable tree)?

> diff --git a/drivers/isdn/gigaset/ser-gigaset.c
> b/drivers/isdn/gigaset/ser-gigaset.c
> index 375be50..d8771b5 100644
> --- a/drivers/isdn/gigaset/ser-gigaset.c
> +++ b/drivers/isdn/gigaset/ser-gigaset.c
> @@ -67,7 +67,7 @@ static int write_modem(struct cardstate *cs)
>  	struct sk_buff *skb = bcs->tx_skb;
>  	int sent = -EOPNOTSUPP;
>  
> -	if (!tty || !tty->driver || !skb)
> +	if (!tty || !tty->ops || !skb)
>  		return -EINVAL;
>  
>  	if (!skb->len) {
> @@ -109,7 +109,7 @@ static int send_cb(struct cardstate *cs)
>  	unsigned long flags;
>  	int sent = 0;
>  
> -	if (!tty || !tty->driver)
> +	if (!tty || !tty->ops)
>  		return -EFAULT;
>  
>  	cb = cs->cmdbuf;
> @@ -432,7 +432,7 @@ static int gigaset_set_modem_ctrl(struct cardstate
> *cs, unsigned old_state,
>  	struct tty_struct *tty = cs->hw.ser->tty;
>  	unsigned int set, clear;
>  
> -	if (!tty || !tty->driver || !tty->ops->tiocmset)
> +	if (!tty || !tty->ops || !tty->ops->tiocmset)
>  		return -EINVAL;
>  	set = new_state & ~old_state;
>  	clear = old_state & ~new_state;

It's pretty obvious that this should have been part of commit
 f34d7a5b7010 ("tty: The big operations rework"). That being said, these
test puzzle me. It's not obvious why they're needed. Ie, can the null
dereferences they try to catch really happen? But I can try to figure
out that in the future, if I ever feel the urge to do so. Anyhow:

Acked-by: Paul Bolle <pebolle@tiscali.nl>


Paul Bolle
