From: kaber@trash.net
Subject: [PATCH 11/28] netfilter: xt_ipvs (netfilter matcher for IPVS)
Date: Mon,  2 Aug 2010 21:57:28 +0200
Message-ID: <1280779065-9333-12-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35364 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754710Ab0HBT57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:57:59 -0400
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <heder@google.com>

This implements the kernel-space side of the netfilter matcher xt_ipvs.

[ minor fixes by Simon Horman <horms@verge.net.au> ]
Signed-off-by: Hannes Eder <heder@google.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
[ Patrick: added xt_ipvs.h to Kbuild ]
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/Kbuild    |    1 +
 include/linux/netfilter/xt_ipvs.h |   27 +++++
 net/netfilter/Kconfig             |   10 ++
 net/netfilter/Makefile            |    1 +
 net/netfilter/ipvs/ip_vs_proto.c  |    1 +
 net/netfilter/xt_ipvs.c           |  189 +++++++++++++++++++++++++++++++++++++
 6 files changed, 229 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_ipvs.h
 create mode 100644 net/netfilter/xt_ipvs.c

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index b93b64d..0cb62c8 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -31,6 +31,7 @@ header-y += xt_dscp.h
 header-y += xt_esp.h
 header-y += xt_hashlimit.h
 header-y += xt_iprange.h
+header-y += xt_ipvs.h
 header-y += xt_helper.h
 header-y += xt_length.h
 header-y += xt_limit.h
diff --git a/include/linux/netfilter/xt_ipvs.h b/include/linux/netfilter/xt_ipvs.h
new file mode 100644
index 0000000..1167aeb
--- /dev/null
+++ b/include/linux/netfilter/xt_ipvs.h
@@ -0,0 +1,27 @@
+#ifndef _XT_IPVS_H
+#define _XT_IPVS_H
+
+enum {
+	XT_IPVS_IPVS_PROPERTY =	1 << 0, /* all other options imply this one */
+	XT_IPVS_PROTO =		1 << 1,
+	XT_IPVS_VADDR =		1 << 2,
+	XT_IPVS_VPORT =		1 << 3,
+	XT_IPVS_DIR =		1 << 4,
+	XT_IPVS_METHOD =	1 << 5,
+	XT_IPVS_VPORTCTL =	1 << 6,
+	XT_IPVS_MASK =		(1 << 7) - 1,
+	XT_IPVS_ONCE_MASK =	XT_IPVS_MASK & ~XT_IPVS_IPVS_PROPERTY
+};
+
+struct xt_ipvs_mtinfo {
+	union nf_inet_addr	vaddr, vmask;
+	__be16			vport;
+	__u8			l4proto;
+	__u8			fwd_method;
+	__be16			vportctl;
+
+	__u8			invert;
+	__u8			bitmask;
+};
+
+#endif /* _XT_IPVS_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 5fb8efa..551b584 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -742,6 +742,16 @@ config NETFILTER_XT_MATCH_IPRANGE
 
 	If unsure, say M.
 
+config NETFILTER_XT_MATCH_IPVS
+	tristate '"ipvs" match support'
+	depends on IP_VS
+	depends on NETFILTER_ADVANCED
+	depends on NF_CONNTRACK
+	help
+	  This option allows you to match against IPVS properties of a packet.
+
+	  If unsure, say N.
+
 config NETFILTER_XT_MATCH_LENGTH
 	tristate '"length" match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 36ef8e6..4366c79 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -77,6 +77,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_HASHLIMIT) += xt_hashlimit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HELPER) += xt_helper.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HL) += xt_hl.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_IPRANGE) += xt_iprange.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_IPVS) += xt_ipvs.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) += xt_length.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) += xt_limit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MAC) += xt_mac.o
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 2d3d5e4..027f654 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -98,6 +98,7 @@ struct ip_vs_protocol * ip_vs_proto_get(unsigned short proto)
 
 	return NULL;
 }
