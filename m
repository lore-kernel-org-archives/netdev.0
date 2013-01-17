From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same port
Date: Thu, 17 Jan 2013 09:53:12 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7112@saturn3.aculab.com>
References: <alpine.DEB.2.00.1301141138440.959@pokey.mtv.corp.google.com><AE90C24D6B3A694183C094C60CF0A2F6026B710E@saturn3.aculab.com> <CA+mtBx-DRiSg4z5OUvp4=pJxZ=Ki4pt-vz716ubsJx1PHnD7Nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@markandruth.co.uk>, <eric.dumazet@gmail.com>
To: "Tom Herbert" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49520 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758866Ab3AQJzP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 04:55:15 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09354-04 for <netdev@vger.kernel.org>;
 Thu, 17 Jan 2013 09:55:11 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <CA+mtBx-DRiSg4z5OUvp4=pJxZ=Ki4pt-vz716ubsJx1PHnD7Nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We had considered solving this within accept.  The problem is that
> there's no way to indicate how much work a thread should do via
> accept.  For instance, an event loop usually would look like:
> 
> while (1) {
>     fd = accept();
>     process(fd);
> }
> 
> With multiple threads, the number of accepted sockets in a particular
> thread is non-deterministic...

If your loop looks like that then each thread is only processing
a single socket and won't call accept() again until it is idle.

OTOH if each thread is processing multiple requests using
poll/select (or similar) at the top of the loop then a single
thread is likely to pick up a large number of connections.

Given that both poll and select are inefficient with very large
numbers of fds (every call is usually o(n) [1]), the kernel will
support some kind of event mechanism, maybe tweaking that to
signal the waiters in turn would also work - and be more general.

It might also be possible to do something on the user side of
sockets to generate additional fd with their own queue?
(IMHO some of the SCTP stuff should have been done that way).

	David

[1] I've known systems where it was actually o(n*n) because
the relevant kernel used a linked list to map fd to kernel
file structures! By the time you got to 1000 fd this dominated.
