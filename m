From: James Morris <jmorris@namei.org>
Subject: [RFC] SECMARK 1.1
Date: Sun, 14 May 2006 02:03:31 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605140133560.5506@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>,
	Karl MacMillan <kmacmillan@tresys.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Bleher <bleher@informatik.uni-muenchen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:54729 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751324AbWENGDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 May 2006 02:03:36 -0400
To: selinux@tycho.nsa.gov
In-Reply-To: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Included below is an incremental patch against the initial secmark posting 
last week: http://thread.gmane.org/gmane.linux.network/34927/focus=34927

This posting to gather feedback on changes made since then primarily to 
address concerns raised by Karl MacMillan on providing fine-grained 
assurances for network applications which pass connections (e.g. xinetd).

If all looks ok, I'll rebase the entire patchset (also merging elements 
from the patch below back into other patches), and submit it for inclusion 
in 2.6.18.  As it touches a bunch of networking code, it may be best to 
aim for Dave's tree, although it could also go into -mm.

Anyway, the way the issue has been addressed is to implement something 
similar to CONNMARK, but specific to this useage scenario and dealing with 
security markings instead of network markings.

In a nutshell:

1. A --track option was added to the SECMARK target, which causes the 
   security mark being applied to the packet to also be applied to a new
   secmark field on the conntrack (only if it is unmarked).

2. A new CONNSECMARK target was added which copies the secmark value to 
   packets.

This allows all packets on a connection (or related to it) to be marked 
with the same security label, so that they can be explicitly 
differentiated.

This also turns out to simplify the SELinux policy, while the xtables 
implementation has been designed to remain as simple as possible (e.g. it 
only copies lables to packets, and has no options).

So, here's an example of per-packet network policy for vsftpd with the new 
code:

  allow ftpd_t ftpd_packet_t:packet { recv send };

Assuming it doesn't do DNS lookups, that's it in terms of access control 
rules for packets.  This covers all established and related packets, 
including ICMP and the FTP data connetion.

