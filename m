From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 00/11] standardize TIPC SKB queue operations
Date: Wed, 26 Nov 2014 11:41:44 +0800
Message-ID: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <richard.alpe@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:43983 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbaKZDmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 22:42:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the following SKB queues are created and maintained within internal
TIPC stack:

- link transmission queue
- link deferred queue
- link receive queue
- socket outgoing packet chain
- name table outgoing packet chain

In order to manage above queues, TIPC stack declares a sk_buff pointer
for each queue to record its head, and directly modifies "prev" and
"next" SKB pointers of SKB structure when inserting or deleting a SKB
to or from the queue. As these operations are pretty complex, they
easily involve fatal mistakes. If these sk_buff pointers are replaced
with sk_buff_head instances as queue heads and corresponding generic
SKB list APIs are used to manage them, the entire TIPC code would
become quite clean and readable. But before make the change, we need
to clean up below redundant functionalities:

- remove node subscribe infrastructure
- remove protocol message queue
- remove retransmission queue
- clean up process of pushing packets in link layer 

Ying Xue (11):
  tipc: remove node subscription infrastructure
  tipc: remove protocol message queue
  tipc: remove retransmission queue
  tipc: clean up the process of link pushing packets
  tipc: eliminate two pseudo message types of BUNDLE_OPEN and
    BUNDLE_CLOSED
  tipc: remove unused between routine
  tipc: use skb_queue_walk_safe marco to simplify link_prepare_wakeup
    routine
  tipc: use generic SKB list APIs to manage link transmission queue
  tipc: use generic SKB list APIs to manage deferred queue of link
  tipc: use generic SKB list APIs to manage link receive queue
  tipc: use generic SKB list APIs to manage TIPC outgoing packet chains

 net/tipc/Makefile      |    4 +-
 net/tipc/bcast.c       |  109 +++++-----
 net/tipc/bcast.h       |    2 +-
 net/tipc/bearer.h      |    2 +-
 net/tipc/core.h        |    1 +
 net/tipc/link.c        |  514 ++++++++++++++++++++----------------------------
 net/tipc/link.h        |   48 ++---
 net/tipc/msg.c         |  125 ++++++------
 net/tipc/msg.h         |   16 +-
 net/tipc/name_distr.c  |   98 ++++++---
 net/tipc/name_distr.h  |    1 +
 net/tipc/name_table.c  |    2 +-
 net/tipc/name_table.h  |    6 +-
 net/tipc/node.c        |   10 +-
 net/tipc/node.h        |   12 +-
 net/tipc/node_subscr.c |   96 ---------
 net/tipc/node_subscr.h |   63 ------
 net/tipc/socket.c      |  127 ++++++------
 18 files changed, 496 insertions(+), 740 deletions(-)
 delete mode 100644 net/tipc/node_subscr.c
 delete mode 100644 net/tipc/node_subscr.h

-- 
1.7.9.5
