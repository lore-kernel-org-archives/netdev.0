From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [WTF?] random test in netlink_sendmsg()
Date: Fri, 12 Dec 2014 21:32:43 +0000
Message-ID: <20141212213242.GE22149@ZenIV.linux.org.uk>
References: <20141128062315.GC29748@ZenIV.linux.org.uk>
 <20141212.153433.1675057029307550538.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:52571 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaLLVcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 16:32:46 -0500
Content-Disposition: inline
In-Reply-To: <20141212.153433.1675057029307550538.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 03:34:33PM -0500, David Miller wrote:
> > 	What is that check trying to do?  Is that simply missing
> > "(msg->msg_iovlen > 0) &&"?  And why on the Earth didn't it simply use
> > zero msg_iovlen as the indicator, instead of messing with iovec contents?
> > Obviously too late to change, but... ouch.
> 
> I think it's simply trying to say: if nothing in the given iovec, use
> the mmap() netlink area for the data.
> 
> I cannot vouch for the correctness of this test.
> 
> If we take the netlink_mmap_sendmsg() path, msg->msg_iov is not
> accessed at all, so it cannot be a huge problem.

Yes, but decision whether to take that path or not is random in case of
msg_iovlen being 0...

What do we want sendmsg(fd, &msg, 0) to do when fd is AF_NETLINK socket
that had setsockopt(fd, SOL_NETLINK, NETLINK_TX_RING, ...) successfully done
to it and msg.msg_iovlen is 0?  Userland ABI question - not a "do we have
a security hole there" one...  As it is, it might decide to do
netlink_mmap_sendmsg() or it might decide to act as if we hadn't done
NETLINK_TX_RING at all.  In _both_ cases it won't try to dereference
kernel-side ->msg_iov[0].iov_base - the former won't look at msg_iov at all,
the latter will ask to copy 0 bytes from it, which will succeed and do nothing
whatsoever.  Which path is taken depends on whether an uninitialized array
on stack frame of ___sys_sendmsg() happens to begin with NULL.

IMO that's bogus - behaviour ought to be at least deterministic...
