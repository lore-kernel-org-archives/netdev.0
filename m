From: Alexey Perevalov <a.perevalov@samsung.com>
Subject: [RFC PATCH v3] cgroup: net_cls: traffic counter based on
 classification control cgroup
Date: Mon, 14 Jan 2013 11:39:39 +0400
Message-ID: <50F3B63B.6050104@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Glauber Costa <glommer@parallels.com>,
	Daniel Wagner <wagi@monom.org>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	netdev@vger.kernel.org
To: cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:18462 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309Ab3ANHjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 02:39:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I would like to represent next version of patch I sent before
cgroup: "net_cls: traffic counter based on classification control cgroup"

The main idea is the same as was. It keeping counter in control groups, 
but now uses atomic instead resource_counters.

I have a performance measurement for this patch. It was done by lmbench 
on physical machine.
Results are not so representative for 20 tests and some numbers are real 
weird.

Daniel Wagner wrote what he is doing something similar, but using 
namespaces.

Proposed by me approach is used in upcoming Tizen release, but little 
bit different version.


Signed-off-by: Alexey Perevalov <a.perevalov@samsung.com>
---
include/net/cls_cgroup.h | 200 ++++++++++++++++++++++++++++++++++----
include/net/cls_counter_holder.h | 26 +++++
init/Kconfig | 25 +++++
kernel/cgroup.c | 2 +
kernel/res_counter.c | 4 +
net/core/dev.c | 6 ++
net/ipv4/tcp.c | 29 +++++-
net/ipv4/udp.c | 6 ++
net/sched/Kconfig | 11 ---
net/sched/Makefile | 1 +
net/sched/cls_cgroup.c | 193 +++++++++++++++++++++++++++++++++++-
net/sched/cls_counter_holder.c | 144 +++++++++++++++++++++++++++
12 files changed, 612 insertions(+), 35 deletions(-)
create mode 100644 include/net/cls_counter_holder.h
create mode 100644 net/sched/cls_counter_holder.c

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 2581638..304786d 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -13,54 +13,197 @@
#ifndef _NET_CLS_CGROUP_H
#define _NET_CLS_CGROUP_H

+#include <linux/atomic.h>
#include <linux/cgroup.h>
#include <linux/hardirq.h>
#include <linux/rcupdate.h>

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+#include <linux/nsproxy.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <net/cls_counter_holder.h>
+#include <net/sock.h>
+
+/*TODO hide all it to separate file*/
+
+struct cls_iface_cntrs {
+ char *dev_name;
+ atomic64_t snd_counter;
+ atomic64_t rcv_counter;
+ struct list_head link;
+};
+
+#endif /*CONFIG_NET_CLS_COUNTER*/
+
+
#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
struct cgroup_cls_state
{
struct cgroup_subsys_state css;
u32 classid;
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ struct cls_iface_cntrs iface_stats;
+#endif /*CONFIG_NET_CLS_COUNTER*/
};

extern void sock_update_classid(struct sock *sk, struct task_struct *task);

-#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
-static inline u32 task_cls_classid(struct task_struct *p)
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
+static inline struct cgroup_cls_state *get_cls_cgroup(struct 
task_struct *p)
{
- u32 classid;
+ struct cgroup_subsys_state *css = task_subsys_state(p,
+ net_cls_subsys_id);
+ if (css)
+ return container_of(css,
+ struct cgroup_cls_state, css);
+ return NULL;
+}
+#elif IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
+static inline struct cgroup_cls_state *get_cls_cgroup(struct 
task_struct *p)
+{
+ return container_of(task_subsys_state(p, net_cls_subsys_id),
+ struct cgroup_cls_state, css);
+}
+#endif

- if (in_interrupt())
- return 0;

- rcu_read_lock();
- classid = container_of(task_subsys_state(p, net_cls_subsys_id),
- struct cgroup_cls_state, css)->classid;
- rcu_read_unlock();
+#endif /*CONFIG_NET_CLS_CGROUP*/

