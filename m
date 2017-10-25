From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [RFC] net/unix_diag: Provide UDIAG_SHOW_VFS2 attribute to fetch complete inode number
Date: Wed, 25 Oct 2017 09:55:07 -0400
Message-ID: <85bmkvcoxw.fsf@mojatatu.com>
References: <20171024214814.GO5343@uranus>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NETDEV <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrey Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>,
        Pavel Emelyanov <xemul@virtuozzo.com>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024214814.GO5343@uranus> (Cyrill Gorcunov's message of
        "Wed, 25 Oct 2017 00:48:14 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cyrill Gorcunov <gorcunov@gmail.com> writes:

> Currently unix_diag_vfs structure reports unix socket inode
> as u32 value which of course doesn't fit to ino_t type and
> the number may be trimmed. Lets rather deprecate old UDIAG_SHOW_VFS
> interface and provide UDIAG_SHOW_VFS2 (with one field "__zero" reserved
> which we could extend in future).
>

[...]

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

I think __zero should be explicitly set to 0.

[...]
