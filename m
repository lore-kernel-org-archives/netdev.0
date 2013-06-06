From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Unbreak compat_sys_{send,recv}msg
Date: Thu, 06 Jun 2013 00:26:25 -0700 (PDT)
Message-ID: <20130606.002625.223430401087826901.davem@davemloft.net>
References: <20130606132926.f4161ddff87dc9a55e33a8ca@canb.auug.org.au>
	<e3bf421e44c6d27817c15a8683612a49e093b419.1370496702.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: x86@kernel.org, torvalds@linux-foundation.org, mikey@neuling.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, trinity@vger.kernel.org,
	eric.dumazet@gmail.com
To: luto@amacapital.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e3bf421e44c6d27817c15a8683612a49e093b419.1370496702.git.luto@amacapital.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@amacapital.net>
Date: Wed,  5 Jun 2013 22:38:26 -0700

> I broke them in this commit:
> 
>     commit 1be374a0518a288147c6a7398792583200a67261
>     Author: Andy Lutomirski <luto@amacapital.net>
>     Date:   Wed May 22 14:07:44 2013 -0700
> 
>         net: Block MSG_CMSG_COMPAT in send(m)msg and recv(m)msg
> 
> This patch adds __sys_sendmsg and __sys_sendmsg as common helpers that accept
> MSG_CMSG_COMPAT and blocks MSG_CMSG_COMPAT at the syscall entrypoints.  It
> also reverts some unnecessary checks in sys_socketcall.
> 
> Apparently I was suffering from underscore blindness the first time around.
> 
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Eric, can you test this patch too?

Thanks.

