From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Make xfrm subsystem optional
Date: Sat, 14 Jun 2003 11:16:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030614091631.GA16993@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patches only compiles the xfrm subsystem in when any of the options
using it are selected. This shrinks the text segment on an amd64
kernel by ~32k, data by ~6k, bss by ~33k, overall ~72K memory saved.

-Andi


Index: linux/include/net/dst.h
===================================================================
RCS file: /home/cvs/linux-2.5/include/net/dst.h,v
retrieving revision 1.11
diff -u -r1.11 dst.h
--- linux/include/net/dst.h	17 Apr 2003 00:35:02 -0000	1.11
+++ linux/include/net/dst.h	14 Jun 2003 07:58:37 -0000
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
+#endif
 #endif
 
 #endif /* _NET_DST_H */
Index: linux/include/net/xfrm.h
===================================================================
RCS file: /home/cvs/linux-2.5/include/net/xfrm.h,v
retrieving revision 1.34
diff -u -r1.34 xfrm.h
--- linux/include/net/xfrm.h	9 Jun 2003 17:26:52 -0000	1.34
+++ linux/include/net/xfrm.h	14 Jun 2003 07:58:39 -0000
@@ -584,6 +584,8 @@
 	return !0;
 }
 
+#ifdef CONFIG_XFRM
+
 extern int __xfrm_policy_check(struct sock *, int dir, struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, unsigned short family)
@@ -649,6 +651,26 @@
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
@@ -777,13 +799,31 @@
 extern int xfrm_check_selectors(struct xfrm_state **x, int n, struct flowi *fl);
 extern int xfrm_check_output(struct xfrm_state *x, struct sk_buff *skb, unsigned short family);
 extern int xfrm4_rcv(struct sk_buff *skb);
-extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_check_size(struct sk_buff *skb);
 extern int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp);
 extern int xfrm6_clear_mutable_options(struct sk_buff *skb, u16 *nh_offset, int dir);
+#ifdef CONFIG_XFRM
+extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
 extern int xfrm_user_policy(struct sock *sk, int optname, u8 *optval, int optlen);
+extern int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl, unsigned short family);
+#else
+static inline int xfrm_user_policy(struct sock *sk, int optname, u8 *optval, int optlen)
+{
+	return -ENOPROTOOPT;
+} 
+static inline int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
+{
+	/* should not happen */
+	kfree_skb(skb);
+	return 0;
+}
+static inline int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl, unsigned short family)
+{
+	return -EINVAL;
+} 
+#endif
 
 void xfrm_policy_init(void);
 void xfrm4_policy_init(void);
@@ -805,7 +845,6 @@
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struct flowi *fl);
 extern int xfrm_flush_bundles(struct xfrm_state *x);
-extern int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl, unsigned short family);
 
 extern wait_queue_head_t km_waitq;
 extern void km_warn_expired(struct xfrm_state *x);
Index: linux/net/Kconfig
===================================================================
RCS file: /home/cvs/linux-2.5/net/Kconfig,v
retrieving revision 1.14
diff -u -r1.14 Kconfig
--- linux/net/Kconfig	16 May 2003 04:12:42 -0000	1.14
+++ linux/net/Kconfig	14 Jun 2003 07:58:42 -0000
@@ -143,6 +143,7 @@
 
 config NET_KEY
 	tristate "PF_KEY sockets"
+	select XFRM
 	---help---
 	  PF_KEYv2 socket family, compatible to KAME ones.
 	  They are required if you are going to use IPsec tools ported
Index: linux/net/netsyms.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/netsyms.c,v
retrieving revision 1.70
diff -u -r1.70 netsyms.c
--- linux/net/netsyms.c	9 Jun 2003 17:26:52 -0000	1.70
+++ linux/net/netsyms.c	14 Jun 2003 07:58:43 -0000
@@ -56,7 +56,6 @@
 #include <linux/inet.h>
 #include <linux/mroute.h>
 #include <linux/igmp.h>
-#include <net/xfrm.h>
 #if defined(CONFIG_INET_AH) || defined(CONFIG_INET_AH_MODULE) || defined(CONFIG_INET6_AH) || defined(CONFIG_INET6_AH_MODULE)
 #include <net/ah.h>
 #endif
@@ -292,76 +291,6 @@
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
Index: linux/net/core/skbuff.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/core/skbuff.c,v
retrieving revision 1.26
diff -u -r1.26 skbuff.c
--- linux/net/core/skbuff.c	26 May 2003 05:13:42 -0000	1.26
+++ linux/net/core/skbuff.c	14 Jun 2003 07:58:45 -0000
@@ -225,7 +225,7 @@
 	}
 
 	dst_release(skb->dst);
