From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] netns: unix: only allow to find out unix socket in same
	net namespace
Date: Wed, 21 Aug 2013 12:58:30 +0800
Message-ID: <521448F6.4010506@cn.fujitsu.com>
References: <1377059473-25526-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1377059473-25526-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

cc containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org

On 08/21/2013 12:31 PM, Gao feng wrote:
> Unix sockets are private resources of net namespace,
> allowing one net namespace to access to other netns's unix
> sockets is meaningless.
> 
> I'm researching a problem about shutdown from container,
> if the cotainer shares the same file /run/systemd/private
> with host, when we run shutdown -h xxx in container, the
> shutdown message will be send to the systemd-shutdownd
> through unix socket /run/systemd/private, and because
> systemd-shutdownd is running in host, so finally, the host
> will become shutdown.
> 
> We should make sure unix sockets are per net namespace to
> avoid this problem.
> 
> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  net/unix/af_unix.c |  8 ++++++--
>  net/unix/diag.c    | 11 ++++++++---
>  2 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index c4ce243..98e3689 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -295,7 +295,8 @@ static inline struct sock *unix_find_socket_byname(struct net *net,
>  	return s;
>  }
>  
> -static struct sock *unix_find_socket_byinode(struct inode *i)
> +static struct sock *unix_find_socket_byinode(struct net *net,
> +					     struct inode *i)
>  {
>  	struct sock *s;
>  
> @@ -304,6 +305,9 @@ static struct sock *unix_find_socket_byinode(struct inode *i)
>  		    &unix_socket_table[i->i_ino & (UNIX_HASH_SIZE - 1)]) {
>  		struct dentry *dentry = unix_sk(s)->path.dentry;
>  
> +		if (!net_eq(sock_net(s), net))
> +			continue;
> +
>  		if (dentry && dentry->d_inode == i) {
>  			sock_hold(s);
>  			goto found;
> @@ -784,7 +788,7 @@ static struct sock *unix_find_other(struct net *net,
>  		err = -ECONNREFUSED;
>  		if (!S_ISSOCK(inode->i_mode))
>  			goto put_fail;
> -		u = unix_find_socket_byinode(inode);
> +		u = unix_find_socket_byinode(net, inode);
>  		if (!u)
>  			goto put_fail;
>  
> diff --git a/net/unix/diag.c b/net/unix/diag.c
> index d591091..80ada12 100644
> --- a/net/unix/diag.c
> +++ b/net/unix/diag.c
> @@ -218,20 +218,25 @@ done:
>  	return skb->len;
>  }
>  
> -static struct sock *unix_lookup_by_ino(int ino)
> +static struct sock *unix_lookup_by_ino(struct net *net, int ino)
>  {
>  	int i;
>  	struct sock *sk;
>  
>  	spin_lock(&unix_table_lock);
>  	for (i = 0; i < ARRAY_SIZE(unix_socket_table); i++) {
> -		sk_for_each(sk, &unix_socket_table[i])
> +		sk_for_each(sk, &unix_socket_table[i]) {
> +
> +			if (!net_eq(sock_net(sk), net))
> +				continue;
> +
>  			if (ino == sock_i_ino(sk)) {
>  				sock_hold(sk);
>  				spin_unlock(&unix_table_lock);
>  
>  				return sk;
>  			}
> +		}
>  	}
>  
>  	spin_unlock(&unix_table_lock);
> @@ -251,7 +256,7 @@ static int unix_diag_get_exact(struct sk_buff *in_skb,
>  	if (req->udiag_ino == 0)
>  		goto out_nosk;
>  
> -	sk = unix_lookup_by_ino(req->udiag_ino);
> +	sk = unix_lookup_by_ino(net, req->udiag_ino);
>  	err = -ENOENT;
>  	if (sk == NULL)
>  		goto out_nosk;
> 
