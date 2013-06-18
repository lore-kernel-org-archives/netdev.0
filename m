From: James Yonan <james@openvpn.net>
Subject: UDP "accept" proposed
Date: Tue, 18 Jun 2013 02:48:26 -0600
Message-ID: <51C01EDA.30705@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from magnetar.openvpn.net ([74.52.27.18]:59537 "EHLO
	magnetar.openvpn.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755820Ab3FRJie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 05:38:34 -0400
Received: from moab.lan (c-24-9-78-222.hsd1.co.comcast.net [24.9.78.222])
	(authenticated bits=0)
	by magnetar.openvpn.net (8.13.1/8.13.1) with ESMTP id r5I8mIkr018087
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 02:48:18 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of the frustrations of creating UDP servers using BSD sockets is 
that there isn't an easy way for a server to pass off a socket for a 
particular client instance to a handler thread or process.

By contrast, with TCP you can "accept" an incoming connection, and pass 
the socket representing that connection off to any arbitrary handler.

But UDP servers that want to play well with stateful firewalls and NAT 
are forced to aggregate their entire connection pool onto a single 
socket, since BSD sockets don't have the equivalent of an "accept" 
mechanism to provide a connection-specific socket.

This is a disaster from a performance perspective because you can't take 
a UDP server that binds to a single port and efficiently scale it up 
across multiple threads or processors because you must operate off a 
single socket.

So why can't I "accept" a UDP socket?  The conventional response would 
be that UDP is connectionless and that "accept" is meaningless outside 
the context of a connection.  UDP may be connectionless, but it's not 
stateless.  The tuple of (local address/port, remote address/port) 
concisely defines the state of a UDP session between a client and 
server.  Netfilter connection tracking recognizes this statefulness, but 
unfortunately BSD sockets do not.

I would like to propose that Linux adds a userspace API method to allow 
UDP sockets to be "accepted":

int accept_udp(int sockfd, const struct sockaddr *addr, socklen_t 
*addrlen, int flags)

accept_udp will return a new UDP socket which is bound to the original 
local address/port of sockfd but which is additionally bound to the 
source address/port denoted by addr.  This socket will only receive 
datagrams having a source address of addr, and when used with send(), 
will transmit datagrams to addr.

This socket, while open, will have priority in the sense of receiving 
any datagrams having a source address of addr that would normally have 
been received by sockfd.  When closed, datagrams from addr will revert 
to being received by sockfd.

This abstraction allows UDP servers to follow the same scalable event 
loop as TCP servers, i.e. bind to local socket, then:

1. recvfrom to read a packet

2. call accept_udp on socket, passing the source address of packet read 
in (1)

3. pass the return socket of accept_udp to a handler thread

4. repeat

This would require the UDP implementation in the kernel to understand 
how to dispatch incoming UDP datagrams to sockets based on the tuple of 
(source addr, local addr) rather than just local addr as is currently 
the case.

But this would be a huge performance win for UDP servers (I'm thinking 
about OpenVPN in particular) because making the kernel smarter about 
dispatching UDP datagrams would make it much easier to develop scalable 
UDP servers on Linux.

James
