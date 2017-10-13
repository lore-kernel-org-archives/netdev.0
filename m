From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next v2 00/18] tipc: Introduce Communcation Group feature
Date: Fri, 13 Oct 2017 11:04:16 +0200
Message-ID: <1507885474-11213-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:59735 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753406AbdJMJEt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 05:04:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this commit series we introduce a 'Group Communication' feature in
order to resolve the datagram and multicast flow control problem. This 
new feature makes it possible for a user to instantiate multiple private
virtual brokerless message buses by just creating and joining member 
sockets.

The main features are as follows:
---------------------------------
- Sockets can join a group via a new setsockopt() call TIPC_GROUP_JOIN.
  If it is the first socket of the group this implies creation of the
  group. This call takes four parameters: 'type' serves as group 
  identifier, 'instance' serves as member identifier, and 'scope' 
  indicates the visibility of the group (node/cluster/zone). Finally,
  'flags' indicates different options for the socket joining the group. 
  For the time being, there are only two such flags: 1) 'LOOPBACK'
  indicates if the creator of the socket wants to receive a copy of 
  broadcast or multicast messages it sends to the group, 2) EVENTS 
  indicates if it wants to receive membership (JOINED/LEFT) events for
  the other members of the group.

- Groups are closed, i.e., sockets which have not joined a group will
  not be able to send messages to or receive messages from members of
  the group, and vice versa. A socket can only be member of one group
  at a time.

- There are four transmission modes.
  1: Unicast. The sender transmits a message using the port identity
     (node:port tuple) of the receiving socket.
  2: Anycast. The sender transmits a message using a port name (type:
     instance:scope) of one of the receiving sockets. If more than
     one member socket matches the given address a destination is 
     selected according to a round-robin algorithm, but also considering
     the destination load (advertised window size) as an additional
     criteria.
  3: Multicast. The sender transmits a message using a port name 
     (type:instance:scope) of one or more of the receiving sockets.
     All sockets in the group matching the given address will receive
     a copy of the message. 
  4: Broadcast. The sender transmits a message using the primtive
     send(). All members of the group, irrespective of their member
     identity (instance) number receive a copy of the message.

- TIPC broadcast is used for carrying messages in mode 3 or 4 when
  this is deemed more efficient, i.e., depending on number of actual
  destinations.

- All transmission modes are flow controlled, so that messages never
  are dropped or rejected, just like we are used to from connection
  oriented communication. A special algorithm guarantees that this is
  true even for multipoint-to-point communication, i.e., at occasions
  where many source sockets may decide to send simultaneously towards
  the same  destination socket.

- Sequence order is always guaranteed, even between the different
  transmission modes.

- Member join/leave events are received in all other member sockets
  in guaranteed order. I.e., a 'JOINED' (an empty message with the OOB
  bit set) will always be received before the first data message from
  a new member, and a 'LEAVE' (like 'JOINED', but with EOR bit set) will
  always arrive after the last data message from a leaving member.

-----
v2: Reordered variable declarations in descending length order, as per
    feedback from David Miller. This was done as far as permitted by the
    the initialization order.

Jon Maloy (18):
  tipc: add ability to order and receive topology events in driver
  tipc: improve address sanity check in tipc_connect()
  tipc: add ability to obtain node availability status from other files
  tipc: refactor function filter_rcv()
  tipc: add new function for sending multiple small messages
  tipc: improve destination linked list
  tipc: introduce communication groups
  tipc: add second source address to recvmsg()/recvfrom()
  tipc: receive group membership events via member socket
  tipc: introduce flow control for group broadcast messages
  tipc: introduce group unicast messaging
  tipc: introduce group anycast messaging
  tipc: introduce group multicast messaging
  tipc: guarantee group unicast doesn't bypass group broadcast
  tipc: guarantee that group broadcast doesn't bypass group unicast
  tipc: guarantee delivery of UP event before first broadcast
  tipc: guarantee delivery of last broadcast before DOWN event
  tipc: add multipoint-to-point flow control

 include/uapi/linux/tipc.h |  15 +
 net/tipc/Makefile         |   2 +-
 net/tipc/bcast.c          |  18 +-
 net/tipc/core.h           |   5 +
 net/tipc/group.c          | 871 ++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/group.h          |  73 ++++
 net/tipc/link.c           |   9 +-
 net/tipc/msg.c            |   7 +
 net/tipc/msg.h            | 118 ++++++-
 net/tipc/name_table.c     | 174 ++++++---
 net/tipc/name_table.h     |  28 +-
 net/tipc/node.c           |  42 ++-
 net/tipc/node.h           |   5 +-
 net/tipc/server.c         | 121 +++++--
 net/tipc/server.h         |   5 +-
 net/tipc/socket.c         | 787 ++++++++++++++++++++++++++++++++---------
 16 files changed, 1997 insertions(+), 283 deletions(-)
 create mode 100644 net/tipc/group.c
 create mode 100644 net/tipc/group.h

-- 
2.1.4
