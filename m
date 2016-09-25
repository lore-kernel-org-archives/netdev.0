From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 52/53] netfilter: nft_log: complete NFTA_LOG_FLAGS attr support
Date: Mon, 26 Sep 2016 01:07:02 +0200
Message-ID: <1474844823-2026-53-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54696 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034928AbcIYXIO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:08:14 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D621EE3A19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C34A6DA815
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 51264DA816
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:09 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

NFTA_LOG_FLAGS attribute is already supported, but the related
NF_LOG_XXX flags are not exposed to the userspace. So we cannot
explicitly enable log flags to log uid, tcp sequence, ip options
and so on, i.e. such rule "nft add rule filter output log uid"
is not supported yet.

So move NF_LOG_XXX macro definitions to the uapi/../nf_log.h. In
order to keep consistent with other modules, change NF_LOG_MASK to
refer to all supported log flags. On the other hand, add a new
NF_LOG_DEFAULT_MASK to refer to the original default log flags.

Finally, if user specify the unsupported log flags or NFTA_LOG_GROUP
and NFTA_LOG_FLAGS are set at the same time, report EINVAL to the
userspace.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_log.h        | 11 +++--------
 include/uapi/linux/netfilter/nf_log.h | 12 ++++++++++++
 net/bridge/netfilter/ebt_log.c        |  2 +-
 net/ipv4/netfilter/ip_tables.c        |  2 +-
 net/ipv4/netfilter/nf_log_arp.c       |  2 +-
 net/ipv4/netfilter/nf_log_ipv4.c      |  4 ++--
 net/ipv6/netfilter/ip6_tables.c       |  2 +-
 net/ipv6/netfilter/nf_log_ipv6.c      |  4 ++--
 net/netfilter/nf_tables_core.c        |  2 +-
 net/netfilter/nft_log.c               |  9 ++++++++-
 10 files changed, 32 insertions(+), 18 deletions(-)
 create mode 100644 include/uapi/linux/netfilter/nf_log.h

diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
index ee07dc8b0a7b..309cd267be4f 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -2,15 +2,10 @@
 #define _NF_LOG_H
 
 #include <linux/netfilter.h>
+#include <linux/netfilter/nf_log.h>
 
-/* those NF_LOG_* defines and struct nf_loginfo are legacy definitios that will
- * disappear once iptables is replaced with pkttables.  Please DO NOT use them
- * for any new code! */
-#define NF_LOG_TCPSEQ		0x01	/* Log TCP sequence numbers */
-#define NF_LOG_TCPOPT		0x02	/* Log TCP options */
-#define NF_LOG_IPOPT		0x04	/* Log IP options */
-#define NF_LOG_UID		0x08	/* Log UID owning local socket */
-#define NF_LOG_MASK		0x0f
+/* Log tcp sequence, tcp options, ip options and uid owning local socket */
+#define NF_LOG_DEFAULT_MASK	0x0f
 
 /* This flag indicates that copy_len field in nf_loginfo is set */
 #define NF_LOG_F_COPY_LEN	0x1
diff --git a/include/uapi/linux/netfilter/nf_log.h b/include/uapi/linux/netfilter/nf_log.h
new file mode 100644
index 000000000000..8be21e02387d
--- /dev/null
+++ b/include/uapi/linux/netfilter/nf_log.h
@@ -0,0 +1,12 @@
+#ifndef _NETFILTER_NF_LOG_H
+#define _NETFILTER_NF_LOG_H
+
+#define NF_LOG_TCPSEQ		0x01	/* Log TCP sequence numbers */
+#define NF_LOG_TCPOPT		0x02	/* Log TCP options */
+#define NF_LOG_IPOPT		0x04	/* Log IP options */
+#define NF_LOG_UID		0x08	/* Log UID owning local socket */
+#define NF_LOG_NFLOG		0x10	/* Unsupported, don't reuse */
+#define NF_LOG_MACDECODE	0x20	/* Decode MAC header */
+#define NF_LOG_MASK		0x2f
+
+#endif /* _NETFILTER_NF_LOG_H */
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 152300d164ac..9a11086ba6ff 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -91,7 +91,7 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 	if (loginfo->type == NF_LOG_TYPE_LOG)
 		bitmask = loginfo->u.log.logflags;
 	else
