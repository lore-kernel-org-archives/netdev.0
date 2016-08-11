From: Anoop Naravaram <anaravaram@google.com>
Subject: [PATCH 2/5] net: add bind/listen ranges to net cgroup
Date: Wed, 10 Aug 2016 17:53:15 -0700
Message-ID: <1470876798-4024-3-git-send-email-anaravaram@google.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Cc: edumazet@google.com, maheshb@google.com, weiwan@google.com,
	tom@herbertland.com, Anoop Naravaram <anaravaram@google.com>
To: corbet@lwn.net, tj@kernel.org, lizefan@huawei.com,
	hannes@cmpxchg.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-doc@vger.kernel.org, cgroups@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33779 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbcHKA4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 20:56:17 -0400
Received: by mail-pf0-f182.google.com with SMTP id y134so20967190pfg.0
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 17:56:17 -0700 (PDT)
In-Reply-To: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bind port ranges
----------------
This property controls which ports the processes in a cgroup are allowed
to bind to. If a process in a cgroup tries to bind a socket to a port
that is not within the range(s) permitted by the cgroup, it will receive an
EACCES error.

>From userspace, you can get or set the bind port ranges by accessing the
'net.bind_port_ranges' file. To set the ranges of a cgroup, write the
comma-separated ranges to the file, where each range could be either a
pair of ports separated by a hyphen (-), or just an individual port. For
example, say you want to allow all the processes in a cgroup to be allowed
to bind to ports 100 through 200 (inclusive), 300 through 320 (inclusive)
and 350. Then you can write the string "100-200,300-320,350" to the
'net.bind_port_ranges' file. When reading the file, any individual ports
will be read as a "start-end" range where the start and end are equal.
The example above would be read as "100-200,300-320,350-350".

The controller imposes the invariant that the ranges of any cgroup must
be a subset (or equal set) of the ranges of its parents (i.e., processes
in a cgroup cannot be allowed to bind to any port that is not allowed
by the parent cgroup). This constraint allows you to ensure that not
only do the processes in a cgroup follow the bind range, but so do the
processes in any of the cgroup's descendants. The way this is enforced
is because of two things: 1) when a cgroup is initialized, its ranges
are inherited from its parent, and 2) when attempting to set the ranges of
a cgroup, the kernel ensures that the condition is true for the current
cgroup and all its children, or otherwise fails to change the ranges
with error EINVAL.

listen port ranges
------------------
This property controls which ports the processes in a cgroup are allowed
to listen on. If a process in a cgroup tries to listen using a socket
bound to a port that is not within the range(s) permitted by the cgroup,
it will receive an EACCES error.

Configuring this property works the same way as with bind port ranges,
except using the file 'net.listen_port_ranges' instead of
'net.bind_port_ranges'. The range subset invariant is imposed
independently for bind and listen port ranges. For now the kernel does
not enforce that the listen range must be a subset of the bind range.

Tested: Used a python unittest to set the range and try
binding/listening to ports inside and outside the range, and ensure
that an error occurred only when it should. Also, ensures that an error
occurs when trying to violate the subset condition.

Signed-off-by: Anoop Naravaram <anaravaram@google.com>
---
 Documentation/cgroup-v1/net.txt |  46 ++++++
 include/net/net_cgroup.h        |  41 +++++
 net/core/net_cgroup.c           | 341 ++++++++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c              |   8 +
 net/ipv4/inet_connection_sock.c |   7 +
 net/ipv6/af_inet6.c             |   7 +
 6 files changed, 450 insertions(+)

diff --git a/Documentation/cgroup-v1/net.txt b/Documentation/cgroup-v1/net.txt
index 580c214..8c50c61 100644
--- a/Documentation/cgroup-v1/net.txt
+++ b/Documentation/cgroup-v1/net.txt
@@ -7,3 +7,49 @@ properties for each process group:
 * listen port ranges
 * dscp ranges
 * udp port usage and limit
