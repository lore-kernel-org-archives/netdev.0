From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/12] netfilter: move socket lookup infrastructure to nf_socket_ipv{4,6}.c
Date: Tue,  1 Nov 2016 22:26:30 +0100
Message-ID: <1478035593-1362-10-git-send-email-pablo@netfilter.org>
References: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52630 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932410AbcKAV1K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 17:27:10 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6AEA01683A3
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:08 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4D042BAC35
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:08 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 636AEBAC39
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:05 +0100 (CET)
In-Reply-To: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need this split to reuse existing codebase for the upcoming nf_tables
socket expression.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_socket.h   |  27 ++++
 net/ipv4/netfilter/Kconfig          |   6 +
 net/ipv4/netfilter/Makefile         |   2 +
 net/ipv4/netfilter/nf_socket_ipv4.c | 163 +++++++++++++++++++
 net/ipv6/netfilter/Kconfig          |   6 +
 net/ipv6/netfilter/Makefile         |   2 +
 net/ipv6/netfilter/nf_socket_ipv6.c | 151 ++++++++++++++++++
 net/netfilter/Kconfig               |   3 +-
 net/netfilter/xt_socket.c           | 305 ++----------------------------------
 9 files changed, 369 insertions(+), 296 deletions(-)
 create mode 100644 include/net/netfilter/nf_socket.h
 create mode 100644 net/ipv4/netfilter/nf_socket_ipv4.c
 create mode 100644 net/ipv6/netfilter/nf_socket_ipv6.c

diff --git a/include/net/netfilter/nf_socket.h b/include/net/netfilter/nf_socket.h
new file mode 100644
index 000000000000..f2fc39c97d43
--- /dev/null
+++ b/include/net/netfilter/nf_socket.h
@@ -0,0 +1,27 @@
+#ifndef _NF_SOCK_H_
+#define _NF_SOCK_H_
+
+struct net_device;
+struct sk_buff;
+struct sock;
+struct net;
+
+static inline bool nf_sk_is_transparent(struct sock *sk)
+{
+	switch (sk->sk_state) {
+	case TCP_TIME_WAIT:
+		return inet_twsk(sk)->tw_transparent;
+	case TCP_NEW_SYN_RECV:
+		return inet_rsk(inet_reqsk(sk))->no_srccheck;
+	default:
+		return inet_sk(sk)->transparent;
+	}
+}
+
+struct sock *nf_sk_lookup_slow_v4(struct net *net, const struct sk_buff *skb,
+				  const struct net_device *indev);
+
+struct sock *nf_sk_lookup_slow_v6(struct net *net, const struct sk_buff *skb,
+				  const struct net_device *indev);
+
+#endif
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index f80bb8f457c8..c11eb1744ab1 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -25,6 +25,12 @@ config NF_CONNTRACK_IPV4
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NF_SOCKET_IPV4
+	tristate "IPv4 socket lookup support"
+	help
+	  This option enables the IPv4 socket lookup infrastructure. This is
+	  is required by the iptables socket match.
+
 if NF_TABLES
 
 config NF_TABLES_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 59d7786ddce1..f462fee66ac8 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -14,6 +14,8 @@ obj-$(CONFIG_NF_NAT_IPV4) += nf_nat_ipv4.o
 # defrag
 obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 
+obj-$(CONFIG_NF_SOCKET_IPV4) += nf_socket_ipv4.o
+
 # logging
 obj-$(CONFIG_NF_LOG_ARP) += nf_log_arp.o
 obj-$(CONFIG_NF_LOG_IPV4) += nf_log_ipv4.o
