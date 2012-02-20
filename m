From: Javier Martinez Canillas <javier@collabora.co.uk>
Subject: [PATCH 07/10] af_unix: implement poll(POLLOUT) for multicast sockets
Date: Mon, 20 Feb 2012 17:33:46 +0100
Message-ID: <1329755629-10644-4-git-send-email-javier@collabora.co.uk>
References: <1329755629-10644-1-git-send-email-javier@collabora.co.uk>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	Bart Cerneels <bart.cerneels@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329755629-10644-1-git-send-email-javier@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>

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
 net/unix/af_unix.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index a6b489c..bd9dc58 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2974,6 +2974,11 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
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
@@ -3011,6 +3016,48 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 			if (unix_recvq_full(other))
 				writable = 0;
 		}
+
+#ifdef CONFIG_UNIX_MULTICAST
+		/*
+		 * On multicast sockets, we need to check if the receiving
+		 * queue is full on all peers who don't have
+		 * UNIX_MREQ_DROP_WHEN_FULL.
+		 */
+
+		/* Don't let the group die under us */
+		unix_state_lock(other);
+		if (sock_flag(other, SOCK_DEAD)
+			|| !unix_sk(other)->mcast_group) {
+			unix_state_unlock(other);
+			goto skip_multicast;
+		}
+		atomic_inc(&unix_sk(other)->mcast_group->refcnt);
+		unix_state_unlock(other);
+
+		others = unix_find_multicast_recipients(sk,
+			unix_sk(other)->mcast_group, &err);
+		if (!others)
+			goto skip_multicast_peers;
+		for (i = others->offset ; i < others->cnt ; i++) {
+			if (others->items[i].flags & UNIX_MREQ_DROP_WHEN_FULL)
+				continue;
+			if (unix_peer(others->items[i].s) != sk) {
+				sock_poll_wait(file,
+					&unix_sk(others->items[i].s)
+						->peer_wait, wait);
+				if (unix_recvq_full(others->items[i].s)) {
+					writable = 0;
+					break;
+				}
+			}
+		}
+		up_sock_set(others);
+skip_multicast_peers:
+		if (atomic_dec_and_test(&unix_sk(other)->mcast_group->refcnt))
+			destroy_mcast_group(unix_sk(other)->mcast_group);
+
+skip_multicast:
+#endif
 		sock_put(other);
 	}
 
-- 
1.7.7.6