+
+bind port ranges
+----------------
+This property controls which ports the processes in a cgroup are allowed
+to bind to. If a process in a cgroup tries to bind a socket to a port
+that is not within the range(s) permitted by the cgroup, it will receive an
+EACCES error.
+
+This property is exposed to userspace through the 'net.bind_port_ranges' file,
+as ranges of ports that the processes can bind to (as described in the HOW TO
+INTERACT WITH RANGES FILES section).
+
+listen port ranges
+------------------
+This property controls which ports the processes in a cgroup are allowed
+to listen on. If a process in a cgroup tries to listen using a socket
+bound to a port that is not within the range(s) permitted by the cgroup,
+it will receive an EACCES error.
+
+This property is exposed to userspace through the 'net.listen_port_ranges' file,
+as ranges of ports that the processes can listen on (as described in the HOW TO
+INTERACT WITH RANGES FILES section).
+
+HOW TO INTERACT WITH RANGES FILES
+---------------------------------
+Some cgroup properties can be expressed as ranges of allowed integers. From
+userspace, you can get or set them by accessing the cgroup file corresponding to
+the property you want to interact with. To set the ranges, write a list of
+comma-separated ranges to the file, where each range could be either a pair of
+integers separated by a hyphen (-), or just an individual integer. For example,
+say you want a cgroup to allow the integers 100 through 200 (inclusive), 300
+through 320 (inclusive) and 350. Then you can write the string
+"100-200,300-320,350" to the file. When reading the file, any individual
+integers will be read as a "start-end" range where the start and end are equal.
+The example above would be read as "100-200,300-320,350-350".
+
+The controller imposes the invariant that the ranges allowed by any cgroup must
+be a subset (or equal set) of the ranges allowed by its parent (i.e., a cgroup
+does not allow any integers not allowed by its parent cgroup). This constraint
+allows you to ensure that not only are the processes in any given cgroup
+contrained by its ranges, but so are the processes in any of the cgroup's
+descendants. The way this is enforced is by two things: 1) when a cgroup is
+initialized, its ranges are inherited from its parent, and 2) when attempting to
+set the ranges of a cgroup, the kernel ensures that the invariant is true for
+the current cgroup and all its children, or otherwise fails to change the ranges
+with error EINVAL.
diff --git a/include/net/net_cgroup.h b/include/net/net_cgroup.h
index 8e98803..6ee79d5 100644
--- a/include/net/net_cgroup.h
+++ b/include/net/net_cgroup.h
@@ -16,12 +16,53 @@
 #define _NET_CGROUP_H
 
 #include <linux/cgroup.h>
+#include <linux/types.h>
 
 #ifdef CONFIG_CGROUP_NET
+/* range type */
+enum {
+	NETCG_LISTEN_RANGES,
+	NETCG_BIND_RANGES,
+	NETCG_NUM_RANGE_TYPES
+};
+
+struct net_range {
+	u16 min_value;
+	u16 max_value;
+};
+
+struct net_ranges {
+	int			num_entries;
+	struct rcu_head		rcu;
+	struct net_range	range[0];
+};
+
+struct net_range_types {
+	struct net_ranges __rcu	*ranges;
+	u16			lower_limit;
+	u16			upper_limit;
+};
 
 struct net_cgroup {
 	struct cgroup_subsys_state	css;
+
+	/* these fields are required for bind/listen port ranges */
+	struct mutex			range_lock;
+	struct net_range_types		whitelists[NETCG_NUM_RANGE_TYPES];
 };
 
+bool net_cgroup_bind_allowed(u16 port);
+bool net_cgroup_listen_allowed(u16 port);
+
+#else /* !CONFIG_CGROUP_NET */
+static inline bool net_cgroup_bind_allowed(u16 port)
+{
+	return true;
+}
+static inline bool net_cgroup_listen_allowed(u16 port)
+{
+	return true;
+}
+
 #endif /* CONFIG_CGROUP_NET */
 #endif  /* _NET_CGROUP_H */
