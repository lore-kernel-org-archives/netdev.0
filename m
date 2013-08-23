From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 6/6] netfilter: synproxy: fix handling of retransmissions before established state
Date: Fri, 23 Aug 2013 09:52:09 +0200
Message-ID: <1377244329-20146-7-git-send-email-kaber@trash.net>
References: <1377244329-20146-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	mph@one.com, jesper.brouer@gmail.com, as@one.com
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1377244329-20146-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix multiple issues with retransmissions and out of order packets:

- the final ACK to the server was incorrectly manually attached to the
  existing conntrack entry, causing conntrack to skip handling the packet
  and thus not moving the connection from SYN_RECV to ESTABLISHED state.

- if the final ACK then got lost, a retransmitted SYN/ACK would
  reinitialize timestamp adjustments. The initialization was done
  incrementally though, so at that point the translation would result
  in incorrect timestamp values. To prevent this, the timestamp
  adjustments are not initialized incrementally anymore, but the initial
  timestamp value is stored and adjustment is initialized based on the
  difference between the value stored and the value received in the
  SYN/ACK. Additionally the first point makes sure we're in ESTABLISHED
  state after initialization is complete.

- when a keep-alive from the client was received before the connection
  moved to ESTABLISHED state (SYN to the server was lost) and the client
  sent a keep alive, TCP conntrack regarded the keep alive as invalid in
  this state, meaning it didn't get associated with the conntrack and
  (since INVALID packets are directed to the SYNPROXY target by the
  ruleset to catch the final ACK from the client) hit the SYNPROXY target
  again.

  Since keep alives are sent with SEG.SEQ = SND.NXT-1, a new connection
  with a sequence number off by one was established to the server.
  A special case is added to TCP conntrack handling of invalid packets
  to catch the keep alives and associate them with the correct conntrack
  entry so the retransmitted SYN to the server will use the correct
  sequence number. A new counter has been introduced for these
  retranmissions.

Additionally:

- fix the window size announced in the window update sent to the client
  when the connection to the server is established: the window value is
  taken from the server's SYN/ACK, meaning it is unscaled, so we have to
  scale it down when including it in a pure ACK.

- don't reinitializex sequence number translation when a RST is received
  for an establshed connection. This is only supposed to be done when the
  first and only reply is a RST.

With these changes, I get 100% success rate at connection establishment
even with drop rates of 10%.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack_synproxy.h |  2 +
 net/ipv4/netfilter/ipt_SYNPROXY.c             | 88 ++++++++++++++++-----------
 net/ipv6/netfilter/ip6t_SYNPROXY.c            | 88 ++++++++++++++++-----------
 net/netfilter/nf_conntrack_proto_tcp.c        | 16 +++++
 net/netfilter/nf_synproxy_core.c              | 10 +--
 5 files changed, 132 insertions(+), 72 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_synproxy.h b/include/net/netfilter/nf_conntrack_synproxy.h
index cc43895..c3de4a2 100644
--- a/include/net/netfilter/nf_conntrack_synproxy.h
+++ b/include/net/netfilter/nf_conntrack_synproxy.h
@@ -5,6 +5,7 @@
 
 struct nf_conn_synproxy {
 	u32	isn;
+	u32	its;
 	u32	tsoff;
 };
 
