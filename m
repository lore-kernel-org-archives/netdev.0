From: Andi Kleen <ak@colin2.muc.de>
Subject: Re: [PATCH] Make XFRM optional
Date: 4 Aug 2003 15:04:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030804130408.GA36367@colin2.muc.de>
References: <20030804125022.GA8167@averell> <20030804.215801.124854897.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@muc.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Mon, 4 Aug 2003 15:04:08 +0200
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030804.215801.124854897.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 04, 2003 at 09:58:01PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> Hello.
> 
> In article <20030804125022.GA8167@averell> (at Mon, 4 Aug 2003 14:50:22 +0200), Andi Kleen <ak@muc.de> says:
> 
> > diff -u linux-work/net/ipv6/Kconfig-XFRM linux-work/net/ipv6/Kconfig
> > --- linux-work/net/ipv6/Kconfig-XFRM	2003-07-18 02:39:29.000000000 +0200
> > +++ linux-work/net/ipv6/Kconfig	2003-08-03 23:12:25.000000000 +0200
> > @@ -4,6 +4,7 @@
> >  config IPV6_PRIVACY
> >  	bool "IPv6: Privacy Extensions (RFC 3041) support"
> >  	depends on IPV6
> > +	select XFRM
> >  	select CRYPTO
> >  	select CRYPTO_MD5
> >  	---help---
> 
> We do not need this.

Thanks for the feedback. Here is a new patch with the two hunks 
removed.

-Andi



diff -u linux-work/include/net/dst.h-XFRM linux-work/include/net/dst.h
--- linux-work/include/net/dst.h-XFRM	2003-07-18 02:40:02.000000000 +0200
+++ linux-work/include/net/dst.h	2003-08-03 23:12:24.000000000 +0200
@@ -247,8 +247,16 @@
 extern void		dst_init(void);
 
 struct flowi;
+#ifndef CONFIG_XFRM
+static inline int xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
+		       struct sock *sk, int flags)
+{
+	return 0;
+} 
+#else
 extern int xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
 		       struct sock *sk, int flags);
 #endif
+#endif
 
 #endif /* _NET_DST_H */
diff -u linux-work/include/net/xfrm.h-XFRM linux-work/include/net/xfrm.h
--- linux-work/include/net/xfrm.h-XFRM	2003-07-28 23:12:30.000000000 +0200
+++ linux-work/include/net/xfrm.h	2003-08-03 23:14:04.000000000 +0200
@@ -587,6 +587,8 @@
 	return !0;
 }
 
+#ifdef CONFIG_XFRM
+
 extern int __xfrm_policy_check(struct sock *, int dir, struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, unsigned short family)
@@ -652,6 +654,26 @@
 	}
 }
 
+#else
+
+static inline void xfrm_sk_free_policy(struct sock *sk) {}
+static inline int xfrm_sk_clone_policy(struct sock *sk) { return 0; }
+static inline int xfrm6_route_forward(struct sk_buff *skb) { return 1; }  
+static inline int xfrm4_route_forward(struct sk_buff *skb) { return 1; } 
+static inline int xfrm6_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
+{ 
+	return 1; 
+} 
+static inline int xfrm4_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
+{
+	return 1;
+}
+static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, unsigned short family)
+{
+	return 1;
+}
+#endif
+
 static __inline__
 xfrm_address_t *xfrm_flowi_daddr(struct flowi *fl, unsigned short family)
 {
@@ -782,12 +804,32 @@
 extern int xfrm_check_selectors(struct xfrm_state **x, int n, struct flowi *fl);
 extern int xfrm_check_output(struct xfrm_state *x, struct sk_buff *skb, unsigned short family);
 extern int xfrm4_rcv(struct sk_buff *skb);
-extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_check_size(struct sk_buff *skb);
 extern int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp);
+
+#ifdef CONFIG_XFRM
+extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
 extern int xfrm_user_policy(struct sock *sk, int optname, u8 *optval, int optlen);
+extern int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl, unsigned short family);
+#else
+static inline int xfrm_user_policy(struct sock *sk, int optname, u8 *optval, int optlen)
+{
+ 	return -ENOPROTOOPT;
+} 
+
+static inline int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
+{
+ 	/* should not happen */
+ 	kfree_skb(skb);
+	return 0;
+}
+static inline int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl, unsigned short family)
+{
+	return -EINVAL;
+} 
+#endif
 
 void xfrm_policy_init(void);
 void xfrm4_policy_init(void);
