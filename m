From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return
 -EINTR
Date: Wed, 26 Mar 2014 07:09:32 -0700
Message-ID: <1395842972.12610.203.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8761n19k0w.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:45196 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526AbaCZOJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 10:09:35 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so1998844pad.0
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 07:09:34 -0700 (PDT)
In-Reply-To: <8761n19k0w.fsf@sable.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-26 at 13:17 +0000, Rainer Weikusat wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Some applications didn't expect recvmsg() on a non blocking socket
> > could return -EINTR. This possibility was added as a side effect
> > of commit b3ca9b02b00704 ("net: fix multithreaded signal handling in
> > unix recv routines").
> >
> > To hit this bug, you need to be a bit unlucky, as the u->readlock
> > mutex is usually held for very small periods.
> 
> This would mean that 'some applications' are broken, cf
> 
> [EAGAIN] or [EWOULDBLOCK]
>     The socket's file descriptor is marked O_NONBLOCK and no data is
>     waiting to be received; or MSG_OOB is set and no out-of-band data is
>     available and either the socket's file descriptor is marked
>     O_NONBLOCK or the socket does not support blocking to await
>     out-of-band data.
> 
> [EINTR]
>     This function was interrupted by a signal before any data was
>     available.
>     
> http://pubs.opengroup.org/onlinepubs/9699919799/functions/recvmsg.html
> 
> and
> 
>  EAGAIN or EWOULDBLOCK
>               The socket is marked nonblocking and the receive operation
>               would block, or a receive timeout had been set and the
>               timeout expired before data was received.
> 
>  EINTR  The receive was interrupted by delivery of a signal before any
>         data were available; see signal(7).
> 
> [3.27 Linux recvmsg(2)]
> 
> since the function was interrupted before any data was available and it
> is unknown if the condition supposed to be signalled by EAGAIN had
> otherwise occurred.
> 
> A correct 'fix'/ workaround would seem to be using mutex_trylock and
> abort execution immediately with -EAGAIN in case the operation had to
> wait for the lock, although this is inconsistent with the usual
> semantics of 'blocking' which implies that the operation may take an
> indefinite amount of time because it waits for an external event which
> might never occur.

Before your patch, -EAGAIN was delivered, -EINTR was _never_ delivered.

Thats a fact. If you read the manpage, its in this order :

When using a nonblocking socket, and no data is available, EAGAIN or
EWOULDBLOCK is delivered.

-EINTR is not expected from a non blocking system call. Period.

After your patch, -EINTR might be delivered, and it breaks legacy
applications.




Please send a fix if you think you have a better one, thanks
