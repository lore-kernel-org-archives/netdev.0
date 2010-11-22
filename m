From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 7/9] AF_UNIX: Documentation on multicast Unix Sockets
Date: Mon, 22 Nov 2010 18:36:20 +0000
Message-ID: <1290450982-17480-7-git-send-email-alban.crequy@collabora.co.uk>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 .../networking/multicast-unix-sockets.txt          |   76 ++++++++++++++++++++
 1 files changed, 76 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/multicast-unix-sockets.txt

diff --git a/Documentation/networking/multicast-unix-sockets.txt b/Documentation/networking/multicast-unix-sockets.txt
new file mode 100644
index 0000000..b9882a1
--- /dev/null
+++ b/Documentation/networking/multicast-unix-sockets.txt
@@ -0,0 +1,76 @@
+Multicast Unix sockets
+======================
+
+Multicast group memberships are stored in struct unix_mcast nodes. An Unix
+socket can join several multicast groups. Struct unix_mcast nodes are doubly
+linked:
+- In (struct unix_sock)->mcast_subscriptions
+- In (struct unix_sock)->mcast_members
+
+Example
+=======
+
+                   Addr1             Addr2
+                     |                 |
+                     v                 v
+Socket1  ---->  mcast node  ----> mcast node
+                     |
+                     v
+Socket2  ---->  mcast node
+                     |
+                     v
+Socket3  ---->  mcast node
+
+
+Addr1 and Addr2 are struct unix_sock with is_mcast_addr set to 1. They are
+bount to a multicast address with:
+  setsockopt(sockfd, SOL_UNIX, UNIX_CREATE_GROUP, ...).
+
+Socket1, Socket2 and Socket3 are also struct unix_sock. They are associated to
+a multicast address with:
+  setsockopt(sockfd, SOL_UNIX, UNIX_JOIN_GROUP, ...).
+
+Socket1 joined two multicast groups. Socket2 and Socket3 joined one multicast
+group. The multicast group Addr1 has 3 members. Addr2 has one member.
+
+Atomic delivery and ordering
+============================
+
+Each message sent is delivered atomically to either none of the recipients or
+all the recipients, even with interruptions and errors.
+
+The locking is done to keep the ordering consistent on all recipients. We want
+to avoid the following scenario. Two emitters A and B, and 2 recipients C and
+D:
+
+           C    D
+A -------->|    |    Step 1: A's message is delivered to C
+B -------->|    |    Step 2: B's message is delivered to C
+B ---------|--->|    Step 3: B's message is delivered to D
+A ---------|--->|    Step 4: A's message is delivered to D
+
+Although A and B had a list of recipients (C, D) in the same order, C and D
+received the messages in a different order.
+
+
+SOCK_SEQPACKET semantics
+========================
+
+When a connection is performed on a SOCK_SEQPACKET multicast socket, a new
+socket is created and its file descriptor is received with accept(). The new
+socket could join the multicast group from userspace with setsockopt() but
+there would be race: it could lose the first messages sent by an application
+after connect() returns but before setsockopt() is executed.
+
+To avoid that race, the application should use the flag UNIX_MREQ_AUTOJOIN when
+creating the multicast group.
+
+When several connections are established to a SOCK_SEQPACKET multicast socket,
+the creator of the multicast group using UNIX_MREQ_AUTOJOIN would receive the
+messages several times: one time on each accepted socket. To avoid that, the
+creator of the group may prefer to use UNIX_MREQ_SEND_TO_PEER. Then, the
+accepted socket will not be part of the group but will still receive messages
+from its peer.
+
+
+
-- 
1.7.1
