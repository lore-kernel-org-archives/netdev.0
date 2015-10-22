From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 00/16] tipc: improve broadcast implementation
Date: Thu, 22 Oct 2015 08:51:32 -0400
Message-ID: <1445518308-26200-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.biz.mail.bf1.yahoo.com ([98.139.221.60]:34167 "EHLO
	smtp101.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755856AbbJVMwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 08:52:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TIPC broadcast link implementation is currently complex and hard to
follow. It also incurs some amount of code and structure duplication,
something that can be reduced significantly with a little effort.

This commit series introduces a number of improvements which address
both the locking structure, the code/structure duplication issue, and
the overall readbility of the code.

The series consists of three main parts:

1-7: Adaptation to the new link structure, and preparation for the next
     step. In particular, we want the broadcast transmission link to
     have a life cycle that is longer than any of its potential (unicast
     and broadcast receive links) users. This eliminates the need to
     always test for the presence of this link before accessing it.

8-10: This is what is really new in this series. Commit #9 is by far
      the largest and most important one, because it moves most of
      the broadcast functionality into link.c, partially reusing the
      fields and functionality of the unicast link. The removal of
      the "node_map" infrastructure in commit #10 is also an important
      achievement.

11-16: Some improvements leveraging the changes made in the previous
       commits.

The series needs commit 53387c4e22ac ("tipc: extend broadcast link window size")
and commit e53567948f82 ("tipc: conditionally expand buffer headroom over udp tunnel")
which are both present in 'net' but not yet in 'net-next', to apply cleanly.


Jon Maloy (16):
  tipc: move bcast definitions to bcast.c
  tipc: move broadcast link lock to struct tipc_net
  tipc: create broadcast transmission link at namespace init
  tipc: make link implementation independent from struct tipc_bearer
  tipc: use explicit allocation of broadcast send link
  tipc: make struct tipc_link generic to support broadcast
  tipc: let broadcast transmission use new link transmit function
  tipc: introduce capability bit for broadcast synchronization
  tipc: let broadcast packet reception use new link receive function
  tipc: simplify bearer level broadcast
  tipc: introduce jumbo frame support for broadcast
  tipc: let neighbor discoverer tranmsit consumable buffers
  tipc: eliminate redundant buffer cloning at transmission
  tipc: eliminate link's reference to owner node
  tipc: ensure binding table initial distribution is sent via first link
  tipc: clean up unused code and structures

 net/tipc/bcast.c      | 988 ++++++++++++--------------------------------------
 net/tipc/bcast.h      | 122 ++-----
 net/tipc/bearer.c     |  94 +++--
 net/tipc/bearer.h     |   9 +-
 net/tipc/core.c       |   9 +
 net/tipc/core.h       |  12 +-
 net/tipc/discover.c   |  28 +-
 net/tipc/link.c       | 775 +++++++++++++++++++++------------------
 net/tipc/link.h       |  76 ++--
 net/tipc/msg.c        |  20 +-
 net/tipc/msg.h        |   8 +-
 net/tipc/name_distr.c |   4 +-
 net/tipc/net.c        |   6 +-
 net/tipc/node.c       | 184 ++++++----
 net/tipc/node.h       |  41 +--
 net/tipc/socket.c     |   4 +-
 net/tipc/udp_media.c  |  12 +-
 17 files changed, 1005 insertions(+), 1387 deletions(-)

-- 
1.9.1
