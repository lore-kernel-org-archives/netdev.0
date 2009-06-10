From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 31/31: nf_conntrack: use per-conntrack locks for protocol data
Date: Wed, 10 Jun 2009 21:47:01 +0200 (MEST)
Message-ID: <20090610194700.11112.93963.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 440f0d588555892601cfe511728a0fc0c8204063
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jun 10 14:32:47 2009 +0200

    netfilter: nf_conntrack: use per-conntrack locks for protocol data
    
    Introduce per-conntrack locks and use them instead of the global protocol
    locks to avoid contention. Especially tcp_lock shows up very high in
    profiles on larger machines.
    
    This will also allow to simplify the upcoming reliable event delivery patches.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 2b87737..ecc79f9 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -93,6 +93,8 @@ struct nf_conn {
            plus 1 for any connection(s) we are `master' for */
 	struct nf_conntrack ct_general;
 
+	spinlock_t lock;
+
 	/* XXX should I move this to the tail ? - Y.K */
 	/* These are my tuples; original and reply */
 	struct nf_conntrack_tuple_hash tuplehash[IP_CT_DIR_MAX];
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index ba32ed7..3767fb4 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -59,11 +59,11 @@ struct nf_conntrack_l4proto
 			   const struct nf_conntrack_tuple *);
 
 	/* Print out the private part of the conntrack. */
-	int (*print_conntrack)(struct seq_file *s, const struct nf_conn *);
+	int (*print_conntrack)(struct seq_file *s, struct nf_conn *);
 
 	/* convert protoinfo to nfnetink attributes */
 	int (*to_nlattr)(struct sk_buff *skb, struct nlattr *nla,
-			 const struct nf_conn *ct);
+			 struct nf_conn *ct);
 	/* Calculate protoinfo nlattr size */
 	int (*nlattr_size)(void);
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index b54c234..edf9569 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -519,6 +519,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 		return ERR_PTR(-ENOMEM);
 	}
 
+	spin_lock_init(&ct->lock);
 	atomic_set(&ct->ct_general.use, 1);
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4448b06..4e503ad 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -143,7 +143,7 @@ nla_put_failure:
 }
 
 static inline int
-ctnetlink_dump_protoinfo(struct sk_buff *skb, const struct nf_conn *ct)
+ctnetlink_dump_protoinfo(struct sk_buff *skb, struct nf_conn *ct)
 {
 	struct nf_conntrack_l4proto *l4proto;
 	struct nlattr *nest_proto;
@@ -347,7 +347,7 @@ nla_put_failure:
 
 static int
 ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
-		    int event, const struct nf_conn *ct)
+		    int event, struct nf_conn *ct)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 11801c4..6b08d32 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -24,8 +24,6 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_log.h>
 
-static DEFINE_RWLOCK(dccp_lock);
-
 /* Timeouts are based on values from RFC4340:
  *
  * - REQUEST:
@@ -491,7 +489,7 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 		return NF_ACCEPT;
 	}
 
-	write_lock_bh(&dccp_lock);
+	spin_lock_bh(&ct->lock);
 
 	role = ct->proto.dccp.role[dir];
 	old_state = ct->proto.dccp.state;
@@ -535,13 +533,13 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 		ct->proto.dccp.last_dir = dir;
 		ct->proto.dccp.last_pkt = type;
 
-		write_unlock_bh(&dccp_lock);
+		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_DCCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_dccp: invalid packet ignored ");
 		return NF_ACCEPT;
 	case CT_DCCP_INVALID:
-		write_unlock_bh(&dccp_lock);
+		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_DCCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_dccp: invalid state transition ");
@@ -551,7 +549,7 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 	ct->proto.dccp.last_dir = dir;
 	ct->proto.dccp.last_pkt = type;
 	ct->proto.dccp.state = new_state;
-	write_unlock_bh(&dccp_lock);
+	spin_unlock_bh(&ct->lock);
 
 	dn = dccp_pernet(net);
 	nf_ct_refresh_acct(ct, ctinfo, skb, dn->dccp_timeout[new_state]);
@@ -617,18 +615,18 @@ static int dccp_print_tuple(struct seq_file *s,
 			  ntohs(tuple->dst.u.dccp.port));
 }
 
-static int dccp_print_conntrack(struct seq_file *s, const struct nf_conn *ct)
+static int dccp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
 	return seq_printf(s, "%s ", dccp_state_names[ct->proto.dccp.state]);
 }
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 static int dccp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
-			  const struct nf_conn *ct)
+			  struct nf_conn *ct)
 {
 	struct nlattr *nest_parms;
 
-	read_lock_bh(&dccp_lock);
+	spin_lock_bh(&ct->lock);
 	nest_parms = nla_nest_start(skb, CTA_PROTOINFO_DCCP | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
@@ -638,11 +636,11 @@ static int dccp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
 	NLA_PUT_BE64(skb, CTA_PROTOINFO_DCCP_HANDSHAKE_SEQ,
 		     cpu_to_be64(ct->proto.dccp.handshake_seq));
 	nla_nest_end(skb, nest_parms);
-	read_unlock_bh(&dccp_lock);
+	spin_unlock_bh(&ct->lock);
 	return 0;
 
 nla_put_failure:
-	read_unlock_bh(&dccp_lock);
+	spin_unlock_bh(&ct->lock);
 	return -1;
 }
 
@@ -673,7 +671,7 @@ static int nlattr_to_dccp(struct nlattr *cda[], struct nf_conn *ct)
 		return -EINVAL;
 	}
 
-	write_lock_bh(&dccp_lock);
+	spin_lock_bh(&ct->lock);
 	ct->proto.dccp.state = nla_get_u8(tb[CTA_PROTOINFO_DCCP_STATE]);
 	if (nla_get_u8(tb[CTA_PROTOINFO_DCCP_ROLE]) == CT_DCCP_ROLE_CLIENT) {
 		ct->proto.dccp.role[IP_CT_DIR_ORIGINAL] = CT_DCCP_ROLE_CLIENT;
@@ -686,7 +684,7 @@ static int nlattr_to_dccp(struct nlattr *cda[], struct nf_conn *ct)
 		ct->proto.dccp.handshake_seq =
 		be64_to_cpu(nla_get_be64(tb[CTA_PROTOINFO_DCCP_HANDSHAKE_SEQ]));
 	}
-	write_unlock_bh(&dccp_lock);
+	spin_unlock_bh(&ct->lock);
 	return 0;
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 117b801..175a28c 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -219,8 +219,7 @@ static int gre_print_tuple(struct seq_file *s,
 }
 
 /* print private data for conntrack */
-static int gre_print_conntrack(struct seq_file *s,
-			       const struct nf_conn *ct)
+static int gre_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
 	return seq_printf(s, "timeout=%u, stream_timeout=%u ",
 			  (ct->proto.gre.timeout / HZ),
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 101b4ad..c10e6f3 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -25,9 +25,6 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 
-/* Protects ct->proto.sctp */
-static DEFINE_RWLOCK(sctp_lock);
-
 /* FIXME: Examine ipfilter's timeouts and conntrack transitions more
    closely.  They're more complex. --RR
 
@@ -164,13 +161,13 @@ static int sctp_print_tuple(struct seq_file *s,
 }
 
 /* Print out the private part of the conntrack. */
-static int sctp_print_conntrack(struct seq_file *s, const struct nf_conn *ct)
+static int sctp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
 	enum sctp_conntrack state;
 
-	read_lock_bh(&sctp_lock);
+	spin_lock_bh(&ct->lock);
 	state = ct->proto.sctp.state;
-	read_unlock_bh(&sctp_lock);
+	spin_unlock_bh(&ct->lock);
 
 	return seq_printf(s, "%s ", sctp_conntrack_names[state]);
 }
@@ -318,7 +315,7 @@ static int sctp_packet(struct nf_conn *ct,
 	}
 
 	old_state = new_state = SCTP_CONNTRACK_NONE;
-	write_lock_bh(&sctp_lock);
+	spin_lock_bh(&ct->lock);
 	for_each_sctp_chunk (skb, sch, _sch, offset, dataoff, count) {
 		/* Special cases of Verification tag check (Sec 8.5.1) */
 		if (sch->type == SCTP_CID_INIT) {
@@ -371,7 +368,7 @@ static int sctp_packet(struct nf_conn *ct,
 		if (old_state != new_state)
 			nf_conntrack_event_cache(IPCT_PROTOINFO, ct);
 	}
-	write_unlock_bh(&sctp_lock);
+	spin_unlock_bh(&ct->lock);
 
 	nf_ct_refresh_acct(ct, ctinfo, skb, sctp_timeouts[new_state]);
 
@@ -386,7 +383,7 @@ static int sctp_packet(struct nf_conn *ct,
 	return NF_ACCEPT;
 
 out_unlock:
-	write_unlock_bh(&sctp_lock);
+	spin_unlock_bh(&ct->lock);
 out:
 	return -NF_ACCEPT;
 }
@@ -469,11 +466,11 @@ static bool sctp_new(struct nf_conn *ct, const struct sk_buff *skb,
 #include <linux/netfilter/nfnetlink_conntrack.h>
 
 static int sctp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
-			  const struct nf_conn *ct)
+			  struct nf_conn *ct)
 {
 	struct nlattr *nest_parms;
 
-	read_lock_bh(&sctp_lock);
+	spin_lock_bh(&ct->lock);
 	nest_parms = nla_nest_start(skb, CTA_PROTOINFO_SCTP | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
@@ -488,14 +485,14 @@ static int sctp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
 		     CTA_PROTOINFO_SCTP_VTAG_REPLY,
 		     ct->proto.sctp.vtag[IP_CT_DIR_REPLY]);
 
-	read_unlock_bh(&sctp_lock);
+	spin_unlock_bh(&ct->lock);
 
 	nla_nest_end(skb, nest_parms);
 
 	return 0;
 
 nla_put_failure:
-	read_unlock_bh(&sctp_lock);
+	spin_unlock_bh(&ct->lock);
 	return -1;
 }
 
@@ -527,13 +524,13 @@ static int nlattr_to_sctp(struct nlattr *cda[], struct nf_conn *ct)
 	    !tb[CTA_PROTOINFO_SCTP_VTAG_REPLY])
 		return -EINVAL;
 
-	write_lock_bh(&sctp_lock);
+	spin_lock_bh(&ct->lock);
 	ct->proto.sctp.state = nla_get_u8(tb[CTA_PROTOINFO_SCTP_STATE]);
 	ct->proto.sctp.vtag[IP_CT_DIR_ORIGINAL] =
 		nla_get_be32(tb[CTA_PROTOINFO_SCTP_VTAG_ORIGINAL]);
 	ct->proto.sctp.vtag[IP_CT_DIR_REPLY] =
 		nla_get_be32(tb[CTA_PROTOINFO_SCTP_VTAG_REPLY]);
-	write_unlock_bh(&sctp_lock);
+	spin_unlock_bh(&ct->lock);
 
 	return 0;
 }
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index b7e8a82..5c5739c 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -29,9 +29,6 @@
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
 
-/* Protects ct->proto.tcp */
-static DEFINE_RWLOCK(tcp_lock);
-
 /* "Be conservative in what you do,
     be liberal in what you accept from others."
     If it's non-zero, we mark only out of window RST segments as INVALID. */
@@ -309,13 +306,13 @@ static int tcp_print_tuple(struct seq_file *s,
 }
 
 /* Print out the private part of the conntrack. */
-static int tcp_print_conntrack(struct seq_file *s, const struct nf_conn *ct)
+static int tcp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
 	enum tcp_conntrack state;
 
-	read_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->lock);
 	state = ct->proto.tcp.state;
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->lock);
 
 	return seq_printf(s, "%s ", tcp_conntrack_names[state]);
 }
@@ -725,14 +722,14 @@ void nf_conntrack_tcp_update(const struct sk_buff *skb,
 
 	end = segment_seq_plus_len(ntohl(tcph->seq), skb->len, dataoff, tcph);
 
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->lock);
 	/*
 	 * We have to worry for the ack in the reply packet only...
 	 */
 	if (after(end, ct->proto.tcp.seen[dir].td_end))
 		ct->proto.tcp.seen[dir].td_end = end;
 	ct->proto.tcp.last_end = end;
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->lock);
 	pr_debug("tcp_update: sender end=%u maxend=%u maxwin=%u scale=%i "
 		 "receiver end=%u maxend=%u maxwin=%u scale=%i\n",
 		 sender->td_end, sender->td_maxend, sender->td_maxwin,
@@ -841,7 +838,7 @@ static int tcp_packet(struct nf_conn *ct,
 	th = skb_header_pointer(skb, dataoff, sizeof(_tcph), &_tcph);
 	BUG_ON(th == NULL);
 
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->lock);
 	old_state = ct->proto.tcp.state;
 	dir = CTINFO2DIR(ctinfo);
 	index = get_conntrack_index(th);
@@ -871,7 +868,7 @@ static int tcp_packet(struct nf_conn *ct,
 		        && ct->proto.tcp.last_index == TCP_RST_SET)) {
 			/* Attempt to reopen a closed/aborted connection.
 			 * Delete this connection and look up again. */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(&ct->lock);
 
 			/* Only repeat if we can actually remove the timer.
 			 * Destruction may already be in progress in process
@@ -907,7 +904,7 @@ static int tcp_packet(struct nf_conn *ct,
 			 * that the client cannot but retransmit its SYN and
 			 * thus initiate a clean new session.
 			 */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(&ct->lock);
 			if (LOG_INVALID(net, IPPROTO_TCP))
 				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 					  "nf_ct_tcp: killing out of sync session ");
@@ -920,7 +917,7 @@ static int tcp_packet(struct nf_conn *ct,
 		ct->proto.tcp.last_end =
 		    segment_seq_plus_len(ntohl(th->seq), skb->len, dataoff, th);
 
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid packet ignored ");
@@ -929,7 +926,7 @@ static int tcp_packet(struct nf_conn *ct,
 		/* Invalid packet */
 		pr_debug("nf_ct_tcp: Invalid dir=%i index=%u ostate=%u\n",
 			 dir, get_conntrack_index(th), old_state);
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid state ");
@@ -960,7 +957,7 @@ static int tcp_packet(struct nf_conn *ct,
 
 	if (!tcp_in_window(ct, &ct->proto.tcp, dir, index,
 			   skb, dataoff, th, pf)) {
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(&ct->lock);
 		return -NF_ACCEPT;
 	}
      in_window:
@@ -989,7 +986,7 @@ static int tcp_packet(struct nf_conn *ct,
 		timeout = nf_ct_tcp_timeout_unacknowledged;
 	else
 		timeout = tcp_timeouts[new_state];
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->lock);
 
 	if (new_state != old_state)
 		nf_conntrack_event_cache(IPCT_PROTOINFO, ct);
@@ -1106,12 +1103,12 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 #include <linux/netfilter/nfnetlink_conntrack.h>
 
 static int tcp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
-			 const struct nf_conn *ct)
+			 struct nf_conn *ct)
 {
 	struct nlattr *nest_parms;
 	struct nf_ct_tcp_flags tmp = {};
 
-	read_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->lock);
 	nest_parms = nla_nest_start(skb, CTA_PROTOINFO_TCP | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
@@ -1131,14 +1128,14 @@ static int tcp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
 	tmp.flags = ct->proto.tcp.seen[1].flags;
 	NLA_PUT(skb, CTA_PROTOINFO_TCP_FLAGS_REPLY,
 		sizeof(struct nf_ct_tcp_flags), &tmp);
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->lock);
 
 	nla_nest_end(skb, nest_parms);
 
 	return 0;
 
 nla_put_failure:
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->lock);
 	return -1;
 }
 
@@ -1169,7 +1166,7 @@ static int nlattr_to_tcp(struct nlattr *cda[], struct nf_conn *ct)
 	    nla_get_u8(tb[CTA_PROTOINFO_TCP_STATE]) >= TCP_CONNTRACK_MAX)
 		return -EINVAL;
 
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->lock);
 	if (tb[CTA_PROTOINFO_TCP_STATE])
 		ct->proto.tcp.state = nla_get_u8(tb[CTA_PROTOINFO_TCP_STATE]);
 
@@ -1196,7 +1193,7 @@ static int nlattr_to_tcp(struct nlattr *cda[], struct nf_conn *ct)
 		ct->proto.tcp.seen[1].td_scale =
 			nla_get_u8(tb[CTA_PROTOINFO_TCP_WSCALE_REPLY]);
 	}
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->lock);
 
 	return 0;
 }
