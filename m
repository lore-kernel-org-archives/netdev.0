From: David Laight <David.Laight@ACULAB.COM>
Subject: SCTP's processing of unexpected COOKIE_ECHO doesn't seem useful.
Date: Tue, 10 Jun 2014 09:52:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17259B99@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59047 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751286AbaFJJwx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 05:52:53 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14299-08 for <netdev@vger.kernel.org>;
 Tue, 10 Jun 2014 10:52:44 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing some unexpected (to me) behaviour of the SCTP stack
when the remote system restarts.

I've a socket that has a single association, and I'm rather
expecting TCP-like behaviour.
So I'd expect some kind of failure condition on my existing
connection, and then a new connection be established on a
different socket - eg though a listening socket.
This would then go through all my code for correctly
initialising a new connection.

What happens is rather different.

The remote sends an INIT with the same port numbers as the
previous connection, AFAICT the code sends an INIT_ACK with
some numbers taken from the existing TCB.

When the COOKIE_ECHO is received sctp_sf_do_5_2_4_dupcook()
is called, condition 'A' is detected and sctp_sf_do_dupcook_a()
called.

RFC 2960 says that this should be treated as a received ABORT
followed by a COOKIE echo - this sounds fine, I want the ABORT
processing to kill the existing connection.
However it then says that 'RESTART' should be indicated to the ULP
rather than 'COMMUNICATION LOST'.

AFAICT this is just silently ignored by the socket layer.
I've a process sleeping in recv() (actually a kernel thread in
sock_recvmsg()) and it is not woken up at all.

This leaves the 'application' code in completely the wrong state for
the SCTP connection.

ISTM that the mapping of SCTP to connection-mode sockets should be
treating this as a disconnect.

This scenario can be reproduced by disconnecting with ABORT and
getting iptables to discard the ABORT.
It can happen with some connection retry algorithms if there is
message loss.

	David
