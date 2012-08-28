From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 14/19] netfilter: nf_nat: support IPv6 in FTP NAT helper
Date: Tue, 28 Aug 2012 23:48:54 +0200
Message-ID: <1346190539-9963-15-git-send-email-kaber@trash.net>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59163 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507Ab2H1VtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 17:49:07 -0400
In-Reply-To: <1346190539-9963-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/Kconfig            |    5 -----
 net/ipv4/netfilter/Makefile           |    1 -
 net/netfilter/Kconfig                 |    5 +++++
 net/netfilter/Makefile                |    3 +++
 net/netfilter/nf_conntrack_ftp.c      |    3 +--
 net/{ipv4 => }/netfilter/nf_nat_ftp.c |   30 ++++++++++++++++++------------
 6 files changed, 27 insertions(+), 20 deletions(-)
 rename net/{ipv4 => }/netfilter/nf_nat_ftp.c (82%)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index b266296..8c6c692 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -221,11 +221,6 @@ config NF_NAT_PROTO_GRE
 	tristate
 	depends on NF_NAT_IPV4 && NF_CT_PROTO_GRE
 
-config NF_NAT_FTP
-	tristate
-	depends on NF_CONNTRACK && NF_NAT_IPV4
-	default NF_NAT_IPV4 && NF_CONNTRACK_FTP
-
 config NF_NAT_IRC
 	tristate
 	depends on NF_CONNTRACK && NF_NAT_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 0ea3acc..4d8a4ad 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -21,7 +21,6 @@ obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 
 # NAT helpers (nf_conntrack)
 obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
-obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
 obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
 obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 91addda..3104494 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -380,6 +380,11 @@ config NF_NAT_PROTO_SCTP
 	depends on NF_NAT && NF_CT_PROTO_SCTP
 	select LIBCRC32C
 
+config NF_NAT_FTP
+	tristate
+	depends on NF_CONNTRACK && NF_NAT
+	default NF_NAT && NF_CONNTRACK_FTP
+
 endif # NF_CONNTRACK
 
 # transparent proxy support
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 09c9451..16592b1 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -54,6 +54,9 @@ obj-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
 obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
 obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 
+# NAT helpers
+obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
+
 # transparent proxy support
 obj-$(CONFIG_NETFILTER_TPROXY) += nf_tproxy_core.o
 
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index c0f4a5b..f8cc26a 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -488,8 +488,7 @@ static int help(struct sk_buff *skb,
 	/* Now, NAT might want to mangle the packet, and register the
 	 * (possibly changed) expectation itself. */
 	nf_nat_ftp = rcu_dereference(nf_nat_ftp_hook);
-	if (nf_nat_ftp && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
-	    ct->status & IPS_NAT_MASK)
+	if (nf_nat_ftp && ct->status & IPS_NAT_MASK)
 		ret = nf_nat_ftp(skb, ctinfo, search[dir][i].ftptype,
 				 protoff, matchoff, matchlen, exp);
 	else {
diff --git a/net/ipv4/netfilter/nf_nat_ftp.c b/net/netfilter/nf_nat_ftp.c
similarity index 82%
rename from net/ipv4/netfilter/nf_nat_ftp.c
rename to net/netfilter/nf_nat_ftp.c
index dd5e387..e839b97 100644
--- a/net/ipv4/netfilter/nf_nat_ftp.c
+++ b/net/netfilter/nf_nat_ftp.c
@@ -10,7 +10,7 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-#include <linux/ip.h>
+#include <linux/inet.h>
 #include <linux/tcp.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/netfilter/nf_nat.h>
@@ -26,22 +26,27 @@ MODULE_ALIAS("ip_nat_ftp");
 
 /* FIXME: Time out? --RR */
 
-static int nf_nat_ftp_fmt_cmd(enum nf_ct_ftp_type type,
+static int nf_nat_ftp_fmt_cmd(struct nf_conn *ct, enum nf_ct_ftp_type type,
 			      char *buffer, size_t buflen,
-			      __be32 addr, u16 port)
+			      union nf_inet_addr *addr, u16 port)
 {
 	switch (type) {
 	case NF_CT_FTP_PORT:
 	case NF_CT_FTP_PASV:
 		return snprintf(buffer, buflen, "%u,%u,%u,%u,%u,%u",
-				((unsigned char *)&addr)[0],
-				((unsigned char *)&addr)[1],
-				((unsigned char *)&addr)[2],
-				((unsigned char *)&addr)[3],
+				((unsigned char *)&addr->ip)[0],
+				((unsigned char *)&addr->ip)[1],
+				((unsigned char *)&addr->ip)[2],
+				((unsigned char *)&addr->ip)[3],
 				port >> 8,
 				port & 0xFF);
 	case NF_CT_FTP_EPRT:
-		return snprintf(buffer, buflen, "|1|%pI4|%u|", &addr, port);
+		if (nf_ct_l3num(ct) == NFPROTO_IPV4)
+			return snprintf(buffer, buflen, "|1|%pI4|%u|",
+					&addr->ip, port);
+		else
+			return snprintf(buffer, buflen, "|2|%pI6|%u|",
+					&addr->ip6, port);
 	case NF_CT_FTP_EPSV:
 		return snprintf(buffer, buflen, "|||%u|", port);
 	}
@@ -59,17 +64,17 @@ static unsigned int nf_nat_ftp(struct sk_buff *skb,
 			       unsigned int matchlen,
 			       struct nf_conntrack_expect *exp)
 {
-	__be32 newip;
+	union nf_inet_addr newaddr;
 	u_int16_t port;
 	int dir = CTINFO2DIR(ctinfo);
 	struct nf_conn *ct = exp->master;
-	char buffer[sizeof("|1|255.255.255.255|65535|")];
+	char buffer[sizeof("|1||65535|") + INET6_ADDRSTRLEN];
 	unsigned int buflen;
 
 	pr_debug("FTP_NAT: type %i, off %u len %u\n", type, matchoff, matchlen);
 
 	/* Connection will come from wherever this packet goes, hence !dir */
-	newip = ct->tuplehash[!dir].tuple.dst.u3.ip;
+	newaddr = ct->tuplehash[!dir].tuple.dst.u3;
 	exp->saved_proto.tcp.port = exp->tuple.dst.u.tcp.port;
 	exp->dir = !dir;
 
@@ -94,7 +99,8 @@ static unsigned int nf_nat_ftp(struct sk_buff *skb,
 	if (port == 0)
 		return NF_DROP;
 
-	buflen = nf_nat_ftp_fmt_cmd(type, buffer, sizeof(buffer), newip, port);
+	buflen = nf_nat_ftp_fmt_cmd(ct, type, buffer, sizeof(buffer),
+				    &newaddr, port);
 	if (!buflen)
 		goto out;
 
-- 
1.7.1
