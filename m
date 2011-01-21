From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 5/8] af_unix: find the recipients of a multicast group
Date: Fri, 21 Jan 2011 14:39:45 +0000
Message-ID: <1295620788-6002-5-git-send-email-alban.crequy@collabora.co.uk>
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

unix_find_multicast_recipients() returns a list of recipients for the specific
multicast address. It checks the options UNIX_MREQ_SEND_TO_PEER and
UNIX_MREQ_LOOPBACK to get the right recipients.

The list of recipients is ordered and guaranteed not to have duplicates.

When the caller has finished with the list of recipients, it will call
up_sock_set() and the list can be reused by another sender.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Ian Molton <ian.molton@collabora.co.uk>
---
 net/unix/af_unix.c |  259 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 256 insertions(+), 3 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f25c020..fe0d3bb 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -114,18 +114,84 @@
 #include <linux/mount.h>
 #include <net/checksum.h>
 #include <linux/security.h>
-
-static struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
-static DEFINE_SPINLOCK(unix_table_lock);
 #ifdef CONFIG_UNIX_MULTICAST
+#include <linux/sort.h>
+
 static DEFINE_SPINLOCK(unix_multicast_lock);
 #endif
+static struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
+static DEFINE_SPINLOCK(unix_table_lock);
 static atomic_long_t unix_nr_socks;
 
 #define unix_sockets_unbound	(&unix_socket_table[UNIX_HASH_SIZE])
 
 #define UNIX_ABSTRACT(sk)	(unix_sk(sk)->addr->hash != UNIX_HASH_SIZE)
 
+#ifdef CONFIG_UNIX_MULTICAST
+/* Array of sockets used in multicast deliveries */
+struct sock_item {
+	/* constant fields */
+	struct sock *s;
+	unsigned int flags;
+
+	/* fields reinitialized at every send */
+	struct sk_buff *skb;
+	unsigned int to_deliver:1;
+};
+
+struct sock_set {
+	/* struct sock_set is used by one sender at a time */
+	struct semaphore sem;
+	struct hlist_node list;
+	struct rcu_head rcu;
+	int generation;
+
+	/* the sender should consider only sockets from items[offset] to
+	 * item[cnt-1] */
+	int cnt;
+	int offset;
+	/* Bitfield of (struct unix_mcast_group)->lock spinlocks to take in
+	 * order to guarantee causal order of delivery */
+	u8 hash;
+	/* ordered list of sockets without duplicates. Cell zero is reserved
+	 * for sending a message to the accepted socket (SOCK_SEQPACKET only).
+	 */
+	struct sock_item items[0];
+};
+
+static void up_sock_set(struct sock_set *set)
+{
+	if ((set->offset == 0) && set->items[0].s) {
+		sock_put(set->items[0].s);
+		set->items[0].s = NULL;
+		set->items[0].skb = NULL;
+	}
+	up(&set->sem);
+}
+
+static void kfree_sock_set(struct sock_set *set)
+{
+	int i;
+	for (i = set->offset ; i < set->cnt ; i++) {
+		if (set->items[i].s)
+			sock_put(set->items[i].s);
+	}
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
+#endif
+
 #ifdef CONFIG_SECURITY_NETWORK
 static void unix_get_secdata(struct scm_cookie *scm, struct sk_buff *skb)
 {
@@ -379,6 +445,7 @@ static void
 destroy_mcast_group(struct unix_mcast_group *group)
 {
 	struct unix_mcast *node;
+	struct sock_set *set;
 	struct hlist_node *pos;
 	struct hlist_node *pos_tmp;
 
@@ -392,6 +459,12 @@ destroy_mcast_group(struct unix_mcast_group *group)
 		sock_put(&node->member->sk);
 		kfree(node);
 	}
+	hlist_for_each_entry_safe(set, pos, pos_tmp,
+				  &group->mcast_members_lists,
+				  list) {
+		hlist_del_rcu(&set->list);
+		kfree_sock_set(set);
+	}
 	kfree(group);
 }
 #endif
@@ -851,6 +924,186 @@ fail:
 	return NULL;
 }
 