diff --git a/net/core/net_cgroup.c b/net/core/net_cgroup.c
index 3a46960..7e69ad5 100644
--- a/net/core/net_cgroup.c
+++ b/net/core/net_cgroup.c
@@ -12,8 +12,19 @@
  */
 
 #include <linux/slab.h>
+#include <linux/ctype.h>
 #include <net/net_cgroup.h>
 
+#define BYTES_PER_ENTRY		sizeof(struct net_range)
+#define MAX_WRITE_SIZE		4096
+
+#define MIN_PORT_VALUE		0
+#define MAX_PORT_VALUE		65535
+
+/* Deriving MAX_ENTRIES from MAX_WRITE_SIZE as a rough estimate */
+#define MAX_ENTRIES ((MAX_WRITE_SIZE - offsetof(struct net_ranges, range)) /   \
+		     BYTES_PER_ENTRY)
+
 static struct net_cgroup *css_to_net_cgroup(struct cgroup_subsys_state *css)
 {
 	return css ? container_of(css, struct net_cgroup, css) : NULL;
@@ -29,8 +40,78 @@ static struct net_cgroup *net_cgroup_to_parent(struct net_cgroup *netcg)
 	return css_to_net_cgroup(netcg->css.parent);
 }
 
+static struct net_ranges *alloc_net_ranges(int num_entries)
+{
+	struct net_ranges *ranges;
+
+	ranges = kmalloc(offsetof(struct net_ranges, range[num_entries]),
+			 GFP_KERNEL);
+	if (!ranges)
+		return NULL;
+
+	ranges->num_entries = num_entries;
+
+	return ranges;
+}
+
+static int alloc_init_net_ranges(struct net_range_types *r, int min_value,
+				 int max_value)
+{
+	struct net_ranges *ranges;
+
+	ranges = alloc_net_ranges(1);
+	if (!ranges)
+		return -ENOMEM;
+
+	ranges->range[0].min_value = min_value;
+	ranges->range[0].max_value = max_value;
+	r->lower_limit = min_value;
+	r->upper_limit = max_value;
+	rcu_assign_pointer(r->ranges, ranges);
+
+	return 0;
+}
+
+static int alloc_copy_net_ranges(struct net_range_types *r,
+				 int min_value,
+				 int max_value,
+				 struct net_range_types *parent_rt)
+{
+	struct net_ranges *ranges;
+	struct net_ranges *parent_ranges;
+	int i; /* loop counter */
+
+	parent_ranges = rcu_dereference(parent_rt->ranges);
+	ranges = alloc_net_ranges(parent_ranges->num_entries);
+	if (!ranges)
+		return -ENOMEM;
+	for (i = 0; i < parent_ranges->num_entries; i++) {
+		ranges->range[i].min_value = parent_ranges->range[i].min_value;
+		ranges->range[i].max_value = parent_ranges->range[i].max_value;
+	}
+
+	r->lower_limit = min_value;
+	r->upper_limit = max_value;
+	rcu_assign_pointer(r->ranges, ranges);
+
+	return 0;
+}
+
 static void free_net_cgroup(struct net_cgroup *netcg)
 {
+	int i;
+
+	mutex_lock(&netcg->range_lock);
+	for (i = 0; i < NETCG_NUM_RANGE_TYPES; i++) {
+		struct net_ranges *range =
+		    rcu_dereference_protected(netcg->whitelists[i].ranges,
+					      1);
+
+		if (range)
+			kfree_rcu(range, rcu);
+	}
+	mutex_unlock(&netcg->range_lock);
+
 	kfree(netcg);
 }
 
@@ -38,11 +119,43 @@ static struct cgroup_subsys_state *
 cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct net_cgroup *netcg;
+	struct net_cgroup *parent_netcg = css_to_net_cgroup(parent_css);
 
 	netcg = kzalloc(sizeof(*netcg), GFP_KERNEL);
 	if (!netcg)
 		return ERR_PTR(-ENOMEM);
 
