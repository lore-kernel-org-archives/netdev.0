From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] Give skb_checksum_help an sk_buff * again
Date: Mon, 25 Oct 2004 22:35:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025123507.GA4346@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SUOF0GtieIMvvwua"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Since skb_checksum_help has been using pskb_expand_head for a while
now without any ill effects, I thought it would be a good idea to
remove the double pointers from it and its callers.

This is what the following patch does.  The only "rider" bit is the
removal of an unnecessary BUG_ON in ip6_pkt_discard_out.  The preceding
assignment was only added because the following function oopsed so
there is no point in doing BUG_ON.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/netdevice.h 1.89 vs edited =====
--- 1.89/include/linux/netdevice.h	2004-10-21 09:57:03 +10:00
+++ edited/include/linux/netdevice.h	2004-10-25 18:10:13 +10:00
@@ -937,7 +937,7 @@
 extern unsigned long	netdev_fc_xoff;
 extern atomic_t netdev_dropping;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
-extern int skb_checksum_help(struct sk_buff **pskb, int inward);
+extern int skb_checksum_help(struct sk_buff *skb, int inward);
 
 #ifdef CONFIG_SYSCTL
 extern char *net_sysctl_strdup(const char *s);
===== include/net/dst.h 1.23 vs edited =====
--- 1.23/include/net/dst.h	2004-10-22 14:49:18 +10:00
+++ edited/include/net/dst.h	2004-10-25 18:10:14 +10:00
@@ -67,7 +67,7 @@
 	struct xfrm_state	*xfrm;
 
 	int			(*input)(struct sk_buff*);
-	int			(*output)(struct sk_buff**);
+	int			(*output)(struct sk_buff*);
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	__u32			tclassid;
@@ -222,7 +222,7 @@
 	int err;
 
 	for (;;) {
-		err = skb->dst->output(&skb);
+		err = skb->dst->output(skb);
 
 		if (likely(err == 0))
 			return err;
===== include/net/ip.h 1.34 vs edited =====
--- 1.34/include/net/ip.h	2004-08-30 14:10:09 +10:00
+++ edited/include/net/ip.h	2004-10-25 18:10:14 +10:00
@@ -89,8 +89,8 @@
 			       struct packet_type *pt);
 extern int		ip_local_deliver(struct sk_buff *skb);
 extern int		ip_mr_input(struct sk_buff *skb);
-extern int		ip_output(struct sk_buff **pskb);
-extern int		ip_mc_output(struct sk_buff **pskb);
+extern int		ip_output(struct sk_buff *skb);
+extern int		ip_mc_output(struct sk_buff *skb);
 extern int		ip_fragment(struct sk_buff *skb, int (*out)(struct sk_buff*));
 extern int		ip_do_nat(struct sk_buff *skb);
 extern void		ip_send_check(struct iphdr *ip);
===== include/net/ip6_route.h 1.19 vs edited =====
--- 1.19/include/net/ip6_route.h	2004-09-15 07:03:30 +10:00
+++ edited/include/net/ip6_route.h	2004-10-25 18:10:14 +10:00
@@ -70,7 +70,7 @@
 extern struct dst_entry *ndisc_dst_alloc(struct net_device *dev,
 					 struct neighbour *neigh,
 					 struct in6_addr *addr,
-					 int (*output)(struct sk_buff **));
+					 int (*output)(struct sk_buff *));
 extern int ndisc_dst_gc(int *more);
 extern void fib6_force_start_gc(void);
 
===== include/net/ipv6.h 1.39 vs edited =====
--- 1.39/include/net/ipv6.h	2004-09-08 16:32:57 +10:00
+++ edited/include/net/ipv6.h	2004-10-25 18:10:14 +10:00
@@ -355,7 +355,7 @@
  *	skb processing functions
  */
 
-extern int			ip6_output(struct sk_buff **pskb);
+extern int			ip6_output(struct sk_buff *skb);
 extern int			ip6_forward(struct sk_buff *skb);
 extern int			ip6_input(struct sk_buff *skb);
 extern int			ip6_mc_input(struct sk_buff *skb);
===== include/net/xfrm.h 1.69 vs edited =====
--- 1.69/include/net/xfrm.h	2004-10-21 14:47:36 +10:00
+++ edited/include/net/xfrm.h	2004-10-25 18:10:14 +10:00
@@ -815,7 +815,7 @@
 extern int xfrm_check_selectors(struct xfrm_state **x, int n, struct flowi *fl);
 extern int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_rcv(struct sk_buff *skb);
-extern int xfrm4_output(struct sk_buff **pskb);
+extern int xfrm4_output(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
 extern int xfrm6_rcv_spi(struct sk_buff **pskb, unsigned int *nhoffp, u32 spi);
@@ -825,7 +825,7 @@
 extern u32 xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr);
 extern void xfrm6_tunnel_free_spi(xfrm_address_t *saddr);
 extern u32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr);
