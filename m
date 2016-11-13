From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/39] netfilter: ipset: Split extensions into separate files
Date: Sun, 13 Nov 2016 23:25:15 +0100
Message-ID: <1479075933-4491-22-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47678 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965079AbcKMW0S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:18 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 8B06FB6C79
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7D46BDA863
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 54D50DA851
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:15 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Cleanup to separate all extensions into individual files.

Ported from a patch proposed by Sergey Popovich <popovich_sergei@mail.ua>.

Suggested-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h         | 95 +-------------------------
 include/linux/netfilter/ipset/ip_set_counter.h | 75 ++++++++++++++++++++
 include/linux/netfilter/ipset/ip_set_skbinfo.h | 46 +++++++++++++
 3 files changed, 123 insertions(+), 93 deletions(-)
 create mode 100644 include/linux/netfilter/ipset/ip_set_counter.h
 create mode 100644 include/linux/netfilter/ipset/ip_set_skbinfo.h

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 780262124632..b5bd0fb3d07b 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -292,99 +292,6 @@ ip_set_put_flags(struct sk_buff *skb, struct ip_set *set)
 	return nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(cadt_flags));
 }
 
-static inline void
-ip_set_add_bytes(u64 bytes, struct ip_set_counter *counter)
-{
-	atomic64_add((long long)bytes, &(counter)->bytes);
-}
-
-static inline void
-ip_set_add_packets(u64 packets, struct ip_set_counter *counter)
-{
-	atomic64_add((long long)packets, &(counter)->packets);
-}
-
-static inline u64
-ip_set_get_bytes(const struct ip_set_counter *counter)
-{
-	return (u64)atomic64_read(&(counter)->bytes);
-}
-
-static inline u64
-ip_set_get_packets(const struct ip_set_counter *counter)
-{
-	return (u64)atomic64_read(&(counter)->packets);
-}
-
-static inline void
-ip_set_update_counter(struct ip_set_counter *counter,
-		      const struct ip_set_ext *ext,
-		      struct ip_set_ext *mext, u32 flags)
-{
-	if (ext->packets != ULLONG_MAX &&
-	    !(flags & IPSET_FLAG_SKIP_COUNTER_UPDATE)) {
-		ip_set_add_bytes(ext->bytes, counter);
-		ip_set_add_packets(ext->packets, counter);
-	}
-	if (flags & IPSET_FLAG_MATCH_COUNTERS) {
-		mext->packets = ip_set_get_packets(counter);
-		mext->bytes = ip_set_get_bytes(counter);
-	}
-}
-
-static inline bool
-ip_set_put_counter(struct sk_buff *skb, const struct ip_set_counter *counter)
-{
-	return nla_put_net64(skb, IPSET_ATTR_BYTES,
-			     cpu_to_be64(ip_set_get_bytes(counter)),
-			     IPSET_ATTR_PAD) ||
-	       nla_put_net64(skb, IPSET_ATTR_PACKETS,
-			     cpu_to_be64(ip_set_get_packets(counter)),
-			     IPSET_ATTR_PAD);
-}
-
-static inline void
-ip_set_init_counter(struct ip_set_counter *counter,
-		    const struct ip_set_ext *ext)
-{
-	if (ext->bytes != ULLONG_MAX)
-		atomic64_set(&(counter)->bytes, (long long)(ext->bytes));
-	if (ext->packets != ULLONG_MAX)
-		atomic64_set(&(counter)->packets, (long long)(ext->packets));
-}
-
-static inline void
-ip_set_get_skbinfo(struct ip_set_skbinfo *skbinfo,
-		   const struct ip_set_ext *ext,
-		   struct ip_set_ext *mext, u32 flags)
-{
-	mext->skbinfo = *skbinfo;
-}
-
-static inline bool
-ip_set_put_skbinfo(struct sk_buff *skb, const struct ip_set_skbinfo *skbinfo)
-{
-	/* Send nonzero parameters only */
-	return ((skbinfo->skbmark || skbinfo->skbmarkmask) &&
-		nla_put_net64(skb, IPSET_ATTR_SKBMARK,
-			      cpu_to_be64((u64)skbinfo->skbmark << 32 |
-					  skbinfo->skbmarkmask),
-			      IPSET_ATTR_PAD)) ||
-	       (skbinfo->skbprio &&
-		nla_put_net32(skb, IPSET_ATTR_SKBPRIO,
-			      cpu_to_be32(skbinfo->skbprio))) ||
-	       (skbinfo->skbqueue &&
-		nla_put_net16(skb, IPSET_ATTR_SKBQUEUE,
-			     cpu_to_be16(skbinfo->skbqueue)));
-}
-
-static inline void
-ip_set_init_skbinfo(struct ip_set_skbinfo *skbinfo,
-		    const struct ip_set_ext *ext)
-{
-	*skbinfo = ext->skbinfo;
-}
-
 /* Netlink CB args */
 enum {
 	IPSET_CB_NET = 0,	/* net namespace */
@@ -539,6 +446,8 @@ bitmap_bytes(u32 a, u32 b)
 
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_comment.h>
+#include <linux/netfilter/ipset/ip_set_counter.h>
+#include <linux/netfilter/ipset/ip_set_skbinfo.h>
 
 int
 ip_set_put_extensions(struct sk_buff *skb, const struct ip_set *set,
diff --git a/include/linux/netfilter/ipset/ip_set_counter.h b/include/linux/netfilter/ipset/ip_set_counter.h
new file mode 100644
index 000000000000..bb6fba480118
--- /dev/null
+++ b/include/linux/netfilter/ipset/ip_set_counter.h
@@ -0,0 +1,75 @@
+#ifndef _IP_SET_COUNTER_H
+#define _IP_SET_COUNTER_H
+
+/* Copyright (C) 2015 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifdef __KERNEL__
+
+static inline void
+ip_set_add_bytes(u64 bytes, struct ip_set_counter *counter)
+{
+	atomic64_add((long long)bytes, &(counter)->bytes);
+}
+
+static inline void
+ip_set_add_packets(u64 packets, struct ip_set_counter *counter)
+{
+	atomic64_add((long long)packets, &(counter)->packets);
+}
+
+static inline u64
+ip_set_get_bytes(const struct ip_set_counter *counter)
+{
+	return (u64)atomic64_read(&(counter)->bytes);
+}
+
+static inline u64
+ip_set_get_packets(const struct ip_set_counter *counter)
+{
+	return (u64)atomic64_read(&(counter)->packets);
+}
+
+static inline void
+ip_set_update_counter(struct ip_set_counter *counter,
+		      const struct ip_set_ext *ext,
+		      struct ip_set_ext *mext, u32 flags)
+{
+	if (ext->packets != ULLONG_MAX &&
+	    !(flags & IPSET_FLAG_SKIP_COUNTER_UPDATE)) {
+		ip_set_add_bytes(ext->bytes, counter);
+		ip_set_add_packets(ext->packets, counter);
+	}
+	if (flags & IPSET_FLAG_MATCH_COUNTERS) {
+		mext->packets = ip_set_get_packets(counter);
+		mext->bytes = ip_set_get_bytes(counter);
+	}
+}
+
+static inline bool
+ip_set_put_counter(struct sk_buff *skb, const struct ip_set_counter *counter)
+{
+	return nla_put_net64(skb, IPSET_ATTR_BYTES,
+			     cpu_to_be64(ip_set_get_bytes(counter)),
+			     IPSET_ATTR_PAD) ||
+	       nla_put_net64(skb, IPSET_ATTR_PACKETS,
+			     cpu_to_be64(ip_set_get_packets(counter)),
+			     IPSET_ATTR_PAD);
+}
+
+static inline void
+ip_set_init_counter(struct ip_set_counter *counter,
+		    const struct ip_set_ext *ext)
+{
+	if (ext->bytes != ULLONG_MAX)
+		atomic64_set(&(counter)->bytes, (long long)(ext->bytes));
+	if (ext->packets != ULLONG_MAX)
+		atomic64_set(&(counter)->packets, (long long)(ext->packets));
+}
+
+#endif /* __KERNEL__ */
+#endif /* _IP_SET_COUNTER_H */
diff --git a/include/linux/netfilter/ipset/ip_set_skbinfo.h b/include/linux/netfilter/ipset/ip_set_skbinfo.h
new file mode 100644
index 000000000000..29d7ef2bc3fa
--- /dev/null
+++ b/include/linux/netfilter/ipset/ip_set_skbinfo.h
@@ -0,0 +1,46 @@
+#ifndef _IP_SET_SKBINFO_H
+#define _IP_SET_SKBINFO_H
+
+/* Copyright (C) 2015 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifdef __KERNEL__
+
+static inline void
+ip_set_get_skbinfo(struct ip_set_skbinfo *skbinfo,
+		   const struct ip_set_ext *ext,
+		   struct ip_set_ext *mext, u32 flags)
+{
+	mext->skbinfo = *skbinfo;
+}
+
+static inline bool
+ip_set_put_skbinfo(struct sk_buff *skb, const struct ip_set_skbinfo *skbinfo)
+{
+	/* Send nonzero parameters only */
+	return ((skbinfo->skbmark || skbinfo->skbmarkmask) &&
+		nla_put_net64(skb, IPSET_ATTR_SKBMARK,
+			      cpu_to_be64((u64)skbinfo->skbmark << 32 |
+					  skbinfo->skbmarkmask),
+			      IPSET_ATTR_PAD)) ||
+	       (skbinfo->skbprio &&
+		nla_put_net32(skb, IPSET_ATTR_SKBPRIO,
+			      cpu_to_be32(skbinfo->skbprio))) ||
+	       (skbinfo->skbqueue &&
+		nla_put_net16(skb, IPSET_ATTR_SKBQUEUE,
+			      cpu_to_be16(skbinfo->skbqueue)));
+}
+
+static inline void
+ip_set_init_skbinfo(struct ip_set_skbinfo *skbinfo,
+		    const struct ip_set_ext *ext)
+{
+	*skbinfo = ext->skbinfo;
+}
+
+#endif /* __KERNEL__ */
+#endif /* _IP_SET_SKBINFO_H */
-- 
2.1.4