diff --git a/net/ipv4/netfilter/nf_socket_ipv4.c b/net/ipv4/netfilter/nf_socket_ipv4.c
new file mode 100644
index 000000000000..a83d558e1aae
--- /dev/null
+++ b/net/ipv4/netfilter/nf_socket_ipv4.c
@@ -0,0 +1,163 @@
+/*
+ * Copyright (C) 2007-2008 BalaBit IT Ltd.
+ * Author: Krisztian Kovacs
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+#include <net/icmp.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <net/netfilter/nf_socket.h>
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+#include <net/netfilter/nf_conntrack.h>
+#endif
+
+static int
+extract_icmp4_fields(const struct sk_buff *skb, u8 *protocol,
+		     __be32 *raddr, __be32 *laddr,
+		     __be16 *rport, __be16 *lport)
+{
+	unsigned int outside_hdrlen = ip_hdrlen(skb);
+	struct iphdr *inside_iph, _inside_iph;
+	struct icmphdr *icmph, _icmph;
+	__be16 *ports, _ports[2];
+
+	icmph = skb_header_pointer(skb, outside_hdrlen,
+				   sizeof(_icmph), &_icmph);
+	if (icmph == NULL)
+		return 1;
+
+	switch (icmph->type) {
+	case ICMP_DEST_UNREACH:
+	case ICMP_SOURCE_QUENCH:
+	case ICMP_REDIRECT:
+	case ICMP_TIME_EXCEEDED:
+	case ICMP_PARAMETERPROB:
+		break;
+	default:
+		return 1;
+	}
+
+	inside_iph = skb_header_pointer(skb, outside_hdrlen +
+					sizeof(struct icmphdr),
+					sizeof(_inside_iph), &_inside_iph);
+	if (inside_iph == NULL)
+		return 1;
+
+	if (inside_iph->protocol != IPPROTO_TCP &&
+	    inside_iph->protocol != IPPROTO_UDP)
+		return 1;
+
+	ports = skb_header_pointer(skb, outside_hdrlen +
+				   sizeof(struct icmphdr) +
+				   (inside_iph->ihl << 2),
+				   sizeof(_ports), &_ports);
+	if (ports == NULL)
+		return 1;
+
+	/* the inside IP packet is the one quoted from our side, thus
+	 * its saddr is the local address */
+	*protocol = inside_iph->protocol;
+	*laddr = inside_iph->saddr;
+	*lport = ports[0];
+	*raddr = inside_iph->daddr;
+	*rport = ports[1];
+
+	return 0;
+}
+
+static struct sock *
+nf_socket_get_sock_v4(struct net *net, struct sk_buff *skb, const int doff,
+		      const u8 protocol,
+		      const __be32 saddr, const __be32 daddr,
+		      const __be16 sport, const __be16 dport,
+		      const struct net_device *in)
+{
+	switch (protocol) {
+	case IPPROTO_TCP:
+		return inet_lookup(net, &tcp_hashinfo, skb, doff,
+				   saddr, sport, daddr, dport,
+				   in->ifindex);
+	case IPPROTO_UDP:
+		return udp4_lib_lookup(net, saddr, sport, daddr, dport,
+				       in->ifindex);
+	}
+	return NULL;
+}
+
+struct sock *nf_sk_lookup_slow_v4(struct net *net, const struct sk_buff *skb,
+				  const struct net_device *indev)
+{
+	__be32 uninitialized_var(daddr), uninitialized_var(saddr);
+	__be16 uninitialized_var(dport), uninitialized_var(sport);
+	const struct iphdr *iph = ip_hdr(skb);
+	struct sk_buff *data_skb = NULL;
+	u8 uninitialized_var(protocol);
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn const *ct;
+#endif
+	int doff = 0;
+
+	if (iph->protocol == IPPROTO_UDP || iph->protocol == IPPROTO_TCP) {
+		struct udphdr _hdr, *hp;
+
+		hp = skb_header_pointer(skb, ip_hdrlen(skb),
+					sizeof(_hdr), &_hdr);
+		if (hp == NULL)
+			return NULL;
+
+		protocol = iph->protocol;
+		saddr = iph->saddr;
+		sport = hp->source;
+		daddr = iph->daddr;
+		dport = hp->dest;
+		data_skb = (struct sk_buff *)skb;
+		doff = iph->protocol == IPPROTO_TCP ?
+			ip_hdrlen(skb) + __tcp_hdrlen((struct tcphdr *)hp) :
+			ip_hdrlen(skb) + sizeof(*hp);
+
+	} else if (iph->protocol == IPPROTO_ICMP) {
+		if (extract_icmp4_fields(skb, &protocol, &saddr, &daddr,
+					 &sport, &dport))
+			return NULL;
+	} else {
+		return NULL;
+	}
+
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	/* Do the lookup with the original socket address in
+	 * case this is a reply packet of an established
+	 * SNAT-ted connection.
+	 */
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct && !nf_ct_is_untracked(ct) &&
+	    ((iph->protocol != IPPROTO_ICMP &&
+	      ctinfo == IP_CT_ESTABLISHED_REPLY) ||
+	     (iph->protocol == IPPROTO_ICMP &&
+	      ctinfo == IP_CT_RELATED_REPLY)) &&
+	    (ct->status & IPS_SRC_NAT_DONE)) {
+
+		daddr = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip;
+		dport = (iph->protocol == IPPROTO_TCP) ?
+			ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.tcp.port :
+			ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.udp.port;
+	}
+#endif
+
+	return nf_socket_get_sock_v4(net, data_skb, doff, protocol, saddr,
+				     daddr, sport, dport, indev);
+}
+EXPORT_SYMBOL_GPL(nf_sk_lookup_slow_v4);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Krisztian Kovacs, Balazs Scheidler");
+MODULE_DESCRIPTION("Netfilter IPv4 socket lookup infrastructure");
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 144f1de33836..6acb2eecd986 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -25,6 +25,12 @@ config NF_CONNTRACK_IPV6
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NF_SOCKET_IPV6
+	tristate "IPv6 socket lookup support"
+	help
+	  This option enables the IPv6 socket lookup infrastructure. This
+	  is used by the ip6tables socket match.
+
 if NF_TABLES
 
 config NF_TABLES_IPV6
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 7984f3071f05..fe180c96040e 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -24,6 +24,8 @@ obj-$(CONFIG_NF_NAT_MASQUERADE_IPV6) += nf_nat_masquerade_ipv6.o
 nf_defrag_ipv6-y := nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
 obj-$(CONFIG_NF_DEFRAG_IPV6) += nf_defrag_ipv6.o
 
