From: Samir Bellabes <sam@synack.fr>
Subject: [RFC v2 05/10] snet: introduce snet_event
Date: Tue,  2 Mar 2010 21:23:09 +0100
Message-ID: <1267561394-13626-6-git-send-email-sam@synack.fr>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bob75-7-88-160-5-175.fbx.proxad.net ([88.160.5.175]:38866 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263Ab0CBUaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 15:30:24 -0500
In-Reply-To: <1267561394-13626-1-git-send-email-sam@synack.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the snet's subsystem responsive of managing events

snet is using the word 'event' for a couple of values [syscall, protocol].
For example, [listen, tcp] or [sendmsg, dccp] are events.

This patch introduces a hastable 'event_hash' and operations (add/remove/search..)
in order to manage which events have to be protected.
With the help of the communication's subsystem, managing orders are coming from
userspace.

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/snet_event.c |  189 ++++++++++++++++++++++++++++++++++++++++++++
 security/snet/snet_event.h |   21 +++++
 2 files changed, 210 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/snet_event.c
 create mode 100644 security/snet/snet_event.h

diff --git a/security/snet/snet_event.c b/security/snet/snet_event.c
new file mode 100644
index 0000000..9e3f7d2
--- /dev/null
+++ b/security/snet/snet_event.c
@@ -0,0 +1,189 @@
+#include <linux/spinlock.h>
+#include <linux/list.h>
+#include <linux/jhash.h>
+#include <linux/slab.h>
+#include <linux/netlink.h>
+#include <linux/snet.h>
+#include "snet_event.h"
+#include "snet_netlink.h"
+#include "snet_utils.h"
+
+static struct list_head *snet_evh;
+static rwlock_t snet_evh_lock = __RW_LOCK_UNLOCKED();
+
+struct snet_event_entry {
+	struct list_head list;
+	struct snet_event se;
+};
+
+/* lookup for a snet_evh - before using this function, lock snet_evh_lock */
+static struct snet_event_entry *__snet_event_lookup(const enum snet_syscall syscall,
+						    const u8 protocol)
+{
+	unsigned int h = 0;
+	struct list_head *l;
+	struct snet_event_entry *s;
+
+	/* computing its hash value */
+	h = jhash_2words(syscall, protocol, 0) % snet_evh_size;
+	l = &snet_evh[h];
+
+	list_for_each_entry(s, l, list) {
+		if ((s->se.protocol == protocol) &&
+		    (s->se.syscall == syscall)) {
+			return s;
+		}
+	}
+	return NULL;
+}
+
+int snet_event_fill_info(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	unsigned int i = 0, n = 0;
+	int ret = -1;
+	unsigned hashs_to_skip = cb->args[0];
+	unsigned events_to_skip = cb->args[1];
+	struct list_head *l;
+	struct snet_event_entry *s;
+
+	read_lock_bh(&snet_evh_lock);
+
+	for (i = 0; i < snet_evh_size; i++) {
+		if (i < hashs_to_skip)
+			continue;
+		l = &snet_evh[i];
+		n = 0;
+		list_for_each_entry(s, l, list) {
+			if (++n < events_to_skip)
+				continue;
+			ret = snet_nl_list_fill_info(skb,
+						     NETLINK_CB(cb->skb).pid,
+						     cb->nlh->nlmsg_seq,
+						     NLM_F_MULTI,
+						     s->se.protocol,
+						     s->se.syscall);
+			if (ret < 0)
+				goto errout;
+		}
+	}
+
+errout:
+	read_unlock_bh(&snet_evh_lock);
+
+	cb->args[0] = i;
+	cb->args[1] = n;
+	return skb->len;
+}
+
+/*
+ * check if a event is registered or not
+ * return 1 if event is registered, 0 if not
+ */
+int snet_event_is_registered(const enum snet_syscall syscall, const u8 protocol)
+{
+	int ret = 0;
+
+	read_lock_bh(&snet_evh_lock);
+	if (__snet_event_lookup(syscall, protocol) != NULL)
+		ret = 1;
+	read_unlock_bh(&snet_evh_lock);
+	return ret;
+}
+
+/* adding a event */
+int snet_event_insert(const enum snet_syscall syscall, const u8 protocol)
+{
+	struct snet_event_entry *data = NULL;
+	unsigned int h = 0;
+	int err = 0;
+
+	data = kzalloc(sizeof(struct snet_event_entry), GFP_KERNEL);
+	if (!data) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	write_lock_bh(&snet_evh_lock);
+	/* check if event is already registered */
+	if (__snet_event_lookup(syscall, protocol) != NULL) {
+		write_unlock_bh(&snet_evh_lock);
+		kfree(data);
+		err = -EINVAL;
+		goto out;
+	}
+
+	data->se.syscall = syscall;
+	data->se.protocol = protocol;
+	INIT_LIST_HEAD(&(data->list));
+	h = jhash_2words(data->se.syscall, data->se.protocol, 0) % snet_evh_size;
+	list_add_tail(&data->list, &snet_evh[h]);
+	write_unlock_bh(&snet_evh_lock);
+	pr_debug("[%u]=(syscall=%s, protocol=%u)\n",
+		 h, snet_syscall_name(syscall), protocol);
+out:
+	return err;
+}
+
+/* removing a event */
+int snet_event_remove(const enum snet_syscall syscall, const u8 protocol)
+{
+	struct snet_event_entry *data = NULL;
+
+	write_lock_bh(&snet_evh_lock);
+	data = __snet_event_lookup(syscall, protocol);
+	if (data == NULL) {
+		write_unlock_bh(&snet_evh_lock);
+		return -EINVAL;
+	}
+	pr_debug("(syscall=%s, protocol=%u)\n",
+		 snet_syscall_name(syscall), protocol);
+	list_del(&data->list);
+	write_unlock_bh(&snet_evh_lock);
+	kfree(data);
+	return 0;
+}
+
+/* flushing all events */
+void snet_event_flush(void)
+{
+	unsigned int i = 0;
+
+	write_lock_bh(&snet_evh_lock);
+	for (i = 0; i < snet_evh_size; i++) {
+		struct snet_event_entry *data, *tmp;
+		list_for_each_entry_safe(data, tmp, &snet_evh[i], list) {
+			list_del(&data->list);
+			kfree(data);
+		}
+	}
+	write_unlock_bh(&snet_evh_lock);
+	return;
+}
+
+/* init function */
+int snet_event_init(void)
+{
+	int err = 0, i = 0;
+
+	snet_evh = kzalloc(sizeof(struct list_head) * snet_evh_size,
+			     GFP_KERNEL);
+	if (!snet_evh) {
+		printk(KERN_WARNING
+		       "snet: can't alloc memory for snet_evh\n");
+		err = -ENOMEM;
+		goto out;
+	}
+
+	for (i = 0; i < snet_evh_size; i++)
+		INIT_LIST_HEAD(&snet_evh[i]);
+
+out:
+	return err;
+}
+
+/* exit function */
+void snet_event_exit(void)
+{
+	kfree(snet_evh);
+	snet_evh = NULL;
+}
diff --git a/security/snet/snet_event.h b/security/snet/snet_event.h
new file mode 100644
index 0000000..fa991c7
--- /dev/null
+++ b/security/snet/snet_event.h
@@ -0,0 +1,21 @@
+#ifndef _SNET_EVENT_H
+#define _SNET_EVENT_H
+
+#include <linux/skbuff.h>
+
+extern unsigned int snet_evh_size;
+
+/* manipulate the events hash table */
+int snet_event_fill_info(struct sk_buff *skb, struct netlink_callback *cb);
+int snet_event_is_registered(const enum snet_syscall syscall, const u8 protocol);
+int snet_event_insert(const enum snet_syscall syscall, const u8 protocol);
+int snet_event_remove(const enum snet_syscall syscall, const u8 protocol);
+void snet_event_flush(void);
+void snet_event_dumpall(void);
+
+/* init function */
+int snet_event_init(void);
+/* exit funtion */
+void snet_event_exit(void);
+
+#endif /* _SNET_EVENT_H */
-- 
1.6.3.3

