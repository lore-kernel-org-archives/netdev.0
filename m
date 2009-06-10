From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 22/31: conntrack: simplify event caching system
Date: Wed, 10 Jun 2009 21:46:49 +0200 (MEST)
Message-ID: <20090610194647.11112.40805.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 17e6e4eac070607a35464ea7e2c5eceac32e5eca
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Jun 2 20:08:46 2009 +0200

    netfilter: conntrack: simplify event caching system
    
    This patch simplifies the conntrack event caching system by removing
    several events:
    
     * IPCT_[*]_VOLATILE, IPCT_HELPINFO and IPCT_NATINFO has been deleted
       since the have no clients.
     * IPCT_COUNTER_FILLING which is a leftover of the 32-bits counter
       days.
     * IPCT_REFRESH which is not of any use since we always include the
       timeout in the messages.
    
    After this patch, the existing events are:
    
     * IPCT_NEW, IPCT_RELATED and IPCT_DESTROY, that are used to identify
     addition and deletion of entries.
     * IPCT_STATUS, that notes that the status bits have changes,
     eg. IPS_SEEN_REPLY and IPS_ASSURED.
     * IPCT_PROTOINFO, that reports that internal protocol information has
     changed, eg. the TCP, DCCP and SCTP protocol state.
     * IPCT_HELPER, that a helper has been assigned or unassigned to this
     entry.
     * IPCT_MARK and IPCT_SECMARK, that reports that the mark has changed, this
     covers the case when a mark is set to zero.
     * IPCT_NATSEQADJ, to report that there's updates in the NAT sequence
     adjustment.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 892b8cd..2e17a2d 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -26,52 +26,28 @@ enum ip_conntrack_events
 	IPCT_DESTROY_BIT = 2,
 	IPCT_DESTROY = (1 << IPCT_DESTROY_BIT),
 
-	/* Timer has been refreshed */
-	IPCT_REFRESH_BIT = 3,
-	IPCT_REFRESH = (1 << IPCT_REFRESH_BIT),
-
 	/* Status has changed */
-	IPCT_STATUS_BIT = 4,
+	IPCT_STATUS_BIT = 3,
 	IPCT_STATUS = (1 << IPCT_STATUS_BIT),
 
 	/* Update of protocol info */
-	IPCT_PROTOINFO_BIT = 5,
+	IPCT_PROTOINFO_BIT = 4,
 	IPCT_PROTOINFO = (1 << IPCT_PROTOINFO_BIT),
 
-	/* Volatile protocol info */
-	IPCT_PROTOINFO_VOLATILE_BIT = 6,
-	IPCT_PROTOINFO_VOLATILE = (1 << IPCT_PROTOINFO_VOLATILE_BIT),
-
 	/* New helper for conntrack */
-	IPCT_HELPER_BIT = 7,
+	IPCT_HELPER_BIT = 5,
 	IPCT_HELPER = (1 << IPCT_HELPER_BIT),
 
-	/* Update of helper info */
-	IPCT_HELPINFO_BIT = 8,
-	IPCT_HELPINFO = (1 << IPCT_HELPINFO_BIT),
-
-	/* Volatile helper info */
-	IPCT_HELPINFO_VOLATILE_BIT = 9,
-	IPCT_HELPINFO_VOLATILE = (1 << IPCT_HELPINFO_VOLATILE_BIT),
-
-	/* NAT info */
-	IPCT_NATINFO_BIT = 10,
-	IPCT_NATINFO = (1 << IPCT_NATINFO_BIT),
-
-	/* Counter highest bit has been set, unused */
-	IPCT_COUNTER_FILLING_BIT = 11,
-	IPCT_COUNTER_FILLING = (1 << IPCT_COUNTER_FILLING_BIT),
-
 	/* Mark is set */
-	IPCT_MARK_BIT = 12,
+	IPCT_MARK_BIT = 6,
 	IPCT_MARK = (1 << IPCT_MARK_BIT),
 
 	/* NAT sequence adjustment */
-	IPCT_NATSEQADJ_BIT = 13,
+	IPCT_NATSEQADJ_BIT = 7,
 	IPCT_NATSEQADJ = (1 << IPCT_NATSEQADJ_BIT),
 
 	/* Secmark is set */
