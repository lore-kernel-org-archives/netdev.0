From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH v2 net-next 00/16] tipc: make use of kernel threads to simplify things
Date: Mon, 17 Jun 2013 10:54:35 -0400
Message-ID: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63205 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab3FQOzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 10:55:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a rework of the content sent earlier[1], with the following changes:

	-drop the Kconfig --> modparam conversion patch; this was
	 requested to be replaced[2] with a dynamic port quantity resizing.
	 Ying and Erik were discussing how best to achieve this, and then
	 vacation schedules got in the way, so implementing that will
	 come (hopefully) in the next round.

	-rework the sk_rcvbuf patch to allow memory resizing via sysctl
	 as per what Ying and Neil discussed[3]

	-add 4 more seemingly straigtforward and relatively small changes
	 from Ying (the last 4 in the series).

	-add cosmetic UAPI comment update patch from Ying.

That said, the largest change is still the one where we make use of
the fact that linux supports kernel threads and do the server like
operations within kernel threads.  As Jon says:  

   We remove the last remnants of the TIPC native API, to make it
   possible to simplify locking policy and solve a problem with lost
   topology events.
 
   First, we introduce a socket-based alternative to the native API.

   Second, we convert the two remaining users of the native API, the 
   TIPC internal topology server and the configuarion server, to use the
   new API. 

   Third, we remove the remaining code pertaining to the native API.

I have re-tested this collection of commits between 32 and 64 bit x86
machines using the standard tipc test suite, and build tested for ppc.

[1] http://patchwork.ozlabs.org/patch/247687/
[2] http://patchwork.ozlabs.org/patch/247680/
[3] http://patchwork.ozlabs.org/patch/247688/

Thanks,
Paul.
---
Cc: Neil Horman <nhorman@tuxdriver.com>

The following changes since commit 2e0c9e7911465b29daf85f7de97949004bf7b31c:

  net: sctp: sctp_association_init: put refs in reverse order (2013-06-14 15:38:36 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc_net-next

for you to fetch changes up to d4e1208e0e85255c644160be879e6f2d0b6bdcf9:

  tipc: remove dev_base_lock use from enable_bearer (2013-06-17 10:13:30 -0400)

----------------------------------------------------------------
Erik Hugne (1):
      tipc: allow implicit connect for stream sockets

Paul Gortmaker (1):
      tipc: cosmetic realignment of function arguments

Ying Xue (14):
      tipc: update code comments to reflect new uapi header path
      tipc: change socket buffer overflow control to respect sk_rcvbuf
      tipc: introduce new TIPC server infrastructure
      tipc: convert topology server to use new server facility
      tipc: convert configuration server to use new server facility
      tipc: delete code orphaned by new server infrastructure
      tipc: remove user_port instance from tipc_port structure
      tipc: rename tipc_createport_raw to tipc_createport
      tipc: convert config_lock from spinlock to mutex
      tipc: save sock structure pointer instead of void pointer to tipc_port
      tipc: enhance priority of link protocol packet
      tipc: make tipc_link_send_sections_fast exit earlier
      tipc: fix wrong return value for link_send_sections_long routine
      tipc: remove dev_base_lock use from enable_bearer

 Documentation/sysctl/net.txt     |  17 +-
 include/uapi/linux/tipc.h        |   2 +-
 include/uapi/linux/tipc_config.h |   2 +-
 net/tipc/Makefile                |   3 +-
 net/tipc/bcast.c                 |   3 +-
 net/tipc/bcast.h                 |   3 +-
 net/tipc/config.c                | 119 ++++----
 net/tipc/core.c                  |  22 +-
 net/tipc/core.h                  |  17 +-
 net/tipc/discover.c              |   7 +-
 net/tipc/eth_media.c             |  15 +-
 net/tipc/ib_media.c              |  13 +-
 net/tipc/link.c                  |  88 ++----
 net/tipc/msg.c                   |  19 +-
 net/tipc/msg.h                   |   8 +-
 net/tipc/name_table.c            |  10 +-
 net/tipc/name_table.h            |  11 +-
 net/tipc/node_subscr.c           |   2 +-
 net/tipc/port.c                  | 320 +--------------------
 net/tipc/port.h                  |  85 +-----
 net/tipc/server.c                | 596 +++++++++++++++++++++++++++++++++++++++
 net/tipc/server.h                |  94 ++++++
 net/tipc/socket.c                | 146 ++++++++--
 net/tipc/subscr.c                | 348 +++++++----------------
 net/tipc/subscr.h                |  21 +-
 net/tipc/sysctl.c                |  64 +++++
 26 files changed, 1158 insertions(+), 877 deletions(-)
 create mode 100644 net/tipc/server.c
 create mode 100644 net/tipc/server.h
 create mode 100644 net/tipc/sysctl.c