- return classid;
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+static inline u32 skb_cls_classid(const struct sk_buff *skb)
+{
+ return (skb && skb->sk) ? skb->sk->sk_classid : 0;
+}
+
+static inline int get_ifindex_from_skb(const struct sk_buff *skb)
+{
+ int ifindex = 0;
+ if (skb)
+ ifindex = skb->skb_iif;
+ return ifindex;
+}
+
+static struct cls_iface_cntrs *find_cls_counter(
+ struct cgroup_cls_state *cls_cgroup,
+ const char *dev_name,
+ bool create)
+{
+ /*TODO Add lock*/
+ struct cls_iface_cntrs *entry = NULL;
+
+ if (!dev_name) {
+ pr_err("cls please provide valid dev name");
+ return NULL;
+ }
+
+ list_for_each_entry(entry, &cls_cgroup->iface_stats.link, link)
+ if (!strcmp(entry->dev_name, dev_name))
+ return entry;
+
+ if (!create)
+ return entry;
+
+ /*not found, insert*/
+ entry = kmalloc(sizeof(struct cls_iface_cntrs), GFP_ATOMIC);
+ entry->dev_name = kstrdup(dev_name, GFP_ATOMIC);
+ atomic64_set(&entry->rcv_counter, 0);
+ atomic64_set(&entry->snd_counter, 0);
+ list_add_tail(&entry->link, &cls_cgroup->iface_stats.link);
+ return entry;
}
-#elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
+
+static void charge_net_cls_snd(struct cgroup_cls_state *cls_cgroup,
+ const u32 copied, const char *dev_name)
+{
+ struct cls_iface_cntrs *cnt = find_cls_counter(cls_cgroup,
+ dev_name, true);
+
+ if (!cnt)
+ return;
+
+ atomic64_add(copied, &cnt->snd_counter);
+}
+
+static char *get_dev_name(const int ifindex)
+{
+ struct net *net = NULL;
+ struct nsproxy *nsproxy = NULL;
+ struct net_device *net_dev = NULL;
+
+ nsproxy = task_nsproxy(current);
+ if (!nsproxy) {
+ pr_debug("cls cant find task_nsproxy");
+ return NULL;
+ }
+
+ net = get_net(nsproxy->net_ns);
+ if (!net) {
+ pr_debug("cls cant find net");
+ return NULL;
+ }
+ net_dev = dev_get_by_index(net, ifindex);
+
+ return net_dev ? net_dev->name : NULL;
+}
+
+static void charge_net_cls_rcv(struct cgroup_cls_state *cls_cgroup,
+ const u32 copied, const int ifindex)
+{
+ char *dev_name = get_dev_name(ifindex);
+ struct cls_iface_cntrs *cnt = find_cls_counter(cls_cgroup,
+ dev_name, true);
+
+ if (!cnt)
+ return;
+
+ atomic64_add(copied, &cnt->rcv_counter);
+}
+
+static inline void count_cls_rcv(struct task_struct *p, const u32 copied,
+ const int ifindex)
+{
+ struct cgroup_cls_state *cls_cgroup;
+
+ cls_cgroup = get_cls_cgroup(p);
+
+ if (cls_cgroup)
+ charge_net_cls_rcv(cls_cgroup, copied, ifindex);
+}
+
+static inline void count_cls_snd(u32 classid, const u32 copied,
+ const char *dev_name)
+{
+ struct cgroup_cls_state *cls_cgroup;
+
+ cls_cgroup = find_cls_cgroup_by_classid(classid);
+
+ if (cls_cgroup)
+ charge_net_cls_snd(cls_cgroup, copied, dev_name);
+}
+#endif /*CONFIG_NET_CLS_COUNTER*/
+
static inline u32 task_cls_classid(struct task_struct *p)
{
- struct cgroup_subsys_state *css;
- u32 classid = 0;
+ int classid = 0;
+ struct cgroup_cls_state *cls_cgroup = NULL;

if (in_interrupt())
return 0;

rcu_read_lock();
- css = task_subsys_state(p, net_cls_subsys_id);
- if (css)
- classid = container_of(css,
- struct cgroup_cls_state, css)->classid;
+
+ cls_cgroup = get_cls_cgroup(p);
+ if (cls_cgroup)
+ classid = cls_cgroup->classid;
+
rcu_read_unlock();

return classid;
}
-#endif
-#else /* !CGROUP_NET_CLS_CGROUP */
+
+#else /* !CONFIG_NET_CLS_CGROUP */
static inline void sock_update_classid(struct sock *sk, struct 
task_struct *task)
{
}
@@ -69,5 +212,22 @@ static inline u32 task_cls_classid(struct 
task_struct *p)
{
return 0;
}
-#endif /* CGROUP_NET_CLS_CGROUP */
+#endif /* CONFIG_NET_CLS_CGROUP */
+
+#if !IS_ENABLED(CONFIG_NET_CLS_CGROUP) || 
!IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+static inline void count_cls_rcv(struct task_struct *p,
+ const u32 copied, const int ifindex)
+{
+}
+
+static inline void count_cls_snd(u32 classid,
+ const u32 copied, const char *dev_name)
+{
+}
+
+static inline u32 skb_cls_classid(const struct sk_buff *skb)
+{
+ return 0;
+}
+#endif
#endif /* _NET_CLS_CGROUP_H */
diff --git a/include/net/cls_counter_holder.h 
b/include/net/cls_counter_holder.h
new file mode 100644
index 0000000..a129baa
--- /dev/null
+++ b/include/net/cls_counter_holder.h
@@ -0,0 +1,26 @@
+/*
+ * cls_counter_holder.c Interface for holding references of the
+ * net cls cgroup instances.
+ *
+ * Authors: Alexey Perevalov, <a.perevalov@samsung.com>
+ *
+ * Changes:
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _NET_CLS_COUNTER_HOLDER_H_
+#define _NET_CLS_COUNTER_HOLDER_H_
+
+#include <net/cls_cgroup.h>
+
+struct cgroup_cls_state;
+
+void insert_cls_cgroup_entry(struct cgroup_cls_state *obj);
+void delete_cls_cgroup_entry(const u32 classid);
+struct cgroup_cls_state *find_cls_cgroup_by_classid(const u32 classid);
+
+
+#endif /* _NET_CLS_COUNTER_HOLDER_H_ */
diff --git a/init/Kconfig b/init/Kconfig
index 6fdd6e3..2e6af85 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -841,6 +841,31 @@ config CGROUP_HUGETLB
control group is tracked in the third page lru pointer. This means
that we cannot use the controller with huge page less than 3 pages.

