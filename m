From: Patrick McHardy <kaber@trash.net>
Subject: Netfilter+IPsec
Date: Thu, 24 Mar 2005 06:05:50 +0100
Message-ID: <42424AAE.9080403@trash.net>
References: <20050214221607.GC18465@gondor.apana.org.au>	<20050306213214.7d8a143d.davem@davemloft.net>	<20050307103536.GB7137@gondor.apana.org.au>	<20050308102741.GA23468@gondor.apana.org.au>	<20050314102614.GA9610@gondor.apana.org.au>	<20050314105313.GA21001@gondor.apana.org.au>	<20050314111002.GA29156@gondor.apana.org.au>	<20050315091904.GA6256@gondor.apana.org.au>	<20050315095837.GA7130@gondor.apana.org.au>	<20050318090310.GA28443@gondor.apana.org.au>	<20050318091129.GA28658@gondor.apana.org.au>	<20050318104013.57d65e99.davem@davemloft.net>	<423D9ADA.6050407@trash.net> <20050322194910.6a9fa3a4.davem@davemloft.net> <4240EA78.5050402@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010409090802040802080707"
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <4240EA78.5050402@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010409090802040802080707
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> It would call netif_rx(). The packet should pass all hooks as usual,
> so everything works as expected. It is cleaner than my current
> approach, but has the same problems wrt. statistics and AF_PACKET/raw
> sockets. I'll post a patch (probably tomorrow, its late here) so we
> have something concrete to talk about.

Unfortunately I have to delay again. This patch (not entirely
reviewed myself yet) contains the parts necessary for hooking
output IPsec packets for netfilter. dst_output() in ipv4/ and
ipv6/ are replaced by ip_dst_output() and ip6_dst_output(), which
pass the packets through POST_ROUTING before IPsec. All replaced
calls should happen directly after NF_HOOK(LOCAL_OUT, ...). The
packet is then marked as transformed in xfrm{4,6}_output() and
passed through LOCAL_OUT in ip_output() again. This resembles
the behaviour of tunnel-devices, a packet is first visible
in plain on OUTPUT/FORWARD -> POST_ROUTING, then encapsulated
on OUTPUT -> POST_ROUTING again. This part doesn't have any
known problems, the input patch will follow tomorrow.

Regards
Patrick

--------------010409090802040802080707
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== include/linux/ipv6.h 1.29 vs edited =====
--- 1.29/include/linux/ipv6.h	2005-03-16 00:27:17 +01:00
+++ edited/include/linux/ipv6.h	2005-03-24 04:41:37 +01:00
@@ -177,19 +177,20 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 
-/* 
-   This structure contains results of exthdrs parsing
-   as offsets from skb->nh.
- */
 
 struct inet6_skb_parm {
+	/* results of exthdrs parsing as offsets from skb->nh. */
 	int			iif;
 	__u16			ra;
 	__u16			hop;
 	__u16			dst0;
 	__u16			srcrt;
 	__u16			dst1;
+	/* flags */
+	__u16			flags;
 };
+
+#define IP6SKB_XFRM_TRANSFORMED	0x1
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
 
===== include/linux/netfilter.h 1.18 vs edited =====
--- 1.18/include/linux/netfilter.h	2005-03-12 04:12:50 +01:00
+++ edited/include/linux/netfilter.h	2005-03-23 06:19:51 +01:00
@@ -139,9 +139,10 @@
 /* This is gross, but inline doesn't cut it for avoiding the function
    call in fast path: gcc doesn't inline (needs value tracking?). --RR */
 #ifdef CONFIG_NETFILTER_DEBUG
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			       \
+#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)		       \
 ({int __ret;								       \
-if ((__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN)) == 1) \
+if (!(cond) ||								       \
+    (__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN)) == 1) \
 	__ret = (okfn)(skb);						       \
 __ret;})
 #define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	       \