-extern int xfrm6_output(struct sk_buff **pskb);
+extern int xfrm6_output(struct sk_buff *skb);
 
 #ifdef CONFIG_XFRM
 extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
===== net/bridge/br_netfilter.c 1.26 vs edited =====
--- 1.26/net/bridge/br_netfilter.c	2004-10-06 07:51:01 +10:00
+++ edited/net/bridge/br_netfilter.c	2004-10-25 18:10:14 +10:00
@@ -197,7 +197,7 @@
 		skb_pull(skb, VLAN_HLEN);
 		skb->nh.raw += VLAN_HLEN;
 	}
-	skb->dst->output(&skb);
+	skb->dst->output(skb);
 	return 0;
 }
 
===== net/core/dev.c 1.167 vs edited =====
--- 1.167/net/core/dev.c	2004-10-21 14:42:00 +10:00
+++ edited/net/core/dev.c	2004-10-25 18:10:15 +10:00
@@ -1106,34 +1106,34 @@
  * Invalidate hardware checksum when packet is to be mangled, and
  * complete checksum manually on outgoing path.
  */
-int skb_checksum_help(struct sk_buff **pskb, int inward)
+int skb_checksum_help(struct sk_buff *skb, int inward)
 {
 	unsigned int csum;
-	int ret = 0, offset = (*pskb)->h.raw - (*pskb)->data;
+	int ret = 0, offset = skb->h.raw - skb->data;
 
 	if (inward) {
-		(*pskb)->ip_summed = CHECKSUM_NONE;
+		skb->ip_summed = CHECKSUM_NONE;
 		goto out;
 	}
 
-	if (skb_cloned(*pskb)) {
-		ret = pskb_expand_head(*pskb, 0, 0, GFP_ATOMIC);
+	if (skb_cloned(skb)) {
+		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 		if (ret)
 			goto out;
 	}
 
-	if (offset > (int)(*pskb)->len)
+	if (offset > (int)skb->len)
 		BUG();
-	csum = skb_checksum(*pskb, offset, (*pskb)->len-offset, 0);
+	csum = skb_checksum(skb, offset, skb->len-offset, 0);
 
-	offset = (*pskb)->tail - (*pskb)->h.raw;
+	offset = skb->tail - skb->h.raw;
 	if (offset <= 0)
 		BUG();
-	if ((*pskb)->csum + 2 > offset)
+	if (skb->csum + 2 > offset)
 		BUG();
 
-	*(u16*)((*pskb)->h.raw + (*pskb)->csum) = csum_fold(csum);
-	(*pskb)->ip_summed = CHECKSUM_NONE;
+	*(u16*)(skb->h.raw + skb->csum) = csum_fold(csum);
+	skb->ip_summed = CHECKSUM_NONE;
 out:	
 	return ret;
 }
@@ -1282,7 +1282,7 @@
 	    (!(dev->features & (NETIF_F_HW_CSUM | NETIF_F_NO_CSUM)) &&
 	     (!(dev->features & NETIF_F_IP_CSUM) ||
 	      skb->protocol != htons(ETH_P_IP))))
-	      	if (skb_checksum_help(&skb, 0))
+	      	if (skb_checksum_help(skb, 0))
 	      		goto out_kfree_skb;
 
 
===== net/core/dst.c 1.22 vs edited =====
--- 1.22/net/core/dst.c	2004-10-22 14:49:18 +10:00
+++ edited/net/core/dst.c	2004-10-25 21:29:09 +10:00
@@ -106,9 +106,9 @@
 	return 0;
 }
 
-static int dst_discard_out(struct sk_buff **pskb)
+static int dst_discard_out(struct sk_buff *skb)
 {
-	kfree_skb(*pskb);
+	kfree_skb(skb);
 	return 0;
 }
 
===== net/decnet/dn_route.c 1.25 vs edited =====
--- 1.25/net/decnet/dn_route.c	2004-09-24 09:51:55 +10:00
+++ edited/net/decnet/dn_route.c	2004-10-25 21:57:33 +10:00
@@ -683,9 +683,8 @@
 	return NET_RX_DROP;
 }
 
-static int dn_output(struct sk_buff **pskb)
+static int dn_output(struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
 	struct dst_entry *dst = skb->dst;
 	struct dn_route *rt = (struct dn_route *)dst;
 	struct net_device *dev = dst->dev;
@@ -796,11 +795,6 @@
 	return NET_RX_BAD;
 }
 
