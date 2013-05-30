From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/12] tipc: make use of kernel threads to simplify things
Date: Thu, 30 May 2013 15:36:05 -0400
Message-ID: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:51501 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932164Ab3E3Tgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 15:36:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The biggest change here is the one where we make use of the fact
that linux supports kernel threads and do the server like operations
within kernel threads.  As Jon says:  

   We remove the last remnants of the TIPC native API, to make it
   possible to simplify locking policy and solve a problem with lost
   topology events.
 
   First, we introduce a socket-based alternative to the native API.

   Second, we convert the two remaining users of the native API, the 
   TIPC internal topology server and the configuarion server, to use the
   new API. 

   Third, we remove the remaining code pertaining to the native API.

We also ditch another Kconfig parameter, in favour of having it being
able to be set at boot/module load time vs requiring a reconfig/recompile.

In addition, there is a follow up to fix an issue that Neil had
highlighted during the previous round of TIPC commits.

I've tested this collection of commits between 32 and 64 bit x86
machines using the standard tipc test suite.

Paul.
---
Cc: Neil Horman <nhorman@tuxdriver.com>

The following changes since commit cbb963deed7bbf206f5077ab5742bee00ceefa46:

  net/usb/kalmia: use %*phC to dump small buffers (2013-05-29 00:35:20 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc_net-next

for you to fetch changes up to 9ea5c43104d88c985d95bf82f97097ae8335f3fc:

  tipc: cosmetic realignment of function arguments (2013-05-30 15:30:54 -0400)

----------------------------------------------------------------
Erik Hugne (2):
      tipc: Add "max_ports" configuration parameter
      tipc: allow implicit connect for stream sockets

Jon Maloy (1):
      tipc: change socket buffer overflow control to respect sk_rcvbuf

Paul Gortmaker (1):
      tipc: cosmetic realignment of function arguments

Ying Xue (8):
      tipc: introduce new TIPC server infrastructure
      tipc: convert topology server to use new server facility
      tipc: convert configuration server to use new server facility
      tipc: delete code orphaned by new server infrastructure
      tipc: remove user_port instance from tipc_port structure
      tipc: rename tipc_createport_raw to tipc_createport
      tipc: convert config_lock from spinlock to mutex
      tipc: save sock structure pointer instead of void pointer to tipc_port

 net/tipc/Kconfig       |  12 -
 net/tipc/Makefile      |   2 +-
 net/tipc/bcast.c       |   3 +-
 net/tipc/bcast.h       |   3 +-
 net/tipc/config.c      | 139 ++++--------
 net/tipc/core.c        |  19 +-
 net/tipc/core.h        |  14 +-
 net/tipc/discover.c    |   7 +-
 net/tipc/eth_media.c   |   2 +-
 net/tipc/link.c        |  72 ++----
 net/tipc/msg.c         |  19 +-
 net/tipc/msg.h         |   8 +-
 net/tipc/name_table.c  |  10 +-
 net/tipc/name_table.h  |  11 +-
 net/tipc/node_subscr.c |   2 +-
 net/tipc/port.c        | 320 +-------------------------
 net/tipc/port.h        |  83 +------
 net/tipc/server.c      | 591 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/server.h      |  92 ++++++++
 net/tipc/socket.c      | 139 +++++++++---
 net/tipc/subscr.c      | 348 ++++++++---------------------
 net/tipc/subscr.h      |  21 +-
 22 files changed, 1040 insertions(+), 877 deletions(-)
 create mode 100644 net/tipc/server.c
 create mode 100644 net/tipc/server.h
