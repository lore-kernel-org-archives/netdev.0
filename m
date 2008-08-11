From: Eugene Teo <eugeneteo@kernel.sg>
Subject: Re: OOPS, ip -f inet6 route get fec0::1, linux-2.6.26,
	ip6_route_output, rt6_fill_node+0x175
Date: Mon, 11 Aug 2008 19:03:35 +0800
Message-ID: <20080811110335.GA29407@kernel.sg>
References: <9F6ACAE02B6DD040A1E259977622CFDB033590C3@oslexcp1.eu.tandberg.int> <20080807203748.GA5196@martell.zuzino.mipt.ru> <489BD227.6000209@hp.com>
Reply-To: Eugene Teo <eugeneteo@kernel.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	John Gumb <john.gumb@tandberg.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753363AbYHKLEh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <489BD227.6000209@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

<quote sender="Brian Haley">
> Alexey Dobriyan wrote:
>> On Thu, Aug 07, 2008 at 07:00:56PM +0200, John Gumb wrote:
[...]
> The commit that changed this can't be reverted easily, but the patch  
> below works for me.
>
> Fix NULL de-reference in rt6_fill_node() when there's no IPv6 input  
> device present in the dst entry.
>
> Signed-off-by: Brian Haley <brian.haley@hp.com>

I think it's better to use a helper routine like ipv6_get_saddr to make
sure that both dst and rt6i_idev arguments are checked for NULL.

I have compiled, and tested the patch.

Thanks,
Eugene

---
Fix NULL pointer dereference in rt6_fill_node().

# ip -f inet6 route get fec0::1

BUG: unable to handle kernel NULL pointer dereference at 00000000
IP: [<c0369b85>] rt6_fill_node+0x175/0x3b0
EIP is at rt6_fill_node+0x175/0x3b0

Cc: Stable <stable@kernel.org>
Signed-off-by: Eugene Teo <eugeneteo@kernel.sg>
---
 include/net/addrconf.h  |    4 ++++
 include/net/ip6_fib.h   |    2 +-
 net/ipv6/addrconf.c     |    8 ++++++++
 net/ipv6/fib6_rules.c   |    3 +--
 net/ipv6/ip6_output.c   |    3 +--
 net/ipv6/route.c        |    3 +--
 net/ipv6/xfrm6_policy.c |    3 +--
 net/sctp/ipv6.c         |    3 +--
 8 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 06b2814..c43ad8e 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -80,6 +80,10 @@ extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
 						 struct net_device *dev,
 						 int strict);
 
+extern int			ipv6_get_saddr(struct dst_entry *dst,
+					       const struct in6_addr *daddr,
+					       unsigned int srcprefs,
+					       struct in6_addr *saddr);
 extern int			ipv6_dev_get_saddr(struct net_device *dev, 
 					       const struct in6_addr *daddr,
 					       unsigned int srcprefs,
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 7c5c0f7..73f7f6b 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -118,7 +118,7 @@ struct rt6_info
 
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 {
-	return ((struct rt6_info *)dst)->rt6i_idev;
+	return dst ? ((struct rt6_info *)dst)->rt6i_idev : NULL;
 }
 
 struct fib6_walker_t
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a7842c5..55647bd 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1239,6 +1239,14 @@ try_nextdev:
 	return 0;
 }
 
+int ipv6_get_saddr(struct dst_entry *dst, const struct in6_addr *daddr,
+		    unsigned int srcprefs, struct in6_addr *saddr)
+{
+	struct inet6_dev *idev = ip6_dst_idev(dst);
+	return ipv6_dev_get_saddr(idev ? idev->dev : NULL, daddr, srcprefs, saddr);
+
+}
+EXPORT_SYMBOL(ipv6_get_saddr);
 EXPORT_SYMBOL(ipv6_dev_get_saddr);
 
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 8d05527..27c859c 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -93,8 +93,7 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 			if (flags & RT6_LOOKUP_F_SRCPREF_COA)
 				srcprefs |= IPV6_PREFER_SRC_COA;
 
-			if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
-					       &flp->fl6_dst, srcprefs,
+			if (ipv6_get_saddr(&rt->u.dst, &flp->fl6_dst, srcprefs,
 					       &saddr))
 				goto again;
 			if (!ipv6_prefix_equal(&saddr, &r->src.addr,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a4402de..fc5f4f4 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -934,8 +934,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		goto out_err_release;
 
 	if (ipv6_addr_any(&fl->fl6_src)) {
-		err = ipv6_dev_get_saddr(ip6_dst_idev(*dst)->dev,
-					 &fl->fl6_dst,
+		err = ipv6_get_saddr(*dst, &fl->fl6_dst,
 					 sk ? inet6_sk(sk)->srcprefs : 0,
 					 &fl->fl6_src);
 		if (err)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5a3e87e..950d709 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2188,8 +2188,7 @@ static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 			NLA_PUT_U32(skb, RTA_IIF, iif);
 	} else if (dst) {
 		struct in6_addr saddr_buf;
-		if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
-				       dst, 0, &saddr_buf) == 0)
+		if (ipv6_get_saddr(&rt->u.dst, dst, 0, &saddr_buf) == 0)
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 8f1e054..ad582bd 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -57,8 +57,7 @@ static int xfrm6_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
-	ipv6_dev_get_saddr(ip6_dst_idev(dst)->dev,
-			   (struct in6_addr *)&daddr->a6, 0,
+	ipv6_get_saddr(dst, (struct in6_addr *)&daddr->a6, 0,
 			   (struct in6_addr *)&saddr->a6);
 	dst_release(dst);
 	return 0;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 483a01d..0fa9411 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -319,8 +319,7 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 			  __func__, asoc, dst, NIP6(daddr->v6.sin6_addr));
 
 	if (!asoc) {
-		ipv6_dev_get_saddr(dst ? ip6_dst_idev(dst)->dev : NULL,
-				   &daddr->v6.sin6_addr,
+		ipv6_get_saddr(dst, &daddr->v6.sin6_addr,
 				   inet6_sk(&sk->inet.sk)->srcprefs,
 				   &saddr->v6.sin6_addr);
 		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: " NIP6_FMT "\n",