-static int dn_rt_bug_out(struct sk_buff **pskb)
-{
-	return dn_rt_bug(*pskb);
-}
-
 static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 {
 	struct dn_fib_info *fi = res->fi;
@@ -1392,7 +1386,7 @@
 	rt->u.dst.neighbour = neigh;
 	rt->u.dst.dev = out_dev;
 	rt->u.dst.lastuse = jiffies;
-	rt->u.dst.output = dn_rt_bug_out;
+	rt->u.dst.output = dn_rt_bug;
 	switch(res.type) {
 		case RTN_UNICAST:
 			rt->u.dst.input = dn_forward;
===== net/ipv4/ip_output.c 1.70 vs edited =====
--- 1.70/net/ipv4/ip_output.c	2004-10-01 13:56:45 +10:00
+++ edited/net/ipv4/ip_output.c	2004-10-25 21:30:21 +10:00
@@ -224,9 +224,8 @@
 		       ip_finish_output2);
 }
 
-int ip_mc_output(struct sk_buff **pskb)
+int ip_mc_output(struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
 	struct sock *sk = skb->sk;
 	struct rtable *rt = (struct rtable*)skb->dst;
 	struct net_device *dev = rt->u.dst.dev;
@@ -285,10 +284,8 @@
 		return ip_finish_output(skb);
 }
 
-int ip_output(struct sk_buff **pskb)
+int ip_output(struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
-
 	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 
 	if ((skb->len > dst_pmtu(skb->dst) || skb_shinfo(skb)->frag_list) &&
===== net/ipv4/route.c 1.95 vs edited =====
--- 1.95/net/ipv4/route.c	2004-10-20 18:37:15 +10:00
+++ edited/net/ipv4/route.c	2004-10-25 21:32:32 +10:00
@@ -1367,10 +1367,8 @@
 		dst_set_expires(&rt->u.dst, 0);
 }
 
-static int ip_rt_bug(struct sk_buff **pskb)
+static int ip_rt_bug(struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
-
 	printk(KERN_DEBUG "ip_rt_bug: %u.%u.%u.%u -> %u.%u.%u.%u, %s\n",
 		NIPQUAD(skb->nh.iph->saddr), NIPQUAD(skb->nh.iph->daddr),
 		skb->dev ? skb->dev->name : "?");
===== net/ipv4/xfrm4_output.c 1.4 vs edited =====
--- 1.4/net/ipv4/xfrm4_output.c	2004-08-25 04:30:14 +10:00
+++ edited/net/ipv4/xfrm4_output.c	2004-10-25 21:30:04 +10:00
@@ -91,16 +91,14 @@
 	return ret;
 }
 
-int xfrm4_output(struct sk_buff **pskb)
+int xfrm4_output(struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
 	int err;
 	
 	if (skb->ip_summed == CHECKSUM_HW) {
-		err = skb_checksum_help(pskb, 0);
-		skb = *pskb;
+		err = skb_checksum_help(skb, 0);
 		if (err)
 			goto error_nolock;
 	}
===== net/ipv4/netfilter/ip_fw_compat.c 1.22 vs edited =====
--- 1.22/net/ipv4/netfilter/ip_fw_compat.c	2004-06-04 15:02:47 +10:00
+++ edited/net/ipv4/netfilter/ip_fw_compat.c	2004-10-25 21:30:51 +10:00
@@ -69,7 +69,7 @@
 	/* Assume worse case: any hook could change packet */
 	(*pskb)->nfcache |= NFC_UNKNOWN | NFC_ALTERED;
 	if ((*pskb)->ip_summed == CHECKSUM_HW)
-		if (skb_checksum_help(pskb, (out == NULL)))
+		if (skb_checksum_help(*pskb, (out == NULL)))
 			return NF_DROP;
 
 	switch (hooknum) {
===== net/ipv4/netfilter/ip_nat_standalone.c 1.35 vs edited =====
--- 1.35/net/ipv4/netfilter/ip_nat_standalone.c	2004-09-24 07:42:34 +10:00
+++ edited/net/ipv4/netfilter/ip_nat_standalone.c	2004-10-25 21:31:17 +10:00
@@ -86,7 +86,7 @@
 
 	/* If we had a hardware checksum before, it's now invalid */
 	if ((*pskb)->ip_summed == CHECKSUM_HW)
-		if (skb_checksum_help(pskb, (out == NULL)))
+		if (skb_checksum_help(*pskb, (out == NULL)))
 			return NF_DROP;
 
 	ct = ip_conntrack_get(*pskb, &ctinfo);
===== net/ipv4/netfilter/ipt_ECN.c 1.10 vs edited =====
--- 1.10/net/ipv4/netfilter/ipt_ECN.c	2004-08-19 10:14:53 +10:00
+++ edited/net/ipv4/netfilter/ipt_ECN.c	2004-10-25 21:31:50 +10:00
@@ -86,7 +86,7 @@
 		memcpy((*pskb)->data + (*pskb)->nh.iph->ihl*4,
 		       &_tcph, sizeof(_tcph));
 		if ((*pskb)->ip_summed == CHECKSUM_HW)
-			if (skb_checksum_help(pskb, inward))
+			if (skb_checksum_help(*pskb, inward))
 				return 0;
 		(*pskb)->nfcache |= NFC_ALTERED;
 	}
===== net/ipv6/ip6_output.c 1.74 vs edited =====
--- 1.74/net/ipv6/ip6_output.c	2004-09-24 07:39:26 +10:00
+++ edited/net/ipv6/ip6_output.c	2004-10-25 21:58:19 +10:00
@@ -56,7 +56,7 @@
 #include <net/xfrm.h>
 #include <net/checksum.h>
 
-static int ip6_fragment(struct sk_buff **pskb, int (*output)(struct sk_buff**));
+static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 
 static __inline__ void ipv6_select_ident(struct sk_buff *skb, struct frag_hdr *fhdr)
 {
@@ -108,9 +108,8 @@
 }
 
 
-static int ip6_output2(struct sk_buff **pskb)
+static int ip6_output2(struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
 	struct dst_entry *dst = skb->dst;
 	struct net_device *dev = dst->dev;
 
@@ -146,14 +145,12 @@
 	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb,NULL, skb->dev,ip6_output_finish);
 }
 
-int ip6_output(struct sk_buff **pskb)
+int ip6_output(struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
-
 	if ((skb->len > dst_pmtu(skb->dst) || skb_shinfo(skb)->frag_list))
-		return ip6_fragment(pskb, ip6_output2);
+		return ip6_fragment(skb, ip6_output2);
 	else
-		return ip6_output2(pskb);
+		return ip6_output2(skb);
 }
 
 #ifdef CONFIG_NETFILTER
@@ -518,10 +515,10 @@
 	return offset;
 }
 