(see the full policy at 
http://people.redhat.com/jmorris/selinux/secmark/policy/ftpd_tracked/ftpd_tracked.te)

In terms of iptables rules, the only real change is that we need to add 
CONNSECMARK rules for all incoming and outgoing packets (assuming you want 
this for all services, otherwise, use iptables selectors to apply 
CONNSECMARK on a per-service basis).  Here's an example for the above:

#
# Accept incoming connections, label SYN packets, and copy
# labels to connections.
#
$IPT -A SEL_INPUT -p tcp --dport 21 -m state --state NEW -j SEL_FTPD
$IPT -A SEL_FTPD -j SECMARK --selctx system_u:object_r:ftpd_packet_t:s0 --track
$IPT -A SEL_FTPD -j ACCEPT

#
# Copy connection labels to established and related packets.
#
$IPT -A SEL_INPUT -m state --state ESTABLISHED,RELATED -j CONNSECMARK
$IPT -A SEL_OUTPUT -m state --state ESTABLISHED,RELATED -j CONNSECMARK


It should be easy to modularize the iptables rules and distribute them 
with policy modules, and I'd recommend always generating them with some 
script or macro.

Everything needed to get this running (including iptables patches) is at:
http://people.redhat.com/jmorris/selinux/secmark/

I've also added a patch at the site which adds a kernel boot param to 
determine whether to use the old or new packet controls, although I'm 
still not sure whether it's justified adding this stuff to the kernel when 
it can be set at runtime during early boot.

Please review and let me know if there any further issues.


Signed-off-by: James Morris <jmorris@namei.org>

---

 include/linux/netfilter/xt_SECMARK.h         |    7 +-
 include/linux/netfilter_ipv4/ip_conntrack.h  |    4 +
 include/net/netfilter/nf_conntrack.h         |    4 +
 include/net/netfilter/nf_conntrack_compat.h  |   26 +++++++
 net/ipv4/netfilter/Kconfig                   |   10 ++
 net/ipv4/netfilter/ip_conntrack_core.c       |    3 
 net/ipv4/netfilter/ip_conntrack_standalone.c |    5 +
 net/netfilter/Kconfig                        |   20 +++++
 net/netfilter/Makefile                       |    1 
 net/netfilter/nf_conntrack_core.c            |    3 
 net/netfilter/nf_conntrack_standalone.c      |    5 +
 net/netfilter/xt_CONNSECMARK.c               |   93 +++++++++++++++++++++++++++
 net/netfilter/xt_SECMARK.c                   |   45 ++++++++++++-
 13 files changed, 224 insertions(+), 2 deletions(-)

diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/include/linux/netfilter/xt_SECMARK.h linux-2.6.17-rc3-git7.w/include/linux/netfilter/xt_SECMARK.h
--- linux-2.6.17-rc3-git7.p/include/linux/netfilter/xt_SECMARK.h	2006-05-13 15:15:29.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/include/linux/netfilter/xt_SECMARK.h	2006-05-10 18:20:50.000000000 -0400
@@ -7,6 +7,10 @@
  *
  * 'mode' refers to the specific security subsystem which the 
  * packets are being marked for.
+ *
+ * The 'track' flag is used to request that the security marking also be
+ * applied to the associated conntrack, if the conntrack is not labeled 
+ * already.
  */
 #define SECMARK_MODE_SEL	0x01		/* SELinux */
 #define SECMARK_SELCTX_MAX	256
@@ -17,7 +21,8 @@ struct xt_secmark_target_selinux_info {
 };
 
 struct xt_secmark_target_info {
-	u_int8_t mode;
+	u_int32_t mode:8,
+		  track:1;
 	union {
 		struct xt_secmark_target_selinux_info sel;
 	} u;
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/include/linux/netfilter_ipv4/ip_conntrack.h linux-2.6.17-rc3-git7.w/include/linux/netfilter_ipv4/ip_conntrack.h
--- linux-2.6.17-rc3-git7.p/include/linux/netfilter_ipv4/ip_conntrack.h	2006-05-13 15:15:29.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/include/linux/netfilter_ipv4/ip_conntrack.h	2006-05-10 11:59:17.000000000 -0400
@@ -121,6 +121,10 @@ struct ip_conntrack
 	u_int32_t mark;
 #endif
 
+#ifdef CONFIG_IP_NF_CONNTRACK_SECMARK
+	u_int32_t secmark;
+#endif
+
 	/* Traversed often, so hopefully in different cacheline to top */
 	/* These are my tuples; original and reply */
 	struct ip_conntrack_tuple_hash tuplehash[IP_CT_DIR_MAX];
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/include/net/netfilter/nf_conntrack_compat.h linux-2.6.17-rc3-git7.w/include/net/netfilter/nf_conntrack_compat.h
--- linux-2.6.17-rc3-git7.p/include/net/netfilter/nf_conntrack_compat.h	2006-05-13 15:15:29.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/include/net/netfilter/nf_conntrack_compat.h	2006-05-10 00:39:46.000000000 -0400
@@ -20,6 +20,19 @@ static inline u_int32_t *nf_ct_get_mark(
 }
 #endif /* CONFIG_IP_NF_CONNTRACK_MARK */
 
+#ifdef CONFIG_IP_NF_CONNTRACK_SECMARK
+static inline u_int32_t *nf_ct_get_secmark(const struct sk_buff *skb,
+					   u_int32_t *ctinfo)
+{
+	struct ip_conntrack *ct = ip_conntrack_get(skb, ctinfo);
+
+	if (ct)
+		return &ct->secmark;
+	else
+		return NULL;
+}
+#endif /* CONFIG_IP_NF_CONNTRACK_SECMARK */
+
 #ifdef CONFIG_IP_NF_CT_ACCT
 static inline struct ip_conntrack_counter *
 nf_ct_get_counters(const struct sk_buff *skb)
@@ -70,6 +83,19 @@ static inline u_int32_t *nf_ct_get_mark(
 }
 #endif /* CONFIG_NF_CONNTRACK_MARK */
 
+#ifdef CONFIG_NF_CONNTRACK_SECMARK
+static inline u_int32_t *nf_ct_get_secmark(const struct sk_buff *skb,
+					   u_int32_t *ctinfo)
+{
+	struct nf_conn *ct = nf_ct_get(skb, ctinfo);
+
+	if (ct)
+		return &ct->secmark;
+	else
+		return NULL;
+}
+#endif /* CONFIG_NF_CONNTRACK_MARK */
+
 #ifdef CONFIG_NF_CT_ACCT
 static inline struct ip_conntrack_counter *
 nf_ct_get_counters(const struct sk_buff *skb)
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/include/net/netfilter/nf_conntrack.h linux-2.6.17-rc3-git7.w/include/net/netfilter/nf_conntrack.h
--- linux-2.6.17-rc3-git7.p/include/net/netfilter/nf_conntrack.h	2006-05-13 15:15:29.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/include/net/netfilter/nf_conntrack.h	2006-05-10 11:58:34.000000000 -0400
@@ -114,6 +114,10 @@ struct nf_conn
 	u_int32_t mark;
 #endif
 
+#ifdef CONFIG_NF_CONNTRACK_SECMARK
+	u_int32_t secmark;
+#endif
+
 	/* Storage reserved for other modules: */
 	union nf_conntrack_proto proto;
 
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/net/ipv4/netfilter/ip_conntrack_core.c linux-2.6.17-rc3-git7.w/net/ipv4/netfilter/ip_conntrack_core.c
--- linux-2.6.17-rc3-git7.p/net/ipv4/netfilter/ip_conntrack_core.c	2006-05-03 10:25:01.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/net/ipv4/netfilter/ip_conntrack_core.c	2006-05-13 15:20:47.000000000 -0400
@@ -724,6 +724,9 @@ init_conntrack(struct ip_conntrack_tuple
 		/* this is ugly, but there is no other place where to put it */
 		conntrack->nat.masq_index = exp->master->nat.masq_index;
 #endif
+#ifdef CONFIG_IP_NF_CONNTRACK_SECMARK
+		conntrack->secmark = exp->master->secmark;
+#endif
 		nf_conntrack_get(&conntrack->master->ct_general);
 		CONNTRACK_STAT_INC(expect_new);
 	} else {
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/net/ipv4/netfilter/ip_conntrack_standalone.c linux-2.6.17-rc3-git7.w/net/ipv4/netfilter/ip_conntrack_standalone.c
--- linux-2.6.17-rc3-git7.p/net/ipv4/netfilter/ip_conntrack_standalone.c	2006-05-13 15:15:29.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/net/ipv4/netfilter/ip_conntrack_standalone.c	2006-05-10 17:58:03.000000000 -0400
@@ -189,6 +189,11 @@ static int ct_seq_show(struct seq_file *
 		return -ENOSPC;
 #endif
 
+#ifdef CONFIG_IP_NF_CONNTRACK_SECMARK
+	if (seq_printf(s, "secmark=%u ", conntrack->secmark))
+		return -ENOSPC;
+#endif
+
 	if (seq_printf(s, "use=%u\n", atomic_read(&conntrack->ct_general.use)))
 		return -ENOSPC;
 
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/net/ipv4/netfilter/Kconfig linux-2.6.17-rc3-git7.w/net/ipv4/netfilter/Kconfig
--- linux-2.6.17-rc3-git7.p/net/ipv4/netfilter/Kconfig	2006-05-13 15:15:29.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/net/ipv4/netfilter/Kconfig	2006-05-10 18:09:02.000000000 -0400
@@ -55,6 +55,16 @@ config IP_NF_CONNTRACK_MARK
 	  of packets, but this mark value is kept in the conntrack session
 	  instead of the individual packets.
 	
+config IP_NF_CONNTRACK_SECMARK
+	bool  'Connection tracking security mark support'
+	depends on IP_NF_CONNTRACK
+	help
+	  This option enables security markings to be applied to
+	  connections; typically copied from packet markings
+	  via the the iptables SECMARK target.
+	  
+	  If unsure, say 'N'.
+	  
 config IP_NF_CONNTRACK_EVENTS
 	bool "Connection tracking events (EXPERIMENTAL)"
 	depends on EXPERIMENTAL && IP_NF_CONNTRACK
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/net/netfilter/Kconfig linux-2.6.17-rc3-git7.w/net/netfilter/Kconfig
--- linux-2.6.17-rc3-git7.p/net/netfilter/Kconfig	2006-05-13 15:15:29.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/net/netfilter/Kconfig	2006-05-13 15:13:08.000000000 -0400
@@ -60,6 +60,16 @@ config NF_CONNTRACK_MARK
 	  of packets, but this mark value is kept in the conntrack session
 	  instead of the individual packets.
 
+config NF_CONNTRACK_SECMARK
+	bool  'Connection tracking security mark support'
+	depends on NF_CONNTRACK
+	help
+	  This option enables security markings to be applied to
+	  connections; typically copied from packet markings
+	  via the the iptables SECMARK target.
+	  
+	  If unsure, say 'N'.
+
 config NF_CONNTRACK_EVENTS
 	bool "Connection tracking events (EXPERIMENTAL)"
 	depends on EXPERIMENTAL && NF_CONNTRACK
@@ -183,6 +193,16 @@ config NETFILTER_XT_TARGET_SECMARK
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_TARGET_CONNSECMARK
+	tristate '"CONNSECMARK" target support'
+	depends on NETFILTER_XTABLES && NETWORK_SECMARK && (NF_CONNTRACK_SECMARK || IP_NF_CONNTRACK_SECMARK)
+	help
+	  The CONNSECMARK target copies security markings from conntracks
+	  to packets, if the packets are not already marked.  This would
+	  normally be used in conjunction with 'SECMARK --track'.
+	  
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_COMMENT
 	tristate  '"comment" match support'
 	depends on NETFILTER_XTABLES
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/net/netfilter/Makefile linux-2.6.17-rc3-git7.w/net/netfilter/Makefile
--- linux-2.6.17-rc3-git7.p/net/netfilter/Makefile	2006-05-09 19:56:11.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/net/netfilter/Makefile	2006-05-13 12:22:55.000000000 -0400
@@ -29,6 +29,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_MARK) +
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) += xt_NOTRACK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) += xt_SECMARK.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/net/netfilter/nf_conntrack_core.c linux-2.6.17-rc3-git7.w/net/netfilter/nf_conntrack_core.c
--- linux-2.6.17-rc3-git7.p/net/netfilter/nf_conntrack_core.c	2006-05-13 15:15:29.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/net/netfilter/nf_conntrack_core.c	2006-05-10 18:22:10.000000000 -0400
@@ -990,6 +990,9 @@ init_conntrack(const struct nf_conntrack
 #ifdef CONFIG_NF_CONNTRACK_MARK
 		conntrack->mark = exp->master->mark;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_SECMARK
+		conntrack->secmark = exp->master->secmark;
+#endif
 		nf_conntrack_get(&conntrack->master->ct_general);
 		NF_CT_STAT_INC(expect_new);
 	} else
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/net/netfilter/nf_conntrack_standalone.c linux-2.6.17-rc3-git7.w/net/netfilter/nf_conntrack_standalone.c
--- linux-2.6.17-rc3-git7.p/net/netfilter/nf_conntrack_standalone.c	2006-05-13 15:15:29.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/net/netfilter/nf_conntrack_standalone.c	2006-05-13 15:21:45.000000000 -0400
@@ -213,6 +213,11 @@ static int ct_seq_show(struct seq_file *
 		return -ENOSPC;
 #endif
 
+#ifdef CONFIG_NF_CONNTRACK_SECMARK
+	if (seq_printf(s, "secmark=%u ", conntrack->secmark))
+		return -ENOSPC;
+#endif
+
 	if (seq_printf(s, "use=%u\n", atomic_read(&conntrack->ct_general.use)))
 		return -ENOSPC;
 	
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/net/netfilter/xt_CONNSECMARK.c linux-2.6.17-rc3-git7.w/net/netfilter/xt_CONNSECMARK.c
--- linux-2.6.17-rc3-git7.p/net/netfilter/xt_CONNSECMARK.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.6.17-rc3-git7.w/net/netfilter/xt_CONNSECMARK.c	2006-05-13 23:27:00.000000000 -0400
@@ -0,0 +1,93 @@
+/*
+ * This module is used to copy security markings from conntracks
+ * to packets, most likely in conjunction with "SECMARK --track".
+ *
+ * Based on the nfmark match by:
+ * (C) 1999-2001 Marc Boucher <marc@mbsi.ca>
+ *
+ * (C) 2006 Red Hat, Inc., James Morris <jmorris@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/x_tables.h>
+#include <net/netfilter/nf_conntrack_compat.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("James Morris <jmorris@redhat.com>");
+MODULE_DESCRIPTION("ip[6]tables CONNSECMARK module");
+MODULE_ALIAS("ipt_CONNSECMARK");
+MODULE_ALIAS("ip6t_CONNSECMARK");
+
+static unsigned int target(struct sk_buff **pskb, const struct net_device *in,
+			   const struct net_device *out, unsigned int hooknum,
+			   const struct xt_target *target,
+			   const void *targinfo, void *userinfo)
+{
+	struct sk_buff *skb = *pskb;
+
+	if (!skb->secmark) {
+		u32 *connsecmark;
+		enum ip_conntrack_info ctinfo;
+		
+		/*
+		 * If packet is unlabeled, and the connection is labeled,
+		 * copy the connection label to the packet.
+		 */
+		connsecmark = nf_ct_get_secmark(skb, &ctinfo);
+		if (connsecmark && *connsecmark != 0) {
+			if (skb->secmark != *connsecmark)
+				skb->secmark = *connsecmark;
+		}
+	}
+
+	return XT_CONTINUE;
+}
+
+static struct xt_target ipt_connsecmark_reg = {
+	.name		= "CONNSECMARK",
+	.target		= target,
+	.targetsize	= 0,
+	.table		= "mangle",
+	.me		= THIS_MODULE,
+	.family		= AF_INET,
+	.revision	= 0,
+};
+
+static struct xt_target ip6t_connsecmark_reg = {
+	.name		= "CONNSECMARK",
+	.target		= target,
+	.targetsize	= 0,
+	.table		= "mangle",
+	.me		= THIS_MODULE,
+	.family		= AF_INET6,
+	.revision	= 0,
+};
+
+static int __init xt_connsecmark_init(void)
+{
+	int err;
+
+	err = xt_register_target(&ipt_connsecmark_reg);
+	if (err)
+		return err;
+
+	err = xt_register_target(&ip6t_connsecmark_reg);
+	if (err)
+		xt_unregister_target(&ipt_connsecmark_reg);
+
+	return err;
+}
+
+static void __exit xt_connsecmark_fini(void)
+{
+	xt_unregister_target(&ip6t_connsecmark_reg);
+	xt_unregister_target(&ipt_connsecmark_reg);
+}
+
+module_init(xt_connsecmark_init);
+module_exit(xt_connsecmark_fini);
diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/net/netfilter/xt_SECMARK.c linux-2.6.17-rc3-git7.w/net/netfilter/xt_SECMARK.c
--- linux-2.6.17-rc3-git7.p/net/netfilter/xt_SECMARK.c	2006-05-13 15:15:29.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/net/netfilter/xt_SECMARK.c	2006-05-13 15:24:28.000000000 -0400
@@ -17,6 +17,7 @@
 #include <linux/selinux.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_SECMARK.h>
