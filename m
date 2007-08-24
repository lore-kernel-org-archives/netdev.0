From: TJ <linux@tjworld.net>
Subject: Problem with implementation of TCP_DEFER_ACCEPT?
Date: Fri, 24 Aug 2007 01:08:25 +0100
Message-ID: <1187914105.26866.41.camel@bagoas.tjworld.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [66.6.122.20] ([66.6.122.20]:39485 "EHLO tjworld.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932514AbXHXAJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 20:09:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'd welcome the views of those familiar with TCP_DEFER_ACCEPT on a
recent issue I've worked on where connections between a Juniper DX (aka
redline) load-balancer and Apache 2.2 cluster caused random connection
failures.

Today, after 2 weeks debugging the issue, we confirmed the problem was
related to TCP_DEFER_ACCEPT. Part of the issue is caused by Juniper's
implementation of persistent connections, but there remains a question
as to whether the Linux kernel is correctly handling handshakes when a
listening socket has TCP_DEFER_ACCEPT enabled.

Upon reflection, and after having worked with the RFCs this past few
weeks, I'm finding myself doubting the kernel's TCP_DEFER_ACCEPT
implementation.

Also, I'm unable to locate an RFC or other specification for
TCP_DEFER_ACCEPT aka BSD's SO_ACCEPTFILTER - can you point me to one?

The complete background and observations of the original problem and the
workaround are available here:

https://bugs.launchpad.net/ubuntu/+bug/134274

My specific concerns are explained in the following comments, for which
I'd appreciate your views. 

----------------------------------------------------

An RFC 793 standard TCP handshake requires three packets:

client SYN > server LISTENING
client < SYN ACK server SYN_RECEIVED
client ACK > server ESTABLISHED

client PSH ACK + data > server

TCP_DEFER_ACCEPT is designed to increase performance by reducing the
number of TCP packets exchanged before the client can pass data:

client SYN > server LISTENING
client < SYN ACK server SYN_RECEIVED

client PSH ACK + data > server ESTABLISHED

At present with TCP_DEFER_ACCEPT the kernel treats the RFC 793 handshake
as invalid; dropping the ACK from the client without replying so the
client doesn't know the server has in fact set it's internal ACKed flag.

If the client doesn't send a packet containing data before the SYN_ACK
time-outs finally expire the connection will be dropped.

For a client obeying RFC 793 what we see is:

client SYN > server LISTENING
client < SYN ACK server SYN_RECEIVED (time-out 3s)
                 server: inet_rsk(req)->acked = 1

client ACK > server (discarded)

client < SYN ACK (DUP) server (time-out 6s)
client ACK (DUP) > server (discarded)

client < SYN ACK (DUP) server (time-out 12s)
client ACK (DUP) > server (discarded)

client < SYN ACK (DUP) server (time-out 24s)
client ACK (DUP) > server (discarded)

client < SYN ACK (DUP) server (time-out 48s)
client ACK (DUP) > server (discarded)

client < SYN ACK (DUP) server (time-out 96s)
client ACK (DUP) > server (discarded)

server: half-open socket closed.

With each client ACK being dropped by the kernel's TCP_DEFER_ACCEPT
mechanism eventually the handshake fails after the 'SYN ACK' retries and
time-outs expire.

There is a case for arguing the kernel should be operating in an
enhanced handshaking mode when TCP_DEFER_ACCEPT is enabled, not an
alternative mode, and therefore should accept *both* RFC 793 and
TCP_DEFER_ACCEPT. I've been unable to find a specification or RFC for
implementing TCP_DEFER_ACCEPT aka BSD's SO_ACCEPTFILTER to give me firm
guidance.

It seems incorrect to penalise a client that is trying to complete the
handshake according to the RFC 793 specification, especially as the
client has no way of knowing ahead of time whether or not the server is
operating deferred accept.

-------------------------------------------

net/ipv4/tcp_minisocks.c::tcp_check_req() implements the
TCP_DEFER_ACCEPT check:

/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {

	inet_rsk(req)->acked = 1;
	return NULL;
}

--------------------------------------------

Thanks

TJ.
Ubuntu ACPI Kernel Team


