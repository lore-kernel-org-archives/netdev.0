From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 4 Nov 2015 16:27:35 +0000
Message-ID: <20151104162735.GS22011@ZenIV.linux.org.uk>
References: <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
 <20151022215741.GW22011@ZenIV.linux.org.uk>
 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
 <20151024023054.GZ22011@ZenIV.linux.org.uk>
 <201510270908.t9R9873a001683@room101.nl.oracle.com>
 <562F577E.6000901@oracle.com>
 <20151029145847.GA10859@netbsd.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CBC66C8@AcuExch.aculab.com>
 <20151030210943.GJ22011@ZenIV.linux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D1CBCC02B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'David Holland' <dholland-tech@netbsd.org>,
	Alan Burlison <Alan.Burlison@oracle.com>,
	"Casper.Dik@oracle.com" <Casper.Dik@oracle.com>,
	David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53435 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964795AbbKDQ1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 11:27:52 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBCC02B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 04, 2015 at 03:54:09PM +0000, David Laight wrote:
> > Sigh...  The kernel has no idea when other threads are done with "all
> > io activities using that fd" - it can wait for them to leave the
> > kernel mode, but there's fuck-all it can do about e.g. a userland
> > loop doing write() until there's more data to send.  And no, you can't
> > rely upon them catching EBADF on the next iteration - by the time they
> > get there, close() might very well have returned and open() from yet
> > another thread might've grabbed the same descriptor.  Welcome to your
> > data being written to hell knows what...
> 
> That just means that the application must use dup2() rather than close().
> It must do that anyway since the thread it is trying to stop might be
> sleeping in the system call stub in libc at the time a close() and open()
> happen.

Oh, _lovely_.  So instead of continuation of that write(2) going down
the throat of something opened by unrelated thread, it (starting from a
pretty arbitrary point) will go into the descriptor the closing thread
passed to dup2().  Until it, in turn, gets closed, at which point we
are back to square one.  That, of course, makes it so much better -
whatever had I been thinking about that made me miss that?

> The listening (in this case) thread would need to look at its global
> data to determine that it is supposed to exit, and then close the fd itself.

Right until it crosses into the kernel mode and does descriptor-to-file
lookup, presumably?  Because prior to that point this kernel-side
"protection" oesn't come into play.  In other words, this is inherently
racy, and AFAICS you are the first poster in that thread who disagrees
with that.

_Any_ userland code that would be racy without that kludge of semantics
in close()/dup2() is *still* racy with it.  If that crap gets triggered
at all, the userland code responsible for that is broken.  Said crap
makes the race windows more narrow, but it doesn't really close them.
And IMO it's rather misduided, especially since it's a) quiet and b)
costly as hell.
