From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: [RFCv3] 0/14 af_unix: Multicast and filtering features on AF_UNIX
Date: Mon, 20 Feb 2012 10:26:13 +0100
Message-ID: <4F4211B5.2050602@collabora.co.uk>
References: <4F35206D.8010604@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	Bart Cerneels <bart.cerneels@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:42597 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab2BTJcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 04:32:07 -0500
In-Reply-To: <4F35206D.8010604@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Following is an extension to AF_UNIX datagram and seqpacket sockets to
support multicast communication. This work was made by Alban Crequy as a
result from a research we have been doing to improve the performance of
the D-bus IPC system.

The first approach was to create a new AF_DBUS socket address family and
move the routing logic of the D-bus daemon to the kernel. The
motivations behind that approach and the thread of the patches post can
be found in [1] and [2] respectively.

The feedback was that having D-bus specific code in the kernel is a bad
idea so the second approach was to implement multicast Unix domain
sockets so clients can directly send messages to peers bypassing the
D-bus daemon. A previous version of the patches was already posted by
Alban [3] who has also a good explanation of the implementation on
his blog [4].

The stable and development version of the patches can be found in [5]
and [6] respectively. It is a work in progress so probably some issues
can be found.

We didn't want to send the full patches since we are more interested to
discuss the proposed architecture and ABI rather than the kernel
implementation (which can always be rework to meet upstream code quality).

[1]http://alban-apinc.blogspot.com/2011/12/d-bus-in-kernel-faster.html
[2]http://thread.gmane.org/gmane.linux.kernel/1040481
[3]http://thread.gmane.org/gmane.linux.network/178772
[4]http://alban-apinc.blogspot.com/2011/12/introducing-multicast-unix-sockets.html
[5]http://cgit.collabora.com/git/user/javier/linux.git/log/?h=multicast-unix-socket-stable
[6]http://cgit.collabora.com/git/user/javier/linux.git/log/?h=multicast-attach-peer-filter

Multicast Unix sockets summary
==============================

Multicast is implemented on SOCK_DGRAM and SOCK_SEQPACKET Unix sockets.

An userspace application can create a multicast group with:

  struct unix_mreq mreq = {0,};
  mreq.address.sun_family = AF_UNIX;
  mreq.address.sun_path[0] = '\0';
  strcpy(mreq.address.sun_path + 1, "socket-address");

  sockfd = socket(AF_UNIX, SOCK_DGRAM, 0);
  ret = setsockopt(sockfd, SOL_UNIX, UNIX_CREATE_GROUP, &mreq,
sizeof(mreq));

This allocates a struct unix_mcast_group, which is reference counted and
exists as long as the socket who created it exists or the group has at
least one member.

SOCK_DGRAM sockets can join a multicast group with:

  ret = setsockopt(sockfd, SOL_UNIX, UNIX_JOIN_GROUP, &mreq, sizeof(mreq));

This allocates a struct unix_mcast, which holds the settings of the
membership, mainly whether loopback is enabled. A socket can be a member
of several multicast groups.

Since the SOCK_SEQPACKET is connection-oriented the semantics are
different. A client cannot join a group but it can only connect and the
multicast listen socket is used to allow the peer to join the group with:

  ret = setsockopt(groupfd, SOL_UNIX, UNIX_CREATE_GROUP, &val, vallen);
  ret = listen(groupfd, 10);
  connfd = accept(sockfd, NULL, 0);
  ret = setsockopt(connfd, SOL_UNIX, UNIX_ACCEPT_GROUP, &mreq,
sizeof(mreq));

The socket is part of the multicast group until it is released, shutdown
with RCV_SHUTDOWN or it leaves explicitely the group:

  ret = setsockopt(sockfd, SOL_UNIX, UNIX_LEAVE_GROUP, &mreq, sizeof(mreq));

Struct unix_mcast nodes are linked in two RCU lists:
- (struct unix_sock)->mcast_subscriptions
- (struct unix_mcast_group)->mcast_members

              unix_mcast_group  unix_mcast_group
                      |                 |
                      v                 v
unix_sock  ---->  unix_mcast  ----> unix_mcast
                      |
                      v
unix_sock  ---->  unix_mcast
                      |
                      v
unix_sock  ---->  unix_mcast


SOCK_DGRAM semantics
====================

          G          The socket which created the group
       /  |  \
     P1  P2  P3      The member sockets

Messages sent to the group are received by all members except the sender
itself unless the sending socket has UNIX_MREQ_LOOPBACK set.

