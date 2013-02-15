From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC PATCH 0/6] udp: add encapsulation socket destroy hook
Date: Fri, 15 Feb 2013 10:25:13 +0000
Message-ID: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:34087 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161227Ab3BOKZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 05:25:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working on an issue in l2tp relating to tunnel cleanup I discovered a
problem which I think may require a new hook in udp core to resolve.  The l2tp
code uses encapsulated udp sockets, and it needs to know when a socket is
being closed in order to clean up.  Since sessions hold a reference to the
tunnel socket, hooking sk_destruct isn't sufficient: any tunnel with sessions
running in it will be pinned open by the sessions.

To resolve this, the first patch in this series adds a .destroy hook to udp, 
while the following patches show how I'd use this feature in l2tp.  Essentially 
the .destroy callback is used to close the sessions in the tunnel, thereby 
dropping the socket references.

Does this seem like a reasonable approach?  I'm reluctant to modify udp, but
I've not managed to discover a safe alternative...

The rest of this email goes into some more detail about the problem I'm trying
to solve.

A bit of background is probably useful for context.

The kernel l2tp code supports two flavours of tunnel socket: managed and
unmanaged.  The managed tunnel socket is created by a userspace daemon which
handles the L2TP control protocol, while the kernel handles L2TP data
encapsulation.  The unmanaged tunnel socket is created by the kernel
and just provides L2TP data encapsulation with no control protocol.

These two flavours of tunnel socket make for a fairly complex set of tunnel
lifetime requirements:

A managed tunnel may be deleted by:

 * userspace using a netlink "delete" command
 * userspace calling close(2) on the tunnel socket
 * userspace dying and the tunnel socket being released as a part of
   the normal tidyup after a process terminates

An unmanaged tunnel may be deleted by:

 * userspace using a netlink "delete" command

In order to satisfy all these deletion mechanisms, l2tp uses sk_destruct to
free tunnel resources when the tunnel socket is being destroyed.  That way we
can catch userspace closing the socket as well as explicit deletion using
netlink.

The problem comes when sessions are added to the tunnel.  Each session holds a
reference to the tunnel socket, in order to prevent the tunnel socket
unexpectedly going away while the session is still active and passing data.
But of course this also keeps the tunnel socket alive even if userspace closes
it!

This is where the protocol .destroy hook comes in.  Because .destroy is called
by sk_common_release before sock_put, the l2tp code is able to use the hook to
close the sessions in the tunnel.  Now that all the session references to the
socket have been dropped, when sk_common_release makes its final sock_put
call, the socket is actually freed and sk_destruct is called.

Tom Parkin (6):
  udp: add encap_destroy callback
  l2tp: add udp encap socket destroy handler
  l2tp: drop session refs in l2tp_tunnel_closeall
  l2tp: export l2tp_tunnel_closeall
  l2tp: close sessions in ip socket destroy callback
  l2tp: close sessions before initiating tunnel delete

 include/linux/udp.h  |    1 +
 net/ipv4/udp.c       |    7 +++++++
 net/ipv6/udp.c       |    8 ++++++++
 net/l2tp/l2tp_core.c |   19 +++++++++++++++++--
 net/l2tp/l2tp_core.h |    1 +
 net/l2tp/l2tp_ip.c   |    6 ++++++
 net/l2tp/l2tp_ip6.c  |    7 +++++++
 7 files changed, 47 insertions(+), 2 deletions(-)

-- 
1.7.9.5
