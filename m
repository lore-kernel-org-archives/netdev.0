From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFT 4/4] netfilter: Get rid of central rwlock in tcp conntracking
Date: Tue, 17 Feb 2009 21:19:10 -0800
Message-ID: <20090218052747.679540125@vyatta.com>
References: <20090218051906.174295181@vyatta.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=tcp_conntrack_lock.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TCP connection tracking suffers of huge contention on a global rwlock,
is used for protecting the  tcp conntracking state.
As each tcp conntrack state have no relations between each others, we
can switch to fine grained lock, using a spinlock per "struct ip_ct_tcp"

tcp_print_conntrack() dont need to lock anything to read ct->proto.tcp.state,
so speedup /proc/net/ip_conntrack as well.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Reported-by: Rick Jones <rick.jones2@hp.com>

---
 include/linux/netfilter/nf_conntrack_tcp.h   |    1 
 include/net/netfilter/nf_conntrack_helper.h  |    2 -
 include/net/netfilter/nf_conntrack_l4proto.h |    3 --
 net/netfilter/nf_conntrack_netlink.c         |    6 ++--
 net/netfilter/nf_conntrack_proto_dccp.c      |    2 -
 net/netfilter/nf_conntrack_proto_sctp.c      |    2 -
 net/netfilter/nf_conntrack_proto_tcp.c       |   37 ++++++++++++---------------
 7 files changed, 25 insertions(+), 28 deletions(-)

