From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC 1/9] lsm: add security_socket_closed()
Date: Mon, 4 Jan 2010 12:33:55 -0600
Message-ID: <20100104183355.GA5083@us.ibm.com>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
 <1262437456-24476-2-git-send-email-sam@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1262437456-24476-2-git-send-email-sam@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Samir Bellabes (sam@synack.fr):
> Allow a module to update security informations when a socket is closed.
> 
> Signed-off-by: Samir Bellabes <sam@synack.fr>
> ---
>  include/linux/security.h |   10 ++++++++++
>  net/socket.c             |    1 +
>  security/capability.c    |    5 +++++
>  security/security.c      |    5 +++++
>  4 files changed, 21 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 466cbad..275dd04 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -974,6 +974,9 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *	@sock contains the socket structure.
>   *	@how contains the flag indicating how future sends and receives are handled.
>   *	Return 0 if permission is granted.
> + * @socket_close:
> + *	Allow a module to update security informations when a socket is closed
> + *	@sock is closed.
>   * @socket_sock_rcv_skb:
>   *	Check permissions on incoming network packets.  This hook is distinct
>   *	from Netfilter's IP input hooks since it is the first time that the
> @@ -1673,6 +1676,7 @@ struct security_operations {
>  	int (*socket_getsockopt) (struct socket *sock, int level, int optname);
>  	int (*socket_setsockopt) (struct socket *sock, int level, int optname);
>  	int (*socket_shutdown) (struct socket *sock, int how);
> +	void (*socket_close) (struct socket *sock);
>  	int (*socket_sock_rcv_skb) (struct sock *sk, struct sk_buff *skb);
>  	int (*socket_getpeersec_stream) (struct socket *sock, char __user *optval, int __user *optlen, unsigned len);
>  	int (*socket_getpeersec_dgram) (struct socket *sock, struct sk_buff *skb, u32 *secid);
> @@ -2693,6 +2697,7 @@ int security_socket_getpeername(struct socket *sock);
>  int security_socket_getsockopt(struct socket *sock, int level, int optname);
>  int security_socket_setsockopt(struct socket *sock, int level, int optname);
>  int security_socket_shutdown(struct socket *sock, int how);
> +void security_socket_close(struct socket *sock);
>  int security_sock_rcv_skb(struct sock *sk, struct sk_buff *skb);
>  int security_socket_getpeersec_stream(struct socket *sock, char __user *optval,
>  				      int __user *optlen, unsigned len);
> @@ -2805,6 +2810,11 @@ static inline int security_socket_shutdown(struct socket *sock, int how)
>  {
>  	return 0;
>  }
> +
> +static inline void security_socket_close(struct socket *sock)
> +{
> +}
> +
>  static inline int security_sock_rcv_skb(struct sock *sk,
>  					struct sk_buff *skb)
>  {
> diff --git a/net/socket.c b/net/socket.c
> index dbfdfa9..8984973 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1074,6 +1074,7 @@ static int sock_close(struct inode *inode, struct file *filp)
>  		printk(KERN_DEBUG "sock_close: NULL inode\n");
>  		return 0;
>  	}
> +	security_socket_close(SOCKET_I(inode));

Hi,

Should this also be called at other sock_release() callers, i.e.
on error paths throughout net/socket.c?  ofr instance, I assume
sock_create() will set up whatever you want released, so if
sock_map-fd() fails, do you need to call security_socket_close()
there as well?

If so, should it just be called from sock_release()?

Or do you really intend for this only to be called when userspace
purposely releases the socket?

>  	sock_release(SOCKET_I(inode));
>  	return 0;
>  }
> diff --git a/security/capability.c b/security/capability.c
> index 5c700e1..a9810dc 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -677,6 +677,10 @@ static int cap_socket_shutdown(struct socket *sock, int how)
>  	return 0;
>  }
> 
> +static void cap_socket_close(struct socket *sock)
> +{
> +}
> +
>  static int cap_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  {
>  	return 0;
> @@ -1084,6 +1088,7 @@ void security_fixup_ops(struct security_operations *ops)
>  	set_to_cap_if_null(ops, socket_setsockopt);
>  	set_to_cap_if_null(ops, socket_getsockopt);
>  	set_to_cap_if_null(ops, socket_shutdown);
> +	set_to_cap_if_null(ops, socket_close);
>  	set_to_cap_if_null(ops, socket_sock_rcv_skb);
>  	set_to_cap_if_null(ops, socket_getpeersec_stream);
>  	set_to_cap_if_null(ops, socket_getpeersec_dgram);
> diff --git a/security/security.c b/security/security.c
> index 24e060b..7457ed5 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -1120,6 +1120,11 @@ int security_socket_shutdown(struct socket *sock, int how)
>  	return security_ops->socket_shutdown(sock, how);
>  }
> 
> +void security_socket_close(struct socket *sock)
> +{
> +	return security_ops->socket_close(sock);
> +}
> +
>  int security_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  {
>  	return security_ops->socket_sock_rcv_skb(sk, skb);
> -- 
> 1.6.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
