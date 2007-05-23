From: nakam@linux-ipv6.org
Subject: [PATCH 2/2] [IPV6] MIP6: Loadable module support for MIPv6.
Date: Wed, 23 May 2007 16:50:19 +0900
Message-ID: <11799066192758-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:38369 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755807AbXEWIPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 04:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

This patch makes MIPv6 loadable module named "mip6".

Here is a modprobe.conf(5) example to load it automatically
when user application uses XFRM state for MIPv6:

alias xfrm-type-10-43 mip6
alias xfrm-type-10-60 mip6

Some MIPv6 feature is not included by this modular, however,
it should not be affected to other features like either IPsec
or IPv6 with and without the patch.
We may discuss XFRM, MH (RAW socket) and ancillary data/sockopt
separately for future work.

Loadable features:
* MH receiving check (to send ICMP error back)
* RO header parsing and building (i.e. RH2 and HAO in DSTOPTS)
* XFRM policy/state database handling for RO

These are NOT covered as loadable:
* Home Address flags and its rule on source address selection
* XFRM sub policy (depends on its own kernel option)
* XFRM functions to receive RO as IPv6 extension header
* MH sending/receiving through raw socket if user application
  opens it (since raw socket allows to do so)
* RH2 sending as ancillary data
* RH2 operation with setsockopt(2)

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/linux/ipv6.h     |    2 +-
 include/net/addrconf.h   |    2 +-
 include/net/mip6.h       |    4 ----
 include/net/rawv6.h      |    9 +++++++++
 net/ipv6/Kconfig         |    2 +-
 net/ipv6/Makefile        |    2 +-
 net/ipv6/addrconf.c      |    4 ++--
 net/ipv6/af_inet6.c      |   10 +---------
 net/ipv6/ah6.c           |    8 ++++----
 net/ipv6/datagram.c      |    2 +-
 net/ipv6/exthdrs.c       |   19 ++++++++++---------
 net/ipv6/icmp.c          |    2 +-
 net/ipv6/ip6_output.c    |    2 +-
 net/ipv6/ipv6_sockglue.c |    2 +-
 net/ipv6/mip6.c          |   22 +++++++++++++++++++---
 net/ipv6/raw.c           |   34 +++++++++++++++++++++++++++++++---
 net/ipv6/xfrm6_policy.c  |    4 ++--
 net/ipv6/xfrm6_state.c   |    4 ++--
 18 files changed, 88 insertions(+), 46 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 09ea01a..a353860 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -248,7 +248,7 @@ struct inet6_skb_parm {
 	__u16			lastopt;
 	__u32			nhoff;
 	__u16			flags;
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	__u16			dsthao;
 #endif
 
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index f3531d0..33b593e 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -61,7 +61,7 @@ extern int			addrconf_set_dstaddr(void __user *arg);
 extern int			ipv6_chk_addr(struct in6_addr *addr,
 					      struct net_device *dev,
 					      int strict);
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 extern int			ipv6_chk_home_addr(struct in6_addr *addr);
 #endif
 extern struct inet6_ifaddr *	ipv6_get_ifaddr(struct in6_addr *addr,
diff --git a/include/net/mip6.h b/include/net/mip6.h
index 68263c6..6327261 100644
--- a/include/net/mip6.h
+++ b/include/net/mip6.h
@@ -54,8 +54,4 @@ struct ip6_mh {
 #define IP6_MH_TYPE_BERROR	7   /* Binding Error */
 #define IP6_MH_TYPE_MAX		IP6_MH_TYPE_BERROR
 
-extern int mip6_init(void);
-extern void mip6_fini(void);
-extern int mip6_mh_filter(struct sock *sk, struct sk_buff *skb);
-
 #endif
diff --git a/include/net/rawv6.h b/include/net/rawv6.h
index af89608..a581989 100644
--- a/include/net/rawv6.h
+++ b/include/net/rawv6.h
@@ -3,6 +3,8 @@
 
 #ifdef __KERNEL__
 
+#include <net/protocol.h>
+
 #define RAWV6_HTABLE_SIZE	MAX_INET_PROTOS
 extern struct hlist_head raw_v6_htable[RAWV6_HTABLE_SIZE];
 extern rwlock_t raw_v6_lock;
@@ -23,6 +25,13 @@ extern void			rawv6_err(struct sock *sk,
 					  int type, int code, 
 					  int offset, __be32 info);
 
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+int rawv6_mh_filter_register(int (*filter)(struct sock *sock,
+					   struct sk_buff *skb));
+int rawv6_mh_filter_unregister(int (*filter)(struct sock *sock,
+					     struct sk_buff *skb));
+#endif
+
 #endif
 
 #endif
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 8e5d54f..eb0b808 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -109,7 +109,7 @@ config INET6_IPCOMP
 	  If unsure, say Y.
 
 config IPV6_MIP6
-	bool "IPv6: Mobility (EXPERIMENTAL)"
+	tristate "IPv6: Mobility (EXPERIMENTAL)"
 	depends on IPV6 && EXPERIMENTAL
 	select XFRM
 	---help---
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index bb33309..87c23a7 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -14,7 +14,6 @@ ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
 	xfrm6_output.o
 ipv6-$(CONFIG_NETFILTER) += netfilter.o
 ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o
-ipv6-$(CONFIG_IPV6_MIP6) += mip6.o
 ipv6-$(CONFIG_PROC_FS) += proc.o
 
 ipv6-objs += $(ipv6-y)
@@ -28,6 +27,7 @@ obj-$(CONFIG_INET6_XFRM_MODE_TRANSPORT) += xfrm6_mode_transport.o
 obj-$(CONFIG_INET6_XFRM_MODE_TUNNEL) += xfrm6_mode_tunnel.o
 obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
 obj-$(CONFIG_INET6_XFRM_MODE_BEET) += xfrm6_mode_beet.o
+obj-$(CONFIG_IPV6_MIP6) += mip6.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 
 obj-$(CONFIG_IPV6_SIT) += sit.o
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c7ea248..fb63368 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1034,7 +1034,7 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 			}
 
 			/* Rule 4: Prefer home address */
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 			if (hiscore.rule < 4) {
 				if (ifa_result->flags & IFA_F_HOMEADDRESS)
 					hiscore.attrs |= IPV6_SADDR_SCORE_HOA;
@@ -2832,7 +2832,7 @@ void if6_proc_exit(void)
 }
 #endif	/* CONFIG_PROC_FS */
 
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 /* Check if address is a home address configured on any interface. */
 int ipv6_chk_home_addr(struct in6_addr *addr)
 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6dd3772..eed0937 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -58,9 +58,6 @@
 #ifdef CONFIG_IPV6_TUNNEL
 #include <net/ip6_tunnel.h>
 #endif
-#ifdef CONFIG_IPV6_MIP6
-#include <net/mip6.h>
-#endif
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -853,9 +850,6 @@ static int __init inet6_init(void)
 	ipv6_frag_init();
 	ipv6_nodata_init();
 	ipv6_destopt_init();
-#ifdef CONFIG_IPV6_MIP6
-	mip6_init();
-#endif
 
 	/* Init v6 transport protocols. */
 	udpv6_init();
@@ -921,9 +915,7 @@ static void __exit inet6_exit(void)
 
 	/* Cleanup code parts. */
 	ipv6_packet_cleanup();
-#ifdef CONFIG_IPV6_MIP6
-	mip6_fini();
-#endif
+
 	addrconf_cleanup();
 	ip6_flowlabel_cleanup();
 	ip6_route_cleanup();
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 17b8771..7f764f9 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -74,7 +74,7 @@ bad:
 	return 0;
 }
 
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 /**
  *	ipv6_rearrange_destopt - rearrange IPv6 destination options header
  *	@iph: IPv6 header
@@ -228,7 +228,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 nexthdr;
 	char tmp_base[8];
 	struct {
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 		struct in6_addr saddr;
 #endif
 		struct in6_addr daddr;
@@ -255,7 +255,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 			err = -ENOMEM;
 			goto error;
 		}
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 		memcpy(tmp_ext, &top_iph->saddr, extlen);
 #else
 		memcpy(tmp_ext, &top_iph->daddr, extlen);
@@ -294,7 +294,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	memcpy(top_iph, tmp_base, sizeof(tmp_base));
 	if (tmp_ext) {
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 		memcpy(&top_iph->saddr, tmp_ext, extlen);
 #else
 		memcpy(&top_iph->daddr, tmp_ext, extlen);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 403eee6..b94b7e2 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -654,7 +654,7 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 
 			switch (rthdr->type) {
 			case IPV6_SRCRT_TYPE_0:
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 			case IPV6_SRCRT_TYPE_2:
 #endif
 				break;
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 14be0b9..173a4bb 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -42,7 +42,7 @@
 #include <net/ndisc.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 #include <net/xfrm.h>
 #endif
 
@@ -90,6 +90,7 @@ int ipv6_find_tlv(struct sk_buff *skb, int offset, int type)
  bad:
 	return -1;
 }
+EXPORT_SYMBOL_GPL(ipv6_find_tlv);
 
 /*
  *	Parsing tlv encoded headers.
@@ -196,7 +197,7 @@ bad:
   Destination options header.
  *****************************/
 
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 static int ipv6_dest_hao(struct sk_buff **skbp, int optoff)
 {
 	struct sk_buff *skb = *skbp;
@@ -270,7 +271,7 @@ static int ipv6_dest_hao(struct sk_buff **skbp, int optoff)
 #endif
 
 static struct tlvtype_proc tlvprocdestopt_lst[] = {
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	{
 		.type	= IPV6_TLV_HAO,
 		.func	= ipv6_dest_hao,
@@ -283,7 +284,7 @@ static int ipv6_destopt_rcv(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
 	struct inet6_skb_parm *opt = IP6CB(skb);
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	__u16 dstbuf;
 #endif
 	struct dst_entry *dst;
@@ -298,7 +299,7 @@ static int ipv6_destopt_rcv(struct sk_buff **skbp)
 	}
 
 	opt->lastopt = opt->dst1 = skb_network_header_len(skb);
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	dstbuf = opt->dst1;
 #endif
 
@@ -308,7 +309,7 @@ static int ipv6_destopt_rcv(struct sk_buff **skbp)
 		skb = *skbp;
 		skb->transport_header += (skb_transport_header(skb)[1] + 1) << 3;
 		opt = IP6CB(skb);
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 		opt->nhoff = dstbuf;
 #else
 		opt->nhoff = opt->dst1;
@@ -427,7 +428,7 @@ static int ipv6_rthdr_rcv(struct sk_buff **skbp)
 looped_back:
 	if (hdr->segments_left == 0) {
 		switch (hdr->type) {
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 		case IPV6_SRCRT_TYPE_2:
 			/* Silently discard type 2 header unless it was
 			 * processed by own
@@ -463,7 +464,7 @@ looped_back:
 			return -1;
 		}
 		break;
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	case IPV6_SRCRT_TYPE_2:
 		/* Silently discard invalid RTH type 2 */
 		if (hdr->hdrlen != 2 || hdr->segments_left != 1) {
@@ -520,7 +521,7 @@ looped_back:
 	addr += i - 1;
 
 	switch (hdr->type) {
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	case IPV6_SRCRT_TYPE_2:
 		if (xfrm6_input_addr(skb, (xfrm_address_t *)addr,
 				     (xfrm_address_t *)&ipv6_hdr(skb)->saddr,
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index e9bcce9..4765a29 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -272,7 +272,7 @@ static int icmpv6_getfrag(void *from, char *to, int offset, int len, int odd, st
 	return 0;
 }
 
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 static void mip6_addr_swap(struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4704b5f..31dafaf 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -543,7 +543,7 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 			found_rhdr = 1;
 			break;
 		case NEXTHDR_DEST:
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 			if (ipv6_find_tlv(skb, offset, IPV6_TLV_HAO) >= 0)
 				break;
 #endif
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index aa3d07c..b636c38 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -417,7 +417,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			struct ipv6_rt_hdr *rthdr = opt->srcrt;
 			switch (rthdr->type) {
 			case IPV6_SRCRT_TYPE_0:
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 			case IPV6_SRCRT_TYPE_2:
 #endif
 				break;
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 13b7160..20c78ec 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -30,6 +30,7 @@
 #include <net/sock.h>
 #include <net/ipv6.h>
 #include <net/ip6_checksum.h>
+#include <net/rawv6.h>
 #include <net/xfrm.h>
 #include <net/mip6.h>
 
@@ -86,7 +87,7 @@ static int mip6_mh_len(int type)
 	return len;
 }
 
-int mip6_mh_filter(struct sock *sk, struct sk_buff *skb)
+static int mip6_mh_filter(struct sock *sk, struct sk_buff *skb)
 {
 	struct ip6_mh *mh;
 
@@ -471,7 +472,7 @@ static struct xfrm_type mip6_rthdr_type =
 	.remote_addr	= mip6_xfrm_addr,
 };
 
-int __init mip6_init(void)
+static int __init mip6_init(void)
 {
 	printk(KERN_INFO "Mobile IPv6\n");
 
@@ -483,18 +484,33 @@ int __init mip6_init(void)
 		printk(KERN_INFO "%s: can't add xfrm type(rthdr)\n", __FUNCTION__);
 		goto mip6_rthdr_xfrm_fail;
 	}
+	if (rawv6_mh_filter_register(mip6_mh_filter) < 0) {
+		printk(KERN_INFO "%s: can't add rawv6 mh filter\n", __FUNCTION__);
+		goto mip6_rawv6_mh_fail;
+	}
+
+
 	return 0;
 
+ mip6_rawv6_mh_fail:
+	xfrm_unregister_type(&mip6_rthdr_type, AF_INET6);
  mip6_rthdr_xfrm_fail:
 	xfrm_unregister_type(&mip6_destopt_type, AF_INET6);
  mip6_destopt_xfrm_fail:
 	return -EAGAIN;
 }
 
-void __exit mip6_fini(void)
+static void __exit mip6_fini(void)
 {
+	if (rawv6_mh_filter_unregister(mip6_mh_filter) < 0)
+		printk(KERN_INFO "%s: can't remove rawv6 mh filter\n", __FUNCTION__);
 	if (xfrm_unregister_type(&mip6_rthdr_type, AF_INET6) < 0)
 		printk(KERN_INFO "%s: can't remove xfrm type(rthdr)\n", __FUNCTION__);
 	if (xfrm_unregister_type(&mip6_destopt_type, AF_INET6) < 0)
 		printk(KERN_INFO "%s: can't remove xfrm type(destopt)\n", __FUNCTION__);
 }
+
+module_init(mip6_init);
+module_exit(mip6_fini);
+
+MODULE_LICENSE("GPL");
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 71a656d..6056726 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -49,7 +49,7 @@
 #include <net/udp.h>
 #include <net/inet_common.h>
 #include <net/tcp_states.h>
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 #include <net/mip6.h>
 #endif
 
@@ -137,6 +137,28 @@ static __inline__ int icmpv6_filter(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+static int (*mh_filter)(struct sock *sock, struct sk_buff *skb);
+
+int rawv6_mh_filter_register(int (*filter)(struct sock *sock,
+					   struct sk_buff *skb))
+{
+	rcu_assign_pointer(mh_filter, filter);
+	return 0;
+}
+EXPORT_SYMBOL(rawv6_mh_filter_register);
+
+int rawv6_mh_filter_unregister(int (*filter)(struct sock *sock,
+					     struct sk_buff *skb))
+{
+	rcu_assign_pointer(mh_filter, NULL);
+	synchronize_rcu();
+	return 0;
+}
+EXPORT_SYMBOL(rawv6_mh_filter_unregister);
+
+#endif
+
 /*
  *	demultiplex raw sockets.
  *	(should consider queueing the skb in the sock receive_queue
@@ -178,16 +200,22 @@ int ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 		case IPPROTO_ICMPV6:
 			filtered = icmpv6_filter(sk, skb);
 			break;
-#ifdef CONFIG_IPV6_MIP6
+
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 		case IPPROTO_MH:
+		{
 			/* XXX: To validate MH only once for each packet,
 			 * this is placed here. It should be after checking
 			 * xfrm policy, however it doesn't. The checking xfrm
 			 * policy is placed in rawv6_rcv() because it is
 			 * required for each socket.
 			 */
-			filtered = mip6_mh_filter(sk, skb);
+			int (*filter)(struct sock *sock, struct sk_buff *skb);
+
+			filter = rcu_dereference(mh_filter);
+			filtered = filter ? filter(sk, skb) : 0;
 			break;
+		}
 #endif
 		default:
 			filtered = 0;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 1faa2ea..3ec0c47 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -18,7 +18,7 @@
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 #include <net/mip6.h>
 #endif
 
@@ -318,7 +318,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl)
 			fl->proto = nexthdr;
 			return;
 
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 		case IPPROTO_MH:
 			if (pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
 				struct ip6_mh *mh;
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index baa461b..cdadb48 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -65,7 +65,7 @@ __xfrm6_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n)
 		goto end;
 
 	/* Rule 2: select MIPv6 RO or inbound trigger */
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	for (i = 0; i < n; i++) {
 		if (src[i] &&
 		    (src[i]->props.mode == XFRM_MODE_ROUTEOPTIMIZATION ||
@@ -130,7 +130,7 @@ __xfrm6_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n)
 		goto end;
 
 	/* Rule 2: select MIPv6 RO or inbound trigger */
-#ifdef CONFIG_IPV6_MIP6
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	for (i = 0; i < n; i++) {
 		if (src[i] &&
 		    (src[i]->mode == XFRM_MODE_ROUTEOPTIMIZATION ||
-- 
1.4.4.2

