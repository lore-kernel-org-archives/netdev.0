From: <richard.alpe@ericsson.com>
Subject: [PATCH v2 net-next 00/15] tipc: new netlink API
Date: Thu, 2 Oct 2014 16:58:26 +0200
Message-ID: <1412261921-28510-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:45844 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbaJBPAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 11:00:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

v2
Redesigned "socket list command" to address David Millers comments in
net-next v1 of this patchset.

Simply put the problem is that we can have an arbitrary amount of
sockets with an arbitrary amount of associated publications. In the
previous patchset this was solved by nesting as many publications as
possible into a socket. If all didn't fit it sent the same socket again
with the remaining publications. As David Miller pointed out this makes
each message malformed as the receiver cannot by the data itself know if
it has received a complete set or not. This was flagged outside of the
data and the client did the reassembly.

o socket 1
  o publ 1
  o publ 2
o socket 1
  o publ 3
  o publ 4

In this patchset this is divided into socket listing and publication
listing to avoid having nested data of arbitrary size.

TIPC_NL_SOCK_GET now dumps all sockets with any nested connection
information. However, it no longer include publication information,
only a HAS_PUBL flag to indicate whether the socket has publications or
not. To compliment this there is a new command TIPC_NL_PUBL_GET which
takes a socket as argument and dumps all associated publications.

This means that on "top-level" the data is always complete. In the case
of "tipc socket list" (new tipc-config -p) it first queries all sockets
with TIPC_NL_SOCK_GET and if the socket is published it fetches the
publications using TIPC_NL_PUBL_GET. This is slow for large amount of
sockets with a low publication count (worst case). However, the
integrity is preserved and there is no malformed messages.
/v2

This is a new netlink API for TIPC. It's intended to replace the
existing ASCII API. It utilizes many of the standard netlink
functionalities in the kernel, such as attribute nesting and
input polices.

There are a couple of reasons for this rewrite. The main and most
easily justifiable is that the existing API doesn't scale.  Meaning
that a TIPC cluster with a larger amount of nodes, publications or
ports will rapidly exceed what the exiting API can handle. Resulting
in truncated or corrupt responses. In addition to this, the existing
ASCII API rarely uses "standard" kernel functions and has several
tipc specific functions for sanity checking and string formating.

The new API utilizes standard function for pushing data to socket
buffers and netlink attribute nesting to logically group data.
The new API can handle an arbitrary amount of data for things that
are likely to scale up as the TIPC usage and/or cluster size
increases.

A new user-space tool has been developed to work with this new API.
It is called "tipc" and is part of the "tipc-utils" package that
comes with many Linux distributions.  The new "tipc" tool utilizes
standard functions from libnl to format, send, receive and process
messages. The tool has borrowed design philosophies from git and the
ip tool. Making the syntax resemble that of ip whiles its strong
modularity resembles that of git.

The existing tool for managing TIPC, "tipc-config" remains in the
package, but when built for kernels that has this new API it is
replaced by a script-based wrapper that maps the old syntax to the
new tool. This way, backwards compatibility is mostly preserved.

MORE ABOUT THE CODE

The main challenge here is to handle the case where the data is of
arbitrary size. This was largely neglected in the old API design.
For example when there is a lot of sockets that has a large amount of
associated publications. In this specific case we can't assume that
all ports nor for that matter all the publications can fit inside a
single netlink message. Sending everything in one batch isn't an
option as we need to yield for the socket layer to cope.

This is solved by using the standard netlink callback for dumping
data and releasing the locks when the netlink message is full. The
dumping mechanism gets us back and we keep a reference (logical) to
where we where when the message became full. This means that we are
not "atomic", what is retrieved by user-space isn't a snapshot at a
certain time but rather a continuously updated data set. In the case
where we can't find our way back i.e. our logical reference are gone
we set a standard flag (NLM_F_DUMP_INTR) to tell user-space that the
dump was interrupted.

Richard Alpe (15):
  tipc: add bearer disable/enable to new netlink api
  tipc: add bearer get/dump to new netlink api
  tipc: add bearer set to new netlink api
  tipc: add sock dump to new netlink api
  tipc: add publication dump to new netlink api
  tipc: add link get/dump to new netlink api
  tipc: add link set to new netlink api
  tipc: add link stat reset to new netlink api
  tipc: add media get/dump to new netlink api
  tipc: add media set to new netlink api
  tipc: add node get/dump to new netlink api
  tipc: add net dump to new netlink api
  tipc: add net set to new netlink api
  tipc: add name table dump to new netlink api
  tipc: remove old ASCII netlink API

 include/uapi/linux/tipc_config.h |  480 ++++++++++--------------
 net/tipc/Makefile                |    2 +-
 net/tipc/bcast.c                 |  130 +++++--
 net/tipc/bcast.h                 |    4 +-
 net/tipc/bearer.c                |  510 ++++++++++++++++++++++----
 net/tipc/bearer.h                |   15 +-
 net/tipc/config.c                |  342 -----------------
 net/tipc/config.h                |   67 ----
 net/tipc/core.c                  |    3 +-
 net/tipc/link.c                  |  746 +++++++++++++++++++++++---------------
 net/tipc/link.h                  |   14 +-
 net/tipc/log.c                   |    1 -
 net/tipc/name_table.c            |  375 +++++++++----------
 net/tipc/name_table.h            |    5 +-
 net/tipc/net.c                   |  107 +++++-
 net/tipc/net.h                   |    8 +-
 net/tipc/netlink.c               |  146 ++++++--
 net/tipc/netlink.h               |   48 +++
 net/tipc/node.c                  |  209 +++++------
 net/tipc/node.h                  |    6 +-
 net/tipc/socket.c                |  313 ++++++++++++----
 net/tipc/socket.h                |    4 +-
 22 files changed, 2011 insertions(+), 1524 deletions(-)
 delete mode 100644 net/tipc/config.c
 delete mode 100644 net/tipc/config.h
 create mode 100644 net/tipc/netlink.h

-- 
1.7.10.4
