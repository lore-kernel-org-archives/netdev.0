From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 3/3] net: Fix security_socket_sendmsg() bypass problem.
Date: Thu, 04 Aug 2011 17:38:43 -0700
Message-ID: <4E3B3B93.3060803@schaufler-ca.com>
References: <20110805000737.743684961@samba.org> <20110805000822.408914956@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, davem@davemloft.net,
	eparis@parisplace.org, mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Casey Schaufler <casey@schaufler-ca.com>
To: Anton Blanchard <anton@samba.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110805000822.408914956@samba.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/4/2011 5:07 PM, Anton Blanchard wrote:
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>
> The sendmmsg() introduced by commit 228e548e "net: Add sendmmsg socket system
> call" is capable of sending to multiple different destination addresses.
>
> SMACK is using destination's address for checking sendmsg() permission.
> However, security_socket_sendmsg() is called for only once even if multiple
> different destination addresses are passed to sendmmsg().
>
> Therefore, we need to call security_socket_sendmsg() for each destination
> address rather than only the first destination address.
>
> Since calling security_socket_sendmsg() every time when only single destination
> address was passed to sendmmsg() is a waste of time, omit calling
> security_socket_sendmsg() unless destination address of previous datagram and
> that of current datagram differs.

Thank you.

>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Acked-off: Anton Blanchard <anton@samba.org>
> Cc: stable <stable@kernel.org> [3.0+]
> ---
>
> Index: linux-net/net/socket.c
> ===================================================================
> --- linux-net.orig/net/socket.c	2011-08-05 09:31:27.000000000 +1000
> +++ linux-net/net/socket.c	2011-08-05 09:32:46.146436405 +1000
> @@ -1871,8 +1871,14 @@ SYSCALL_DEFINE2(shutdown, int, fd, int,
>  #define COMPAT_NAMELEN(msg)	COMPAT_MSG(msg, msg_namelen)
>  #define COMPAT_FLAGS(msg)	COMPAT_MSG(msg, msg_flags)
>  
> +struct used_address {
> +	struct sockaddr_storage name;
> +	unsigned int name_len;
> +};
> +
>  static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
> -			 struct msghdr *msg_sys, unsigned flags, int nosec)
> +			 struct msghdr *msg_sys, unsigned flags,
> +			 struct used_address *used_address)
>  {
>  	struct compat_msghdr __user *msg_compat =
>  	    (struct compat_msghdr __user *)msg;
> @@ -1953,8 +1959,28 @@ static int __sys_sendmsg(struct socket *
>  
>  	if (sock->file->f_flags & O_NONBLOCK)
>  		msg_sys->msg_flags |= MSG_DONTWAIT;
> -	err = (nosec ? sock_sendmsg_nosec : sock_sendmsg)(sock, msg_sys,
> -							  total_len);
> +	/*
> +	 * If this is sendmmsg() and current destination address is same as
> +	 * previously succeeded address, omit asking LSM's decision.
> +	 * used_address->name_len is initialized to UINT_MAX so that the first
> +	 * destination address never matches.
> +	 */
> +	if (used_address && used_address->name_len == msg_sys->msg_namelen &&
> +	    !memcmp(&used_address->name, msg->msg_name,
> +		    used_address->name_len)) {
> +		err = sock_sendmsg_nosec(sock, msg_sys, total_len);
> +		goto out_freectl;
> +	}
> +	err = sock_sendmsg(sock, msg_sys, total_len);
> +	/*
> +	 * If this is sendmmsg() and sending to current destination address was
> +	 * successful, remember it.
> +	 */
> +	if (used_address && err >= 0) {
> +		used_address->name_len = msg_sys->msg_namelen;
> +		memcpy(&used_address->name, msg->msg_name,
> +		       used_address->name_len);
> +	}
>  
>  out_freectl:
>  	if (ctl_buf != ctl)
> @@ -1979,7 +2005,7 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct
>  	if (!sock)
>  		goto out;
>  
> -	err = __sys_sendmsg(sock, msg, &msg_sys, flags, 0);
> +	err = __sys_sendmsg(sock, msg, &msg_sys, flags, NULL);
>  
>  	fput_light(sock->file, fput_needed);
>  out:
> @@ -1998,6 +2024,7 @@ int __sys_sendmmsg(int fd, struct mmsghd
>  	struct mmsghdr __user *entry;
>  	struct compat_mmsghdr __user *compat_entry;
>  	struct msghdr msg_sys;
> +	struct used_address used_address;
>  
>  	if (vlen > UIO_MAXIOV)
>  		vlen = UIO_MAXIOV;
> @@ -2008,24 +2035,22 @@ int __sys_sendmmsg(int fd, struct mmsghd
>  	if (!sock)
>  		return err;
>  
> +	used_address.name_len = UINT_MAX;
>  	entry = mmsg;
>  	compat_entry = (struct compat_mmsghdr __user *)mmsg;
>  	err = 0;
>  
>  	while (datagrams < vlen) {
> -		/*
> -		 * No need to ask LSM for more than the first datagram.
> -		 */
>  		if (MSG_CMSG_COMPAT & flags) {
>  			err = __sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
> -					    &msg_sys, flags, datagrams);
> +					    &msg_sys, flags, &used_address);
>  			if (err < 0)
>  				break;
>  			err = __put_user(err, &compat_entry->msg_len);
>  			++compat_entry;
>  		} else {
>  			err = __sys_sendmsg(sock, (struct msghdr __user *)entry,
> -					    &msg_sys, flags, datagrams);
> +					    &msg_sys, flags, &used_address);
>  			if (err < 0)
>  				break;
>  			err = put_user(err, &entry->msg_len);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

