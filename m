From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC PATCH 0/3] net namespace support in l2tp_core
Date: Fri,  4 Jan 2013 17:51:45 +0000
Message-ID: <1357321908-30619-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53772 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755113Ab3ADRwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2013 12:52:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This exploratory patchset is an attempt to fix up l2tp_core to behave properly
with network namespaces, based on issues raised previously on netdev[1].

The reason I'm posting it as an RFC is that I'm seeing some bugs that I'm
having trouble tracking down, and I'd appreciate any suggestions as to what
I'm doing wrong.

During stress testing I see kernel oopses after a few hours.  My stress test is 
a script which spawns lots of sub-processes which create and delete multiple 
namespaces containing multiple l2tp tunnels.  I've seen oopses in various 
locations -- for example, ndist_net_exit, dst_ifdown, 
netlink_broadcast_filtered, dev_change_net_namespace.  I'm assuming my changes 
are causing some race condition which might bite in multiple places depending 
on timing.

So far I'm guessing that the method I'm using to clean up l2tp tunnel sockets
in the net namespace callback may be to blame.  In the case of "unmanaged"
sockets (see patch 3 for details) the socket is created using:

	sock_create_kern
	sk_change_net

to create a socket without a namespace reference.  When the namespace exits, I
walk the per-namespace list of tunnels, calling sk_release_kernel to release
the socket.  The l2tp-specific resources are freed in the socket destructor
function.

This general pattern of socket creation and destruction
(sock_create_kern/sk_change_net/sk_release_kernel) seems to be used
elsewhere, for example inet_ctl_sock_create and inet_ctl_sock_destroy.  So
this seems reasonable.  I'm not sure if hanging resource deallocation off
sk_destruct in this context is OK, though.  Any comments welcome!

Thanks,
Tom

[1].
	http://www.spinics.net/lists/netdev/msg214776.html
	http://www.spinics.net/lists/netdev/msg212234.html

Tom Parkin (3):
  l2tp: set netnsok flag for netlink messages
  l2tp: prevent tunnel creation on netns mismatch
  l2tp: fix network namespace use for unmanaged tunnel sockets

 net/l2tp/l2tp_core.c    |   94 ++++++++++++++++++++++++++++++-----------------
 net/l2tp/l2tp_netlink.c |    1 +
 2 files changed, 62 insertions(+), 33 deletions(-)

-- 
1.7.9.5
