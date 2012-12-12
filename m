From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network namespace bugs in L2TP
Date: Wed, 12 Dec 2012 11:44:36 -0800
Message-ID: <87k3snnjh7.fsf@xmission.com>
References: <20121212155105.GB2790@raven>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42341 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754312Ab2LLToo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 14:44:44 -0500
In-Reply-To: <20121212155105.GB2790@raven> (Tom Parkin's message of "Wed, 12
	Dec 2012 15:51:05 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Parkin <tparkin@katalix.com> writes:

> Hi Eric,
>
> I'm following up on this thread from later October in which you
> pointed out some network namespace bugs in L2TP:
>
> http://www.spinics.net/lists/netdev/msg214776.html
>
> I use L2TP, and I'd like to help fix these bugs.  But I'm not very
> conversant with network namespaces, and so I'm struggling to fully
> appreciate the issues you pointed out previously.  Could you give me a
> hand getting to grips with this?
>
> So far I've tested L2TP within network namespaces, using both iproute2
> to create sessions between two namespaces on the same host, and an
> L2TP daemon running in a namespace to create sessions between two
> hosts.  In both cases I've done a bit of trivial ping and iperf
> testing using Ethernet pseudowires.
>
> To make this work I've had to add a couple of trivial patches (see
> below).
>
> There are two things I'm uncertain about:
>
>  1. Why do we need to change the namespace of the socket created in
>     l2tp_tunnel_sock_create?  So far as I can tell, sock_create
>     defaults to the namespace of the calling process.  Is the issue
>     here that this code may run from a work queue or similar?

Something similar.  At the very least l2tp_tunnel_create which calls
l2tp_tunnel_sock_create gets called from netlink.  The network namespace
of a socket is not necessarily the same as the network namespace of the
process that uses that socket.

So since current is not necessarily the right network namespace we need
push the desired network namespace of the socket down into
l2tp_tunnel_sock_create and use that when creating the socket.

>  2. You mentioned the need to keep track of sockets allocated within a
>     namespace in order to be able to clean them up when the namespace
>     is deleted.  Should we be keeping a list of sockets we create and
>     then destroying them in the namespace pernet_ops exit function?

I think the issue that I was referring to and certainly the issue I am
thinking about is the issue where normal sockets hold a reference to a
network namespace and keep the network namespace alive.  Today l2tp uses
sock_create when creating a socket, and as such I think it pins it
current network namespace.  So I believe we can effectively have a
reference counting loop with l2tp sockets pinning the network namespace
and the network namespace keeping the l2tp device alive which keeps the
l2tp socket alive.

I don't remeber the specifics of l2tp as it creates some sockets, and
has other sockets passed in, and as such has rules that are not at all
normal.

Eric