+obj-$(CONFIG_NF_SOCKET_IPV6) += nf_socket_ipv6.o
+
 # logging
 obj-$(CONFIG_NF_LOG_IPV6) += nf_log_ipv6.o
 
diff --git a/net/ipv6/netfilter/nf_socket_ipv6.c b/net/ipv6/netfilter/nf_socket_ipv6.c
new file mode 100644
index 000000000000..ebb2bf84232a
--- /dev/null
+++ b/net/ipv6/netfilter/nf_socket_ipv6.c
@@ -0,0 +1,151 @@
+/*
+ * Copyright (C) 2007-2008 BalaBit IT Ltd.
+ * Author: Krisztian Kovacs
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+#include <net/icmp.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <net/inet6_hashtables.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
+#include <net/netfilter/nf_socket.h>
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+#include <net/netfilter/nf_conntrack.h>
+#endif
+
+static int
+extract_icmp6_fields(const struct sk_buff *skb,
+		     unsigned int outside_hdrlen,
+		     int *protocol,
+		     const struct in6_addr **raddr,
+		     const struct in6_addr **laddr,
+		     __be16 *rport,
+		     __be16 *lport,
+		     struct ipv6hdr *ipv6_var)
+{
+	const struct ipv6hdr *inside_iph;
+	struct icmp6hdr *icmph, _icmph;
+	__be16 *ports, _ports[2];
+	u8 inside_nexthdr;
+	__be16 inside_fragoff;
+	int inside_hdrlen;
+
+	icmph = skb_header_pointer(skb, outside_hdrlen,
+				   sizeof(_icmph), &_icmph);
+	if (icmph == NULL)
+		return 1;
+
+	if (icmph->icmp6_type & ICMPV6_INFOMSG_MASK)
+		return 1;
+
+	inside_iph = skb_header_pointer(skb, outside_hdrlen + sizeof(_icmph),
+					sizeof(*ipv6_var), ipv6_var);
+	if (inside_iph == NULL)
+		return 1;
+	inside_nexthdr = inside_iph->nexthdr;
+
+	inside_hdrlen = ipv6_skip_exthdr(skb, outside_hdrlen + sizeof(_icmph) +
+					      sizeof(*ipv6_var),
+					 &inside_nexthdr, &inside_fragoff);
+	if (inside_hdrlen < 0)
+		return 1; /* hjm: Packet has no/incomplete transport layer headers. */
+
+	if (inside_nexthdr != IPPROTO_TCP &&
+	    inside_nexthdr != IPPROTO_UDP)
+		return 1;
+
+	ports = skb_header_pointer(skb, inside_hdrlen,
+				   sizeof(_ports), &_ports);
+	if (ports == NULL)
+		return 1;
+
+	/* the inside IP packet is the one quoted from our side, thus
+	 * its saddr is the local address */
+	*protocol = inside_nexthdr;
+	*laddr = &inside_iph->saddr;
+	*lport = ports[0];
+	*raddr = &inside_iph->daddr;
+	*rport = ports[1];
+
+	return 0;
+}
+
+static struct sock *
+nf_socket_get_sock_v6(struct net *net, struct sk_buff *skb, int doff,
+		      const u8 protocol,
+		      const struct in6_addr *saddr, const struct in6_addr *daddr,
+		      const __be16 sport, const __be16 dport,
+		      const struct net_device *in)
+{
+	switch (protocol) {
+	case IPPROTO_TCP:
+		return inet6_lookup(net, &tcp_hashinfo, skb, doff,
+				    saddr, sport, daddr, dport,
+				    in->ifindex);
+	case IPPROTO_UDP:
+		return udp6_lib_lookup(net, saddr, sport, daddr, dport,
+				       in->ifindex);
+	}
+
+	return NULL;
+}
+
+struct sock *nf_sk_lookup_slow_v6(struct net *net, const struct sk_buff *skb,
+				  const struct net_device *indev)
+{
+	__be16 uninitialized_var(dport), uninitialized_var(sport);
+	const struct in6_addr *daddr = NULL, *saddr = NULL;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct sk_buff *data_skb = NULL;
+	int doff = 0;
+	int thoff = 0, tproto;
+
+	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
+	if (tproto < 0) {
+		pr_debug("unable to find transport header in IPv6 packet, dropping\n");
+		return NULL;
+	}
+
+	if (tproto == IPPROTO_UDP || tproto == IPPROTO_TCP) {
+		struct udphdr _hdr, *hp;
+
+		hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
+		if (hp == NULL)
+			return NULL;
+
+		saddr = &iph->saddr;
+		sport = hp->source;
+		daddr = &iph->daddr;
+		dport = hp->dest;
+		data_skb = (struct sk_buff *)skb;
+		doff = tproto == IPPROTO_TCP ?
+			thoff + __tcp_hdrlen((struct tcphdr *)hp) :
+			thoff + sizeof(*hp);
+
+	} else if (tproto == IPPROTO_ICMPV6) {
+		struct ipv6hdr ipv6_var;
+
+		if (extract_icmp6_fields(skb, thoff, &tproto, &saddr, &daddr,
+					 &sport, &dport, &ipv6_var))
+			return NULL;
+	} else {
+		return NULL;
+	}
+
+	return nf_socket_get_sock_v6(net, data_skb, doff, tproto, saddr, daddr,
+				     sport, dport, indev);
+}
+EXPORT_SYMBOL_GPL(nf_sk_lookup_slow_v6);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Krisztian Kovacs, Balazs Scheidler");
+MODULE_DESCRIPTION("Netfilter IPv6 socket lookup infrastructure");
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 854dadb196a1..ed00ec114ea2 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -1426,9 +1426,10 @@ config NETFILTER_XT_MATCH_SOCKET
 	tristate '"socket" match support'
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
-	depends on !NF_CONNTRACK || NF_CONNTRACK
 	depends on IPV6 || IPV6=n
 	depends on IP6_NF_IPTABLES || IP6_NF_IPTABLES=n
