From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 02/10] netfilter: nf_log: prepar net namespace support for
	nf_log
Date: Thu, 7 Feb 2013 15:49:42 +0800
Message-ID: <1360223390-15589-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lve-ke3WRBg/xIg@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1360223390-15589-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds netns support for nf_log,contains
three major changes.

1,nf_log_register is split to two functions:
  nf_log_register and nf_log_set.
  The new nf_log_register is used only for register nf_logger,
  nf_log_set is used for setting pernet nf_loggers.

  Because the moudules that use the nf_log_register should be
  changed to use these new functions, and in order not to
  change the behavior. only allow to set the nf_loggers of
  init net.

2,Add net as a parameter of nf_log_bind_pf,only allow init net
  to bind the nflogger to the proto family.

3,Some l4proto such as tcp,udp... use nf_log_packet to log
  the invalid packets, we need pass proper netns to the
  nf_log_packet. Since other netns except init net has
  no nflogger binding to the proto, we only allow nf_log_packet
  handle the log request which comes from init net.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/net/netfilter/nf_log.h                 |  14 +-
 include/net/netns/conntrack.h                  |   3 +
 net/bridge/netfilter/ebt_log.c                 |   5 +-
 net/bridge/netfilter/ebt_nflog.c               |   5 +-
 net/ipv4/netfilter/ip_tables.c                 |   5 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   6 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  10 +-
 net/ipv6/netfilter/ip6_tables.c                |   5 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   5 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   9 +-
 net/netfilter/nf_conntrack_proto_dccp.c        |   9 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |  18 +-
 net/netfilter/nf_conntrack_proto_udp.c         |   6 +-
 net/netfilter/nf_conntrack_proto_udplite.c     |   8 +-
 net/netfilter/nf_log.c                         | 241 ++++++++++++++++++-------
 net/netfilter/nfnetlink_log.c                  |   5 +-
 net/netfilter/xt_osf.c                         |   8 +-
 17 files changed, 249 insertions(+), 113 deletions(-)

diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
index e991bd0..518eb01 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -49,12 +49,18 @@ struct nf_logger {
 int nf_log_register(u_int8_t pf, struct nf_logger *logger);
 void nf_log_unregister(struct nf_logger *logger);
 
-int nf_log_bind_pf(u_int8_t pf, const struct nf_logger *logger);
-void nf_log_unbind_pf(u_int8_t pf);
+void nf_log_set(struct net *net, u_int8_t pf,
+		struct nf_logger *logger);
+void nf_log_unset(struct net *net, struct nf_logger *logger);
+
+int nf_log_bind_pf(struct net *net, u_int8_t pf,
+		   const struct nf_logger *logger);
+void nf_log_unbind_pf(struct net *net, u_int8_t pf);
 
 /* Calls the registered backend logging function */
-__printf(7, 8)
-void nf_log_packet(u_int8_t pf,
+__printf(8, 9)
+void nf_log_packet(struct net *net,
+		   u_int8_t pf,
 		   unsigned int hooknum,
 		   const struct sk_buff *skb,
 		   const struct net_device *in,
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index c9c0c53..6358d5f 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -8,6 +8,7 @@
 
 struct ctl_table_header;
 struct nf_conntrack_ecache;
+struct nf_logger;
 
 struct nf_proto_net {
 #ifdef CONFIG_SYSCTL
@@ -73,6 +74,7 @@ struct netns_ct {
 	struct hlist_nulls_head	dying;
 	struct hlist_nulls_head tmpl;
 	struct ip_conntrack_stat __percpu *stat;
+	const struct nf_logger __rcu *nf_loggers[NFPROTO_NUMPROTO];
 	struct nf_ct_event_notifier __rcu *nf_conntrack_event_cb;
 	struct nf_exp_event_notifier __rcu *nf_expect_event_cb;
 	int			sysctl_events;
@@ -98,6 +100,7 @@ struct netns_ct {
 	struct ctl_table_header	*tstamp_sysctl_header;
 	struct ctl_table_header	*event_sysctl_header;
 	struct ctl_table_header	*helper_sysctl_header;
+	struct ctl_table_header *nf_log_dir_header;
 #endif
 	char			*slabname;
 };
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 92de5e5..1d397ac 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -176,14 +176,15 @@ ebt_log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_log_info *info = par->targinfo;
 	struct nf_loginfo li;
+	struct net *net = dev_net(par->in ? par->in : par->out);
 
 	li.type = NF_LOG_TYPE_LOG;
 	li.u.log.level = info->loglevel;
 	li.u.log.logflags = info->bitmask;
 
 	if (info->bitmask & EBT_LOG_NFLOG)
-		nf_log_packet(NFPROTO_BRIDGE, par->hooknum, skb, par->in,
-		              par->out, &li, "%s", info->prefix);
+		nf_log_packet(net, NFPROTO_BRIDGE, par->hooknum, skb,
+			      par->in, par->out, &li, "%s", info->prefix);
 	else
 		ebt_log_packet(NFPROTO_BRIDGE, par->hooknum, skb, par->in,
 		               par->out, &li, info->prefix);
diff --git a/net/bridge/netfilter/ebt_nflog.c b/net/bridge/netfilter/ebt_nflog.c
index 5be68bb..101b6e4 100644
--- a/net/bridge/netfilter/ebt_nflog.c
+++ b/net/bridge/netfilter/ebt_nflog.c
@@ -24,14 +24,15 @@ ebt_nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_nflog_info *info = par->targinfo;
 	struct nf_loginfo li;
+	struct net *net = dev_net(par->in ? par->in : par->out);
 
 	li.type = NF_LOG_TYPE_ULOG;
 	li.u.ulog.copy_len = info->len;
 	li.u.ulog.group = info->group;
 	li.u.ulog.qthreshold = info->threshold;
 
-	nf_log_packet(PF_BRIDGE, par->hooknum, skb, par->in, par->out,
-	              &li, "%s", info->prefix);
+	nf_log_packet(net, PF_BRIDGE, par->hooknum, skb,
+		      par->in, par->out, &li, "%s", info->prefix);
 	return EBT_CONTINUE;
 }
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 17c5e06..3b5e0e2 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -259,6 +259,7 @@ static void trace_packet(const struct sk_buff *skb,
 	const char *hookname, *chainname, *comment;
 	const struct ipt_entry *iter;
 	unsigned int rulenum = 0;
+	struct net *net = dev_net(in ? in : out);
 
 	table_base = private->entries[smp_processor_id()];
 	root = get_entry(table_base, private->hook_entry[hook]);
@@ -271,8 +272,8 @@ static void trace_packet(const struct sk_buff *skb,
 		    &chainname, &comment, &rulenum) != 0)
 			break;
 
-	nf_log_packet(AF_INET, hook, skb, in, out, &trace_loginfo,
-		      "TRACE: %s:%s:%s:%u ",
+	nf_log_packet(net, AF_INET, hook, skb, in, out,
+		      &trace_loginfo, "TRACE: %s:%s:%s:%u ",
 		      tablename, chainname, comment, rulenum);
 }
 #endif
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 48990ad..640215c 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -101,6 +101,7 @@ static unsigned int ipv4_helper(unsigned int hooknum,
 	const struct nf_conn_help *help;
 	const struct nf_conntrack_helper *helper;
 	unsigned int ret;
+	struct net *net = dev_net(in ? in : out);
 
 	/* This is where we call the helper: as the packet goes out. */
 	ct = nf_ct_get(skb, &ctinfo);
@@ -119,8 +120,9 @@ static unsigned int ipv4_helper(unsigned int hooknum,
 	ret = helper->help(skb, skb_network_offset(skb) + ip_hdrlen(skb),
 			   ct, ctinfo);
 	if (ret != NF_ACCEPT && (ret & NF_VERDICT_MASK) != NF_QUEUE) {
-		nf_log_packet(NFPROTO_IPV4, hooknum, skb, in, out, NULL,
-			      "nf_ct_%s: dropping packet", helper->name);
+		nf_log_packet(net, NFPROTO_IPV4, hooknum, skb, in,
+			      out, NULL, "nf_ct_%s: dropping packet",
+			      helper->name);
 	}
 	return ret;
 }
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 5241d99..4275a63 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -187,8 +187,8 @@ icmp_error(struct net *net, struct nf_conn *tmpl,
 	icmph = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_ih), &_ih);
 	if (icmph == NULL) {
 		if (LOG_INVALID(net, IPPROTO_ICMP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
-				      "nf_ct_icmp: short packet ");
+			nf_log_packet(net, PF_INET, 0, skb, NULL, NULL,
+				      NULL, "nf_ct_icmp: short packet ");
 		return -NF_ACCEPT;
 	}
 
@@ -196,8 +196,8 @@ icmp_error(struct net *net, struct nf_conn *tmpl,
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_ip_checksum(skb, hooknum, dataoff, 0)) {
 		if (LOG_INVALID(net, IPPROTO_ICMP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
-				      "nf_ct_icmp: bad HW ICMP checksum ");
+			nf_log_packet(net, PF_INET, 0, skb, NULL, NULL,
+				NULL, "nf_ct_icmp: bad HW ICMP checksum ");
 		return -NF_ACCEPT;
 	}
 
@@ -209,7 +209,7 @@ icmp_error(struct net *net, struct nf_conn *tmpl,
 	 */
 	if (icmph->type > NR_ICMP_TYPES) {
 		if (LOG_INVALID(net, IPPROTO_ICMP))
-			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, PF_INET, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_icmp: invalid ICMP type ");
 		return -NF_ACCEPT;
 	}
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 125a90d..71b3631 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -283,6 +283,7 @@ static void trace_packet(const struct sk_buff *skb,
 	const struct ip6t_entry *root;
 	const char *hookname, *chainname, *comment;
 	const struct ip6t_entry *iter;
+	struct net *net = dev_net(in ? in : out);
 	unsigned int rulenum = 0;
 
 	table_base = private->entries[smp_processor_id()];
@@ -296,8 +297,8 @@ static void trace_packet(const struct sk_buff *skb,
 		    &chainname, &comment, &rulenum) != 0)
 			break;
 
-	nf_log_packet(AF_INET6, hook, skb, in, out, &trace_loginfo,
-		      "TRACE: %s:%s:%s:%u ",
+	nf_log_packet(net, AF_INET6, hook, skb, in, out,
+		      &trace_loginfo, "TRACE: %s:%s:%s:%u ",
 		      tablename, chainname, comment, rulenum);
 }
 #endif
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 8a45bb2..375a75b 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -104,6 +104,7 @@ static unsigned int ipv6_helper(unsigned int hooknum,
 	const struct nf_conn_help *help;
 	const struct nf_conntrack_helper *helper;
 	enum ip_conntrack_info ctinfo;
+	struct net *net = dev_net(in ? in : out);
 	unsigned int ret;
 	__be16 frag_off;
 	int protoff;
@@ -132,8 +133,8 @@ static unsigned int ipv6_helper(unsigned int hooknum,
 
 	ret = helper->help(skb, protoff, ct, ctinfo);
 	if (ret != NF_ACCEPT && (ret & NF_VERDICT_MASK) != NF_QUEUE) {
-		nf_log_packet(NFPROTO_IPV6, hooknum, skb, in, out, NULL,
-			      "nf_ct_%s: dropping packet", helper->name);
+		nf_log_packet(net, NFPROTO_IPV6, hooknum, skb, in, out,
+			      NULL, "nf_ct_%s: dropping packet", helper->name);
 	}
 	return ret;
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 24df3dd..4b6c9e0 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -131,7 +131,8 @@ static bool icmpv6_new(struct nf_conn *ct, const struct sk_buff *skb,
 			 type + 128);
 		nf_ct_dump_tuple_ipv6(&ct->tuplehash[0].tuple);
 		if (LOG_INVALID(nf_ct_net(ct), IPPROTO_ICMPV6))
-			nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(nf_ct_net(ct), PF_INET6, 0, skb, NULL,
+				      NULL, NULL,
 				      "nf_ct_icmpv6: invalid new with type %d ",
 				      type + 128);
 		return false;
@@ -203,15 +204,15 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	icmp6h = skb_header_pointer(skb, dataoff, sizeof(_ih), &_ih);
 	if (icmp6h == NULL) {
 		if (LOG_INVALID(net, IPPROTO_ICMPV6))
-		nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
-			      "nf_ct_icmpv6: short packet ");
+			nf_log_packet(net, PF_INET6, 0, skb, NULL, NULL, NULL,
+				      "nf_ct_icmpv6: short packet ");
 		return -NF_ACCEPT;
 	}
 
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_ip6_checksum(skb, hooknum, dataoff, IPPROTO_ICMPV6)) {
 		if (LOG_INVALID(net, IPPROTO_ICMPV6))
-			nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, PF_INET6, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_icmpv6: ICMPv6 checksum failed ");
 		return -NF_ACCEPT;
 	}
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 432f957..ef7201a 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -456,7 +456,8 @@ static bool dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
 
 out_invalid:
 	if (LOG_INVALID(net, IPPROTO_DCCP))
-		nf_log_packet(nf_ct_l3num(ct), 0, skb, NULL, NULL, NULL, msg);
+		nf_log_packet(net, nf_ct_l3num(ct), 0, skb, NULL,
+			      NULL, NULL, msg);
 	return false;
 }
 
@@ -542,13 +543,13 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 
 		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_DCCP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_dccp: invalid packet ignored ");
 		return NF_ACCEPT;
 	case CT_DCCP_INVALID:
 		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_DCCP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_dccp: invalid state transition ");
 		return -NF_ACCEPT;
 	}
@@ -613,7 +614,7 @@ static int dccp_error(struct net *net, struct nf_conn *tmpl,
 
 out_invalid:
 	if (LOG_INVALID(net, IPPROTO_DCCP))
-		nf_log_packet(pf, 0, skb, NULL, NULL, NULL, msg);
+		nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL, msg);
 	return -NF_ACCEPT;
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 83876e9..f021a20 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -720,7 +720,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 		    tn->tcp_be_liberal)
 			res = true;
 		if (!res && LOG_INVALID(net, IPPROTO_TCP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 			"nf_ct_tcp: %s ",
 			before(seq, sender->td_maxend + 1) ?
 			after(end, sender->td_end - receiver->td_maxwin - 1) ?
@@ -772,7 +772,7 @@ static int tcp_error(struct net *net, struct nf_conn *tmpl,
 	th = skb_header_pointer(skb, dataoff, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
 		if (LOG_INVALID(net, IPPROTO_TCP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_tcp: short packet ");
 		return -NF_ACCEPT;
 	}
@@ -780,7 +780,7 @@ static int tcp_error(struct net *net, struct nf_conn *tmpl,
 	/* Not whole TCP header or malformed packet */
 	if (th->doff*4 < sizeof(struct tcphdr) || tcplen < th->doff*4) {
 		if (LOG_INVALID(net, IPPROTO_TCP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_tcp: truncated/malformed packet ");
 		return -NF_ACCEPT;
 	}
@@ -793,7 +793,7 @@ static int tcp_error(struct net *net, struct nf_conn *tmpl,
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum(skb, hooknum, dataoff, IPPROTO_TCP, pf)) {
 		if (LOG_INVALID(net, IPPROTO_TCP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: bad TCP checksum ");
 		return -NF_ACCEPT;
 	}
@@ -802,7 +802,7 @@ static int tcp_error(struct net *net, struct nf_conn *tmpl,
 	tcpflags = (tcp_flag_byte(th) & ~(TCPHDR_ECE|TCPHDR_CWR|TCPHDR_PSH));
 	if (!tcp_valid_flags[tcpflags]) {
 		if (LOG_INVALID(net, IPPROTO_TCP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid TCP flag combination ");
 		return -NF_ACCEPT;
 	}
@@ -949,7 +949,7 @@ static int tcp_packet(struct nf_conn *ct,
 		}
 		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid packet ignored in "
 				  "state %s ", tcp_conntrack_names[old_state]);
 		return NF_ACCEPT;
@@ -959,7 +959,7 @@ static int tcp_packet(struct nf_conn *ct,
 			 dir, get_conntrack_index(th), old_state);
 		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid state ");
 		return -NF_ACCEPT;
 	case TCP_CONNTRACK_CLOSE:
@@ -969,8 +969,8 @@ static int tcp_packet(struct nf_conn *ct,
 			/* Invalid RST  */
 			spin_unlock_bh(&ct->lock);
 			if (LOG_INVALID(net, IPPROTO_TCP))
-				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
-					  "nf_ct_tcp: invalid RST ");
+				nf_log_packet(net, pf, 0, skb, NULL, NULL,
+					      NULL, "nf_ct_tcp: invalid RST ");
 			return -NF_ACCEPT;
 		}
 		if (index == TCP_RST_SET
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 59623cc..fee4322 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -119,7 +119,7 @@ static int udp_error(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	hdr = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
 	if (hdr == NULL) {
 		if (LOG_INVALID(net, IPPROTO_UDP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udp: short packet ");
 		return -NF_ACCEPT;
 	}
@@ -127,7 +127,7 @@ static int udp_error(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	/* Truncated/malformed packets */
 	if (ntohs(hdr->len) > udplen || ntohs(hdr->len) < sizeof(*hdr)) {
 		if (LOG_INVALID(net, IPPROTO_UDP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_udp: truncated/malformed packet ");
 		return -NF_ACCEPT;
 	}
@@ -143,7 +143,7 @@ static int udp_error(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum(skb, hooknum, dataoff, IPPROTO_UDP, pf)) {
 		if (LOG_INVALID(net, IPPROTO_UDP))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_udp: bad UDP checksum ");
 		return -NF_ACCEPT;
 	}
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 1574895..c29d359 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -131,7 +131,7 @@ static int udplite_error(struct net *net, struct nf_conn *tmpl,
 	hdr = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
 	if (hdr == NULL) {
 		if (LOG_INVALID(net, IPPROTO_UDPLITE))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udplite: short packet ");
 		return -NF_ACCEPT;
 	}
@@ -141,7 +141,7 @@ static int udplite_error(struct net *net, struct nf_conn *tmpl,
 		cscov = udplen;
 	else if (cscov < sizeof(*hdr) || cscov > udplen) {
 		if (LOG_INVALID(net, IPPROTO_UDPLITE))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_udplite: invalid checksum coverage ");
 		return -NF_ACCEPT;
 	}
@@ -149,7 +149,7 @@ static int udplite_error(struct net *net, struct nf_conn *tmpl,
 	/* UDPLITE mandates checksums */
 	if (!hdr->check) {
 		if (LOG_INVALID(net, IPPROTO_UDPLITE))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udplite: checksum missing ");
 		return -NF_ACCEPT;
 	}
@@ -159,7 +159,7 @@ static int udplite_error(struct net *net, struct nf_conn *tmpl,
 	    nf_checksum_partial(skb, hooknum, dataoff, cscov, IPPROTO_UDP,
 	    			pf)) {
 		if (LOG_INVALID(net, IPPROTO_UDPLITE))
-			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
+			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udplite: bad UDPLite checksum ");
 		return -NF_ACCEPT;
 	}
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 9e31269..b1e5126 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -16,7 +16,6 @@
 #define NF_LOG_PREFIXLEN		128
 #define NFLOGGER_NAME_LEN		64
 
-static const struct nf_logger __rcu *nf_loggers[NFPROTO_NUMPROTO] __read_mostly;
 static struct list_head nf_loggers_l[NFPROTO_NUMPROTO] __read_mostly;
 static DEFINE_MUTEX(nf_log_mutex);
 
@@ -32,13 +31,50 @@ static struct nf_logger *__find_logger(int pf, const char *str_logger)
 	return NULL;
 }
 
+void nf_log_set(struct net *net, u_int8_t pf, struct nf_logger *logger)
+{
+	if (!net_eq(net, &init_net))
+		return;
+
+	if (pf != NFPROTO_UNSPEC) {
+		const struct nf_logger *llog;
+		mutex_lock(&nf_log_mutex);
+		llog = rcu_dereference_protected(net->ct.nf_loggers[pf],
+					lockdep_is_held(&nf_log_mutex));
+		if (llog == NULL)
+			rcu_assign_pointer(net->ct.nf_loggers[pf], logger);
+
+		mutex_unlock(&nf_log_mutex);
+	}
+}
+EXPORT_SYMBOL(nf_log_set);
+
+void nf_log_unset(struct net *net, struct nf_logger *logger)
+{
+	int i;
+	const struct nf_logger *c_logger;
+
+	if (!net_eq(net, &init_net))
+		return;
+
+	mutex_lock(&nf_log_mutex);
+	for (i = 0; i < NFPROTO_NUMPROTO; i++) {
+		c_logger = rcu_dereference_protected(net->ct.nf_loggers[i],
+				lockdep_is_held(&nf_log_mutex));
+		if (c_logger == logger)
+			RCU_INIT_POINTER(net->ct.nf_loggers[i], NULL);
+	}
+	mutex_unlock(&nf_log_mutex);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL(nf_log_unset);
+
 /* return EEXIST if the same logger is registered, 0 on success. */
 int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 {
-	const struct nf_logger *llog;
 	int i;
 
-	if (pf >= ARRAY_SIZE(nf_loggers))
+	if (pf >= ARRAY_SIZE(init_net.ct.nf_loggers))
 		return -EINVAL;
 
 	for (i = 0; i < ARRAY_SIZE(logger->list); i++)
@@ -46,69 +82,69 @@ int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 
 	mutex_lock(&nf_log_mutex);
 
-	if (pf == NFPROTO_UNSPEC) {
+	if (pf == NFPROTO_UNSPEC)
 		for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
 			list_add_tail(&(logger->list[i]), &(nf_loggers_l[i]));
-	} else {
+	else
 		/* register at end of list to honor first register win */
 		list_add_tail(&logger->list[pf], &nf_loggers_l[pf]);
-		llog = rcu_dereference_protected(nf_loggers[pf],
-						 lockdep_is_held(&nf_log_mutex));
-		if (llog == NULL)
-			rcu_assign_pointer(nf_loggers[pf], logger);
-	}
 
 	mutex_unlock(&nf_log_mutex);
 
+	nf_log_set(&init_net, pf, logger);
 	return 0;
 }
 EXPORT_SYMBOL(nf_log_register);
 
 void nf_log_unregister(struct nf_logger *logger)
 {
-	const struct nf_logger *c_logger;
 	int i;
 
 	mutex_lock(&nf_log_mutex);
-	for (i = 0; i < ARRAY_SIZE(nf_loggers); i++) {
-		c_logger = rcu_dereference_protected(nf_loggers[i],
-						     lockdep_is_held(&nf_log_mutex));
-		if (c_logger == logger)
-			RCU_INIT_POINTER(nf_loggers[i], NULL);
+	for (i = 0; i < NFPROTO_NUMPROTO; i++)
 		list_del(&logger->list[i]);
-	}
-	mutex_unlock(&nf_log_mutex);
 
-	synchronize_rcu();
+	mutex_unlock(&nf_log_mutex);
+	nf_log_unset(&init_net, logger);
 }
 EXPORT_SYMBOL(nf_log_unregister);
 
-int nf_log_bind_pf(u_int8_t pf, const struct nf_logger *logger)
+int nf_log_bind_pf(struct net *net, u_int8_t pf,
+		   const struct nf_logger *logger)
 {
-	if (pf >= ARRAY_SIZE(nf_loggers))
+	if (!net_eq(net, &init_net))
+		return 0;
+
+	if (pf >= ARRAY_SIZE(net->ct.nf_loggers))
 		return -EINVAL;
+
 	mutex_lock(&nf_log_mutex);
 	if (__find_logger(pf, logger->name) == NULL) {
 		mutex_unlock(&nf_log_mutex);
 		return -ENOENT;
 	}
-	rcu_assign_pointer(nf_loggers[pf], logger);
+	rcu_assign_pointer(net->ct.nf_loggers[pf], logger);
 	mutex_unlock(&nf_log_mutex);
 	return 0;
 }
 EXPORT_SYMBOL(nf_log_bind_pf);
 
-void nf_log_unbind_pf(u_int8_t pf)
+void nf_log_unbind_pf(struct net *net, u_int8_t pf)
 {
-	if (pf >= ARRAY_SIZE(nf_loggers))
+	if (!net_eq(net, &init_net))
+		return;
+
+	if (pf >= ARRAY_SIZE(net->ct.nf_loggers))
 		return;
+
 	mutex_lock(&nf_log_mutex);
-	RCU_INIT_POINTER(nf_loggers[pf], NULL);
+	RCU_INIT_POINTER(net->ct.nf_loggers[pf], NULL);
 	mutex_unlock(&nf_log_mutex);
 }
 EXPORT_SYMBOL(nf_log_unbind_pf);
 
-void nf_log_packet(u_int8_t pf,
+void nf_log_packet(struct net *net,
+		   u_int8_t pf,
 		   unsigned int hooknum,
 		   const struct sk_buff *skb,
 		   const struct net_device *in,
@@ -120,8 +156,11 @@ void nf_log_packet(u_int8_t pf,
 	char prefix[NF_LOG_PREFIXLEN];
 	const struct nf_logger *logger;
 
+	if (!net_eq(net, &init_net))
+		return;
+
 	rcu_read_lock();
-	logger = rcu_dereference(nf_loggers[pf]);
+	logger = rcu_dereference(net->ct.nf_loggers[pf]);
 	if (logger) {
 		va_start(args, fmt);
 		vsnprintf(prefix, sizeof(prefix), fmt, args);
@@ -133,11 +172,13 @@ void nf_log_packet(u_int8_t pf,
 EXPORT_SYMBOL(nf_log_packet);
 
 #ifdef CONFIG_PROC_FS
-static void *seq_start(struct seq_file *seq, loff_t *pos)
+static void *seq_start(struct seq_file *s, loff_t *pos)
 {
+	struct net *net = seq_file_net(s);
+
 	mutex_lock(&nf_log_mutex);
 
-	if (*pos >= ARRAY_SIZE(nf_loggers))
+	if (*pos >= ARRAY_SIZE(net->ct.nf_loggers))
 		return NULL;
 
 	return pos;
@@ -145,9 +186,10 @@ static void *seq_start(struct seq_file *seq, loff_t *pos)
 
 static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
 {
-	(*pos)++;
+	struct net *net = seq_file_net(s);
 
-	if (*pos >= ARRAY_SIZE(nf_loggers))
+	(*pos)++;
+	if (*pos >= ARRAY_SIZE(net->ct.nf_loggers))
 		return NULL;
 
 	return pos;
@@ -163,9 +205,10 @@ static int seq_show(struct seq_file *s, void *v)
 	loff_t *pos = v;
 	const struct nf_logger *logger;
 	struct nf_logger *t;
+	struct net *net = seq_file_net(s);
 	int ret;
 
-	logger = rcu_dereference_protected(nf_loggers[*pos],
+	logger = rcu_dereference_protected(net->ct.nf_loggers[*pos],
 					   lockdep_is_held(&nf_log_mutex));
 
 	if (!logger)
@@ -199,7 +242,8 @@ static const struct seq_operations nflog_seq_ops = {
 
 static int nflog_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &nflog_seq_ops);
+	return seq_open_net(inode, file, &nflog_seq_ops,
+			    sizeof(struct seq_net_private));
 }
 
 static const struct file_operations nflog_file_ops = {
@@ -207,7 +251,7 @@ static const struct file_operations nflog_file_ops = {
 	.open	 = nflog_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 
@@ -216,7 +260,6 @@ static const struct file_operations nflog_file_ops = {
 #ifdef CONFIG_SYSCTL
 static char nf_log_sysctl_fnames[NFPROTO_NUMPROTO-NFPROTO_UNSPEC][3];
 static struct ctl_table nf_log_sysctl_table[NFPROTO_NUMPROTO+1];
-static struct ctl_table_header *nf_log_dir_header;
 
 static int nf_log_proc_dostring(ctl_table *table, int write,
 			 void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -226,15 +269,19 @@ static int nf_log_proc_dostring(ctl_table *table, int write,
 	size_t size = *lenp;
 	int r = 0;
 	int tindex = (unsigned long)table->extra1;
+	struct net *net = current->nsproxy->net_ns;
 
 	if (write) {
+		if (!net_eq(net, &init_net))
+			return -EPERM;
+
 		if (size > sizeof(buf))
 			size = sizeof(buf);
 		if (copy_from_user(buf, buffer, size))
 			return -EFAULT;
 
 		if (!strcmp(buf, "NONE")) {
-			nf_log_unbind_pf(tindex);
+			nf_log_unbind_pf(net, tindex);
 			return 0;
 		}
 		mutex_lock(&nf_log_mutex);
@@ -243,11 +290,11 @@ static int nf_log_proc_dostring(ctl_table *table, int write,
 			mutex_unlock(&nf_log_mutex);
 			return -ENOENT;
 		}
-		rcu_assign_pointer(nf_loggers[tindex], logger);
+		rcu_assign_pointer(net->ct.nf_loggers[tindex], logger);
 		mutex_unlock(&nf_log_mutex);
 	} else {
 		mutex_lock(&nf_log_mutex);
-		logger = rcu_dereference_protected(nf_loggers[tindex],
+		logger = rcu_dereference_protected(net->ct.nf_loggers[tindex],
 						   lockdep_is_held(&nf_log_mutex));
 		if (!logger)
 			table->data = "NONE";
@@ -260,49 +307,117 @@ static int nf_log_proc_dostring(ctl_table *table, int write,
 	return r;
 }
 
-static __init int netfilter_log_sysctl_init(void)
+static int netfilter_log_sysctl_init(struct net *net)
 {
-	int i;
+	unsigned int i;
+	struct ctl_table *table;
 
-	for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++) {
-		snprintf(nf_log_sysctl_fnames[i-NFPROTO_UNSPEC], 3, "%d", i);
-		nf_log_sysctl_table[i].procname	=
-			nf_log_sysctl_fnames[i-NFPROTO_UNSPEC];
-		nf_log_sysctl_table[i].data = NULL;
-		nf_log_sysctl_table[i].maxlen =
-			NFLOGGER_NAME_LEN * sizeof(char);
-		nf_log_sysctl_table[i].mode = 0644;
-		nf_log_sysctl_table[i].proc_handler = nf_log_proc_dostring;
-		nf_log_sysctl_table[i].extra1 = (void *)(unsigned long) i;
+	table = nf_log_sysctl_table;
+	if (!net_eq(net, &init_net)) {
+		table = kmemdup(nf_log_sysctl_table,
+				sizeof(nf_log_sysctl_table),
+				GFP_KERNEL);
+		if (!table)
+			goto err_alloc;
+
+		for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
+			table[i].data = NULL;
+	} else {
+		for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++) {
+			snprintf(nf_log_sysctl_fnames[i-NFPROTO_UNSPEC],
+				 3, "%d", i);
+			nf_log_sysctl_table[i].procname	=
+				nf_log_sysctl_fnames[i-NFPROTO_UNSPEC];
+			nf_log_sysctl_table[i].data = NULL;
+			nf_log_sysctl_table[i].maxlen =
+				NFLOGGER_NAME_LEN * sizeof(char);
+			nf_log_sysctl_table[i].mode = 0644;
+			nf_log_sysctl_table[i].proc_handler =
+				nf_log_proc_dostring;
+			nf_log_sysctl_table[i].extra1 =
+				(void *)(unsigned long) i;
+		}
 	}
 
-	nf_log_dir_header = register_net_sysctl(&init_net, "net/netfilter/nf_log",
-				       nf_log_sysctl_table);
-	if (!nf_log_dir_header)
-		return -ENOMEM;
+	net->ct.nf_log_dir_header = register_net_sysctl(net,
+					"net/netfilter/nf_log",
+					table);
+	if (!net->ct.nf_log_dir_header)
+		goto err_reg;
 
 	return 0;
+
+err_reg:
+	if (!net_eq(net, &init_net))
+		kfree(net);
+err_alloc:
+	return -ENOMEM;
+}
+
+static void netfilter_log_sysctl_exit(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = net->ct.nf_log_dir_header->ctl_table_arg;
+	unregister_net_sysctl_table(net->ct.nf_log_dir_header);
+	if (!net_eq(net, &init_net))
+		kfree(table);
 }
 #else
-static __init int netfilter_log_sysctl_init(void)
+static int netfilter_log_sysctl_init(struct net *net)
 {
 	return 0;
 }
+
+static void netfilter_log_sysctl_exit(struct net *net)
+{
+}
 #endif /* CONFIG_SYSCTL */
 
-int __init netfilter_log_init(void)
+static int __net_init nf_log_net_init(struct net *net)
 {
-	int i, r;
+	int ret = -ENOMEM;
 #ifdef CONFIG_PROC_FS
 	if (!proc_create("nf_log", S_IRUGO,
-			 proc_net_netfilter, &nflog_file_ops))
-		return -1;
+			 net->xt.proc_netfilter, &nflog_file_ops))
+		goto out_proc;
 #endif
+	ret = netfilter_log_sysctl_init(net);
+	if (ret < 0)
+		goto out_sysctl;
+
+	return 0;
+out_sysctl:
+#ifdef CONFIG_PROC_FS
+	/*
+	 * For init net, Errors will trigger panic,
+	 * unroll on error is unnecessary.
+	 */
+	if (!net_eq(net, &init_net))
+		remove_proc_entry("nf_log", net->xt.proc_netfilter);
+out_proc:
+#endif
+	return ret;
+}
+
+static void __net_exit nf_log_net_exit(struct net *net)
+{
+	netfilter_log_sysctl_exit(net);
+	remove_proc_entry("nf_log", net->xt.proc_netfilter);
+}
 
-	/* Errors will trigger panic, unroll on error is unnecessary. */
-	r = netfilter_log_sysctl_init();
-	if (r < 0)
-		return r;
+static struct pernet_operations nf_log_net_ops = {
+	.init = nf_log_net_init,
+	.exit = nf_log_net_exit,
+};
+
+int __init netfilter_log_init(void)
+{
+	int i, ret;
+
+	ret = register_pernet_subsys(&nf_log_net_ops);
+	if (ret < 0)
+		return ret;
 
 	for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
 		INIT_LIST_HEAD(&(nf_loggers_l[i]));
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 92fd8ec..8f35467 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -768,6 +768,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 	u_int16_t group_num = ntohs(nfmsg->res_id);
 	struct nfulnl_instance *inst;
 	struct nfulnl_msg_config_cmd *cmd = NULL;
+	struct net *net = sock_net(ctnl);
 	int ret = 0;
 
 	if (nfula[NFULA_CFG_CMD]) {
@@ -777,9 +778,9 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 		/* Commands without queue context */
 		switch (cmd->command) {
 		case NFULNL_CFG_CMD_PF_BIND:
-			return nf_log_bind_pf(pf, &nfulnl_logger);
+			return nf_log_bind_pf(net, pf, &nfulnl_logger);
 		case NFULNL_CFG_CMD_PF_UNBIND:
-			nf_log_unbind_pf(pf);
+			nf_log_unbind_pf(net, pf);
 			return 0;
 		}
 	}
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index a5e673d..b6c61cd 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -201,6 +201,7 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 	unsigned char opts[MAX_IPOPTLEN];
 	const struct xt_osf_finger *kf;
 	const struct xt_osf_user_finger *f;
+	struct net *net = dev_net(p->in ? p->in : p->out);
 
 	if (!info)
 		return false;
@@ -325,8 +326,8 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 			fcount++;
 
 			if (info->flags & XT_OSF_LOG)
-				nf_log_packet(p->family, p->hooknum, skb,
-					p->in, p->out, NULL,
+				nf_log_packet(net, p->family, p->hooknum,
+					skb, p->in, p->out, NULL,
 					"%s [%s:%s] : %pI4:%d -> %pI4:%d hops=%d\n",
 					f->genre, f->version, f->subtype,
 					&ip->saddr, ntohs(tcp->source),
@@ -341,7 +342,8 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 	rcu_read_unlock();
 
 	if (!fcount && (info->flags & XT_OSF_LOG))
-		nf_log_packet(p->family, p->hooknum, skb, p->in, p->out, NULL,
+		nf_log_packet(net, p->family, p->hooknum, skb, p->in,
+				p->out, NULL,
 			"Remote OS is not known: %pI4:%u -> %pI4:%u\n",
 				&ip->saddr, ntohs(tcp->source),
 				&ip->daddr, ntohs(tcp->dest));
-- 
1.7.11.7
