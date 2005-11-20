From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 09/13]: [NETFILTER]: Redo policy lookups after NAT when
	neccessary
Date: Sun, 20 Nov 2005 17:31:39 +0100
Message-ID: <20051120163139.16666.30437.sendpatchset@localhost.localdomain>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Redo policy lookups after NAT when neccessary

When NAT changes the key used for the xfrm lookup it needs to be done again.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8cb6cfa80dd5dc4da1de280a0278746c262a2d8d
tree efffac2335bd21d0a0c2aa848df544002e4316f4
parent 864cef1bc7d011f4a07b01043786107ad570c820
author Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:07:34 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:07:34 +0100

 include/net/dst.h                      |    1 +
 net/ipv4/ip_output.c                   |    7 ++++++-
 net/ipv4/netfilter.c                   |    2 +-
 net/ipv4/netfilter/ip_nat_standalone.c |   27 +++++++++++++++++++++++++--
 4 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 7eadd0c..4630e17 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -237,6 +237,7 @@ static inline int dst_output(struct sk_b
 }
 
 #if defined(CONFIG_XFRM) && defined(CONFIG_NETFILTER)
+extern int __ip_dst_output(struct sk_buff *skb);
 extern int ip_dst_output(struct sk_buff *skb);
 extern int ip6_dst_output(struct sk_buff *skb);
 #else
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 2c91f03..6836389 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -195,13 +195,18 @@ static inline int ip_finish_output2(stru
 		return dst->neighbour->output(skb);
 
 	if (net_ratelimit())
-		printk(KERN_DEBUG "ip_finish_output2: No header cache and no neighbour!\n");
+		printk(KERN_DEBUG "ip_finish_output3: No header cache and no neighbour!\n");
 	kfree_skb(skb);
 	return -EINVAL;
 }
 
 static inline int ip_finish_output(struct sk_buff *skb)
 {
+#if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
+	/* Policy lookup after SNAT yielded a new policy */
+	if (skb->dst->xfrm != NULL)
+		return __ip_dst_output(skb);
+#endif
 	if (skb->len > dst_mtu(skb->dst) &&
 	    !(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
 		return ip_fragment(skb, ip_finish_output2);
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index db330b6..8fda96a 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -87,7 +87,7 @@ int ip_route_me_harder(struct sk_buff **
 EXPORT_SYMBOL(ip_route_me_harder);
 
 #ifdef CONFIG_XFRM
-static inline int __ip_dst_output(struct sk_buff *skb)
+inline int __ip_dst_output(struct sk_buff *skb)
 {
 	int err;
 
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index 1bb5089..b518697 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -187,12 +187,30 @@ ip_nat_out(unsigned int hooknum,
 	   const struct net_device *out,
 	   int (*okfn)(struct sk_buff *))
 {
+	struct ip_conntrack *ct;
+	enum ip_conntrack_info ctinfo;
+	unsigned int ret;
+
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
 	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	return ip_nat_fn(hooknum, pskb, in, out, okfn);
+	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
+	if (ret != NF_DROP && ret != NF_STOLEN
+	    && (ct = ip_conntrack_get(*pskb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+
+		if (ct->tuplehash[dir].tuple.src.ip !=
+		    ct->tuplehash[!dir].tuple.dst.ip
+#ifdef CONFIG_XFRM
+		    || ct->tuplehash[dir].tuple.src.u.all !=
+		       ct->tuplehash[!dir].tuple.dst.u.all
+#endif
+		    )
+			return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
+	}
+	return ret;
 }
 
 static unsigned int
@@ -217,7 +235,12 @@ ip_nat_local_fn(unsigned int hooknum,
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 
 		if (ct->tuplehash[dir].tuple.dst.ip !=
-		    ct->tuplehash[!dir].tuple.src.ip)
+		    ct->tuplehash[!dir].tuple.src.ip
+#ifdef CONFIG_XFRM
+		    || ct->tuplehash[dir].tuple.dst.u.all !=
+		       ct->tuplehash[dir].tuple.src.u.all
+#endif
+		    )
 			return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
 	}
 	return ret;
