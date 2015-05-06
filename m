From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] netfilter: ipset: deinline ip_set_put_extensions()
Date: Wed,  6 May 2015 16:28:57 +0200
Message-ID: <1430922537-28428-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On x86 allyesconfig build:
The function compiles to 489 bytes of machine code.
It has 25 callsites.

    text    data       bss       dec     hex filename
82441375 22255384 20627456 125324215 7784bb7 vmlinux.before
82434909 22255384 20627456 125317749 7783275 vmlinux

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
CC: Eric W. Biederman <ebiederm@xmission.com>
CC: David S. Miller <davem@davemloft.net>
CC: Jan Engelhardt <jengelh@medozas.de>
CC: Jiri Pirko <jpirko@redhat.com>
CC: linux-kernel@vger.kernel.org
CC: netdev@vger.kernel.org
CC: netfilter-devel@vger.kernel.org
---
 include/linux/netfilter/ipset/ip_set.h | 24 ++----------------------
 net/netfilter/ipset/ip_set_core.c      | 25 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index f1606fa..bf6e018 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -534,29 +534,9 @@ bitmap_bytes(u32 a, u32 b)
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_comment.h>
 
-static inline int
+int
 ip_set_put_extensions(struct sk_buff *skb, const struct ip_set *set,
-		      const void *e, bool active)
-{
-	if (SET_WITH_TIMEOUT(set)) {
-		unsigned long *timeout = ext_timeout(e, set);
-
-		if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-			htonl(active ? ip_set_timeout_get(timeout)
-				: *timeout)))
-			return -EMSGSIZE;
-	}
-	if (SET_WITH_COUNTER(set) &&
-	    ip_set_put_counter(skb, ext_counter(e, set)))
-		return -EMSGSIZE;
-	if (SET_WITH_COMMENT(set) &&
-	    ip_set_put_comment(skb, ext_comment(e, set)))
-		return -EMSGSIZE;
-	if (SET_WITH_SKBINFO(set) &&
-	    ip_set_put_skbinfo(skb, ext_skbinfo(e, set)))
-		return -EMSGSIZE;
-	return 0;
-}
+		      const void *e, bool active);
 
 #define IP_SET_INIT_KEXT(skb, opt, set)			\
 	{ .bytes = (skb)->len, .packets = 1,		\
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index d259da3..6539b74 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -432,6 +432,31 @@ ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
 }
 EXPORT_SYMBOL_GPL(ip_set_get_extensions);
 
+int
+ip_set_put_extensions(struct sk_buff *skb, const struct ip_set *set,
+		      const void *e, bool active)
+{
+	if (SET_WITH_TIMEOUT(set)) {
+		unsigned long *timeout = ext_timeout(e, set);
+
+		if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			htonl(active ? ip_set_timeout_get(timeout)
+				: *timeout)))
+			return -EMSGSIZE;
+	}
+	if (SET_WITH_COUNTER(set) &&
+	    ip_set_put_counter(skb, ext_counter(e, set)))
+		return -EMSGSIZE;
+	if (SET_WITH_COMMENT(set) &&
+	    ip_set_put_comment(skb, ext_comment(e, set)))
+		return -EMSGSIZE;
+	if (SET_WITH_SKBINFO(set) &&
+	    ip_set_put_skbinfo(skb, ext_skbinfo(e, set)))
+		return -EMSGSIZE;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip_set_put_extensions);
+
 /*
  * Creating/destroying/renaming/swapping affect the existence and
  * the properties of a set. All of these can be executed from userspace
-- 
1.8.1.4
