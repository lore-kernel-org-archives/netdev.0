From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 13/31] netns ct: pass netns to nf_conntrack_in
Date: Mon, 21 Jul 2008 20:40:39 +0400
Message-ID: <20080721164039.GQ13264@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, den@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:7337 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbYGUQm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:42:27 -0400
Received: by ug-out-1314.google.com with SMTP id h2so275386ugf.16
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 09:42:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's used for resolving conntracks in netns and (later) for conntrack statistics.

Can grab netns from skb->dev or ->skb->dst->dev in nf_conntrack_in(), but
relevant netns is know at every nf_conntrack_in() user, so avoid branches.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack_core.h      |    2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    4 ++--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   24 ++++++++++++++++--------
 net/netfilter/nf_conntrack_core.c              |   10 +++++-----
 4 files changed, 24 insertions(+), 16 deletions(-)

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
@@ -607,7 +607,7 @@ init_conntrack(struct net *net,
 
 /* On success, returns conntrack ptr, sets skb->nfct and ctinfo */
 static inline struct nf_conn *
-resolve_normal_ct(struct sk_buff *skb,
+resolve_normal_ct(struct net *net, struct sk_buff *skb,
 		  unsigned int dataoff,
 		  u_int16_t l3num,
 		  u_int8_t protonum,
@@ -628,9 +628,9 @@ resolve_normal_ct(struct sk_buff *skb,
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
@@ -664,7 +664,7 @@ resolve_normal_ct(struct sk_buff *skb,
 }
 
 unsigned int
-nf_conntrack_in(int pf, unsigned int hooknum, struct sk_buff *skb)
+nf_conntrack_in(struct net *net, int pf, unsigned int hooknum, struct sk_buff *skb)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -704,7 +704,7 @@ nf_conntrack_in(int pf, unsigned int hooknum, struct sk_buff *skb)
 		return -ret;
 	}
 
-	ct = resolve_normal_ct(skb, dataoff, pf, protonum, l3proto, l4proto,
+	ct = resolve_normal_ct(net, skb, dataoff, pf, protonum, l3proto, l4proto,
 			       &set_reply, &ctinfo);
 	if (!ct) {
 		/* Not valid part of a connection */
-- 
1.5.4.5


