From: Andrew Morton <akpm@osdl.org>
Subject: Re: kiocb->private is too large for kiocb's on-stack
Date: Mon, 28 Jun 2004 01:12:32 -0700
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <20040628011232.43acd3b8.akpm@osdl.org>
References: <20040628080801.GO21066@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@oss.sgi.com, davem@redhat.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: William Lee Irwin III <wli@holomorphy.com>
In-Reply-To: <20040628080801.GO21066@holomorphy.com>
List-Id: netdev.vger.kernel.org

William Lee Irwin III <wli@holomorphy.com> wrote:
>
> sizeof(struct kiocb) is dangerously large for a structure commonly
> allocated on-stack. This patch converts the 24*sizeof(long) field,
> ->private, to a void pointer for use by file_operations entrypoints.
> A ->dtor() method is added to the kiocb in order to support the release
> of dynamically allocated structures referred to by ->private.
> 
> The sole in-tree users of ->private are async network read/write,
> which are not, in fact, async, and so need not handle preallocated
> ->private as they would need to if ->ki_retry were ever used. The sole
> truly async operations are direct IO pread()/pwrite() which do not
> now use ->ki_retry(). All they would need to do in that case is to
> check for ->private already being allocated for async kiocbs.
> 
> This rips 88B off the stack on 32-bit in the common case.
> 

>  int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
>  {
>  	struct kiocb iocb;
> +	struct sock_iocb siocb;
>  	int ret;
>  
>  	init_sync_kiocb(&iocb, NULL);
> +	iocb.private = &siocb;
>  	ret = __sock_sendmsg(&iocb, sock, msg, size);
>  	if (-EIOCBQUEUED == ret)
>  		ret = wait_on_sync_kiocb(&iocb);

That's so much better than what we had before it ain't funny.

Was this runtime tested?