+#ifdef CONFIG_UNIX_MULTICAST
+static int unix_find_multicast_members(struct sock_set *set,
+				       int recipient_cnt,
+				       struct hlist_head *list)
+{
+	struct unix_mcast *node;
+	struct hlist_node *pos;
+
+	hlist_for_each_entry_rcu(node, pos, list,
+			     member_node) {
+		struct sock *s;
+
+		if (set->cnt + 1 > recipient_cnt)
+			return -ENOMEM;
+
+		s = &node->member->sk;
+		sock_hold(s);
+		set->items[set->cnt].s = s;
+		set->items[set->cnt].flags = node->flags;
+		set->cnt++;
+
+		set->hash |= 1 << ((((int)s) >> 6) & 0x07);
+	}
+
+	return 0;
+}
+
+void sock_set_reclaim(struct rcu_head *rp)
+{
+	struct sock_set *set = container_of(rp, struct sock_set, rcu);
+	kfree_sock_set(set);
+}
+
+static struct sock_set *unix_find_multicast_recipients(struct sock *sender,
+				struct unix_mcast_group *group,
+				int *err)
+{
+	struct sock_set *set = NULL; /* fake GCC */
+	struct sock_set *del_set;
+	struct hlist_node *pos;
+	int recipient_cnt;
+	int generation;
+	int i;
+
+	BUG_ON(sender == NULL);
+	BUG_ON(group == NULL);
+
+	/* Find an available set if any */
+	generation = atomic_read(&group->mcast_membership_generation);
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(set, pos, &group->mcast_members_lists,
+			     list) {
+		if (down_trylock(&set->sem)) {
+			/* the set is being used by someone else */
+			continue;
+		}
+		if (set->generation == generation) {
+			/* the set is still valid, use it */
+			break;
+		}
+		/* The set is outdated. It will be removed from the RCU list
+		 * soon but not in this lockless RCU read */
+		up(&set->sem);
+	}
+	rcu_read_unlock();
+	if (pos)
+		goto list_found;
+
+	/* We cannot allocate in the spin lock. First, count the recipients */
+try_again:
+	generation = atomic_read(&group->mcast_membership_generation);
+	recipient_cnt = atomic_read(&group->mcast_members_cnt);
+
+	/* Allocate for the set and hope the number of recipients does not
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
+	sema_init(&set->sem, 0);
+	set->cnt = 1;
+	set->offset = 1;
+	set->generation = generation;
+	set->hash = 0;
+
+	rcu_read_lock();
+	if (unix_find_multicast_members(set, recipient_cnt,
+			&group->mcast_members)) {
+		rcu_read_unlock();
+		kfree_sock_set(set);
+		goto try_again;
+	}
+	rcu_read_unlock();
+
+	/* Keep the array ordered to prevent deadlocks when locking the
+	 * receiving queues. The ordering is:
+	 * - First, the accepted socket (SOCK_SEQPACKET only)
+	 * - Then, the member sockets ordered by memory address
+	 * The accepted socket cannot be member of a multicast group.
+	 */
+	sort(set->items + 1, set->cnt - 1, sizeof(struct sock_item),
+	     sock_item_compare, NULL);
+	/* Avoid duplicates */
+	for (i = 2 ; i < set->cnt ; i++) {
+		if (set->items[i].s == set->items[i - 1].s) {
+			sock_put(set->items[i - 1].s);
+			set->items[i - 1].s = NULL;
+		}
+	}
+
+	if (generation != atomic_read(&group->mcast_membership_generation)) {
+		kfree_sock_set(set);
+		goto try_again;
+	}
+
+	/* Take the lock to insert the new list but take the opportunity to do
+	 * some garbage collection on outdated lists */
+	spin_lock(&unix_multicast_lock);
+	hlist_for_each_entry_rcu(del_set, pos, &group->mcast_members_lists,
+			     list) {
+		if (down_trylock(&del_set->sem)) {
+			/* the list is being used by someone else */
+			continue;
+		}
+		if (del_set->generation < generation) {
+			hlist_del_rcu(&del_set->list);
+			call_rcu(&del_set->rcu, sock_set_reclaim);
+		}
+		up(&del_set->sem);
+	}
+	hlist_add_head_rcu(&set->list,
+			   &group->mcast_members_lists);
+	spin_unlock(&unix_multicast_lock);
+
+list_found:
+	/* List found. Initialize the first item. */
+	if (sender->sk_type == SOCK_SEQPACKET
+	    && unix_peer(sender)
+	    && unix_sk(sender)->mcast_send_to_peer) {
+		set->offset = 0;
+		sock_hold(unix_peer(sender));
+		set->items[0].s = unix_peer(sender);
+		set->items[0].skb = NULL;
+		set->items[0].to_deliver = 1;
+		set->items[0].flags =
+			unix_sk(sender)->mcast_drop_when_peer_full
+			? UNIX_MREQ_DROP_WHEN_FULL : 0;
+	} else {
+		set->items[0].s = NULL;
+		set->items[0].skb = NULL;
+		set->items[0].to_deliver = 0;
+		set->offset = 1;
+	}
+
+	/* Initialize the other items. */
+	for (i = 1 ; i < set->cnt ; i++) {
+		set->items[i].skb = NULL;
+		if (set->items[i].s == NULL) {
+			set->items[i].to_deliver = 0;
+			continue;
+		}
+		if (set->items[i].flags & UNIX_MREQ_LOOPBACK
+		    || sender != set->items[i].s)
+			set->items[i].to_deliver = 1;
+		else
+			set->items[i].to_deliver = 0;
+	}
+
+	return set;
+}
+#endif
+
 
 static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
-- 
1.7.2.3
