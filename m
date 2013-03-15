From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv3 iproute2 2/3] bridge: Add support for printing bridge port attributes
Date: Fri, 15 Mar 2013 13:01:08 -0400
Message-ID: <1363366869-27778-3-git-send-email-vyasevic@redhat.com>
References: <1363366869-27778-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755089Ab3CORBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 13:01:13 -0400
In-Reply-To: <1363366869-27778-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Output new nested bridge port attributes.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 bridge/link.c        |   79 +++++++++++++++++++++++++++++++++++++++++++++----
 include/libnetlink.h |    2 +
 lib/libnetlink.c     |   13 +++++++-
 3 files changed, 85 insertions(+), 9 deletions(-)

diff --git a/bridge/link.c b/bridge/link.c
index 5811ee9..6b53833 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -65,6 +65,8 @@ static const char *oper_states[] = {
 	"TESTING", "DORMANT",	 "UP"
 };
 
+static const char *hw_mode[] = {"VEB", "VEPA"};
+
 static void print_operstate(FILE *f, __u8 state)
 {
 	if (state >= sizeof(oper_states)/sizeof(oper_states[0]))
@@ -73,6 +75,27 @@ static void print_operstate(FILE *f, __u8 state)
 		fprintf(f, "state %s ", oper_states[state]);
 }
 
+static void print_portstate(FILE *f, __u8 state)
+{
+	if (state <= BR_STATE_BLOCKING)
+		fprintf(f, "state %s ", port_states[state]);
+	else
+		fprintf(f, "state (%d) ", state);
+}
+
+static void print_onoff(FILE *f, char *flag, __u8 val)
+{
+	fprintf(f, "%s %s ", flag, val ? "on" : "off");
+}
+
+static void print_hwmode(FILE *f, __u16 mode)
+{
+	if (mode >= sizeof(hw_mode)/sizeof(hw_mode[0]))
+		fprintf(f, "hwmode %#hx ", mode);
+	else
+		fprintf(f, "hwmode %s ", hw_mode[mode]);
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -94,7 +117,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (filter_index && filter_index != ifi->ifi_index)
 		return 0;
 
-	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
+	parse_rtattr_flags(tb, IFLA_MAX, IFLA_RTA(ifi), len, NLA_F_NESTED);
 
 	if (tb[IFLA_IFNAME] == NULL) {
 		fprintf(stderr, "BUG: nil ifname\n");
@@ -131,13 +154,48 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			if_indextoname(rta_getattr_u32(tb[IFLA_MASTER]), b1));
 
 	if (tb[IFLA_PROTINFO]) {
-		__u8 state = rta_getattr_u8(tb[IFLA_PROTINFO]);
-		if (state <= BR_STATE_BLOCKING)
-			fprintf(fp, "state %s", port_states[state]);
-		else
-			fprintf(fp, "state (%d)", state);
+		if (tb[IFLA_PROTINFO]->rta_type & NLA_F_NESTED) {
+			struct rtattr *prtb[IFLA_BRPORT_MAX+1];
+
+			parse_rtattr_nested(prtb, IFLA_BRPORT_MAX,
+					    tb[IFLA_PROTINFO]);
+
+			if (prtb[IFLA_BRPORT_STATE])
+				print_portstate(fp,
+						rta_getattr_u8(prtb[IFLA_BRPORT_STATE]));
+			if (prtb[IFLA_BRPORT_PRIORITY])
+				fprintf(fp, "priority %hu ",
+					rta_getattr_u16(prtb[IFLA_BRPORT_PRIORITY]));
+			if (prtb[IFLA_BRPORT_COST])
+				fprintf(fp, "cost %u ",
+					rta_getattr_u32(prtb[IFLA_BRPORT_COST]));
+			if (prtb[IFLA_BRPORT_MODE])
+				print_onoff(fp, "hairpin",
+					    rta_getattr_u8(prtb[IFLA_BRPORT_MODE]));
+			if (prtb[IFLA_BRPORT_GUARD])
+				print_onoff(fp, "guard",
+					    rta_getattr_u8(prtb[IFLA_BRPORT_GUARD]));
+			if (prtb[IFLA_BRPORT_PROTECT])
+				print_onoff(fp, "root_block",
+					    rta_getattr_u8(prtb[IFLA_BRPORT_PROTECT]));
+			if (prtb[IFLA_BRPORT_FAST_LEAVE])
+				print_onoff(fp, "fastleave",
+					    rta_getattr_u8(prtb[IFLA_BRPORT_FAST_LEAVE]));
+		} else
+			print_portstate(fp, rta_getattr_u8(tb[IFLA_PROTINFO]));
 	}
 
+	if (tb[IFLA_AF_SPEC]) {
+		/* This is reported by HW devices that have some bridging
+		 * capabilities.
+		 */
+		struct rtattr *aftb[IFLA_BRIDGE_MAX+1];
+
+		parse_rtattr_nested(aftb, IFLA_BRIDGE_MAX, tb[IFLA_AF_SPEC]);
+
+		if (tb[IFLA_BRIDGE_MODE])
+			print_hwmode(fp, rta_getattr_u16(tb[IFLA_BRIDGE_MODE]));
+	}
 
 	fprintf(fp, "\n");
 	fflush(fp);
@@ -183,6 +241,7 @@ static int brlink_modify(int argc, char **argv)
 	__s8 hairpin = -1;
 	__s8 bpdu_guard = -1;
 	__s8 fast_leave = -1;
+	__s8 root_block = -1;
 	__u32 cost = 0;
 	__s16 priority = -1;
 	__s8 state = -1;
@@ -213,6 +272,10 @@ static int brlink_modify(int argc, char **argv)
 			NEXT_ARG();
 			if (!on_off("fastleave", &fast_leave, *argv))
 				exit(-1);
+		} else if (strcmp(*argv, "root_block") == 0) {
+			NEXT_ARG();
+			if (!on_off("root_block", &root_block, *argv))
+				exit(-1);
 		} else if (strcmp(*argv, "cost")) {
 			NEXT_ARG();
 			cost = atoi(*argv);
@@ -222,7 +285,7 @@ static int brlink_modify(int argc, char **argv)
 		} else if (strcmp(*argv, "state")) {
 			NEXT_ARG();
 			state = atoi(*argv);
-		} else if (strcmp(*argv, "mode")) {
+		} else if (strcmp(*argv, "hwmode")) {
 			NEXT_ARG();
 			flags |= BRIDGE_FLAGS_SELF;
 			if (strcmp(*argv, "vepa") == 0)
@@ -265,6 +328,8 @@ static int brlink_modify(int argc, char **argv)
 	if (fast_leave >= 0)
 		addattr8(&req.n, sizeof(req), IFLA_BRPORT_FAST_LEAVE,
 			 fast_leave);
+	if (root_block >= 0)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_PROTECT, root_block);
 
 	if (cost > 0)
 		addattr32(&req.n, sizeof(req), IFLA_BRPORT_COST, cost);
