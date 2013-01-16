From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same port
Date: Wed, 16 Jan 2013 10:22:39 -0800
Message-ID: <CA+mtBx-DRiSg4z5OUvp4=pJxZ=Ki4pt-vz716ubsJx1PHnD7Nw@mail.gmail.com>
References: <alpine.DEB.2.00.1301141138440.959@pokey.mtv.corp.google.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B710E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:43365 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038Ab3APSWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 13:22:40 -0500
Received: by mail-ie0-f175.google.com with SMTP id qd14so3073063ieb.6
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 10:22:39 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B710E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmmm.... do you need that sort of fairness between the threads?
>
Yes :-)

> If one request takes longer than average to process, then you
> don't want other requests to be delayed when there are other
> idle worker processes.
>
On a heavily loaded server processing thousands of requests/second,
law of large numbers hopefully applies where each connection
represents approximately same unit of work.

> Also having the same thread normally collect a request would
> make it more likely that the required code/data be in the
> cache of the cpu (assuming that the main reason for multiple
> threads is to load balance over multiple cpus, and with the
> threads tied to a single cpu).
>
Right.  Multiple listener sockets also imply that the work on the
connected sockets will be in the same thread or at least dispatched to
thread which is close to the same CPU.  soreuseport moves the start of
siloed processing into kernel.

> If there are a lot of processes sleeping in accept() (on the same
> socket) it might be worth looking at which is actually woken
> when a new connection arrives. If they are sleeping in poll/select
> it is probably more difficult (but not impossible) to avoid waking
> all the processes for every incoming connection.

We had considered solving this within accept.  The problem is that
there's no way to indicate how much work a thread should do via
accept.  For instance, an event loop usually would look like:

while (1) {
    fd = accept();
    process(fd);
}

With multiple threads, the number of accepted sockets in a particular
thread is non-deterministic.  It is even possible that one thread
could end up accepting all the connections, and the others are starved
(wake up but no connection to process.).  Since connections are the
unit of work, this creates imbalance among threads.  There was an
attempt to fix this in user space by sleeping for a while instead of
calling accept on threads for one that have already have a
disproportionate number of connections.  This was unpleasant-- it
needed shared state in user space and provided no granularity.

Tom
