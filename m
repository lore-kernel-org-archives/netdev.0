From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 23 Oct 2015 17:40:59 +0100
Message-ID: <562A631B.6060207@oracle.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>	 <20151021.182955.1434243485706993231.davem@davemloft.net>	 <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>	 <20151022060304.GQ22011@ZenIV.linux.org.uk>	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>	 <20151022172146.GS22011@ZenIV.linux.org.uk>	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>	 <20151022190701.GV22011@ZenIV.linux.org.uk>	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>	 <20151022215741.GW22011@ZenIV.linux.org.uk>	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>	 <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>	 <562A37A3.8000705@oracle.com>	 <1445610118.22974.153.camel@edumazet-glaptop2.roam.corp.google.com>	 <562A563D.6020600@oracle.com>	 <1445616011.22974
 .158.camel@edumazet-glaptop2.roam.corp.google.com> <1445617163.22974.163.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43612 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbbJWQlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 12:41:11 -0400
In-Reply-To: <1445617163.22974.163.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/10/2015 17:19, Eric Dumazet wrote:

>>> The AF_UNIX poll one? No, I don't have the means to do so, and in any
>>> case that's not a POSIX issue, just a plain bug. I'm happy to log a bug
>>> if that helps.
>
> BTW, there is no kernel bug here. POSIX poll() man page says :
>
> POLLOUT
>      Normal data may be written without blocking.
>
> If you attempt to write on a listener, write() does _not_ block and
> returns -1, which seems correct behavior to me, in accordance with man
> page.

Except of course data may not be written, because an attempt to actually 
do so fails, because the socket is in the listen state, is not connected 
and therefore no attempt to write to it could ever succeed. The only bit 
of the required behaviour that the current AF_UNIX poll implementation 
actually gets right is the "without blocking" bit, and that's only the 
case because the failure is detected immediately and the write call 
returns immediately with an error.

> socket(PF_LOCAL, SOCK_STREAM, 0)        = 3
> bind(3, {sa_family=AF_LOCAL, sun_path=@""}, 110) = 0
> listen(3, 10)                           = 0
> write(3, "test", 4)                     = -1 ENOTCONN (Transport endpoint is not connected)
>
> Could you point out which part of POSIX is mandating that af_unix
> listener MUST filter out POLLOUT ?

"A file descriptor for a socket that is listening for connections shall 
indicate that it is ready for reading, once connections are available. A 
file descriptor for a socket that is connecting asynchronously shall 
indicate that it is ready for writing, once a connection has been 
established."

If POSIX had to explicitly list every possible thing that 
implementations *should not* do rather than just those that they 
*should* do then it would be even more unwieldy than it already is.

And if what you are asserting is correct, why isn't the AF_INET 
behaviour the same as the AF_UNIX behaviour?

-- 
Alan Burlison
--
