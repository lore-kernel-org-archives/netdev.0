From: pablo@netfilter.org
Subject: [PATCH 4/7] netfilter: nf_conntrack: pass timeout array to l4->new and l4->packet
Date: Sun,  4 Mar 2012 12:27:55 +0100
Message-ID: <1330860478-13184-5-git-send-email-pablo@netfilter.org>
References: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch defines a new interface for l4 protocol trackers:

unsigned int *(*get_timeouts)(struct net *net);

that is used to return the array of unsigned int that contains
the timeouts that will be applied for this flow. This is passed
to the l4proto->new(...) and l4proto->packet(...) functions to
specify the timeout policy.

This interface allows per-net global timeout configuration
(although only DCCP supports this by now) and it will allow
custom custom timeout configuration by means of follow-up
patches.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h   |    8 +++++-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   13 ++++++++--
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   13 ++++++++--
 net/netfilter/nf_conntrack_core.c              |   18 ++++++++++-----
 net/netfilter/nf_conntrack_proto_dccp.c        |   16 +++++++++----
 net/netfilter/nf_conntrack_proto_generic.c     |   29 ++++++++++++++---------
 net/netfilter/nf_conntrack_proto_gre.c         |   15 +++++++++---
 net/netfilter/nf_conntrack_proto_sctp.c        |   14 +++++++++--
 net/netfilter/nf_conntrack_proto_tcp.c         |   22 ++++++++++++-----
 net/netfilter/nf_conntrack_proto_udp.c         |   16 ++++++++++---
 net/netfilter/nf_conntrack_proto_udplite.c     |   16 ++++++++++---
 11 files changed, 128 insertions(+), 52 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index e3d3ee3..c48b674 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -39,12 +39,13 @@ struct nf_conntrack_l4proto {
 		      unsigned int dataoff,
 		      enum ip_conntrack_info ctinfo,
 		      u_int8_t pf,
-		      unsigned int hooknum);
+		      unsigned int hooknum,
+		      unsigned int *timeouts);
 
 	/* Called when a new connection for this protocol found;
 	 * returns TRUE if it's OK.  If so, packet() called next. */
 	bool (*new)(struct nf_conn *ct, const struct sk_buff *skb,
-		    unsigned int dataoff);
+		    unsigned int dataoff, unsigned int *timeouts);
 
 	/* Called when a conntrack entry is destroyed */
 	void (*destroy)(struct nf_conn *ct);
@@ -60,6 +61,9 @@ struct nf_conntrack_l4proto {
 	/* Print out the private part of the conntrack. */
 	int (*print_conntrack)(struct seq_file *s, struct nf_conn *);
 
+	/* Return the array of timeouts for this protocol. */
+	unsigned int *(*get_timeouts)(struct net *net);
+
 	/* convert protoinfo to nfnetink attributes */
 	int (*to_nlattr)(struct sk_buff *skb, struct nlattr *nla,
 			 struct nf_conn *ct);
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index ab5b27a..6b80112 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -75,25 +75,31 @@ static int icmp_print_tuple(struct seq_file *s,
 			  ntohs(tuple->src.u.icmp.id));
 }
 
