From: Javier Martinez Canillas <javier@collabora.co.uk>
Subject: [PATCH 08/10] af_unix: Unsubscribe sockets from their multicast groups on RCV_SHUTDOWN
Date: Mon, 20 Feb 2012 17:33:47 +0100
Message-ID: <1329755629-10644-5-git-send-email-javier@collabora.co.uk>
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

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Ian Molton <ian.molton@collabora.co.uk>
---
 net/unix/af_unix.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index bd9dc58..07e6b05 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2841,6 +2841,10 @@ static int unix_shutdown(struct socket *sock, int mode)
 {
 	struct sock *sk = sock->sk;
 	struct sock *other;
+#ifdef CONFIG_UNIX_MULTICAST
+	struct unix_sock *u = unix_sk(sk);
+	int unsubscribed = 0;
+#endif
 
 	mode = (mode+1)&(RCV_SHUTDOWN|SEND_SHUTDOWN);
 
@@ -2852,7 +2856,38 @@ static int unix_shutdown(struct socket *sock, int mode)
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
1.7.7.6
