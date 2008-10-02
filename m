From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [net-next PATCH 14/16] iptables socket match
Date: Thu, 02 Oct 2008 12:26:41 +0200
Message-ID: <1222943201.7058.8.camel@este>
References: <20081001142431.4893.48078.stgit@este>
 <20081001142431.4893.56954.stgit@este> <48E493CC.9020502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <48E493CC.9020502@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, 2008-10-02 at 11:26 +0200, Patrick McHardy wrote:
> KOVACS Krisztian wrote:
> > Add iptables 'socket' match, which matches packets for which a TCP/UDP
> > socket lookup succeeds.
> >   
> 
> It seems sufficiently different from what xt_owner does to justify a 
> separate module.
> Minor nitpicking:
> [...]

Sorry, should be better this time.

- 8< -

Add iptables 'socket' match, which matches packets for which a TCP/UDP
socket lookup succeeds.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 net/netfilter/Kconfig     |   15 ++++
 net/netfilter/Makefile    |    1 
 net/netfilter/xt_socket.c |  192 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 208 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index ff1b0e6..a4b8006 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -760,6 +760,21 @@ config NETFILTER_XT_MATCH_SCTP
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
 
+config NETFILTER_XT_MATCH_SOCKET
+	tristate '"socket" match support (EXPERIMENTAL)'
+	depends on EXPERIMENTAL
+	depends on NETFILTER_TPROXY
+	depends on NETFILTER_XTABLES
+	depends on NETFILTER_ADVANCED
+	select NF_DEFRAG_IPV4
+	help
+	  This option adds a `socket' match, which can be used to match
+	  packets for which a TCP or UDP socket lookup finds a valid socket.
+	  It can be used in combination with the MARK target and policy
+	  routing to implement full featured non-locally bound sockets.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_STATE
 	tristate '"state" match support'
 	depends on NETFILTER_XTABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 1b8cb7f..c386755 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -80,6 +80,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_QUOTA) += xt_quota.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_RATEEST) += xt_rateest.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_REALM) += xt_realm.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_SCTP) += xt_sctp.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_SOCKET) += xt_socket.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_STATE) += xt_state.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_STATISTIC) += xt_statistic.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_STRING) += xt_string.o
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
new file mode 100644
index 0000000..83eeff3
--- /dev/null
+++ b/net/netfilter/xt_socket.c
@@ -0,0 +1,192 @@
+/*
+ * Transparent proxy support for Linux/iptables
+ *
+ * Copyright (C) 2007-2008 BalaBit IT Ltd.
+ * Author: Krisztian Kovacs
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+#include <net/icmp.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <net/netfilter/nf_tproxy_core.h>
+#include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#define XT_SOCKET_HAVE_CONNTRACK 1
+#include <net/netfilter/nf_conntrack.h>
+#endif
+
+static int
+extract_icmp_fields(const struct sk_buff *skb,
+		    u8 *protocol,
+		    __be32 *raddr,
+		    __be32 *laddr,
+		    __be16 *rport,
+		    __be16 *lport)
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
+
+static bool
+socket_mt(const struct sk_buff *skb,
+	  const struct net_device *in,
+	  const struct net_device *out,
+	  const struct xt_match *match,
+	  const void *matchinfo,
+	  int offset,
+	  unsigned int protoff,
+	  bool *hotdrop)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct udphdr _hdr, *hp = NULL;
+	struct sock *sk;
+	__be32 daddr, saddr;
+	__be16 dport, sport;
+	u8 protocol;
+#ifdef XT_SOCKET_HAVE_CONNTRACK
+	struct nf_conn const *ct;
+	enum ip_conntrack_info ctinfo;
+#endif
+
+	if (iph->protocol == IPPROTO_UDP || iph->protocol == IPPROTO_TCP) {
+		hp = skb_header_pointer(skb, ip_hdrlen(skb),
+					sizeof(_hdr), &_hdr);
+		if (hp == NULL)
+			return false;
+
+		protocol = iph->protocol;
+		saddr = iph->saddr;
+		sport = hp->source;
+		daddr = iph->daddr;
+		dport = hp->dest;
+
+	} else if (iph->protocol == IPPROTO_ICMP) {
+		if (extract_icmp_fields(skb, &protocol, &saddr, &daddr,
+					&sport, &dport))
+			return false;
+	} else {
+		return false;
+	}
+
+#ifdef XT_SOCKET_HAVE_CONNTRACK
+	/* Do the lookup with the original socket address in case this is a
+	 * reply packet of an established SNAT-ted connection. */
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct && (ct != &nf_conntrack_untracked) &&
+	    ((iph->protocol != IPPROTO_ICMP &&
+	      ctinfo == IP_CT_IS_REPLY + IP_CT_ESTABLISHED) ||
+	     (iph->protocol == IPPROTO_ICMP &&
+	      ctinfo == IP_CT_IS_REPLY + IP_CT_RELATED)) &&
+	    (ct->status & IPS_SRC_NAT_DONE)) {
+
+		daddr = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip;
+		dport = (iph->protocol == IPPROTO_TCP) ?
+			ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.tcp.port :
+			ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.udp.port;
+	}
+#endif
+
+	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), protocol,
+				   saddr, daddr, sport, dport, in, false);
+	if (sk != NULL) {
+		bool wildcard = (inet_sk(sk)->rcv_saddr == 0);
+
+		nf_tproxy_put_sock(sk);
+		if (wildcard)
+			sk = NULL;
+	}
+
+	pr_debug("socket match: proto %u %08x:%u -> %08x:%u "
+		 "(orig %08x:%u) sock %p\n",
+		 protocol, ntohl(saddr), ntohs(sport),
+		 ntohl(daddr), ntohs(dport),
+		 ntohl(iph->daddr), hp ? ntohs(hp->dest) : 0, sk);
+
+	return (sk != NULL);
+}
+
+static struct xt_match socket_mt_reg __read_mostly = {
+	.name		= "socket",
+	.family		= AF_INET,
+	.match		= socket_mt,
+	.hooks		= 1 << NF_INET_PRE_ROUTING,
+	.me		= THIS_MODULE,
+};
+
+static int __init socket_mt_init(void)
+{
+	nf_defrag_ipv4_enable();
+	return xt_register_match(&socket_mt_reg);
+}
+
+static void __exit socket_mt_exit(void)
+{
+	xt_unregister_match(&socket_mt_reg);
+}
+
+module_init(socket_mt_init);
+module_exit(socket_mt_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Krisztian Kovacs, Balazs Scheidler");
+MODULE_DESCRIPTION("x_tables socket match module");
+MODULE_ALIAS("ipt_socket");


