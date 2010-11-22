From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 4/9] AF_UNIX: find the recipients for multicast messages
Date: Mon, 22 Nov 2010 18:36:17 +0000
Message-ID: <1290450982-17480-4-git-send-email-alban.crequy@collabora.co.uk>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:38610 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757264Ab0KVSjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 13:39:40 -0500
In-Reply-To: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unix_find_multicast_recipients() builds an array of recipients. It can either
find the peers of a specific multicast address, or find all the peers of all
multicast group the sender is part of.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 net/unix/af_unix.c |  144 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 144 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 2278829..3cc9695 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -114,15 +114,48 @@
 #include <linux/mount.h>
 #include <net/checksum.h>
 #include <linux/security.h>
+#include <linux/sort.h>
 
 static struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 static DEFINE_SPINLOCK(unix_table_lock);
+static DEFINE_SPINLOCK(unix_multicast_lock);
 static atomic_long_t unix_nr_socks;
 
 #define unix_sockets_unbound	(&unix_socket_table[UNIX_HASH_SIZE])
 
 #define UNIX_ABSTRACT(sk)	(unix_sk(sk)->addr->hash != UNIX_HASH_SIZE)
 
+struct sock_item {
+	struct sock *s;
+	struct sk_buff *skb;
+	int to_deliver;
+};
+
+struct sock_set {
+	int cnt;
+	struct sock_item items[0];
+};
+
+static void kfree_sock_set(struct sock_set *set)
+{
+	int i;
+	for (i = 0 ; i < set->cnt ; i++)
+		sock_put(set->items[i].s);
+	kfree(set);
+}
+
+static int sock_item_compare(const void *_a, const void *_b)
+{
+	const struct sock_item *a = _a;
+	const struct sock_item *b = _b;
+	if (a->s > b->s)
+		return 1;
+	else if (a->s < b->s)
+		return -1;
+	else
+		return 0;
+}
+
 #ifdef CONFIG_SECURITY_NETWORK
 static void unix_get_secdata(struct scm_cookie *scm, struct sk_buff *skb)
 {
@@ -824,6 +857,117 @@ fail:
 	return NULL;
 }
 
+static int unix_find_multicast_members(struct sock_set *set,
+				       int recipient_cnt,
+				       struct sock *sender,
+				       struct hlist_head *list)
+{
+	struct unix_mcast *node;
+	struct hlist_node *pos;
+	hlist_for_each_entry(node, pos, list,
+			     member_node) {
+		if (set->cnt + 1 > recipient_cnt)
+			return -ENOMEM;
+		if (node->member == unix_sk(sender) &&
+		    !(node->flags & UNIX_MREQ_LOOPBACK))
+			continue;
+
+		sock_hold(&node->member->sk);
+		set->items[set->cnt].s = &node->member->sk;
+		set->items[set->cnt].skb = NULL;
+		set->items[set->cnt].to_deliver = 1;
+		set->cnt++;
+	}
+	return 0;
+}
+
+/* Find the recipients for a message sent by 'sender' to 'addr'. If 'dest' is
+ * NULL, the recipients are peers of all subscribed groups.
+ */
+static struct sock_set *unix_find_multicast_recipients(struct sock *sender,
+						       struct sock *dest,
+						       int *err)
+{
+	struct unix_sock *u = unix_sk(sender);
+	struct unix_mcast *node;
+	struct hlist_node *pos;
+	struct sock_set *set;
+	int recipient_cnt;
+
+	/* We cannot allocate in the spin lock. First, count the recipients */
+try_again:
+	spin_lock(&unix_multicast_lock);
+	if (dest != NULL) {
+		if (unix_sk(dest)->is_mcast_addr) {
+			recipient_cnt = unix_sk(dest)->mcast_members_cnt;
+		} else {
+			recipient_cnt = 1;
+		}
+	} else {
+		recipient_cnt = 0;
+		hlist_for_each_entry(node, pos, &u->mcast_subscriptions,
+				     subscription_node) {
+			recipient_cnt += node->addr->mcast_members_cnt;
+		}
+	}
+	spin_unlock(&unix_multicast_lock);
+
+        /* Allocate for the set and hope the number of recipients does not
+	 * change while the lock is released. If it changes, we have to try
+	 * again... We allocate a bit more than needed, so if a _few_ members
+	 * are added in a multicast group meanwhile, we don't always need to
+	 * try again. */
+	recipient_cnt += 5;
+
+	set = kmalloc(sizeof(struct sock_set)
+		      + sizeof(struct sock_item) * recipient_cnt,
+	    GFP_KERNEL);
+	if (!set) {
+		*err = -ENOMEM;
+		return NULL;
+	}
+	set->cnt = 0;
+
+	spin_lock(&unix_multicast_lock);
+	if (dest && unix_sk(dest)->is_mcast_addr) {
+		/* Message sent to a multicast address */
+		if (unix_find_multicast_members(set, recipient_cnt,
+				sender,
+				&unix_sk(dest)->mcast_members)) {
+			spin_unlock(&unix_multicast_lock);
+			kfree_sock_set(set);
+			goto try_again;
+		}
+	} else if (!dest) {
+		/* Destination not specified, sending to all peers of
+		 * subscribed groups */
+		hlist_for_each_entry(node, pos, &u->mcast_subscriptions,
+				     subscription_node) {
+			if (unix_find_multicast_members(set, recipient_cnt,
+					sender,
+					&node->addr->mcast_members)) {
+				spin_unlock(&unix_multicast_lock);
+				kfree_sock_set(set);
+				goto try_again;
+			}
+		}
+	} else {
+		/* Message sent to a non-multicast address */
+		BUG_ON(recipient_cnt < 1);
+		set->cnt = 1;
+		sock_hold(dest);
+		set->items[0].s = dest;
+		set->items[0].skb = NULL;
+		set->items[0].to_deliver = 1;
+	}
+	spin_unlock(&unix_multicast_lock);
+
+	/* Keep the array ordered to prevent deadlocks on circular waits */
+	sort(set->items, set->cnt, sizeof(struct sock_item),
+	     sock_item_compare, NULL);
+	return set;
+}
+
 
 static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
-- 
1.7.1

