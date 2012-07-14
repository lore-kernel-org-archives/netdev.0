From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC PATCH] tun: don't zeroize sock->file on detach
Date: Sat, 14 Jul 2012 09:15:14 +0100
Message-ID: <20120714081513.GJ22927@ZenIV.linux.org.uk>
References: <20120711114753.24395.53193.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ruanzhijie@hotmail.com, linux-kernel@vger.kernel.org
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33001 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756546Ab2GNIPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 04:15:22 -0400
Content-Disposition: inline
In-Reply-To: <20120711114753.24395.53193.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 11, 2012 at 03:48:20PM +0400, Stanislav Kinsbursky wrote:
> This is a fix for bug, introduced in 3.4 kernel by commit
> 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d, which, among other things, replaced
> simple sock_put() by sk_release_kernel(). Below is sequence, which leads to
> oops for non-persistent devices:
> 
> tun_chr_close()
> tun_detach()				<== tun->socket.file = NULL
> tun_free_netdev()
> sk_release_sock()
> sock_release(sock->file == NULL)
> iput(SOCK_INODE(sock))			<== dereference on NULL pointer
> 
> This patch just removes zeroing of socket's file from __tun_detach().
> sock_release() will do this.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  drivers/net/tun.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 987aeef..c1639f3 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -185,7 +185,6 @@ static void __tun_detach(struct tun_struct *tun)
>  	netif_tx_lock_bh(tun->dev);
>  	netif_carrier_off(tun->dev);
>  	tun->tfile = NULL;
> -	tun->socket.file = NULL;
>  	netif_tx_unlock_bh(tun->dev);

ACK, but I have to say that I don't like the entire area.  The games around sock->file
in general tend to be really nasty.  Examples:
1) net/9p/trans_fd.c:p9_socket_open():
	we come there with freshly created and connected struct socket in *csocket
	we do sock_map_fd() and bugger off if it fails
	we do get_file(csocket->file) twice and, having grabbed the references, close
the damn fd.
What happens if that races with close() on the same fd before we get to those get_file()?
We hit sock_close(), which calls sock_release(), which clears csocket->file.  Boom -
atomic_inc_long(&NULL->f_count) is not going to do us any good.  Outright bug, mitigated
only by the fact that all callchains to that place go through mount(2), so you have elevated
privs anyway.

2) with this sucker we hit an interesting interplay with vhost; note that the total effect
of tun_get_socket() does *not* include any refcount changes.  Nor should it - the caller
has a valid reference to struct file, after all.  Eventually the caller proceeds to drop
the same reference, by doing fput(sock->file).  And it will be the same struct file, but
proving that takes a lot of digging through the tun.c guts; the crucial observation is that
we never get to __tun_detach() as long as we have a reference to opened (cdev) file that
has been successfully attached at some point and that ones that hadn't been attached at
all wouldn't have passed through tun_get_socket().  IOW, it works, but it's brittle as hell.
Unless I've missed something in the analysis and it's really broken, that is.

Frankly, I would prefer to keep the reference to struct file for vhost explicitly in vhost
data structures.  Would be less dependent on the guts of tun/macvtap/whatnot that way...

3) iscsi goes as far as allocating fake struct file (with kzalloc(), and $DEITY help you
if you ever call fput() on that), presumably for the sake of sctp.  The only place in sctp
stack I see looking at sock->file is
        /* in-kernel sockets don't generally have a file allocated to them
         * if all they do is call sock_create_kern().
         */
        if (sk->sk_socket->file)
                f_flags = sk->sk_socket->file->f_flags;

        timeo = sock_sndtimeo(sk, f_flags & O_NONBLOCK);
in __sctp_connect() and AFAICS we could bloody well have left it NULL - we leave ->f_flags
zero in that code anyway and that's what __sctp_connect() will presume on NULL ->file.
I'm not familiar enough with sctp or iscsi, but at the first look it seems to be asking
for removal of all those games with ->file in the latter.

I really wonder if we have a single legitimate case for anything other than sock_alloc_file()
setting sock->file.  Anyone?
