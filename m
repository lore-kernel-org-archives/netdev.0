From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Wed, 26 Mar 2014 22:06:49 +0000
Message-ID: <8761n07gxy.fsf@sable.mobileactivedefense.com>
References: <87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
	<20140326.170514.1793472148242469413.davem@davemloft.net>
	<87a9cc7j1o.fsf@sable.mobileactivedefense.com>
	<1395870280.12610.252.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:52381 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754185AbaCZWHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 18:07:03 -0400
In-Reply-To: <1395870280.12610.252.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 26 Mar 2014 14:44:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Wed, 2014-03-26 at 21:21 +0000, Rainer Weikusat wrote:
>> BTW, here's the program with the O_NONBLOCK read call which blocks until
>> the end of electricity, at least on 3.2.9:
>> 
>> ---------
>> #include <fcntl.h>
>> #include <string.h>
>> #include <sys/socket.h>
>> #include <sys/un.h>
>> 
>> int main(void)
>> {
>>     struct sockaddr_un sun;
>>     int fd;
>> 
>>     fd = socket(AF_UNIX, SOCK_DGRAM, 0);
>>     sun.sun_family = AF_UNIX;
>>     strncpy(sun.sun_path, "/tmp/bla", sizeof(sun.sun_path));
>>     bind(fd, (struct sockaddr *)&sun, sizeof(sun));
>> 
>>     if (fork() == 0) read(fd, &fd, sizeof(fd));
>> 
>>     sleep(1);
>> 
>>     fcntl(fd, F_SETFL, O_NONBLOCK);
>>     read(fd, &fd, sizeof(fd));
>> 
>>     return 0;
>> }
>
> Sure, O_NONBLOCK is translated into MSG_NOWAIT one time per socket
> syscall. 
>
> Once we block, we don't automatically unblock if another thread change
> the file flag.

That would be a seriously bizarre idea. The thread of execution which
does the supposed-to-be-non-blocking call shouldn't become blocked for
an indefinite time. Which means it should not wait indefinitely for a
thread which - in turn - waits indefinitely for an external event (and
hence, the original problem should never have existed to begin with as
there would neither be an opportunity nor a reason to interrupt in the
non-blocking case).

BTW, while these are things which are of some interest to me (even of
some professional interest), I don't exactly get paid for these kind of
discussions, have some real work to do, and the way people interact on
LKML is seriously more aggressive then I can stand for a prolonged time,
so can we please end this discussion here while it - if only for a
change - hasn't yet degraded into an all out mutual extermination fight?
