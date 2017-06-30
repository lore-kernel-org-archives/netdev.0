From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH v2] sctp: Add peeloff-flags socket option
Date: Fri, 30 Jun 2017 13:29:57 -0300
Message-ID: <20170630162957.GM18138@localhost.localdomain>
References: <20170629181340.12423-1-nhorman@tuxdriver.com>
 <20170630153554.22901-1-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andreas Steinmetz <ast@domdv.de>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42540 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750975AbdF3QaC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 12:30:02 -0400
Content-Disposition: inline
In-Reply-To: <20170630153554.22901-1-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 30, 2017 at 11:35:54AM -0400, Neil Horman wrote:
> Based on a request raised on the sctp devel list, there is a need to
> augment the sctp_peeloff operation while specifying the O_CLOEXEC and
> O_NONBLOCK flags (simmilar to the socket syscall).  Since modifying the
> SCTP_SOCKOPT_PEELOFF socket option would break user space ABI for existing
> programs, this patch creates a new socket option
> SCTP_SOCKOPT_PEELOFF_FLAGS, which accepts a third flags parameter to
> allow atomic assignment of the socket descriptor flags.
> 
> Tested successfully by myself and the requestor
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Andreas Steinmetz <ast@domdv.de>
> CC: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> ---
> Change notes:
> 
> v2)
> 
> * Per Marcellos comments, move to use of get_unused_fd_flags() and
> clean up code to independently set CLOEXEC
> 
> * clean up a stray tab
> ---
>  include/uapi/linux/sctp.h |  6 ++++
>  net/sctp/socket.c         | 84 ++++++++++++++++++++++++++++++++++++++---------
>  2 files changed, 75 insertions(+), 15 deletions(-)
> 
> diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> index ced9d8b..6217ff8 100644
> --- a/include/uapi/linux/sctp.h
> +++ b/include/uapi/linux/sctp.h
> @@ -121,6 +121,7 @@ typedef __s32 sctp_assoc_t;
>  #define SCTP_RESET_STREAMS	119
>  #define SCTP_RESET_ASSOC	120
>  #define SCTP_ADD_STREAMS	121
> +#define SCTP_SOCKOPT_PEELOFF_FLAGS 122
>  
>  /* PR-SCTP policies */
>  #define SCTP_PR_SCTP_NONE	0x0000
> @@ -978,6 +979,11 @@ typedef struct {
>  	int sd;
>  } sctp_peeloff_arg_t;
>  
> +typedef struct {
> +	sctp_peeloff_arg_t p_arg;
> +	unsigned flags;
> +} sctp_peeloff_flags_arg_t;
> +
>  /*
>   *  Peer Address Thresholds socket option
>   */
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 7b6e20e..3cc5309 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4933,11 +4933,46 @@ int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
>  }
>  EXPORT_SYMBOL(sctp_do_peeloff);
>  
> +static int sctp_getsockopt_peeloff_common(struct sock *sk, sctp_peeloff_arg_t *peeloff, struct file **newfile, unsigned flags)
> +{
> +	struct socket *newsock;
> +	int retval;
> +
> +	retval = sctp_do_peeloff(sk, peeloff->associd, &newsock);
> +	if (retval < 0)
> +		goto out;
> +
> +	/* Map the socket to an unused fd that can be returned to the user.  */
> +	retval = get_unused_fd_flags(flags & SOCK_CLOEXEC);
> +	if (retval < 0) {
> +		sock_release(newsock);
> +		goto out;
> +	}
> +
> +	*newfile = sock_alloc_file(newsock, 0, NULL);
> +	if (IS_ERR(*newfile)) {
> +		put_unused_fd(retval);
> +		sock_release(newsock);
> +		retval = PTR_ERR(*newfile);
> +		*newfile = NULL;
> +		return retval;
> +	}
> +
> +	pr_debug("%s: sk:%p, newsk:%p, sd:%d\n", __func__, sk, newsock->sk,
> +		 retval);
> +
> +	peeloff->sd = retval;
> +
> +	if (flags & SOCK_NONBLOCK)
> +		(*newfile)->f_flags |= O_NONBLOCK;
> +out:
> +	return retval;
> +}
> +
>  static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval, int __user *optlen)
>  {
>  	sctp_peeloff_arg_t peeloff;
> -	struct socket *newsock;
> -	struct file *newfile;
> +	struct file *newfile = NULL;
>  	int retval = 0;
>  
>  	if (len < sizeof(sctp_peeloff_arg_t))
> @@ -4946,26 +4981,42 @@ static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval
>  	if (copy_from_user(&peeloff, optval, len))
>  		return -EFAULT;
>  
> -	retval = sctp_do_peeloff(sk, peeloff.associd, &newsock);
> +	retval = sctp_getsockopt_peeloff_common(sk, &peeloff, &newfile, 0);
>  	if (retval < 0)
>  		goto out;
>  
> -	/* Map the socket to an unused fd that can be returned to the user.  */
> -	retval = get_unused_fd_flags(0);
> -	if (retval < 0) {
> -		sock_release(newsock);
> -		goto out;
> +	/* Return the fd mapped to the new socket.  */
> +	if (put_user(len, optlen)) {
> +		fput(newfile);
> +		put_unused_fd(retval);
> +		return -EFAULT;
>  	}
>  
> -	newfile = sock_alloc_file(newsock, 0, NULL);
> -	if (IS_ERR(newfile)) {
> +	if (copy_to_user(optval, &peeloff, len)) {
> +		fput(newfile);
>  		put_unused_fd(retval);
> -		sock_release(newsock);
> -		return PTR_ERR(newfile);
> +		return -EFAULT;
>  	}
> +	fd_install(retval, newfile);
> +out:
> +	return retval;
> +}
>  
> -	pr_debug("%s: sk:%p, newsk:%p, sd:%d\n", __func__, sk, newsock->sk,
> -		 retval);
> +static int sctp_getsockopt_peeloff_flags(struct sock *sk, int len, char __user *optval, int __user *optlen)
> +{
> +	sctp_peeloff_flags_arg_t peeloff;
> +	struct file *newfile = NULL;
> +	int retval = 0;
> +
> +	if (len < sizeof(sctp_peeloff_flags_arg_t))
> +		return -EINVAL;
> +	len = sizeof(sctp_peeloff_flags_arg_t);
> +	if (copy_from_user(&peeloff, optval, len))
> +		return -EFAULT;
> +
> +	retval = sctp_getsockopt_peeloff_common(sk, &peeloff.p_arg, &newfile, peeloff.flags);

That is a long line, would be nice to break it. It fits quite well if
broken before newfile parameter.

  Marcelo

> +	if (retval < 0)
> +		goto out;
>  
>  	/* Return the fd mapped to the new socket.  */
>  	if (put_user(len, optlen)) {
> @@ -4973,7 +5024,7 @@ static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval
>  		put_unused_fd(retval);
>  		return -EFAULT;
>  	}
> -	peeloff.sd = retval;
> +
>  	if (copy_to_user(optval, &peeloff, len)) {
>  		fput(newfile);
>  		put_unused_fd(retval);
> @@ -6758,6 +6809,9 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
>  	case SCTP_SOCKOPT_PEELOFF:
>  		retval = sctp_getsockopt_peeloff(sk, len, optval, optlen);
>  		break;
> +	case SCTP_SOCKOPT_PEELOFF_FLAGS:
> +		retval = sctp_getsockopt_peeloff_flags(sk, len, optval, optlen);
> +		break;
>  	case SCTP_PEER_ADDR_PARAMS:
>  		retval = sctp_getsockopt_peer_addr_params(sk, len, optval,
>  							  optlen);
> -- 
> 2.9.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
