From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/17] netfilter: nf_nat: move alloc_null_binding to nf_nat_core.c
Date: Mon, 14 Oct 2013 18:38:43 +0200
Message-ID: <1381768738-17739-3-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34731 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757229Ab3JNQjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:13 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to nat_decode_session, alloc_null_binding is needed for both
ip_tables and nf_tables, so move it to nf_nat_core.c. This change
is required by nf_tables.

This is an adapted version of the original patch from Patrick McHardy.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat.h |    3 +++
 net/netfilter/nf_nat_core.c    |   20 ++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index c29b4e5..07eaaf6 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -45,6 +45,9 @@ unsigned int nf_nat_setup_info(struct nf_conn *ct,
 			       const struct nf_nat_range *range,
 			       enum nf_nat_manip_type maniptype);
 
+extern unsigned int nf_nat_alloc_null_binding(struct nf_conn *ct,
+					      unsigned int hooknum);
+
 /* Is this tuple already taken? (not by us)*/
 int nf_nat_used_tuple(const struct nf_conntrack_tuple *tuple,
 		      const struct nf_conn *ignored_conntrack);
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 6f0f4f7..63a8154 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -432,6 +432,26 @@ nf_nat_setup_info(struct nf_conn *ct,
 }
 EXPORT_SYMBOL(nf_nat_setup_info);
 
+unsigned int
+nf_nat_alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
+{
+	/* Force range to this IP; let proto decide mapping for
+	 * per-proto parts (hence not IP_NAT_RANGE_PROTO_SPECIFIED).
+	 * Use reply in case it's already been mangled (eg local packet).
+	 */
+	union nf_inet_addr ip =
+		(HOOK2MANIP(hooknum) == NF_NAT_MANIP_SRC ?
+		ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3 :
+		ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3);
+	struct nf_nat_range range = {
+		.flags		= NF_NAT_RANGE_MAP_IPS,
+		.min_addr	= ip,
+		.max_addr	= ip,
+	};
+	return nf_nat_setup_info(ct, &range, HOOK2MANIP(hooknum));
+}
+EXPORT_SYMBOL_GPL(nf_nat_alloc_null_binding);
+
 /* Do packet manipulations according to nf_nat_setup_info. */
 unsigned int nf_nat_packet(struct nf_conn *ct,
 			   enum ip_conntrack_info ctinfo,
-- 
1.7.10.4