@@ -30,6 +31,7 @@ struct synproxy_stats {
 	unsigned int			syn_received;
 	unsigned int			cookie_invalid;
 	unsigned int			cookie_valid;
+	unsigned int			cookie_retrans;
 };
 
 struct synproxy_net {
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index d8577e0..8fd6143 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -54,9 +54,11 @@ synproxy_send_tcp(const struct sk_buff *skb, struct sk_buff *nskb,
 	if (ip_route_me_harder(nskb, RTN_UNSPEC))
 		goto free_nskb;
 
-	nskb->nfct = nfct;
-	nskb->nfctinfo = ctinfo;
-	nf_conntrack_get(nfct);
+	if (nfct) {
+		nskb->nfct = nfct;
+		nskb->nfctinfo = ctinfo;
+		nf_conntrack_get(nfct);
+	}
 
 	ip_local_out(nskb);
 	return;
@@ -109,7 +111,7 @@ synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
 static void
 synproxy_send_server_syn(const struct synproxy_net *snet,
 			 const struct sk_buff *skb, const struct tcphdr *th,
-			 const struct synproxy_options *opts)
+			 const struct synproxy_options *opts, u32 recv_seq)
 {
 	struct sk_buff *nskb;
 	struct iphdr *iph, *niph;
@@ -131,7 +133,7 @@ synproxy_send_server_syn(const struct synproxy_net *snet,
 	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->source;
 	nth->dest	= th->dest;
-	nth->seq	= htonl(ntohl(th->seq) - 1);
+	nth->seq	= htonl(recv_seq - 1);
 	/* ack_seq is used to relay our ISN to the synproxy hook to initialize
 	 * sequence number translation once a connection tracking entry exists.
 	 */
@@ -186,8 +188,7 @@ synproxy_send_server_ack(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED,
-			  niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
 }
 
 static void
@@ -219,14 +220,36 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	nth->ack_seq	= th->ack_seq;
 	tcp_flag_word(nth) = TCP_FLAG_ACK;
 	nth->doff	= tcp_hdr_size / 4;
-	nth->window	= th->window;
+	nth->window	= ntohs(htons(th->window) >> opts->wscale);
 	nth->check	= 0;
 	nth->urg_ptr	= 0;
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
-			  niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
+}
+
+static bool
+synproxy_recv_client_ack(const struct synproxy_net *snet,
+			 const struct sk_buff *skb, const struct tcphdr *th,
+			 struct synproxy_options *opts, u32 recv_seq)
+{
+	int mss;
+
+	mss = __cookie_v4_check(ip_hdr(skb), th, ntohl(th->ack_seq) - 1);
+	if (mss == 0) {
+		this_cpu_inc(snet->stats->cookie_invalid);
+		return false;
+	}
+
+	this_cpu_inc(snet->stats->cookie_valid);
+	opts->mss = mss;
+
+	if (opts->options & XT_SYNPROXY_OPT_TIMESTAMP)
+		synproxy_check_timestamp_cookie(opts);
+
+	synproxy_send_server_syn(snet, skb, th, opts, recv_seq);
+	return true;
 }
 
 static unsigned int
@@ -262,23 +285,9 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_ECN);
 
 		synproxy_send_client_synack(skb, th, &opts);
-	} else if (th->ack && !(th->fin || th->rst)) {
+	} else if (th->ack && !(th->fin || th->rst))
 		/* ACK from client */
-		int mss = __cookie_v4_check(ip_hdr(skb), th,
-					    ntohl(th->ack_seq) - 1);
-		if (mss == 0) {
-			this_cpu_inc(snet->stats->cookie_invalid);
-			return NF_DROP;
-		}
-
-		this_cpu_inc(snet->stats->cookie_valid);
-		opts.mss = mss;
-
-		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
-			synproxy_check_timestamp_cookie(&opts);
-
-		synproxy_send_server_syn(snet, skb, th, &opts);
-	}
+		synproxy_recv_client_ack(snet, skb, th, &opts, ntohl(th->seq));
 
 	return NF_DROP;
 }
