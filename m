From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: [RFC] net/unix_diag: Provide UDIAG_SHOW_VFS2 attribute to fetch
 complete inode number
Date: Tue, 24 Oct 2017 17:25:16 -0700
Message-ID: <20171025002509.GA12438@outlook.office365.com>
References: <20171024214814.GO5343@uranus>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: NETDEV <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrey Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>,
        Pavel Emelyanov <xemul@virtuozzo.com>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171024214814.GO5343@uranus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2017 at 12:48:14AM +0300, Cyrill Gorcunov wrote:
> Currently unix_diag_vfs structure reports unix socket inode
> as u32 value which of course doesn't fit to ino_t type and

BTW: As far as I understand, it is not a problem right now, because
get_next_ino returns int. And I'm agree that it maybe a problem in a
future and it is better to be ready.

> the number may be trimmed. Lets rather deprecate old UDIAG_SHOW_VFS
> interface and provide UDIAG_SHOW_VFS2 (with one field "__zero" reserved
> which we could extend in future).

There is one more place where we return ino as u32:

static int sk_diag_dump_peer(struct sock *sk, struct sk_buff *nlskb)
....
                return nla_put_u32(nlskb, UNIX_DIAG_PEER, ino);

> 
> CC: Andrey Vagin <avagin@openvz.org>
> CC: David S. Miller <davem@davemloft.net>
> CC: Pavel Emelyanov <xemul@virtuozzo.com>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
> 
> I build-tested it only thus not for inclusion yet, but rather
> to discuss if there some better way to handle this potential
> problem.
> 
>  include/uapi/linux/unix_diag.h |    8 ++++++++
>  net/unix/diag.c                |   25 ++++++++++++++++---------
>  2 files changed, 24 insertions(+), 9 deletions(-)
> 
> Index: linux-ml.git/include/uapi/linux/unix_diag.h
> ===================================================================
> --- linux-ml.git.orig/include/uapi/linux/unix_diag.h
> +++ linux-ml.git/include/uapi/linux/unix_diag.h
> @@ -19,6 +19,7 @@ struct unix_diag_req {
>  #define UDIAG_SHOW_ICONS	0x00000008	/* show pending connections */
>  #define UDIAG_SHOW_RQLEN	0x00000010	/* show skb receive queue len */
>  #define UDIAG_SHOW_MEMINFO	0x00000020	/* show memory info of a socket */
> +#define UDIAG_SHOW_VFS2		0x00000040	/* show VFS inode info v2 */
>  
>  struct unix_diag_msg {
>  	__u8	udiag_family;
> @@ -39,6 +40,7 @@ enum {
>  	UNIX_DIAG_RQLEN,
>  	UNIX_DIAG_MEMINFO,
>  	UNIX_DIAG_SHUTDOWN,
> +	UNIX_DIAG_VFS2,
>  
>  	__UNIX_DIAG_MAX,
>  };
> @@ -50,6 +52,12 @@ struct unix_diag_vfs {
>  	__u32	udiag_vfs_dev;
>  };
>  
> +struct unix_diag_vfs2 {
> +	__u64	udiag_vfs_ino;
> +	__u32	udiag_vfs_dev;
> +	__u32	__zero;		/* Reserve for future use */

How can a user understand whether this field is used or not?

Each netlink attribute has its size in a header. Any attribute can be
extended, and users can understand which fields are filled by
a size of an attribute.

> +};
> +
>  struct unix_diag_rqlen {
>  	__u32	udiag_rqueue;
>  	__u32	udiag_wqueue;
> Index: linux-ml.git/net/unix/diag.c
> ===================================================================
> --- linux-ml.git.orig/net/unix/diag.c
> +++ linux-ml.git/net/unix/diag.c
> @@ -19,17 +19,24 @@ static int sk_diag_dump_name(struct sock
>  		       addr->name->sun_path);
>  }
>  
> -static int sk_diag_dump_vfs(struct sock *sk, struct sk_buff *nlskb)
> +static int sk_diag_dump_vfs(struct sock *sk, struct sk_buff *nlskb, unsigned int flags)
>  {
>  	struct dentry *dentry = unix_sk(sk)->path.dentry;
>  
>  	if (dentry) {
> -		struct unix_diag_vfs uv = {
> -			.udiag_vfs_ino = d_backing_inode(dentry)->i_ino,
> -			.udiag_vfs_dev = dentry->d_sb->s_dev,
> -		};
> -
> -		return nla_put(nlskb, UNIX_DIAG_VFS, sizeof(uv), &uv);
> +		if (flags & UDIAG_SHOW_VFS2) {
> +			struct unix_diag_vfs uv = {
> +				.udiag_vfs_ino = d_backing_inode(dentry)->i_ino,
> +				.udiag_vfs_dev = dentry->d_sb->s_dev,
> +			};
> +			return nla_put(nlskb, UNIX_DIAG_VFS, sizeof(uv), &uv);
> +		} else {
> +			struct unix_diag_vfs2 uv = {
> +				.udiag_vfs_ino = d_backing_inode(dentry)->i_ino,
> +				.udiag_vfs_dev = dentry->d_sb->s_dev,
> +			};
> +			return nla_put(nlskb, UDIAG_SHOW_VFS2, sizeof(uv), &uv);
> +		}
>  	}
>  
>  	return 0;
> @@ -132,8 +139,8 @@ static int sk_diag_fill(struct sock *sk,
>  	    sk_diag_dump_name(sk, skb))
>  		goto out_nlmsg_trim;
>  
> -	if ((req->udiag_show & UDIAG_SHOW_VFS) &&
> -	    sk_diag_dump_vfs(sk, skb))
> +	if ((req->udiag_show & (UDIAG_SHOW_VFS | UDIAG_SHOW_VFS2)) &&
> +	    sk_diag_dump_vfs(sk, skb, req->udiag_show))
>  		goto out_nlmsg_trim;
>  
>  	if ((req->udiag_show & UDIAG_SHOW_PEER) &&
