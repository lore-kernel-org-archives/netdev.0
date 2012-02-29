From: Pavel Emelyanov <xemul@parallels.com>
Subject: [RFC][PATCH 0/2] TCP connection repair
Date: Wed, 29 Feb 2012 19:13:08 +0400
Message-ID: <4F4E4084.9080804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19581 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031111Ab2B2PNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 10:13:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Here's another approach to transparent TCP connection hijacking (previous one
was here [1]). This one is _much_ more straightforward and patches TCP code a
little bit more. I'd like to have comments on the idea itself early, so here is
the very-very basic functionality, just to demonstrate the concept.

The idea briefly is -- introduce the "repair" mode of a TCP socket. In this mode
any API call to the socket (bind/connect/sendmsg/etc.) does not result in packets
sent over the network, but instead modifies the socket locally in an expected way.

I.e., the connect() in the repair mode assigns peer's credentials to the sock and 
just turns one into the connected state without issuing SYN-s or whatever. The
bind() call on the socket under repair forcibly binds one to the desired IP and 
port ignoring any (potential) local conflicts (just like if everybody else has the
SO_REUSEADDR set). The sendmsg() just queues data for transmission (however, this
is not implemented in this set, need more thinking on how to make it symmetrical
to the receive queue), etc.

The protocol sequences are also to be get/set, so a couple of another sockopts
are introduced for this.

I think, that it makes sense to have this ability in a form of non-obscure API,
since the connection migration can be used not only by checkpoint/restore project,
but also by various load balancing solutions. E.g., a server can accept the 
connection, read the app-level header out of the stream, take the balancing 
decision based on _it_ (rather than just TCP and/or IP header) and then pass 
the existing connection to another host.

Of course, switching socket to the repair mode is only allowed for CAP_SYS_ADMIN.

What do you think?

With the set provided you can do only simple tricks, e.g. transparently passing a
connection between echo server and telnet to another echo server task and proceed 
with echoing messages.

Thanks,
Pavel

[1] http://lwn.net/Articles/454304/