+static unsigned int *icmp_get_timeouts(struct net *net)
+{
+	return &nf_ct_icmp_timeout;
+}
+
 /* Returns verdict for packet, or -1 for invalid. */
 static int icmp_packet(struct nf_conn *ct,
 		       const struct sk_buff *skb,
 		       unsigned int dataoff,
 		       enum ip_conntrack_info ctinfo,
 		       u_int8_t pf,
-		       unsigned int hooknum)
+		       unsigned int hooknum,
+		       unsigned int *timeout)
 {
 	/* Do not immediately delete the connection after the first
 	   successful reply to avoid excessive conntrackd traffic
 	   and also to handle correctly ICMP echo reply duplicates. */
-	nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmp_timeout);
+	nf_ct_refresh_acct(ct, ctinfo, skb, *timeout);
 
 	return NF_ACCEPT;
 }
 
 /* Called when a new connection for this protocol found. */
 static bool icmp_new(struct nf_conn *ct, const struct sk_buff *skb,
-		     unsigned int dataoff)
+		     unsigned int dataoff, unsigned int *timeouts)
 {
 	static const u_int8_t valid_new[] = {
 		[ICMP_ECHO] = 1,
@@ -298,6 +304,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 	.invert_tuple		= icmp_invert_tuple,
 	.print_tuple		= icmp_print_tuple,
 	.packet			= icmp_packet,
+	.get_timeouts		= icmp_get_timeouts,
 	.new			= icmp_new,
 	.error			= icmp_error,
 	.destroy		= NULL,
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 7c05e7e..2eb9751 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -88,25 +88,31 @@ static int icmpv6_print_tuple(struct seq_file *s,
 			  ntohs(tuple->src.u.icmp.id));
 }
 
+static unsigned int *icmpv6_get_timeouts(struct net *net)
+{
+	return &nf_ct_icmpv6_timeout;
+}
+
 /* Returns verdict for packet, or -1 for invalid. */
 static int icmpv6_packet(struct nf_conn *ct,
 		       const struct sk_buff *skb,
 		       unsigned int dataoff,
 		       enum ip_conntrack_info ctinfo,
 		       u_int8_t pf,
-		       unsigned int hooknum)
+		       unsigned int hooknum,
+		       unsigned int *timeout)
 {
 	/* Do not immediately delete the connection after the first
 	   successful reply to avoid excessive conntrackd traffic
 	   and also to handle correctly ICMP echo reply duplicates. */
-	nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmpv6_timeout);
+	nf_ct_refresh_acct(ct, ctinfo, skb, *timeout);
 
 	return NF_ACCEPT;
 }
 
 /* Called when a new connection for this protocol found. */
 static bool icmpv6_new(struct nf_conn *ct, const struct sk_buff *skb,
-		       unsigned int dataoff)
+		       unsigned int dataoff, unsigned int *timeouts)
 {
 	static const u_int8_t valid_new[] = {
 		[ICMPV6_ECHO_REQUEST - 128] = 1,
@@ -293,6 +299,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 	.invert_tuple		= icmpv6_invert_tuple,
 	.print_tuple		= icmpv6_print_tuple,
 	.packet			= icmpv6_packet,
+	.get_timeouts		= icmpv6_get_timeouts,
 	.new			= icmpv6_new,
 	.error			= icmpv6_error,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 76613f5..7bf9532 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -733,7 +733,8 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	       struct nf_conntrack_l3proto *l3proto,
 	       struct nf_conntrack_l4proto *l4proto,
 	       struct sk_buff *skb,
-	       unsigned int dataoff, u32 hash)
+	       unsigned int dataoff, u32 hash,
+	       unsigned int *timeouts)
 {
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
@@ -752,7 +753,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	if (IS_ERR(ct))
 		return (struct nf_conntrack_tuple_hash *)ct;
 
-	if (!l4proto->new(ct, skb, dataoff)) {
+	if (!l4proto->new(ct, skb, dataoff, timeouts)) {
 		nf_conntrack_free(ct);
 		pr_debug("init conntrack: can't track with proto module\n");
 		return NULL;
@@ -818,7 +819,8 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		  struct nf_conntrack_l3proto *l3proto,
 		  struct nf_conntrack_l4proto *l4proto,
 		  int *set_reply,
-		  enum ip_conntrack_info *ctinfo)
+		  enum ip_conntrack_info *ctinfo,
+		  unsigned int *timeouts)
 {
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_tuple_hash *h;
@@ -838,7 +840,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	h = __nf_conntrack_find_get(net, zone, &tuple, hash);
 	if (!h) {
 		h = init_conntrack(net, tmpl, &tuple, l3proto, l4proto,
-				   skb, dataoff, hash);
+				   skb, dataoff, hash, timeouts);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
@@ -879,6 +881,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
+	unsigned int *timeouts;
 	unsigned int dataoff;
 	u_int8_t protonum;
 	int set_reply = 0;
@@ -925,8 +928,11 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			goto out;
 	}
 
+	timeouts = l4proto->get_timeouts(net);
+
 	ct = resolve_normal_ct(net, tmpl, skb, dataoff, pf, protonum,
-			       l3proto, l4proto, &set_reply, &ctinfo);
+			       l3proto, l4proto, &set_reply, &ctinfo,
+			       timeouts);
 	if (!ct) {
 		/* Not valid part of a connection */
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
@@ -943,7 +949,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 
 	NF_CT_ASSERT(skb->nfct);
 
-	ret = l4proto->packet(ct, skb, dataoff, ctinfo, pf, hooknum);
+	ret = l4proto->packet(ct, skb, dataoff, ctinfo, pf, hooknum, timeouts);
 	if (ret <= 0) {
 		/* Invalid: inverse of the return code tells
 		 * the netfilter core what to do */
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index d6dde6d..8ea3359 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -423,7 +423,7 @@ static bool dccp_invert_tuple(struct nf_conntrack_tuple *inv,
 }
 
 static bool dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
-		     unsigned int dataoff)
+		     unsigned int dataoff, unsigned int *timeouts)
 {
 	struct net *net = nf_ct_net(ct);
 	struct dccp_net *dn;
@@ -472,12 +472,17 @@ static u64 dccp_ack_seq(const struct dccp_hdr *dh)
 		     ntohl(dhack->dccph_ack_nr_low);
 }
 
