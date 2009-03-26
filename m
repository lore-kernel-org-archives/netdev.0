From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 09/12: ctnetlink: allocate right-sized ctnetlink skb
Date: Thu, 26 Mar 2009 20:02:43 +0100 (MET)
Message-ID: <20090326190237.23365.25820.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 2732c4e45bb67006fdc9ae6669be866762711ab5
Author: Holger Eitzenberger <holger@eitzenberger.org>
Date:   Wed Mar 25 21:50:59 2009 +0100

    netfilter: ctnetlink: allocate right-sized ctnetlink skb
    
    Try to allocate a Netlink skb roughly the size of the actual
    message, with the help from the l3 and l4 protocol helpers.
    This is all to prevent a reallocation in netlink_trim() later.
    
    The overhead of allocating the right-sized skb is rather small, with
    ctnetlink_alloc_skb() actually being inlined away on my x86_64 box.
    The size of the per-proto space is determined at registration time of
    the protocol helper.
    
    Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 349bbef..03547c6 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -405,6 +405,69 @@ nla_put_failure:
 }
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
+/*
+ * The general structure of a ctnetlink event is
+ *
+ *  CTA_TUPLE_ORIG
+ *    <l3/l4-proto-attributes>
+ *  CTA_TUPLE_REPLY
+ *    <l3/l4-proto-attributes>
+ *  CTA_ID
+ *  ...
+ *  CTA_PROTOINFO
+ *    <l4-proto-attributes>
+ *  CTA_TUPLE_MASTER
+ *    <l3/l4-proto-attributes>
+ *
+ * Therefore the formular is
+ *
+ *   size = sizeof(headers) + sizeof(generic_nlas) + 3 * sizeof(tuple_nlas)
+ *		+ sizeof(protoinfo_nlas)
+ */
+static struct sk_buff *
+ctnetlink_alloc_skb(const struct nf_conntrack_tuple *tuple, gfp_t gfp)
+{
+	struct nf_conntrack_l3proto *l3proto;
+	struct nf_conntrack_l4proto *l4proto;
+	int len;
+
+#define NLA_TYPE_SIZE(type)		nla_total_size(sizeof(type))
+
+	/* proto independant part */
+	len = NLMSG_SPACE(sizeof(struct nfgenmsg))
+		+ 3 * nla_total_size(0)		/* CTA_TUPLE_ORIG|REPL|MASTER */
+		+ 3 * nla_total_size(0)		/* CTA_TUPLE_IP */
+		+ 3 * nla_total_size(0)		/* CTA_TUPLE_PROTO */
+		+ 3 * NLA_TYPE_SIZE(u_int8_t)	/* CTA_PROTO_NUM */
+		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_ID */
+		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_STATUS */
+		+ 2 * nla_total_size(0)		/* CTA_COUNTERS_ORIG|REPL */
+		+ 2 * NLA_TYPE_SIZE(uint64_t)	/* CTA_COUNTERS_PACKETS */
+		+ 2 * NLA_TYPE_SIZE(uint64_t)	/* CTA_COUNTERS_BYTES */
+		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_TIMEOUT */
+		+ nla_total_size(0)		/* CTA_PROTOINFO */
+		+ nla_total_size(0)		/* CTA_HELP */
+		+ nla_total_size(NF_CT_HELPER_NAME_LEN)	/* CTA_HELP_NAME */
+		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_SECMARK */
+		+ 2 * nla_total_size(0)		/* CTA_NAT_SEQ_ADJ_ORIG|REPL */
+		+ 2 * NLA_TYPE_SIZE(u_int32_t)	/* CTA_NAT_SEQ_CORRECTION_POS */
+		+ 2 * NLA_TYPE_SIZE(u_int32_t)	/* CTA_NAT_SEQ_CORRECTION_BEFORE */
+		+ 2 * NLA_TYPE_SIZE(u_int32_t)	/* CTA_NAT_SEQ_CORRECTION_AFTER */
+		+ NLA_TYPE_SIZE(u_int32_t);	/* CTA_MARK */
+
+#undef NLA_TYPE_SIZE
+
+	rcu_read_lock();
+	l3proto = __nf_ct_l3proto_find(tuple->src.l3num);
+	len += l3proto->nla_size;
+
+	l4proto = __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.protonum);
+	len += l4proto->nla_size;
+	rcu_read_unlock();
+
+	return alloc_skb(len, gfp);
+}
+
 static int ctnetlink_conntrack_event(struct notifier_block *this,
 				     unsigned long events, void *ptr)
 {
@@ -438,7 +501,7 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	if (!item->report && !nfnetlink_has_listeners(group))
 		return NOTIFY_DONE;
 
-	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	skb = ctnetlink_alloc_skb(tuple(ct, IP_CT_DIR_ORIGINAL), GFP_ATOMIC);
 	if (!skb)
 		return NOTIFY_DONE;
 