+menuconfig NET_CLS_CGROUP
+ tristate "Control Group Classifier"
+ select NET_CLS
+ depends on CGROUPS
+ ---help---
+ Say Y here if you want to classify packets based on the control
+ cgroup of their process.
+
+ To compile this code as a module, choose M here: the
+ module will be called cls_cgroup.
+
+if NET_CLS_CGROUP
+config NET_CLS_COUNTER
+ bool "Network traffic counter for network Control Group Classifier"
+ select NET_CLS
+ default n
+ depends on NET_CLS_CGROUP && RESOURCE_COUNTERS
+ ---help---
+ Say Y here if you want to count traffic associate with the control
+ cgroup.
+
+ To add functionality to cls_cgroup select y.
+
+endif #NET_CLS_CGROUP
+
config CGROUP_PERF
bool "Enable perf_event per-cpu per-container group (cgroup) monitoring"
depends on PERF_EVENTS && CGROUPS
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 13774b3..68a4a53 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2966,6 +2966,8 @@ int cgroup_rm_cftypes(struct cgroup_subsys *ss, 
struct cftype *cfts)
cgroup_cfts_commit(ss, NULL, false);
return -ENOENT;
}
+EXPORT_SYMBOL_GPL(cgroup_rm_cftypes);
+

/**
* cgroup_task_count - count the number of tasks in a cgroup.
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index ad581aa..f5767af 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -13,6 +13,8 @@
#include <linux/res_counter.h>
#include <linux/uaccess.h>
#include <linux/mm.h>
+#include <linux/export.h>
+

void res_counter_init(struct res_counter *counter, struct res_counter 
*parent)
{
@@ -21,6 +23,7 @@ void res_counter_init(struct res_counter *counter, 
struct res_counter *parent)
counter->soft_limit = RESOURCE_MAX;
counter->parent = parent;
}
+EXPORT_SYMBOL(res_counter_init);

int res_counter_charge_locked(struct res_counter *counter, unsigned long 
val,
bool force)
@@ -170,6 +173,7 @@ u64 res_counter_read_u64(struct res_counter 
*counter, int member)
return *res_counter_member(counter, member);
}
#endif
+EXPORT_SYMBOL(res_counter_read_u64);

int res_counter_memparse_write_strategy(const char *buf,
unsigned long long *res)
diff --git a/net/core/dev.c b/net/core/dev.c
index b4978e2..61c9a61 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,6 +135,7 @@
#include <linux/net_tstamp.h>
#include <linux/static_key.h>
#include <net/flow_keys.h>
+#include <net/cls_cgroup.h>

#include "net-sysfs.h"

@@ -2570,6 +2571,11 @@ int dev_queue_xmit(struct sk_buff *skb)
*/
rcu_read_lock_bh();

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ if (dev)
+ count_cls_snd(skb_cls_classid(skb), skb->len, dev->name);
+#endif
+
skb_update_prio(skb);