@@ -809,7 +851,6 @@
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struct flowi *fl);
 extern int xfrm_flush_bundles(struct xfrm_state *x);
-extern int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl, unsigned short family);
 
 extern wait_queue_head_t km_waitq;
 extern void km_state_expired(struct xfrm_state *x, int hard);
diff -u linux-work/net/core/skbuff.c-XFRM linux-work/net/core/skbuff.c
--- linux-work/net/core/skbuff.c-XFRM	2003-07-18 02:39:47.000000000 +0200
+++ linux-work/net/core/skbuff.c	2003-08-03 23:12:25.000000000 +0200
@@ -225,7 +225,7 @@
 	}
 
 	dst_release(skb->dst);
-#ifdef CONFIG_INET
+#ifdef CONFIG_XFRM
 	secpath_put(skb->sp);
 #endif
 	if(skb->destructor) {
diff -u linux-work/net/ipv4/Kconfig-XFRM linux-work/net/ipv4/Kconfig
--- linux-work/net/ipv4/Kconfig-XFRM	2003-07-18 02:42:42.000000000 +0200
+++ linux-work/net/ipv4/Kconfig	2003-08-03 23:12:25.000000000 +0200
@@ -187,6 +187,7 @@
 config NET_IPIP
 	tristate "IP: tunneling"
 	depends on INET
+	select XFRM
 	---help---
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
@@ -205,6 +206,7 @@
 config NET_IPGRE
 	tristate "IP: GRE tunnels over IP"
 	depends on INET
+	select XFRM
 	help
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
@@ -343,6 +345,7 @@
 
 config INET_AH
 	tristate "IP: AH transformation"
+	select XFRM
 	select CRYPTO
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
@@ -354,6 +357,7 @@
 
 config INET_ESP
 	tristate "IP: ESP transformation"
+	select XFRM
 	select CRYPTO
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
@@ -366,6 +370,7 @@
 
 config INET_IPCOMP
 	tristate "IP: IPComp transformation"
+	select XFRM
 	select CRYPTO
 	select CRYPTO_DEFLATE
 	---help---
diff -u linux-work/net/ipv4/Makefile-XFRM linux-work/net/ipv4/Makefile
--- linux-work/net/ipv4/Makefile-XFRM	2003-07-18 02:42:42.000000000 +0200
+++ linux-work/net/ipv4/Makefile	2003-08-03 23:12:25.000000000 +0200
@@ -23,4 +23,4 @@
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 obj-$(CONFIG_IP_VS) += ipvs/
 
-obj-y += xfrm4_policy.o xfrm4_state.o xfrm4_input.o xfrm4_tunnel.o
+obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o xfrm4_tunnel.o
diff -u linux-work/net/ipv4/route.c-XFRM linux-work/net/ipv4/route.c
--- linux-work/net/ipv4/route.c-XFRM	2003-07-18 02:39:31.000000000 +0200
+++ linux-work/net/ipv4/route.c	2003-08-03 23:12:25.000000000 +0200
@@ -2785,8 +2785,10 @@
 	create_proc_read_entry("net/rt_acct", 0, 0, ip_rt_acct_read, NULL);
 #endif
 #endif
+#ifdef CONFIG_XFRM
 	xfrm_init();
 	xfrm4_init();
+#endif
 out:
 	return rc;
 out_enomem:
diff -u linux-work/net/ipv4/udp.c-XFRM linux-work/net/ipv4/udp.c
--- linux-work/net/ipv4/udp.c-XFRM	2003-07-18 02:42:43.000000000 +0200
+++ linux-work/net/ipv4/udp.c	2003-08-03 23:31:05.000000000 +0200
@@ -938,6 +938,9 @@
  */
 static int udp_encap_rcv(struct sock * sk, struct sk_buff *skb)
 {
+#ifndef CONFIG_XFRM
+	return 1; 
+#else
 	struct udp_opt *up = udp_sk(sk);
   	struct udphdr *uh = skb->h.uh;
 	struct iphdr *iph;
@@ -997,10 +1000,12 @@
 		return -1;
 
 	default:
-		printk(KERN_INFO "udp_encap_rcv(): Unhandled UDP encap type: %u\n",
-		       encap_type);
+		if (net_ratelimit())
+			printk(KERN_INFO "udp_encap_rcv(): Unhandled UDP encap type: %u\n",
+			       encap_type);
 		return 1;
 	}
+#endif
 }
 
 /* returns:
diff -u linux-work/net/ipv6/Kconfig-XFRM linux-work/net/ipv6/Kconfig
--- linux-work/net/ipv6/Kconfig-XFRM	2003-07-18 02:39:29.000000000 +0200
+++ linux-work/net/ipv6/Kconfig	2003-08-03 23:12:25.000000000 +0200
@@ -22,6 +23,7 @@
 config INET6_AH
 	tristate "IPv6: AH transformation"
 	depends on IPV6
+	select XFRM
 	select CRYPTO
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
@@ -34,6 +36,7 @@
 config INET6_ESP
 	tristate "IPv6: ESP transformation"
 	depends on IPV6
+	select XFRM
 	select CRYPTO
 	select CRYPTO_HMAC
 	select CRYPTO_MD5
@@ -47,6 +50,7 @@
 config INET6_IPCOMP
 	tristate "IPv6: IPComp transformation"
 	depends on IPV6
+	select XFRM
 	select CRYPTO
 	select CRYPTO_DEFLATE
 	---help---
diff -u linux-work/net/ipv6/Makefile-XFRM linux-work/net/ipv6/Makefile
--- linux-work/net/ipv6/Makefile-XFRM	2003-07-18 02:39:29.000000000 +0200
+++ linux-work/net/ipv6/Makefile	2003-08-03 23:12:25.000000000 +0200
@@ -8,8 +8,9 @@
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o raw.o \
 		protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o sysctl_net_ipv6.o datagram.o proc.o \
-		ip6_flowlabel.o ipv6_syms.o \
-		xfrm6_policy.o xfrm6_state.o xfrm6_input.o
+		ip6_flowlabel.o ipv6_syms.o
+
+obj-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o
 
 obj-$(CONFIG_INET6_AH) += ah6.o
 obj-$(CONFIG_INET6_ESP) += esp6.o
diff -u linux-work/net/ipv6/ipv6_syms.c-XFRM linux-work/net/ipv6/ipv6_syms.c
--- linux-work/net/ipv6/ipv6_syms.c-XFRM	2003-07-18 02:39:31.000000000 +0200
+++ linux-work/net/ipv6/ipv6_syms.c	2003-08-03 23:14:41.000000000 +0200
@@ -36,7 +36,9 @@
 EXPORT_SYMBOL(in6addr_loopback);
 EXPORT_SYMBOL(in6_dev_finish_destroy);
 EXPORT_SYMBOL(ip6_find_1stfragopt);
+#ifdef CONFIG_XFRM
 EXPORT_SYMBOL(xfrm6_rcv);
+#endif
 EXPORT_SYMBOL(rt6_lookup);
 EXPORT_SYMBOL(fl6_sock_lookup);
 EXPORT_SYMBOL(ipv6_ext_hdr);
diff -u linux-work/net/ipv6/route.c-XFRM linux-work/net/ipv6/route.c
--- linux-work/net/ipv6/route.c-XFRM	2003-07-28 23:12:32.000000000 +0200
+++ linux-work/net/ipv6/route.c	2003-08-03 23:12:25.000000000 +0200
@@ -1988,7 +1988,9 @@
 	if (p)
 		p->proc_fops = &rt6_stats_seq_fops;
 #endif
+#ifdef CONFIG_XFRM
 	xfrm6_init();
+#endif
 }
 
 #ifdef MODULE
diff -u linux-work/net/xfrm/Kconfig-XFRM linux-work/net/xfrm/Kconfig
--- linux-work/net/xfrm/Kconfig-XFRM	2003-05-27 03:00:40.000000000 +0200
+++ linux-work/net/xfrm/Kconfig	2003-08-03 23:12:25.000000000 +0200
@@ -1,9 +1,13 @@
 #
 # XFRM configuration
 #
+config XFRM
+       bool
+       depends on NET
+
 config XFRM_USER
 	tristate "IPsec user configuration interface"
-	depends on INET
+	depends on INET && XFRM
 	---help---
 	  Support for IPsec user configuration interface used
 	  by native Linux tools.
diff -u linux-work/net/xfrm/Makefile-XFRM linux-work/net/xfrm/Makefile
--- linux-work/net/xfrm/Makefile-XFRM	2003-05-27 03:01:03.000000000 +0200
+++ linux-work/net/xfrm/Makefile	2003-08-03 23:12:25.000000000 +0200
@@ -2,6 +2,7 @@
 # Makefile for the XFRM subsystem.
 #
 
-obj-y := xfrm_policy.o xfrm_state.o xfrm_input.o xfrm_algo.o xfrm_output.o
+obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_input.o xfrm_algo.o xfrm_output.o \
+	xfrm_export.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 
diff -u linux-work/net/xfrm/xfrm_export.c-XFRM linux-work/net/xfrm/xfrm_export.c
--- linux-work/net/xfrm/xfrm_export.c-XFRM	2003-08-03 23:12:25.000000000 +0200
+++ linux-work/net/xfrm/xfrm_export.c	2003-08-03 23:16:06.000000000 +0200
@@ -0,0 +1,76 @@
+#include <linux/module.h>
+#include <net/xfrm.h>
+
+EXPORT_SYMBOL(xfrm_user_policy);
+EXPORT_SYMBOL(km_waitq);
+EXPORT_SYMBOL(km_new_mapping);
+EXPORT_SYMBOL(xfrm_cfg_sem);
+EXPORT_SYMBOL(xfrm_policy_alloc);
+EXPORT_SYMBOL(__xfrm_policy_destroy);
+EXPORT_SYMBOL(xfrm_lookup);
+EXPORT_SYMBOL(__xfrm_policy_check);
+EXPORT_SYMBOL(__xfrm_route_forward);
+EXPORT_SYMBOL(xfrm_state_alloc);
+EXPORT_SYMBOL(__xfrm_state_destroy);
+EXPORT_SYMBOL(xfrm_state_find);
+EXPORT_SYMBOL(xfrm_state_insert);
+EXPORT_SYMBOL(xfrm_state_add);
+EXPORT_SYMBOL(xfrm_state_update);
+EXPORT_SYMBOL(xfrm_state_check_expire);
+EXPORT_SYMBOL(xfrm_state_check_space);
+EXPORT_SYMBOL(xfrm_state_lookup);
+EXPORT_SYMBOL(xfrm_state_register_afinfo);
+EXPORT_SYMBOL(xfrm_state_unregister_afinfo);
+EXPORT_SYMBOL(xfrm_state_get_afinfo);
+EXPORT_SYMBOL(xfrm_state_put_afinfo);
+EXPORT_SYMBOL(xfrm_state_delete_tunnel);
+EXPORT_SYMBOL(xfrm_replay_check);
+EXPORT_SYMBOL(xfrm_replay_advance);
+EXPORT_SYMBOL(xfrm_check_selectors);
+EXPORT_SYMBOL(xfrm_check_output);
+EXPORT_SYMBOL(__secpath_destroy);
+EXPORT_SYMBOL(xfrm_get_acqseq);
+EXPORT_SYMBOL(xfrm_parse_spi);
+EXPORT_SYMBOL(xfrm4_rcv);
+EXPORT_SYMBOL(xfrm4_tunnel_register);
+EXPORT_SYMBOL(xfrm4_tunnel_deregister);
+EXPORT_SYMBOL(xfrm4_tunnel_check_size);
+EXPORT_SYMBOL(xfrm_register_type);
+EXPORT_SYMBOL(xfrm_unregister_type);
+EXPORT_SYMBOL(xfrm_get_type);
+EXPORT_SYMBOL(inet_peer_idlock);
+EXPORT_SYMBOL(xfrm_register_km);
+EXPORT_SYMBOL(xfrm_unregister_km);
+EXPORT_SYMBOL(xfrm_state_delete);
+EXPORT_SYMBOL(xfrm_state_walk);
+EXPORT_SYMBOL(xfrm_find_acq_byseq);
+EXPORT_SYMBOL(xfrm_find_acq);
+EXPORT_SYMBOL(xfrm_alloc_spi);
+EXPORT_SYMBOL(xfrm_state_flush);
+EXPORT_SYMBOL(xfrm_policy_kill);
+EXPORT_SYMBOL(xfrm_policy_bysel);
+EXPORT_SYMBOL(xfrm_policy_insert);
+EXPORT_SYMBOL(xfrm_policy_walk);
+EXPORT_SYMBOL(xfrm_policy_flush);
+EXPORT_SYMBOL(xfrm_policy_byid);
+EXPORT_SYMBOL(xfrm_policy_list);
+EXPORT_SYMBOL(xfrm_dst_lookup);
+EXPORT_SYMBOL(xfrm_policy_register_afinfo);
+EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
+EXPORT_SYMBOL(xfrm_policy_get_afinfo);
+EXPORT_SYMBOL(xfrm_policy_put_afinfo);
+
+EXPORT_SYMBOL_GPL(xfrm_probe_algs);
+EXPORT_SYMBOL_GPL(xfrm_count_auth_supported);
+EXPORT_SYMBOL_GPL(xfrm_count_enc_supported);
+EXPORT_SYMBOL_GPL(xfrm_aalg_get_byidx);
+EXPORT_SYMBOL_GPL(xfrm_ealg_get_byidx);
+EXPORT_SYMBOL_GPL(xfrm_calg_get_byidx);
+EXPORT_SYMBOL_GPL(xfrm_aalg_get_byid);
+EXPORT_SYMBOL_GPL(xfrm_ealg_get_byid);
+EXPORT_SYMBOL_GPL(xfrm_calg_get_byid);
+EXPORT_SYMBOL_GPL(xfrm_aalg_get_byname);
+EXPORT_SYMBOL_GPL(xfrm_ealg_get_byname);
+EXPORT_SYMBOL_GPL(xfrm_calg_get_byname);
+
+EXPORT_SYMBOL_GPL(skb_icv_walk);
diff -u linux-work/net/Kconfig-XFRM linux-work/net/Kconfig
--- linux-work/net/Kconfig-XFRM	2003-05-27 03:00:21.000000000 +0200
+++ linux-work/net/Kconfig	2003-08-03 23:12:24.000000000 +0200
@@ -143,6 +143,7 @@
 
 config NET_KEY
 	tristate "PF_KEY sockets"
+	select XFRM
 	---help---
 	  PF_KEYv2 socket family, compatible to KAME ones.
 	  They are required if you are going to use IPsec tools ported
diff -u linux-work/net/netsyms.c-XFRM linux-work/net/netsyms.c
--- linux-work/net/netsyms.c-XFRM	2003-07-28 23:12:33.000000000 +0200
+++ linux-work/net/netsyms.c	2003-08-03 23:16:23.000000000 +0200
@@ -56,7 +56,6 @@
 #include <linux/inet.h>
 #include <linux/mroute.h>
 #include <linux/igmp.h>
-#include <net/xfrm.h>
 #if defined(CONFIG_INET_AH) || defined(CONFIG_INET_AH_MODULE) || defined(CONFIG_INET6_AH) || defined(CONFIG_INET6_AH_MODULE)
 #include <net/ah.h>
 #endif
@@ -294,78 +293,6 @@
 /* needed for ip_gre -cw */
 EXPORT_SYMBOL(ip_statistics);
 
