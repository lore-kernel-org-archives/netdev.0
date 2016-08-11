From: Anoop Naravaram <anaravaram-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/5] net: add udp limit to net cgroup
Date: Wed, 10 Aug 2016 17:53:16 -0700
Message-ID: <1470876798-4024-4-git-send-email-anaravaram@google.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Cc: edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, weiwan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, Anoop Naravaram <anaravaram-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: corbet-T1hC0tSOHrs@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org,
	jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470876798-4024-1-git-send-email-anaravaram-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

udp port limit
--------------
This property controls the limit of udp ports that can be used by the
processes in a cgroup. The controller manages udp statistics (usage,
limit, etc) for each cgroup. Every cgroup also keeps track of the udp
ports acquired by its descendants. If a process tries to acquire a port
when its cgroup has already reached its limit, it will fail with error
EACCES. It will also fail if one of the cgroup's ancestors has reached its
limit. There are 5 files exposed to userspace to configure this property:

* 'net.udp_usage': Reading this file gives the number of udp ports used by
processes in this cgroup and all its descendants.
* 'net.udp_limit': Writing this file sets the total number of udp ports
that can be used by processes in this cgroup and all
its descendants. This file can also be read.
* 'net.udp_maxusage': Reading this file gives the highest value of
net.udp_usage that has been seen for this cgroup.
* 'net.udp_failcnt': Reading this file gives the number of times a
process in this cgroup or one of its descendants has attempted to acquire
a udp port but failed because the limit of this cgroup was reached.
* 'net.udp_underflowcnt': Reading this file gives the number of times a
process in this cgroup or one of its descendants released a udp port when
the usage value of this cgroup was 0.

When a new cgroup is created, its udp limit is copied from its parent.

Tested: Set the udp limit, then used python to use several udp ports,
ensuring that it is successful up until the limit, after which there
should be an error. Also tried different limits at different levels of the
hierarchy.

Signed-off-by: Anoop Naravaram <anaravaram-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 Documentation/cgroup-v1/net.txt |  26 ++++
 include/net/net_cgroup.h        |  29 +++++
 net/core/net_cgroup.c           | 273 ++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udp.c                  |   8 ++
 4 files changed, 336 insertions(+)

diff --git a/Documentation/cgroup-v1/net.txt b/Documentation/cgroup-v1/net.txt
index 8c50c61..a14fd1c 100644
--- a/Documentation/cgroup-v1/net.txt
+++ b/Documentation/cgroup-v1/net.txt
@@ -30,6 +30,32 @@ This property is exposed to userspace through the 'net.listen_port_ranges' file,
 as ranges of ports that the processes can listen on (as described in the HOW TO
 INTERACT WITH RANGES FILES section).
 
+udp port usage and limit
+------------------------
+This property controls the limit of udp ports that can be used by the
+processes in a cgroup. The controller manages udp statistics (usage, limit, etc)
+for each cgroup. Every cgroup also keeps track of the udp ports acquired by its
+descendants. If a process tries to acquire a port when its cgroup has
+already reached its limit, it will fail with error EACCES. It will also fail if
+one of the cgroup's ancestors has reached its limit. There are 5 files
+exposed to userspace to configure this property:
+
+* 'net.udp_usage': Reading this file gives the number of udp ports used by
+processes in this cgroup and all its descendants.
+* 'net.udp_limit': Writing this file sets the total number of udp ports
+that can be used by processes in this cgroup and all
+its descendants. This file can also be read.
+* 'net.udp_maxusage': Reading this file gives the highest value of
+net.udp_usage that has been seen for this cgroup.
+* 'net.udp_failcnt': Reading this file gives the number of times a
+process in this cgroup or one of its descendants has attempted to acquire a
+udp port but failed because the limit of this cgroup was reached.
+* 'net.udp_underflowcnt': Reading this file gives the number of times a
+process in this cgroup or one of its descendants released a udp port when the
+usage value of this cgroup was 0.
+
+When a new cgroup is created, its udp limit is copied from its parent.
+
 HOW TO INTERACT WITH RANGES FILES
 ---------------------------------
 Some cgroup properties can be expressed as ranges of allowed integers. From