@@ -150,9 +151,9 @@
 	__ret = (okfn)(skb);						       \
 __ret;})
 #else
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			       \
+#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)		       \
 ({int __ret;								       \
-if (list_empty(&nf_hooks[pf][hook]) ||					       \
+if (!(cond) || list_empty(&nf_hooks[pf][hook]) ||					       \
     (__ret=nf_hook_slow(pf, hook, &(skb), indev, outdev, okfn, INT_MIN)) == 1) \
 	__ret = (okfn)(skb);						       \
 __ret;})
@@ -163,6 +164,8 @@
 	__ret = (okfn)(skb);						       \
 __ret;})
 #endif
+#define NF_HOOK(pf, hook, skb, indev, outdev, okfn)			\
+ NF_HOOK_COND((pf), (hook), (skb), (indev), (outdev), (okfn), 1)
 
 int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
 		 struct net_device *indev, struct net_device *outdev,
@@ -192,6 +195,7 @@
 
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
+#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond) (okfn)(skb)
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
 #endif /*CONFIG_NETFILTER*/
 
===== include/net/ip.h 1.38 vs edited =====
--- 1.38/include/net/ip.h	2005-01-27 07:03:17 +01:00
+++ edited/include/net/ip.h	2005-03-23 06:20:11 +01:00
@@ -30,6 +30,8 @@
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
 #include <linux/in_route.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
 #include <net/route.h>
 #include <net/arp.h>
 #include <net/snmp.h>
@@ -45,6 +47,7 @@
 #define IPSKB_TRANSLATED	2
 #define IPSKB_FORWARDED		4
 #define IPSKB_XFRM_TUNNEL_SIZE	8
+#define IPSKB_XFRM_TRANSFORMED	16
 };
 
 struct ipcm_cookie
@@ -210,6 +213,12 @@
 			iph->id = 0;
 	} else
 		__ip_select_ident(iph, dst, more);
+}
+
+static inline int ip_dst_output(struct sk_buff *skb)
+{
+	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL,
+	                    skb->dst->dev, dst_output, skb->dst->xfrm != NULL);
 }
 
 /*
===== include/net/ipv6.h 1.44 vs edited =====
--- 1.44/include/net/ipv6.h	2005-03-03 06:12:44 +01:00
+++ edited/include/net/ipv6.h	2005-03-23 06:14:52 +01:00
@@ -17,6 +17,8 @@
 
 #include <linux/ipv6.h>
 #include <linux/hardirq.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
 #include <net/ndisc.h>
 #include <net/flow.h>
 #include <net/snmp.h>
@@ -335,6 +337,12 @@
 {
 	return ((a->s6_addr32[0] | a->s6_addr32[1] | 
 		 a->s6_addr32[2] | a->s6_addr32[3] ) == 0); 
+}
+
+static inline int ip6_dst_output(struct sk_buff *skb)
+{
+	return NF_HOOK_COND(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL,
+	                    skb->dst->dev, dst_output, skb->dst->xfrm != NULL);
 }
 
 /*
===== net/ipv4/igmp.c 1.61 vs edited =====
--- 1.61/net/ipv4/igmp.c	2004-12-28 06:30:43 +01:00
+++ edited/net/ipv4/igmp.c	2005-03-23 05:53:14 +01:00
@@ -343,7 +343,7 @@
 	pig->csum = ip_compute_csum((void *)skb->h.igmph, igmplen);
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dev,
-		       dst_output);
+	               ip_dst_output);
 }
 
 static int grec_size(struct ip_mc_list *pmc, int type, int gdel, int sdel)
@@ -674,7 +674,7 @@
 	ih->csum=ip_compute_csum((void *)ih, sizeof(struct igmphdr));
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+	               ip_dst_output);
 }
 
 static void igmp_gq_timer_expire(unsigned long data)
===== net/ipv4/ip_forward.c 1.11 vs edited =====
--- 1.11/net/ipv4/ip_forward.c	2004-07-08 00:17:28 +02:00
+++ edited/net/ipv4/ip_forward.c	2005-03-23 05:53:14 +01:00
@@ -51,7 +51,7 @@
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output(skb);
+	return ip_dst_output(skb);
 }
 
 int ip_forward(struct sk_buff *skb)
===== net/ipv4/ip_output.c 1.80 vs edited =====
--- 1.80/net/ipv4/ip_output.c	2005-03-18 19:43:26 +01:00
+++ edited/net/ipv4/ip_output.c	2005-03-23 06:20:28 +01:00
@@ -166,7 +166,7 @@
 
 	/* Send it out. */
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+		       ip_dst_output);
 }
 
 static inline int ip_finish_output2(struct sk_buff *skb)