+	mutex_init(&netcg->range_lock);
+
+	/* allocate the listen and bind range whitelists */
+	if (!parent_netcg) {
+		/* if root, then init ranges with full range */
+		if (alloc_init_net_ranges(
+				&netcg->whitelists[NETCG_BIND_RANGES],
+				MIN_PORT_VALUE, MAX_PORT_VALUE) ||
+		    alloc_init_net_ranges(
+				&netcg->whitelists[NETCG_LISTEN_RANGES],
+				MIN_PORT_VALUE, MAX_PORT_VALUE)) {
+			free_net_cgroup(netcg);
+			/* if any of these cause an error, return ENOMEM */
+			return ERR_PTR(-ENOMEM);
+		}
+	} else {
+		/* if not root, then, inherit ranges from parent */
+		if (alloc_copy_net_ranges(
+				&netcg->whitelists[NETCG_BIND_RANGES],
+				MIN_PORT_VALUE, MAX_PORT_VALUE,
+				&parent_netcg->whitelists[NETCG_BIND_RANGES]) ||
+		    alloc_copy_net_ranges(
+				&netcg->whitelists[NETCG_LISTEN_RANGES],
+				MIN_PORT_VALUE, MAX_PORT_VALUE,
+				&parent_netcg->whitelists[NETCG_LISTEN_RANGES])) {
+			free_net_cgroup(netcg);
+			/* if any of these cause an error, return ENOMEM */
+			return ERR_PTR(-ENOMEM);
+		}
+	}
+
 	return &netcg->css;
 }
 
@@ -51,7 +164,235 @@ static void cgrp_css_free(struct cgroup_subsys_state *css)
 	free_net_cgroup(css_to_net_cgroup(css));
 }
 
