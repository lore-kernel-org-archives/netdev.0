From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Thu, 18 Nov 2004 14:02:57 -0500
Message-ID: <20041118190257.GA7084@calma.pair.com>
References: <20041109205358.GA64015@calma.pair.com> <E1CRdBr-0001P2-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CRdBr-0001P2-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> /proc/net/tcp is an obsolete interface.  It is inherently unreliable
> in that a record may be read using two read(2) calls.  Those two calls
> may end up looking at two different records.
> 
> So please use the netlink interface or ss(8) from the iproute package.

OK, so just out of sheer morbid curiousity, I added an ioctl which will
accept 4 parameters (the address/port pairs), and will return the user id
associated with that socket.  I also changed pidentd to call this ioctl
instead of looking at /proc/net/tcp.  This should theoretically get rid
of all race conditions.

However, the problem still happens.  We see many instances of the kernel 
reporting the wrong user id.  What is even more interesting is that we added
a retry loop, and many times the problem goes away after re-trying.  Sometimes
the first retry gets the correct username, and sometimes it takes 4 or 5 
retries.  So there is definitely some sort of race condition going on here.
We have verified that when this problem occurs the process holding the
socket endpoint in question is still running, so it isn't some problem caused
by doing an identd lookup after the other end has gone away.

Does anybody have any idea why the userid associated with the socket's inode
might be changing mid-stream?  What are the chances of a defect where two
sockets are using the same inode memory or something like that?

Chad
