From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next 2/4] switchdev: add fwd_mark generator helper
Date: Sun, 14 Jun 2015 08:56:02 +0200
Message-ID: <20150614065601.GB2105@nanopsycho.orion>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
 <1434218670-43821-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	roopa@cumulusnetworks.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:35955 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbbFNG4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 02:56:05 -0400
Received: by wgzl5 with SMTP id l5so22519811wgz.3
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2015 23:56:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434218670-43821-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jun 13, 2015 at 08:04:28PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>skb->fwd_mark and dev->fwd_mark are 32-bit and should be unique for device
>and maybe even unique for a sub-set of ports within device, so add
>switchdev helper function to generate unique marks based on driver-supplied
>key.  Typically, the driver would use device switch ID for key, and maybe
>additional fields in key for grouped ports such as bridge ifindex.  The key
>can be of arbitrary length.
>
>The generator uses a global hash table to store fwd_marks hashed by key.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> include/net/switchdev.h   |    6 ++++
> net/switchdev/switchdev.c |   72 +++++++++++++++++++++++++++++++++++++++++++++
> 2 files changed, 78 insertions(+)
>
>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>index 437f8fe..6eaceee 100644
>--- a/include/net/switchdev.h
>+++ b/include/net/switchdev.h
>@@ -157,6 +157,7 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
> int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
> 			    struct net_device *dev,
> 			    struct net_device *filter_dev, int idx);
>+u32 switchdev_mark_get(void *key, size_t key_len);
> 
> #else
> 
>@@ -271,6 +272,11 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
> 	return -EOPNOTSUPP;
> }
> 
>+static inline u32 switchdev_mark_get(void *key, size_t key_len)
>+{
>+	return 0;
>+}
>+
> #endif
> 
> #endif /* _LINUX_SWITCHDEV_H_ */
>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>index a5d0f8e..9ca37b3 100644
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -16,6 +16,8 @@
> #include <linux/notifier.h>
> #include <linux/netdevice.h>
> #include <linux/if_bridge.h>
>+#include <linux/hashtable.h>
>+#include <linux/crc32.h>
> #include <net/ip_fib.h>
> #include <net/switchdev.h>
> 
>@@ -924,3 +926,73 @@ void switchdev_fib_ipv4_abort(struct fib_info *fi)
> 	fi->fib_net->ipv4.fib_offload_disabled = true;
> }
> EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_abort);
>+
>+#define SWITCHDEV_MARK_HT_BITS	5
>+static DEFINE_HASHTABLE(switchdev_mark_ht, SWITCHDEV_MARK_HT_BITS);
>+static DEFINE_SPINLOCK(switchdev_mark_lock);
>+static u32 switchdev_mark_next = 1;
>+
>+/**
>+ *	switchdev_mark_get - Generate a unique mark for key
>+ *
>+ *	@key: key used to generate mark
>+ *	@key_len: length of key in bytes
>+ *
>+ *	Returns unqiue 32-bit mark for given key, or 0 if error.
                ^^^^^^
		typo.


>+ *	A small global hash table stores the marks for each key.
>+ *	The length of the key and key contents are arbitrary.
>+ *	The marks can be used, for example, to skb->fwd_mark a pkt
>+ *	to associate the skb with a key.
>+ */
>+u32 switchdev_mark_get(void *key, size_t key_len)
>+{
>+	struct switchdev_mark_ht_entry {
>+		struct hlist_node entry;
>+		void *key;
>+		size_t key_len;
>+		u32 key_crc32;
>+		u32 mark;
>+	} *entry;
>+	u32 key_crc32 = crc32(~0, key, key_len);
>+	u32 mark = 0;
>+	unsigned long flags;
>+
>+	spin_lock_irqsave(&switchdev_mark_lock, flags);

I fail to see why _irqsave variant is needed here.