+static bool value_in_range(struct net_range_types *r, u16 val)
+{
+	int i;
+	struct net_ranges *ranges;
+
+	ranges = rcu_dereference(r->ranges);
+	for (i = 0; i < ranges->num_entries; i++) {
+		if (val >= ranges->range[i].min_value &&
+		    val <= ranges->range[i].max_value)
+			return true;
+	}
+
+	return false;
+}
+
+static bool net_cgroup_value_allowed(u16 value, int type)
+{
+	struct net_cgroup *netcg;
+	bool retval;
+
+	rcu_read_lock();
+	netcg = task_to_net_cgroup(current);
+	retval = value_in_range(&netcg->whitelists[type], value);
+	rcu_read_unlock();
+	return retval;
+}
+
+bool net_cgroup_bind_allowed(u16 port)
+{
+	return net_cgroup_value_allowed(port, NETCG_BIND_RANGES);
+}
+EXPORT_SYMBOL_GPL(net_cgroup_bind_allowed);
+
+bool net_cgroup_listen_allowed(u16 port)
+{
+	return net_cgroup_value_allowed(port, NETCG_LISTEN_RANGES);
+}
+EXPORT_SYMBOL_GPL(net_cgroup_listen_allowed);
+
+/* Returns true if the range r is a subset of at least one of the ranges in
+ * rs, and returns false otherwise.
+ */
+static bool range_in_ranges(struct net_range *r, struct net_ranges *rs)
+{
+	int ri;
+
+	for (ri = 0; ri < rs->num_entries; ri++)
+		if (r->min_value >= rs->range[ri].min_value &&
+		    r->max_value <= rs->range[ri].max_value)
+			return true;
+
+	return false;
+}
+
+/* Returns true if all the ranges in rs1 are subsets of at least one of the
+ * ranges in rs2, ans returns false otherwise.
+ */
+static bool ranges_in_ranges(struct net_ranges *rs1, struct net_ranges *rs2)
+{
+	int ri;
+
+	for (ri = 0; ri < rs1->num_entries; ri++)
+		if (!range_in_ranges(&rs1->range[ri], rs2))
+			return false;
+
+	return true;
+}
+
+static ssize_t update_ranges(struct net_cgroup *netcg, int type,
+			     const char *bp)
+{
+	unsigned int a, b;
+	int curr_index = 0;
+	ssize_t retval = 0;
+	struct net_ranges *ranges, *new, *old, *parent_ranges, *child_ranges;
+	struct cgroup_subsys_state *child_pos;
+	struct net_cgroup *child_netcg;
+
+	ranges = alloc_net_ranges(MAX_ENTRIES);
+	if (!ranges)
+		return -ENOMEM;
+
+	while (*bp != '\0' && *bp != '\n' && curr_index < MAX_ENTRIES) {
+		if (!isdigit(*bp)) {
+			retval = -EINVAL;
+			goto out;
+		}
+
+		a = simple_strtoul(bp, (char **)&bp, 10);
+		b = a;
+		if (*bp == '-') {
+			bp++;
+			if (!isdigit(*bp)) {
+				retval = -EINVAL;
+				goto out;
+			}
+			b = simple_strtoul(bp, (char **)&bp, 10);
+		}
+
+		if (!(a <= b)) {
+			retval = -EINVAL;
+			goto out;
+		}
+
+		if (a < netcg->whitelists[type].lower_limit ||
+		    b > netcg->whitelists[type].upper_limit) {
+			retval = -EINVAL;
+			goto out;
+		}
+
+		ranges->range[curr_index].min_value = a;
+		ranges->range[curr_index].max_value = b;
+
+		if (*bp == ',')
+			bp++;
+
+		curr_index++;
+	}
+
+	if (curr_index == MAX_ENTRIES) {
+		retval = -E2BIG;
+		goto out;
+	}
+
+	new = alloc_net_ranges(curr_index);
+	if (!new) {
+		retval = -ENOMEM;
+		goto out;
+	}
+
+	memcpy(new->range, ranges->range,
+	       sizeof(struct net_range) * curr_index);
+
+	/* make sure this cgroup is still a subset of its parent's */
+	parent_ranges = rcu_dereference(
+			net_cgroup_to_parent(netcg)->whitelists[type].ranges);
+	if (!ranges_in_ranges(new, parent_ranges)) {
+		retval = -EINVAL;
+		goto out;
+	}
+
+	/* make sure children's ranges are still subsets of this cgroup's */
+	css_for_each_child(child_pos, &netcg->css) {
+		child_netcg = css_to_net_cgroup(child_pos);
+		child_ranges = rcu_dereference(
+				child_netcg->whitelists[type].ranges);
+		if (!ranges_in_ranges(child_ranges, new)) {
+			retval = -EINVAL;
+			goto out;
+		}
+	}
+
+	mutex_lock(&netcg->range_lock);
+	old = rcu_dereference_protected(netcg->whitelists[type].ranges, 1);
+	rcu_assign_pointer(netcg->whitelists[type].ranges, new);
+	mutex_unlock(&netcg->range_lock);
+
+	kfree_rcu(old, rcu);
+out:
+	kfree(ranges);
+	return retval;
+}
+
+static ssize_t net_write_ranges(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off)
+{
+	struct net_cgroup *netcg = css_to_net_cgroup(of_css(of));
+	int type = of_cft(of)->private;
+
+	return update_ranges(netcg, type, buf) ?: nbytes;
+}
+
+static void net_seq_printf_list(struct seq_file *s, struct net_range_types *r)
+{
+	int i;
+	struct net_ranges *ranges;
+
+	ranges = rcu_dereference(r->ranges);
+
+	for (i = 0; i < ranges->num_entries; i++) {
+		if (i)
+			seq_puts(s, ",");
+		seq_printf(s, "%d-%d", ranges->range[i].min_value,
+			   ranges->range[i].max_value);
+	}
+	seq_puts(s, "\n");
+}
+
+static int net_read_ranges(struct seq_file *sf, void *v)
+{
+	struct net_cgroup *netcg = css_to_net_cgroup(seq_css(sf));
+	int type = seq_cft(sf)->private;
+
+	rcu_read_lock();
+	net_seq_printf_list(sf, &netcg->whitelists[type]);
+	rcu_read_unlock();
+
+	return 0;
+}
+
 static struct cftype ss_files[] = {
+	{
+		.name		= "listen_port_ranges",
+		.flags		= CFTYPE_ONLY_ON_ROOT,
+		.seq_show	= net_read_ranges,
+		.private	= NETCG_LISTEN_RANGES,
+	},
+	{
+		.name		= "listen_port_ranges",
+		.flags		= CFTYPE_NOT_ON_ROOT,
+		.seq_show	= net_read_ranges,
+		.write		= net_write_ranges,
+		.private	= NETCG_LISTEN_RANGES,
+		.max_write_len	= MAX_WRITE_SIZE,
+	},
+	{
+		.name		= "bind_port_ranges",
+		.flags		= CFTYPE_ONLY_ON_ROOT,
+		.seq_show	= net_read_ranges,
+		.private	= NETCG_BIND_RANGES,
+	},
+	{
+		.name		= "bind_port_ranges",
+		.flags		= CFTYPE_NOT_ON_ROOT,
+		.seq_show	= net_read_ranges,
+		.write		= net_write_ranges,
+		.private	= NETCG_BIND_RANGES,
+		.max_write_len	= MAX_WRITE_SIZE,
+	},
 	{ }	/* terminate */
 };
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 55513e6..c3160ad 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -120,6 +120,7 @@
 #include <linux/mroute.h>
 #endif
 #include <net/l3mdev.h>
