From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: Fix for the fundamental network/block layer race in sendfile().
Date: Tue, 01 Apr 2008 20:14:47 +0300
Message-ID: <47F26D87.7020006@kolumbus.fi>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, axboe@kernel.dk,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn1.fre.skanova.net ([81.228.11.168]:49250 "EHLO
	pne-smtpout4-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756287AbYDARZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 13:25:15 -0400
In-Reply-To: <20080401164904.GA2382@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Hi.
>
> Summary of the previous series with this pompous header:
> when sendfile() returns, pages which it sent can still be queued in tcp
> stack or hardware, so subsequent write into them will endup in
> corrupting data which will be eventually sent. This concerns all
> ->sendpage() users namely sendfile() and splice().
>
> We can only safely reuse that pages only when ack is received from the
> remote side, which will force network stack to release pages.
>
> My simple extension allows to hook into data releasing path and perform
> any actions we want. This is achieved by replacing skb->destructor with
> own callback registerd by interested user, for example splice/sendfile
> code. Splice (pipe info structure) in turn is extended to hold atomic
> counter of the pages in flight (without structure size change because of
> alignment issues it has right now), so splice code will sleep when full
> pipe info (->nrbufs pages) was sent, it will wait until number of pages
> in flight hits zero, which is decremented in private splice callback.
>
> Patch was tested with simple send and recv applications, which can be
> found at
> http://tservice.net.ru/~s0mbre/archive/tmp/sendfile_fix/
>
> One has to run them on different machines, since loopback uses a bit
> different scheme (namely page is _never_ copied, so when it is received
> by 'remote' side, it still exists on the 'local' side, so modifications
> will endup in data corruption).
> devfs1# ./recv -a 0.0.0.0 -p 1025 -c 1024
> devfs2# ./send -a devfs1 -p 1025 -f /tmp/test -c 1024
>
> In case of failure you will get this:
> Connected to devfs1:1025.
> /tmp/test/1024 -> devfs1:1025
> Data was corrupted: ab.
>
> after short period of time, where above 'ab' is a hex byte writen into
> mapped file, which has been sent, immediately after senfile()
> returns to userspace.
> Data is supposed to be always zero, and applications should run forever.
> -c parameter specifies number of bytes to be sent in each run of the
> sendfile(). It has to be the same on both machines.
>
> Fix attached, consider for inclusion.
>
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
>
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
>  
>  #include <asm/uaccess.h>
> @@ -703,6 +704,8 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
>  	loff_t pos;
>  	ssize_t retval;
>  	int fput_needed_in, fput_needed_out, fl;
> +	struct sock *sk;
> +	struct socket *sock;
>  
>  	/*
>  	 * Get input file, and verify that it is ok..
> @@ -762,6 +765,12 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
>  		count = max - pos;
>  	}
>  
> +	sock = out_file->private_data;
> +	sk = sock->sk;
> +
> +	sk->sk_user_data = &skb_splice_destructor;
> +	sk->sk_flags |= SO_PRIVATE_CALLBACK;
> +
>  	fl = 0;
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
>  
>  /*
>   * Attempt to steal a page from a pipe buffer. This should perhaps go into
> @@ -535,6 +536,7 @@ static int pipe_to_sendpage(struct pipe_inode_info *pipe,
>  	if (!ret) {
>  		more = (sd->flags & SPLICE_F_MORE) || sd->len < sd->total_len;
>  
> +		buf->page->lru.next = (void *)pipe;
>  		ret = file->f_op->sendpage(file, buf->page, buf->offset,
>  					   sd->len, &pos, more);
>  	}
> @@ -629,6 +631,8 @@ ssize_t __splice_from_pipe(struct pipe_inode_info *pipe, struct splice_desc *sd,
>  	ret = 0;
>  	do_wakeup = 0;
>  
> +	atomic_set(&pipe->god_blessed_us, pipe->nrbufs);
> +
>  	for (;;) {
>  		if (pipe->nrbufs) {
>  			struct pipe_buffer *buf = pipe->bufs + pipe->curbuf;
> @@ -665,12 +669,18 @@ ssize_t __splice_from_pipe(struct pipe_inode_info *pipe, struct splice_desc *sd,
>  					do_wakeup = 1;
>  			}
>  
> -			if (!sd->total_len)
> +			if (!sd->total_len) {
> +				wait_event_interruptible(pipe->wait,
> +					!atomic_read(&pipe->god_blessed_us));
>  				break;
> +			}
>  		}
>  
>  		if (pipe->nrbufs)
>  			continue;
> +
> +		wait_event_interruptible(pipe->wait, !atomic_read(&pipe->god_blessed_us));
> +
>  		if (!pipe->writers)
>  			break;
>  		if (!pipe->waiting_writers) {
> diff --git a/include/asm-x86/socket.h b/include/asm-x86/socket.h
> index 80af9c4..a4b047e 100644
> --- a/include/asm-x86/socket.h
> +++ b/include/asm-x86/socket.h
> @@ -54,4 +54,6 @@
>  
>  #define SO_MARK			36
>  
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
> @@ -862,6 +862,8 @@ extern struct sk_buff		*sock_rmalloc(struct sock *sk,
>  extern void			sock_wfree(struct sk_buff *skb);
>  extern void			sock_rfree(struct sk_buff *skb);
>  
> +extern void skb_splice_destructor(struct sk_buff *skb);
> +
>  extern int			sock_setsockopt(struct socket *sock, int level,
>  						int op, char __user *optval,
>  						int optlen);
> @@ -1168,6 +1170,8 @@ static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
>  	sock_hold(sk);
>  	skb->sk = sk;
>  	skb->destructor = sock_wfree;
> +	if (sk->sk_flags & SO_PRIVATE_CALLBACK)
> +		skb->destructor = sk->sk_user_data;
>  	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
>  }
>  
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 2654c14..0c10581 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -112,6 +112,7 @@
>  #include <linux/tcp.h>
>  #include <linux/init.h>
>  #include <linux/highmem.h>
> +#include <linux/pipe_fs_i.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/system.h>
> @@ -1116,6 +1117,24 @@ void sock_wfree(struct sk_buff *skb)
>  	sock_put(sk);
>  }
>  
> +void skb_splice_destructor(struct sk_buff *skb)
> +{
> +	if (skb_shinfo(skb)->nr_frags) {
> +		int i;
> +		struct pipe_inode_info *pipe;
> +
> +		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +			struct page *page = skb_shinfo(skb)->frags[i].page;
> +
> +			pipe = (struct pipe_inode_info *)page->lru.next;
> +			if (atomic_dec_return(&pipe->god_blessed_us) == 0)
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
>
>
>   
Hi,

Aren't you breaking the other types of splices, like splice to file 
which doesn't have the wakeup thing.

--Mika

