From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] LSM: Add post accept() hook.
Date: Mon, 19 Jul 2010 18:15:51 -0400
Message-ID: <201007191815.52124.paul.moore@hp.com>
References: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp> <20100718.142550.25115105.davem@davemloft.net> <201007191325.IDI17618.VJStMOFOOLFFHQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jmorris@namei.org,
	sam@synack.fr, serge@hallyn.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007191325.IDI17618.VJStMOFOOLFFHQ@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, July 19, 2010 12:25:25 am Tetsuo Handa wrote:
> Current pre accept hook (i.e. security_socket_accept()) has two problems.
> 
> One is that it will cause eating 100% of CPU time if the caller does not
> close() the socket when accept() failed due to security_socket_accept(),
> for subsequent select() notifies the caller of readiness for accept()
> since the connection which would have been already picked up if
> security_socket_accept() did not return error is remaining in the queue.
> 
> The other is that it is racy if LSM module wants to do filtering based on
> "which process can pick up connections from which source" because the
> process which picks up the connection is not known until
> sock->ops->accept() and lock is not held between security_socket_accept()
> and sock->ops->accept.
> 
> This patch introduces post accept hook (i.e. security_socket_post_accept())
> in order to solve above problems at the cost of ability to pick up the
> connection which would have been picked up if preceding
> security_socket_post_accept() did not return error.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

I think you need to show how you plan to use this hook in an LSM before we can 
consider merging it with mainline.  What you are proposing here is giving an 
LSM the ability to drop a connection _after_ allowing it to be established in 
the first place; this seems very wrong to me and I want to make sure everyone 
else is aware of that before accepting this code into the kernel.  I 
understand that TOMOYO's security model does not allow it to reject incoming 
connections at the beginning of the connection request like some of the LSMs 
currently in use, but I'm just not very happy with the idea of finishing a 
connection handshake only to later drop the connection on the floor.

> ---
>  include/linux/security.h |   21 +++++++++++++++++++++
>  net/socket.c             |    7 +++++++
>  security/capability.c    |    6 ++++++
>  security/security.c      |    5 +++++
>  4 files changed, 39 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 409c44d..2ed73c1 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -866,6 +866,19 @@ static inline void security_free_mnt_opts(struct
> security_mnt_opts *opts) *	@sock contains the listening socket structure.
>   *	@newsock contains the newly created server socket for connection.
>   *	Return 0 if permission is granted.
> + * @socket_post_accept:
> + *	Check permission after accepting a new connection.
> + *	The connection is discarded if permission is not granted.
> + *	Return 0 after updating security information on the socket if you 
want
> + *	to restrict some of socket syscalls on the connection (e.g. forbid 
only
> + *	sending data). But you can't use this hook for updating security
> + *	information of the socket for preventing the connection from 
receiving
> + *	incoming data, for the kernel already started receiving incoming data
> + *	before accept() syscall. Return error if updating security 
information
> + *	failed or you want to forbid all of socket syscalls on the 
connection.
> + *	@sock contains the listening socket structure.
> + *	@newsock contains the accepted socket structure.
> + *	Return 0 if permission is granted.
>   * @socket_sendmsg:
>   *	Check permission before transmitting a message to another socket.
>   *	@sock contains the socket structure.
> @@ -1577,6 +1590,7 @@ struct security_operations {
>  			       struct sockaddr *address, int addrlen);
>  	int (*socket_listen) (struct socket *sock, int backlog);
>  	int (*socket_accept) (struct socket *sock, struct socket *newsock);
> +	int (*socket_post_accept) (struct socket *sock, struct socket *newsock);
>  	int (*socket_sendmsg) (struct socket *sock,
>  			       struct msghdr *msg, int size);
>  	int (*socket_recvmsg) (struct socket *sock,
> @@ -2530,6 +2544,7 @@ int security_socket_bind(struct socket *sock, struct
> sockaddr *address, int addr int security_socket_connect(struct socket
> *sock, struct sockaddr *address, int addrlen); int
> security_socket_listen(struct socket *sock, int backlog);
>  int security_socket_accept(struct socket *sock, struct socket *newsock);
> +int security_socket_post_accept(struct socket *sock, struct socket
> *newsock); int security_socket_sendmsg(struct socket *sock, struct msghdr
> *msg, int size); int security_socket_recvmsg(struct socket *sock, struct
> msghdr *msg, int size, int flags);
> @@ -2612,6 +2627,12 @@ static inline int security_socket_accept(struct
> socket *sock, return 0;
>  }
> 
> +static inline int security_socket_post_accept(struct socket *sock,
> +					      struct socket *newsock)
> +{
> +	return 0;
> +}
> +
>  static inline int security_socket_sendmsg(struct socket *sock,
>  					  struct msghdr *msg, int size)
>  {
> diff --git a/net/socket.c b/net/socket.c
> index 367d547..97d644c 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1473,6 +1473,7 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr
> __user *, upeer_sockaddr, if (!sock)
>  		goto out;
> 
> + retry:
>  	err = -ENFILE;
>  	if (!(newsock = sock_alloc()))
>  		goto out_put;
> @@ -1500,6 +1501,12 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr
> __user *, upeer_sockaddr, err = sock->ops->accept(sock, newsock,
> sock->file->f_flags);
>  	if (err < 0)
>  		goto out_fd;
> +	err = security_socket_post_accept(sock, newsock);
> +	if (unlikely(err)) {
> +		fput(newfile);
> +		put_unused_fd(newfd);
> +		goto retry;
> +	}
> 
>  	if (upeer_sockaddr) {
>  		if (newsock->ops->getname(newsock, (struct sockaddr *)&address,
> diff --git a/security/capability.c b/security/capability.c
> index 709aea3..1fb88f5 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -586,6 +586,11 @@ static int cap_socket_accept(struct socket *sock,
> struct socket *newsock) return 0;
>  }
> 
> +static int cap_socket_post_accept(struct socket *sock, struct socket
> *newsock) +{
> +	return 0;
> +}
> +
>  static int cap_socket_sendmsg(struct socket *sock, struct msghdr *msg, int
> size) {
>  	return 0;
> @@ -1004,6 +1009,7 @@ void __init security_fixup_ops(struct
> security_operations *ops) set_to_cap_if_null(ops, socket_connect);
>  	set_to_cap_if_null(ops, socket_listen);
>  	set_to_cap_if_null(ops, socket_accept);
> +	set_to_cap_if_null(ops, socket_post_accept);
>  	set_to_cap_if_null(ops, socket_sendmsg);
>  	set_to_cap_if_null(ops, socket_recvmsg);
>  	set_to_cap_if_null(ops, socket_post_recvmsg);
> diff --git a/security/security.c b/security/security.c
> index 4291bd7..5c9ab0a 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -1026,6 +1026,11 @@ int security_socket_accept(struct socket *sock,
> struct socket *newsock) return security_ops->socket_accept(sock, newsock);
>  }
> 
> +int security_socket_post_accept(struct socket *sock, struct socket
> *newsock) +{
> +	return security_ops->socket_post_accept(sock, newsock);
> +}
> +
>  int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int
> size) {
>  	return security_ops->socket_sendmsg(sock, msg, size);

-- 
paul moore
linux @ hp
