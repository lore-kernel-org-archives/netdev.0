From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v5 net-next 05/14] net: Cleanup encap items in ip_tunnels.h
Date: Sun, 15 May 2016 16:42:26 -0700
Message-ID: <1463355755-3481375-6-git-send-email-tom@herbertland.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57877 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752204AbcEOXmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 19:42:53 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4FNffEd023655
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:42:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22x03xx35w-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:42:52 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 bcb160601af611e6a12624be0595f910-d34ebc50 for <netdev@vger.kernel.org>;	Sun,
 15 May 2016 16:42:51 -0700
In-Reply-To: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate all the ip_tunnel_encap definitions in one spot in the
header file. Also, move ip_encap_hlen and ip_tunnel_encap from
ip_tunnel.c to ip_tunnels.h so they call be called without a dependency
on ip_tunnel module. Similarly, move iptun_encaps to ip_tunnel_core.c.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ip_tunnels.h  | 76 ++++++++++++++++++++++++++++++++++++-----------
 net/ipv4/ip_tunnel.c      | 45 ----------------------------
 net/ipv4/ip_tunnel_core.c |  4 +++
 3 files changed, 62 insertions(+), 63 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index d916b43..dbf4444 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -171,22 +171,6 @@ struct ip_tunnel_net {
 	struct ip_tunnel __rcu *collect_md_tun;
 };
 
-struct ip_tunnel_encap_ops {
-	size_t (*encap_hlen)(struct ip_tunnel_encap *e);
-	int (*build_header)(struct sk_buff *skb, struct ip_tunnel_encap *e,
-			    u8 *protocol, struct flowi4 *fl4);
-};
-
-#define MAX_IPTUN_ENCAP_OPS 8
-
-extern const struct ip_tunnel_encap_ops __rcu *
-		iptun_encaps[MAX_IPTUN_ENCAP_OPS];
-
-int ip_tunnel_encap_add_ops(const struct ip_tunnel_encap_ops *op,
-			    unsigned int num);
-int ip_tunnel_encap_del_ops(const struct ip_tunnel_encap_ops *op,
-			    unsigned int num);
-
 static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
 				      __be32 saddr, __be32 daddr,
 				      u8 tos, u8 ttl, __be32 label,
@@ -251,8 +235,6 @@ void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, const u8 protocol);
 int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
-int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
-		    u8 *protocol, struct flowi4 *fl4);
 int __ip_tunnel_change_mtu(struct net_device *dev, int new_mtu, bool strict);
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
 
@@ -271,9 +253,67 @@ int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		      struct ip_tunnel_parm *p);
 void ip_tunnel_setup(struct net_device *dev, int net_id);
+
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
 int ip_tunnel_encap_setup(struct ip_tunnel *t,
 			  struct ip_tunnel_encap *ipencap);
 
+static inline int ip_encap_hlen(struct ip_tunnel_encap *e)
+{
+	const struct ip_tunnel_encap_ops *ops;
+	int hlen = -EINVAL;
+
+	if (e->type == TUNNEL_ENCAP_NONE)
+		return 0;
+
+	if (e->type >= MAX_IPTUN_ENCAP_OPS)
+		return -EINVAL;
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
+static inline int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
+				  u8 *protocol, struct flowi4 *fl4)
+{
+	const struct ip_tunnel_encap_ops *ops;
+	int ret = -EINVAL;
+
+	if (t->encap.type == TUNNEL_ENCAP_NONE)
+		return 0;
+
+	if (t->encap.type >= MAX_IPTUN_ENCAP_OPS)
+		return -EINVAL;
+
+	rcu_read_lock();
+	ops = rcu_dereference(iptun_encaps[t->encap.type]);
+	if (likely(ops && ops->build_header))
+		ret = ops->build_header(skb, &t->encap, protocol, fl4);
+	rcu_read_unlock();
+
+	return ret;
+}
+
 /* Extract dsfield from inner protocol */
 static inline u8 ip_tunnel_get_dsfield(const struct iphdr *iph,
 				       const struct sk_buff *skb)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index a69ed94..d8f5e0a 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -443,29 +443,6 @@ drop:
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_rcv);
 
-static int ip_encap_hlen(struct ip_tunnel_encap *e)
-{
-	const struct ip_tunnel_encap_ops *ops;
-	int hlen = -EINVAL;
-
-	if (e->type == TUNNEL_ENCAP_NONE)
-		return 0;
-
-	if (e->type >= MAX_IPTUN_ENCAP_OPS)
-		return -EINVAL;
-
-	rcu_read_lock();
-	ops = rcu_dereference(iptun_encaps[e->type]);
-	if (likely(ops && ops->encap_hlen))
-		hlen = ops->encap_hlen(e);
-	rcu_read_unlock();
-
-	return hlen;
-}
-
-const struct ip_tunnel_encap_ops __rcu *
-		iptun_encaps[MAX_IPTUN_ENCAP_OPS] __read_mostly;
-
 int ip_tunnel_encap_add_ops(const struct ip_tunnel_encap_ops *ops,
 			    unsigned int num)
 {
@@ -519,28 +496,6 @@ int ip_tunnel_encap_setup(struct ip_tunnel *t,
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_encap_setup);
 
-int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
-		    u8 *protocol, struct flowi4 *fl4)
-{
-	const struct ip_tunnel_encap_ops *ops;
-	int ret = -EINVAL;
-
-	if (t->encap.type == TUNNEL_ENCAP_NONE)
-		return 0;
-
-	if (t->encap.type >= MAX_IPTUN_ENCAP_OPS)
-		return -EINVAL;
-
-	rcu_read_lock();
-	ops = rcu_dereference(iptun_encaps[t->encap.type]);
-	if (likely(ops && ops->build_header))
-		ret = ops->build_header(skb, &t->encap, protocol, fl4);
-	rcu_read_unlock();
-
-	return ret;
-}
-EXPORT_SYMBOL(ip_tunnel_encap);
-
 static int tnl_update_pmtu(struct net_device *dev, struct sk_buff *skb,
 			    struct rtable *rt, __be16 df,
 			    const struct iphdr *inner_iph)
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 9118b0e..cc66a20 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -47,6 +47,10 @@
 #include <net/rtnetlink.h>
 #include <net/dst_metadata.h>
 
+const struct ip_tunnel_encap_ops __rcu *
+		iptun_encaps[MAX_IPTUN_ENCAP_OPS] __read_mostly;
+EXPORT_SYMBOL(iptun_encaps);
+
 void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 proto,
 		   __u8 tos, __u8 ttl, __be16 df, bool xnet)
-- 
2.8.0.rc2
