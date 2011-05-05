From: y@vger.kernel.org
Subject: [RFC v4 08/11] snet: introduce snet_ticket
Date: Thu,  5 May 2011 15:59:18 +0200
Message-ID: <36673.8982069821$1304604701@news.gmane.org>
References: <1304603961-2517-1-git-send-email-y>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1304603961-2517-1-git-send-email-y>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samir Bellabes <sam@synack.fr>

this patch adds the snet's subsystem managing granted-access tickets

snet is using the term 'ticket' for refering to a structure which keeps
informations about verdict, coming from userspace.

generic informations:
  timeout
  syscall
  protocol
  verdict

protocol-dependant informations : (so some infos may not be used)
  address family
  socket type
  source address
  source port
  distant address
  distant port

ticket are attached to the "void *security" pointer of task_struct

there are 3 modes:

0. no ticket - SNET_TICKET_OFF
   every syscalls has to be verified by userspace.

1. timeout fixed - SNET_TICKET_FIX
   for each response from the userspace, we are creating a ticket,
   attached to the task_struct, with the filled informations, and a
   fixed timeout value (10 secs by default).
   then before asking userspace, kernel mecanism is checking existing
   tickets for the task_struct, if there is a granted-access ticket, we
   are using the verdict value attached.
   after the timeout value, the ticket is destroyed.

2. timeout with extendable value - SNET_TICKET_EXTEND
   this is the same mecanism as 1, but every time a ticket is matched
   and used, the timeout value is reset to the default value, so its
   life is extended.

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/snet_ticket.c        |  195 ++++++++++++++++++++++++++++++++++++
 security/snet/snet_ticket.h        |   37 +++++++
 security/snet/snet_ticket_helper.c |  127 +++++++++++++++++++++++
 security/snet/snet_ticket_helper.h |    8 ++
 4 files changed, 367 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/snet_ticket.c
 create mode 100644 security/snet/snet_ticket.h
 create mode 100644 security/snet/snet_ticket_helper.c
 create mode 100644 security/snet/snet_ticket_helper.h