@@ -319,17 +328,30 @@ static unsigned int ipv4_synproxy_hook(unsigned int hooknum,
 	case TCP_CONNTRACK_SYN_SENT:
 		synproxy_parse_options(skb, thoff, th, &opts);
 
+		if (!th->syn && th->ack &&
+		    CTINFO2DIR(ctinfo) == IP_CT_DIR_ORIGINAL) {
+			/* Keep-Alives are sent with SEG.SEQ = SND.NXT-1,
+			 * therefore we need to add 1 to make the SYN sequence
+			 * number match the one of first SYN.
+			 */
+			if (synproxy_recv_client_ack(snet, skb, th, &opts,
+						     ntohl(th->seq) + 1))
+				this_cpu_inc(snet->stats->cookie_retrans);
+
+			return NF_DROP;
+		}
+
 		synproxy->isn = ntohl(th->ack_seq);
 		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
-			synproxy->tsoff = -opts.tsecr;
+			synproxy->its = opts.tsecr;
 		break;
 	case TCP_CONNTRACK_SYN_RECV:
-		if (!th->syn)
+		if (!th->syn || !th->ack)
 			break;
 
 		synproxy_parse_options(skb, thoff, th, &opts);
 		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
-			synproxy->tsoff += opts.tsval;
+			synproxy->tsoff = opts.tsval - synproxy->its;
 
 		opts.options &= ~(XT_SYNPROXY_OPT_MSS |
 				  XT_SYNPROXY_OPT_WSCALE |
@@ -346,11 +368,9 @@ static unsigned int ipv4_synproxy_hook(unsigned int hooknum,
 		consume_skb(skb);
 		return NF_STOLEN;
 	case TCP_CONNTRACK_CLOSE:
-		if (!th->rst)
-			break;
-
-		nf_ct_seqadj_init(ct, ctinfo, synproxy->isn -
-					      ntohl(th->seq) + 1);
+		if (th->rst && !test_bit(IPS_SEEN_REPLY_BIT, &ct->status))
+			nf_ct_seqadj_init(ct, ctinfo, synproxy->isn -
+						      ntohl(th->seq) + 1);
 		break;
 	default:
 		break;
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 644e6ed..b388964 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -69,9 +69,11 @@ synproxy_send_tcp(const struct sk_buff *skb, struct sk_buff *nskb,
 
 	skb_dst_set(nskb, dst);
 
-	nskb->nfct = nfct;
-	nskb->nfctinfo = ctinfo;
-	nf_conntrack_get(nfct);
+	if (nfct) {
+		nskb->nfct = nfct;
+		nskb->nfctinfo = ctinfo;
+		nf_conntrack_get(nfct);
+	}
 
 	ip6_local_out(nskb);
 	return;
@@ -124,7 +126,7 @@ synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
 static void
 synproxy_send_server_syn(const struct synproxy_net *snet,
 			 const struct sk_buff *skb, const struct tcphdr *th,
-			 const struct synproxy_options *opts)
+			 const struct synproxy_options *opts, u32 recv_seq)
 {
 	struct sk_buff *nskb;
 	struct ipv6hdr *iph, *niph;
@@ -146,7 +148,7 @@ synproxy_send_server_syn(const struct synproxy_net *snet,
 	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
 	nth->source	= th->source;
 	nth->dest	= th->dest;
-	nth->seq	= htonl(ntohl(th->seq) - 1);
+	nth->seq	= htonl(recv_seq - 1);
 	/* ack_seq is used to relay our ISN to the synproxy hook to initialize
 	 * sequence number translation once a connection tracking entry exists.
 	 */
@@ -201,8 +203,7 @@ synproxy_send_server_ack(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED,
-			  niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
 }
 
 static void
@@ -234,14 +235,36 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	nth->ack_seq	= th->ack_seq;
 	tcp_flag_word(nth) = TCP_FLAG_ACK;
 	nth->doff	= tcp_hdr_size / 4;
-	nth->window	= th->window;
+	nth->window	= ntohs(htons(th->window) >> opts->wscale);
 	nth->check	= 0;
 	nth->urg_ptr	= 0;
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
-			  niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
+}
+
+static bool
+synproxy_recv_client_ack(const struct synproxy_net *snet,
+			 const struct sk_buff *skb, const struct tcphdr *th,
+			 struct synproxy_options *opts, u32 recv_seq)
+{
+	int mss;
+
+	mss = __cookie_v6_check(ipv6_hdr(skb), th, ntohl(th->ack_seq) - 1);
+	if (mss == 0) {
+		this_cpu_inc(snet->stats->cookie_invalid);
+		return false;
+	}
+
+	this_cpu_inc(snet->stats->cookie_valid);
+	opts->mss = mss;
+
+	if (opts->options & XT_SYNPROXY_OPT_TIMESTAMP)
+		synproxy_check_timestamp_cookie(opts);
+
+	synproxy_send_server_syn(snet, skb, th, opts, recv_seq);
+	return true;
 }
 
 static unsigned int
@@ -277,23 +300,9 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_ECN);
 
 		synproxy_send_client_synack(skb, th, &opts);
-	} else if (th->ack && !(th->fin || th->rst)) {
+	} else if (th->ack && !(th->fin || th->rst))
 		/* ACK from client */
-		int mss = __cookie_v6_check(ipv6_hdr(skb), th,
-					    ntohl(th->ack_seq) - 1);
-		if (mss == 0) {
-			this_cpu_inc(snet->stats->cookie_invalid);
-			return NF_DROP;
-		}
-
-		this_cpu_inc(snet->stats->cookie_valid);
-		opts.mss = mss;
-
-		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
-			synproxy_check_timestamp_cookie(&opts);
-
-		synproxy_send_server_syn(snet, skb, th, &opts);
-	}
+		synproxy_recv_client_ack(snet, skb, th, &opts, ntohl(th->seq));
 
 	return NF_DROP;
 }
