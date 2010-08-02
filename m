From: kaber@trash.net
Subject: [PATCH 26/28] netfilter: nf_nat: make unique_tuple return void
Date: Mon,  2 Aug 2010 21:57:43 +0200
Message-ID: <1280779065-9333-27-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

The only user of unique_tuple() get_unique_tuple() doesn't care about the
return value of unique_tuple(), so make unique_tuple() return void (nothing).

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_nat_protocol.h   |    8 ++++----
 net/ipv4/netfilter/nf_nat_proto_common.c  |    8 ++++----
 net/ipv4/netfilter/nf_nat_proto_dccp.c    |    6 +++---
 net/ipv4/netfilter/nf_nat_proto_gre.c     |    8 ++++----
 net/ipv4/netfilter/nf_nat_proto_icmp.c    |    6 +++---
 net/ipv4/netfilter/nf_nat_proto_sctp.c    |    6 +++---
 net/ipv4/netfilter/nf_nat_proto_tcp.c     |    5 ++---
 net/ipv4/netfilter/nf_nat_proto_udp.c     |    5 ++---
 net/ipv4/netfilter/nf_nat_proto_udplite.c |    6 +++---
 net/ipv4/netfilter/nf_nat_proto_unknown.c |    4 ++--
 10 files changed, 30 insertions(+), 32 deletions(-)

diff --git a/include/net/netfilter/nf_nat_protocol.h b/include/net/netfilter/nf_nat_protocol.h
index c398017..df17bac 100644
--- a/include/net/netfilter/nf_nat_protocol.h
+++ b/include/net/netfilter/nf_nat_protocol.h
@@ -27,9 +27,9 @@ struct nf_nat_protocol {
 
 	/* Alter the per-proto part of the tuple (depending on
 	   maniptype), to give a unique tuple in the given range if
-	   possible; return false if not.  Per-protocol part of tuple
-	   is initialized to the incoming packet. */
-	bool (*unique_tuple)(struct nf_conntrack_tuple *tuple,
+	   possible.  Per-protocol part of tuple is initialized to the
+	   incoming packet. */
+	void (*unique_tuple)(struct nf_conntrack_tuple *tuple,
 			     const struct nf_nat_range *range,
 			     enum nf_nat_manip_type maniptype,
 			     const struct nf_conn *ct);
@@ -63,7 +63,7 @@ extern bool nf_nat_proto_in_range(const struct nf_conntrack_tuple *tuple,
 				  const union nf_conntrack_man_proto *min,
 				  const union nf_conntrack_man_proto *max);
 
-extern bool nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
+extern void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 				      const struct nf_nat_range *range,
 				      enum nf_nat_manip_type maniptype,
 				      const struct nf_conn *ct,
diff --git a/net/ipv4/netfilter/nf_nat_proto_common.c b/net/ipv4/netfilter/nf_nat_proto_common.c
index 6c4f11f..2844a03 100644
--- a/net/ipv4/netfilter/nf_nat_proto_common.c
+++ b/net/ipv4/netfilter/nf_nat_proto_common.c
@@ -34,7 +34,7 @@ bool nf_nat_proto_in_range(const struct nf_conntrack_tuple *tuple,
 }
 EXPORT_SYMBOL_GPL(nf_nat_proto_in_range);
 
-bool nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
+void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 			       const struct nf_nat_range *range,
 			       enum nf_nat_manip_type maniptype,
 			       const struct nf_conn *ct,
@@ -53,7 +53,7 @@ bool nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 	if (!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED)) {
 		/* If it's dst rewrite, can't change port */
 		if (maniptype == IP_NAT_MANIP_DST)
-			return false;
+			return;
 
 		if (ntohs(*portptr) < 1024) {
 			/* Loose convention: >> 512 is credential passing */
@@ -87,9 +87,9 @@ bool nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 			continue;
 		if (!(range->flags & IP_NAT_RANGE_PROTO_RANDOM))
 			*rover = off;
-		return true;
+		return;
 	}
-	return false;
+	return;
 }
 EXPORT_SYMBOL_GPL(nf_nat_proto_unique_tuple);
 
diff --git a/net/ipv4/netfilter/nf_nat_proto_dccp.c b/net/ipv4/netfilter/nf_nat_proto_dccp.c
index 22485ce..570faf2 100644
--- a/net/ipv4/netfilter/nf_nat_proto_dccp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_dccp.c
@@ -22,14 +22,14 @@
 
 static u_int16_t dccp_port_rover;
 
-static bool
+static void
 dccp_unique_tuple(struct nf_conntrack_tuple *tuple,
 		  const struct nf_nat_range *range,
 		  enum nf_nat_manip_type maniptype,
 		  const struct nf_conn *ct)
 {
-	return nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
-					 &dccp_port_rover);
+	nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
+				  &dccp_port_rover);
 }
 
 static bool
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index d7e8920..89933ab 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -37,7 +37,7 @@ MODULE_AUTHOR("Harald Welte <laforge@gnumonks.org>");
 MODULE_DESCRIPTION("Netfilter NAT protocol helper module for GRE");
 
 /* generate unique tuple ... */