diff --git a/security/snet/snet_ticket.c b/security/snet/snet_ticket.c
new file mode 100644
index 0000000..a260412
--- /dev/null
+++ b/security/snet/snet_ticket.c
@@ -0,0 +1,195 @@
+#include <linux/slab.h>
+#include <linux/cred.h>
+#include <linux/jhash.h>
+#include <linux/security.h>
+#include <linux/snet.h>
+#include "snet_ticket.h"
+#include "snet_ticket_helper.h"
+
+#define HSIZE 16
+
+static struct kmem_cache *snet_ticket_cachep;
+static struct kmem_cache *snet_task_security_cachep;
+
+enum snet_verdict snet_ticket_check(struct snet_info *info)
+{
+	struct snet_ticket *st = NULL;
+	unsigned int h = 0, verdict = SNET_VERDICT_NONE;
+	struct list_head *l = NULL;
+	struct snet_task_security *tsec = NULL;
+
+	if (snet_ticket_mode == SNET_TICKET_OFF)
+		goto out;
+
+	tsec = (struct snet_task_security*) current_security();
+
+	h = jhash_2words(info->syscall, info->protocol, 0) % HSIZE;
+	l = &tsec->hash[h];
+
+	read_lock_bh(&tsec->lock);
+	list_for_each_entry(st, l, list) {
+		if (__ticket_check(st, info)) {
+			verdict = st->verdict;
+			pr_debug("snet_ticket found: ticket=%p tsec=%p\n",
+				 st, st->tsec);
+			if (snet_ticket_mode == SNET_TICKET_EXTEND) {
+				mod_timer(&st->timeout,
+					  jiffies + snet_ticket_delay * HZ);
+			}
+			break;
+		}
+	}
+	read_unlock_bh(&tsec->lock);
+out:
+	return verdict;
+}
+
+static void snet_ticket_timeout(unsigned long arg)
+{
+	struct snet_ticket *st = (struct snet_ticket*)arg;
+
+	pr_debug("snet_ticket_timeout: ticket=%p tsec=%p\n", st, st->tsec);
+
+	write_lock_bh(&st->tsec->lock);
+	list_del(&st->list);
+	write_unlock_bh(&st->tsec->lock);
+	kmem_cache_free(snet_ticket_cachep, st);
+	return;
+}
+
+static struct snet_ticket *snet_ticket_alloc(void)
+{
+	struct snet_ticket *st = NULL;
+
+	st = kmem_cache_zalloc(snet_ticket_cachep, GFP_KERNEL);
+	if (st == NULL)
+		goto out;
+
+	INIT_LIST_HEAD(&st->list);
+	init_timer(&st->timeout);
+	st->timeout.expires = snet_ticket_delay * HZ;
+out:
+	return st;
+}
+
+static void snet_ticket_insert(struct snet_ticket *st)
+{
+	unsigned int h;
+	struct list_head *l;
+
+	h = jhash_2words(st->syscall, st->protocol, 0) % HSIZE;
+	l = &(st->tsec->hash[h]);
+
+	st->timeout.expires += jiffies;
+	add_timer(&st->timeout);
+
+	write_lock_bh(&(st->tsec->lock));
+	list_add_tail(&st->list, l);
+	write_unlock_bh(&(st->tsec->lock));
+	return;
+}
+
+void snet_ticket_create(struct snet_info *info, enum snet_verdict verdict)
+{
+	struct snet_ticket *st;
+	struct snet_task_security *tsec = NULL;
+
+	if (snet_ticket_mode == SNET_TICKET_OFF)
+		goto out;
+
+	tsec = (struct snet_task_security*) current_security();
+
+	st = snet_ticket_alloc();
+	if (st == NULL)
+		goto out;
+
+	st->tsec = tsec;
+	snet_ticket_fill(st, info, verdict);
+	setup_timer(&st->timeout, snet_ticket_timeout, (unsigned long)st);
+	snet_ticket_insert(st);
+out:
+	return;
+}
+
+int snet_prepare_creds(struct cred *new, const struct cred *old, gfp_t gfp)
+{
+	unsigned int index = 0;
+	struct snet_task_security *tsec = NULL;
+
+	tsec = kmem_cache_zalloc(snet_task_security_cachep, gfp);
+	if (tsec == NULL)
+		return -ENOMEM;
+
+	pr_debug("ticket_prepare_creds: pid=%u tsec=%p\n", current->pid, tsec);
+	rwlock_init(&tsec->lock);
+	for (index = 0; index < HSIZE; index++)
+		INIT_LIST_HEAD(&tsec->hash[index]);
+
+	new->security = tsec;
+	return 0;
+}
+
+void snet_cred_free(struct cred *cred)
+{
+	struct snet_task_security *tsec = cred->security;
+	unsigned int index;
+
+	pr_debug("ticket_free_cred: pid=%u tsec=%p\n",  current->pid, tsec);
+
+	write_lock_bh(&tsec->lock);
+	/* destroy all tickets */
+	for (index = 0; index < HSIZE; index++) {
+		struct snet_ticket *st, *tmp;
+		list_for_each_entry_safe(st, tmp, &tsec->hash[index], list) {
+			if (del_timer_sync(&st->timeout)) {
+				pr_debug("ticket_cred_free: [%u] ticket=%p tsec=%p\n",
+					 index, st, st->tsec);
+				list_del(&st->list);
+				kmem_cache_free(snet_ticket_cachep, st);
+			}
+		}
+	}
+	cred->security = NULL;
+	write_unlock_bh(&tsec->lock);
+	kmem_cache_free(snet_task_security_cachep, tsec);
+	return;
+}
+
+int snet_ticket_init(void)
+{
+	unsigned int index = 0;
+	struct cred *cred = (struct cred *) current->real_cred;
+	struct snet_task_security *tsec = NULL;
+
+	if (snet_ticket_mode >= SNET_TICKET_INVALID) {
+		printk(KERN_ERR "snet: bad snet_ticket_mode\n");
+		return -EINVAL;
+	}
+
+	if ((snet_ticket_mode == SNET_TICKET_FIX ||
+	    snet_ticket_mode == SNET_TICKET_EXTEND) &&
+	    (snet_ticket_delay == 0)) {
+		printk(KERN_ERR "snet: bad snet_ticket_delay\n");
+		return -EINVAL;
+	}
+
+	/* snet_ticket_cachep is not destroyed */
+	snet_ticket_cachep = kmem_cache_create("snet_ticket",
+					       sizeof(struct snet_ticket),
+					       0, SLAB_PANIC, NULL);
+	/* snet_task_security_cachep is not destroyed */
+	snet_task_security_cachep = kmem_cache_create("snet_task_security",
+						      sizeof(struct snet_task_security),
+						      0, SLAB_PANIC, NULL);
+
+	tsec = kmem_cache_zalloc(snet_task_security_cachep, GFP_KERNEL);
+	if (tsec == NULL)
+		return -ENOMEM;
+
+	rwlock_init(&tsec->lock);
+	for (index = 0; index < HSIZE; index++)
+		INIT_LIST_HEAD(&tsec->hash[index]);
+
+	cred->security = tsec;
+	return 0;
+}
diff --git a/security/snet/snet_ticket.h b/security/snet/snet_ticket.h
new file mode 100644
index 0000000..b6d1020
--- /dev/null
+++ b/security/snet/snet_ticket.h
@@ -0,0 +1,37 @@
+#ifndef _SNET_TICKET_H
+#define _SNET_TICKET_H
+
+#include <linux/timer.h>
+#include <linux/list.h>
+#include <linux/cred.h>
+#include <linux/snet.h>
+
+struct snet_task_security {
+	struct list_head hash[16];
+	rwlock_t lock;
+};
+
+struct snet_ticket {
+	struct list_head list;
+	struct snet_task_security *tsec;
+	struct timer_list timeout;
+
+	enum snet_syscall syscall;
+	u8 protocol;
+	u8 family;
+	int type;
+	struct snet_sock_half src;
+	struct snet_sock_half dst;
+	enum snet_verdict verdict;
+};
+
+extern unsigned int snet_ticket_delay;
+extern unsigned int snet_ticket_mode;
+
+void snet_cred_free(struct cred *cred);
+int snet_prepare_creds(struct cred *new, const struct cred *old, gfp_t gfp);
+enum snet_verdict snet_ticket_check(struct snet_info *info);
+void snet_ticket_create(struct snet_info *info, enum snet_verdict verdict);
+int snet_ticket_init(void);
+
+#endif	/* _SNET_TICKET_H */
diff --git a/security/snet/snet_ticket_helper.c b/security/snet/snet_ticket_helper.c
new file mode 100644
index 0000000..2dc9b94
--- /dev/null
+++ b/security/snet/snet_ticket_helper.c
@@ -0,0 +1,127 @@
+#include <linux/sched.h>
+#include <linux/socket.h>
+#include <linux/snet.h>
+#include "snet_ticket.h"
+#include "snet_utils.h"
+
+static int check_create(struct snet_ticket *st, struct snet_info *info)
+{
+	return (st->type == info->type);
+}
+
+static int check_src(struct snet_ticket *st, struct snet_info *info)
+{
+	switch (info->family) {
+	case AF_INET:
+		if ((st->src.u3.ip == info->src.u3.ip) &&
+		    (st->src.u.port == info->src.u.port))
+			return 1;
+		break;
+	case AF_INET6:
+		if ((!memcmp(&st->src.u3.ip6, &info->src.u3.ip6,
+			     sizeof(info->src.u3.ip6))) &&
+		    (st->src.u.port == info->src.u.port))
+			return 1;
+		break;
+	default:
+		break;
+	}
+	return 0;
+}
+
+static int check_dst(struct snet_ticket *st, struct snet_info *info)
+{
+	switch (info->family) {
+	case AF_INET:
+		if ((st->dst.u3.ip == info->dst.u3.ip) &&
+		    (st->dst.u.port == info->dst.u.port))
+			return 1;
+		break;
+	case AF_INET6:
+		if ((!memcmp(&st->dst.u3.ip6, &info->dst.u3.ip6,
+			     sizeof(info->dst.u3.ip6))) &&
+		    (st->dst.u.port == info->dst.u.port))
+			return 1;
+		break;
+	default:
+		break;
+	}
+	return 0;
+}
+
+static int check_src_and_dst(struct snet_ticket *st, struct snet_info *info)
+{
+	return (check_src(st, info) && check_dst(st, info));
+}
+
+static int check_none(struct snet_ticket *st, struct snet_info *info)
+{
+	return 0;
+}
+
+int __ticket_check(struct snet_ticket *st, struct snet_info *info)
+{
+	static int (*ticket_df[])(struct snet_ticket *, struct snet_info *) = {
+		[SNET_SOCKET_CREATE]		= &check_create,
+		[SNET_SOCKET_BIND]		= &check_src,
+		[SNET_SOCKET_CONNECT]		= &check_dst,
+		[SNET_SOCKET_LISTEN]		= &check_src,
+		[SNET_SOCKET_ACCEPT]		= &check_src,
+		[SNET_SOCKET_POST_ACCEPT]	= &check_none,
+		[SNET_SOCKET_SENDMSG]		= &check_src_and_dst,
+		[SNET_SOCKET_RECVMSG]		= &check_src_and_dst,
+		[SNET_SOCKET_SOCK_RCV_SKB]	= &check_src_and_dst,
+		[SNET_SOCKET_CLOSE]		= &check_none,
+	};
+
+	if (info->syscall >= SNET_NR_SOCKET_TYPES)
+		return 0;
+	else {
+		if ((st->syscall == info->syscall) &&
+		    (st->protocol == info->protocol) &&
+		    (st->family == info->family) &&
+		    ticket_df[info->syscall](st, info))
+			return 1;
+		else
+			return 0;
+	}
+}
+
+void snet_ticket_fill(struct snet_ticket *st, struct snet_info *info,
+		      enum snet_verdict verdict)
+{
+	st->syscall = info->syscall;
+	st->protocol = info->protocol;
+	st->family = info->family;
+	st->src.u.port = info->src.u.port;
+	st->dst.u.port = info->dst.u.port;
+	st->verdict = verdict;
+
+	switch (info->family) {
+	case AF_INET:
+		st->src.u3.ip = info->src.u3.ip;
+		st->dst.u3.ip = info->dst.u3.ip;
+		pr_debug("ticket=%p [syscall=%s protocol=%u "
+			 "family=%u %pI4:%u->%pI4:%u] verdict=%s | tsec=%p pid=%u\n",
+			 st, snet_syscall_name(st->syscall), st->protocol,
+			 st->family, &st->src.u3.ip, st->src.u.port,
+			 &st->dst.u3.ip, st->dst.u.port,
+			 snet_verdict_name(st->verdict), st->tsec, current->pid);
+		break;
+	case AF_INET6:
+		memcpy(&st->src.u3.ip6, &info->src.u3.ip6,
+		       sizeof(info->src.u3.ip6));
+		memcpy(&st->dst.u3.ip6, &info->dst.u3.ip6,
+		       sizeof(info->dst.u3.ip6));
+		pr_debug("ticket=%p [syscall=%s protocol=%u "
+			 "family=%u %pI6:%u->%pI6:%u] verdict=%s | tsec=%p pid=%u\n",
+			 st, snet_syscall_name(st->syscall), st->protocol,
+			 st->family, &st->src.u3.ip6, st->src.u.port,
+			 &st->dst.u3.ip6, st->dst.u.port,
+			 snet_verdict_name(st->verdict), st->tsec, current->pid);
+		break;
+	default:
+		break;
+	}
+	return;
+}
diff --git a/security/snet/snet_ticket_helper.h b/security/snet/snet_ticket_helper.h
new file mode 100644
index 0000000..177bca5
--- /dev/null
+++ b/security/snet/snet_ticket_helper.h
@@ -0,0 +1,8 @@
+#ifndef _SNET_TICKET_HELPER_H
+#define _SNET_TICKET_HELPER_H
+
+void snet_ticket_fill(struct snet_ticket *st, struct snet_info *info,
+		      enum snet_verdict verdict);
+int __ticket_check(struct snet_ticket *st, struct snet_info *info);
+
+#endif	/* _SNET_TICKET_HELPER_H */
-- 
1.7.4.1