+	depends on NF_SOCKET_IPV4
+	depends on NF_SOCKET_IPV6
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES != n
 	help
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index b10ade272b50..018c369c9f0d 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -22,76 +22,14 @@
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
-#define XT_SOCKET_HAVE_IPV6 1
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/inet6_hashtables.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 #endif
 
+#include <net/netfilter/nf_socket.h>
 #include <linux/netfilter/xt_socket.h>
 
-#if IS_ENABLED(CONFIG_NF_CONNTRACK)
-#define XT_SOCKET_HAVE_CONNTRACK 1
-#include <net/netfilter/nf_conntrack.h>
-#endif
-
-static int
-extract_icmp4_fields(const struct sk_buff *skb,
-		    u8 *protocol,
-		    __be32 *raddr,
-		    __be32 *laddr,
-		    __be16 *rport,
-		    __be16 *lport)
-{
-	unsigned int outside_hdrlen = ip_hdrlen(skb);
-	struct iphdr *inside_iph, _inside_iph;
-	struct icmphdr *icmph, _icmph;
-	__be16 *ports, _ports[2];
-
-	icmph = skb_header_pointer(skb, outside_hdrlen,
-				   sizeof(_icmph), &_icmph);
-	if (icmph == NULL)
-		return 1;
-
-	switch (icmph->type) {
-	case ICMP_DEST_UNREACH:
-	case ICMP_SOURCE_QUENCH:
-	case ICMP_REDIRECT:
-	case ICMP_TIME_EXCEEDED:
-	case ICMP_PARAMETERPROB:
-		break;
-	default:
-		return 1;
-	}
-
-	inside_iph = skb_header_pointer(skb, outside_hdrlen +
-					sizeof(struct icmphdr),
-					sizeof(_inside_iph), &_inside_iph);
-	if (inside_iph == NULL)
-		return 1;
-
-	if (inside_iph->protocol != IPPROTO_TCP &&
-	    inside_iph->protocol != IPPROTO_UDP)
-		return 1;
-
-	ports = skb_header_pointer(skb, outside_hdrlen +
-				   sizeof(struct icmphdr) +
-				   (inside_iph->ihl << 2),
-				   sizeof(_ports), &_ports);
-	if (ports == NULL)
-		return 1;
-
-	/* the inside IP packet is the one quoted from our side, thus
-	 * its saddr is the local address */
-	*protocol = inside_iph->protocol;
-	*laddr = inside_iph->saddr;
-	*lport = ports[0];
-	*raddr = inside_iph->daddr;
-	*rport = ports[1];
-
-	return 0;
-}
-
 /* "socket" match based redirection (no specific rule)
  * ===================================================
  *
@@ -111,104 +49,6 @@ extract_icmp4_fields(const struct sk_buff *skb,
  *     then local services could intercept traffic going through the
  *     box.
  */
