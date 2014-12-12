From: David Miller <davem@davemloft.net>
Subject: Re: [WTF?] random test in netlink_sendmsg()
Date: Fri, 12 Dec 2014 15:34:33 -0500 (EST)
Message-ID: <20141212.153433.1675057029307550538.davem@davemloft.net>
References: <20141128062315.GC29748@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966672AbaLLUef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 15:34:35 -0500
In-Reply-To: <20141128062315.GC29748@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Fri, 28 Nov 2014 06:23:15 +0000

> 	In netlink_sendmsg() we have the following:
> 
>         if (netlink_tx_is_mmaped(sk) &&
>             msg->msg_iov->iov_base == NULL) {
>                 err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
>                                            siocb);
>                 goto out;
>         }
> 
> Now, suppose sendmsg(2) is called with msg.msg_iovlen == 0.  We'll have
> ->msg_iov in kernel-side copy pointing at the uninitialized array in
> stack frame of ___sys_sendmsg() - neither new nor old code touches elements
> past the first msg_iovlen ones.  So in that case it checks if an
> uninitialized word on stack is zero.
> 
> 	What is that check trying to do?  Is that simply missing
> "(msg->msg_iovlen > 0) &&"?  And why on the Earth didn't it simply use
> zero msg_iovlen as the indicator, instead of messing with iovec contents?
> Obviously too late to change, but... ouch.

I think it's simply trying to say: if nothing in the given iovec, use
the mmap() netlink area for the data.

I cannot vouch for the correctness of this test.

If we take the netlink_mmap_sendmsg() path, msg->msg_iov is not
accessed at all, so it cannot be a huge problem.