> ---
> 
> I've tested this a little, but I'm not sure I have a great test case.
> 
> If the decision is that it's better to leave this for the 3.11, I can send
> a squashed version.  Note that the oops that this fixes is only an oops if
> the other patches in the original series are applied.
> 
> (FWIW, I wasn't sure how to submit this stuff in the first place.  I submitted
> some kernel hardening patches for the x86 tree that converted an access_ok
> oddity in the net code into an actual oops.  In a bit of looking, I couldn't
> find any failure mode other than a -EFAULT return without the other patches
> applied.  This was clear in the patch series description but not in the
> change log message for the net part.)
> 
>  include/linux/socket.h |  3 +++
>  net/compat.c           | 13 +++++++--
>  net/socket.c           | 72 +++++++++++++++++++++++---------------------------
>  3 files changed, 47 insertions(+), 41 deletions(-)
> 
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 2b9f74b..e897bdc 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -321,6 +321,9 @@ extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
>  
>  struct timespec;
>  
> +/* The __sys_...msg variants allow MSG_CMSG_COMPAT */
> +extern long __sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags);
> +extern long __sys_sendmsg(int fd, struct msghdr __user *msg, unsigned flags);
>  extern int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
>  			  unsigned int flags, struct timespec *timeout);
>  extern int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg,
> diff --git a/net/compat.c b/net/compat.c
> index 79ae884..f0a1ba6 100644
> --- a/net/compat.c
> +++ b/net/compat.c
> @@ -734,19 +734,25 @@ static unsigned char nas[21] = {
>  
>  asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user *msg, unsigned int flags)
>  {
> -	return sys_sendmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
> +	if (flags & MSG_CMSG_COMPAT)
> +		return -EINVAL;
> +	return __sys_sendmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
>  }
>  
>  asmlinkage long compat_sys_sendmmsg(int fd, struct compat_mmsghdr __user *mmsg,
>  				    unsigned int vlen, unsigned int flags)
>  {
> +	if (flags & MSG_CMSG_COMPAT)
> +		return -EINVAL;
>  	return __sys_sendmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
>  			      flags | MSG_CMSG_COMPAT);
>  }
>  
>  asmlinkage long compat_sys_recvmsg(int fd, struct compat_msghdr __user *msg, unsigned int flags)
>  {
> -	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
> +	if (flags & MSG_CMSG_COMPAT)
> +		return -EINVAL;
> +	return __sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
>  }
>  
>  asmlinkage long compat_sys_recv(int fd, void __user *buf, size_t len, unsigned int flags)
> @@ -768,6 +774,9 @@ asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __user *mmsg,
>  	int datagrams;
>  	struct timespec ktspec;
>  
> +	if (flags & MSG_CMSG_COMPAT)
> +		return -EINVAL;
> +
>  	if (COMPAT_USE_64BIT_TIME)
>  		return __sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
>  				      flags | MSG_CMSG_COMPAT,
> diff --git a/net/socket.c b/net/socket.c
> index 0e16888..e216502 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1978,7 +1978,7 @@ struct used_address {
>  	unsigned int name_len;
>  };
>  
> -static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
> +static int ___sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
>  			 struct msghdr *msg_sys, unsigned int flags,
>  			 struct used_address *used_address)
>  {
> @@ -2093,26 +2093,30 @@ out:
>   *	BSD sendmsg interface
>   */
>  
> -SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned int, flags)
> +long __sys_sendmsg(int fd, struct msghdr __user *msg, unsigned flags)
>  {
>  	int fput_needed, err;
>  	struct msghdr msg_sys;
>  	struct socket *sock;
>  
> -	if (flags & MSG_CMSG_COMPAT)
> -		return -EINVAL;
> -
>  	sock = sockfd_lookup_light(fd, &err, &fput_needed);
>  	if (!sock)
>  		goto out;
>  
> -	err = __sys_sendmsg(sock, msg, &msg_sys, flags, NULL);
> +	err = ___sys_sendmsg(sock, msg, &msg_sys, flags, NULL);
>  
>  	fput_light(sock->file, fput_needed);
>  out:
>  	return err;
>  }
>  
> +SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned int, flags)
> +{
> +	if (flags & MSG_CMSG_COMPAT)
> +		return -EINVAL;
> +	return __sys_sendmsg(fd, msg, flags);
> +}
> +
>  /*
>   *	Linux sendmmsg interface
>   */
> @@ -2143,15 +2147,16 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
>  
>  	while (datagrams < vlen) {
>  		if (MSG_CMSG_COMPAT & flags) {
> -			err = __sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
> -					    &msg_sys, flags, &used_address);
> +			err = ___sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
> +					     &msg_sys, flags, &used_address);
>  			if (err < 0)
>  				break;
>  			err = __put_user(err, &compat_entry->msg_len);
>  			++compat_entry;
>  		} else {
> -			err = __sys_sendmsg(sock, (struct msghdr __user *)entry,
> -					    &msg_sys, flags, &used_address);
> +			err = ___sys_sendmsg(sock,
> +					     (struct msghdr __user *)entry,
> +					     &msg_sys, flags, &used_address);
>  			if (err < 0)
>  				break;
>  			err = put_user(err, &entry->msg_len);
> @@ -2180,7 +2185,7 @@ SYSCALL_DEFINE4(sendmmsg, int, fd, struct mmsghdr __user *, mmsg,
>  	return __sys_sendmmsg(fd, mmsg, vlen, flags);
>  }
>  
> -static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
> +static int ___sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
>  			 struct msghdr *msg_sys, unsigned int flags, int nosec)
>  {
>  	struct compat_msghdr __user *msg_compat =
> @@ -2272,27 +2277,31 @@ out:
>   *	BSD recvmsg interface
>   */
>  
> -SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
> -		unsigned int, flags)
> +long __sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags)
>  {
>  	int fput_needed, err;
>  	struct msghdr msg_sys;
>  	struct socket *sock;
>  
> -	if (flags & MSG_CMSG_COMPAT)
> -		return -EINVAL;
> -
>  	sock = sockfd_lookup_light(fd, &err, &fput_needed);
>  	if (!sock)
>  		goto out;
>  
> -	err = __sys_recvmsg(sock, msg, &msg_sys, flags, 0);
> +	err = ___sys_recvmsg(sock, msg, &msg_sys, flags, 0);
>  
>  	fput_light(sock->file, fput_needed);
>  out:
>  	return err;
>  }
>  
> +SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
> +		unsigned int, flags)
> +{
> +	if (flags & MSG_CMSG_COMPAT)
> +		return -EINVAL;
> +	return __sys_recvmsg(fd, msg, flags);
> +}
> +
>  /*
>   *     Linux recvmmsg interface
>   */
> @@ -2330,17 +2339,18 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
>  		 * No need to ask LSM for more than the first datagram.
>  		 */
>  		if (MSG_CMSG_COMPAT & flags) {
> -			err = __sys_recvmsg(sock, (struct msghdr __user *)compat_entry,
> -					    &msg_sys, flags & ~MSG_WAITFORONE,
> -					    datagrams);
> +			err = ___sys_recvmsg(sock, (struct msghdr __user *)compat_entry,
> +					     &msg_sys, flags & ~MSG_WAITFORONE,
> +					     datagrams);
>  			if (err < 0)
>  				break;
>  			err = __put_user(err, &compat_entry->msg_len);
>  			++compat_entry;
>  		} else {
> -			err = __sys_recvmsg(sock, (struct msghdr __user *)entry,
> -					    &msg_sys, flags & ~MSG_WAITFORONE,
> -					    datagrams);
> +			err = ___sys_recvmsg(sock,
> +					     (struct msghdr __user *)entry,
> +					     &msg_sys, flags & ~MSG_WAITFORONE,
> +					     datagrams);
>  			if (err < 0)
>  				break;
>  			err = put_user(err, &entry->msg_len);
> @@ -2525,31 +2535,15 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
>  				   (int __user *)a[4]);
>  		break;
>  	case SYS_SENDMSG:
> -		if (a[2] & MSG_CMSG_COMPAT) {
> -			err = -EINVAL;
> -			break;
> -		}
>  		err = sys_sendmsg(a0, (struct msghdr __user *)a1, a[2]);
>  		break;
>  	case SYS_SENDMMSG:
> -		if (a[3] & MSG_CMSG_COMPAT) {
> -			err = -EINVAL;
> -			break;
> -		}
>  		err = sys_sendmmsg(a0, (struct mmsghdr __user *)a1, a[2], a[3]);
>  		break;
>  	case SYS_RECVMSG:
> -		if (a[2] & MSG_CMSG_COMPAT) {
> -			err = -EINVAL;
> -			break;
> -		}
>  		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
>  		break;
>  	case SYS_RECVMMSG:
> -		if (a[3] & MSG_CMSG_COMPAT) {
> -			err = -EINVAL;
> -			break;
> -		}
>  		err = sys_recvmmsg(a0, (struct mmsghdr __user *)a1, a[2], a[3],
>  				   (struct timespec __user *)a[4]);
>  		break;
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe trinity" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
