From: Casper.Dik@oracle.com
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Tue, 27 Oct 2015 10:08:07 +0100
Message-ID: <201510270908.t9R9873a001683@room101.nl.oracle.com>
References: <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk> <20151022060304.GQ22011@ZenIV.linux.org.uk> <201510220634.t9M6YJLD017883@room101.nl.oracle.com> <20151022172146.GS22011@ZenIV.linux.org.uk> <201510221824.t9MIOp6n003978@room101.nl.oracle.com> <20151022190701.GV22011@ZenIV.linux.org.uk> <201510221951.t9MJp5LC005892@room101.nl.oracle.com> <20151022215741.GW22011@ZenIV.linux.org.uk> <201510230952.t9N9qYZJ021998@room101.nl.oracle.com> <20151024023054.GZ22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39353 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbbJ0JYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 05:24:14 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9R9OD5v024268
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 09:24:13 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by aserv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t9R9BKT4012335
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 09:24:12 GMT
In-Reply-To: <20151024023054.GZ22011@ZenIV.linux.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>And no, I'm not fond of such irregular ways to pass file descriptors, but
>we can't kill ioctl(2) with all weirdness hiding behind it, more's the pity...

Yeah, there are a number of calls which supposed work on one but have a 
second argument which is also a file descriptor; mostly part of ioctl().

>> In those specific cases where a system call needs to convert a file 
>> descriptor to a file pointer, there is only one routines which can be used.
>
>Obviously, but the problem is deadlock avoidance using it.

The Solaris algorithm is quite different and as such there is no chance of 
having a deadlock using that function (there is a bunch of functions)


>The memory footprint is really scary.  Bitmaps are pretty much noise, but
>blowing it by factor of 8 on normal 64bit (or 16 on something like Itanic -
>or Venus for that matter, which is more relevant for you guys)

Fair enough.  I think we have some systems with a larger cache line.

>Said that, what's the point of "close won't return until..."?  After all,
>you can't guarantee that thread with cancelled syscall won't lose CPU
>immediately upon return to userland, so it *can't* make any assumptions
>about the descriptor not having been already reused.  I don't get it - what
>does that buy for userland code?

Generally I wouldn't see that as a problem, but in the case of a socket 
blocking on accept indefinitely, I do see it as a problem especially as 
the thread actually wants to stop listening.

But in general, this is basically a problem with the application: the file 
descriptor space is shared between threads and having one thread sniping 
at open files, you do have a problem and whatever the kernel does in that 
case perhaps doesn't matter all that much: the application needs to be 
fixed anyway.

Casper
