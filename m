From: David Miller <davem@davemloft.net>
Subject: Re: [patch for 2.6.31? 2/2] gigaset: really fix chars_in_buffer
Date: Thu, 06 Aug 2009 20:22:27 -0700 (PDT)
Message-ID: <20090806.202227.224933454.davem@davemloft.net>
References: <200908062219.n76MJXhY024495@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tilman@imap.cc, greg@kroah.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756961AbZHGDWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 23:22:17 -0400
In-Reply-To: <200908062219.n76MJXhY024495@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 06 Aug 2009 15:19:32 -0700

> From: Tilman Schmidt <tilman@imap.cc>
> 
> The tty_operation chars_in_buffer() is not allowed to return a negative
> value to signal an error.  Corrects the problem flagged by commit
> 23198fda7182969b619613a555f8645fdc3dc334, "tty: fix chars_in_buffers".
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I was letting Alan Cox handle changes in this area since it's
TTY stuff, and thus it probably should go to the new TTY
mad man, CC:'d :-)

> ---
> 
>  drivers/isdn/gigaset/interface.c |   19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)
> 
> diff -puN drivers/isdn/gigaset/interface.c~gigaset-really-fix-chars_in_buffer drivers/isdn/gigaset/interface.c
> --- a/drivers/isdn/gigaset/interface.c~gigaset-really-fix-chars_in_buffer
> +++ a/drivers/isdn/gigaset/interface.c
> @@ -408,33 +408,28 @@ static int if_write_room(struct tty_stru
>  	return retval;
>  }
>  
> -/* FIXME: This function does not have error returns */
> -
>  static int if_chars_in_buffer(struct tty_struct *tty)
>  {
>  	struct cardstate *cs;
> -	int retval = -ENODEV;
> +	int retval = 0;
>  
>  	cs = (struct cardstate *) tty->driver_data;
>  	if (!cs) {
>  		pr_err("%s: no cardstate\n", __func__);
> -		return -ENODEV;
> +		return 0;
>  	}
>  
>  	gig_dbg(DEBUG_IF, "%u: %s()", cs->minor_index, __func__);
>  
> -	if (mutex_lock_interruptible(&cs->mutex))
> -		return -ERESTARTSYS; // FIXME -EINTR?
> +	mutex_lock(&cs->mutex);
>  
> -	if (!cs->connected) {
> +	if (!cs->connected)
>  		gig_dbg(DEBUG_IF, "not connected");
> -		retval = -ENODEV;
> -	} else if (!cs->open_count)
> +	else if (!cs->open_count)
>  		dev_warn(cs->dev, "%s: device not opened\n", __func__);
> -	else if (cs->mstate != MS_LOCKED) {
> +	else if (cs->mstate != MS_LOCKED)
>  		dev_warn(cs->dev, "can't write to unlocked device\n");
> -		retval = -EBUSY;
> -	} else
> +	else
>  		retval = cs->ops->chars_in_buffer(cs);
>  
>  	mutex_unlock(&cs->mutex);
> _