-EXPORT_SYMBOL(xfrm_user_policy);
-EXPORT_SYMBOL(km_waitq);
-EXPORT_SYMBOL(km_new_mapping);
-EXPORT_SYMBOL(xfrm_cfg_sem);
-EXPORT_SYMBOL(xfrm_policy_alloc);
-EXPORT_SYMBOL(__xfrm_policy_destroy);
-EXPORT_SYMBOL(xfrm_lookup);
-EXPORT_SYMBOL(__xfrm_policy_check);
-EXPORT_SYMBOL(__xfrm_route_forward);
-EXPORT_SYMBOL(xfrm_state_alloc);
-EXPORT_SYMBOL(__xfrm_state_destroy);
-EXPORT_SYMBOL(xfrm_state_find);
-EXPORT_SYMBOL(xfrm_state_insert);
-EXPORT_SYMBOL(xfrm_state_add);
-EXPORT_SYMBOL(xfrm_state_update);
-EXPORT_SYMBOL(xfrm_state_check_expire);
-EXPORT_SYMBOL(xfrm_state_check_space);
-EXPORT_SYMBOL(xfrm_state_lookup);
-EXPORT_SYMBOL(xfrm_state_register_afinfo);
-EXPORT_SYMBOL(xfrm_state_unregister_afinfo);
-EXPORT_SYMBOL(xfrm_state_get_afinfo);
-EXPORT_SYMBOL(xfrm_state_put_afinfo);
-EXPORT_SYMBOL(xfrm_state_delete_tunnel);
-EXPORT_SYMBOL(xfrm_replay_check);
-EXPORT_SYMBOL(xfrm_replay_advance);
-EXPORT_SYMBOL(xfrm_check_selectors);
-EXPORT_SYMBOL(xfrm_check_output);
-EXPORT_SYMBOL(__secpath_destroy);
-EXPORT_SYMBOL(xfrm_get_acqseq);
-EXPORT_SYMBOL(xfrm_parse_spi);
-EXPORT_SYMBOL(xfrm4_rcv);
-EXPORT_SYMBOL(xfrm4_tunnel_register);
-EXPORT_SYMBOL(xfrm4_tunnel_deregister);
-EXPORT_SYMBOL(xfrm4_tunnel_check_size);
-EXPORT_SYMBOL(xfrm_register_type);
-EXPORT_SYMBOL(xfrm_unregister_type);
-EXPORT_SYMBOL(xfrm_get_type);
-EXPORT_SYMBOL(inet_peer_idlock);
-EXPORT_SYMBOL(xfrm_register_km);
-EXPORT_SYMBOL(xfrm_unregister_km);
-EXPORT_SYMBOL(xfrm_state_delete);
-EXPORT_SYMBOL(xfrm_state_walk);
-EXPORT_SYMBOL(xfrm_find_acq_byseq);
-EXPORT_SYMBOL(xfrm_find_acq);
-EXPORT_SYMBOL(xfrm_alloc_spi);
-EXPORT_SYMBOL(xfrm_state_flush);
-EXPORT_SYMBOL(xfrm_policy_kill);
-EXPORT_SYMBOL(xfrm_policy_bysel);
-EXPORT_SYMBOL(xfrm_policy_insert);
-EXPORT_SYMBOL(xfrm_policy_walk);
-EXPORT_SYMBOL(xfrm_policy_flush);
-EXPORT_SYMBOL(xfrm_policy_byid);
-EXPORT_SYMBOL(xfrm_policy_list);
-EXPORT_SYMBOL(xfrm_dst_lookup);
-EXPORT_SYMBOL(xfrm_policy_register_afinfo);
-EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
-EXPORT_SYMBOL(xfrm_policy_get_afinfo);
-EXPORT_SYMBOL(xfrm_policy_put_afinfo);
-
-EXPORT_SYMBOL_GPL(xfrm_probe_algs);
-EXPORT_SYMBOL_GPL(xfrm_count_auth_supported);
-EXPORT_SYMBOL_GPL(xfrm_count_enc_supported);
-EXPORT_SYMBOL_GPL(xfrm_aalg_get_byidx);
-EXPORT_SYMBOL_GPL(xfrm_ealg_get_byidx);
-EXPORT_SYMBOL_GPL(xfrm_calg_get_byidx);
-EXPORT_SYMBOL_GPL(xfrm_aalg_get_byid);
-EXPORT_SYMBOL_GPL(xfrm_ealg_get_byid);
-EXPORT_SYMBOL_GPL(xfrm_calg_get_byid);
-EXPORT_SYMBOL_GPL(xfrm_aalg_get_byname);
-EXPORT_SYMBOL_GPL(xfrm_ealg_get_byname);
-EXPORT_SYMBOL_GPL(xfrm_calg_get_byname);
-EXPORT_SYMBOL_GPL(skb_icv_walk);
 #if defined(CONFIG_INET_ESP) || defined(CONFIG_INET_ESP_MODULE) || defined(CONFIG_INET6_ESP) || defined(CONFIG_INET6_ESP_MODULE)
 EXPORT_SYMBOL_GPL(skb_cow_data);
 EXPORT_SYMBOL_GPL(pskb_put);
