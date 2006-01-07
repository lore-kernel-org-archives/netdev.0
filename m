From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER 07/10]: Redo policy lookups after NAT when neccessary
Date: Sat,  7 Jan 2006 02:09:40 +0100 (MET)
Message-ID: <20060107010905.8712.53527.sendpatchset@localhost.localdomain>
References: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David S. Miller <davem@davemloft.net>
In-Reply-To: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
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

When NAT changes the key used for the xfrm lookup it needs to be done
again. If a new policy is returned in POST_ROUTING the packet needs
to be passed to xfrm4_output_one manually after all hooks were called
because POST_ROUTING is called with fixed okfn (ip_finish_output).

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 00b264ce82ccc3216e3e4b0175dd1337eeb16f24
tree e774053af87fff87b29e652c6a90588c30695224
parent 3ba04601534a6f050fb695c92ddc62d403078cc6
author Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 01:18:04 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 01:18:04 +0100

 include/net/xfrm.h                     |    1 +
 net/ipv4/ip_output.c                   |    5 +++++
 net/ipv4/netfilter/ip_nat_standalone.c |   27 +++++++++++++++++++++++++--
 net/ipv4/xfrm4_output.c                |    2 +-
 4 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d6111a2..d09ca0e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -866,6 +866,7 @@ extern int xfrm_state_mtu(struct xfrm_st
 extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm4_rcv(struct sk_buff *skb);
 extern int xfrm4_output(struct sk_buff *skb);
+extern int xfrm4_output_finish(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
 extern int xfrm6_rcv_spi(struct sk_buff **pskb, u32 spi);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 71da318..5b42dbe 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -202,6 +202,11 @@ static inline int ip_finish_output2(stru
 
 static inline int ip_finish_output(struct sk_buff *skb)
 {
+#if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
+	/* Policy lookup after SNAT yielded a new policy */
+	if (skb->dst->xfrm != NULL)
+		return xfrm4_output_finish(skb);
+#endif
 	if (skb->len > dst_mtu(skb->dst) &&
 	    !(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
 		return ip_fragment(skb, ip_finish_output2);
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
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 160c488..d4df0dd 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -152,7 +152,7 @@ error_nolock:
 	goto out_exit;
 }
 
-static int xfrm4_output_finish(struct sk_buff *skb)
+int xfrm4_output_finish(struct sk_buff *skb)
 {
 	int err;
 