-#ifdef CONFIG_INET
+#ifdef CONFIG_XFRM
 	secpath_put(skb->sp);
 #endif
 	if(skb->destructor) {
Index: linux/net/ipv4/Kconfig
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/Kconfig,v
retrieving revision 1.8
diff -u -r1.8 Kconfig
--- linux/net/ipv4/Kconfig	4 Jun 2003 05:50:13 -0000	1.8
+++ linux/net/ipv4/Kconfig	14 Jun 2003 07:58:46 -0000
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
Index: linux/net/ipv4/Makefile
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/Makefile,v
retrieving revision 1.19
diff -u -r1.19 Makefile
--- linux/net/ipv4/Makefile	4 Jun 2003 05:18:50 -0000	1.19
+++ linux/net/ipv4/Makefile	14 Jun 2003 07:58:46 -0000
@@ -22,4 +22,4 @@
 obj-$(CONFIG_IP_PNP) += ipconfig.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 
-obj-y += xfrm4_policy.o xfrm4_state.o xfrm4_input.o xfrm4_tunnel.o
+obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o xfrm4_tunnel.o
Index: linux/net/ipv4/route.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/route.c,v
retrieving revision 1.52
diff -u -r1.52 route.c
--- linux/net/ipv4/route.c	6 Jun 2003 15:53:37 -0000	1.52
+++ linux/net/ipv4/route.c	14 Jun 2003 07:58:50 -0000
@@ -2727,8 +2727,10 @@
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
Index: linux/net/ipv4/udp.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/udp.c,v
retrieving revision 1.34
diff -u -r1.34 udp.c
--- linux/net/ipv4/udp.c	7 Jun 2003 00:22:34 -0000	1.34
+++ linux/net/ipv4/udp.c	14 Jun 2003 07:58:52 -0000
@@ -945,6 +945,9 @@
  */
 static int udp_encap_rcv(struct sock * sk, struct sk_buff *skb)
 {
+#ifndef CONFIG_XFRM
+	return 1; 
+#else
 	struct udp_opt *up = udp_sk(sk);
   	struct udphdr *uh = skb->h.uh;
 	struct iphdr *iph;
@@ -1004,10 +1007,12 @@
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
Index: linux/net/ipv6/Kconfig
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/Kconfig,v
retrieving revision 1.7
diff -u -r1.7 Kconfig
--- linux/net/ipv6/Kconfig	9 Jun 2003 17:26:52 -0000	1.7
+++ linux/net/ipv6/Kconfig	14 Jun 2003 07:58:53 -0000
@@ -4,6 +4,7 @@
 config IPV6_PRIVACY
 	bool "IPv6: Privacy Extensions (RFC 3041) support"
 	depends on IPV6
+	select XFRM
 	select CRYPTO
 	select CRYPTO_MD5
 	---help---
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
@@ -57,6 +61,7 @@
 
 config IPV6_TUNNEL
 	tristate "IPv6: IPv6-in-IPv6 tunnel"
+	select XFRM
 	depends on IPV6
 	---help---
 	  Support for IPv6-in-IPv6 tunnels described in RFC 2473.
Index: linux/net/ipv6/Makefile
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/Makefile,v
retrieving revision 1.15
diff -u -r1.15 Makefile
--- linux/net/ipv6/Makefile	9 Jun 2003 17:26:52 -0000	1.15
+++ linux/net/ipv6/Makefile	14 Jun 2003 07:58:53 -0000
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
Index: linux/net/ipv6/ipv6_syms.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ipv6_syms.c,v
retrieving revision 1.16
diff -u -r1.16 ipv6_syms.c
--- linux/net/ipv6/ipv6_syms.c	9 Jun 2003 17:26:52 -0000	1.16
+++ linux/net/ipv6/ipv6_syms.c	14 Jun 2003 07:58:53 -0000
@@ -36,8 +36,10 @@
 EXPORT_SYMBOL(in6addr_loopback);
 EXPORT_SYMBOL(in6_dev_finish_destroy);
 EXPORT_SYMBOL(ip6_find_1stfragopt);
+#ifdef CONFIG_XFRM
 EXPORT_SYMBOL(xfrm6_rcv);
 EXPORT_SYMBOL(xfrm6_clear_mutable_options);
+#endif
 EXPORT_SYMBOL(rt6_lookup);
 EXPORT_SYMBOL(fl6_sock_lookup);
 EXPORT_SYMBOL(ipv6_ext_hdr);
Index: linux/net/ipv6/route.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/route.c,v
retrieving revision 1.40
diff -u -r1.40 route.c
--- linux/net/ipv6/route.c	9 Jun 2003 17:26:52 -0000	1.40
+++ linux/net/ipv6/route.c	14 Jun 2003 07:58:56 -0000
@@ -1915,7 +1915,9 @@
 	if (p)
 		p->proc_fops = &rt6_stats_seq_fops;
 #endif
+#ifdef CONFIG_XFRM
 	xfrm6_init();
+#endif
 }
 
 #ifdef MODULE
Index: linux/net/xfrm/Kconfig
===================================================================
RCS file: /home/cvs/linux-2.5/net/xfrm/Kconfig,v
retrieving revision 1.2
diff -u -r1.2 Kconfig
--- linux/net/xfrm/Kconfig	25 Mar 2003 18:55:43 -0000	1.2
+++ linux/net/xfrm/Kconfig	14 Jun 2003 07:58:57 -0000
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
Index: linux/net/xfrm/Makefile
===================================================================
RCS file: /home/cvs/linux-2.5/net/xfrm/Makefile,v
retrieving revision 1.3
diff -u -r1.3 Makefile
--- linux/net/xfrm/Makefile	4 May 2003 14:10:04 -0000	1.3
+++ linux/net/xfrm/Makefile	14 Jun 2003 07:58:57 -0000
@@ -2,6 +2,7 @@
 # Makefile for the XFRM subsystem.
 #
 
-obj-y := xfrm_policy.o xfrm_state.o xfrm_input.o xfrm_algo.o xfrm_output.o
+obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_input.o xfrm_algo.o xfrm_output.o \
+	xfrm_export.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 
--- /dev/null	2003-03-04 04:26:28.000000000 +0100
+++ linux-2.5/net/xfrm/xfrm_export.c	2003-06-14 10:36:49.000000000 +0200
@@ -0,0 +1,74 @@
+
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
