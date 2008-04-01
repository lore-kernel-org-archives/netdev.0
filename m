From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Fix for the fundamental network/block layer race in sendfile().
Date: Tue, 01 Apr 2008 19:19:39 +0200
Message-ID: <47F26EAB.7040900@cosmosbay.com>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, axboe@kernel.dk,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:33948
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755844AbYDARUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 13:20:01 -0400
In-Reply-To: <20080401164904.GA2382@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> Hi.
>=20
> Summary of the previous series with this pompous header:
> when sendfile() returns, pages which it sent can still be queued in t=
cp
> stack or hardware, so subsequent write into them will endup in
> corrupting data which will be eventually sent. This concerns all
> ->sendpage() users namely sendfile() and splice().
>=20
> We can only safely reuse that pages only when ack is received from th=
e
> remote side, which will force network stack to release pages.
>=20
> My simple extension allows to hook into data releasing path and perfo=
rm
> any actions we want. This is achieved by replacing skb->destructor wi=
th
> own callback registerd by interested user, for example splice/sendfil=
e
> code. Splice (pipe info structure) in turn is extended to hold atomic
> counter of the pages in flight (without structure size change because=
 of
> alignment issues it has right now), so splice code will sleep when fu=
ll
> pipe info (->nrbufs pages) was sent, it will wait until number of pag=
es
> in flight hits zero, which is decremented in private splice callback.
>=20
> Patch was tested with simple send and recv applications, which can be
> found at
> http://tservice.net.ru/~s0mbre/archive/tmp/sendfile_fix/
>=20
> One has to run them on different machines, since loopback uses a bit
> different scheme (namely page is _never_ copied, so when it is receiv=
ed
> by 'remote' side, it still exists on the 'local' side, so modificatio=
ns
> will endup in data corruption).
> devfs1# ./recv -a 0.0.0.0 -p 1025 -c 1024
> devfs2# ./send -a devfs1 -p 1025 -f /tmp/test -c 1024
>=20
> In case of failure you will get this:
> Connected to devfs1:1025.
> /tmp/test/1024 -> devfs1:1025
> Data was corrupted: ab.
>=20
> after short period of time, where above 'ab' is a hex byte writen int=
o
> mapped file, which has been sent, immediately after senfile()
> returns to userspace.
> Data is supposed to be always zero, and applications should run forev=
er.
> -c parameter specifies number of bytes to be sent in each run of the
> sendfile(). It has to be the same on both machines.
>=20
> Fix attached, consider for inclusion.
>=20
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
>=20
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 49a9871..8c94e03 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -16,6 +16,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/pagemap.h>
>  #include <linux/splice.h>
> +#include <net/sock.h>
>  #include "read_write.h"
> =20
>  #include <asm/uaccess.h>
> @@ -703,6 +704,8 @@ static ssize_t do_sendfile(int out_fd, int in_fd,=
 loff_t *ppos,
>  	loff_t pos;
>  	ssize_t retval;
>  	int fput_needed_in, fput_needed_out, fl;
> +	struct sock *sk;
> +	struct socket *sock;
> =20
>  	/*
>  	 * Get input file, and verify that it is ok..
> @@ -762,6 +765,12 @@ static ssize_t do_sendfile(int out_fd, int in_fd=
, loff_t *ppos,
>  		count =3D max - pos;
>  	}
> =20
> +	sock =3D out_file->private_data;
> +	sk =3D sock->sk;
> +
> +	sk->sk_user_data =3D &skb_splice_destructor;
> +	sk->sk_flags |=3D SO_PRIVATE_CALLBACK;

Ouch...

this seems very ugly (sorry).

1) Is out_file garanted to be a socket ?

2) SO_PRIVATE_CALLBACK is defined to be 37 later on your patch. Is ORin=
g 37 to=20
sk_flags really working ???

3) So, once a socket has been used for a sendfile(), all subsequent sen=
dmsg()=20
will call skb_splice_destructor ? (I see no clearing of SO_PRIVATE_CALL=
BACK)
  This will probably crash.

4) god_blessed_us name ... Oh I got it, its April the first !!!!


> +
>  	fl =3D 0;
>  #if 0
>  	/*
> diff --git a/fs/splice.c b/fs/splice.c
> index 0670c91..1432b13 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -29,6 +29,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/uio.h>
>  #include <linux/security.h>
> +#include <net/sock.h>
> =20
>  /*
>   * Attempt to steal a page from a pipe buffer. This should perhaps g=
o into
> @@ -535,6 +536,7 @@ static int pipe_to_sendpage(struct pipe_inode_inf=
o *pipe,
>  	if (!ret) {
>  		more =3D (sd->flags & SPLICE_F_MORE) || sd->len < sd->total_len;
> =20
> +		buf->page->lru.next =3D (void *)pipe;
>  		ret =3D file->f_op->sendpage(file, buf->page, buf->offset,
>  					   sd->len, &pos, more);
>  	}
> @@ -629,6 +631,8 @@ ssize_t __splice_from_pipe(struct pipe_inode_info=
 *pipe, struct splice_desc *sd,
>  	ret =3D 0;
>  	do_wakeup =3D 0;
> =20
> +	atomic_set(&pipe->god_blessed_us, pipe->nrbufs);
> +
>  	for (;;) {
>  		if (pipe->nrbufs) {
>  			struct pipe_buffer *buf =3D pipe->bufs + pipe->curbuf;
> @@ -665,12 +669,18 @@ ssize_t __splice_from_pipe(struct pipe_inode_in=
fo *pipe, struct splice_desc *sd,
>  					do_wakeup =3D 1;
>  			}
> =20
> -			if (!sd->total_len)
> +			if (!sd->total_len) {
> +				wait_event_interruptible(pipe->wait,
> +					!atomic_read(&pipe->god_blessed_us));
>  				break;
> +			}
>  		}
> =20
>  		if (pipe->nrbufs)
>  			continue;
> +
> +		wait_event_interruptible(pipe->wait, !atomic_read(&pipe->god_bless=
ed_us));
> +
>  		if (!pipe->writers)
>  			break;
>  		if (!pipe->waiting_writers) {
> diff --git a/include/asm-x86/socket.h b/include/asm-x86/socket.h
> index 80af9c4..a4b047e 100644
> --- a/include/asm-x86/socket.h
> +++ b/include/asm-x86/socket.h
> @@ -54,4 +54,6 @@
> =20
>  #define SO_MARK			36
> =20
> +#define SO_PRIVATE_CALLBACK	37
> +
>  #endif /* _ASM_SOCKET_H */
> diff --git a/include/linux/pipe_fs_i.h b/include/linux/pipe_fs_i.h
> index 8e41202..465405a 100644
> --- a/include/linux/pipe_fs_i.h
> +++ b/include/linux/pipe_fs_i.h
> @@ -51,6 +51,7 @@ struct pipe_inode_info {
>  	unsigned int waiting_writers;
>  	unsigned int r_counter;
>  	unsigned int w_counter;
> +	atomic_t god_blessed_us;
>  	struct fasync_struct *fasync_readers;
>  	struct fasync_struct *fasync_writers;
>  	struct inode *inode;
> diff --git a/include/net/sock.h b/include/net/sock.h
> index fd98760..ac7bc52 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -862,6 +862,8 @@ extern struct sk_buff		*sock_rmalloc(struct sock =
*sk,
>  extern void			sock_wfree(struct sk_buff *skb);
>  extern void			sock_rfree(struct sk_buff *skb);
> =20
> +extern void skb_splice_destructor(struct sk_buff *skb);
> +
>  extern int			sock_setsockopt(struct socket *sock, int level,
>  						int op, char __user *optval,
>  						int optlen);
> @@ -1168,6 +1170,8 @@ static inline void skb_set_owner_w(struct sk_bu=
ff *skb, struct sock *sk)
>  	sock_hold(sk);
>  	skb->sk =3D sk;
>  	skb->destructor =3D sock_wfree;
> +	if (sk->sk_flags & SO_PRIVATE_CALLBACK)
> +		skb->destructor =3D sk->sk_user_data;
>  	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
>  }
> =20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 2654c14..0c10581 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -112,6 +112,7 @@
>  #include <linux/tcp.h>
>  #include <linux/init.h>
>  #include <linux/highmem.h>
> +#include <linux/pipe_fs_i.h>
> =20
>  #include <asm/uaccess.h>
>  #include <asm/system.h>
> @@ -1116,6 +1117,24 @@ void sock_wfree(struct sk_buff *skb)
>  	sock_put(sk);
>  }
> =20
> +void skb_splice_destructor(struct sk_buff *skb)
> +{
> +	if (skb_shinfo(skb)->nr_frags) {
> +		int i;
> +		struct pipe_inode_info *pipe;
> +
> +		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +			struct page *page =3D skb_shinfo(skb)->frags[i].page;
> +
> +			pipe =3D (struct pipe_inode_info *)page->lru.next;
> +			if (atomic_dec_return(&pipe->god_blessed_us) =3D=3D 0)
> +				wake_up(&pipe->wait);
> +		}
> +	}
> +
> +	sock_wfree(skb);
> +}
> +
>  /*
>   * Read buffer destructor automatically called from kfree_skb.
>   */
> @@ -2164,6 +2183,7 @@ EXPORT_SYMBOL(sock_no_socketpair);
>  EXPORT_SYMBOL(sock_rfree);
>  EXPORT_SYMBOL(sock_setsockopt);
>  EXPORT_SYMBOL(sock_wfree);
> +EXPORT_SYMBOL(skb_splice_destructor);
>  EXPORT_SYMBOL(sock_wmalloc);
>  EXPORT_SYMBOL(sock_i_uid);
>  EXPORT_SYMBOL(sock_i_ino);
>=20
>=20

