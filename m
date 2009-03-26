From: Patrick McHardy <kaber@trash.net>
Subject: ctnetlink 12/12: compute generic part of event more acurately
Date: Thu, 26 Mar 2009 20:02:47 +0100 (MET)
Message-ID: <20090326190241.23365.23033.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit d271e8bd8c60ce059ee36d836ba063cfc61c3e21
Author: Holger Eitzenberger <holger@eitzenberger.org>
Date:   Thu Mar 26 13:37:14 2009 +0100

    ctnetlink: compute generic part of event more acurately
    
    On a box with most of the optional Netfilter switches turned off some
    of the NLAs are never send, e. g. secmark, mark or the conntrack
    byte/packet counters.  As a worst case scenario this may possibly
    still lead to ctnetlink skbs being reallocated in netlink_trim()
    later, loosing all the nice effects from the previous patches.
    
    I try to solve that (at least partly) by correctly #ifdef'ing the
    NLAs in the computation.
    
    Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 03547c6..2fb833b 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -441,19 +441,28 @@ ctnetlink_alloc_skb(const struct nf_conntrack_tuple *tuple, gfp_t gfp)
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
 
