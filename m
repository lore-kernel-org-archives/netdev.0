From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 15/33] netns ct: pass conntrack to nf_conntrack_event_cache() not skb
Date: Mon,  8 Sep 2008 07:02:52 +0400
Message-ID: <1220842990-30500-15-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is cleaner, we already know conntrack to which event is relevant.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index f0b9078..c1b406c 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -28,10 +28,8 @@ extern void __nf_ct_event_cache_init(struct nf_conn *ct);
 extern void nf_ct_event_cache_flush(void);
 
 static inline void
-nf_conntrack_event_cache(enum ip_conntrack_events event,
-			 const struct sk_buff *skb)
+nf_conntrack_event_cache(enum ip_conntrack_events event, struct nf_conn *ct)
 {
-	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
 	struct nf_conntrack_ecache *ecache;
 
 	local_bh_disable();
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 8c7ed5b..205ba39 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -91,7 +91,7 @@ static int icmp_packet(struct nf_conn *ct,
 			nf_ct_kill_acct(ct, ctinfo, skb);
 	} else {
 		atomic_inc(&ct->proto.icmp.count);
-		nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, skb);
+		nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmp_timeout);
 	}
 
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 11976ea..7eed1fb 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -192,7 +192,7 @@ nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 		nf_conntrack_tcp_update(skb, ip_hdrlen(skb),
 					ct, CTINFO2DIR(ctinfo));
 
-		nf_conntrack_event_cache(IPCT_NATSEQADJ, skb);
+		nf_conntrack_event_cache(IPCT_NATSEQADJ, ct);
 	}
 	return 1;
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index aabddfe..df04de9 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -93,7 +93,7 @@ static int icmpv6_packet(struct nf_conn *ct,
 			nf_ct_kill_acct(ct, ctinfo, skb);
 	} else {
 		atomic_inc(&ct->proto.icmp.count);
-		nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, skb);
+		nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmpv6_timeout);
 	}
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 251f020..01f59c5 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -370,14 +370,14 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	spin_unlock_bh(&nf_conntrack_lock);
 	help = nfct_help(ct);
 	if (help && help->helper)
-		nf_conntrack_event_cache(IPCT_HELPER, skb);
+		nf_conntrack_event_cache(IPCT_HELPER, ct);
 #ifdef CONFIG_NF_NAT_NEEDED
 	if (test_bit(IPS_SRC_NAT_DONE_BIT, &ct->status) ||
 	    test_bit(IPS_DST_NAT_DONE_BIT, &ct->status))
-		nf_conntrack_event_cache(IPCT_NATINFO, skb);
+		nf_conntrack_event_cache(IPCT_NATINFO, ct);
 #endif
 	nf_conntrack_event_cache(master_ct(ct) ?
-				 IPCT_RELATED : IPCT_NEW, skb);
+				 IPCT_RELATED : IPCT_NEW, ct);
 	return NF_ACCEPT;
 
 out:
@@ -740,7 +740,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	}
 
 	if (set_reply && !test_and_set_bit(IPS_SEEN_REPLY_BIT, &ct->status))
-		nf_conntrack_event_cache(IPCT_STATUS, skb);
+		nf_conntrack_event_cache(IPCT_STATUS, ct);
 
 	return ret;
 }
@@ -853,7 +853,7 @@ acct:
 
 	/* must be unlocked when calling event cache */
 	if (event)
-		nf_conntrack_event_cache(event, skb);
+		nf_conntrack_event_cache(event, ct);
 }
 EXPORT_SYMBOL_GPL(__nf_ct_refresh_acct);
 
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index bb20672..4f71071 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -318,7 +318,8 @@ static int find_nl_seq(u32 seq, const struct nf_ct_ftp_master *info, int dir)
 }
 
 /* We don't update if it's older than what we have. */