-		bitmask = NF_LOG_MASK;
+		bitmask = NF_LOG_DEFAULT_MASK;
 
 	if ((bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto ==
 	   htons(ETH_P_IP)) {
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index f993545a3373..7c00ce90adb8 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -156,7 +156,7 @@ static struct nf_loginfo trace_loginfo = {
 	.u = {
 		.log = {
 			.level = 4,
-			.logflags = NF_LOG_MASK,
+			.logflags = NF_LOG_DEFAULT_MASK,
 		},
 	},
 };
diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index 8945c2653814..b24795e2ee6d 100644
--- a/net/ipv4/netfilter/nf_log_arp.c
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -30,7 +30,7 @@ static struct nf_loginfo default_loginfo = {
 	.u = {
 		.log = {
 			.level	  = LOGLEVEL_NOTICE,
-			.logflags = NF_LOG_MASK,
+			.logflags = NF_LOG_DEFAULT_MASK,
 		},
 	},
 };
diff --git a/net/ipv4/netfilter/nf_log_ipv4.c b/net/ipv4/netfilter/nf_log_ipv4.c
index 20f225593a8b..5b571e1b5f15 100644
--- a/net/ipv4/netfilter/nf_log_ipv4.c
+++ b/net/ipv4/netfilter/nf_log_ipv4.c
@@ -29,7 +29,7 @@ static struct nf_loginfo default_loginfo = {
 	.u = {
 		.log = {
 			.level	  = LOGLEVEL_NOTICE,
-			.logflags = NF_LOG_MASK,
+			.logflags = NF_LOG_DEFAULT_MASK,
 		},
 	},
 };
@@ -46,7 +46,7 @@ static void dump_ipv4_packet(struct nf_log_buf *m,
 	if (info->type == NF_LOG_TYPE_LOG)
 		logflags = info->u.log.logflags;
 	else
-		logflags = NF_LOG_MASK;
+		logflags = NF_LOG_DEFAULT_MASK;
 
 	ih = skb_header_pointer(skb, iphoff, sizeof(_iph), &_iph);
 	if (ih == NULL) {
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 552fac2f390a..55aacea24396 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -190,7 +190,7 @@ static struct nf_loginfo trace_loginfo = {
 	.u = {
 		.log = {
 			.level = LOGLEVEL_WARNING,
-			.logflags = NF_LOG_MASK,
+			.logflags = NF_LOG_DEFAULT_MASK,
 		},
 	},
 };
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index c1bcf699a23d..f6aee2895fee 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -30,7 +30,7 @@ static struct nf_loginfo default_loginfo = {
 	.u = {
 		.log = {
 			.level	  = LOGLEVEL_NOTICE,
-			.logflags = NF_LOG_MASK,
+			.logflags = NF_LOG_DEFAULT_MASK,
 		},
 	},
 };
@@ -52,7 +52,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 	if (info->type == NF_LOG_TYPE_LOG)
 		logflags = info->u.log.logflags;
 	else
-		logflags = NF_LOG_MASK;
+		logflags = NF_LOG_DEFAULT_MASK;
 
 	ih = skb_header_pointer(skb, ip6hoff, sizeof(_ip6h), &_ip6h);
 	if (ih == NULL) {
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 7c94ce0080d5..0dd5c695482f 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -34,7 +34,7 @@ static struct nf_loginfo trace_loginfo = {
 	.u = {
 		.log = {
 			.level = LOGLEVEL_WARNING,
-			.logflags = NF_LOG_MASK,
+			.logflags = NF_LOG_DEFAULT_MASK,
 	        },
 	},
 };
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index 24a73bb26e94..1b01404bb33f 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -58,8 +58,11 @@ static int nft_log_init(const struct nft_ctx *ctx,
 	if (tb[NFTA_LOG_LEVEL] != NULL &&
 	    tb[NFTA_LOG_GROUP] != NULL)
 		return -EINVAL;
-	if (tb[NFTA_LOG_GROUP] != NULL)
+	if (tb[NFTA_LOG_GROUP] != NULL) {
 		li->type = NF_LOG_TYPE_ULOG;
+		if (tb[NFTA_LOG_FLAGS] != NULL)
+			return -EINVAL;
+	}
 
 	nla = tb[NFTA_LOG_PREFIX];
 	if (nla != NULL) {
@@ -87,6 +90,10 @@ static int nft_log_init(const struct nft_ctx *ctx,
 		if (tb[NFTA_LOG_FLAGS] != NULL) {
 			li->u.log.logflags =
 				ntohl(nla_get_be32(tb[NFTA_LOG_FLAGS]));
+			if (li->u.log.logflags & ~NF_LOG_MASK) {
+				err = -EINVAL;
+				goto err1;
+			}
 		}
 		break;
 	case NF_LOG_TYPE_ULOG:
-- 
2.1.4
