From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH v5 25/44] tty: Fix recursive deadlock in
 tty_perform_flush()
Date: Mon, 11 Mar 2013 17:36:53 -0400
Message-ID: <1363037813.27803.12.camel@thor.lan>
References: <1361390599-15195-1-git-send-email-peter@hurleysoftware.com>
	 <1363034704-28036-1-git-send-email-peter@hurleysoftware.com>
	 <1363034704-28036-26-git-send-email-peter@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>,
	Sasha Levin <levinsasha928@gmail.com>,
	Dave Jones <davej@redhat.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Shawn Guo <shawn.guo@linaro.org>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout01.c08.mtsvc.net ([205.186.168.189]:35533 "EHLO
	mailout01.c08.mtsvc.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754704Ab3CKVhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 17:37:12 -0400
In-Reply-To: <1363034704-28036-26-git-send-email-peter@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ +cc Paul Mackerras, linux-ppp, netdev ]

I neglected to cc the proper folks. Sorry about that.

Regards,
Peter Hurley

On Mon, 2013-03-11 at 16:44 -0400, Peter Hurley wrote:
> tty_perform_flush() can deadlock when called while holding
> a line discipline reference. By definition, all ldisc drivers
> hold a ldisc reference, so calls originating from ldisc drivers
> must not block for a ldisc reference.
> 
> The deadlock can occur when:
>   CPU 0                    |  CPU 1
>                            |
> tty_ldisc_ref(tty)         |
> ....                       | <line discipline halted>
> tty_ldisc_ref_wait(tty)    |
>                            |
> 
> CPU 0 cannot progess because it cannot obtain an ldisc reference
> with the line discipline has been halted (thus no new references
> are granted).
> CPU 1 cannot progress because an outstanding ldisc reference
> has not been released.
> 
> An in-tree call-tree audit of tty_perform_flush() [1] shows 5
> ldisc drivers calling tty_perform_flush() indirectly via
> n_tty_ioctl_helper() and 2 ldisc drivers calling directly.
> A single tty driver safely uses the function.
> 
> [1]
> Recursive usage:
> 
> /* These functions are line discipline ioctls and thus
>  * recursive wrt line discipline references */
> 
> tty_perform_flush() - ./drivers/tty/tty_ioctl.c
>     n_tty_ioctl_helper()
>         hci_uart_tty_ioctl(default) - drivers/bluetooth/hci_ldisc.c (N_HCI)
>         n_hdlc_tty_ioctl(default) - drivers/tty/n_hdlc.c (N_HDLC)
>         gsmld_ioctl(default) - drivers/tty/n_gsm.c (N_GSM0710)
>         n_tty_ioctl(default) - drivers/tty/n_tty.c (N_TTY)
>         gigaset_tty_ioctl(default) - drivers/isdn/gigaset/ser-gigaset.c (N_GIGASET_M101)
>     ppp_synctty_ioctl(TCFLSH) - drivers/net/ppp/pps_synctty.c
>     ppp_asynctty_ioctl(TCFLSH) - drivers/net/ppp/ppp_async.c
> 
> Non-recursive use:
> 
> tty_perform_flush() - drivers/tty/tty_ioctl.c
>     ipw_ioctl(TCFLSH) - drivers/tty/ipwireless/tty.c
>        /* This function is a tty i/o ioctl method, which
>         * is invoked by tty_ioctl() */
> 
> Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
> ---
>  drivers/net/ppp/ppp_async.c   |  2 +-
>  drivers/net/ppp/ppp_synctty.c |  2 +-
>  drivers/tty/tty_ioctl.c       | 28 +++++++++++++++++++---------
>  3 files changed, 21 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ppp/ppp_async.c b/drivers/net/ppp/ppp_async.c
> index a031f6b..9c889e0 100644
> --- a/drivers/net/ppp/ppp_async.c
> +++ b/drivers/net/ppp/ppp_async.c
> @@ -314,7 +314,7 @@ ppp_asynctty_ioctl(struct tty_struct *tty, struct file *file,
>  		/* flush our buffers and the serial port's buffer */
>  		if (arg == TCIOFLUSH || arg == TCOFLUSH)
>  			ppp_async_flush_output(ap);
> -		err = tty_perform_flush(tty, arg);
> +		err = n_tty_ioctl_helper(tty, file, cmd, arg);
>  		break;
>  
>  	case FIONREAD:
> diff --git a/drivers/net/ppp/ppp_synctty.c b/drivers/net/ppp/ppp_synctty.c
> index 1a12033..bdf3b13 100644
> --- a/drivers/net/ppp/ppp_synctty.c
> +++ b/drivers/net/ppp/ppp_synctty.c
> @@ -355,7 +355,7 @@ ppp_synctty_ioctl(struct tty_struct *tty, struct file *file,
>  		/* flush our buffers and the serial port's buffer */
>  		if (arg == TCIOFLUSH || arg == TCOFLUSH)
>  			ppp_sync_flush_output(ap);
> -		err = tty_perform_flush(tty, arg);
> +		err = n_tty_ioctl_helper(tty, file, cmd, arg);
>  		break;
>  
>  	case FIONREAD:
> diff --git a/drivers/tty/tty_ioctl.c b/drivers/tty/tty_ioctl.c
> index d58b92c..935b032 100644
> --- a/drivers/tty/tty_ioctl.c
> +++ b/drivers/tty/tty_ioctl.c
> @@ -1086,14 +1086,12 @@ int tty_mode_ioctl(struct tty_struct *tty, struct file *file,
>  }
>  EXPORT_SYMBOL_GPL(tty_mode_ioctl);
>  
> -int tty_perform_flush(struct tty_struct *tty, unsigned long arg)
> +
> +/* Caller guarantees ldisc reference is held */
> +static int __tty_perform_flush(struct tty_struct *tty, unsigned long arg)
>  {
> -	struct tty_ldisc *ld;
> -	int retval = tty_check_change(tty);
> -	if (retval)
> -		return retval;
> +	struct tty_ldisc *ld = tty->ldisc;
>  
> -	ld = tty_ldisc_ref_wait(tty);
>  	switch (arg) {
>  	case TCIFLUSH:
>  		if (ld && ld->ops->flush_buffer) {
> @@ -1111,12 +1109,24 @@ int tty_perform_flush(struct tty_struct *tty, unsigned long arg)
>  		tty_driver_flush_buffer(tty);
>  		break;
>  	default:
> -		tty_ldisc_deref(ld);
>  		return -EINVAL;
>  	}
> -	tty_ldisc_deref(ld);
>  	return 0;
>  }
> +
> +int tty_perform_flush(struct tty_struct *tty, unsigned long arg)
> +{
> +	struct tty_ldisc *ld;
> +	int retval = tty_check_change(tty);
> +	if (retval)
> +		return retval;
> +
> +	ld = tty_ldisc_ref_wait(tty);
> +	retval = __tty_perform_flush(tty, arg);
> +	if (ld)
> +		tty_ldisc_deref(ld);
> +	return retval;
> +}
>  EXPORT_SYMBOL_GPL(tty_perform_flush);
>  
>  int n_tty_ioctl_helper(struct tty_struct *tty, struct file *file,
> @@ -1155,7 +1165,7 @@ int n_tty_ioctl_helper(struct tty_struct *tty, struct file *file,
>  		}
>  		return 0;
>  	case TCFLSH:
> -		return tty_perform_flush(tty, arg);
> +		return __tty_perform_flush(tty, arg);
>  	default:
>  		/* Try the mode commands */
>  		return tty_mode_ioctl(tty, file, cmd, arg);
