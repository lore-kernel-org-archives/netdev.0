From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK] introduce netlink bucket
Date: Wed, 3 Nov 2004 15:48:33 -0800
Message-ID: <20041103154833.164e33f5.davem@davemloft.net>
References: <4187FF18.5050608@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <4187FF18.5050608@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 02 Nov 2004 22:41:44 +0100
Pablo Neira <pablo@eurodev.net> wrote:

> This patch introduces the netlink bucket struct, it joins three arrays 
> into an array of netlink bucket.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@eurodev.net>

Here is the work Herbert and I were talking about.  It kind
of makes your patch taken care of already :-)

Herbert, this is what I actually checked into my tree.  If
you could cook up a 2.4.x version, that would be really great.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/03 15:34:53-08:00 herbert@gondor.apana.org.au 
#   [NETLINK]: Hash sockets by pid if not multicast.
#   
#   Collaborative work between David S. Miller and
#   Herbert Xu.
#   
#   Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/netlink/af_netlink.c
#   2004/11/03 15:33:45-08:00 herbert@gondor.apana.org.au +374 -109
#   [NETLINK]: Hash sockets by pid if not multicast.
# 
diff -Nru a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	2004-11-03 15:35:38 -08:00
+++ b/net/netlink/af_netlink.c	2004-11-03 15:35:38 -08:00
@@ -44,6 +44,12 @@
 #include <linux/smp_lock.h>
 #include <linux/notifier.h>
 #include <linux/security.h>
+#include <linux/jhash.h>
+#include <linux/jiffies.h>
+#include <linux/random.h>
+#include <linux/bitops.h>
+#include <linux/mm.h>
+#include <linux/types.h>
 #include <net/sock.h>
 #include <net/scm.h>
 