+#include <net/net_cgroup.h>
 
 
 /* The inetsw table contains everything that inet_create needs to
@@ -497,6 +498,13 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		inet->inet_saddr = 0;  /* Use device */
 
 	/* Make sure we are allowed to bind here. */
+	if (!net_cgroup_bind_allowed(snum)) {
+		inet->inet_saddr = 0;
+		inet->inet_rcv_saddr = 0;
+		err = -EACCES;
+		goto out_release_sock;
+	}
+
 	if ((snum || !inet->bind_address_no_port) &&
 	    sk->sk_prot->get_port(sk, snum)) {
 		inet->inet_saddr = inet->inet_rcv_saddr = 0;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 61a9dee..4fc3bd1 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -25,6 +25,7 @@
 #include <net/xfrm.h>
 #include <net/tcp.h>
 #include <net/sock_reuseport.h>
+#include <net/net_cgroup.h>
 
 #ifdef INET_CSK_DEBUG
 const char inet_csk_timer_bug_msg[] = "inet_csk BUG: unknown timer value\n";
@@ -743,6 +744,11 @@ int inet_csk_listen_start(struct sock *sk, int backlog)
 	sk->sk_ack_backlog = 0;
 	inet_csk_delack_init(sk);
 
+	if (!net_cgroup_listen_allowed(inet->inet_num)) {
+		err = -EACCES;
+		goto out;
+	}
+
 	/* There is race window here: we announce ourselves listening,
 	 * but this transition is still not validated by get_port().
 	 * It is OK, because this socket enters to hash table only
@@ -759,6 +765,7 @@ int inet_csk_listen_start(struct sock *sk, int backlog)
 			return 0;
 	}
 
+out:
 	sk->sk_state = TCP_CLOSE;
 	return err;
 }
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 2076c21..9328240 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -65,6 +65,7 @@
 #include <linux/mroute6.h>
 
 #include "ip6_offload.h"
+#include <net/net_cgroup.h>
 
 MODULE_AUTHOR("Cast of dozens");
 MODULE_DESCRIPTION("IPv6 protocol stack for Linux");
@@ -379,6 +380,12 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		np->saddr = addr->sin6_addr;
 
 	/* Make sure we are allowed to bind here. */
+	if (!net_cgroup_bind_allowed(snum)) {
+		inet_reset_saddr(sk);
+		err = -EACCES;
+		goto out;
+	}
+
 	if ((snum || !inet->bind_address_no_port) &&
 	    sk->sk_prot->get_port(sk, snum)) {
 		inet_reset_saddr(sk);
-- 
2.8.0.rc3.226.g39d4020
