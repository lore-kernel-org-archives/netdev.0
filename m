From: Tom Herbert <therbert@google.com>
Subject: [PATCH] ip_tunnel: Ops registration for secondary encap (fou, gue)
Date: Wed, 12 Nov 2014 11:54:09 -0800
Message-ID: <1415822049-24978-1-git-send-email-therbert@google.com>
Cc: rdunlap@infradead.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:64302 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234AbaKLTy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 14:54:26 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so13824777iec.7
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 11:54:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of calling fou and gue functions directly from ip_tunnel
use ops for these that were previously registered. This patch adds the
logic to add and remove encapsulation operations for ip_tunnel,
and modified fou (and gue) to register with ip_tunnels.

This patch also addresses a circular dependency between ip_tunnel
and fou that was causing link errors when CONFIG_NET_IP_TUNNEL=y
and CONFIG_NET_FOU=m. References to fou an gue have been removed from
ip_tunnel.c

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/fou.h        | 25 ++------------
 include/net/ip_tunnels.h | 16 +++++++++
 net/ipv4/fou.c           | 85 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_tunnel.c     | 78 ++++++++++++++++++++++++++++++--------------
 4 files changed, 157 insertions(+), 47 deletions(-)

diff --git a/include/net/fou.h b/include/net/fou.h
index 25b26ff..19b8a0c 100644
--- a/include/net/fou.h
+++ b/include/net/fou.h
@@ -8,31 +8,12 @@
 #include <net/ip_tunnels.h>
 #include <net/udp.h>
 
+size_t fou_encap_hlen(struct ip_tunnel_encap *e);
+static size_t gue_encap_hlen(struct ip_tunnel_encap *e);
+
 int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		     u8 *protocol, struct flowi4 *fl4);
 int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		     u8 *protocol, struct flowi4 *fl4);
 
-static size_t fou_encap_hlen(struct ip_tunnel_encap *e)
-{
-	return sizeof(struct udphdr);
-}
-
-static size_t gue_encap_hlen(struct ip_tunnel_encap *e)
-{
-	size_t len;
-	bool need_priv = false;
-
-	len = sizeof(struct udphdr) + sizeof(struct guehdr);
-
-	if (e->flags & TUNNEL_ENCAP_FLAG_REMCSUM) {
-		len += GUE_PLEN_REMCSUM;
-		need_priv = true;
-	}
-
-	len += need_priv ? GUE_LEN_PRIV : 0;
-
-	return len;
-}
-
 #endif
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 5bc6ede..25a59eb 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -117,6 +117,22 @@ struct ip_tunnel_net {
 	struct hlist_head tunnels[IP_TNL_HASH_SIZE];
 };
 
+struct ip_tunnel_encap_ops {
+	size_t (*encap_hlen)(struct ip_tunnel_encap *e);
+	int (*build_header)(struct sk_buff *skb, struct ip_tunnel_encap *e,
+			    u8 *protocol, struct flowi4 *fl4);
+};
+
+#define MAX_IPTUN_ENCAP_OPS 8
+
+extern const struct ip_tunnel_encap_ops __rcu *
+		iptun_encaps[MAX_IPTUN_ENCAP_OPS];
+
+int ip_tunnel_encap_add_ops(const struct ip_tunnel_encap_ops *op,
+			    unsigned int num);
+int ip_tunnel_encap_del_ops(const struct ip_tunnel_encap_ops *op,
+			    unsigned int num);
+
 #ifdef CONFIG_INET
 
 int ip_tunnel_init(struct net_device *dev);
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 740ae09..fe09077 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -668,6 +668,30 @@ static const struct genl_ops fou_nl_ops[] = {
 	},
 };
 
+size_t fou_encap_hlen(struct ip_tunnel_encap *e)
+{
+	return sizeof(struct udphdr);
+}
+EXPORT_SYMBOL(fou_encap_hlen);
+
+size_t gue_encap_hlen(struct ip_tunnel_encap *e)
+{
+	size_t len;
+	bool need_priv = false;
+
+	len = sizeof(struct udphdr) + sizeof(struct guehdr);
+
+	if (e->flags & TUNNEL_ENCAP_FLAG_REMCSUM) {
+		len += GUE_PLEN_REMCSUM;
+		need_priv = true;
+	}
+
+	len += need_priv ? GUE_LEN_PRIV : 0;
+
+	return len;
+}
+EXPORT_SYMBOL(gue_encap_hlen);
+
 static void fou_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
 			  struct flowi4 *fl4, u8 *protocol, __be16 sport)
 {
@@ -787,6 +811,57 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 }
 EXPORT_SYMBOL(gue_build_header);
 
