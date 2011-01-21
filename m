From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 7/8] af_unix: implement poll(POLLOUT) for multicast sockets
Date: Fri, 21 Jan 2011 14:39:47 +0000
Message-ID: <1295620788-6002-7-git-send-email-alban.crequy@collabora.co.uk>
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

When a socket subscribed to a multicast group has its incoming queue full, it
can either block the emission to the multicast group or let the messages be
dropped. The latter is useful to monitor all messages without slowing down the
traffic.

It is specified with the flag UNIX_MREQ_DROP_WHEN_FULL when the multicast group
is joined.

poll(POLLOUT) is implemented by checking all receiving queues of subscribed
sockets. If only one of them has its receiving queue full and does not have
UNIX_MREQ_DROP_WHEN_FULL, the multicast socket is not writeable.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Ian Molton <ian.molton@collabora.co.uk>
---
 net/unix/af_unix.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4147d64..138d9a2 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2940,6 +2940,11 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 {
 	struct sock *sk = sock->sk, *other;
 	unsigned int mask, writable;
+#ifdef CONFIG_UNIX_MULTICAST
+	struct sock_set *others;
+	int err = 0;
+	int i;
+#endif
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask = 0;
@@ -2980,6 +2985,34 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 		sock_put(other);
 	}
 
+#ifdef CONFIG_UNIX_MULTICAST
+	/*
+	 * On multicast sockets, we need to check if the receiving queue is
+	 * full on all peers who don't have UNIX_MREQ_DROP_WHEN_FULL.
+	 */
+	if (!other || !unix_sk(other)->mcast_group)
+		goto skip_multicast;
+	others = unix_find_multicast_recipients(sk,
+		unix_sk(other)->mcast_group, &err);
+	if (!others)
+		goto skip_multicast;
+	for (i = others->offset ; i < others->cnt ; i++) {
+		if (others->items[i].flags & UNIX_MREQ_DROP_WHEN_FULL)
+			continue;
+		if (unix_peer(others->items[i].s) != sk) {
+			sock_poll_wait(file,
+				&unix_sk(others->items[i].s)->peer_wait, wait);
+			if (unix_recvq_full(others->items[i].s)) {
+				writable = 0;
+				break;
+			}
+		}
+	}
+	up_sock_set(others);
+
+skip_multicast:
+#endif
+
 	if (writable)
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-- 
1.7.2.3
