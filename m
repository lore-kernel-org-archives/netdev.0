From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Wed, 26 Mar 2014 21:21:23 +0000
Message-ID: <87a9cc7j1o.fsf@sable.mobileactivedefense.com>
References: <87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
	<20140326.170514.1793472148242469413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:57627 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753544AbaCZVVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 17:21:36 -0400
In-Reply-To: <20140326.170514.1793472148242469413.davem@davemloft.net> (David
	Miller's message of "Wed, 26 Mar 2014 17:05:14 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>:
>> As I already wrote, this is a theoretical problem with no really
>> satisfactory solution minus noting that both 'nonblocking sockets' and
>> 'multithreaded kernels' are somewhat alien concepts when considering the
>> system where EINTR originated (AFAIK).
>
> I completely disagree.

And I "completely disagree" with having written the text above, that is
minus the "reporting EAGAIN when the call was really interrupted by a
signal is inaccurate" and "for pragmatic reasons, the kernel should
behave in line with common expectations about its behaviour" parts which
means

a) This is an 'interesting theoretical problem to me' (but maybe not to
   you)

b) my suggestion would be to apply the patch regardless of it.

BTW, here's the program with the O_NONBLOCK read call which blocks until
the end of electricity, at least on 3.2.9:

---------
#include <fcntl.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>

int main(void)
{
    struct sockaddr_un sun;
    int fd;

    fd = socket(AF_UNIX, SOCK_DGRAM, 0);
    sun.sun_family = AF_UNIX;
    strncpy(sun.sun_path, "/tmp/bla", sizeof(sun.sun_path));
    bind(fd, (struct sockaddr *)&sun, sizeof(sun));

    if (fork() == 0) read(fd, &fd, sizeof(fd));

    sleep(1);

    fcntl(fd, F_SETFL, O_NONBLOCK);
    read(fd, &fd, sizeof(fd));

    return 0;
}
--------
