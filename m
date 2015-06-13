From: sfeldma@gmail.com
Subject: [RFC PATCH net-next 2/4] switchdev: add fwd_mark generator helper
Date: Sat, 13 Jun 2015 11:04:28 -0700
Message-ID: <1434218670-43821-3-git-send-email-sfeldma@gmail.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	roopa@cumulusnetworks.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:36696 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbbFMSCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 14:02:40 -0400
Received: by iecrd14 with SMTP id rd14so9497054iec.3
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2015 11:02:39 -0700 (PDT)
In-Reply-To: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

skb->fwd_mark and dev->fwd_mark are 32-bit and should be unique for device
and maybe even unique for a sub-set of ports within device, so add
switchdev helper function to generate unique marks based on driver-supplied
key.  Typically, the driver would use device switch ID for key, and maybe
additional fields in key for grouped ports such as bridge ifindex.  The key
can be of arbitrary length.

The generator uses a global hash table to store fwd_marks hashed by key.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |    6 ++++
 net/switchdev/switchdev.c |   72 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 78 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 437f8fe..6eaceee 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -157,6 +157,7 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *dev,
 			    struct net_device *filter_dev, int idx);
+u32 switchdev_mark_get(void *key, size_t key_len);
 
 #else
 
@@ -271,6 +272,11 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
 	return -EOPNOTSUPP;
 }
 
+static inline u32 switchdev_mark_get(void *key, size_t key_len)
+{
+	return 0;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index a5d0f8e..9ca37b3 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -16,6 +16,8 @@
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
 #include <linux/if_bridge.h>
+#include <linux/hashtable.h>
+#include <linux/crc32.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
@@ -924,3 +926,73 @@ void switchdev_fib_ipv4_abort(struct fib_info *fi)
 	fi->fib_net->ipv4.fib_offload_disabled = true;
 }
 EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_abort);
+
+#define SWITCHDEV_MARK_HT_BITS	5
+static DEFINE_HASHTABLE(switchdev_mark_ht, SWITCHDEV_MARK_HT_BITS);
+static DEFINE_SPINLOCK(switchdev_mark_lock);
+static u32 switchdev_mark_next = 1;
+
+/**
+ *	switchdev_mark_get - Generate a unique mark for key
+ *
+ *	@key: key used to generate mark
+ *	@key_len: length of key in bytes
+ *
+ *	Returns unqiue 32-bit mark for given key, or 0 if error.
+ *	A small global hash table stores the marks for each key.
+ *	The length of the key and key contents are arbitrary.
+ *	The marks can be used, for example, to skb->fwd_mark a pkt
+ *	to associate the skb with a key.
+ */
+u32 switchdev_mark_get(void *key, size_t key_len)
+{
+	struct switchdev_mark_ht_entry {
+		struct hlist_node entry;
+		void *key;
+		size_t key_len;
+		u32 key_crc32;
+		u32 mark;
+	} *entry;
+	u32 key_crc32 = crc32(~0, key, key_len);
+	u32 mark = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&switchdev_mark_lock, flags);
+	hash_for_each_possible(switchdev_mark_ht, entry,
+			       entry, key_crc32) {
+		if (entry->key_len != key_len)
+			continue;
+		if (memcmp(entry->key, key, key_len) == 0) {
+			mark = entry->mark;
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&switchdev_mark_lock, flags);
+
+	if (mark)
+		goto out;
+
+	entry = kmalloc(GFP_KERNEL, sizeof(*entry));
+	if (!entry)
+		goto out;
+
+	entry->key = kmalloc(GFP_KERNEL, key_len);
+	if (!entry->key) {
+		kfree(entry);
+		goto out;
+	}
+
+	memcpy(entry->key, key, key_len);
+	entry->key_len = key_len;
+	entry->key_crc32 = key_crc32;
+
+	spin_lock_irqsave(&switchdev_mark_lock, flags);
+	mark = switchdev_mark_next++;
+	entry->mark = mark;
+	hash_add(switchdev_mark_ht, &entry->entry, key_crc32);
+	spin_unlock_irqrestore(&switchdev_mark_lock, flags);
+
+out:
+	return mark;
+}
+EXPORT_SYMBOL_GPL(switchdev_mark_get);
-- 
1.7.10.4