+static unsigned int *dccp_get_timeouts(struct net *net)
+{
+	return dccp_pernet(net)->dccp_timeout;
+}
+
 static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 		       unsigned int dataoff, enum ip_conntrack_info ctinfo,
-		       u_int8_t pf, unsigned int hooknum)
+		       u_int8_t pf, unsigned int hooknum,
+		       unsigned int *timeouts)
 {
 	struct net *net = nf_ct_net(ct);
-	struct dccp_net *dn;
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	struct dccp_hdr _dh, *dh;
 	u_int8_t type, old_state, new_state;
@@ -559,8 +564,7 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 	if (new_state != old_state)
 		nf_conntrack_event_cache(IPCT_PROTOINFO, ct);
 
-	dn = dccp_pernet(net);
-	nf_ct_refresh_acct(ct, ctinfo, skb, dn->dccp_timeout[new_state]);
+	nf_ct_refresh_acct(ct, ctinfo, skb, timeouts[new_state]);
 
 	return NF_ACCEPT;
 }
@@ -767,6 +771,7 @@ static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
 	.invert_tuple		= dccp_invert_tuple,
 	.new			= dccp_new,
 	.packet			= dccp_packet,
+	.get_timeouts		= dccp_get_timeouts,
 	.error			= dccp_error,
 	.print_tuple		= dccp_print_tuple,
 	.print_conntrack	= dccp_print_conntrack,
@@ -789,6 +794,7 @@ static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
 	.invert_tuple		= dccp_invert_tuple,
 	.new			= dccp_new,
 	.packet			= dccp_packet,
+	.get_timeouts		= dccp_get_timeouts,
 	.error			= dccp_error,
 	.print_tuple		= dccp_print_tuple,
 	.print_conntrack	= dccp_print_conntrack,
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index e2091d0..0e6c545 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -40,21 +40,27 @@ static int generic_print_tuple(struct seq_file *s,
 	return 0;
 }
 
+static unsigned int *generic_get_timeouts(struct net *net)
+{
+	return &nf_ct_generic_timeout;
+}
+
 /* Returns verdict for packet, or -1 for invalid. */
-static int packet(struct nf_conn *ct,
-		  const struct sk_buff *skb,
-		  unsigned int dataoff,
-		  enum ip_conntrack_info ctinfo,
-		  u_int8_t pf,
-		  unsigned int hooknum)
+static int generic_packet(struct nf_conn *ct,
+			  const struct sk_buff *skb,
+			  unsigned int dataoff,
+			  enum ip_conntrack_info ctinfo,
+			  u_int8_t pf,
+			  unsigned int hooknum,
+			  unsigned int *timeout)
 {
-	nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_generic_timeout);
+	nf_ct_refresh_acct(ct, ctinfo, skb, *timeout);
 	return NF_ACCEPT;
 }
 
 /* Called when a new connection for this protocol found. */
-static bool new(struct nf_conn *ct, const struct sk_buff *skb,
-		unsigned int dataoff)
+static bool generic_new(struct nf_conn *ct, const struct sk_buff *skb,
+			unsigned int dataoff, unsigned int *timeouts)
 {
 	return true;
 }