--- a/include/linux/netfilter/nf_conntrack_tcp.h	2009-02-17 11:07:16.884086452 -0800
+++ b/include/linux/netfilter/nf_conntrack_tcp.h	2009-02-17 11:07:31.643846743 -0800
@@ -50,6 +50,7 @@ struct ip_ct_tcp_state {
 
 struct ip_ct_tcp
 {
+	spinlock_t	lock;
 	struct ip_ct_tcp_state seen[2];	/* connection parameters per direction */
 	u_int8_t	state;		/* state of the connection (enum tcp_conntrack) */
 	/* For detecting stale connections */
--- a/net/netfilter/nf_conntrack_proto_tcp.c	2009-02-17 11:07:16.870763455 -0800
+++ b/net/netfilter/nf_conntrack_proto_tcp.c	2009-02-17 11:21:57.528485882 -0800
@@ -26,9 +26,6 @@
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_log.h>
 
-/* Protects ct->proto.tcp */
-static DEFINE_RWLOCK(tcp_lock);
-
 /* "Be conservative in what you do,
     be liberal in what you accept from others."
     If it's non-zero, we mark only out of window RST segments as INVALID. */
@@ -297,9 +294,7 @@ static int tcp_print_conntrack(struct se
 {
 	enum tcp_conntrack state;
 
-	read_lock_bh(&tcp_lock);
 	state = ct->proto.tcp.state;
-	read_unlock_bh(&tcp_lock);
 
 	return seq_printf(s, "%s ", tcp_conntrack_names[state]);
 }
@@ -705,14 +700,15 @@ void nf_conntrack_tcp_update(const struc
 
 	end = segment_seq_plus_len(ntohl(tcph->seq), skb->len, dataoff, tcph);
 
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->proto.tcp.lock);
 	/*
 	 * We have to worry for the ack in the reply packet only...
 	 */
 	if (after(end, ct->proto.tcp.seen[dir].td_end))
 		ct->proto.tcp.seen[dir].td_end = end;
 	ct->proto.tcp.last_end = end;
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->proto.tcp.lock);
+
 	pr_debug("tcp_update: sender end=%u maxend=%u maxwin=%u scale=%i "
 		 "receiver end=%u maxend=%u maxwin=%u scale=%i\n",
 		 sender->td_end, sender->td_maxend, sender->td_maxwin,
@@ -821,7 +817,7 @@ static int tcp_packet(struct nf_conn *ct
 	th = skb_header_pointer(skb, dataoff, sizeof(_tcph), &_tcph);
 	BUG_ON(th == NULL);
 
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->proto.tcp.lock);
 	old_state = ct->proto.tcp.state;
 	dir = CTINFO2DIR(ctinfo);
 	index = get_conntrack_index(th);
@@ -851,7 +847,7 @@ static int tcp_packet(struct nf_conn *ct
 		        && ct->proto.tcp.last_index == TCP_RST_SET)) {
 			/* Attempt to reopen a closed/aborted connection.
 			 * Delete this connection and look up again. */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(&ct->proto.tcp.lock);
 
 			/* Only repeat if we can actually remove the timer.
 			 * Destruction may already be in progress in process
@@ -887,7 +883,7 @@ static int tcp_packet(struct nf_conn *ct
 			 * that the client cannot but retransmit its SYN and
 			 * thus initiate a clean new session.
 			 */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(&ct->proto.tcp.lock);
 			if (LOG_INVALID(net, IPPROTO_TCP))
 				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 					  "nf_ct_tcp: killing out of sync session ");
@@ -900,7 +896,7 @@ static int tcp_packet(struct nf_conn *ct
 		ct->proto.tcp.last_end =
 		    segment_seq_plus_len(ntohl(th->seq), skb->len, dataoff, th);
 
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(&ct->proto.tcp.lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid packet ignored ");
@@ -909,7 +905,7 @@ static int tcp_packet(struct nf_conn *ct
 		/* Invalid packet */
 		pr_debug("nf_ct_tcp: Invalid dir=%i index=%u ostate=%u\n",
 			 dir, get_conntrack_index(th), old_state);
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(&ct->proto.tcp.lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid state ");
@@ -940,7 +936,7 @@ static int tcp_packet(struct nf_conn *ct
 
 	if (!tcp_in_window(ct, &ct->proto.tcp, dir, index,
 			   skb, dataoff, th, pf)) {
-		write_unlock_bh(&tcp_lock);
+		spin_unlock_bh(&ct->proto.tcp.lock);
 		return -NF_ACCEPT;
 	}
      in_window:
@@ -969,7 +965,7 @@ static int tcp_packet(struct nf_conn *ct
 		timeout = nf_ct_tcp_timeout_unacknowledged;
 	else
 		timeout = tcp_timeouts[new_state];
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->proto.tcp.lock);
 
 	nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
 	if (new_state != old_state)
@@ -1022,6 +1018,7 @@ static bool tcp_new(struct nf_conn *ct, 
 		pr_debug("nf_ct_tcp: invalid new deleting.\n");
 		return false;
 	}
+	spin_lock_init(&ct->proto.tcp.lock);
 
 	if (new_state == TCP_CONNTRACK_SYN_SENT) {
 		/* SYN packet */
@@ -1087,12 +1084,12 @@ static bool tcp_new(struct nf_conn *ct, 
 #include <linux/netfilter/nfnetlink_conntrack.h>
 
 static int tcp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
-			 const struct nf_conn *ct)
+			 struct nf_conn *ct)
 {
 	struct nlattr *nest_parms;
 	struct nf_ct_tcp_flags tmp = {};
 
-	read_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->proto.tcp.lock);
 	nest_parms = nla_nest_start(skb, CTA_PROTOINFO_TCP | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
@@ -1112,14 +1109,14 @@ static int tcp_to_nlattr(struct sk_buff 
 	tmp.flags = ct->proto.tcp.seen[1].flags;
 	NLA_PUT(skb, CTA_PROTOINFO_TCP_FLAGS_REPLY,
 		sizeof(struct nf_ct_tcp_flags), &tmp);
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->proto.tcp.lock);
 
 	nla_nest_end(skb, nest_parms);
 
 	return 0;
 
 nla_put_failure:
-	read_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->proto.tcp.lock);
 	return -1;
 }
 
@@ -1150,7 +1147,7 @@ static int nlattr_to_tcp(struct nlattr *
 	    nla_get_u8(tb[CTA_PROTOINFO_TCP_STATE]) >= TCP_CONNTRACK_MAX)
 		return -EINVAL;
 
-	write_lock_bh(&tcp_lock);
+	spin_lock_bh(&ct->proto.tcp.lock);
 	if (tb[CTA_PROTOINFO_TCP_STATE])
 		ct->proto.tcp.state = nla_get_u8(tb[CTA_PROTOINFO_TCP_STATE]);
 
@@ -1177,7 +1174,7 @@ static int nlattr_to_tcp(struct nlattr *
 		ct->proto.tcp.seen[1].td_scale =
 			nla_get_u8(tb[CTA_PROTOINFO_TCP_WSCALE_REPLY]);
 	}
-	write_unlock_bh(&tcp_lock);
+	spin_unlock_bh(&ct->proto.tcp.lock);
 
 	return 0;
 }
--- a/include/net/netfilter/nf_conntrack_helper.h	2009-02-17 11:21:31.207534629 -0800
+++ b/include/net/netfilter/nf_conntrack_helper.h	2009-02-17 11:21:40.928500800 -0800
@@ -34,7 +34,7 @@ struct nf_conntrack_helper
 
 	void (*destroy)(struct nf_conn *ct);
 
-	int (*to_nlattr)(struct sk_buff *skb, const struct nf_conn *ct);
+	int (*to_nlattr)(struct sk_buff *skb, struct nf_conn *ct);
 	unsigned int expect_class_max;
 };
 
--- a/include/net/netfilter/nf_conntrack_l4proto.h	2009-02-17 11:31:28.323255150 -0800
+++ b/include/net/netfilter/nf_conntrack_l4proto.h	2009-02-17 11:31:45.175004794 -0800
@@ -62,8 +62,7 @@ struct nf_conntrack_l4proto
 	int (*print_conntrack)(struct seq_file *s, const struct nf_conn *);
 
 	/* convert protoinfo to nfnetink attributes */
-	int (*to_nlattr)(struct sk_buff *skb, struct nlattr *nla,
-			 const struct nf_conn *ct);
+	int (*to_nlattr)(struct sk_buff *skb, struct nlattr *nla, struct nf_conn *ct);
 
 	/* convert nfnetlink attributes to protoinfo */
 	int (*from_nlattr)(struct nlattr *tb[], struct nf_conn *ct);
--- a/net/netfilter/nf_conntrack_netlink.c	2009-02-17 11:22:33.636503637 -0800
+++ b/net/netfilter/nf_conntrack_netlink.c	2009-02-17 11:33:09.030758630 -0800
@@ -143,7 +143,7 @@ nla_put_failure:
 }
 
 static inline int
-ctnetlink_dump_protoinfo(struct sk_buff *skb, const struct nf_conn *ct)
+ctnetlink_dump_protoinfo(struct sk_buff *skb, struct nf_conn *ct)
 {
 	struct nf_conntrack_l4proto *l4proto;
 	struct nlattr *nest_proto;
@@ -168,7 +168,7 @@ nla_put_failure:
 }
 
 static inline int
-ctnetlink_dump_helpinfo(struct sk_buff *skb, const struct nf_conn *ct)
+ctnetlink_dump_helpinfo(struct sk_buff *skb, struct nf_conn *ct)
 {
 	struct nlattr *nest_helper;
 	const struct nf_conn_help *help = nfct_help(ct);
@@ -350,7 +350,7 @@ nla_put_failure:
 static int
 ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 		    int event, int nowait,
-		    const struct nf_conn *ct)
+		    struct nf_conn *ct)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
--- a/net/netfilter/nf_conntrack_proto_dccp.c	2009-02-17 11:22:33.726792709 -0800
+++ b/net/netfilter/nf_conntrack_proto_dccp.c	2009-02-17 11:32:33.262772938 -0800
@@ -612,7 +612,7 @@ static int dccp_print_conntrack(struct s
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 static int dccp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
-			  const struct nf_conn *ct)
+			  struct nf_conn *ct)
 {
 	struct nlattr *nest_parms;
 
--- a/net/netfilter/nf_conntrack_proto_sctp.c	2009-02-17 11:22:33.824548630 -0800
+++ b/net/netfilter/nf_conntrack_proto_sctp.c	2009-02-17 11:32:44.047257293 -0800
@@ -469,7 +469,7 @@ static bool sctp_new(struct nf_conn *ct,
 #include <linux/netfilter/nfnetlink_conntrack.h>
 
 static int sctp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
-			  const struct nf_conn *ct)
+			  struct nf_conn *ct)
 {
 	struct nlattr *nest_parms;
 

-- 

