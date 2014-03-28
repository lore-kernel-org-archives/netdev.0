From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Fri, 28 Mar 2014 20:35:34 +0000
Message-ID: <87ob0q3vu1.fsf@sable.mobileactivedefense.com>
References: <87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
	<20140326.170514.1793472148242469413.davem@davemloft.net>
	<87a9cc7j1o.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:52545 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752973AbaC1Ufv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:35:51 -0400
In-Reply-To: <87a9cc7j1o.fsf@sable.mobileactivedefense.com> (Rainer Weikusat's
	message of "Wed, 26 Mar 2014 21:21:23 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rainer Weikusat <rw@sable> writes:

[...]

> ---------
> #include <fcntl.h>
> #include <string.h>
> #include <sys/socket.h>
> #include <sys/un.h>
>
> int main(void)
> {
>     struct sockaddr_un sun;
>     int fd;
>
>     fd = socket(AF_UNIX, SOCK_DGRAM, 0);
>     sun.sun_family = AF_UNIX;
>     strncpy(sun.sun_path, "/tmp/bla", sizeof(sun.sun_path));
>     bind(fd, (struct sockaddr *)&sun, sizeof(sun));
>
>     if (fork() == 0) read(fd, &fd, sizeof(fd));
>
>     sleep(1);
>
>     fcntl(fd, F_SETFL, O_NONBLOCK);
>     read(fd, &fd, sizeof(fd));
>
>     return 0;
> }
> --------

In the interest of fairness, here's a more realistic test case (tested
on 3.2.9 and 3.2.54):

--------------
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

    if (fork() == 0) recv(fd, &fd, sizeof(fd), 0);

    sleep(1);

    recv(fd, &fd, sizeof(fd), MSG_DONTWAIT);

    return 0;
}
