From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] net: sctp: fix bug in sctp_poll for
 SOCK_SELECT_ERR_QUEUE
Date: Sun, 8 Sep 2013 08:07:45 -0400
Message-ID: <20130908120744.GA16269@neilslaptop.think-freely.org>
References: <1378565099-20987-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Jacob Keller <jacob.e.keller@intel.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50483 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab3IHMHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Sep 2013 08:07:55 -0400
Content-Disposition: inline
In-Reply-To: <1378565099-20987-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 07, 2013 at 04:44:59PM +0200, Daniel Borkmann wrote:
> If we do not add braces around ...
> 
>   mask |= POLLERR |
>           sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
> 
> ... then this condition always evaluates to true as POLLERR is
> defined as 8 and binary or'd with whatever result comes out of
> sock_flag(). Hence instead of (X | Y) ? A : B, transform it into
> X | (Y ? A : B). Unfortunatelty, commit 8facd5fb73 ("net: fix
> smatch warnings inside datagram_poll") forgot about SCTP. :-(
> 
> Introduced by 7d4c04fc170 ("net: add option to enable error queue
> packets waking select").
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> ---
>  net/sctp/socket.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index d5d5882..5462bbb 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -6176,7 +6176,7 @@ unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
>  	/* Is there any exceptional events?  */
>  	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
>  		mask |= POLLERR |
> -			sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
> +			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
>  	if (sk->sk_shutdown & RCV_SHUTDOWN)
>  		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
>  	if (sk->sk_shutdown == SHUTDOWN_MASK)
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