@@ -56,9 +62,9 @@
 struct netlink_opt
 {
 	u32			pid;
-	unsigned		groups;
+	unsigned int		groups;
 	u32			dst_pid;
-	unsigned		dst_groups;
+	unsigned int		dst_groups;
 	unsigned long		state;
 	int			(*handler)(int unit, struct sk_buff *skb);
 	wait_queue_head_t	wait;
@@ -69,9 +75,28 @@
 
 #define nlk_sk(__sk) ((struct netlink_opt *)(__sk)->sk_protinfo)
 
-static struct hlist_head nl_table[MAX_LINKS];
+struct nl_pid_hash {
+	struct hlist_head *table;
+	unsigned long rehash_time;
+
+	unsigned int mask;
+	unsigned int shift;
+
+	unsigned int entries;
+	unsigned int max_shift;
+
+	u32 rnd;
+};
+
+struct netlink_table {
+	struct nl_pid_hash hash;
+	struct hlist_head mc_list;
+};
+
+static struct netlink_table *nl_table;
+
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
-static unsigned nl_nonroot[MAX_LINKS];
+static unsigned int nl_nonroot[MAX_LINKS];
 
 #ifdef NL_EMULATE_DEV
 static struct socket *netlink_kernel[MAX_LINKS];
@@ -85,6 +110,11 @@
 
 static struct notifier_block *netlink_chain;
 
+static struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid)
+{
+	return &hash->table[jhash_1word(pid, hash->rnd) & hash->mask];
+}
+
 static void netlink_sock_destruct(struct sock *sk)
 {
 	skb_queue_purge(&sk->sk_receive_queue);
@@ -153,11 +183,14 @@
 
 static __inline__ struct sock *netlink_lookup(int protocol, u32 pid)
 {
+	struct nl_pid_hash *hash = &nl_table[protocol].hash;
+	struct hlist_head *head;
 	struct sock *sk;
 	struct hlist_node *node;
 
 	read_lock(&nl_table_lock);
-	sk_for_each(sk, node, &nl_table[protocol]) {
+	head = nl_pid_hashfn(hash, pid);
+	sk_for_each(sk, node, head) {
 		if (nlk_sk(sk)->pid == pid) {
 			sock_hold(sk);
 			goto found;
@@ -169,27 +202,118 @@
 	return sk;
 }
 
+static inline struct hlist_head *nl_pid_hash_alloc(size_t size)
+{
+	if (size <= PAGE_SIZE)
+		return kmalloc(size, GFP_ATOMIC);
+	else
+		return (struct hlist_head *)
+			__get_free_pages(GFP_ATOMIC, get_order(size));
+}
+
+static inline void nl_pid_hash_free(struct hlist_head *table, size_t size)
+{
+	if (size <= PAGE_SIZE)
+		kfree(table);
+	else
+		free_pages((unsigned long)table, get_order(size));
+}
+
+static int nl_pid_hash_rehash(struct nl_pid_hash *hash, int grow)
+{
+	unsigned int omask, mask, shift;
+	size_t osize, size;
+	struct hlist_head *otable, *table;
+	int i;
+
+	omask = mask = hash->mask;
+	osize = size = (mask + 1) * sizeof(*table);
+	shift = hash->shift;
+
+	if (grow) {
+		if (++shift > hash->max_shift)
+			return 0;
+		mask = mask * 2 + 1;
+		size *= 2;
+	}
+
+	table = nl_pid_hash_alloc(size);
+	if (!table)
+		return 0;
+
+	memset(table, 0, size);
+	otable = hash->table;
+	hash->table = table;
+	hash->mask = mask;
+	hash->shift = shift;
+	get_random_bytes(&hash->rnd, sizeof(hash->rnd));
+
+	for (i = 0; i <= omask; i++) {
+		struct sock *sk;
+		struct hlist_node *node, *tmp;
+
+		sk_for_each_safe(sk, node, tmp, &otable[i])
+			__sk_add_node(sk, nl_pid_hashfn(hash, nlk_sk(sk)->pid));
+	}
+
+	nl_pid_hash_free(otable, osize);
+	hash->rehash_time = jiffies + 10 * 60 * HZ;
+	return 1;
+}
+
+static inline int nl_pid_hash_dilute(struct nl_pid_hash *hash, int len)
+{
+	int avg = hash->entries >> hash->shift;
+
+	if (unlikely(avg > 1) && nl_pid_hash_rehash(hash, 1))
+		return 1;
+
+	if (unlikely(len > avg) && time_after(jiffies, hash->rehash_time)) {
+		nl_pid_hash_rehash(hash, 0);
+		return 1;
+	}
+
+	return 0;
+}
+
 static struct proto_ops netlink_ops;
 
 static int netlink_insert(struct sock *sk, u32 pid)
 {
+	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
+	struct hlist_head *head;
 	int err = -EADDRINUSE;
 	struct sock *osk;
 	struct hlist_node *node;
+	int len;
 
 	netlink_table_grab();
-	sk_for_each(osk, node, &nl_table[sk->sk_protocol]) {
+	head = nl_pid_hashfn(hash, pid);
+	len = 0;
+	sk_for_each(osk, node, head) {
 		if (nlk_sk(osk)->pid == pid)
 			break;
+		len++;
 	}
-	if (!node) {
-		err = -EBUSY;
-		if (nlk_sk(sk)->pid == 0) {
-			nlk_sk(sk)->pid = pid;
-			sk_add_node(sk, &nl_table[sk->sk_protocol]);
-			err = 0;
-		}
-	}
+	if (node)
+		goto err;
+
+	err = -EBUSY;
+	if (nlk_sk(sk)->pid)
+		goto err;
+
+	err = -ENOMEM;
+	if (BITS_PER_LONG > 32 && unlikely(hash->entries >= UINT_MAX))
+		goto err;
+
+	if (len && nl_pid_hash_dilute(hash, len))
+		head = nl_pid_hashfn(hash, pid);
+	hash->entries++;
+	nlk_sk(sk)->pid = pid;
+	sk_add_node(sk, head);
+	err = 0;
+
+err:
 	netlink_table_ungrab();
 	return err;
 }
@@ -197,7 +321,10 @@
 static void netlink_remove(struct sock *sk)
 {
 	netlink_table_grab();
+	nl_table[sk->sk_protocol].hash.entries--;
 	sk_del_node_init(sk);
+	if (nlk_sk(sk)->groups)
+		__sk_del_bind_node(sk);
 	netlink_table_ungrab();
 }
 
@@ -282,19 +409,25 @@
 static int netlink_autobind(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
+	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
+	struct hlist_head *head;
 	struct sock *osk;
 	struct hlist_node *node;
 	s32 pid = current->pid;
 	int err;
+	static s32 rover = -4097;
 
 retry:
+	cond_resched();
 	netlink_table_grab();
-	sk_for_each(osk, node, &nl_table[sk->sk_protocol]) {
+	head = nl_pid_hashfn(hash, pid);
+	sk_for_each(osk, node, head) {
 		if (nlk_sk(osk)->pid == pid) {
 			/* Bind collision, search negative pid values. */
 			if (pid > 0)
-				pid = -4096;
-			pid--;
+				pid = rover;
+			else if (--pid > 0)
+				pid = -4097;
 			netlink_table_ungrab();
 			goto retry;
 		}
@@ -308,7 +441,7 @@
 	return 0;
 }
 
-static inline int netlink_capable(struct socket *sock, unsigned flag) 
+static inline int netlink_capable(struct socket *sock, unsigned int flag) 
 { 
 	return (nl_nonroot[sock->sk->sk_protocol] & flag) ||
 	       capable(CAP_NET_ADMIN);
@@ -331,21 +464,19 @@
 	if (nlk->pid) {
 		if (nladdr->nl_pid != nlk->pid)
 			return -EINVAL;
-		nlk->groups = nladdr->nl_groups;
-		return 0;
+	} else {
+		err = nladdr->nl_pid ?
+			netlink_insert(sk, nladdr->nl_pid) :
+			netlink_autobind(sock);
+		if (err)
+			return err;
 	}
 
-	if (nladdr->nl_pid == 0) {
-		err = netlink_autobind(sock);
-		if (err == 0)
-			nlk->groups = nladdr->nl_groups;
-		return err;
-	}
+	nlk->groups = nladdr->nl_groups;
+	if (nladdr->nl_groups)
+		sk_add_bind_node(sk, &nl_table[sk->sk_protocol].mc_list);
 
-	err = netlink_insert(sk, nladdr->nl_pid);
-	if (err == 0)
-		nlk->groups = nladdr->nl_groups;
-	return err;
+	return 0;
 }
 
 static int netlink_connect(struct socket *sock, struct sockaddr *addr,
@@ -590,16 +721,76 @@
 	return -1;
 }
 
+struct netlink_broadcast_data {
+	struct sock *exclude_sk;
+	u32 pid;
+	u32 group;
+	int failure;
+	int congested;
+	int delivered;
+	int allocation;
+	struct sk_buff *skb, *skb2;
+};
+
+static inline int do_one_broadcast(struct sock *sk,
+				   struct netlink_broadcast_data *p)
+{
+	struct netlink_opt *nlk = nlk_sk(sk);
+	int val;
+
+	if (p->exclude_sk == sk)
+		goto out;
+
+	if (nlk->pid == p->pid || !(nlk->groups & p->group))
+		goto out;
+
+	if (p->failure) {
+		netlink_overrun(sk);
+		goto out;
+	}
+
+	sock_hold(sk);
+	if (p->skb2 == NULL) {
+		if (atomic_read(&p->skb->users) != 1) {
+			p->skb2 = skb_clone(p->skb, p->allocation);
+		} else {
+			p->skb2 = p->skb;
+			atomic_inc(&p->skb->users);
+		}
+	}
+	if (p->skb2 == NULL) {
+		netlink_overrun(sk);
+		/* Clone failed. Notify ALL listeners. */
+		p->failure = 1;
+	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
+		netlink_overrun(sk);
+	} else {
+		p->congested |= val;
+		p->delivered = 1;
+		p->skb2 = NULL;
+	}
+	sock_put(sk);
+
+out:
+	return 0;
+}
+
 int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 		      u32 group, int allocation)
 {
-	struct sock *sk;
+	struct netlink_broadcast_data info;
 	struct hlist_node *node;
-	struct sk_buff *skb2 = NULL;
-	int protocol = ssk->sk_protocol;
-	int failure = 0, delivered = 0;
-	int congested = 0;
-	int val;
+	struct sock *sk;
+
+	info.exclude_sk = ssk;
+	info.pid = pid;
+	info.group = group;
+	info.failure = 0;
+	info.congested = 0;
+	info.delivered = 0;
+	info.allocation = allocation;
+	info.skb = skb;
+	info.skb2 = NULL;
 
 	netlink_trim(skb, allocation);
 
@@ -607,77 +798,65 @@
 
 	netlink_lock_table();
 
-	sk_for_each(sk, node, &nl_table[protocol]) {
-		struct netlink_opt *nlk = nlk_sk(sk);
-
-		if (ssk == sk)
-			continue;
-
-		if (nlk->pid == pid || !(nlk->groups & group))
-			continue;
-
-		if (failure) {
-			netlink_overrun(sk);
-			continue;
-		}
-
-		sock_hold(sk);
-		if (skb2 == NULL) {
-			if (atomic_read(&skb->users) != 1) {
-				skb2 = skb_clone(skb, allocation);
-			} else {
-				skb2 = skb;
-				atomic_inc(&skb->users);
-			}
-		}
-		if (skb2 == NULL) {
-			netlink_overrun(sk);
-			/* Clone failed. Notify ALL listeners. */
-			failure = 1;
-		} else if ((val = netlink_broadcast_deliver(sk, skb2)) < 0) {
-			netlink_overrun(sk);
-		} else {
-			congested |= val;
-			delivered = 1;
-			skb2 = NULL;
-		}
-		sock_put(sk);
-	}
+	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
+		do_one_broadcast(sk, &info);
 
 	netlink_unlock_table();
 
-	if (skb2)
-		kfree_skb(skb2);
+	if (info.skb2)
+		kfree_skb(info.skb2);
 	kfree_skb(skb);
 
-	if (delivered) {
-		if (congested && (allocation & __GFP_WAIT))
+	if (info.delivered) {
+		if (info.congested && (allocation & __GFP_WAIT))
 			yield();
 		return 0;
 	}
-	if (failure)
+	if (info.failure)
 		return -ENOBUFS;
 	return -ESRCH;
 }
 
+struct netlink_set_err_data {
+	struct sock *exclude_sk;
+	u32 pid;
+	u32 group;
+	int code;
+};
+
+static inline int do_one_set_err(struct sock *sk,
+				 struct netlink_set_err_data *p)
+{
+	struct netlink_opt *nlk = nlk_sk(sk);
+
+	if (sk == p->exclude_sk)
+		goto out;
+
+	if (nlk->pid == p->pid || !(nlk->groups & p->group))
+		goto out;
+
+	sk->sk_err = p->code;
+	sk->sk_error_report(sk);
+out:
+	return 0;
+}
+
 void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 {
-	struct sock *sk;
+	struct netlink_set_err_data info;
 	struct hlist_node *node;
-	int protocol = ssk->sk_protocol;
+	struct sock *sk;
+
+	info.exclude_sk = ssk;
+	info.pid = pid;
+	info.group = group;
+	info.code = code;
 
 	read_lock(&nl_table_lock);
-	sk_for_each(sk, node, &nl_table[protocol]) {
-		struct netlink_opt *nlk = nlk_sk(sk);
-		if (ssk == sk)
-			continue;
 
-		if (nlk->pid == pid || !(nlk->groups & group))
-			continue;
+	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
+		do_one_set_err(sk, &info);
 
-		sk->sk_err = code;
-		sk->sk_error_report(sk);
-	}
 	read_unlock(&nl_table_lock);
 }
 
@@ -853,6 +1032,9 @@
 	struct socket *sock;
 	struct sock *sk;
 
+	if (!nl_table)
+		return NULL;
+
 	if (unit<0 || unit>=MAX_LINKS)
 		return NULL;
 
@@ -875,9 +1057,9 @@
 	return sk;
 }
 
-void netlink_set_nonroot(int protocol, unsigned flags)
+void netlink_set_nonroot(int protocol, unsigned int flags)
 { 
-	if ((unsigned)protocol < MAX_LINKS) 
+	if ((unsigned int)protocol < MAX_LINKS) 
 		nl_nonroot[protocol] = flags;
 } 
 
@@ -1070,20 +1252,31 @@
 #endif
 
 #ifdef CONFIG_PROC_FS
+struct nl_seq_iter {
+	int link;
+	int hash_idx;
+};
+
 static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 {
-	long i;
+	struct nl_seq_iter *iter = seq->private;
+	int i, j;
 	struct sock *s;
 	struct hlist_node *node;
 	loff_t off = 0;
 
 	for (i=0; i<MAX_LINKS; i++) {
-		sk_for_each(s, node, &nl_table[i]) {
-			if (off == pos) {
-				seq->private = (void *) i;
-				return s;
+		struct nl_pid_hash *hash = &nl_table[i].hash;
+
+		for (j = 0; j <= hash->mask; j++) {
+			sk_for_each(s, node, &hash->table[j]) {
+				if (off == pos) {
+					iter->link = i;
+					iter->hash_idx = j;
+					return s;
+				}
+				++off;
 			}
-			++off;
 		}
 	}
 	return NULL;
@@ -1098,6 +1291,8 @@
 static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct sock *s;
+	struct nl_seq_iter *iter;
+	int i, j;
 
 	++*pos;
 
@@ -1105,18 +1300,29 @@
 		return netlink_seq_socket_idx(seq, 0);
 		
 	s = sk_next(v);
-	if (!s) {
-		long i = (long)seq->private;
+	if (s)
+		return s;
+
+	iter = seq->private;
+	i = iter->link;
+	j = iter->hash_idx + 1;
 
-		while (++i < MAX_LINKS) {
-			s = sk_head(&nl_table[i]);
+	do {
+		struct nl_pid_hash *hash = &nl_table[i].hash;
+
+		for (; j <= hash->mask; j++) {
+			s = sk_head(&hash->table[j]);
 			if (s) {
-				seq->private = (void *) i;
-				break;
+				iter->link = i;
+				iter->hash_idx = j;
+				return s;
 			}
 		}
-	}
-	return s;
+
+		j = 0;
+	} while (++i < MAX_LINKS);
+
+	return NULL;
 }
 
 static void netlink_seq_stop(struct seq_file *seq, void *v)
@@ -1160,7 +1366,24 @@
 
 static int netlink_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &netlink_seq_ops);
+	struct seq_file *seq;
+	struct nl_seq_iter *iter;
+	int err;
+
+	iter = kmalloc(sizeof(*iter), GFP_KERNEL);
+	if (!iter)
+		return -ENOMEM;
+
+	err = seq_open(file, &netlink_seq_ops);
+	if (err) {
+		kfree(iter);
+		return err;
+	}
+
+	memset(iter, 0, sizeof(*iter));
+	seq = file->private_data;
+	seq->private = iter;
+	return 0;
 }
 
 static struct file_operations netlink_seq_fops = {
@@ -1168,7 +1391,7 @@
 	.open		= netlink_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release,
+	.release	= seq_release_private,
 };
 
 #endif
@@ -1210,14 +1433,54 @@
 	.owner	= THIS_MODULE,	/* for consistency 8) */
 };
 
+extern void netlink_skb_parms_too_large(void);
+
 static int __init netlink_proto_init(void)
 {
 	struct sk_buff *dummy_skb;
+	int i;
+	unsigned long max;
+	unsigned int order;
+
+	if (sizeof(struct netlink_skb_parms) > sizeof(dummy_skb->cb))
+		netlink_skb_parms_too_large();
+
+	nl_table = kmalloc(sizeof(*nl_table) * MAX_LINKS, GFP_KERNEL);
+	if (!nl_table) {
+enomem:
+		printk(KERN_CRIT "netlink_init: Cannot allocate nl_table\n");
+		return -ENOMEM;
+	}
+
+	memset(nl_table, 0, sizeof(*nl_table) * MAX_LINKS);
 
-	if (sizeof(struct netlink_skb_parms) > sizeof(dummy_skb->cb)) {
-		printk(KERN_CRIT "netlink_init: panic\n");
-		return -1;
+	if (num_physpages >= (128 * 1024))
+		max = num_physpages >> (21 - PAGE_SHIFT);
+	else
+		max = num_physpages >> (23 - PAGE_SHIFT);
+
+	order = get_bitmask_order(max) - 1 + PAGE_SHIFT;
+	max = (1UL << order) / sizeof(struct hlist_head);
+	order = get_bitmask_order(max > UINT_MAX ? UINT_MAX : max) - 1;
+
+	for (i = 0; i < MAX_LINKS; i++) {
+		struct nl_pid_hash *hash = &nl_table[i].hash;
+
+		hash->table = nl_pid_hash_alloc(1 * sizeof(*hash->table));
+		if (!hash->table) {
+			while (i-- > 0)
+				nl_pid_hash_free(nl_table[i].hash.table,
+						 1 * sizeof(*hash->table));
+			kfree(nl_table);
+			goto enomem;
+		}
+		memset(hash->table, 0, 1 * sizeof(*hash->table));
+		hash->max_shift = order;
+		hash->shift = 0;
+		hash->mask = 0;
+		hash->rehash_time = jiffies;
 	}
+
 	sock_register(&netlink_family_ops);
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create("netlink", 0, &netlink_seq_fops);
@@ -1231,6 +1494,8 @@
 {
        sock_unregister(PF_NETLINK);
        proc_net_remove("netlink");
+       kfree(nl_table);
+       nl_table = NULL;
 }
 
 core_initcall(netlink_proto_init);