-static struct sock *
-xt_socket_get_sock_v4(struct net *net, struct sk_buff *skb, const int doff,
-		      const u8 protocol,
-		      const __be32 saddr, const __be32 daddr,
-		      const __be16 sport, const __be16 dport,
-		      const struct net_device *in)
-{
-	switch (protocol) {
-	case IPPROTO_TCP:
-		return inet_lookup(net, &tcp_hashinfo, skb, doff,
-				   saddr, sport, daddr, dport,
-				   in->ifindex);
-	case IPPROTO_UDP:
-		return udp4_lib_lookup(net, saddr, sport, daddr, dport,
-				       in->ifindex);
-	}
-	return NULL;
-}
-
-static bool xt_socket_sk_is_transparent(struct sock *sk)
-{
-	switch (sk->sk_state) {
-	case TCP_TIME_WAIT:
-		return inet_twsk(sk)->tw_transparent;
-
-	case TCP_NEW_SYN_RECV:
-		return inet_rsk(inet_reqsk(sk))->no_srccheck;
-
-	default:
-		return inet_sk(sk)->transparent;
-	}
-}
-
-static struct sock *xt_socket_lookup_slow_v4(struct net *net,
-					     const struct sk_buff *skb,
-					     const struct net_device *indev)
-{
-	const struct iphdr *iph = ip_hdr(skb);
-	struct sk_buff *data_skb = NULL;
-	int doff = 0;
-	__be32 uninitialized_var(daddr), uninitialized_var(saddr);
-	__be16 uninitialized_var(dport), uninitialized_var(sport);
-	u8 uninitialized_var(protocol);
-#ifdef XT_SOCKET_HAVE_CONNTRACK
-	struct nf_conn const *ct;
-	enum ip_conntrack_info ctinfo;
-#endif
-
-	if (iph->protocol == IPPROTO_UDP || iph->protocol == IPPROTO_TCP) {
-		struct udphdr _hdr, *hp;
-
-		hp = skb_header_pointer(skb, ip_hdrlen(skb),
-					sizeof(_hdr), &_hdr);
-		if (hp == NULL)
-			return NULL;
-
-		protocol = iph->protocol;
-		saddr = iph->saddr;
-		sport = hp->source;
-		daddr = iph->daddr;
-		dport = hp->dest;
-		data_skb = (struct sk_buff *)skb;
-		doff = iph->protocol == IPPROTO_TCP ?
-			ip_hdrlen(skb) + __tcp_hdrlen((struct tcphdr *)hp) :
-			ip_hdrlen(skb) + sizeof(*hp);
-
-	} else if (iph->protocol == IPPROTO_ICMP) {
-		if (extract_icmp4_fields(skb, &protocol, &saddr, &daddr,
-					 &sport, &dport))
-			return NULL;
-	} else {
-		return NULL;
-	}
-
-#ifdef XT_SOCKET_HAVE_CONNTRACK
-	/* Do the lookup with the original socket address in
-	 * case this is a reply packet of an established
-	 * SNAT-ted connection.
-	 */
-	ct = nf_ct_get(skb, &ctinfo);
-	if (ct && !nf_ct_is_untracked(ct) &&
-	    ((iph->protocol != IPPROTO_ICMP &&
-	      ctinfo == IP_CT_ESTABLISHED_REPLY) ||
-	     (iph->protocol == IPPROTO_ICMP &&
-	      ctinfo == IP_CT_RELATED_REPLY)) &&
-	    (ct->status & IPS_SRC_NAT_DONE)) {
-
-		daddr = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip;
-		dport = (iph->protocol == IPPROTO_TCP) ?
-			ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.tcp.port :
-			ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.udp.port;
-	}
-#endif
-
-	return xt_socket_get_sock_v4(net, data_skb, doff, protocol, saddr,
-				     daddr, sport, dport, indev);
-}
-
 static bool
 socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	     const struct xt_socket_mtinfo1 *info)