@@ -93,8 +99,9 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 	.pkt_to_tuple		= generic_pkt_to_tuple,
 	.invert_tuple		= generic_invert_tuple,
 	.print_tuple		= generic_print_tuple,
-	.packet			= packet,
-	.new			= new,
+	.packet			= generic_packet,
+	.get_timeouts		= generic_get_timeouts,
+	.new			= generic_new,
 #ifdef CONFIG_SYSCTL
 	.ctl_table_header	= &generic_sysctl_header,
 	.ctl_table		= generic_sysctl_table,
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 8144f22..1bf01c9 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -235,13 +235,19 @@ static int gre_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 			  (ct->proto.gre.stream_timeout / HZ));
 }
 
+static unsigned int *gre_get_timeouts(struct net *net)
+{
+	return gre_timeouts;
+}
+
 /* Returns verdict for packet, and may modify conntrack */
 static int gre_packet(struct nf_conn *ct,
 		      const struct sk_buff *skb,
 		      unsigned int dataoff,
 		      enum ip_conntrack_info ctinfo,
 		      u_int8_t pf,
-		      unsigned int hooknum)
+		      unsigned int hooknum,
+		      unsigned int *timeouts)
 {
 	/* If we've seen traffic both ways, this is a GRE connection.
 	 * Extend timeout. */
@@ -260,15 +266,15 @@ static int gre_packet(struct nf_conn *ct,
 
 /* Called when a new connection for this protocol found. */
 static bool gre_new(struct nf_conn *ct, const struct sk_buff *skb,
-		    unsigned int dataoff)
+		    unsigned int dataoff, unsigned int *timeouts)
 {
 	pr_debug(": ");
 	nf_ct_dump_tuple(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
 
 	/* initialize to sane value.  Ideally a conntrack helper
 	 * (e.g. in case of pptp) is increasing them */
-	ct->proto.gre.stream_timeout = gre_timeouts[GRE_CT_REPLIED];
-	ct->proto.gre.timeout = gre_timeouts[GRE_CT_UNREPLIED];
+	ct->proto.gre.stream_timeout = timeouts[GRE_CT_REPLIED];
+	ct->proto.gre.timeout = timeouts[GRE_CT_UNREPLIED];
 
 	return true;
 }
@@ -295,6 +301,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 	.invert_tuple	 = gre_invert_tuple,
 	.print_tuple	 = gre_print_tuple,
 	.print_conntrack = gre_print_conntrack,
+	.get_timeouts    = gre_get_timeouts,
 	.packet		 = gre_packet,
 	.new		 = gre_new,
 	.destroy	 = gre_destroy,
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index afa6913..2a07033 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -279,13 +279,19 @@ static int sctp_new_state(enum ip_conntrack_dir dir,
 	return sctp_conntracks[dir][i][cur_state];
 }
 
+static unsigned int *sctp_get_timeouts(struct net *net)
+{
+	return sctp_timeouts;
+}
+
 /* Returns verdict for packet, or -NF_ACCEPT for invalid. */
 static int sctp_packet(struct nf_conn *ct,
 		       const struct sk_buff *skb,
 		       unsigned int dataoff,
 		       enum ip_conntrack_info ctinfo,
 		       u_int8_t pf,
-		       unsigned int hooknum)
+		       unsigned int hooknum,
+		       unsigned int *timeouts)
 {
 	enum sctp_conntrack new_state, old_state;
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
@@ -370,7 +376,7 @@ static int sctp_packet(struct nf_conn *ct,
 	}
 	spin_unlock_bh(&ct->lock);
 
-	nf_ct_refresh_acct(ct, ctinfo, skb, sctp_timeouts[new_state]);
+	nf_ct_refresh_acct(ct, ctinfo, skb, timeouts[new_state]);
 
 	if (old_state == SCTP_CONNTRACK_COOKIE_ECHOED &&
 	    dir == IP_CT_DIR_REPLY &&
@@ -390,7 +396,7 @@ out:
 
 /* Called when a new connection for this protocol found. */
 static bool sctp_new(struct nf_conn *ct, const struct sk_buff *skb,
-		     unsigned int dataoff)
+		     unsigned int dataoff, unsigned int *timeouts)
 {
 	enum sctp_conntrack new_state;
 	const struct sctphdr *sh;
@@ -664,6 +670,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.print_tuple 		= sctp_print_tuple,
 	.print_conntrack	= sctp_print_conntrack,
 	.packet 		= sctp_packet,
+	.get_timeouts		= sctp_get_timeouts,
 	.new 			= sctp_new,
 	.me 			= THIS_MODULE,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
@@ -694,6 +701,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.print_tuple 		= sctp_print_tuple,
 	.print_conntrack	= sctp_print_conntrack,
 	.packet 		= sctp_packet,
+	.get_timeouts		= sctp_get_timeouts,
 	.new 			= sctp_new,
 	.me 			= THIS_MODULE,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 57c7785..8372bb4 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -813,13 +813,19 @@ static int tcp_error(struct net *net, struct nf_conn *tmpl,
 	return NF_ACCEPT;
 }
 
+static unsigned int *tcp_get_timeouts(struct net *net)
+{
+	return tcp_timeouts;
+}
+
 /* Returns verdict for packet, or -1 for invalid. */
 static int tcp_packet(struct nf_conn *ct,
 		      const struct sk_buff *skb,
 		      unsigned int dataoff,
 		      enum ip_conntrack_info ctinfo,
 		      u_int8_t pf,
-		      unsigned int hooknum)
+		      unsigned int hooknum,
+		      unsigned int *timeouts)
 {
 	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_tuple *tuple;
@@ -1014,14 +1020,14 @@ static int tcp_packet(struct nf_conn *ct,
 		ct->proto.tcp.seen[dir].flags |= IP_CT_TCP_FLAG_CLOSE_INIT;
 
 	if (ct->proto.tcp.retrans >= nf_ct_tcp_max_retrans &&
-	    tcp_timeouts[new_state] > tcp_timeouts[TCP_CONNTRACK_RETRANS])
-		timeout = tcp_timeouts[TCP_CONNTRACK_RETRANS];
+	    timeouts[new_state] > timeouts[TCP_CONNTRACK_RETRANS])
+		timeout = timeouts[TCP_CONNTRACK_RETRANS];
 	else if ((ct->proto.tcp.seen[0].flags | ct->proto.tcp.seen[1].flags) &
 		 IP_CT_TCP_FLAG_DATA_UNACKNOWLEDGED &&
-		 tcp_timeouts[new_state] > tcp_timeouts[TCP_CONNTRACK_UNACK])
-		timeout = tcp_timeouts[TCP_CONNTRACK_UNACK];
+		 timeouts[new_state] > timeouts[TCP_CONNTRACK_UNACK])
+		timeout = timeouts[TCP_CONNTRACK_UNACK];
 	else
-		timeout = tcp_timeouts[new_state];
+		timeout = timeouts[new_state];
 	spin_unlock_bh(&ct->lock);
 
 	if (new_state != old_state)
@@ -1053,7 +1059,7 @@ static int tcp_packet(struct nf_conn *ct,
 
 /* Called when a new connection for this protocol found. */
 static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
-		    unsigned int dataoff)
+		    unsigned int dataoff, unsigned int *timeouts)
 {
 	enum tcp_conntrack new_state;
 	const struct tcphdr *th;
@@ -1444,6 +1450,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 	.print_tuple 		= tcp_print_tuple,
 	.print_conntrack 	= tcp_print_conntrack,
 	.packet 		= tcp_packet,
+	.get_timeouts		= tcp_get_timeouts,
 	.new 			= tcp_new,
 	.error			= tcp_error,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
@@ -1476,6 +1483,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 	.print_tuple 		= tcp_print_tuple,
 	.print_conntrack 	= tcp_print_conntrack,
 	.packet 		= tcp_packet,
+	.get_timeouts		= tcp_get_timeouts,
 	.new 			= tcp_new,
 	.error			= tcp_error,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 5b24ff8..70e0059 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -71,32 +71,38 @@ static int udp_print_tuple(struct seq_file *s,
 			  ntohs(tuple->dst.u.udp.port));
 }
 
+static unsigned int *udp_get_timeouts(struct net *net)
+{
+	return udp_timeouts;
+}
+
 /* Returns verdict for packet, and may modify conntracktype */
 static int udp_packet(struct nf_conn *ct,
 		      const struct sk_buff *skb,
 		      unsigned int dataoff,
 		      enum ip_conntrack_info ctinfo,
 		      u_int8_t pf,
-		      unsigned int hooknum)
+		      unsigned int hooknum,
+		      unsigned int *timeouts)
 {
 	/* If we've seen traffic both ways, this is some kind of UDP
 	   stream.  Extend timeout. */
 	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
 		nf_ct_refresh_acct(ct, ctinfo, skb,
-				   udp_timeouts[UDP_CT_REPLIED]);
+				   timeouts[UDP_CT_REPLIED]);
 		/* Also, more likely to be important, and not a probe */
 		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
 			nf_conntrack_event_cache(IPCT_ASSURED, ct);
 	} else {
 		nf_ct_refresh_acct(ct, ctinfo, skb,
-				   udp_timeouts[UDP_CT_UNREPLIED]);
+				   timeouts[UDP_CT_UNREPLIED]);
 	}
 	return NF_ACCEPT;
 }
 
 /* Called when a new connection for this protocol found. */
 static bool udp_new(struct nf_conn *ct, const struct sk_buff *skb,
-		    unsigned int dataoff)
+		    unsigned int dataoff, unsigned int *timeouts)
 {
 	return true;
 }