-static void update_nl_seq(u32 nl_seq, struct nf_ct_ftp_master *info, int dir,
+static void update_nl_seq(struct nf_conn *ct, u32 nl_seq,
+			  struct nf_ct_ftp_master *info, int dir,
 			  struct sk_buff *skb)
 {
 	unsigned int i, oldest = NUM_SEQ_TO_REMEMBER;
@@ -336,11 +337,11 @@ static void update_nl_seq(u32 nl_seq, struct nf_ct_ftp_master *info, int dir,
 
 	if (info->seq_aft_nl_num[dir] < NUM_SEQ_TO_REMEMBER) {
 		info->seq_aft_nl[dir][info->seq_aft_nl_num[dir]++] = nl_seq;
-		nf_conntrack_event_cache(IPCT_HELPINFO_VOLATILE, skb);
+		nf_conntrack_event_cache(IPCT_HELPINFO_VOLATILE, ct);
 	} else if (oldest != NUM_SEQ_TO_REMEMBER &&
 		   after(nl_seq, info->seq_aft_nl[dir][oldest])) {
 		info->seq_aft_nl[dir][oldest] = nl_seq;
-		nf_conntrack_event_cache(IPCT_HELPINFO_VOLATILE, skb);
+		nf_conntrack_event_cache(IPCT_HELPINFO_VOLATILE, ct);
 	}
 }
 
@@ -509,7 +510,7 @@ out_update_nl:
 	/* Now if this ends in \n, update ftp info.  Seq may have been
 	 * adjusted by NAT code. */
 	if (ends_in_nl)
-		update_nl_seq(seq, ct_ftp_info, dir, skb);
+		update_nl_seq(ct, seq, ct_ftp_info, dir, skb);
  out:
 	spin_unlock_bh(&nf_ftp_lock);
 	return ret;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index c5a7822..5b1273a 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -229,7 +229,7 @@ static int gre_packet(struct nf_conn *ct,
 				   ct->proto.gre.stream_timeout);
 		/* Also, more likely to be important, and not a probe. */
 		set_bit(IPS_ASSURED_BIT, &ct->status);
-		nf_conntrack_event_cache(IPCT_STATUS, skb);
+		nf_conntrack_event_cache(IPCT_STATUS, ct);
 	} else
 		nf_ct_refresh_acct(ct, ctinfo, skb,
 				   ct->proto.gre.timeout);
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index b5a9059..ae8c260 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -369,7 +369,7 @@ static int sctp_packet(struct nf_conn *ct,
 
 		ct->proto.sctp.state = new_state;
 		if (old_state != new_state)
-			nf_conntrack_event_cache(IPCT_PROTOINFO, skb);
+			nf_conntrack_event_cache(IPCT_PROTOINFO, ct);
 	}
 	write_unlock_bh(&sctp_lock);
 
@@ -380,7 +380,7 @@ static int sctp_packet(struct nf_conn *ct,
 	    new_state == SCTP_CONNTRACK_ESTABLISHED) {
 		pr_debug("Setting assured bit\n");
 		set_bit(IPS_ASSURED_BIT, &ct->status);
-		nf_conntrack_event_cache(IPCT_STATUS, skb);
+		nf_conntrack_event_cache(IPCT_STATUS, ct);
 	}
 
 	return NF_ACCEPT;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 4e71de2..b5d62d6 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -969,9 +969,9 @@ static int tcp_packet(struct nf_conn *ct,
 		timeout = tcp_timeouts[new_state];
 	write_unlock_bh(&tcp_lock);
 
-	nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, skb);
+	nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
 	if (new_state != old_state)
-		nf_conntrack_event_cache(IPCT_PROTOINFO, skb);
+		nf_conntrack_event_cache(IPCT_PROTOINFO, ct);
 
 	if (!test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
 		/* If only reply is a RST, we can consider ourselves not to
@@ -990,7 +990,7 @@ static int tcp_packet(struct nf_conn *ct,
 		   after SYN_RECV or a valid answer for a picked up
 		   connection. */
 		set_bit(IPS_ASSURED_BIT, &ct->status);
-		nf_conntrack_event_cache(IPCT_STATUS, skb);
+		nf_conntrack_event_cache(IPCT_STATUS, ct);
 	}
 	nf_ct_refresh_acct(ct, ctinfo, skb, timeout);
 
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 8a245be..e0ee89e 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -75,7 +75,7 @@ static int udp_packet(struct nf_conn *ct,
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udp_timeout_stream);
 		/* Also, more likely to be important, and not a probe */
 		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
-			nf_conntrack_event_cache(IPCT_STATUS, skb);
+			nf_conntrack_event_cache(IPCT_STATUS, ct);
 	} else
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udp_timeout);
 
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 9817019..c5b77c8 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -75,7 +75,7 @@ static int udplite_packet(struct nf_conn *ct,
 				   nf_ct_udplite_timeout_stream);
 		/* Also, more likely to be important, and not a probe */
 		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
-			nf_conntrack_event_cache(IPCT_STATUS, skb);
+			nf_conntrack_event_cache(IPCT_STATUS, ct);
 	} else
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udplite_timeout);
 
diff --git a/net/netfilter/xt_CONNMARK.c b/net/netfilter/xt_CONNMARK.c
index e72e5d0..e1415c3 100644
--- a/net/netfilter/xt_CONNMARK.c
+++ b/net/netfilter/xt_CONNMARK.c
@@ -54,7 +54,7 @@ connmark_tg_v0(struct sk_buff *skb, const struct net_device *in,
 			newmark = (ct->mark & ~markinfo->mask) | markinfo->mark;
 			if (newmark != ct->mark) {
 				ct->mark = newmark;
-				nf_conntrack_event_cache(IPCT_MARK, skb);
+				nf_conntrack_event_cache(IPCT_MARK, ct);
 			}
 			break;
 		case XT_CONNMARK_SAVE:
@@ -62,7 +62,7 @@ connmark_tg_v0(struct sk_buff *skb, const struct net_device *in,
 				  (skb->mark & markinfo->mask);
 			if (ct->mark != newmark) {
 				ct->mark = newmark;
-				nf_conntrack_event_cache(IPCT_MARK, skb);
+				nf_conntrack_event_cache(IPCT_MARK, ct);
 			}
 			break;
 		case XT_CONNMARK_RESTORE:
@@ -95,7 +95,7 @@ connmark_tg(struct sk_buff *skb, const struct net_device *in,
 		newmark = (ct->mark & ~info->ctmask) ^ info->ctmark;
 		if (ct->mark != newmark) {
 			ct->mark = newmark;
-			nf_conntrack_event_cache(IPCT_MARK, skb);
+			nf_conntrack_event_cache(IPCT_MARK, ct);
 		}
 		break;
 	case XT_CONNMARK_SAVE:
@@ -103,7 +103,7 @@ connmark_tg(struct sk_buff *skb, const struct net_device *in,
 		          (skb->mark & info->nfmask);
 		if (ct->mark != newmark) {
 			ct->mark = newmark;
-			nf_conntrack_event_cache(IPCT_MARK, skb);
+			nf_conntrack_event_cache(IPCT_MARK, ct);
 		}
 		break;
 	case XT_CONNMARK_RESTORE:
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index ae939e5..5f221c3 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -43,7 +43,7 @@ static void secmark_save(const struct sk_buff *skb)
 		ct = nf_ct_get(skb, &ctinfo);
 		if (ct && !ct->secmark) {
 			ct->secmark = skb->secmark;
-			nf_conntrack_event_cache(IPCT_SECMARK, skb);
+			nf_conntrack_event_cache(IPCT_SECMARK, ct);
 		}
 	}
 }