-static bool
+static void
 gre_unique_tuple(struct nf_conntrack_tuple *tuple,
 		 const struct nf_nat_range *range,
 		 enum nf_nat_manip_type maniptype,
@@ -50,7 +50,7 @@ gre_unique_tuple(struct nf_conntrack_tuple *tuple,
 	/* If there is no master conntrack we are not PPTP,
 	   do not change tuples */
 	if (!ct->master)
-		return false;
+		return;
 
 	if (maniptype == IP_NAT_MANIP_SRC)
 		keyptr = &tuple->src.u.gre.key;
@@ -71,11 +71,11 @@ gre_unique_tuple(struct nf_conntrack_tuple *tuple,
 	for (i = 0; i < range_size; i++, key++) {
 		*keyptr = htons(min + key % range_size);
 		if (!nf_nat_used_tuple(tuple, ct))
-			return true;
+			return;
 	}
 
 	pr_debug("%p: no NAT mapping\n", ct);
-	return false;
+	return;
 }
 
 /* manipulate a GRE packet according to maniptype */
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index 19a8b0b..97003fe 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -27,7 +27,7 @@ icmp_in_range(const struct nf_conntrack_tuple *tuple,
 	       ntohs(tuple->src.u.icmp.id) <= ntohs(max->icmp.id);
 }
 
-static bool
+static void
 icmp_unique_tuple(struct nf_conntrack_tuple *tuple,
 		  const struct nf_nat_range *range,
 		  enum nf_nat_manip_type maniptype,
@@ -46,9 +46,9 @@ icmp_unique_tuple(struct nf_conntrack_tuple *tuple,
 		tuple->src.u.icmp.id = htons(ntohs(range->min.icmp.id) +
 					     (id % range_size));
 		if (!nf_nat_used_tuple(tuple, ct))
-			return true;
+			return;
 	}
-	return false;
+	return;
 }
 
 static bool
diff --git a/net/ipv4/netfilter/nf_nat_proto_sctp.c b/net/ipv4/netfilter/nf_nat_proto_sctp.c
index 3fc598e..756331d 100644
--- a/net/ipv4/netfilter/nf_nat_proto_sctp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_sctp.c
@@ -16,14 +16,14 @@
 
 static u_int16_t nf_sctp_port_rover;
 
-static bool
+static void
 sctp_unique_tuple(struct nf_conntrack_tuple *tuple,
 		  const struct nf_nat_range *range,
 		  enum nf_nat_manip_type maniptype,
 		  const struct nf_conn *ct)
 {
-	return nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
-					 &nf_sctp_port_rover);
+	nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
+				  &nf_sctp_port_rover);
 }
 
 static bool
diff --git a/net/ipv4/netfilter/nf_nat_proto_tcp.c b/net/ipv4/netfilter/nf_nat_proto_tcp.c
index 399e2cf..aa460a5 100644
--- a/net/ipv4/netfilter/nf_nat_proto_tcp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_tcp.c
@@ -20,14 +20,13 @@
 
 static u_int16_t tcp_port_rover;
 
-static bool
+static void
 tcp_unique_tuple(struct nf_conntrack_tuple *tuple,
 		 const struct nf_nat_range *range,
 		 enum nf_nat_manip_type maniptype,
 		 const struct nf_conn *ct)
 {
-	return nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
-					 &tcp_port_rover);
+	nf_nat_proto_unique_tuple(tuple, range, maniptype, ct, &tcp_port_rover);
 }
 
 static bool
diff --git a/net/ipv4/netfilter/nf_nat_proto_udp.c b/net/ipv4/netfilter/nf_nat_proto_udp.c
index 9e61c79..dfe65c7 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udp.c
@@ -19,14 +19,13 @@
 
 static u_int16_t udp_port_rover;
 
-static bool
+static void
 udp_unique_tuple(struct nf_conntrack_tuple *tuple,
 		 const struct nf_nat_range *range,
 		 enum nf_nat_manip_type maniptype,
 		 const struct nf_conn *ct)
 {
-	return nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
-					 &udp_port_rover);
+	nf_nat_proto_unique_tuple(tuple, range, maniptype, ct, &udp_port_rover);
 }
 
 static bool
diff --git a/net/ipv4/netfilter/nf_nat_proto_udplite.c b/net/ipv4/netfilter/nf_nat_proto_udplite.c
index 440a229..3cc8c8a 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udplite.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udplite.c
@@ -18,14 +18,14 @@
 
 static u_int16_t udplite_port_rover;
 
-static bool
+static void
 udplite_unique_tuple(struct nf_conntrack_tuple *tuple,
 		     const struct nf_nat_range *range,
 		     enum nf_nat_manip_type maniptype,
 		     const struct nf_conn *ct)
 {
-	return nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
-					 &udplite_port_rover);
+	nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
+				  &udplite_port_rover);
 }
 
 static bool
diff --git a/net/ipv4/netfilter/nf_nat_proto_unknown.c b/net/ipv4/netfilter/nf_nat_proto_unknown.c
index 14381c6..a50f2bc 100644
--- a/net/ipv4/netfilter/nf_nat_proto_unknown.c
+++ b/net/ipv4/netfilter/nf_nat_proto_unknown.c
@@ -26,14 +26,14 @@ static bool unknown_in_range(const struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-static bool unknown_unique_tuple(struct nf_conntrack_tuple *tuple,
+static void unknown_unique_tuple(struct nf_conntrack_tuple *tuple,
 				 const struct nf_nat_range *range,
 				 enum nf_nat_manip_type maniptype,
 				 const struct nf_conn *ct)
 {
 	/* Sorry: we can't help you; if it's not unique, we can't frob
 	   anything. */
-	return false;
+	return;
 }
 
 static bool
-- 
1.7.1