-	IPCT_SECMARK_BIT = 14,
+	IPCT_SECMARK_BIT = 8,
 	IPCT_SECMARK = (1 << IPCT_SECMARK_BIT),
 };
 
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 23b2c2e..c6ab3d9 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -91,7 +91,6 @@ static int icmp_packet(struct nf_conn *ct,
 			nf_ct_kill_acct(ct, ctinfo, skb);
 	} else {
 		atomic_inc(&ct->proto.icmp.count);
-		nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmp_timeout);
 	}
 
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 9903227..a0acd96 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -104,7 +104,6 @@ static int icmpv6_packet(struct nf_conn *ct,
 			nf_ct_kill_acct(ct, ctinfo, skb);
 	} else {
 		atomic_inc(&ct->proto.icmp.count);
-		nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmpv6_timeout);
 	}
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f59c4ed..b54c234 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -398,11 +398,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	help = nfct_help(ct);
 	if (help && help->helper)
 		nf_conntrack_event_cache(IPCT_HELPER, ct);
-#ifdef CONFIG_NF_NAT_NEEDED
-	if (test_bit(IPS_SRC_NAT_DONE_BIT, &ct->status) ||
-	    test_bit(IPS_DST_NAT_DONE_BIT, &ct->status))
-		nf_conntrack_event_cache(IPCT_NATINFO, ct);
-#endif
+
 	nf_conntrack_event_cache(master_ct(ct) ?
 				 IPCT_RELATED : IPCT_NEW, ct);
 	return NF_ACCEPT;
@@ -807,8 +803,6 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 			  unsigned long extra_jiffies,
 			  int do_acct)
 {
-	int event = 0;
-
 	NF_CT_ASSERT(ct->timeout.data == (unsigned long)ct);
 	NF_CT_ASSERT(skb);
 
@@ -821,7 +815,6 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 	/* If not in hash table, timer will not be active yet */
 	if (!nf_ct_is_confirmed(ct)) {
 		ct->timeout.expires = extra_jiffies;
-		event = IPCT_REFRESH;
 	} else {
 		unsigned long newtime = jiffies + extra_jiffies;
 
@@ -832,7 +825,6 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 		    && del_timer(&ct->timeout)) {
 			ct->timeout.expires = newtime;
 			add_timer(&ct->timeout);
-			event = IPCT_REFRESH;
 		}
 	}
 
@@ -849,10 +841,6 @@ acct:
 	}
 
 	spin_unlock_bh(&nf_conntrack_lock);
-
-	/* must be unlocked when calling event cache */
-	if (event)
-		nf_conntrack_event_cache(event, ct);
 }
 EXPORT_SYMBOL_GPL(__nf_ct_refresh_acct);
 
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 00fecc3..5509dd1 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -338,11 +338,9 @@ static void update_nl_seq(struct nf_conn *ct, u32 nl_seq,
 
 	if (info->seq_aft_nl_num[dir] < NUM_SEQ_TO_REMEMBER) {
 		info->seq_aft_nl[dir][info->seq_aft_nl_num[dir]++] = nl_seq;
-		nf_conntrack_event_cache(IPCT_HELPINFO_VOLATILE, ct);
 	} else if (oldest != NUM_SEQ_TO_REMEMBER &&
 		   after(nl_seq, info->seq_aft_nl[dir][oldest])) {
 		info->seq_aft_nl[dir][oldest] = nl_seq;
-		nf_conntrack_event_cache(IPCT_HELPINFO_VOLATILE, ct);
 	}
 }
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 3a20de1..b1b9e4f 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -477,7 +477,7 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 		type = IPCTNL_MSG_CT_NEW;
 		flags = NLM_F_CREATE|NLM_F_EXCL;
 		group = NFNLGRP_CONNTRACK_NEW;
-	} else  if (events & (IPCT_STATUS | IPCT_PROTOINFO)) {
+	} else  if (events) {
 		type = IPCTNL_MSG_CT_NEW;
 		group = NFNLGRP_CONNTRACK_UPDATE;
 	} else
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 4c7f6f0..b7e8a82 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -991,7 +991,6 @@ static int tcp_packet(struct nf_conn *ct,
 		timeout = tcp_timeouts[new_state];
 	write_unlock_bh(&tcp_lock);
 
-	nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
 	if (new_state != old_state)
 		nf_conntrack_event_cache(IPCT_PROTOINFO, ct);
 
