From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 4 Nov 2015 15:54:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBCC02B@AcuExch.aculab.com>
References: <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
 <20151022190701.GV22011@ZenIV.linux.org.uk>
 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
 <20151022215741.GW22011@ZenIV.linux.org.uk>
 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
 <20151024023054.GZ22011@ZenIV.linux.org.uk>
 <201510270908.t9R9873a001683@room101.nl.oracle.com>
 <562F577E.6000901@oracle.com> <20151029145847.GA10859@netbsd.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CBC66C8@AcuExch.aculab.com>
 <20151030210943.GJ22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'David Holland' <dholland-tech@netbsd.org>,
	Alan Burlison <Alan.Burlison@oracle.com>,
	"Casper.Dik@oracle.com" <Casper.Dik@oracle.com>,
	David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Al Viro' <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:58089 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbbKDPzS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 10:55:18 -0500
In-Reply-To: <20151030210943.GJ22011@ZenIV.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro
> Sent: 30 October 2015 21:10
> On Fri, Oct 30, 2015 at 05:43:21PM +0000, David Laight wrote:
> 
> > ISTM that the correct call should be listen(fd, 0);
> > Although that doesn't help a thread stuck in recvmsg() for a datagram.
> >
> > It is also tempting to think that close(fd) should sleep until all
> > io activities using that fd have completed - whether or not blocking
> > calls are woken.
> 
> Sigh...  The kernel has no idea when other threads are done with "all
> io activities using that fd" - it can wait for them to leave the
> kernel mode, but there's fuck-all it can do about e.g. a userland
> loop doing write() until there's more data to send.  And no, you can't
> rely upon them catching EBADF on the next iteration - by the time they
> get there, close() might very well have returned and open() from yet
> another thread might've grabbed the same descriptor.  Welcome to your
> data being written to hell knows what...

That just means that the application must use dup2() rather than close().
It must do that anyway since the thread it is trying to stop might be
sleeping in the system call stub in libc at the time a close() and open()
happen.
The listening (in this case) thread would need to look at its global
data to determine that it is supposed to exit, and then close the fd itself.

	David
