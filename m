From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/53] netfilter: conntrack: remove packet hotpath stats
Date: Mon, 26 Sep 2016 01:06:34 +0200
Message-ID: <1474844823-2026-25-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54654 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034721AbcIYXHp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:45 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id CA941C0B2A
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B3EDBDA850
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 98E97DA81A
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:41 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

These counters sit in hot path and do show up in perf, this is especially
true for 'found' and 'searched' which get incremented for every packet
processed.

Information like

searched=212030105
new=623431
found=333613
delete=623327

does not seem too helpful nowadays:

- on busy systems found and searched will overflow every few hours
(these are 32bit integers), other more busy ones every few days.

- for debugging there are better methods, such as iptables' trace target,
the conntrack log sysctls.  Nowadays we also have perf tool.

This removes packet path stat counters except those that
are expected to be 0 (or close to 0) on a normal system, e.g.
'insert_failed' (race happened) or 'invalid' (proto tracker rejects).

The insert stat is retained for the ctnetlink case.
The found stat is retained for the tuple-is-taken check when NAT has to
determine if it needs to pick a different source address.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_common.h      |  4 ----
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |  8 ++++----
 net/netfilter/nf_conntrack_core.c                  | 14 ++------------
 net/netfilter/nf_conntrack_netlink.c               |  6 +-----
 net/netfilter/nf_conntrack_standalone.c            |  8 ++++----
 5 files changed, 11 insertions(+), 29 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index 275505792664..1d1ef4e20512 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -4,13 +4,9 @@
 #include <uapi/linux/netfilter/nf_conntrack_common.h>
 
 struct ip_conntrack_stat {
-	unsigned int searched;
 	unsigned int found;
-	unsigned int new;
 	unsigned int invalid;
 	unsigned int ignore;
-	unsigned int delete;
-	unsigned int delete_list;
 	unsigned int insert;
 	unsigned int insert_failed;
 	unsigned int drop;
diff --git a/include/uapi/linux/netfilter/nfnetlink_conntrack.h b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
index 9df789709abe..6deb8867c5fc 100644
--- a/include/uapi/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
@@ -231,13 +231,13 @@ enum ctattr_secctx {
 
 enum ctattr_stats_cpu {
 	CTA_STATS_UNSPEC,
-	CTA_STATS_SEARCHED,
+	CTA_STATS_SEARCHED,	/* no longer used */
 	CTA_STATS_FOUND,
-	CTA_STATS_NEW,
+	CTA_STATS_NEW,		/* no longer used */
 	CTA_STATS_INVALID,
 	CTA_STATS_IGNORE,
-	CTA_STATS_DELETE,
-	CTA_STATS_DELETE_LIST,
+	CTA_STATS_DELETE,	/* no longer used */
+	CTA_STATS_DELETE_LIST,	/* no longer used */
 	CTA_STATS_INSERT,
 	CTA_STATS_INSERT_FAILED,
 	CTA_STATS_DROP,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ac1db4019d5c..8d1ddb9b63ed 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -379,7 +379,6 @@ static void
 destroy_conntrack(struct nf_conntrack *nfct)
 {
 	struct nf_conn *ct = (struct nf_conn *)nfct;
-	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_l4proto *l4proto;
 
 	pr_debug("destroy_conntrack(%p)\n", ct);
@@ -406,7 +405,6 @@ destroy_conntrack(struct nf_conntrack *nfct)
 
 	nf_ct_del_from_dying_or_unconfirmed_list(ct);
 
-	NF_CT_STAT_INC(net, delete);
 	local_bh_enable();
 
 	if (ct->master)
@@ -438,7 +436,6 @@ static void nf_ct_delete_from_lists(struct nf_conn *ct)
 
 	nf_ct_add_to_dying_list(ct);
 
-	NF_CT_STAT_INC(net, delete_list);
 	local_bh_enable();
 }
 
@@ -529,11 +526,8 @@ begin:
 		if (nf_ct_is_dying(ct))
 			continue;
 
-		if (nf_ct_key_equal(h, tuple, zone, net)) {
-			NF_CT_STAT_INC_ATOMIC(net, found);
+		if (nf_ct_key_equal(h, tuple, zone, net))
 			return h;
-		}
-		NF_CT_STAT_INC_ATOMIC(net, searched);
 	}
 	/*
 	 * if the nulls value we got at the end of this lookup is
@@ -798,7 +792,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	 */
 	__nf_conntrack_hash_insert(ct, hash, reply_hash);
 	nf_conntrack_double_unlock(hash, reply_hash);
-	NF_CT_STAT_INC(net, insert);
 	local_bh_enable();
 
 	help = nfct_help(ct);
@@ -857,7 +850,6 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 			rcu_read_unlock();
 			return 1;
 		}
-		NF_CT_STAT_INC_ATOMIC(net, searched);
 	}
 
 	if (get_nulls_value(n) != hash) {
@@ -1177,10 +1169,8 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 		}
 		spin_unlock(&nf_conntrack_expect_lock);
 	}
-	if (!exp) {
+	if (!exp)
 		__nf_ct_try_assign_helper(ct, tmpl, GFP_ATOMIC);
-		NF_CT_STAT_INC(net, new);
-	}
 
 	/* Now it is inserted into the unconfirmed list, bump refcount */
 	nf_conntrack_get(&ct->ct_general);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index c052b712c49f..27540455dc62 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1984,13 +1984,9 @@ ctnetlink_ct_stat_cpu_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
 	nfmsg->version      = NFNETLINK_V0;
 	nfmsg->res_id	    = htons(cpu);
 
-	if (nla_put_be32(skb, CTA_STATS_SEARCHED, htonl(st->searched)) ||
-	    nla_put_be32(skb, CTA_STATS_FOUND, htonl(st->found)) ||
-	    nla_put_be32(skb, CTA_STATS_NEW, htonl(st->new)) ||
+	if (nla_put_be32(skb, CTA_STATS_FOUND, htonl(st->found)) ||
 	    nla_put_be32(skb, CTA_STATS_INVALID, htonl(st->invalid)) ||
 	    nla_put_be32(skb, CTA_STATS_IGNORE, htonl(st->ignore)) ||
-	    nla_put_be32(skb, CTA_STATS_DELETE, htonl(st->delete)) ||
-	    nla_put_be32(skb, CTA_STATS_DELETE_LIST, htonl(st->delete_list)) ||
 	    nla_put_be32(skb, CTA_STATS_INSERT, htonl(st->insert)) ||
 	    nla_put_be32(skb, CTA_STATS_INSERT_FAILED,
 				htonl(st->insert_failed)) ||
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 3d9a316a3c77..7d52f8401afd 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -352,13 +352,13 @@ static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "%08x  %08x %08x %08x %08x %08x %08x %08x "
 			"%08x %08x %08x %08x %08x  %08x %08x %08x %08x\n",
 		   nr_conntracks,
-		   st->searched,
+		   0,
 		   st->found,
-		   st->new,
+		   0,
 		   st->invalid,
 		   st->ignore,
-		   st->delete,
-		   st->delete_list,
+		   0,
+		   0,
 		   st->insert,
 		   st->insert_failed,
 		   st->drop,
-- 
2.1.4
