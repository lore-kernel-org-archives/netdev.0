From: Michael Chan <mchan.dev@gmail.com>
Subject: [RFC] Connection-Oriented Multicasting
Date: Wed, 3 Feb 2010 09:55:41 -0800
Message-ID: <944511571002030955s734d3e6al7555b9259a0bada@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f224.google.com ([209.85.217.224]:60442 "EHLO
	mail-gx0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932778Ab0BCRzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 12:55:42 -0500
Received: by gxk24 with SMTP id 24so2065228gxk.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2010 09:55:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This RFC is for transport layer people:

I am implementing a TCP single-source multicast optimization (SMO):

Ref: http://www-dsg.stanford.edu/sliang/tcpm_infocom.pdf

In a nutshell, a source server enables the "SMO" mode of a TCP
listener socket, which creates a master socket through which multicast
data is sent. The server still maintains a connection with each client.
These individual sockets are responsible for retransmissions to
clients. They use the master socket's retransmission queue and
snd_nxt. The multicast clients enables "SMO" mode of its TCP
socket and joins a multicast group.

While coding the client side, I discovered that since 2007 multicast
joins are not allowed for connection-oriented sockets.There isn't any
explanation for the change in the commit that effected the change:

http://www.mail-archive.com/git-commits-head@vger.kernel.org/msg21013.html

Is it a policy to forbid any connection-oriented protocol from
participating in multicast?

Conventional wisdom is against such an optimization due to the
complexity in handling multiple clients from a TCP perspective, but
I don't see what is wrong with a connection-oriented protocol departing
from the well-established point-to-point abstraction given by TCP.
After all, tons of application-level protocols are built to provide
connection services on top of (UDP) multicast.

I believe it is worth optimizing that by putting connection services
in the transport level, given that:

1. There are already in-order delivery, retransmission and connection
management mechanisms in TCP.

2. There are performance benefits in a kernel-mode implementation.
such as timing precision, over using either select() or threads
for individual connections.

3. The additions to TCP are modest and may be enabled /
disabled via kernel configurations. An application that wants
to use reliable single-source multicast needs only add two
setsockopt() calls to the code. Further customization may
be provided with additional socket options, but the benefits
of reliable multicast is available with minimal
application-level changes.

I understand this is a rather intrusive modification to the
existing TCP implementation, since it adds to
struct tcp_sock and modifies the segment processing routines.
Is it a fool's errand to even attempt to get this accepted?

Thanks,
Michael
