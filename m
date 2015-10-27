From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 10:52:46 +0000
Message-ID: <562F577E.6000901@oracle.com>
References: <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk> <20151022060304.GQ22011@ZenIV.linux.org.uk> <201510220634.t9M6YJLD017883@room101.nl.oracle.com> <20151022172146.GS22011@ZenIV.linux.org.uk> <201510221824.t9MIOp6n003978@room101.nl.oracle.com> <20151022190701.GV22011@ZenIV.linux.org.uk> <201510221951.t9MJp5LC005892@room101.nl.oracle.com> <20151022215741.GW22011@ZenIV.linux.org.uk> <201510230952.t9N9qYZJ021998@room101.nl.oracle.com> <20151024023054.GZ22011@ZenIV.linux.org.uk> <201510270908.t9R9873a001683@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44344 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbbJ0Kw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 06:52:56 -0400
In-Reply-To: <201510270908.t9R9873a001683@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/10/2015 09:08, Casper.Dik@oracle.com wrote:

> Generally I wouldn't see that as a problem, but in the case of a socket
> blocking on accept indefinitely, I do see it as a problem especially as
> the thread actually wants to stop listening.
>
> But in general, this is basically a problem with the application: the file
> descriptor space is shared between threads and having one thread sniping
> at open files, you do have a problem and whatever the kernel does in that
> case perhaps doesn't matter all that much: the application needs to be
> fixed anyway.

The scenario in Hadoop is that the FD is being used by a thread that's 
waiting in accept and another thread wants to shut it down, e.g. because 
the application is terminating and needs to stop all threads cleanly. I 
agree the use of shutdown()+close() on Linux or dup2() on Solaris is 
pretty much an application-level hack - the concern in both cases is 
that the file descriptor that's being used in the accept() might be 
recycled by another thread. However that just begs the question of why 
the FD isn't properly encapsulated by the application in a singleton 
object, with the required shut down semantics provided by having a 
mechanism to invalidate the singleton and its contained FD.

There are other mechanisms that could be used to do a clean shutdown 
that don't require the OS to provide workarounds for arguably broken 
application behaviour, for example by setting a 'shutdown' flag in the 
object and then doing a dummy connect() to the accepting FD to kick it 
off the accept() and thereby getting it to re-check the 'shutdown' flag 
and not re-enter the accept().

If the object encapsulating a FD is invalidated and that prevents the FD 
being used any more because the only access is via that object, then it 
simply doesn't matter if the FD is reused elsewhere, there can be no 
race so a complicated, platform-dependent dance isn't needed.

Unfortunately Hadoop isn't the only thing that pulls the shutdown() 
trick, so I don't think there's a simple fix for this, as discussed 
earlier in the thread. Having said that, if close() on Linux also did an 
implicit shutdown() it would mean that well-written applications that 
handled the scoping, sharing and reuse of FDs properly could just call 
close() and have it work the same way across *NIX platforms.

-- 
Alan Burlison
--
