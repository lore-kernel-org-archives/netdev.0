From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 8/8] af_unix: Unsubscribe sockets from their multicast groups on RCV_SHUTDOWN
Date: Fri, 21 Jan 2011 14:39:48 +0000
Message-ID: <1295620788-6002-8-git-send-email-alban.crequy@collabora.co.uk>
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
 net/unix/af_unix.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 138d9a2..9b281cf 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2820,6 +2820,10 @@ static int unix_shutdown(struct socket *sock, int mode)
 {
 	struct sock *sk = sock->sk;
 	struct sock *other;
+#ifdef CONFIG_UNIX_MULTICAST
+	struct unix_sock *u = unix_sk(sk);
+	int unsubscribed = 0;
+#endif
 
 	mode = (mode+1)&(RCV_SHUTDOWN|SEND_SHUTDOWN);
 
@@ -2831,7 +2835,38 @@ static int unix_shutdown(struct socket *sock, int mode)
 	other = unix_peer(sk);
 	if (other)
 		sock_hold(other);
+
+#ifdef CONFIG_UNIX_MULTICAST
+	/* If the socket subscribed to a multicast group and it is shutdown
+	 * with (mode&RCV_SHUTDOWN), it should be unsubscribed or at least
+	 * stop blocking the peers */
+	if (mode&RCV_SHUTDOWN) {
+		struct unix_mcast *node;
+		struct hlist_node *pos;
+		struct hlist_node *pos_tmp;
+
+		spin_lock(&unix_multicast_lock);
+		hlist_for_each_entry_safe(node, pos, pos_tmp,
+					  &u->mcast_subscriptions,
+					  subscription_node) {
+			hlist_del_rcu(&node->member_node);
+			hlist_del_rcu(&node->subscription_node);
+			atomic_dec(&node->group->mcast_members_cnt);
+			atomic_inc(&node->group->mcast_membership_generation);
+			hlist_add_head_rcu(&node->member_dead_node,
+					   &node->group->mcast_dead_members);
+			unsubscribed = 1;
+		}
+		spin_unlock(&unix_multicast_lock);
+	}
+#endif
 	unix_state_unlock(sk);
+
+#ifdef CONFIG_UNIX_MULTICAST
+	if (unsubscribed)
+		wake_up_interruptible_all(&u->peer_wait);
+#endif
+
 	sk->sk_state_change(sk);
 
 	if (other &&
-- 
1.7.2.3
