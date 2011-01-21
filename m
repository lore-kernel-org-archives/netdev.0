From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 1/8] af_unix: Documentation on multicast unix sockets
Date: Fri, 21 Jan 2011 14:39:41 +0000
Message-ID: <1295620788-6002-1-git-send-email-alban.crequy@collabora.co.uk>
References: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
Cc: Alban Crequy <alban.crequy@collabora.co.uk>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Ian Molton <ian.molton@collabora.co.uk>
---
 .../networking/multicast-unix-sockets.txt          |  171 ++++++++++++++++++++
 1 files changed, 171 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/multicast-unix-sockets.txt

diff --git a/Documentation/networking/multicast-unix-sockets.txt b/Documentation/networking/multicast-unix-sockets.txt
new file mode 100644
index 0000000..0cc30cb
--- /dev/null
+++ b/Documentation/networking/multicast-unix-sockets.txt
@@ -0,0 +1,171 @@
+Multicast Unix sockets
+======================
+
+Multicast is implemented on SOCK_DGRAM and SOCK_SEQPACKET Unix sockets.
+
+An userspace application can create a multicast group with:
+
+  struct unix_mreq mreq = {0,};
+  mreq.address.sun_family = AF_UNIX;
+  mreq.address.sun_path[0] = '\0';
+  strcpy(mreq.address.sun_path + 1, "socket-address");
+
+  sockfd = socket(AF_UNIX, SOCK_DGRAM, 0);
+  ret = setsockopt(sockfd, SOL_UNIX, UNIX_CREATE_GROUP, &mreq, sizeof(mreq));
+
+This allocates a struct unix_mcast_group, which is reference counted and exists
+as long as the socket who created it exists or the group has at least one
+member.
+
+Then a multicast group can be joined with:
+
+  ret = setsockopt(sockfd, SOL_UNIX, UNIX_JOIN_GROUP, &mreq, sizeof(mreq));
+
+This allocates a struct unix_mcast, which holds the settings of the membership,
+mainly whether loopback is enabled. A socket can be a member of several
+multicast groups.
+
+The socket is part of the multicast group until it is released, shutdown with
+RCV_SHUTDOWN or it leaves explicitely the group:
+
+  ret = setsockopt(sockfd, SOL_UNIX, UNIX_LEAVE_GROUP, &mreq, sizeof(mreq));
+
+Struct unix_mcast nodes are linked in two RCU lists:
+- (struct unix_sock)->mcast_subscriptions
+- (struct unix_mcast_group)->mcast_members
+
+              unix_mcast_group  unix_mcast_group
+                      |                 |
+                      v                 v
+unix_sock  ---->  unix_mcast  ----> unix_mcast
+                      |
+                      v
+unix_sock  ---->  unix_mcast
+                      |
+                      v
+unix_sock  ---->  unix_mcast
+
+
+SOCK_DGRAM semantics
+====================
+
+          G          The socket which created the group
+       /  |  \
+     P1  P2  P3      The member sockets
+
+Messages sent to the group are received by all members except the sender itself
+unless the sending socket has UNIX_MREQ_LOOPBACK set.
+
+Non-members can also send to the group socket G and the message will be
+broadcast to the group members, however socket G does not receive messages sent
+to the group, via it, itself.
+
+
+SOCK_SEQPACKET semantics
+========================
+
+When a connection is performed on a SOCK_SEQPACKET multicast socket, a new
+socket is created and its file descriptor is received by accept().
+
+          L          The listening socket
+       /  |  \
+     A1  A2  A3      The accepted sockets
+      |   |   |
+     C1  C2  C3      The connected sockets
+
+Messages sent on the C1 socket are received by:
+- C1 itself if UNIX_MREQ_LOOPBACK is set.
+- The peer socket A1 if UNIX_MREQ_SEND_TO_PEER is set.
+- The other members of the multicast group C2 and C3.
+
+Only members can send to the group in this case.
+
+
+Atomic delivery and ordering
+============================
+
+Each message sent is delivered atomically to either none of the recipients or
+all the recipients, even with interruptions and errors.
+
+Locking is used in order to keep the ordering consistent on all recipients. We
+want to avoid the following scenario. Two emitters A and B, and 2 recipients, C
+and D:
+
+           C    D
+A -------->|    |    Step 1: A's message is delivered to C
+B -------->|    |    Step 2: B's message is delivered to C
+B ---------|--->|    Step 3: B's message is delivered to D
+A ---------|--->|    Step 4: A's message is delivered to D
+
+Result: - C received (A, B)
+        - D received (B, A)
+
+Although A and B had a list of recipients (C, D) in the same order, C and D
+received the messages in a different order. To avoid this scenario, we need a
+locking mechanism while the messages are being delivered with skb_queue_tail().
+
+Solution 1:
+The easiest implementation would be to use a global spinlock on the group, but
+it creates an avoidable contention, especially when there are two independent
+streams set up with socket filters; e.g. if A sends messages received only by
+C, and B sends messages received only by D.
+
+Solution 2:
+Fine-grained locking could be implemented with a spinlock on each recipient.
+Before delivering the message to the recipients, the sender takes a spinlock on
+each recipient at the same time.
+
+Taking several spinlocks on the same struct can be dangerous and leads to
+deadlocks. This is prevented by sorting the list of sockets by memory address
+and taking the spinlocks in that order. The ordered list of recipients is
+computed on demand when a message is sent and the list is cached for
+performance. When the group membership changes, the generation of the
+membership is incremented and the ordered recipient list is invalidated.
+
+With this solution, the number of spinlocks taken simultaneously can be
+arbitrary big. Whilst it works, it breaks the lockdep mechanism.
+
+Solution 3:
+The current implementation is similar to solution 2 but with a limit on the
+number of spinlocks taken simultaneously (8), so lockdep works fine. A hash
+function and bit array with n=8 specifies which spinlocks to take.  Contention
+on independent streams can still happen but it is less likely.
+
+
+Flow control
+============
+
+When a socket's receiving queue is full, the default behavior is to block
+senders (or to return -EAGAIN on non-blocking sockets). The socket can also
+join a multicast group with the flag UNIX_MREQ_DROP_WHEN_FULL. In this case,
+messages sent to the group will not be delivered to that socket when its
+receiving queue is full.
+
+Messages are still delivered atomically to all members who don't have the flag
+UNIX_MREQ_DROP_WHEN_FULL. If send() returns -EAGAIN, nobody received the
+message. If send() blocks because of one member, the other members don't
+receive the message until all sockets (except those with
+UNIX_MREQ_DROP_WHEN_FULL set) can receive at the same time.
+
+poll/epoll/select on POLLOUT events have a consistent behavior; they block if
+at least one member of the multicast group without UNIX_MREQ_DROP_WHEN_FULL has
+a full receiving queue.
+
+
+Multicast socket reference counting
+===================================
+
+A poller for POLLOUT events can block for any member of the group. The poller
+can use the wait queue "peer_wait" of any member. So it is important that Unix
+sockets are not released before all pollers exit. This is achieved by:
+
+- Incrementing the reference counter of a socket when it joins a multicast
+  group.
+- Decrementing it when the group is destroyed, that is when all
+  sockets keeping a reference on the group released their reference on the
+  group.
+
+struct unix_mcast_group keeps track of both current members and previous
+members. When a socket leaves a group, it is removed from the members list and
+put in the dead members list. This is done in order to take advantage of RCU
+lists, which reduces lock contention.
-- 
1.7.2.3
