From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] ppp: lock ppp->flags in ppp_read() and ppp_poll()
Date: Mon, 29 Feb 2016 10:18:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D41110082@AcuExch.aculab.com>
References: <c7c10511f505342837d57e9bb628fb145504f3e6.1456507305.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: 'Guillaume Nault' <g.nault@alphalink.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.191]:58920 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307AbcB2KVf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 05:21:35 -0500
In-Reply-To: <c7c10511f505342837d57e9bb628fb145504f3e6.1456507305.git.g.nault@alphalink.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault
> Sent: 26 February 2016 17:46
> 
> ppp_read() and ppp_poll() can be called concurrently with ppp_ioctl().
> In this case, ppp_ioctl() might call ppp_ccp_closed(), which may update
> ppp->flags while ppp_read() or ppp_poll() is reading it.
> The update done by ppp_ccp_closed() isn't atomic due to the bit mask
> operation ('ppp->flags &= ~(SC_CCP_OPEN | SC_CCP_UP)'), so concurrent
> readers might get transient values.
> Reading incorrect ppp->flags may disturb the 'ppp->flags & SC_LOOP_TRAFFIC'
> test in ppp_read() and ppp_poll(), which in turn can lead to improper
> decision on whether the PPP unit file is ready for reading or not.
> 
> Since ppp_ccp_closed() is protected by the Rx and Tx locks (with
> ppp_lock()), taking the Rx lock is enough for ppp_read() and ppp_poll()
> to guarantee that ppp_ccp_closed() won't update ppp->flags
> concurrently.

This is all splurious.
The 'concurrent' calls cannot be distinguished from calls just prior to,
or just after the ppp_ccp_closed() call.

So the additional locking (which is covering a single memory read)
cannot be needed.
Only code that modifies the flags needs to be locked.

	David

> The same reasoning applies to ppp->n_channels. The 'n_channels' field
> can also be written to concurrently by ppp_ioctl() (through
> ppp_connect_channel() or ppp_disconnect_channel()). These writes aren't
> atomic (simple increment/decrement), but are protected by both the Rx
> and Tx locks (like in the ppp->flags case). So holding the Rx lock
> before reading ppp->n_channels also prevents concurrent writes.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> ---
> 
> This was patch #2 of the 'ppp: fix locking issues related to ppp_ioctl()'
> series. I haven't kept the extra locking of ppp->flags in
> ppp_ioctl(PPPIOCGFLAGS), which was added in the original series,
> because the ppp_mutex lock ensures we can't enter the PPPIOCSFLAGS case
> concurrently.
> This is still quite theoretical issue as I've never observed the error
> in practice.
> 
>  drivers/net/ppp/ppp_generic.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index fc8ad00..e8a5936 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -443,9 +443,14 @@ static ssize_t ppp_read(struct file *file, char __user *buf,
>  			 * network traffic (demand mode).
>  			 */
>  			struct ppp *ppp = PF_TO_PPP(pf);
> +
> +			ppp_recv_lock(ppp);
>  			if (ppp->n_channels == 0 &&
> -			    (ppp->flags & SC_LOOP_TRAFFIC) == 0)
> +			    (ppp->flags & SC_LOOP_TRAFFIC) == 0) {
> +				ppp_recv_unlock(ppp);
>  				break;
> +			}
> +			ppp_recv_unlock(ppp);
>  		}
>  		ret = -EAGAIN;
>  		if (file->f_flags & O_NONBLOCK)
> @@ -532,9 +537,12 @@ static unsigned int ppp_poll(struct file *file, poll_table *wait)
>  	else if (pf->kind == INTERFACE) {
>  		/* see comment in ppp_read */
>  		struct ppp *ppp = PF_TO_PPP(pf);
> +
> +		ppp_recv_lock(ppp);
>  		if (ppp->n_channels == 0 &&
>  		    (ppp->flags & SC_LOOP_TRAFFIC) == 0)
>  			mask |= POLLIN | POLLRDNORM;
> +		ppp_recv_unlock(ppp);
>  	}
> 
>  	return mask;
> --
> 2.7.0