+EXPORT_SYMBOL(ip_vs_proto_get);
 
 
 /*
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
new file mode 100644
index 0000000..7a4d66d
--- /dev/null
+++ b/net/netfilter/xt_ipvs.c
@@ -0,0 +1,189 @@
+/*
+ *	xt_ipvs - kernel module to match IPVS connection properties
+ *
+ *	Author: Hannes Eder <heder@google.com>
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/spinlock.h>
+#include <linux/skbuff.h>
+#ifdef CONFIG_IP_VS_IPV6
+#include <net/ipv6.h>
+#endif
+#include <linux/ip_vs.h>
+#include <linux/types.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_ipvs.h>
+#include <net/netfilter/nf_conntrack.h>
+
+#include <net/ip_vs.h>
+
+MODULE_AUTHOR("Hannes Eder <heder@google.com>");
+MODULE_DESCRIPTION("Xtables: match IPVS connection properties");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_ipvs");
+MODULE_ALIAS("ip6t_ipvs");
+
+/* borrowed from xt_conntrack */
+static bool ipvs_mt_addrcmp(const union nf_inet_addr *kaddr,
+			    const union nf_inet_addr *uaddr,
+			    const union nf_inet_addr *umask,
+			    unsigned int l3proto)
+{
+	if (l3proto == NFPROTO_IPV4)
+		return ((kaddr->ip ^ uaddr->ip) & umask->ip) == 0;
+#ifdef CONFIG_IP_VS_IPV6
+	else if (l3proto == NFPROTO_IPV6)
+		return ipv6_masked_addr_cmp(&kaddr->in6, &umask->in6,
+		       &uaddr->in6) == 0;
+#endif
+	else
+		return false;
+}
+
+static bool
+ipvs_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_ipvs_mtinfo *data = par->matchinfo;
+	/* ipvs_mt_check ensures that family is only NFPROTO_IPV[46]. */
+	const u_int8_t family = par->family;
+	struct ip_vs_iphdr iph;
+	struct ip_vs_protocol *pp;
+	struct ip_vs_conn *cp;
+	bool match = true;
+
+	if (data->bitmask == XT_IPVS_IPVS_PROPERTY) {
+		match = skb->ipvs_property ^
+			!!(data->invert & XT_IPVS_IPVS_PROPERTY);
+		goto out;
+	}
+
+	/* other flags than XT_IPVS_IPVS_PROPERTY are set */
+	if (!skb->ipvs_property) {
+		match = false;
+		goto out;
+	}
+
+	ip_vs_fill_iphdr(family, skb_network_header(skb), &iph);
+
+	if (data->bitmask & XT_IPVS_PROTO)
+		if ((iph.protocol == data->l4proto) ^
+		    !(data->invert & XT_IPVS_PROTO)) {
+			match = false;
+			goto out;
+		}
+
+	pp = ip_vs_proto_get(iph.protocol);
+	if (unlikely(!pp)) {
+		match = false;
+		goto out;
+	}
+
+	/*
+	 * Check if the packet belongs to an existing entry
+	 */
+	cp = pp->conn_out_get(family, skb, pp, &iph, iph.len, 1 /* inverse */);
+	if (unlikely(cp == NULL)) {
+		match = false;
+		goto out;
+	}
+
+	/*
+	 * We found a connection, i.e. ct != 0, make sure to call
+	 * __ip_vs_conn_put before returning.  In our case jump to out_put_con.
+	 */
+
+	if (data->bitmask & XT_IPVS_VPORT)
+		if ((cp->vport == data->vport) ^
+		    !(data->invert & XT_IPVS_VPORT)) {
+			match = false;
+			goto out_put_cp;
+		}
+
+	if (data->bitmask & XT_IPVS_VPORTCTL)
+		if ((cp->control != NULL &&
+		     cp->control->vport == data->vportctl) ^
+		    !(data->invert & XT_IPVS_VPORTCTL)) {
+			match = false;
+			goto out_put_cp;
+		}
+
+	if (data->bitmask & XT_IPVS_DIR) {
+		enum ip_conntrack_info ctinfo;
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
+
+		if (ct == NULL || nf_ct_is_untracked(ct)) {
+			match = false;
+			goto out_put_cp;
+		}
+
+		if ((ctinfo >= IP_CT_IS_REPLY) ^
+		    !!(data->invert & XT_IPVS_DIR)) {
+			match = false;
+			goto out_put_cp;
+		}
+	}
+
+	if (data->bitmask & XT_IPVS_METHOD)
+		if (((cp->flags & IP_VS_CONN_F_FWD_MASK) == data->fwd_method) ^
+		    !(data->invert & XT_IPVS_METHOD)) {
+			match = false;
+			goto out_put_cp;
+		}
+
+	if (data->bitmask & XT_IPVS_VADDR) {
+		if (ipvs_mt_addrcmp(&cp->vaddr, &data->vaddr,
+				    &data->vmask, family) ^
+		    !(data->invert & XT_IPVS_VADDR)) {
+			match = false;
+			goto out_put_cp;
+		}
+	}
+
+out_put_cp:
+	__ip_vs_conn_put(cp);
+out:
+	pr_debug("match=%d\n", match);
+	return match;
+}
+
+static int ipvs_mt_check(const struct xt_mtchk_param *par)
+{
+	if (par->family != NFPROTO_IPV4
+#ifdef CONFIG_IP_VS_IPV6
+	    && par->family != NFPROTO_IPV6
+#endif
+		) {
+		pr_info("protocol family %u not supported\n", par->family);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static struct xt_match xt_ipvs_mt_reg __read_mostly = {
+	.name       = "ipvs",
+	.revision   = 0,
+	.family     = NFPROTO_UNSPEC,
+	.match      = ipvs_mt,
+	.checkentry = ipvs_mt_check,
+	.matchsize  = XT_ALIGN(sizeof(struct xt_ipvs_mtinfo)),
+	.me         = THIS_MODULE,
+};
+
+static int __init ipvs_mt_init(void)
+{
+	return xt_register_match(&xt_ipvs_mt_reg);
+}
+
+static void __exit ipvs_mt_exit(void)
+{
+	xt_unregister_match(&xt_ipvs_mt_reg);
+}
+
+module_init(ipvs_mt_init);
+module_exit(ipvs_mt_exit);
-- 
1.7.1

