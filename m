From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Sat, 11 Feb 2017 20:37:06 +0100
Message-ID: <6129494.xvkFqTsVzW@debian64>
References: <20160728012253.GT2356@ZenIV.linux.org.uk> <20170210081126.GA14157@ZenIV.linux.org.uk> <20170210214513.GA8937@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        Alan Curry <rlwinm@sdf.org>, alexmcwhirter@triadic.us,
        David Miller <davem@davemloft.net>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36025 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdBKTjU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 14:39:20 -0500
Received: by mail-wr0-f196.google.com with SMTP id k90so18576775wrc.3
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2017 11:39:19 -0800 (PST)
In-Reply-To: <20170210214513.GA8937@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, February 10, 2017 9:45:13 PM CET Al Viro wrote:
> On Tue, Aug 09, 2016 at 03:58:36PM +0100, Al Viro wrote:
> 
> > Actually returning to the original behaviour would be "restore ->msg_iter
> > if we tried skb_copy_and_csum_datagram() and failed for any reason".  Which
> > would be bloody inconsistent wrt EFAULT, since the other branch (chunk
> > large enough to cover the entire recvmsg()) will copy as much as it can
> > and (in old kernel) drain iovec or (on the current one) leave iov_iter
> > advance unreverted.
> 
> To resurrect the old thread: the problem is still there.  Namely, csum
> mismatch on packet should leave the iterator as it had been.  That much
> is clear; the question is what should be done on EFAULT halfway through.
Thanks for being very persistent with this. The original problem report 
was just about the data corruption issue. I think everyone involved agrees
that restoring the iterator for cases where the checksum check failed
is definitely the right action. (And of course: It is high time that the
data corruption issue gets fixed).

However, it's as you have said earlier about -EFAULT:
"[...] That's why I hadn't simply ACKed the proposed patch; it very much smells
like we have something bogus with EFAULT handling in the whole area."

Because from the explanations that: (*) "-EFAULT can happen at any point, with
zero warning before you get actual page fault when copying the data and
have handle_mm_fault() return VM_FAULT_ERROR. "

I think if you follow through with this argument. You have the problem of:
How to handle EFAULT from skb_copy_datagram_* (and all it's "wrappers")?

Because on one hand, the iovec could be partially bad. I remember that 
the application could do the following shenanigans during recvmsg: 
 - mprotect() could've flipped page read-only and back to read-write.
 - Or truncate() could've shortened the mmapped file,
 - etc.

In this case the error should be propagated back to the userspace.

But OTOH, it could just be a temporary failure (*) and restoring the
iovec and trying again is needed.

Is this a correct/complete assessment of the problem at hand? Or did
I make a mistake / wrong assumption in there?

> Semantics of both csum and non-csum skb_copy_datagram_msg() variants in
> EFAULT case is an interesting question.  None of that family report
                                                              support?
> partial copy; it's full or -EFAULT.  So for the sake of basic sanity
> it would be better to leave iterator in the original state when that
> kind of thing happens.  On the other hand, quite a few callers don't
> care about the state of iterator after that and I wonder if the overhead
> would be sensitive.  OTTH, the overhead in question is "save 5 words into
> local variable and don't use it in the normal case" - in the code that
> copies an skb worth of data.
> 
> AFAICS, the following gives consistent (and minimally surprising) semantics,
> as well as fixing the outright bug with iov_iter left advanced in case of csum
> errors.  Comments?

I'm looking at:
<http://lxr.free-electrons.com/source/net/ipv4/tcp_input.c#L4668>
<http://lxr.free-electrons.com/source/net/ipv4/tcp_input.c#L5232>
<http://lxr.free-electrons.com/source/net/ipv4/tcp_input.c#L5465>

>From what I can see, the tcp functions tcp_data_queue(),
tcp_copy_to_iovec() and tcp_rcv_established() would need to be
extended to handle EFAULT. Because if the iovec is restored
and the application did something bad (mprotect(), truncate(),
 ...), this code would sort of loop?

If this is the case: How many retries do we want, before we can
say it is a permament failure (and abort)?

Regards,
Christian

[...]
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index f1adddc1c5ac..ee8d962373af 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3060,8 +3060,17 @@ struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags, int noblock,
>  				  int *err);
>  unsigned int datagram_poll(struct file *file, struct socket *sock,
>  			   struct poll_table_struct *wait);
> -int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
> +int __skb_copy_datagram_iter(const struct sk_buff *from, int offset,
>  			   struct iov_iter *to, int size);
> +static inline int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
> +					struct iov_iter *to, int size)
> +{
> +	struct iov_iter saved = *to;
> +	int res = __skb_copy_datagram_iter(from, offset, to, size);
> +	if (unlikely(res))
> +		*to = saved;
> +	return res;
> +}
>  static inline int skb_copy_datagram_msg(const struct sk_buff *from, int offset,
>  					struct msghdr *msg, int size)
>  {
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index ea633342ab0d..33ff2046dda1 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -394,7 +394,7 @@ EXPORT_SYMBOL(skb_kill_datagram);
>   *	@to: iovec iterator to copy to
>   *	@len: amount of data to copy from buffer to iovec
>   */
> -int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
> +int __skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
>  			   struct iov_iter *to, int len)
>  {
>  	int start = skb_headlen(skb);
> @@ -445,7 +445,7 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
>  		if ((copy = end - offset) > 0) {
>  			if (copy > len)
>  				copy = len;
> -			if (skb_copy_datagram_iter(frag_iter, offset - start,
> +			if (__skb_copy_datagram_iter(frag_iter, offset - start,
>  						   to, copy))
>  				goto fault;
>  			if ((len -= copy) == 0)
> @@ -471,7 +471,7 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
>  
>  	return 0;
>  }
> -EXPORT_SYMBOL(skb_copy_datagram_iter);
> +EXPORT_SYMBOL(__skb_copy_datagram_iter);
>  
>  /**
>   *	skb_copy_datagram_from_iter - Copy a datagram from an iov_iter.
> @@ -750,14 +750,16 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
>  {
>  	__wsum csum;
>  	int chunk = skb->len - hlen;
> +	struct iov_iter saved;
>  
>  	if (!chunk)
>  		return 0;
>  
> +	saved = msg->msg_iter;
>  	if (msg_data_left(msg) < chunk) {
>  		if (__skb_checksum_complete(skb))
>  			goto csum_error;
> -		if (skb_copy_datagram_msg(skb, hlen, msg, chunk))
> +		if (__skb_copy_datagram_iter(skb, hlen, &msg->msg_iter, chunk))
>  			goto fault;
>  	} else {
>  		csum = csum_partial(skb->data, hlen, skb->csum);
> @@ -771,8 +773,10 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
>  	}
>  	return 0;
>  csum_error:
> +	msg->msg_iter = saved;
>  	return -EINVAL;
>  fault:
> +	msg->msg_iter = saved;
>  	return -EFAULT;
>  }
>  EXPORT_SYMBOL(skb_copy_and_csum_datagram_msg);

You mentioned "overhead" a few times. I tried to measure it with
iperf3 over loopback on a i7-4770. I lowered the MTU to 1500 in 
the hope to see see any difference and It still was very minute: 
188.33 GiB (without) vs 187.89 GiB (patched) for 100 seconds TCP
over IPv4. Of course, I would like to hear more results. Are 
there any special settings that could be interesting and worthwile?