-static int ip6_fragment(struct sk_buff **pskb, int (*output)(struct sk_buff**))
+static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct net_device *dev;
-	struct sk_buff *frag, *skb = *pskb;
+	struct sk_buff *frag;
 	struct rt6_info *rt = (struct rt6_info*)skb->dst;
 	struct ipv6hdr *tmp_hdr;
 	struct frag_hdr *fh;
@@ -610,7 +607,7 @@
 				ip6_copy_metadata(frag, skb);
 			}
 			
-			err = output(&skb);
+			err = output(skb);
 			if (err || !frag)
 				break;
 
@@ -726,7 +723,7 @@
 
 		IP6_INC_STATS(IPSTATS_MIB_FRAGCREATES);
 
-		err = output(&frag);
+		err = output(frag);
 		if (err)
 			goto fail;
 	}
===== net/ipv6/route.c 1.97 vs edited =====
--- 1.97/net/ipv6/route.c	2004-10-21 15:00:01 +10:00
+++ edited/net/ipv6/route.c	2004-10-25 22:00:00 +10:00
@@ -88,7 +88,7 @@
 static int		 ip6_dst_gc(void);
 
 static int		ip6_pkt_discard(struct sk_buff *skb);
-static int		ip6_pkt_discard_out(struct sk_buff **pskb);
+static int		ip6_pkt_discard_out(struct sk_buff *skb);
 static void		ip6_link_failure(struct sk_buff *skb);
 static void		ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 
@@ -638,7 +638,7 @@
 struct dst_entry *ndisc_dst_alloc(struct net_device *dev, 
 				  struct neighbour *neigh,
 				  struct in6_addr *addr,
-				  int (*output)(struct sk_buff **))
+				  int (*output)(struct sk_buff *))
 {
 	struct rt6_info *rt;
 	struct inet6_dev *idev = in6_dev_get(dev);
@@ -1362,11 +1362,10 @@
 	return 0;
 }
 
-int ip6_pkt_discard_out(struct sk_buff **pskb)
+int ip6_pkt_discard_out(struct sk_buff *skb)
 {
-	(*pskb)->dev = (*pskb)->dst->dev;
-	BUG_ON(!(*pskb)->dev);
-	return ip6_pkt_discard(*pskb);
+	skb->dev = skb->dst->dev;
+	return ip6_pkt_discard(skb);
 }
 
 /*
===== net/ipv6/xfrm6_output.c 1.5 vs edited =====
--- 1.5/net/ipv6/xfrm6_output.c	2004-09-09 14:19:31 +10:00
+++ edited/net/ipv6/xfrm6_output.c	2004-10-25 21:33:05 +10:00
@@ -91,16 +91,14 @@
 	return ret;
 }
 
-int xfrm6_output(struct sk_buff **pskb)
+int xfrm6_output(struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
 	int err;
 	
 	if (skb->ip_summed == CHECKSUM_HW) {
-		err = skb_checksum_help(pskb, 0);
-		skb = *pskb;
+		err = skb_checksum_help(skb, 0);
 		if (err)
 			goto error_nolock;
 	}

--SUOF0GtieIMvvwua--
