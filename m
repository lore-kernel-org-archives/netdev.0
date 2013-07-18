From: Patrick McHardy <kaber@trash.net>
Subject: Re: buggy check in netlink_mmap_sendmsg()
Date: Thu, 18 Jul 2013 13:22:34 +0200
Message-ID: <20130718111358.GA27488@macbook.localnet>
References: <20130714093619.GH4165@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50021 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757889Ab3GRLcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 07:32:21 -0400
Content-Disposition: inline
In-Reply-To: <20130714093619.GH4165@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 14, 2013 at 10:36:19AM +0100, Al Viro wrote:
> This
>         /* Netlink messages are validated by the receiver before processing.
>          * In order to avoid userspace changing the contents of the message
>          * after validation, the socket and the ring may only be used by a
>          * single process, otherwise we fall back to copying.
>          */
>         if (atomic_long_read(&sk->sk_socket->file->f_count) > 2 ||  
>             atomic_read(&nlk->mapped) > 1)
>                 excl = false;
> looks very odd.  For one thing, descriptor table may be shared, with
> one thread calling sendmsg() (which gives f_count equal to 2), while
> another calls mmap() just as the first one gets past that check.

Another thread calling mmap() should be fine since validation, processing
and mmap() all happen under the pg_vec_lock mutex.

> Moreover, we might very well have the damn thing mmapped, then clone(2)
> creating another thread that shares address space, but not the descriptor
> table.  Child closes the socket descriptor it got, then parent does
> sendmsg(2) (f_count == 2, again, since this time descriptor table isn't
> shared and sendmsg(2) doesn't grab a reference and we have 1 from descriptor
> table and 1 from mapping).  Again, the child has it mapped and can play
> with it as it wishes...

This is unfortunately not my area of expertise. Let me look into how we
can prevent this.
