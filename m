From: James Morris <jmorris@namei.org>
Subject: [PATCH 05/07] secmark: Add secmark support to conntrack
Date: Thu, 18 May 2006 05:27:05 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605180526070.569@d.namei>
References: <Pine.LNX.4.64.0605180458130.569@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	Karl MacMillan <kmacmillan@tresys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:64998 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751059AbWERJ1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 05:27:08 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605180458130.569@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a secmark field to IP and NF conntracks, so that security 
markings on packets can be copied to their associated connections, and 
also copied back to packets as required.  This is similar to the network 
mark field currently used with conntrack, although it is intended for 
enforcement of security policy rather than network policy.

Please apply.

Signed-off-by: James Morris <jmorris@namei.org>

---

 include/linux/netfilter_ipv4/ip_conntrack.h  |    4 ++++
 include/net/netfilter/nf_conntrack.h         |    4 ++++
 include/net/netfilter/nf_conntrack_compat.h  |   26 ++++++++++++++++++++++++++
 net/ipv4/netfilter/Kconfig                   |   12 ++++++++++++
 net/ipv4/netfilter/ip_conntrack_core.c       |    3 +++
 net/ipv4/netfilter/ip_conntrack_standalone.c |    5 +++++
 net/netfilter/Kconfig                        |   12 ++++++++++++
 net/netfilter/nf_conntrack_core.c            |    3 +++
 net/netfilter/nf_conntrack_standalone.c      |    5 +++++
 9 files changed, 74 insertions(+)

diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/include/linux/netfilter_ipv4/ip_conntrack.h linux-2.6.17-rc4-mm1.w/include/linux/netfilter_ipv4/ip_conntrack.h
--- linux-2.6.17-rc4-mm1.p/include/linux/netfilter_ipv4/ip_conntrack.h	2006-05-16 23:35:11.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/include/linux/netfilter_ipv4/ip_conntrack.h	2006-05-17 01:39:42.000000000 -0400
@@ -120,6 +120,10 @@ struct ip_conntrack
 	u_int32_t mark;
 #endif
 
+#ifdef CONFIG_IP_NF_CONNTRACK_SECMARK
+	u_int32_t secmark;
+#endif
+
 	/* Traversed often, so hopefully in different cacheline to top */
 	/* These are my tuples; original and reply */
 	struct ip_conntrack_tuple_hash tuplehash[IP_CT_DIR_MAX];
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/include/net/netfilter/nf_conntrack_compat.h linux-2.6.17-rc4-mm1.w/include/net/netfilter/nf_conntrack_compat.h
--- linux-2.6.17-rc4-mm1.p/include/net/netfilter/nf_conntrack_compat.h	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.17-rc4-mm1.w/include/net/netfilter/nf_conntrack_compat.h	2006-05-17 01:39:42.000000000 -0400
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
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/include/net/netfilter/nf_conntrack.h linux-2.6.17-rc4-mm1.w/include/net/netfilter/nf_conntrack.h
--- linux-2.6.17-rc4-mm1.p/include/net/netfilter/nf_conntrack.h	2006-05-16 23:35:11.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/include/net/netfilter/nf_conntrack.h	2006-05-17 01:39:42.000000000 -0400
@@ -113,6 +113,10 @@ struct nf_conn
 	u_int32_t mark;
 #endif
 
