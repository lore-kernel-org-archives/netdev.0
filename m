From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take 2] Fix for the fundamental network/block layer race in
 sendfile().
Date: Tue, 08 Apr 2008 14:58:43 +0200
Message-ID: <47FB6C03.3070708@cosmosbay.com>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru> <20080408122545.GA31729@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Jens Axboe <axboe@kernel.dk>,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp28.orange.fr ([80.12.242.99]:62751 "EHLO smtp28.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbYDHM6v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 08:58:51 -0400
In-Reply-To: <20080408122545.GA31729@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> Hi.
>
> Summary of the previous series with this pompous header:
> when sendfile() returns, pages which it sent can still be queued in t=
cp
> stack or hardware, so subsequent write into them will endup in
> corrupting data which will be eventually sent. This concerns all
> ->sendpage() users namely sendfile() and splice().
>
> With this patch it is now guaranteed that data was transferred over t=
he
> wire after splice/sendfile returns.
>
>  =20
1) So a nonblocking operation (O_NDELAY) can become a blocking one now =
?

> This approach (besides the fact that previous one was not 100% correc=
t
> dealing with cloned skbs) uses new destructor field in shared info
> structure (introduced by Rusty, afacs they do not collide), which is
> invoked each time data is about to be released (but before actual
> release of data happens).
>  =20
> Patch works by assigning each page from the sendfile path a couple of
>
>  =20
> pointers: to page itself to differentiate sendfile pages from all
> others and pointer to pipe structure, which wakes up splice code.
> It is safe to assign the same callback for sendfile and non-sendfile
> pages because of above page pointer - pages which do not have it (sla=
b,
> non-sendfile bio layer and others) will not have pipe structure
> dereferenced from private pointers.
>
> P.S. Previous patch was not an April 1 joke as long as this one :)
>
>  =20
Hum, I see you forgot me in CC list, dont try to escape :)
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
>
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 49a9871..1961a46 100644
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
> @@ -695,6 +696,24 @@ sys_writev(unsigned long fd, const struct iovec =
__user *vec, unsigned long vlen)
>  	return ret;
>  }
> =20
> +static void skb_splice_destructor(struct skb_shared_info *shi)
> +{
> +	if (shi->nr_frags) {
> +		int i;
> +		struct pipe_inode_info *pipe;
> +
> +		for (i =3D 0; i < shi->nr_frags; i++) {
> +			struct page *page =3D shi->frags[i].page;
> +
> +			if (page->lru.prev =3D=3D (struct list_head *)page) {
> +				pipe =3D (struct pipe_inode_info *)page->lru.next;
>  =20
    Unless I mistaken, you store in page->lru.next some info to find=20
your pipe pointer, assuming it is unique for this page.

What happens if two threads are doing a splice()/sendfile() using the=20
same underlying (source) file (and same pages in this file)


> +				if (atomic_dec_return(&pipe->god_blessed_us) =3D=3D 0)
> +					wake_up(&pipe->wait);
> +			}
> +		}
> +	}
> +}
> +
>  static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
>  			   size_t count, loff_t max)
>  {
> @@ -703,6 +722,8 @@ static ssize_t do_sendfile(int out_fd, int in_fd,=
 loff_t *ppos,
>  	loff_t pos;
>  	ssize_t retval;
>  	int fput_needed_in, fput_needed_out, fl;
> +	struct sock *sk;
> +	struct socket *sock;
> =20
>  	/*
>  	 * Get input file, and verify that it is ok..
> @@ -762,6 +783,12 @@ static ssize_t do_sendfile(int out_fd, int in_fd=
, loff_t *ppos,
>  		count =3D max - pos;
>  	}
> =20
> +	sock =3D out_file->private_data;
> +	sk =3D sock->sk;
> +
> +	sk->sk_user_data =3D &skb_splice_destructor;
> +	set_bit(SOCK_PRIVATE_CALLBACK, &sock->flags);
> +
>  	fl =3D 0;
>  #if 0
>  	/*
> @@ -775,6 +802,8 @@ static ssize_t do_sendfile(int out_fd, int in_fd,=
 loff_t *ppos,
>  #endif
>  	retval =3D do_splice_direct(in_file, ppos, out_file, count, fl);
> =20
> +	clear_bit(SOCK_PRIVATE_CALLBACK, &sock->flags);
> +
>  	if (retval > 0) {
>  		add_rchar(current, retval);
>  		add_wchar(current, retval);
> diff --git a/fs/splice.c b/fs/splice.c
> index 0670c91..dcda32e 100644
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
> @@ -535,6 +536,8 @@ static int pipe_to_sendpage(struct pipe_inode_inf=
o *pipe,
>  	if (!ret) {
>  		more =3D (sd->flags & SPLICE_F_MORE) || sd->len < sd->total_len;
> =20
> +		buf->page->lru.next =3D (void *)pipe;
>  =20
is it really allowed here, are you the only user ot this page ?
> +		buf->page->lru.prev =3D (void *)buf->page;
>  		ret =3D file->f_op->sendpage(file, buf->page, buf->offset,
>  					   sd->len, &pos, more);
>  	}
> @@ -629,6 +632,9 @@ ssize_t __splice_from_pipe(struct pipe_inode_info=
 *pipe, struct splice_desc *sd,
>  	ret =3D 0;
>  	do_wakeup =3D 0;
>  =20