diff --git a/include/net/net_cgroup.h b/include/net/net_cgroup.h
index 6ee79d5..25a9def 100644
--- a/include/net/net_cgroup.h
+++ b/include/net/net_cgroup.h
@@ -26,6 +26,16 @@ enum {
 	NETCG_NUM_RANGE_TYPES
 };
 
+/* udp statistic type */
+enum {
+	NETCG_LIMIT_UDP,
+	NETCG_USAGE_UDP,
+	NETCG_MAXUSAGE_UDP,
+	NETCG_FAILCNT_UDP,
+	NETCG_UNDERFLOWCNT_UDP,
+	NETCG_NUM_UDP_STATS
+};
+
 struct net_range {
 	u16 min_value;
 	u16 max_value;
@@ -43,9 +53,19 @@ struct net_range_types {
 	u16			upper_limit;
 };
 
+struct cgroup_udp_stats {
+	/* Use atomics to protect against multiple writers */
+	atomic64_t	udp_limitandusage; /* 32MSB => limit, 32LSB => usage */
+	atomic_t	udp_maxusage;
+	atomic_t	udp_failcnt;
+	atomic_t	udp_underflowcnt;
+};
+
 struct net_cgroup {
 	struct cgroup_subsys_state	css;
 
+	struct cgroup_udp_stats		udp_stats;
+
 	/* these fields are required for bind/listen port ranges */
 	struct mutex			range_lock;
 	struct net_range_types		whitelists[NETCG_NUM_RANGE_TYPES];
@@ -53,6 +73,8 @@ struct net_cgroup {
 
 bool net_cgroup_bind_allowed(u16 port);
 bool net_cgroup_listen_allowed(u16 port);
+bool net_cgroup_acquire_udp_port(void);
+void net_cgroup_release_udp_port(void);
 
 #else /* !CONFIG_CGROUP_NET */
 static inline bool net_cgroup_bind_allowed(u16 port)
@@ -63,6 +85,13 @@ static inline bool net_cgroup_listen_allowed(u16 port)
 {
 	return true;
 }
+static inline bool net_cgroup_acquire_udp_port(void)
+{
+	return true;
+}
+static inline void net_cgroup_release_udp_port(void)
+{
+}
 
 #endif /* CONFIG_CGROUP_NET */
 #endif  /* _NET_CGROUP_H */
diff --git a/net/core/net_cgroup.c b/net/core/net_cgroup.c
index 7e69ad5..2f58e13 100644
--- a/net/core/net_cgroup.c
+++ b/net/core/net_cgroup.c
@@ -25,6 +25,31 @@
 #define MAX_ENTRIES ((MAX_WRITE_SIZE - offsetof(struct net_ranges, range)) /   \
 		     BYTES_PER_ENTRY)
 
+#define DEFAULT_UDP_LIMIT	-1
+#define UDP_FBITS		32
+#define UDP_FMASK		(((u64)1 << UDP_FBITS) - 1)
+
+/* Upper 32 bits are 'limit' and lower 32 bits are 'usage' */
+static s32 get_udp_limit(u64 limitandusage)
+{
+	return (s32)(limitandusage >> UDP_FBITS);
+}
+
+static s32 get_udp_usage(u64 limitandusage)
+{
+	return (s32)(limitandusage & UDP_FMASK);
+}
+
+static u64 set_udp_usage(u64 limitandusage, s32 usage)
+{
+	return (u64)((limitandusage & ~UDP_FMASK) | usage);
+}
+
+static u64 set_udp_limit_usage(s32 limit, s32 usage)
+{
+	return (u64)(((u64)limit << UDP_FBITS) | usage);
+}
+
 static struct net_cgroup *css_to_net_cgroup(struct cgroup_subsys_state *css)
 {
 	return css ? container_of(css, struct net_cgroup, css) : NULL;
@@ -120,6 +145,7 @@ cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct net_cgroup *netcg;
 	struct net_cgroup *parent_netcg = css_to_net_cgroup(parent_css);
+	s32 parent_udp_limit;
 
 	netcg = kzalloc(sizeof(*netcg), GFP_KERNEL);
 	if (!netcg)
@@ -140,6 +166,9 @@ cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
 			/* if any of these cause an error, return ENOMEM */
 			return ERR_PTR(-ENOMEM);
 		}
+		/* and set no limit on udp ports */
+		atomic64_set(&netcg->udp_stats.udp_limitandusage,
+			     set_udp_limit_usage(DEFAULT_UDP_LIMIT, 0));
 	} else {
 		/* if not root, then, inherit ranges from parent */
 		if (alloc_copy_net_ranges(
@@ -154,6 +183,11 @@ cgrp_css_alloc(struct cgroup_subsys_state *parent_css)
 			/* if any of these cause an error, return ENOMEM */
 			return ERR_PTR(-ENOMEM);
 		}
+		/* and inherit udp port limit from parent */
+		parent_udp_limit = get_udp_limit(atomic64_read(
+			&parent_netcg->udp_stats.udp_limitandusage));
+		atomic64_set(&netcg->udp_stats.udp_limitandusage,
+			     set_udp_limit_usage(parent_udp_limit, 0));
 	}
 
 	return &netcg->css;
@@ -203,6 +237,212 @@ bool net_cgroup_listen_allowed(u16 port)
 }
 EXPORT_SYMBOL_GPL(net_cgroup_listen_allowed);
 
+static s64 net_udp_read_s64(struct cgroup_subsys_state *css, struct cftype *cft)
+{
+	struct  net_cgroup *netcg = css_to_net_cgroup(css);
+	s32 value = 0;
+
+	switch (cft->private) {
+	case NETCG_LIMIT_UDP:
+		value = get_udp_limit(
+			atomic64_read(&netcg->udp_stats.udp_limitandusage));
+		break;
+	case NETCG_USAGE_UDP:
+		value = get_udp_usage(
+			atomic64_read(&netcg->udp_stats.udp_limitandusage));
+		break;
+	case NETCG_MAXUSAGE_UDP:
+		value = atomic_read(&netcg->udp_stats.udp_maxusage);
+		break;
+	case NETCG_FAILCNT_UDP:
+		value = atomic_read(&netcg->udp_stats.udp_failcnt);
+		break;
+	case NETCG_UNDERFLOWCNT_UDP:
+		value = atomic_read(&netcg->udp_stats.udp_underflowcnt);
+		break;
+	default:
+		value = 0; /* this shouldn't happen */
+		break;
+	}
+
+	return (s64)value;
+}
+
+static int net_udp_write_s64(struct cgroup_subsys_state *css,
+			     struct cftype *cft, s64 val)
+{
+	struct net_cgroup *netcg = css_to_net_cgroup(css);
+	s32 oldlimit, usage;
+	u64     limitandusage, oldbits, newbits;
+
+	/* Make sure that 'val' is a 32 bit int */
+	if (val != (s32)val || val < -1)
+		return -EINVAL;
+
+	limitandusage = atomic64_read(&netcg->udp_stats.udp_limitandusage);
+	for (;;) {
+		oldlimit = get_udp_limit(limitandusage);
+		usage = get_udp_usage(limitandusage);
+		if (unlikely(oldlimit == (s32)val))
+			break;
+		newbits = set_udp_limit_usage((s32)val, usage);
+		oldbits = atomic64_cmpxchg(&netcg->udp_stats.udp_limitandusage,
+					   limitandusage, newbits);
+		if (likely(oldbits == limitandusage))
+			break;
+		limitandusage = oldbits;
+	}
+
+	return 0;
+}
+
+static bool try_inc_udp_usage(struct net_cgroup *netcg)
+{
+	s32 limit, usage, oldusage, maxusage;
+	u64 limitandusage, newbits, oldbits;
+
+	limitandusage = atomic64_read(&netcg->udp_stats.udp_limitandusage);
+	for (;;) {
+		usage = get_udp_usage(limitandusage);
+		limit = get_udp_limit(limitandusage);
+		/* Default indicates no restriction. */
+		if ((limit != DEFAULT_UDP_LIMIT) && unlikely(usage >= limit)) {
+			atomic_inc(&netcg->udp_stats.udp_failcnt);
+			return false;
+		}
+		/* Increment the usage irrespective of the fact that there is
+		 * limit set or not to record the usage.
+		 */
+		++usage;
+		newbits = set_udp_usage(limitandusage, usage);
+		oldbits = atomic64_cmpxchg(&netcg->udp_stats.udp_limitandusage,
+					   limitandusage, newbits);
+		if (likely(oldbits == limitandusage))
+			break;
+		limitandusage = oldbits;
+	}
+
+	maxusage = atomic_read(&netcg->udp_stats.udp_maxusage);
+
+	while (usage > maxusage) {
+		oldusage = atomic_cmpxchg(&netcg->udp_stats.udp_maxusage,
+					  maxusage, usage);
+		if (likely(oldusage == maxusage))
+			break;
+		maxusage = oldusage;
+	}
+	return true;
+}
+
+static bool try_dec_udp_usage(struct net_cgroup *netcg)
+{
+	s32 usage;
+	u64 limitandusage, newbits, oldbits;
+
+	limitandusage = atomic64_read(&netcg->udp_stats.udp_limitandusage);
+	for (;;) {
+		usage = get_udp_usage(limitandusage);
+		if (unlikely(usage <= 0)) {
+			atomic_inc(&netcg->udp_stats.udp_underflowcnt);
+			return false;
+		}
+		--usage;
+		newbits = set_udp_usage(limitandusage, usage);
+		oldbits = atomic64_cmpxchg(&netcg->udp_stats.udp_limitandusage,
+					   limitandusage, newbits);
+		if (likely(oldbits == limitandusage))
+			break;
+		limitandusage = oldbits;
+	}
+
+	return true;
+}
+
+/* The feature exposes following values through the cgroup interface:
+ * (1) udp_limit: Maximum number of UDP ports that processes from this
+ *                container can use.
+ * (2) udp_usage: Current usage of UDP ports by processes in this container.
+ * (3) udp_maxusage: The peak usage of UDP ports since container creation.
+ * (4) udp_failcnt: Number of port allocation requests failed because of
+ *                  ports depletion for this container.
+ * (5) udp_underflowcnt: Number of port release requests that would have
+ *                       pushed the usage below zero (see description below).
+ *
+ * Caveats:
+ *    If a process is moved to a different container, the udp sockets are not
+ * accounted for that process in the destination container. When that process
+ * finishes; that much credit will not be returned to the source container.
+ * This will create some sort of discrepancy at both source and destination
+ * containers. This transfer would create a pseudo-permanent transfer of port
+ * credits to the destination container. The trasfer effect will be nullified
+ * only if all the processes in this destination container stop using the udp
+ * ports momentarily and total usage drops to ZERO (since we do not allow the
+ * usage count to go negative, the pseudo-permanent transfer gets nullified
+ * at the destination container). It's assumed that this kind of process
+ * migration is minimal.
+ *    The limitandusage (64 bit) field holds limit in upper 32 bits and current
+ * usage in lower 32 bits. Since this is one field, the check and update atomic
+ * operations eliminate possible mismatch on multi-core systems.
+ */
+bool net_cgroup_acquire_udp_port(void)
+{
+	struct net_cgroup *netcg;
+	struct net_cgroup *curr;
+	struct net_cgroup *curr2;
+	bool success = true;
+
+	rcu_read_lock();
+	netcg = task_to_net_cgroup(current);
+
+	/* iterate this net_cgroup and its ancestors, attempting increment the
+	 * usage at each step
+	 */
+	for (curr = netcg;
+	     net_cgroup_to_parent(curr);
+	     curr = net_cgroup_to_parent(curr)) {
+		if (!try_inc_udp_usage(curr)) {
+			/* get out if any one ancestor fails */
+			success = false;
+			break;
+		}
+	}
+
+	if (!success) {
+		/* one of the ancestors failed to increment its usage. now, we
+		 * need to undo all the increments we did
+		 */
+		for (curr2 = netcg;
+		     curr2 != curr;
+		     curr2 = net_cgroup_to_parent(curr2)) {
+			try_dec_udp_usage(curr2);
+		}
+	}
+
+	rcu_read_unlock();
+	return success;
+}
+EXPORT_SYMBOL_GPL(net_cgroup_acquire_udp_port);
+
+void net_cgroup_release_udp_port(void)
+{
+	struct net_cgroup *netcg;
+	struct net_cgroup *curr;
+
+	rcu_read_lock();
+	netcg = task_to_net_cgroup(current);
+
+	/* iterate this net_cgroup and its ancestors, attempting decrement the
+	 * usage at each step
+	 */
+	for (curr = netcg;
+	     net_cgroup_to_parent(curr);
+	     curr = net_cgroup_to_parent(curr)) {
+		try_dec_udp_usage(curr);
+	}
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(net_cgroup_release_udp_port);
+
 /* Returns true if the range r is a subset of at least one of the ranges in
  * rs, and returns false otherwise.
  */
@@ -393,6 +633,39 @@ static struct cftype ss_files[] = {
 		.private	= NETCG_BIND_RANGES,
 		.max_write_len	= MAX_WRITE_SIZE,
 	},
+	{
+		.name		= "udp_limit",
+		.flags		= CFTYPE_ONLY_ON_ROOT,
+		.read_s64	= net_udp_read_s64,
+		.private	= NETCG_LIMIT_UDP,
+	},
+	{
+		.name		= "udp_limit",
+		.flags		= CFTYPE_NOT_ON_ROOT,
+		.read_s64	= net_udp_read_s64,
+		.write_s64	= net_udp_write_s64,
+		.private	= NETCG_LIMIT_UDP,
+	},
+	{
+		.name		= "udp_usage",
+		.read_s64	= net_udp_read_s64,
+		.private	= NETCG_USAGE_UDP,
+	},
+	{
+		.name		= "udp_maxusage",
+		.read_s64	= net_udp_read_s64,
+		.private	= NETCG_MAXUSAGE_UDP,
+	},
+	{
+		.name		= "udp_failcnt",
+		.read_s64	= net_udp_read_s64,
+		.private	= NETCG_FAILCNT_UDP,
+	},
+	{
+		.name		= "udp_underflowcnt",
+		.read_s64	= net_udp_read_s64,
+		.private	= NETCG_UNDERFLOWCNT_UDP,
+	},
 	{ }	/* terminate */
 };
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e61f7cd..fe588cf 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -114,6 +114,7 @@
 #include <net/busy_poll.h>
 #include "udp_impl.h"
 #include <net/sock_reuseport.h>
+#include <net/net_cgroup.h>
 
 struct udp_table udp_table __read_mostly;
 EXPORT_SYMBOL(udp_table);
@@ -318,6 +319,11 @@ scan_primary_hash:
 			goto fail_unlock;
 	}
 found:
+	/* Make sure it's UDP (and not UDP-lite) and it's unhashed! */
+	if (sk->sk_protocol == IPPROTO_UDP && sk_unhashed(sk) &&
+	    !net_cgroup_acquire_udp_port())
+		goto fail_unlock;
+
 	inet_sk(sk)->inet_num = snum;
 	udp_sk(sk)->udp_port_hash = snum;
 	udp_sk(sk)->udp_portaddr_hash ^= snum;
@@ -1388,6 +1394,8 @@ void udp_lib_unhash(struct sock *sk)
 		if (rcu_access_pointer(sk->sk_reuseport_cb))
 			reuseport_detach_sock(sk);
 		if (sk_del_node_init_rcu(sk)) {
+			if (sk->sk_protocol == IPPROTO_UDP)
+				net_cgroup_release_udp_port();
 			hslot->count--;
 			inet_sk(sk)->inet_num = 0;
 			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
-- 
2.8.0.rc3.226.g39d4020