@@ -284,7 +284,7 @@
 		return ip_finish_output(skb);
 }
 
-int ip_output(struct sk_buff *skb)
+static inline int ip_output2(struct sk_buff *skb)
 {
 	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 
@@ -294,6 +294,16 @@
 		return ip_finish_output(skb);
 }
 
+int ip_output(struct sk_buff *skb)
+{
+	int transformed = IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED;
+
+	if (transformed)
+		nf_reset(skb);
+	return NF_HOOK_COND(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
+	                    skb->dst->dev, ip_output2, transformed);
+}
+
 int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 {
 	struct sock *sk = skb->sk;
@@ -374,7 +384,7 @@
 	skb->priority = sk->sk_priority;
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+		       ip_dst_output);
 
 no_route:
 	IP_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
@@ -1189,7 +1199,7 @@
 
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, 
-		      skb->dst->dev, dst_output);
+		      skb->dst->dev, ip_dst_output);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
===== net/ipv4/ipmr.c 1.47 vs edited =====
--- 1.47/net/ipv4/ipmr.c	2005-03-18 19:36:11 +01:00
+++ edited/net/ipv4/ipmr.c	2005-03-23 05:53:13 +01:00
@@ -1119,7 +1119,7 @@
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output(skb);
+	return ip_dst_output(skb);
 }
 
 /*
===== net/ipv4/raw.c 1.63 vs edited =====
--- 1.63/net/ipv4/raw.c	2005-03-16 00:20:37 +01:00
+++ edited/net/ipv4/raw.c	2005-03-23 05:53:13 +01:00
@@ -310,7 +310,7 @@
 	}
 
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		      dst_output);
+	              ip_dst_output);
 	if (err > 0)
 		err = inet->recverr ? net_xmit_errno(err) : 0;
 	if (err)
===== net/ipv4/xfrm4_output.c 1.10 vs edited =====
--- 1.10/net/ipv4/xfrm4_output.c	2005-03-18 19:41:26 +01:00
+++ edited/net/ipv4/xfrm4_output.c	2005-03-23 05:53:13 +01:00
@@ -129,6 +129,7 @@
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	err = NET_XMIT_BYPASS;
 
 out_exit:
===== net/ipv4/ipvs/ip_vs_xmit.c 1.13 vs edited =====
--- 1.13/net/ipv4/ipvs/ip_vs_xmit.c	2005-03-18 19:38:59 +01:00
+++ edited/net/ipv4/ipvs/ip_vs_xmit.c	2005-03-24 05:05:57 +01:00
@@ -131,7 +131,7 @@
 	(skb)->nfcache |= NFC_IPVS_PROPERTY;		\
 	(skb)->ip_summed = CHECKSUM_NONE;		\
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
-		(rt)->u.dst.dev, dst_output);		\
+		(rt)->u.dst.dev, ip_dst_output);	\
 } while (0)
 
 
===== net/ipv4/netfilter/ipt_REJECT.c 1.37 vs edited =====
--- 1.37/net/ipv4/netfilter/ipt_REJECT.c	2005-03-17 19:05:37 +01:00
+++ edited/net/ipv4/netfilter/ipt_REJECT.c	2005-03-23 06:05:51 +01:00
@@ -213,7 +213,7 @@
 	nf_ct_attach(nskb, oldskb);
 
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
-		dst_output);
+		ip_dst_output);
 	return;
 
  free_nskb:
===== net/ipv6/ip6_input.c 1.23 vs edited =====
--- 1.23/net/ipv6/ip6_input.c	2005-03-10 06:12:11 +01:00
+++ edited/net/ipv6/ip6_input.c	2005-03-24 05:06:19 +01:00
@@ -241,9 +241,9 @@
 			
 			if (deliver) {
 				skb2 = skb_clone(skb, GFP_ATOMIC);
-				dst_output(skb2);
+				ip6_dst_output(skb2);
 			} else {
-				dst_output(skb);
+				ip6_dst_output(skb);
 				return 0;
 			}
 		}
===== net/ipv6/ip6_output.c 1.91 vs edited =====
--- 1.91/net/ipv6/ip6_output.c	2005-03-18 19:44:52 +01:00
+++ edited/net/ipv6/ip6_output.c	2005-03-24 04:52:01 +01:00
@@ -108,7 +108,7 @@
 }
 
 
-static int ip6_output2(struct sk_buff *skb)
+static int ip6_output3(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct net_device *dev = dst->dev;
@@ -145,12 +145,22 @@
 	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb,NULL, skb->dev,ip6_output_finish);
 }
 
-int ip6_output(struct sk_buff *skb)
+static inline int ip6_output2(struct sk_buff *skb)
 {
 	if (skb->len > dst_mtu(skb->dst) || dst_allfrag(skb->dst))
-		return ip6_fragment(skb, ip6_output2);
+		return ip6_fragment(skb, ip6_output3);
 	else
-		return ip6_output2(skb);
+		return ip6_output3(skb);
+}
+
+int ip6_output(struct sk_buff *skb)
+{
+	int transformed = IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED;
+
+	if (transformed)
+		nf_reset(skb);
+	return NF_HOOK_COND(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL,
+	                    skb->dst->dev, ip6_output2, transformed);
 }
 
 #ifdef CONFIG_NETFILTER
@@ -195,7 +205,7 @@
 		}
 	}
 #endif /* CONFIG_NETFILTER */
