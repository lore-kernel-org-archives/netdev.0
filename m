From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 8/8] iproute2: handle new bridge PROTINFO format
Date: Mon, 29 Oct 2012 17:57:39 -0700
Message-ID: <20121030005835.894317015@vyatta.com>
References: <20121030005731.843020405@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:35112 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761340Ab2J3BGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 21:06:15 -0400
Content-Disposition: inline; filename=virtio-bql.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support nested attributes over netlink for bridge port state
---
Patch against current -git version of iproute2

 bridge/link.c           |   56 ++++++++++++++++++++++++++++++++++++++++++-----
 include/linux/if_link.h |   18 +++++++++++++++
 lib/libnetlink.c        |    6 +++--
 3 files changed, 72 insertions(+), 8 deletions(-)

diff --git a/bridge/link.c b/bridge/link.c
index edb6fbf..4ae256b 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -69,6 +69,49 @@ static void print_operstate(FILE *f, __u8 state)
 		fprintf(f, "state %s ", oper_states[state]);
 }
 
+static void print_stpstate(FILE *fp, __u8 state)
+{
+	if (state <= BR_STATE_BLOCKING)
+		fprintf(fp, "state %s", port_states[state]);
+	else
+		fprintf(fp, "state (%d)", state);
+}
+
+static void print_protinfo(FILE *f, struct rtattr *pinfo)
+{
+	struct rtattr *pb[IFLA_BRPORT_MAX+1];
+
+	parse_rtattr_nested(pb, IFLA_BRPORT_MAX, pinfo);
+
+	if (pb[IFLA_BRPORT_STATE])
+		print_stpstate(f, rta_getattr_u8(pb[IFLA_BRPORT_STATE]));
+
+	if (pb[IFLA_BRPORT_PRIORITY])
+		fprintf(f, " priority %u",
+			rta_getattr_u16(pb[IFLA_BRPORT_PRIORITY]));
+
+	if (pb[IFLA_BRPORT_COST])
+		fprintf(f, " cost %u",
+			rta_getattr_u32(pb[IFLA_BRPORT_COST]));
+
+
+	if (pb[IFLA_BRPORT_MODE]) {
+		__u8 mode = rta_getattr_u8(pb[IFLA_BRPORT_MODE]);
+		if (mode == BRIDGE_MODE_HAIRPIN)
+			fprintf(f, " hairpin");
+	}
+
+	if (pb[IFLA_BRPORT_BLOCK] && rta_getattr_u8(pb[IFLA_BRPORT_BLOCK]))
+		fprintf(f, " bpdu blocked");
+
+	if (pb[IFLA_BRPORT_GUARD] && rta_getattr_u8(pb[IFLA_BRPORT_GUARD]))
+		fprintf(f, " bpdu guard");
+
+	if (pb[IFLA_BRPORT_PROTECT] && rta_getattr_u8(pb[IFLA_BRPORT_PROTECT]))
+		fprintf(f, " rootprotect");
+
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -124,13 +167,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			if_indextoname(rta_getattr_u32(tb[IFLA_MASTER]), b1));
 
 	if (tb[IFLA_PROTINFO]) {
-		__u8 state = rta_getattr_u8(tb[IFLA_PROTINFO]);
-		if (state <= BR_STATE_BLOCKING)
-			fprintf(fp, "state %s", port_states[state]);
-		else
-			fprintf(fp, "state (%d)", state);
-	}
+		struct rtattr *pinfo = tb[IFLA_PROTINFO];
 
+		/* Handle both new (nested) and bare format */
+		if (pinfo->rta_type & NLA_F_NESTED)
+			print_protinfo(fp, pinfo);
+ 		else
+			print_stpstate(fp, rta_getattr_u8(tb[IFLA_PROTINFO]));
+	}
 
 	fprintf(fp, "\n");
 	fflush(fp);
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 012d95a..cb5e8a7 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -203,6 +203,24 @@ enum {
 
 #define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
 
+enum {
+	BRIDGE_MODE_UNSPEC,
+	BRIDGE_MODE_HAIRPIN,
+};
+
+enum {
+	IFLA_BRPORT_UNSPEC,
+	IFLA_BRPORT_STATE,	/* Spanning tree state     */
+	IFLA_BRPORT_PRIORITY,	/* "             priority  */
+	IFLA_BRPORT_COST,	/* "             cost      */
+	IFLA_BRPORT_MODE,	/* mode (hairpin)          */
+	IFLA_BRPORT_GUARD,	/* bpdu guard              */
+	IFLA_BRPORT_PROTECT,	/* root port protection    */
+	IFLA_BRPORT_BLOCK,	/* bpdu filter             */
+	__IFLA_BRPORT_MAX
+};
+#define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
+
 struct ifla_cacheinfo {
 	__u32	max_reasm_len;
 	__u32	tstamp;		/* ipv6InterfaceTable updated timestamp */
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 8e8c8b9..08dadf9 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -653,9 +653,11 @@ int rta_addattr_l(struct rtattr *rta, int maxlen, int type,
 int parse_rtattr(struct rtattr *tb[], int max, struct rtattr *rta, int len)
 {
 	memset(tb, 0, sizeof(struct rtattr *) * (max + 1));
+
 	while (RTA_OK(rta, len)) {
-		if ((rta->rta_type <= max) && (!tb[rta->rta_type]))
-			tb[rta->rta_type] = rta;
+		__u16 rta_type = rta->rta_type & NLA_TYPE_MASK;
+		if (rta_type <= max && !tb[rta_type])
+			tb[rta_type] = rta;
 		rta = RTA_NEXT(rta,len);
 	}
 	if (len)
-- 
1.7.10.4