txq = netdev_pick_tx(dev, skb);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index eace049..ba54577 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -276,6 +276,7 @@
#include <net/ip.h>
#include <net/netdma.h>
#include <net/sock.h>
+#include <net/cls_cgroup.h>

#include <asm/uaccess.h>
#include <asm/ioctls.h>
@@ -1467,6 +1468,9 @@ int tcp_read_sock(struct sock *sk, 
read_descriptor_t *desc,
u32 seq = tp->copied_seq;
u32 offset;
int copied = 0;
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ int ifindex = 0;
+#endif

if (sk->sk_state == TCP_LISTEN)
return -ENOTCONN;
@@ -1509,6 +1513,9 @@ int tcp_read_sock(struct sock *sk, 
read_descriptor_t *desc,
++seq;
break;
}
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ ifindex = get_ifindex_from_skb(skb);
+#endif
sk_eat_skb(sk, skb, false);
if (!desc->count)
break;
@@ -1519,8 +1526,12 @@ int tcp_read_sock(struct sock *sk, 
read_descriptor_t *desc,
tcp_rcv_space_adjust(sk);

/* Clean up data we have read: This will do ACK frames. */
- if (copied > 0)
+ if (copied > 0) {
tcp_cleanup_rbuf(sk, copied);
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ count_cls_rcv(current, copied, ifindex);
+#endif
+ }
return copied;
}
EXPORT_SYMBOL(tcp_read_sock);
@@ -1548,6 +1559,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock 
*sk, struct msghdr *msg,
bool copied_early = false;
struct sk_buff *skb;
u32 urg_hole = 0;
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ int ifindex = 0;
+#endif

lock_sock(sk);

@@ -1872,6 +1886,9 @@ skip_copy:
if (tcp_hdr(skb)->fin)
goto found_fin_ok;
if (!(flags & MSG_PEEK)) {
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ ifindex = get_ifindex_from_skb(skb);
+#endif
sk_eat_skb(sk, skb, copied_early);
copied_early = false;
}
@@ -1881,6 +1898,9 @@ skip_copy:
/* Process the FIN. */
++*seq;
if (!(flags & MSG_PEEK)) {
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ ifindex = get_ifindex_from_skb(skb);
+#endif
sk_eat_skb(sk, skb, copied_early);
copied_early = false;
}
@@ -1923,6 +1943,11 @@ skip_copy:
/* Clean up data we have read: This will do ACK frames. */
tcp_cleanup_rbuf(sk, copied);

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ if (copied > 0)
+ count_cls_rcv(current, copied, ifindex);
+#endif
+
release_sock(sk);
return copied;

@@ -1932,6 +1957,8 @@ out:

recv_urg:
err = tcp_recv_urg(sk, msg, len, flags);
+ if (err > 0)
+ count_cls_rcv(current, err, ifindex);
goto out;

recv_sndq:
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 79c8dbe..a143629 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -101,6 +101,7 @@
#include <linux/skbuff.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
+#include <net/cls_cgroup.h>
#include <net/net_namespace.h>
#include <net/icmp.h>
#include <net/route.h>
@@ -1254,6 +1255,11 @@ try_again:
if (flags & MSG_TRUNC)
err = ulen;

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ if (ulen > 0)
+ count_cls_rcv(current, ulen, get_ifindex_from_skb(skb));
+#endif
+
out_free:
skb_free_datagram_locked(sk, skb);
out:
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 62fb51f..926dedf 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -418,17 +418,6 @@ config NET_CLS_FLOW
To compile this code as a module, choose M here: the
module will be called cls_flow.

-config NET_CLS_CGROUP
- tristate "Control Group Classifier"
- select NET_CLS
- depends on CGROUPS
- ---help---
- Say Y here if you want to classify packets based on the control
- cgroup of their process.
-
- To compile this code as a module, choose M here: the
- module will be called cls_cgroup.
-
config NET_EMATCH
bool "Extended Matches"
select NET_CLS
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 978cbf0..95dbb12 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -49,6 +49,7 @@ obj-$(CONFIG_NET_CLS_RSVP6) += cls_rsvp6.o
obj-$(CONFIG_NET_CLS_BASIC) += cls_basic.o
obj-$(CONFIG_NET_CLS_FLOW) += cls_flow.o
obj-$(CONFIG_NET_CLS_CGROUP) += cls_cgroup.o
+obj-$(CONFIG_NET_CLS_COUNTER) += cls_counter_holder.o
obj-$(CONFIG_NET_EMATCH) += ematch.o
obj-$(CONFIG_NET_EMATCH_CMP) += em_cmp.o
obj-$(CONFIG_NET_EMATCH_NBYTE) += em_nbyte.o
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 709b0fb..5683120 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -9,6 +9,7 @@
* Authors: Thomas Graf <tgraf@suug.ch>
*/

+#include <linux/atomic.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/types.h>
@@ -22,6 +23,15 @@
#include <net/pkt_cls.h>
#include <net/sock.h>
#include <net/cls_cgroup.h>
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+#include <linux/rbtree.h>
+#include <net/cls_counter_holder.h>
+
+static struct notifier_block counter_notifier;
+static const char *rcv_label = "rcv:";
+static const char *snd_label = "snd:";
+
+#endif

static inline struct cgroup_cls_state *cgrp_cls_state(struct cgroup *cgrp)
{
@@ -46,11 +56,47 @@ static struct cgroup_subsys_state 
*cgrp_create(struct cgroup *cgrp)
if (cgrp->parent)
cs->classid = cgrp_cls_state(cgrp->parent)->classid;

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ atomic64_set(&cs->iface_stats.snd_counter, 0);
+ atomic64_set(&cs->iface_stats.rcv_counter, 0);
+ cs->iface_stats.dev_name = 0;
+ INIT_LIST_HEAD(&cs->iface_stats.link);
+#endif
+
return &cs->css;
}

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+static inline void cgrp_counter_destroy(struct cgroup_cls_state *cs)
+{
+ struct list_head *pos, *q;
+ delete_cls_cgroup_entry(cs->classid);
+
+ list_for_each_safe(pos, q, &cs->iface_stats.link) {
+ struct cls_iface_cntrs *tmp = list_entry(
+ pos, struct cls_iface_cntrs, link);
+ list_del(pos);
+ if (!tmp)
+ continue;
+
+ if (!tmp->dev_name)
+ kfree(tmp->dev_name);
+ kfree(tmp);
+ }
+
+}
+#endif
+
static void cgrp_destroy(struct cgroup *cgrp)
{
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+
+ struct cgroup_cls_state *cs = cgrp_cls_state(cgrp);
+
+ if (!cs)
+ return;
+ cgrp_counter_destroy(cs);
+#endif
kfree(cgrp_cls_state(cgrp));
}

@@ -81,9 +127,57 @@ static u64 read_classid(struct cgroup *cgrp, struct 
cftype *cft)
return cgrp_cls_state(cgrp)->classid;
}

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+static const char *extract_dev_name(const char *cgroup_file_name)
+{
+ const char *dot = strchr(cgroup_file_name, '.');
+ const size_t len = dot ? dot - cgroup_file_name :
+ strlen(cgroup_file_name);
+
+ return kstrndup(cgroup_file_name, len, GFP_KERNEL);
+}
+
+static int read_stat(struct cgroup *cgrp, struct cftype *cft,
+ struct cgroup_map_cb *cb)
+{
+ struct cgroup_cls_state *cs = cgrp_cls_state(cgrp);
+ const char *dev_name = extract_dev_name(cft->name);
+ struct cls_iface_cntrs *res = find_cls_counter(cs, dev_name, false);
+
+ if (!res) {
+ pr_debug("cls cant read for cls");
+ return -EINVAL;
+ }
+
+ cb->fill(cb, rcv_label,
+ atomic64_read(&res->rcv_counter));
+ cb->fill(cb, snd_label,
+ atomic64_read(&res->snd_counter));
+
+ kfree(dev_name);
+ return 0;
+}
+#endif /* CONFIG_NET_CLS_COUNTER */
+
static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
{
- cgrp_cls_state(cgrp)->classid = (u32) value;
+ struct cgroup_cls_state *cgrp_cls = cgrp_cls_state(cgrp);
+ u32 *classid = &cgrp_cls->classid;
+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ u32 oldclassid = *classid;
+
+ if (find_cls_cgroup_by_classid(value)) {
+ pr_err("cls: classid %llu already exists\n", value);
+ return -EINVAL;
+ }
+
+ insert_cls_cgroup_entry(cgrp_cls);
+
+ if (oldclassid)
+ delete_cls_cgroup_entry(oldclassid);
+#endif /* CONFIG_NET_CLS_COUNTER */
+ *classid = (u32) value;
+
return 0;
}