-	return dst_output(skb);
+	return ip6_dst_output(skb);
 }
 
 /*
@@ -342,7 +352,7 @@
 
 static inline int ip6_forward_finish(struct sk_buff *skb)
 {
-	return dst_output(skb);
+	return ip6_dst_output(skb);
 }
 
 int ip6_forward(struct sk_buff *skb)
@@ -1146,7 +1156,7 @@
 
 	skb->dst = dst_clone(&rt->u.dst);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);	
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, ip6_dst_output);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
===== net/ipv6/ip6_tunnel.c 1.30 vs edited =====
--- 1.30/net/ipv6/ip6_tunnel.c	2005-03-15 19:19:23 +01:00
+++ edited/net/ipv6/ip6_tunnel.c	2005-03-23 06:08:09 +01:00
@@ -744,7 +744,7 @@
 	nf_reset(skb);
 	pkt_len = skb->len;
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, 
-		      skb->dst->dev, dst_output);
+		      skb->dst->dev, ip6_dst_output);
 
 	if (err == NET_XMIT_SUCCESS || err == NET_XMIT_CN) {
 		stats->tx_bytes += pkt_len;
===== net/ipv6/ndisc.c 1.124 vs edited =====
--- 1.124/net/ipv6/ndisc.c	2005-03-16 23:52:27 +01:00
+++ edited/net/ipv6/ndisc.c	2005-03-23 06:08:42 +01:00
@@ -501,7 +501,7 @@
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTNEIGHBORADVERTISEMENTS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
@@ -586,7 +586,7 @@
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTNEIGHBORSOLICITS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
@@ -660,7 +660,7 @@
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);	
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTROUTERSOLICITS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
@@ -1446,7 +1446,7 @@
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTREDIRECTS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
===== net/ipv6/raw.c 1.79 vs edited =====
--- 1.79/net/ipv6/raw.c	2005-03-03 06:12:38 +01:00
+++ edited/net/ipv6/raw.c	2005-03-23 06:08:54 +01:00
@@ -541,7 +541,7 @@
 
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);		
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		      dst_output);
+		      ip6_dst_output);
 	if (err > 0)
 		err = inet->recverr ? net_xmit_errno(err) : 0;
 	if (err)
===== net/ipv6/xfrm6_output.c 1.11 vs edited =====
--- 1.11/net/ipv6/xfrm6_output.c	2005-03-18 19:41:26 +01:00
+++ edited/net/ipv6/xfrm6_output.c	2005-03-24 04:46:59 +01:00
@@ -131,6 +131,7 @@
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
 	err = NET_XMIT_BYPASS;
 
 out_exit:

--------------010409090802040802080707--
