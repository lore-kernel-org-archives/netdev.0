From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 1/1] ctnetlink: compute generic part of event more acurately
Date: Wed, 25 Mar 2009 22:25:22 +0100
Message-ID: <20090325213123.842307488@jonathan.eitzenberger.org>
References: <20090325212521.149272388@jonathan.eitzenberger.org>
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ctnetlink-alloc-generic-event-more-acurately.diff
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On a box with most of the optional Netfilter switches turned off some
of the NLAs are never send, e. g. secmark, mark or the conntrack
byte/packet counters.  As a worst case scenario this may possibly
still lead to ctnetlink skbs being reallocated in netlink_trim()
later, loosing all the nice effects from the previous patches.

I try to solve that (at least partly) by correctly #ifdef'ing the
NLAs in the computation.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: nf-next-2.6/net/netfilter/nf_conntrack_netlink.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_netlink.c
+++ nf-next-2.6/net/netfilter/nf_conntrack_netlink.c
@@ -440,19 +440,28 @@ ctnetlink_alloc_skb(const struct nf_conn
 		+ 3 * NLA_TYPE_SIZE(u_int8_t)	/* CTA_PROTO_NUM */
 		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_ID */
 		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_STATUS */
+#ifdef CONFIG_NF_CT_ACCT
 		+ 2 * nla_total_size(0)		/* CTA_COUNTERS_ORIG|REPL */
 		+ 2 * NLA_TYPE_SIZE(uint64_t)	/* CTA_COUNTERS_PACKETS */
 		+ 2 * NLA_TYPE_SIZE(uint64_t)	/* CTA_COUNTERS_BYTES */
+#endif
 		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_TIMEOUT */
 		+ nla_total_size(0)		/* CTA_PROTOINFO */
 		+ nla_total_size(0)		/* CTA_HELP */
 		+ nla_total_size(NF_CT_HELPER_NAME_LEN)	/* CTA_HELP_NAME */
+#ifdef CONFIG_NF_CONNTRACK_SECMARK
 		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_SECMARK */
+#endif
+#ifdef CONFIG_NF_NAT_NEEDED
 		+ 2 * nla_total_size(0)		/* CTA_NAT_SEQ_ADJ_ORIG|REPL */
 		+ 2 * NLA_TYPE_SIZE(u_int32_t)	/* CTA_NAT_SEQ_CORRECTION_POS */
 		+ 2 * NLA_TYPE_SIZE(u_int32_t)	/* CTA_NAT_SEQ_CORRECTION_BEFORE */
 		+ 2 * NLA_TYPE_SIZE(u_int32_t)	/* CTA_NAT_SEQ_CORRECTION_AFTER */
-		+ NLA_TYPE_SIZE(u_int32_t);	/* CTA_MARK */
+#endif
+#ifdef CONFIG_NF_CONNTRACK_MARK
+		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_MARK */
+#endif
+		;
 
 #undef NLA_TYPE_SIZE
 

-- 
