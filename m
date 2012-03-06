From: Pavel Emelyanov <xemul@parallels.com>
Subject: [RFC][PATCH 0/3] TCP connection repair (v2)
Date: Tue, 06 Mar 2012 13:54:38 +0400
Message-ID: <4F55DEDE.1090602@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1790 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758568Ab2CFJyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 04:54:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Attempt #2 with transparent TCP connection hijacking.


The idea briefly is -- introduce the "repair" mode of a TCP socket. In this mode
any API call to the socket (bind/connect/sendmsg/etc.) does not result in packets
sent over the network, but instead modifies the socket locally in an expected way.

I.e., the connect() in the repair mode assigns peer's credentials to the sock and 
just turns one into the connected state without issuing SYN-s or whatever. The
bind() call on the socket under repair forcibly binds one to the desired IP and 
port ignoring any (potential) local conflicts (just like if everybody else has the
SO_REUSEADDR set). The sendmsg() just queues data for transmission, etc.

I think, that it makes sense to have this ability in a form of non-obscure API,
since the connection migration can be used not only by checkpoint/restore project,
but also by various load balancing solutions. E.g., a server can accept the 
connection, read the app-level header out of the stream, take the balancing 
decision based on _it_ (rather than just TCP and/or IP header) and then pass 
the existing connection to another host.


Changes since v1:

* Addressed (I hope) David's concern about TCP sequences self-consistency.

The repair mode is turned on only for "static" TCP states, i.e. TCP_CLOSE and
TCP_ESTABLISHED with the socket being locked. Only two sequences can be changed
manually -- the write_seq and the copied_seq -- and only when the socket is in
TCP_CLOSE state. The rest is maintained fully by the kernel code according to
the protocol rules in connect/sendmsg/etc. calls.

* Slight API change.

Instead of two separate sockoptions for send and receive queues sequences I
introduce the option which sets which queue is under repair right now and
the other option for setting the sequence (as described -- works only for
TCP_CLOSE state) of the queue under repair. Yes, there still two options for
this, but such approach helps with socket queues repair (see below).

* Added support for queues repair.

According to the overall idea of the "repair" mode the recv/send syscalls
are used for this and what they do is just peek/poke data from/to queues.
The queue-under-repair set by the described option makes it possible to read
from the send queue and write to the receive one. Caller is obliged to use
the MSG_PEEK flag for recv in the repair mode.


Thanks,
Pavel
