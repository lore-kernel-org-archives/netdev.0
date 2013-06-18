From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: UDP "accept" proposed
Date: Tue, 18 Jun 2013 10:54:41 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7297@saturn3.aculab.com>
References: <51C01EDA.30705@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "James Yonan" <james@openvpn.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39371 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754406Ab3FRJ4d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 05:56:33 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16895-03 for <netdev@vger.kernel.org>;
 Tue, 18 Jun 2013 10:56:32 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <51C01EDA.30705@openvpn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> One of the frustrations of creating UDP servers using BSD sockets is
> that there isn't an easy way for a server to pass off a socket for a
> particular client instance to a handler thread or process.
> 
> By contrast, with TCP you can "accept" an incoming connection, and pass
> the socket representing that connection off to any arbitrary handler.
> 
> But UDP servers that want to play well with stateful firewalls and NAT
> are forced to aggregate their entire connection pool onto a single
> socket, since BSD sockets don't have the equivalent of an "accept"
> mechanism to provide a connection-specific socket.

You should be able to create another UDP socket and use connect().

> This is a disaster from a performance perspective because you can't take
> a UDP server that binds to a single port and efficiently scale it up
> across multiple threads or processors because you must operate off a
> single socket.

Actually, for really large workloads having large number of sockets
generates its own problems.

...
> This would require the UDP implementation in the kernel to understand
> how to dispatch incoming UDP datagrams to sockets based on the tuple of
> (source addr, local addr) rather than just local addr as is currently
> the case.

I believe it already does that if you've called connect().

> But this would be a huge performance win for UDP servers (I'm thinking
> about OpenVPN in particular) because making the kernel smarter about
> dispatching UDP datagrams would make it much easier to develop scalable
> UDP servers on Linux.

By the sound of it what you really want is a small number of sockets
all bound to the same UDP port, and for the kernel to spread the
received traffic between the sockets in a manner that tends to keep
traffic from a specific remote host assigned to the same socket.

Then you can have a multi-threaded daemon that will tend to keep
the data in the correct cpu cache.

	David
