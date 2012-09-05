From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: linux-next: manual merge of the net-next tree with the vfs tree
Date: Wed, 05 Sep 2012 13:55:53 +0900 (JST)
Message-ID: <20120905.135553.1191951431365833823.yamato@redhat.com>
References: <20120905120204.a8990185fb80f6b1b65bc6ea@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120905120204.a8990185fb80f6b1b65bc6ea@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

How can I see source files applied your patch?
(I'm very new to kernel development.)

You patch looks like a patch for another patch.

Masatake YAMATO

> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> net/socket.c between commits f8a78429cc70 ("take descriptor handling from
> sock_alloc_file() to callers") and 32b529f92ea7 ("unexport sock_map_fd(),
> switch to sock_alloc_file()") from the vfs tree and commit 600e177920df
> ("net: Providing protocol type via system.sockprotoname xattr
> of /proc/PID/fd entries") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.  I also had
> to add this merge fix patch:
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 5 Sep 2012 11:52:06 +1000
> Subject: [PATCH] net: cope with sock_alloc_file() API change
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  include/linux/net.h |    3 ++-
>  net/9p/trans_fd.c   |    2 +-
>  net/sctp/socket.c   |    2 +-
>  3 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/net.h b/include/linux/net.h
> index c8a9708..a3831f3 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -247,7 +247,8 @@ extern int   	     sock_sendmsg(struct socket *sock, struct msghdr *msg,
>  				  size_t len);
>  extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
>  				  size_t size, int flags);
> -extern struct file  *sock_alloc_file(struct socket *sock, int flags);
> +extern struct file  *sock_alloc_file(struct socket *sock, int flags,
> +				     const char *dname);
>  extern struct socket *sockfd_lookup(int fd, int *err);
>  extern struct socket *sock_from_file(struct file *file, int *err);
>  #define		     sockfd_put(sock) fput(sock->file)
> diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
> index 8c4e0b5..1c8b557 100644
> --- a/net/9p/trans_fd.c
> +++ b/net/9p/trans_fd.c
> @@ -801,7 +801,7 @@ static int p9_socket_open(struct p9_client *client, struct socket *csocket)
>  		return -ENOMEM;
>  
>  	csocket->sk->sk_allocation = GFP_NOIO;
> -	file = sock_alloc_file(csocket, 0);
> +	file = sock_alloc_file(csocket, 0, NULL);
>  	if (IS_ERR(file)) {
>  		pr_err("%s (%d): failed to map fd\n",
>  		       __func__, task_pid_nr(current));
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 5ba739e..59d16ea 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4313,7 +4313,7 @@ static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval
>  		goto out;
>  	}
>  
> -	newfile = sock_alloc_file(newsock, 0);
> +	newfile = sock_alloc_file(newsock, 0, NULL);
>  	if (unlikely(IS_ERR(newfile))) {
>  		put_unused_fd(retval);
>  		sock_release(newsock);
> -- 
> 1.7.10.280.gaa39
> 
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc net/socket.c
> index 79170dc,977c0f4..0000000
> --- a/net/socket.c
> +++ b/net/socket.c
> @@@ -346,15 -347,30 +347,23 @@@ static struct file_system_type sock_fs_
>    *	but we take care of internal coherence yet.
>    */
>   
> - struct file *sock_alloc_file(struct socket *sock, int flags)
>  -static int sock_alloc_file(struct socket *sock, struct file **f, int flags,
>  -			   const char *dname)
> ++struct file *sock_alloc_file(struct socket *sock, int flags,
> ++			     const char *dname)
>   {
>   	struct qstr name = { .name = "" };
>   	struct path path;
>   	struct file *file;
>  -	int fd;
>  -
>  -	fd = get_unused_fd_flags(flags);
>  -	if (unlikely(fd < 0))
>  -		return fd;
>   
> + 	if (dname) {
> + 		name.name = dname;
> + 		name.len = strlen(name.name);
> + 	} else if (sock->sk) {
> + 		name.name = sock->sk->sk_prot_creator->name;
> + 		name.len = strlen(name.name);
> + 	}
>   	path.dentry = d_alloc_pseudo(sock_mnt->mnt_sb, &name);
>  -	if (unlikely(!path.dentry)) {
>  -		put_unused_fd(fd);
>  -		return -ENOMEM;
>  -	}
>  +	if (unlikely(!path.dentry))
>  +		return ERR_PTR(-ENOMEM);
>   	path.mnt = mntget(sock_mnt);
>   
>   	d_instantiate(path.dentry, SOCK_INODE(sock));
> @@@ -373,26 -390,22 +382,26 @@@
>   	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
>   	file->f_pos = 0;
>   	file->private_data = sock;
>  -
>  -	*f = file;
>  -	return fd;
>  +	return file;
>   }
>  +EXPORT_SYMBOL(sock_alloc_file);
>   
>  -int sock_map_fd(struct socket *sock, int flags)
>  +static int sock_map_fd(struct socket *sock, int flags)
>   {
>   	struct file *newfile;
>  -	int fd = sock_alloc_file(sock, &newfile, flags, NULL);
>  +	int fd = get_unused_fd_flags(flags);
>  +	if (unlikely(fd < 0))
>  +		return fd;
>   
> - 	newfile = sock_alloc_file(sock, flags);
>  -	if (likely(fd >= 0))
> ++	newfile = sock_alloc_file(sock, flags, NULL);
>  +	if (likely(!IS_ERR(newfile))) {
>   		fd_install(fd, newfile);
>  +		return fd;
>  +	}
>   
>  -	return fd;
>  +	put_unused_fd(fd);
>  +	return PTR_ERR(newfile);
>   }
>  -EXPORT_SYMBOL(sock_map_fd);
>   
>   struct socket *sock_from_file(struct file *file, int *err)
>   {
> @@@ -1395,27 -1471,12 +1467,27 @@@ SYSCALL_DEFINE4(socketpair, int, family
>   		err = fd1;
>   		goto out_release_both;
>   	}
>  -
>  -	fd2 = sock_alloc_file(sock2, &newfile2, flags, NULL);
>  +	fd2 = get_unused_fd_flags(flags);
>   	if (unlikely(fd2 < 0)) {
>   		err = fd2;
>  +		put_unused_fd(fd1);
>  +		goto out_release_both;
>  +	}
>  +
> - 	newfile1 = sock_alloc_file(sock1, flags);
> ++	newfile1 = sock_alloc_file(sock1, flags, NULL);
>  +	if (unlikely(IS_ERR(newfile1))) {
>  +		err = PTR_ERR(newfile1);
>  +		put_unused_fd(fd1);
>  +		put_unused_fd(fd2);
>  +		goto out_release_both;
>  +	}
>  +
> - 	newfile2 = sock_alloc_file(sock2, flags);
> ++	newfile2 = sock_alloc_file(sock2, flags, NULL);
>  +	if (IS_ERR(newfile2)) {
>  +		err = PTR_ERR(newfile2);
>   		fput(newfile1);
>   		put_unused_fd(fd1);
>  +		put_unused_fd(fd2);
>   		sock_release(sock2);
>   		goto out;
>   	}
> @@@ -1553,13 -1615,6 +1625,14 @@@ SYSCALL_DEFINE4(accept4, int, fd, struc
>   		sock_release(newsock);
>   		goto out_put;
>   	}
> - 	newfile = sock_alloc_file(newsock, flags);
> ++	newfile = sock_alloc_file(newsock, flags,
> ++				  sock->sk->sk_prot_creator->name);
>  +	if (unlikely(IS_ERR(newfile))) {
>  +		err = PTR_ERR(newfile);
>  +		put_unused_fd(newfd);
>  +		sock_release(newsock);
>  +		goto out_put;
>  +	}
>   
>   	err = security_socket_accept(sock, newsock);
>   	if (err)
