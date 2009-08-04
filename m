From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 3/5] Add common socket helpers to unify the security
	hooks
Date: Tue, 4 Aug 2009 14:20:36 -0500
Message-ID: <20090804192036.GC10275@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:56688 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933322AbZHDTUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 15:20:36 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n74JIksb032096
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 13:18:46 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n74JKaUq213096
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 13:20:36 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n74JKZQe007960
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 13:20:36 -0600
Content-Disposition: inline
In-Reply-To: <1249331463-11887-4-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> This moves the meat out of the bind(), getsockname(), and getpeername() syscalls
> into helper functions that performs security_socket_bind() and then the
> sock->ops->call().  This allows a unification of this behavior between the
> syscalls and the pending socket restart logic.
> 
> Signed-off-by: Dan Smith <danms@us.ibm.com>
> Cc: netdev@vger.kernel.org
> ---
>  include/net/sock.h |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  net/socket.c       |   29 ++++++-----------------------
>  2 files changed, 54 insertions(+), 23 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 2c0da92..43b9599 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1572,6 +1572,54 @@ extern void sock_enable_timestamp(struct sock *sk, int flag);
>  extern int sock_get_timestamp(struct sock *, struct timeval __user *);
>  extern int sock_get_timestampns(struct sock *, struct timespec __user *);
> 
> +/* bind() helper shared between any callers needing to perform a bind on
> + * behalf of userspace (syscall and restart) with the security hooks.
> + */
> +static inline int sock_bind(struct socket *sock,
> +			    struct sockaddr *addr,
> +			    int addr_len)
> +{
> +	int err;
> +
> +	err = security_socket_bind(sock, addr, addr_len);
> +	if (err)
> +		return err;
> +	else
> +		return sock->ops->bind(sock, addr, addr_len);
> +}
> +
> +/* getname() helper shared between any callers needing to perform a getname on
> + * behalf of userspace (syscall and restart) with the security hooks.
> + */
> +static inline int sock_getname(struct socket *sock,
> +			       struct sockaddr *addr,
> +			       int *addr_len)
> +{
> +	int err;
> +
> +	err = security_socket_getsockname(sock);
> +	if (err)
> +		return err;
> +	else
> +		return sock->ops->getname(sock, addr, addr_len, 0);

My only concern here is whether 0 should be passed in by the caller?
(Not sure, just wondering)

Otherwise this looks good, thanks.

Acked-by: Serge Hallyn <serue@us.ibm.com>

> +}
> +
> +/* getpeer() helper shared between any callers needing to perform a getpeer on
> + * behalf of userspace (syscall and restart) with the security hooks.
> + */
> +static inline int sock_getpeer(struct socket *sock,
> +			       struct sockaddr *addr,
> +			       int *addr_len)
> +{
> +	int err;
> +
> +	err = security_socket_getpeername(sock);
> +	if (err)
> +		return err;
> +	else
> +		return sock->ops->getname(sock, addr, addr_len, 1);
> +}
> +
>  /* 
>   *	Enable debug/info messages 
>   */
> diff --git a/net/socket.c b/net/socket.c
> index 791d71a..65e7698 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1414,15 +1414,10 @@ SYSCALL_DEFINE3(bind, int, fd, struct sockaddr __user *, umyaddr, int, addrlen)
>  	sock = sockfd_lookup_light(fd, &err, &fput_needed);
>  	if (sock) {
>  		err = move_addr_to_kernel(umyaddr, addrlen, (struct sockaddr *)&address);
> -		if (err >= 0) {
> -			err = security_socket_bind(sock,
> -						   (struct sockaddr *)&address,
> -						   addrlen);
> -			if (!err)
> -				err = sock->ops->bind(sock,
> -						      (struct sockaddr *)
> -						      &address, addrlen);
> -		}
> +		if (err >= 0)
> +			err = sock_bind(sock,
> +					(struct sockaddr *)&address,
> +					addrlen);
>  		fput_light(sock->file, fput_needed);
>  	}
>  	return err;
> @@ -1610,11 +1605,7 @@ SYSCALL_DEFINE3(getsockname, int, fd, struct sockaddr __user *, usockaddr,
>  	if (!sock)
>  		goto out;
> 
> -	err = security_socket_getsockname(sock);
> -	if (err)
> -		goto out_put;
> -
> -	err = sock->ops->getname(sock, (struct sockaddr *)&address, &len, 0);
> +	err = sock_getname(sock, (struct sockaddr *)&address, &len);
>  	if (err)
>  		goto out_put;
>  	err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr, usockaddr_len);
> @@ -1639,15 +1630,7 @@ SYSCALL_DEFINE3(getpeername, int, fd, struct sockaddr __user *, usockaddr,
> 
>  	sock = sockfd_lookup_light(fd, &err, &fput_needed);
>  	if (sock != NULL) {
> -		err = security_socket_getpeername(sock);
> -		if (err) {
> -			fput_light(sock->file, fput_needed);
> -			return err;
> -		}
> -
> -		err =
> -		    sock->ops->getname(sock, (struct sockaddr *)&address, &len,
> -				       1);
> +		err = sock_getpeer(sock, (struct sockaddr *)&address, &len);
>  		if (!err)
>  			err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr,
>  						usockaddr_len);
> -- 
> 1.6.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
