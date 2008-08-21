From: adobriyan@gmail.com
Subject: [PATCH 12/38] netns ct: pass netns pointer to nf_conntrack_in()
Date: Fri, 22 Aug 2008 02:01:52 +0400
Message-ID: <20080821220152.GL31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's deducible as is, but it's also known at nf_conntrack_in() time allowing
to not branch and make code simpler later.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack_core.h      |    2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    4 ++--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   24 ++++++++++++++++--------
 net/netfilter/nf_conntrack_core.c              |   11 +++++------
 4 files changed, 24 insertions(+), 17 deletions(-)

--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -20,7 +20,7 @@
 /* This header is used to share core functionality between the
    standalone connection tracking module, and the compatibility layer's use
    of connection tracking. */
-extern unsigned int nf_conntrack_in(int pf,
+extern unsigned int nf_conntrack_in(struct net *net, int pf,
 				    unsigned int hooknum,
 				    struct sk_buff *skb);
 
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -172,7 +172,7 @@ static unsigned int ipv4_conntrack_in(unsigned int hooknum,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
-	return nf_conntrack_in(PF_INET, hooknum, skb);
+	return nf_conntrack_in(dev_net(in), PF_INET, hooknum, skb);
 }
 
 static unsigned int ipv4_conntrack_local(unsigned int hooknum,
@@ -188,7 +188,7 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
 			printk("ipt_hook: happy cracking.\n");
 		return NF_ACCEPT;
 	}
-	return nf_conntrack_in(PF_INET, hooknum, skb);
+	return nf_conntrack_in(dev_net(out), PF_INET, hooknum, skb);
 }
 
 /* Connection tracking may drop packets, but never alters them, so
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -211,11 +211,10 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 	return NF_STOLEN;
 }
 
-static unsigned int ipv6_conntrack_in(unsigned int hooknum,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+static unsigned int __ipv6_conntrack_in(struct net *net,
+					unsigned int hooknum,
+					struct sk_buff *skb,
+					int (*okfn)(struct sk_buff *))
 {
 	struct sk_buff *reasm = skb->nfct_reasm;
 
@@ -225,7 +224,7 @@ static unsigned int ipv6_conntrack_in(unsigned int hooknum,
 		if (!reasm->nfct) {
 			unsigned int ret;
 
-			ret = nf_conntrack_in(PF_INET6, hooknum, reasm);
+			ret = nf_conntrack_in(net, PF_INET6, hooknum, reasm);
 			if (ret != NF_ACCEPT)
 				return ret;
 		}
@@ -235,7 +234,16 @@ static unsigned int ipv6_conntrack_in(unsigned int hooknum,
 		return NF_ACCEPT;
 	}
 
-	return nf_conntrack_in(PF_INET6, hooknum, skb);
+	return nf_conntrack_in(net, PF_INET6, hooknum, skb);
+}
+
+static unsigned int ipv6_conntrack_in(unsigned int hooknum,
+				      struct sk_buff *skb,
+				      const struct net_device *in,
+				      const struct net_device *out,
+				      int (*okfn)(struct sk_buff *))
+{
+	return __ipv6_conntrack_in(dev_net(in), hooknum, skb, okfn);
 }
 
 static unsigned int ipv6_conntrack_local(unsigned int hooknum,
@@ -250,7 +258,7 @@ static unsigned int ipv6_conntrack_local(unsigned int hooknum,
 			printk("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
-	return ipv6_conntrack_in(hooknum, skb, in, out, okfn);
+	return __ipv6_conntrack_in(dev_net(out), hooknum, skb, okfn);
 }
 
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -610,7 +610,7 @@ init_conntrack(struct net *net,
 
 /* On success, returns conntrack ptr, sets skb->nfct and ctinfo */
 static inline struct nf_conn *
-resolve_normal_ct(struct sk_buff *skb,
+resolve_normal_ct(struct net *net, struct sk_buff *skb,
 		  unsigned int dataoff,
 		  u_int16_t l3num,
 		  u_int8_t protonum,
@@ -631,9 +631,9 @@ resolve_normal_ct(struct sk_buff *skb,
 	}
 
 	/* look for tuple match */
-	h = nf_conntrack_find_get(&init_net, &tuple);
+	h = nf_conntrack_find_get(net, &tuple);
 	if (!h) {
-		h = init_conntrack(&init_net, &tuple, l3proto, l4proto, skb, dataoff);
+		h = init_conntrack(net, &tuple, l3proto, l4proto, skb, dataoff);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
@@ -667,7 +667,7 @@ resolve_normal_ct(struct sk_buff *skb,
 }
 
 unsigned int
-nf_conntrack_in(int pf, unsigned int hooknum, struct sk_buff *skb)
+nf_conntrack_in(struct net *net, int pf, unsigned int hooknum, struct sk_buff *skb)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -707,7 +707,7 @@ nf_conntrack_in(int pf, unsigned int hooknum, struct sk_buff *skb)
 		return -ret;
 	}
 
-	ct = resolve_normal_ct(skb, dataoff, pf, protonum, l3proto, l4proto,
+	ct = resolve_normal_ct(net, skb, dataoff, pf, protonum, l3proto, l4proto,
 			       &set_reply, &ctinfo);
 	if (!ct) {
 		/* Not valid part of a connection */
-- 
1.5.6.3


