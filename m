From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 00/12] l2tp bugfix patchset
Date: Tue, 19 Mar 2013 16:11:11 +0000
Message-ID: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36140 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932436Ab3CSQLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This l2tp bugfix patchset addresses a number of issues.

The first five patches in the series prevent l2tp sessions pinning an l2tp
tunnel open.  This occurs because the l2tp tunnel is torn down in the tunnel
socket destructor, but each session holds a tunnel socket reference which
prevents tunnels with sessions being deleted.  The solution I've implemented
here involves adding a .destroy hook to udp code, as discussed previously on
netdev[1].

The subsequent seven patches address futher bugs exposed by fixing the problem
above, or exposed through stress testing the implementation above.  Patch 11
(avoid deadlock in l2tp stats update) isn't directly related to tunnel/session
lifetimes, but it does prevent deadlocks on i386 kernels running on 64 bit
hardware.

This patchset has been tested on 32 and 64 bit preempt/non-preempt kernels,
using iproute2, openl2tp, and custom-made stress test code.

[1] http://comments.gmane.org/gmane.linux.network/259169

Tom Parkin (12):
  udp: add encap_destroy callback
  l2tp: add udp encap socket destroy handler
  l2tp: export l2tp_tunnel_closeall
  l2tp: close sessions in ip socket destroy callback
  l2tp: close sessions before initiating tunnel delete
  l2tp: take a reference for kernel sockets in l2tp_tunnel_sock_lookup
  l2tp: don't BUG_ON sk_socket being NULL
  l2tp: add session reorder queue purge function to core
  l2tp: purge session reorder queue on delete
  l2tp: push all ppp pseudowire shutdown through .release handler
  l2tp: avoid deadlock in l2tp stats update
  l2tp: unhash l2tp sessions on delete, not on free

 include/linux/udp.h     |    1 +
 net/ipv4/udp.c          |    7 ++
 net/ipv6/udp.c          |    8 ++
 net/l2tp/l2tp_core.c    |  206 +++++++++++++++++++++++------------------------
 net/l2tp/l2tp_core.h    |   22 ++---
 net/l2tp/l2tp_debugfs.c |   28 +++----
 net/l2tp/l2tp_ip.c      |    6 ++
 net/l2tp/l2tp_ip6.c     |    7 ++
 net/l2tp/l2tp_netlink.c |   72 +++++++----------
 net/l2tp/l2tp_ppp.c     |  111 +++++++++----------------
 10 files changed, 220 insertions(+), 248 deletions(-)

-- 
1.7.9.5
