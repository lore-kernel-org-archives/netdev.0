From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 0/4] l2tp: fix namespace support in l2tp_core
Date: Fri,  1 Feb 2013 09:42:59 +0000
Message-ID: <1359711783-4379-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36155 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755721Ab3BAJnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 04:43:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As previously reported on netdev, l2tp_core has a number of issues with network 
namespaces which this patchset seeks to address:

	* Create unmanaged tunnel sockets[1] in the namespace passed to
	  l2tp_tunnel_create, rather than defaulting to using the namespace
	  of the current process.

	* Drop namespace references for unmanaged tunnel sockets.  This is to
	  prevent such a socket keeping an otherwise inaccessible namespace
	  alive.  Unmanaged sockets are freed in a namespace net_exit
	  callback.

	* Push tunnel socket release onto a workqueue to allow
	  l2tp_tunnel_delete to be called from an atomic context.  This is to
	  allow the l2tp net_exit callback to walk the tunnel list in an RCU
	  critical section.

There are also minor changes to sanity check namespaces for managed tunnel
sockets, and to flag to netlink that l2tp can run in a namespace other than
default.

Tested on AMD64 and armv6l, under preempt and non-prempt configurations.

[1]. An "unmanaged" tunnel socket is created by the kernel and not exposed to
     userspace.  It is used to perform data encapsulation and de-encapsulation
     at the kernel level without incurring the overhead of the L2TP control
     protocol.  There is code in iproute2 to create unmanaged l2tp tunnels.

Tom Parkin (4):
  l2tp: put tunnel socket release on a workqueue
  l2tp: set netnsok flag for netlink messages
  l2tp: prevent tunnel creation on netns mismatch
  l2tp: create tunnel sockets in the right namespace

 net/l2tp/l2tp_core.c    |  179 +++++++++++++++++++++++++++++------------------
 net/l2tp/l2tp_core.h    |    2 +
 net/l2tp/l2tp_netlink.c |    1 +
 3 files changed, 114 insertions(+), 68 deletions(-)

-- 
1.7.9.5
