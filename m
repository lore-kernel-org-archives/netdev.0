From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [RFC] Support for Multipath TCP in the Linux kernel
Date: Mon, 19 May 2014 17:23:01 +0300
Message-ID: <CAE1zot+kBdDbYrZ9m2oCg12yUBAZvToPeDeB4aZmD65xg4e0Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:47410 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbaESOXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 10:23:03 -0400
Received: by mail-we0-f169.google.com with SMTP id u56so5656560wes.14
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 07:23:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multipath TCP is a new protocol and Experimental RFC [1] that
extends TCP with the purpose of allowing (simultaneous) connectivity
across multiple physical links. Its main use-cases are in mobility
(e.g. 3G/WiFi aggregation or handover) and datacenter and there
already are commercial implementations available [2] [3] [4].

An out-of-tree MPTCP implementation for the Linux kernel [5] exists
for some time now and I think it is a good time to start discussing
about including MPTCP in the Linux kernel and what is the best
approach to do so.

I know that some people think that MPTCP is not mature enough to
justify increasing the complexity of the TCP stack and hence I will
open up the discussion with a few approaches to get MPTCP supported in
Linux.

1. Implementation at the TCP level
----------------------------------

This is the approach that current out-of-tree implementation took. It
is the most flexible approach and can probably offer the best
performance and it is quite mature, but at the cost of increased
complexity in the TCP stack.

The main source of that cost comes from the fact that in the case of
MPTCP the original TCP socket is cloned to create a master socket (a
special case of subflow) then modified to be a meta_socket with its
own sk_backlog_rcv callback. Subsequent sub-flows sockets are created
as TCP sockets and linked to the meta socket.

Then various places in the TCP stack are checked to see if processing
is done for either a subflow socket, a meta socket or a plain TCP
socket.

2. Implementation on top of the TCP level
-----------------------------------------

In this approach a new socket family is created that will implement
the MPTCP logic and uses plain TCP sockets for the sub-flows. In order
for this to work we will need to implement in the TCP stack a way of
passing new TCP options.

We will also need a mechanism to redirect the TCP socket() API to the
MPTCP layer, in certain conditions (e.g. for a particular application,
system wide, etc.) to conform with MPTCP requirements that the changes
should be invisible to the application.

In order to allow for fallback to TCP (also required by MPTCP) we
propose a mechanism that allows switching between sockets at the file
level (e.g. from the MPTCP socket to the subflow TCP socket).

This has the potential of reducing the complexity impact to the
existing TCP stack, but we do not have an implementation (except some
prof-of-concept hacks) and probably more changes will be required in
the TCP stack to support MPTCP congestion. The MPTCP performance will
also probably not be on par with the previous approach.

3. Implementation in userspace
------------------------------

Eric Dumazet proposed to implement MPTCP and other experimental TCP
extensions in userspace. Due to MPTCP requirements, that no changes to
the application must be done, this is difficult to do without the
equivalent of a FUSE like solution for networking (which would be an
interesting project).

In addition, without the ability to send new TCP options at the socket
API level, it would mean that basic TCP handling will need to be
implemented as well ending up with a duplicated TCP stack.

IMHO, leaving the performance issues aside, MPTCP in userspace without
NUSE and the ability to pass new TCP options at the socket level is
not something worth doing at the moment, it offers no benefits to an
out of tree implementation.

[1] http://tools.ietf.org/html/rfc6824
[2] http://blogs.citrix.com/2013/08/30/mptcp-netscaler-way/
[3] http://appleinsider.com/articles/13/09/20/apple-found-to-be-using-advanced-multipath-tcp-networking-in-ios-7
[4] https://devcentral.f5.com/articles/mptcp-improving-the-mobile-user-experience
[5] https://github.com/multipath-tcp/mptcp