@@ -307,17 +401,107 @@ static struct tcf_proto_ops cls_cgroup_ops 
__read_mostly = {
.owner = THIS_MODULE,
};

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+static inline int add_cft_file_for_device(struct net_device *dev)
+{
+ struct cftype *cft;
+ int ret = 0;
+
+ if (!dev)
+ return ret;
+
+ cft = kmalloc(sizeof(struct cftype) * 2,
+ GFP_KERNEL);
+ /* *2 and last 0 fill for terminator */
+ memset(cft, 0, sizeof(struct cftype) * 2);
+
+ snprintf(cft->name, MAX_CFTYPE_NAME,
+ "%s.usage_in_bytes", dev->name);
+ cft->read_map = read_stat;
+ cft->private = RES_USAGE;
+ ret = cgroup_add_cftypes(&net_cls_subsys, cft);
+ if (ret)
+ pr_err("cls error adding cft for counting at " \
+ "cls_cgroup %d\n", ret);
+ return ret;
+}
+
+static int device_state_cb(struct notifier_block *nb,
+ unsigned long state, void *arg)
+{
+ struct net_device *net = (struct net_device *)arg;
+ if (!nb || !net) {
+ pr_err("Not valid arguments for net_device notifier cb\n");
+ return 0;
+ }
+
+ if (state == NETDEV_REGISTER) {
+ pr_info("cls New device %s\n", net->name);
+ return add_cft_file_for_device(net);
+ }
+ return 0;
+}
+
+static inline int init_cgroup_counter(void)
+{
+ int ret = 0;
+ struct net_device *dev;
+ counter_notifier.notifier_call = device_state_cb;
+
+ ret = register_netdevice_notifier(&counter_notifier);
+ if (ret)
+ pr_err("cls Cant register nofier\n");
+
+ for_each_netdev(&init_net, dev) {
+ ret = add_cft_file_for_device(dev);
+ if (ret)
+ goto unregister_notifier;
+ }
+
+ return ret;
+unregister_notifier:
+
+ unregister_netdevice_notifier(&counter_notifier);
+ return ret;
+}
+
+static void release_cft(void)
+{
+ struct list_head *pos, *q;
+ list_for_each_safe(pos, q, &net_cls_subsys.cftsets) {
+ struct cftype_set *set =
+ list_entry(pos, struct cftype_set, node);
+ int ret = cgroup_rm_cftypes(&net_cls_subsys, set->cfts);
+ if (!ret) {
+ pr_err("cls cant remove cftypes\n");
+ break;
+ }
+
+ kfree(set->cfts);
+ }
+}
+#endif
+
static int __init init_cgroup_cls(void)
{
int ret;
-
ret = cgroup_load_subsys(&net_cls_subsys);
if (ret)
goto out;

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ ret = init_cgroup_counter();
+ if (ret)
+ goto unload;
+#endif
+
ret = register_tcf_proto_ops(&cls_cgroup_ops);
if (ret)
- cgroup_unload_subsys(&net_cls_subsys);
+ goto unload;
+
+ return 0;
+unload:
+ cgroup_unload_subsys(&net_cls_subsys);

out:
return ret;
@@ -327,6 +511,9 @@ static void __exit exit_cgroup_cls(void)
{
unregister_tcf_proto_ops(&cls_cgroup_ops);

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ release_cft();
+#endif
cgroup_unload_subsys(&net_cls_subsys);
}

diff --git a/net/sched/cls_counter_holder.c b/net/sched/cls_counter_holder.c
new file mode 100644
index 0000000..94ab285
--- /dev/null
+++ b/net/sched/cls_counter_holder.c
@@ -0,0 +1,144 @@
+/*
+ * net/sched/cls_counter_holder.c Interface for holding references of the
+ * net cls cgroup instances.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ *
+ * Authors: Alexey Perevalov <a.perevalov@samsung.com>
+ */
+
+
+#include <linux/export.h>
+#include <linux/module.h>
+#include <net/cls_cgroup.h>
+#include <net/cls_counter_holder.h>
+
+static struct rb_root classid_tree = RB_ROOT;
+static DEFINE_SPINLOCK(classid_tree_lock);
+
+struct entry {
+ struct cgroup_cls_state *data;
+ struct rb_node node;
+};
+
+static struct entry *find_entry(struct rb_root *root, const u32 classid)
+{
+ struct rb_node *node = root->rb_node;
+
+ while (node) {
+ struct entry *cls_entry = rb_entry(node, struct entry, node);
+ int result = 0;
+ if (!cls_entry || !cls_entry->data)
+ break;
+ result = cls_entry->data->classid - classid;
+
+ if (result < 0)
+ node = node->rb_left;
+ else if (result > 0)
+ node = node->rb_right;
+ else
+ return cls_entry;
+ }
+ return NULL;
+}
+
+void insert_cls_cgroup_entry(struct cgroup_cls_state *obj)
+{
+ struct rb_node **new;
+ struct rb_node *parent = NULL;
+ struct entry *new_entry;
+ unsigned long irq_flags = 0;
+
+ struct rb_root *root = &classid_tree;
+
+ spin_lock_irqsave(&classid_tree_lock, irq_flags);
+
+ new = &root->rb_node;
+
+ while (*new) {
+ struct entry *this = rb_entry(*new, struct entry, node);
+ /* Sort by classid, then by ifindex */
+ int result =
+ (this->data->classid - obj->classid);
+ parent = *new;
+ if (result < 0)
+ new = &((*new)->rb_left);
+ else if (result > 0)
+ new = &((*new)->rb_right);
+ else
+ goto unlock;
+ }
+
+ /* If we here, we need to insert new entry into tree */
+ new_entry = kmalloc(sizeof(struct entry), GFP_ATOMIC);
+ if (!new_entry)
+ goto unlock;
+
+ new_entry->data = obj;
+ /* Add new node and rebalance tree */
+ rb_link_node(&new_entry->node, parent, new);
+ rb_insert_color(&new_entry->node, root);
+
+unlock:
+ spin_unlock_irqrestore(&classid_tree_lock, irq_flags);
+}
+EXPORT_SYMBOL(insert_cls_cgroup_entry);
+
+void delete_cls_cgroup_entry(const u32 classid)
+{
+ unsigned long irq_flags = 0;
+ struct entry *data = NULL;
+ struct rb_root *root = &classid_tree;
+ spin_lock_irqsave(&classid_tree_lock, irq_flags);
+
+ data = find_entry(root, classid);
+
+ if (data) {
+ rb_erase(&data->node, root);
+ kfree(data);
+ }
+ spin_unlock_irqrestore(&classid_tree_lock, irq_flags);
+}
+EXPORT_SYMBOL(delete_cls_cgroup_entry);
+
+static void free_node(struct rb_node *root)
+{
+ struct entry *cur_entry = rb_entry(root, struct entry, node);
+ if (root->rb_left)
+ free_node(root->rb_left);
+ if (root->rb_right)
+ free_node(root->rb_right);
+ kfree(cur_entry);
+}
+
+static void free_classid_tree(void)
+{
+ unsigned long irq_flags = 0;
+
+ spin_lock_irqsave(&classid_tree_lock, irq_flags);
+
+ free_node(classid_tree.rb_node);
+
+ spin_unlock_irqrestore(&classid_tree_lock, irq_flags);
+}
+
+struct cgroup_cls_state *find_cls_cgroup_by_classid(const u32 classid)
+{
+ struct entry *cls_entry = find_entry(&classid_tree, classid);
+ if (cls_entry)
+ return cls_entry->data;
+
+ return NULL;
+}
+EXPORT_SYMBOL(find_cls_cgroup_by_classid);
+
+static void __exit exit_cls_counter_holder(void)
+{
+ free_classid_tree();
+}
+
+module_exit(exit_cls_counter_holder);
+MODULE_LICENSE("GPL");
-- 
1.7.9.5


The performance measurement results

*Local* Communication latencies in microseconds smaller is better

2p/0K ctxsw Pipe AF Unix UDP RPC/UDP TCP RPC/TCP TCP conn
Kernel with patch: 6.641 14.83 13.68 43.715 25.005 31.82 26.845 31.45
Kernel without patch: 6.5815 14.64 13.6895 48.6 28.74 35.745 26.875 31.6
Kernel with patch and created cgroups 6.456 14.54 13.88 50.145 33.735 
32.26 26.92 31


*Local* Communication bandwidths in MB/s bigger is better
Pipe AF Unix TCP File reread Mmap reread Bcopy (libc) Bcopy (hand) Mem 
read Mem write
Kernel with patch: 724.8 6952.3 3366.8 4409.565 7534.86 6629.05 3490.055 
5594.15 6701.1
Kernel without patch: 669.55 6839.85 3347.65 4412.215 7506.46 6579.53 
3453.145 5579.5 6243.45
Kernel with patch and create cgroups 718.75 6882.65 3353.2 4422.95 
7521.225 6629.665 3472.87 5591.05 6409.9



-- 
Best regards,
Alexey Perevalov