@@ -341,17 +350,30 @@ static unsigned int ipv6_synproxy_hook(unsigned int hooknum,
 	case TCP_CONNTRACK_SYN_SENT:
 		synproxy_parse_options(skb, thoff, th, &opts);
 
+		if (!th->syn && th->ack &&
+		    CTINFO2DIR(ctinfo) == IP_CT_DIR_ORIGINAL) {
+			/* Keep-Alives are sent with SEG.SEQ = SND.NXT-1,
+			 * therefore we need to add 1 to make the SYN sequence
+			 * number match the one of first SYN.
+			 */
+			if (synproxy_recv_client_ack(snet, skb, th, &opts,
+						     ntohl(th->seq) + 1))
+				this_cpu_inc(snet->stats->cookie_retrans);
+
+			return NF_DROP;
+		}
+
 		synproxy->isn = ntohl(th->ack_seq);
 		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
-			synproxy->tsoff = -opts.tsecr;
+			synproxy->its = opts.tsecr;
 		break;
 	case TCP_CONNTRACK_SYN_RECV:
-		if (!th->syn)
+		if (!th->syn || !th->ack)
 			break;
 
 		synproxy_parse_options(skb, thoff, th, &opts);
 		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
-			synproxy->tsoff += opts.tsval;
+			synproxy->tsoff = opts.tsval - synproxy->its;
 
 		opts.options &= ~(XT_SYNPROXY_OPT_MSS |
 				  XT_SYNPROXY_OPT_WSCALE |
@@ -368,11 +390,9 @@ static unsigned int ipv6_synproxy_hook(unsigned int hooknum,
 		consume_skb(skb);
 		return NF_STOLEN;
 	case TCP_CONNTRACK_CLOSE:
-		if (!th->rst)
-			break;
-
-		nf_ct_seqadj_init(ct, ctinfo, synproxy->isn -
-					      ntohl(th->seq) + 1);
+		if (th->rst && !test_bit(IPS_SEEN_REPLY_BIT, &ct->status))
+			nf_ct_seqadj_init(ct, ctinfo, synproxy->isn -
+						      ntohl(th->seq) + 1);
 		break;
 	default:
 		break;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 3c3401e..5d714db 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -28,6 +28,7 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_conntrack_seqadj.h>
+#include <net/netfilter/nf_conntrack_synproxy.h>
 #include <net/netfilter/nf_log.h>
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
@@ -942,6 +943,21 @@ static int tcp_packet(struct nf_conn *ct,
 				  "state %s ", tcp_conntrack_names[old_state]);
 		return NF_ACCEPT;
 	case TCP_CONNTRACK_MAX:
+		/* Special case for SYN proxy: when the SYN to the server or
+		 * the SYN/ACK from the server is lost, the client may transmit
+		 * a keep-alive packet while in SYN_SENT state. This needs to
+		 * be associated with the original conntrack entry in order to
+		 * generate a new SYN with the correct sequence number.
+		 */
+		if (nfct_synproxy(ct) && old_state == TCP_CONNTRACK_SYN_SENT &&
+		    index == TCP_ACK_SET && dir == IP_CT_DIR_ORIGINAL &&
+		    ct->proto.tcp.last_dir == IP_CT_DIR_ORIGINAL &&
+		    ct->proto.tcp.seen[dir].td_end - 1 == ntohl(th->seq)) {
+			pr_debug("nf_ct_tcp: SYN proxy client keep alive\n");
+			spin_unlock_bh(&ct->lock);
+			return NF_ACCEPT;
+		}
+
 		/* Invalid packet */
 		pr_debug("nf_ct_tcp: Invalid dir=%i index=%u ostate=%u\n",
 			 dir, get_conntrack_index(th), old_state);
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index 502faae..c067845 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -281,15 +281,17 @@ static int synproxy_cpu_seq_show(struct seq_file *seq, void *v)
 	struct synproxy_stats *stats = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries\tsyn_received\t"
-				"cookie_invalid\tcookie_valid\n");
+		seq_printf(seq, "entries\t\tsyn_received\t"
+				"cookie_invalid\tcookie_valid\t"
+				"cookie_retrans\n");
 		return 0;
 	}
 
-	seq_printf(seq, "%08x\t%08x\t%08x\t%08x\n", 0,
+	seq_printf(seq, "%08x\t%08x\t%08x\t%08x\t%08x\n", 0,
 		   stats->syn_received,
 		   stats->cookie_invalid,
-		   stats->cookie_valid);
+		   stats->cookie_valid,
+		   stats->cookie_retrans);
 
 	return 0;
 }
-- 
1.8.1.4

