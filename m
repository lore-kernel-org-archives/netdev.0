From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [NETFILTER] xt_TCPMSS: combine nearly identical reverse_mtu4/6
Date: Sat, 29 Mar 2008 15:25:42 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803291520210.8374@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-474323254-1206797142=:8374"
Cc: netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Patrick Hardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-474323254-1206797142=:8374
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Added tcpmss_reverse_mtu, only flowi setup and family differ

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/netfilter/xt_TCPMSS.c |   34 ++++++++++++++--------------------
 1 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 217e2b6..1619166 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -147,28 +147,35 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	return TCPOLEN_MSS;
 }
 
-static u_int32_t tcpmss_reverse_mtu4(const struct iphdr *iph)
+static u_int32_t tcpmss_reverse_mtu(struct flowi *fl, unsigned short family)
 {
-	struct flowi fl = {
-		.fl4_dst = iph->saddr,
-	};
 	const struct nf_afinfo *ai;
 	struct rtable *rt = NULL;
 	u_int32_t mtu     = ~0U;
 
 	rcu_read_lock();
-	ai = nf_get_afinfo(AF_INET);
+	ai = nf_get_afinfo(family);
 	if (ai != NULL)
-		ai->route((struct dst_entry **)&rt, &fl);
+		ai->route((struct dst_entry **)&rt, fl);
 	rcu_read_unlock();
 
 	if (rt != NULL) {
 		mtu = dst_mtu(&rt->u.dst);
 		dst_release(&rt->u.dst);
 	}
+
 	return mtu;
 }
 
+static u_int32_t tcpmss_reverse_mtu4(const struct iphdr *iph)
+{
+	struct flowi fl = {
+		.fl4_dst = iph->saddr,
+	};
+
+	return tcpmss_reverse_mtu(&fl, AF_INET);
+}
+
 static unsigned int
 tcpmss_tg4(struct sk_buff *skb, const struct net_device *in,
            const struct net_device *out, unsigned int hooknum,
@@ -198,21 +205,8 @@ static u_int32_t tcpmss_reverse_mtu6(const struct ipv6hdr *iph)
 	struct flowi fl = {
 		.fl6_dst = iph->saddr,
 	};
-	const struct nf_afinfo *ai;
-	struct rtable *rt = NULL;
-	u_int32_t mtu     = ~0U;
-
-	rcu_read_lock();
-	ai = nf_get_afinfo(AF_INET6);
-	if (ai != NULL)
-		ai->route((struct dst_entry **)&rt, &fl);
-	rcu_read_unlock();
 
-	if (rt != NULL) {
-		mtu = dst_mtu(&rt->u.dst);
-		dst_release(&rt->u.dst);
-	}
-	return mtu;
+	return tcpmss_reverse_mtu(&fl, AF_INET6);
 }
 
 static unsigned int
-- 
1.5.2.2

---696208474-474323254-1206797142=:8374--