@@ -217,7 +57,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	struct sock *sk = skb->sk;
 
 	if (!sk)
-		sk = xt_socket_lookup_slow_v4(par->net, skb, par->in);
+		sk = nf_sk_lookup_slow_v4(par->net, skb, par->in);
 	if (sk) {
 		bool wildcard;
 		bool transparent = true;
@@ -233,7 +73,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 		 * if XT_SOCKET_TRANSPARENT is used
 		 */
 		if (info->flags & XT_SOCKET_TRANSPARENT)
-			transparent = xt_socket_sk_is_transparent(sk);
+			transparent = nf_sk_is_transparent(sk);
 
 		if (info->flags & XT_SOCKET_RESTORESKMARK && !wildcard &&
 		    transparent)
@@ -265,132 +105,7 @@ socket_mt4_v1_v2_v3(const struct sk_buff *skb, struct xt_action_param *par)
 	return socket_match(skb, par, par->matchinfo);
 }
 
-#ifdef XT_SOCKET_HAVE_IPV6
-
-static int
-extract_icmp6_fields(const struct sk_buff *skb,
-		     unsigned int outside_hdrlen,
-		     int *protocol,
-		     const struct in6_addr **raddr,
-		     const struct in6_addr **laddr,
-		     __be16 *rport,
-		     __be16 *lport,
-		     struct ipv6hdr *ipv6_var)
-{
-	const struct ipv6hdr *inside_iph;
-	struct icmp6hdr *icmph, _icmph;
-	__be16 *ports, _ports[2];
-	u8 inside_nexthdr;
-	__be16 inside_fragoff;
-	int inside_hdrlen;
-
-	icmph = skb_header_pointer(skb, outside_hdrlen,
-				   sizeof(_icmph), &_icmph);
-	if (icmph == NULL)
-		return 1;
-
-	if (icmph->icmp6_type & ICMPV6_INFOMSG_MASK)
-		return 1;
-
-	inside_iph = skb_header_pointer(skb, outside_hdrlen + sizeof(_icmph),
-					sizeof(*ipv6_var), ipv6_var);
-	if (inside_iph == NULL)
-		return 1;
-	inside_nexthdr = inside_iph->nexthdr;
-
-	inside_hdrlen = ipv6_skip_exthdr(skb, outside_hdrlen + sizeof(_icmph) +
-					      sizeof(*ipv6_var),
-					 &inside_nexthdr, &inside_fragoff);
-	if (inside_hdrlen < 0)
-		return 1; /* hjm: Packet has no/incomplete transport layer headers. */
-
-	if (inside_nexthdr != IPPROTO_TCP &&
-	    inside_nexthdr != IPPROTO_UDP)
-		return 1;
-
-	ports = skb_header_pointer(skb, inside_hdrlen,
-				   sizeof(_ports), &_ports);
-	if (ports == NULL)
-		return 1;
-
-	/* the inside IP packet is the one quoted from our side, thus
-	 * its saddr is the local address */
-	*protocol = inside_nexthdr;
-	*laddr = &inside_iph->saddr;
-	*lport = ports[0];
-	*raddr = &inside_iph->daddr;
-	*rport = ports[1];
-
-	return 0;
-}
-
-static struct sock *
-xt_socket_get_sock_v6(struct net *net, struct sk_buff *skb, int doff,
-		      const u8 protocol,
-		      const struct in6_addr *saddr, const struct in6_addr *daddr,
-		      const __be16 sport, const __be16 dport,
-		      const struct net_device *in)
-{
-	switch (protocol) {
-	case IPPROTO_TCP:
-		return inet6_lookup(net, &tcp_hashinfo, skb, doff,
-				    saddr, sport, daddr, dport,
-				    in->ifindex);
-	case IPPROTO_UDP:
-		return udp6_lib_lookup(net, saddr, sport, daddr, dport,
-				       in->ifindex);
-	}
-
-	return NULL;
-}
-
-static struct sock *xt_socket_lookup_slow_v6(struct net *net,
-					     const struct sk_buff *skb,
-					     const struct net_device *indev)
-{
-	__be16 uninitialized_var(dport), uninitialized_var(sport);
-	const struct in6_addr *daddr = NULL, *saddr = NULL;
-	struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct sk_buff *data_skb = NULL;
-	int doff = 0;
-	int thoff = 0, tproto;
-
-	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
-	if (tproto < 0) {
-		pr_debug("unable to find transport header in IPv6 packet, dropping\n");
-		return NULL;
-	}
-
-	if (tproto == IPPROTO_UDP || tproto == IPPROTO_TCP) {
-		struct udphdr _hdr, *hp;
-
-		hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
-		if (hp == NULL)
-			return NULL;
-
-		saddr = &iph->saddr;
-		sport = hp->source;
-		daddr = &iph->daddr;
-		dport = hp->dest;
-		data_skb = (struct sk_buff *)skb;
-		doff = tproto == IPPROTO_TCP ?
-			thoff + __tcp_hdrlen((struct tcphdr *)hp) :
-			thoff + sizeof(*hp);
-
-	} else if (tproto == IPPROTO_ICMPV6) {
-		struct ipv6hdr ipv6_var;
-
-		if (extract_icmp6_fields(skb, thoff, &tproto, &saddr, &daddr,
-					 &sport, &dport, &ipv6_var))
-			return NULL;
-	} else {
-		return NULL;
-	}
-
-	return xt_socket_get_sock_v6(net, data_skb, doff, tproto, saddr, daddr,
-				     sport, dport, indev);
-}
-
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 static bool
 socket_mt6_v1_v2_v3(const struct sk_buff *skb, struct xt_action_param *par)
 {
@@ -399,7 +114,7 @@ socket_mt6_v1_v2_v3(const struct sk_buff *skb, struct xt_action_param *par)
 	struct sock *sk = skb->sk;
 
 	if (!sk)
-		sk = xt_socket_lookup_slow_v6(par->net, skb, par->in);
+		sk = nf_sk_lookup_slow_v6(par->net, skb, par->in);
 	if (sk) {
 		bool wildcard;
 		bool transparent = true;
@@ -415,7 +130,7 @@ socket_mt6_v1_v2_v3(const struct sk_buff *skb, struct xt_action_param *par)
 		 * if XT_SOCKET_TRANSPARENT is used
 		 */
 		if (info->flags & XT_SOCKET_TRANSPARENT)
-			transparent = xt_socket_sk_is_transparent(sk);
+			transparent = nf_sk_is_transparent(sk);
 
 		if (info->flags & XT_SOCKET_RESTORESKMARK && !wildcard &&
 		    transparent)
@@ -488,7 +203,7 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 				  (1 << NF_INET_LOCAL_IN),
 		.me		= THIS_MODULE,
 	},
-#ifdef XT_SOCKET_HAVE_IPV6
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	{
 		.name		= "socket",
 		.revision	= 1,
@@ -512,7 +227,7 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 				  (1 << NF_INET_LOCAL_IN),
 		.me		= THIS_MODULE,
 	},
-#ifdef XT_SOCKET_HAVE_IPV6
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	{
 		.name		= "socket",
 		.revision	= 2,
@@ -536,7 +251,7 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 				  (1 << NF_INET_LOCAL_IN),
 		.me		= THIS_MODULE,
 	},
-#ifdef XT_SOCKET_HAVE_IPV6
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	{
 		.name		= "socket",
 		.revision	= 3,
@@ -554,7 +269,7 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 static int __init socket_mt_init(void)
 {
 	nf_defrag_ipv4_enable();
-#ifdef XT_SOCKET_HAVE_IPV6
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	nf_defrag_ipv6_enable();
 #endif
 
-- 
2.1.4