+#ifdef CONFIG_NET_FOU_IP_TUNNELS
+
+static const struct ip_tunnel_encap_ops __read_mostly fou_iptun_ops = {
+	.encap_hlen = fou_encap_hlen,
+	.build_header = fou_build_header,
+};
+
+static const struct ip_tunnel_encap_ops __read_mostly gue_iptun_ops = {
+	.encap_hlen = gue_encap_hlen,
+	.build_header = gue_build_header,
+};
+
+static int ip_tunnel_encap_add_fou_ops(void)
+{
+	int ret;
+
+	ret = ip_tunnel_encap_add_ops(&fou_iptun_ops, TUNNEL_ENCAP_FOU);
+	if (ret < 0) {
+		pr_err("can't add fou ops\n");
+		return ret;
+	}
+
+	ret = ip_tunnel_encap_add_ops(&gue_iptun_ops, TUNNEL_ENCAP_GUE);
+	if (ret < 0) {
+		pr_err("can't add gue ops\n");
+		ip_tunnel_encap_del_ops(&fou_iptun_ops, TUNNEL_ENCAP_FOU);
+		return ret;
+	}
+
+	return 0;
+}
+
+static void ip_tunnel_encap_del_fou_ops(void)
+{
+	ip_tunnel_encap_del_ops(&fou_iptun_ops, TUNNEL_ENCAP_FOU);
+	ip_tunnel_encap_del_ops(&gue_iptun_ops, TUNNEL_ENCAP_GUE);
+}
+
+#else
+
+static int ip_tunnel_encap_add_fou_ops(void)
+{
+	return 0;
+}
+
+static int ip_tunnel_encap_del_fou_ops(void)
+{
+}
+
+#endif
+
 static int __init fou_init(void)
 {
 	int ret;
@@ -794,6 +869,14 @@ static int __init fou_init(void)
 	ret = genl_register_family_with_ops(&fou_nl_family,
 					    fou_nl_ops);
 
+	if (ret < 0)
+		goto exit;
+
+	ret = ip_tunnel_encap_add_fou_ops();
+	if (ret < 0)
+		genl_unregister_family(&fou_nl_family);
+
+exit:
 	return ret;
 }
 
@@ -801,6 +884,8 @@ static void __exit fou_fini(void)
 {
 	struct fou *fou, *next;
 
+	ip_tunnel_encap_del_fou_ops();
+
 	genl_unregister_family(&fou_nl_family);
 
 	/* Close all the FOU sockets */
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index c3587e1..63e745a 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -57,10 +57,6 @@
 #include <net/rtnetlink.h>
 #include <net/udp.h>
 
-#if IS_ENABLED(CONFIG_NET_FOU)
-#include <net/fou.h>
-#endif
-
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
@@ -494,19 +490,50 @@ EXPORT_SYMBOL_GPL(ip_tunnel_rcv);
 
 static int ip_encap_hlen(struct ip_tunnel_encap *e)
 {
-	switch (e->type) {
-	case TUNNEL_ENCAP_NONE:
+	const struct ip_tunnel_encap_ops *ops;
+	int hlen = -EINVAL;
+
+	if (e->type == TUNNEL_ENCAP_NONE)
 		return 0;
-#if IS_ENABLED(CONFIG_NET_FOU)
-	case TUNNEL_ENCAP_FOU:
-		return fou_encap_hlen(e);
-	case TUNNEL_ENCAP_GUE:
-		return gue_encap_hlen(e);
-#endif
-	default:
+
+	if (e->type >= MAX_IPTUN_ENCAP_OPS)
 		return -EINVAL;
-	}
+
+	rcu_read_lock();
+	ops = rcu_dereference(iptun_encaps[e->type]);
+	if (likely(ops && ops->encap_hlen))
+		hlen = ops->encap_hlen(e);
+	rcu_read_unlock();
+
+	return hlen;
+}
+
+const struct ip_tunnel_encap_ops __rcu *
+		iptun_encaps[MAX_IPTUN_ENCAP_OPS] __read_mostly;
+
+int ip_tunnel_encap_add_ops(const struct ip_tunnel_encap_ops *ops,
+			    unsigned int num)
+{
+	return !cmpxchg((const struct ip_tunnel_encap_ops **)
+			&iptun_encaps[num],
+			NULL, ops) ? 0 : -1;
 }
+EXPORT_SYMBOL(ip_tunnel_encap_add_ops);
+
+int ip_tunnel_encap_del_ops(const struct ip_tunnel_encap_ops *ops,
+			    unsigned int num)
+{
+	int ret;
+
+	ret = (cmpxchg((const struct ip_tunnel_encap_ops **)
+		       &iptun_encaps[num],
+		       ops, NULL) == ops) ? 0 : -1;
+
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL(ip_tunnel_encap_del_ops);
 
 int ip_tunnel_encap_setup(struct ip_tunnel *t,
 			  struct ip_tunnel_encap *ipencap)
@@ -534,18 +561,19 @@ EXPORT_SYMBOL_GPL(ip_tunnel_encap_setup);
 int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
 		    u8 *protocol, struct flowi4 *fl4)
 {
-	switch (t->encap.type) {
-	case TUNNEL_ENCAP_NONE:
+	const struct ip_tunnel_encap_ops *ops;
+	int ret = -EINVAL;
+
+	if (t->encap.type == TUNNEL_ENCAP_NONE)
 		return 0;
-#if IS_ENABLED(CONFIG_NET_FOU)
-	case TUNNEL_ENCAP_FOU:
-		return fou_build_header(skb, &t->encap, protocol, fl4);
-	case TUNNEL_ENCAP_GUE:
-		return gue_build_header(skb, &t->encap, protocol, fl4);
-#endif
-	default:
-		return -EINVAL;
-	}
+
+	rcu_read_lock();
+	ops = rcu_dereference(iptun_encaps[t->encap.type]);
+	if (likely(ops && ops->build_header))
+		ret = ops->build_header(skb, &t->encap, protocol, fl4);
+	rcu_read_unlock();
+
+	return ret;
 }
 EXPORT_SYMBOL(ip_tunnel_encap);
 
-- 
2.1.0.rc2.206.gedb03e5