+#include <net/netfilter/nf_conntrack_compat.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("James Morris <jmorris@redhat.com>");
@@ -28,6 +29,37 @@ MODULE_ALIAS("ip6t_SECMARK");
 
 static u8 mode;
 
+#if defined(CONFIG_IP_NF_CONNTRACK_SECMARK) || defined(CONFIG_NF_CONNTRACK_SECMARK)
+static inline void secmark_conntrack(struct sk_buff **pskb, u32 secmark,
+				     const struct xt_secmark_target_info *info)
+{
+	if (info->track) {
+		u32 *connsecmark;
+		enum ip_conntrack_info ctinfo;
+		
+		/* If connection is unlabeled, copy packet label to it */
+		connsecmark = nf_ct_get_secmark(*pskb, &ctinfo);
+		if (connsecmark && *connsecmark == 0) {
+			if (*connsecmark != secmark)
+				*connsecmark = secmark;
+		}
+	}
+}
+
+static inline int tracking_enabled(void)
+{
+	return 1;
+}
+#else
+static inline void secmark_conntrack(struct sk_buff **pskb, const struct xt_secmark_target_info *info)
+{ }
+
+static inline int tracking_enabled(void)
+{
+	return 0;
+}
+#endif
+
 static unsigned int target(struct sk_buff **pskb, const struct net_device *in,
 			   const struct net_device *out, unsigned int hooknum,
 			   const struct xt_target *target,
@@ -49,7 +81,9 @@ static unsigned int target(struct sk_buf
 	
 	if ((*pskb)->secmark != secmark)
 		(*pskb)->secmark = secmark;
-	
+
+	secmark_conntrack(pskb, secmark, info);
+
 	return XT_CONTINUE;
 }
 
@@ -58,6 +92,12 @@ static int checkentry_selinux(struct xt_
 	int err;
 	struct xt_secmark_target_selinux_info *sel = &info->u.sel;
 
+	if (info->track && !tracking_enabled()) {
+		printk(KERN_INFO PFX "--track option invalid unless "
+		       "conntrack and conntrack security marking enabled\n");
+		return 0;
+	}
+
 	err = selinux_string_to_sid(sel->selctx, &sel->selsid);
 	if (err) {
 		if (err == -EINVAL)
@@ -135,6 +175,9 @@ static int __init xt_secmark_init(void)
 {
 	int err;
 
+	if (tracking_enabled())
+		need_conntrack();
+
 	err = xt_register_target(&ipt_secmark_reg);
 	if (err)
 		return err;















