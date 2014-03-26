From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return
 -EINTR
Date: Wed, 26 Mar 2014 14:44:40 -0700
Message-ID: <1395870280.12610.252.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87zjkd802t.fsf@sable.mobileactivedefense.com>
	 <1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87y4zw7ngi.fsf@sable.mobileactivedefense.com>
	 <20140326.170514.1793472148242469413.davem@davemloft.net>
	 <87a9cc7j1o.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:40677 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755910AbaCZVom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 17:44:42 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so2518176pad.17
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 14:44:41 -0700 (PDT)
In-Reply-To: <87a9cc7j1o.fsf@sable.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-26 at 21:21 +0000, Rainer Weikusat wrote:

> BTW, here's the program with the O_NONBLOCK read call which blocks until
> the end of electricity, at least on 3.2.9:
> 
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

Sure, O_NONBLOCK is translated into MSG_NOWAIT one time per socket
syscall. 

Once we block, we don't automatically unblock if another thread change
the file flag.

grep -n MSG_DONTWAIT net/socket.c