diff --git a/include/libnetlink.h b/include/libnetlink.h
index 8d15ee5..ec3d657 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -65,6 +65,8 @@ extern int rta_addattr32(struct rtattr *rta, int maxlen, int type, __u32 data);
 extern int rta_addattr_l(struct rtattr *rta, int maxlen, int type, const void *data, int alen);
 
 extern int parse_rtattr(struct rtattr *tb[], int max, struct rtattr *rta, int len);
+extern int parse_rtattr_flags(struct rtattr *tb[], int max, struct rtattr *rta,
+			      int len, unsigned short flags);
 extern int parse_rtattr_byindex(struct rtattr *tb[], int max, struct rtattr *rta, int len);
 extern int __parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rta, int len);
 
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 67f046f..f262959 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -658,10 +658,19 @@ int rta_addattr_l(struct rtattr *rta, int maxlen, int type,
 
 int parse_rtattr(struct rtattr *tb[], int max, struct rtattr *rta, int len)
 {
+	return parse_rtattr_flags(tb, max, rta, len, 0);
+}
+
+int parse_rtattr_flags(struct rtattr *tb[], int max, struct rtattr *rta,
+		       int len, unsigned short flags)
+{
+	unsigned short type;
+
 	memset(tb, 0, sizeof(struct rtattr *) * (max + 1));
 	while (RTA_OK(rta, len)) {
-		if ((rta->rta_type <= max) && (!tb[rta->rta_type]))
-			tb[rta->rta_type] = rta;
+		type = rta->rta_type & ~flags;
+		if ((type <= max) && (!tb[type]))
+			tb[type] = rta;
 		rta = RTA_NEXT(rta,len);
 	}
 	if (len)
-- 
1.7.7.6
