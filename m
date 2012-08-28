From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 17/19] netfilter: nf_nat: support IPv6 in IRC NAT helper
Date: Tue, 28 Aug 2012 23:48:57 +0200
Message-ID: <1346190539-9963-18-git-send-email-kaber@trash.net>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59151 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420Ab2H1VtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 17:49:09 -0400
In-Reply-To: <1346190539-9963-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/Kconfig            |    5 -----
 net/ipv4/netfilter/Makefile           |    1 -
 net/netfilter/Kconfig                 |    5 +++++
 net/netfilter/Makefile                |    1 +
 net/netfilter/nf_conntrack_irc.c      |    3 +--
 net/{ipv4 => }/netfilter/nf_nat_irc.c |    6 ------
 6 files changed, 7 insertions(+), 14 deletions(-)
 rename net/{ipv4 => }/netfilter/nf_nat_irc.c (92%)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 30197f8..843fe17 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -221,11 +221,6 @@ config NF_NAT_PROTO_GRE
 	tristate
 	depends on NF_NAT_IPV4 && NF_CT_PROTO_GRE
 
-config NF_NAT_IRC
-	tristate
-	depends on NF_CONNTRACK && NF_NAT_IPV4
-	default NF_NAT_IPV4 && NF_CONNTRACK_IRC
-
 config NF_NAT_TFTP
 	tristate
 	depends on NF_CONNTRACK && NF_NAT_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 8914abf..17e649b 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -21,7 +21,6 @@ obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 
 # NAT helpers (nf_conntrack)
 obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
-obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
 obj-$(CONFIG_NF_NAT_SNMP_BASIC) += nf_nat_snmp_basic.o
 obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index bf3e464..cabe4da 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -390,6 +390,11 @@ config NF_NAT_FTP
 	depends on NF_CONNTRACK && NF_NAT
 	default NF_NAT && NF_CONNTRACK_FTP
 
+config NF_NAT_IRC
+	tristate
+	depends on NF_CONNTRACK && NF_NAT
+	default NF_NAT && NF_CONNTRACK_IRC
+
 config NF_NAT_SIP
 	tristate
 	depends on NF_CONNTRACK && NF_NAT
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 7d6d1a0..0dd7929 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -57,6 +57,7 @@ obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 # NAT helpers
 obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
+obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_SIP) += nf_nat_sip.o
 
 # transparent proxy support
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 95d097c..3b20aa7 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -205,8 +205,7 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 					  IPPROTO_TCP, NULL, &port);
 
 			nf_nat_irc = rcu_dereference(nf_nat_irc_hook);
-			if (nf_nat_irc && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
-			    ct->status & IPS_NAT_MASK)
+			if (nf_nat_irc && ct->status & IPS_NAT_MASK)
 				ret = nf_nat_irc(skb, ctinfo, protoff,
 						 addr_beg_p - ib_ptr,
 						 addr_end_p - addr_beg_p,
diff --git a/net/ipv4/netfilter/nf_nat_irc.c b/net/netfilter/nf_nat_irc.c
similarity index 92%
rename from net/ipv4/netfilter/nf_nat_irc.c
rename to net/netfilter/nf_nat_irc.c
index 1ce37f8..1fedee6 100644
--- a/net/ipv4/netfilter/nf_nat_irc.c
+++ b/net/netfilter/nf_nat_irc.c
@@ -34,7 +34,6 @@ static unsigned int help(struct sk_buff *skb,
 			 struct nf_conntrack_expect *exp)
 {
 	char buffer[sizeof("4294967296 65635")];
-	u_int32_t ip;
 	u_int16_t port;
 	unsigned int ret;
 
@@ -60,11 +59,6 @@ static unsigned int help(struct sk_buff *skb,
 	if (port == 0)
 		return NF_DROP;
 
-	ip = ntohl(exp->master->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip);
-	sprintf(buffer, "%u %u", ip, port);
-	pr_debug("nf_nat_irc: inserting '%s' == %pI4, port %u\n",
-		 buffer, &ip, port);
-
 	ret = nf_nat_mangle_tcp_packet(skb, exp->master, ctinfo,
 				       protoff, matchoff, matchlen, buffer,
 				       strlen(buffer));
-- 
1.7.1