Non-members can also send to the group socket G and the message will be
broadcast to the group members, however socket G does not receive
messages sent to the group, via it, itself.


SOCK_SEQPACKET semantics
========================

When a connection is performed on a SOCK_SEQPACKET multicast socket, a
new socket is created and its file descriptor is received by accept().

          L          The listening socket
       /  |  \
     A1  A2  A3      The accepted sockets
      |   |   |
     C1  C2  C3      The connected sockets

Messages sent on the C1 socket are received by:
- C1 itself if UNIX_MREQ_LOOPBACK is set.
- The peer socket A1 if UNIX_MREQ_SEND_TO_PEER is set.
- The other members of the multicast group C2 and C3.

Only members can send to the group in this case.


Atomic delivery and ordering
============================

Each message sent is delivered atomically to either none of the
recipients or all the recipients, even with interruptions and errors.

Locking is used in order to keep the ordering consistent on all
recipients. We want to avoid the following scenario. Two emitters A and
B, and 2 recipients, C and D:

           C    D
A -------->|    |    Step 1: A's message is delivered to C
B -------->|    |    Step 2: B's message is delivered to C
B ---------|--->|    Step 3: B's message is delivered to D
A ---------|--->|    Step 4: A's message is delivered to D

Result: - C received (A, B)
        - D received (B, A)

Although A and B had a list of recipients (C, D) in the same order, C
and D received the messages in a different order. To avoid this
scenario, we need a locking mechanism while the messages are being
delivered with skb_queue_tail().

Solution 1:
The easiest implementation would be to use a global spinlock on the
group, but it creates an avoidable contention, especially when there are
two independent streams set up with socket filters; e.g. if A sends
messages received only by C, and B sends messages received only by D.

Solution 2:
Fine-grained locking could be implemented with a spinlock on each recipient.
Before delivering the message to the recipients, the sender takes a
spinlock on each recipient at the same time.

Taking several spinlocks on the same struct can be dangerous and leads
to deadlocks. This is prevented by sorting the list of sockets by memory
address and taking the spinlocks in that order. The ordered list of
recipients is computed on demand when a message is sent and the list is
cached for performance. When the group membership changes, the
generation of the membership is incremented and the ordered recipient
list is invalidated.

With this solution, the number of spinlocks taken simultaneously can be
arbitrary big. Whilst it works, it breaks the lockdep mechanism.

Solution 3:
The current implementation is similar to solution 2 but with a limit on
the number of spinlocks taken simultaneously (8), so lockdep works fine.
A hash function and bit array with n=8 specifies which spinlocks to
take. Contention on independent streams can still happen but it is less
likely.


Flow control
============

When a socket's receiving queue is full, the default behavior is to
block senders (or to return -EAGAIN on non-blocking sockets). The socket
can also join a multicast group with the flag UNIX_MREQ_DROP_WHEN_FULL.
In this case, messages sent to the group will not be delivered to that
socket when its receiving queue is full.

Messages are still delivered atomically to all members who don't have
the flag UNIX_MREQ_DROP_WHEN_FULL. If send() returns -EAGAIN, nobody
received the message. If send() blocks because of one member, the other
members don't receive the message until all sockets (except those with
UNIX_MREQ_DROP_WHEN_FULL set) can receive at the same time.

poll/epoll/select on POLLOUT events have a consistent behavior; they
block if at least one member of the multicast group without
UNIX_MREQ_DROP_WHEN_FULL has a full receiving queue.


Multicast socket reference counting
===================================

A poller for POLLOUT events can block for any member of the group. The
poller can use the wait queue "peer_wait" of any member. So it is
important that Unix sockets are not released before all pollers exit.
This is achieved by:

- Incrementing the reference counter of a socket when it joins a
multicast group.
- Decrementing it when the group is destroyed, that is when all sockets
keeping a reference on the group released their reference onthe group.

struct unix_mcast_group keeps track of both current members and previous
members. When a socket leaves a group, it is removed from the members
list and put in the dead members list. This is done in order to take
advantage of RCU lists, which reduces lock contention.

=====================================

diff stat:

 Documentation/networking/multicast-unix-sockets.txt	|  171 ++++
 include/linux/filter.h                                 |    4 +
 include/linux/socket.h                                 |    1 +
 include/net/af_unix.h                                  |   79 ++
 include/net/sock.h                                     |    4 +
 net/core/filter.c                                      |  118 +++
 net/unix/Kconfig                                       |    9 +
 net/unix/af_unix.c                                     | 1052

Regards,
Javier
