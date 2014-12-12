From: Florian Westphal <fw@strlen.de>
Subject: Re: [WTF?] random test in netlink_sendmsg()
Date: Fri, 12 Dec 2014 22:50:17 +0100
Message-ID: <20141212215017.GB3624@breakpoint.cc>
References: <20141128062315.GC29748@ZenIV.linux.org.uk>
 <20141212.153433.1675057029307550538.davem@davemloft.net>
 <20141212213242.GE22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34983 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751132AbaLLVu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 16:50:28 -0500
Content-Disposition: inline
In-Reply-To: <20141212213242.GE22149@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> wrote:
> On Fri, Dec 12, 2014 at 03:34:33PM -0500, David Miller wrote:
> > > 	What is that check trying to do?  Is that simply missing
> > > "(msg->msg_iovlen > 0) &&"?  And why on the Earth didn't it simply use
> > > zero msg_iovlen as the indicator, instead of messing with iovec contents?
> > > Obviously too late to change, but... ouch.
> > 
> > I think it's simply trying to say: if nothing in the given iovec, use
> > the mmap() netlink area for the data.
> > 
> > I cannot vouch for the correctness of this test.
> > 
> > If we take the netlink_mmap_sendmsg() path, msg->msg_iov is not
> > accessed at all, so it cannot be a huge problem.
> 
> Yes, but decision whether to take that path or not is random in case of
> msg_iovlen being 0...
> 
> What do we want sendmsg(fd, &msg, 0) to do when fd is AF_NETLINK socket
> that had setsockopt(fd, SOL_NETLINK, NETLINK_TX_RING, ...) successfully done
> to it and msg.msg_iovlen is 0?  Userland ABI question

IIRC userland, after filling txring with at least one new netlink
message, needs to call this to tell kernel to start processing the
messages in the tx ring.

> a security hole there" one...  As it is, it might decide to do
> netlink_mmap_sendmsg() or it might decide to act as if we hadn't done
> NETLINK_TX_RING at all.

It should definitely be netlink_mmap_sendmsg() to commence messsage
processing.