@@ -196,6 +202,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 	.invert_tuple		= udp_invert_tuple,
 	.print_tuple		= udp_print_tuple,
 	.packet			= udp_packet,
+	.get_timeouts		= udp_get_timeouts,
 	.new			= udp_new,
 	.error			= udp_error,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
@@ -224,6 +231,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 	.invert_tuple		= udp_invert_tuple,
 	.print_tuple		= udp_print_tuple,
 	.packet			= udp_packet,
+	.get_timeouts		= udp_get_timeouts,
 	.new			= udp_new,
 	.error			= udp_error,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index e730717..0b32ccb 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -68,32 +68,38 @@ static int udplite_print_tuple(struct seq_file *s,
 			  ntohs(tuple->dst.u.udp.port));
 }
 
+static unsigned int *udplite_get_timeouts(struct net *net)
+{
+	return udplite_timeouts;
+}
+
 /* Returns verdict for packet, and may modify conntracktype */
 static int udplite_packet(struct nf_conn *ct,
 			  const struct sk_buff *skb,
 			  unsigned int dataoff,
 			  enum ip_conntrack_info ctinfo,
 			  u_int8_t pf,
-			  unsigned int hooknum)
+			  unsigned int hooknum,
+			  unsigned int *timeouts)
 {
 	/* If we've seen traffic both ways, this is some kind of UDP
 	   stream.  Extend timeout. */
 	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
 		nf_ct_refresh_acct(ct, ctinfo, skb,
-				   udplite_timeouts[UDPLITE_CT_REPLIED]);
+				   timeouts[UDPLITE_CT_REPLIED]);
 		/* Also, more likely to be important, and not a probe */
 		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
 			nf_conntrack_event_cache(IPCT_ASSURED, ct);
 	} else {
 		nf_ct_refresh_acct(ct, ctinfo, skb,
-				   udplite_timeouts[UDPLITE_CT_UNREPLIED]);
+				   timeouts[UDPLITE_CT_UNREPLIED]);
 	}
 	return NF_ACCEPT;
 }
 
 /* Called when a new connection for this protocol found. */
 static bool udplite_new(struct nf_conn *ct, const struct sk_buff *skb,
-			unsigned int dataoff)
+			unsigned int dataoff, unsigned int *timeouts)
 {
 	return true;
 }
@@ -181,6 +187,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 	.invert_tuple		= udplite_invert_tuple,
 	.print_tuple		= udplite_print_tuple,
 	.packet			= udplite_packet,
+	.get_timeouts		= udplite_get_timeouts,
 	.new			= udplite_new,
 	.error			= udplite_error,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
@@ -205,6 +212,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 	.invert_tuple		= udplite_invert_tuple,
 	.print_tuple		= udplite_print_tuple,
 	.packet			= udplite_packet,
+	.get_timeouts		= udplite_get_timeouts,
 	.new			= udplite_new,
 	.error			= udplite_error,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
-- 
1.7.7.3