+#ifdef CONFIG_NF_CONNTRACK_SECMARK
+	u_int32_t secmark;
+#endif
+
 	/* Storage reserved for other modules: */
 	union nf_conntrack_proto proto;
 
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/net/ipv4/netfilter/ip_conntrack_core.c linux-2.6.17-rc4-mm1.w/net/ipv4/netfilter/ip_conntrack_core.c
--- linux-2.6.17-rc4-mm1.p/net/ipv4/netfilter/ip_conntrack_core.c	2006-05-16 23:34:59.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/net/ipv4/netfilter/ip_conntrack_core.c	2006-05-17 01:39:42.000000000 -0400
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
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/net/ipv4/netfilter/ip_conntrack_standalone.c linux-2.6.17-rc4-mm1.w/net/ipv4/netfilter/ip_conntrack_standalone.c
--- linux-2.6.17-rc4-mm1.p/net/ipv4/netfilter/ip_conntrack_standalone.c	2006-05-16 23:34:59.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/net/ipv4/netfilter/ip_conntrack_standalone.c	2006-05-17 01:39:42.000000000 -0400
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
 
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/net/ipv4/netfilter/Kconfig linux-2.6.17-rc4-mm1.w/net/ipv4/netfilter/Kconfig
--- linux-2.6.17-rc4-mm1.p/net/ipv4/netfilter/Kconfig	2006-05-16 23:34:59.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/net/ipv4/netfilter/Kconfig	2006-05-17 01:48:41.000000000 -0400
@@ -55,6 +55,18 @@ config IP_NF_CONNTRACK_MARK
 	  of packets, but this mark value is kept in the conntrack session
 	  instead of the individual packets.
 	
+config IP_NF_CONNTRACK_SECMARK
+	bool  'Connection tracking security mark support'
+	depends on IP_NF_CONNTRACK && NETWORK_SECMARK
+	help
+	  This option enables security markings to be applied to
+	  connections.  Typically they are copied to connections from
+	  packets using the CONNSECMARK target and copied back from
+	  connections to packets with the same target, with the packets
+	  being originally labeled via SECMARK.
+	  
+	  If unsure, say 'N'.
+
 config IP_NF_CONNTRACK_EVENTS
 	bool "Connection tracking events (EXPERIMENTAL)"
 	depends on EXPERIMENTAL && IP_NF_CONNTRACK
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/net/netfilter/Kconfig linux-2.6.17-rc4-mm1.w/net/netfilter/Kconfig
--- linux-2.6.17-rc4-mm1.p/net/netfilter/Kconfig	2006-05-17 01:35:52.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/net/netfilter/Kconfig	2006-05-17 01:48:42.000000000 -0400
@@ -60,6 +60,18 @@ config NF_CONNTRACK_MARK
 	  of packets, but this mark value is kept in the conntrack session
 	  instead of the individual packets.
 
+config NF_CONNTRACK_SECMARK
+	bool  'Connection tracking security mark support'
+	depends on NF_CONNTRACK && NETWORK_SECMARK
+	help
+	  This option enables security markings to be applied to
+	  connections.  Typically they are copied to connections from
+	  packets using the CONNSECMARK target and copied back from
+	  connections to packets with the same target, with the packets
+	  being originally labeled via SECMARK.
+
+	  If unsure, say 'N'.
+
 config NF_CONNTRACK_EVENTS
 	bool "Connection tracking events (EXPERIMENTAL)"
 	depends on EXPERIMENTAL && NF_CONNTRACK
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/net/netfilter/nf_conntrack_core.c linux-2.6.17-rc4-mm1.w/net/netfilter/nf_conntrack_core.c
--- linux-2.6.17-rc4-mm1.p/net/netfilter/nf_conntrack_core.c	2006-05-16 23:34:59.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/net/netfilter/nf_conntrack_core.c	2006-05-17 01:39:42.000000000 -0400
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
diff -purN -X dontdiff linux-2.6.17-rc4-mm1.p/net/netfilter/nf_conntrack_standalone.c linux-2.6.17-rc4-mm1.w/net/netfilter/nf_conntrack_standalone.c
--- linux-2.6.17-rc4-mm1.p/net/netfilter/nf_conntrack_standalone.c	2006-05-16 23:34:59.000000000 -0400
+++ linux-2.6.17-rc4-mm1.w/net/netfilter/nf_conntrack_standalone.c	2006-05-17 01:39:42.000000000 -0400
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
 	
