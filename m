From: Neil Horman <nhorman@tuxdriver.com>
Subject: Question regarding expected behavior of two udp sockets with
 SO_REUSEADDR set
Date: Fri, 19 Nov 2010 19:48:47 -0500
Message-ID: <20101120004847.GA2590@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55603 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694Ab0KTAwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 19:52:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-

	Got a question regarding expected/desired behavior of $SUBJECT


I have a report of a problem with a program that opens two sockets:

The first socket is UDP and binds to 127.0.0.1 on a randomly selected port

The second socket is UDP and calls connect, sending to the first socket

Both sockets are part of the same process and have SO_REUSEADDR set

After the connect the second socket sends a message to the first socket.  The
first socket waits for the message by calling select().

Its observed that occasionally the first socket fails to receive the message,
which is odd, given that the system is unloaded, and this is the only message
being sent.  A little investigation shows that when this happens, the client and
the server wind up bound to the same port.

This happens because the second socket calls inet_autobind during the connect
call, and since both it and the server have SO_REUSEADDR set, it is possible
that the autobind will select the same port that the first socket is bound to.
When this happens the sendmsg path can get confused.  Specifically, when the skb
is delivered to the destination socket, the hash lookup might find the wrong
entry and enqueue the skb to the second socket instead of the first.

Questions:

1) Is that expected?

2) If not, what do you think the best way to fix it is?

	a) Deny autobinds to the same port when SO_REUSEADDR is set, but allow
explicity binds to the same port?

	b) Deny both autobinds and explicit binds to the same port/addr,
effectively disablind SO_REUSEADDR with UDP, kind of like with listening TCP
sockets

	c) Add magic to udp_rcv to detect skbs originating from local sockets,
and _dont_ deliver to the socket it originated from

I'm inclined to say, no this is not expected behavior, and that we should fix it
with option A, but I'm interested in getting other opinions before I go down any
particular path.

Thanks!
Neil

