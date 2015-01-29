From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] net: remove sock_iocb
Date: Thu, 29 Jan 2015 07:57:21 +0000
Message-ID: <20150129075721.GD29656@ZenIV.linux.org.uk>
References: <1422464693-7827-1-git-send-email-hch@lst.de>
 <20150128.232211.1157376728217761804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49291 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbbA2H5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 02:57:23 -0500
Content-Disposition: inline
In-Reply-To: <20150128.232211.1157376728217761804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2015 at 11:22:11PM -0800, David Miller wrote:
> From: Christoph Hellwig <hch@lst.de>
> Date: Wed, 28 Jan 2015 18:04:53 +0100
> 
> > The sock_iocb structure is allocate on stack for each read/write-like
> > operation on sockets, and contains various fields of which only the
> > embedded msghdr and sometimes a pointer to the scm_cookie is ever used.
> > Get rid of the sock_iocb and put a msghdr directly on the stack and pass
> > the scm_cookie explicitly to netlink_mmap_sendmsg.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Looks good, applied, thanks.

You know, that's getting _really_ interesting.  The thing is, now
there's only one ->sendmsg() instance using iocb argument at all,
and it's a really weird one.  TIPC.  Which only compares it with
NULL, and that - to tell the normal calls (== done by sock_sendmsg()
et.al.) from tipc_{accept,connect}()-generated ones.  And the way
it's used is
        if (iocb)
                lock_sock(sk);
in tipc_send_stream().  IOW, "tipc_accept() and tipc_connect() would like
to use the guts of tipc_send_stream(), but they are already holding the
socket locked; let's just pass NULL iocb (which net/socket.c never does)
to tell it to leave the fucking lock alone, thank you very much".

And no ->recvmsg() are using iocb at all now.  How about we take the
guts of tipc_send_stream() into a helper function and have tipc_accept/connect
use _that_?  Then we could drop iocb argument completely and for ->sendmsg()
it would be the difference between 4 and 3 arguments, which has interesting
effects on certain register-starved architectures...

While we are at it, size (both for sendmsg and recvmsg) is always equal to
iov_iter_count(&msg->msg_iter), so that's not the only redundant argument
there...

Comments?
