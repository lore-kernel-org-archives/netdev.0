From: Andi Kleen <ak@suse.de>
Subject: Re: shutdown() and SHUT_RD on TCP sockets - broken?
Date: Tue, 8 Jul 2003 18:55:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708185504.385c0d55.ak@suse.de>
References: <27084.1057680554@www6.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mtk-lists@gmx.net
In-Reply-To: <27084.1057680554@www6.gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 8 Jul 2003 18:09:14 +0200 (MEST)
mtk-lists@gmx.net wrote:

> 1. If we perform a read() on the socket and there is no data, then 0
> (EOF) is (immediately) returned.  (This is what I expected.)
> 
> 2. However, the peer can still write() to the socket, and afterwards
> we can read() that data from the socket, even though the reading half
> of the socket should be shut down.  Instead of this behaviour, I
> expected the read() to continue to return 0 as in point 1.  This is what we
> see for example in FreeBSD 4.8, Tru64 5.1B, and HP/UX 11.  

The problem is that it adds a new check to the input path. It's not clear how
the check can be done outside the fast path (one way would be to shrink
the window forcedly and drop the receiver into slow path, but that would
be a severe protocol violation if the shrunk window leaks out with 
some ACK). I don't think it's a good idea to add a check for such 
an obscure situation to the fast path.
> 
> 3. (A side point.) Looking at Stevens UNPv1, p161, there is a statement
> that after a SHUT_RD, "any data for a TCP socket is acknowledged and then
> silently discarded".  This implies to me that the sender could keep on
> writing to the socket and never block.  However, on Linux, if the peer
> keeps sending to a socket, then eventually (the channel is filled and) it
> blocks.  I see that this also occurs on FreeBSD 4.8, Tru64 5.1B, HP/UX 11

That's because the data is not discarded so the window fills. 

> and Solaris 8.  Have I misunderstood Stevens, or has something changed
> since the implementation he described (or was his statement wrong)?  (In

Probably Stevens was confused.

-Andi
