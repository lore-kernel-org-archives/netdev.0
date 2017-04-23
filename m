From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 net 2/8] tc/pedit: Extend pedit to specify offset relative to mac/transport headers
Date: Sun, 23 Apr 2017 15:53:50 +0300
Message-ID: <20170423125356.1298-3-amir@vadai.me>
References: <20170423125356.1298-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33038 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045421AbdDWMyj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 08:54:39 -0400
Received: by mail-wr0-f194.google.com with SMTP id w50so12968542wrc.0
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 05:54:38 -0700 (PDT)
In-Reply-To: <20170423125356.1298-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Utilize the extended pedit netlink to set an offset relative to a
specific header type. Old netlink only enabled the user to set
approximated  offset relative to the IPv4 header.

To use this extended functionality need to use the 'ex' keyword after
'pedit' and before any 'munge'.
e.g:
$ tc filter add dev ens9 protocol ip parent ffff: \
    flower \
      ip_proto udp \
      dst_port 80 \
    action pedit ex munge \
      ip dst set 1.1.1.1 \
      pipe \
    action mirred egress redirect dev veth0

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 man/man8/tc-pedit.8 |  41 +++++++---
 tc/m_pedit.c        | 213 +++++++++++++++++++++++++++++++++++++++++++++-------
 tc/m_pedit.h        |  43 ++++++++---
 tc/p_icmp.c         |   3 +-
 tc/p_ip.c           |  15 +++-
 tc/p_tcp.c          |   3 +-
 tc/p_udp.c          |   3 +-
 7 files changed, 270 insertions(+), 51 deletions(-)

diff --git a/man/man8/tc-pedit.8 b/man/man8/tc-pedit.8
index c34520c046a6..761d5c8ee2d5 100644
--- a/man/man8/tc-pedit.8
+++ b/man/man8/tc-pedit.8
@@ -5,8 +5,8 @@ pedit - generic packet editor action
 .SH SYNOPSIS
 .in +8
 .ti -8
-.BR tc " ... " "action pedit munge " {
-.IR RAW_OP " | " LAYERED_OP " } [ " CONTROL " ]"
+.BR tc " ... " "action pedit [ex] munge " {
+.IR RAW_OP " | " LAYERED_OP " | " EXTENDED_LAYERED_OP " } [ " CONTROL " ]"
 
 .ti -8
 .IR RAW_OP " := "
@@ -22,20 +22,22 @@ pedit - generic packet editor action
 .IR LAYERED_OP " := { "
 .BI ip " IPHDR_FIELD"
 |
-.BI ip6 " IP6HDR_FIELD"
-|
-.BI udp " UDPHDR_FIELD"
-|
-.BI tcp " TCPHDR_FIELD"
-|
-.BI icmp " ICMPHDR_FIELD"
+.BI ip " BEYOND_IPHDR_FIELD"
+.RI } " CMD_SPEC"
+
+.ti -8
+.IR EXTENDED_LAYERED_OP " := { "
+.BI ip " IPHDR_FIELD"
 .RI } " CMD_SPEC"
 
 .ti -8
 .IR IPHDR_FIELD " := { "
 .BR src " | " dst " | " tos " | " dsfield " | " ihl " | " protocol " |"
-.BR precedence " | " nofrag " | " firstfrag " | " ce " | " df " |"
-.BR mf " | " dport " | " sport " | " icmp_type " | " icmp_code " }"
+.BR precedence " | " nofrag " | " firstfrag " | " ce " | " df " }"
+
+.ti -8
+.IR BEYOND_IPHDR_FIELD " := { "
+.BR dport " | " sport " | " icmp_type " | " icmp_code " }"
 
 .ti -8
 .IR CMD_SPEC " := {"
@@ -58,6 +60,11 @@ chosen automatically based on the header field size. Currently this is supported
 only for IPv4 headers.
 .SH OPTIONS
 .TP
+.B ex
+Use extended pedit.
+.I EXTENDED_LAYERED_OP
+is allowed only in this mode.
+.TP
 .BI offset " OFFSET " "\fR{ \fBu32 \fR| \fBu16 \fR| \fBu8 \fR}"
 Specify the offset at which to change data.
 .I OFFSET
@@ -123,6 +130,15 @@ Change IP header flags. Note that the value to pass to the
 .B set
 command is not just a bit value, but the full byte including the flags field.
 Though only the relevant bits of that value are respected, the rest ignored.
+.RE
+.TP
+.BI ip " BEYOND_IPHDR_FIELD"
+Supported only for non-extended layered op. It is passed to the kernel as
+offsets relative to the beginning of the IP header and assumes the IP header is
+of minimum size (20 bytes). The supported keywords for
+.I BEYOND_IPHDR_FIELD
+are:
+.RS
 .TP
 .B dport
 .TQ
@@ -222,6 +238,9 @@ tc filter add dev eth0 parent 1: u32 \\
 tc filter add dev eth0 parent ffff: u32 \\
 	match ip sport 22 0xffff \\
 	action pedit pedit munge ip sport set 23
+tc filter add dev eth0 parent ffff: u32 \\
+	match ip sport 22 0xffff \\
+	action pedit ex munge ip dst set 192.168.1.199
 .EE
 .RE
 .SH SEE ALSO
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 939a6a1455a5..a26fd3e5bc5e 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -34,7 +34,7 @@ static int pedit_debug;
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... pedit munge <MUNGE> [CONTROL]\n");
+	fprintf(stderr, "Usage: ... pedit munge [ex] <MUNGE> [CONTROL]\n");
 	fprintf(stderr,
 		"Where: MUNGE := <RAW>|<LAYERED>\n"
 		"\t<RAW>:= <OFFSETC>[ATC]<CMD>\n \t\tOFFSETC:= offset <offval> <u8|u16|u32>\n"
@@ -45,6 +45,7 @@ static void explain(void)
 		"\t<LAYERED>:= ip <ipdata> | ip6 <ip6data>\n"
 		" \t\t| udp <udpdata> | tcp <tcpdata> | icmp <icmpdata>\n"
 		"\tCONTROL:= reclassify | pipe | drop | continue | pass\n"
+		"\tNOTE: if 'ex' is set, extended functionality will be supported (kernel >= 4.11)\n"
 		"For Example usage look at the examples directory\n");
 
 }
@@ -56,8 +57,8 @@ static void usage(void)
 }
 
 static int pedit_parse_nopopt(int *argc_p, char ***argv_p,
-			      struct tc_pedit_sel *sel,
-			      struct tc_pedit_key *tkey)
+			      struct m_pedit_sel *sel,
+			      struct m_pedit_key *tkey)
 {
 	int argc = *argc_p;
 	char **argv = *argv_p;
@@ -116,8 +117,10 @@ noexist:
 	return p;
 }
 
-int pack_key(struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+int pack_key(struct m_pedit_sel *_sel, struct m_pedit_key *tkey)
 {
+	struct tc_pedit_sel *sel = &_sel->sel;
+	struct m_pedit_key_ex *keys_ex = _sel->keys_ex;
 	int hwm = sel->nkeys;
 
 	if (hwm >= MAX_OFFS)
@@ -134,12 +137,24 @@ int pack_key(struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
 	sel->keys[hwm].at = tkey->at;
 	sel->keys[hwm].offmask = tkey->offmask;
 	sel->keys[hwm].shift = tkey->shift;
+
+	if (_sel->extended) {
+		keys_ex[hwm].htype = tkey->htype;
+		keys_ex[hwm].cmd = tkey->cmd;
+	} else {
+		if (tkey->htype != TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK ||
+		    tkey->cmd != TCA_PEDIT_KEY_EX_CMD_SET) {
+			fprintf(stderr, "Munge parameters not supported. Use 'munge ex'.\n");
+			return -1;
+		}
+	}
+
 	sel->nkeys++;
 	return 0;
 }
 
-int pack_key32(__u32 retain, struct tc_pedit_sel *sel,
-	       struct tc_pedit_key *tkey)
+int pack_key32(__u32 retain, struct m_pedit_sel *sel,
+	       struct m_pedit_key *tkey)
 {
 	if (tkey->off > (tkey->off & ~3)) {
 		fprintf(stderr,
@@ -152,8 +167,8 @@ int pack_key32(__u32 retain, struct tc_pedit_sel *sel,
 	return pack_key(sel, tkey);
 }
 
-int pack_key16(__u32 retain, struct tc_pedit_sel *sel,
-	       struct tc_pedit_key *tkey)
+int pack_key16(__u32 retain, struct m_pedit_sel *sel,
+	       struct m_pedit_key *tkey)
 {
 	int ind, stride;
 	__u32 m[4] = { 0x0000FFFF, 0xFF0000FF, 0xFFFF0000 };
@@ -183,7 +198,7 @@ int pack_key16(__u32 retain, struct tc_pedit_sel *sel,
 
 }
 
-int pack_key8(__u32 retain, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+int pack_key8(__u32 retain, struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 {
 	int ind, stride;
 	__u32 m[4] = { 0x00FFFFFF, 0xFF00FFFF, 0xFFFF00FF, 0xFFFFFF00 };
@@ -239,7 +254,7 @@ int parse_val(int *argc_p, char ***argv_p, __u32 *val, int type)
 }
 
 int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
-	      struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+	      struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 {
 	__u32 mask = 0, val = 0;
 	__u32 o = 0xFF;
@@ -313,8 +328,8 @@ done:
 
 }
 
-int parse_offset(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel,
-		 struct tc_pedit_key *tkey)
+int parse_offset(int *argc_p, char ***argv_p, struct m_pedit_sel *sel,
+		 struct m_pedit_key *tkey)
 {
 	int off;
 	__u32 len, retain;
@@ -389,9 +404,9 @@ done:
 	return res;
 }
 
-static int parse_munge(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel)
+static int parse_munge(int *argc_p, char ***argv_p, struct m_pedit_sel *sel)
 {
-	struct tc_pedit_key tkey = {};
+	struct m_pedit_key tkey = {};
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int res = -1;
@@ -433,13 +448,69 @@ done:
 	return res;
 }
 
+static int pedit_keys_ex_getattr(struct rtattr *attr,
+				 struct m_pedit_key_ex *keys_ex, int n)
+{
+	struct rtattr *i;
+	int rem = RTA_PAYLOAD(attr);
+	struct rtattr *tb[TCA_PEDIT_KEY_EX_MAX + 1];
+	struct m_pedit_key_ex *k = keys_ex;
+
+	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		if (!n)
+			return -1;
+
+		if (i->rta_type != TCA_PEDIT_KEY_EX)
+			return -1;
+
+		parse_rtattr_nested(tb, TCA_PEDIT_KEY_EX_MAX, i);
+
+		k->htype = rta_getattr_u16(tb[TCA_PEDIT_KEY_EX_HTYPE]);
+		k->cmd = rta_getattr_u16(tb[TCA_PEDIT_KEY_EX_CMD]);
+
+		k++;
+		n--;
+	}
+
+	return !!n;
+}
+
+static int pedit_keys_ex_addattr(struct m_pedit_sel *sel, struct nlmsghdr *n)
+{
+	struct m_pedit_key_ex *k = sel->keys_ex;
+	struct rtattr *keys_start;
+	int i;
+
+	if (!sel->extended)
+		return 0;
+
+	keys_start = addattr_nest(n, MAX_MSG, TCA_PEDIT_KEYS_EX | NLA_F_NESTED);
+
+	for (i = 0; i < sel->sel.nkeys; i++) {
+		struct rtattr *key_start;
+
+		key_start = addattr_nest(n, MAX_MSG,
+					 TCA_PEDIT_KEY_EX | NLA_F_NESTED);
+
+		if (addattr16(n, MAX_MSG, TCA_PEDIT_KEY_EX_HTYPE, k->htype) ||
+		    addattr16(n, MAX_MSG, TCA_PEDIT_KEY_EX_CMD, k->cmd)) {
+			return -1;
+		}
+
+		addattr_nest_end(n, key_start);
+
+		k++;
+	}
+
+	addattr_nest_end(n, keys_start);
+
+	return 0;
+}
+
 int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		struct nlmsghdr *n)
 {
-	struct {
-		struct tc_pedit_sel sel;
-		struct tc_pedit_key keys[MAX_OFFS];
-	} sel = {};
+	struct m_pedit_sel sel = {};
 
 	int argc = *argc_p;
 	char **argv = *argv_p;
@@ -452,6 +523,17 @@ int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		if (matches(*argv, "pedit") == 0) {
 			NEXT_ARG();
 			ok++;
+
+			if (matches(*argv, "ex") == 0) {
+				if (ok > 1) {
+					fprintf(stderr, "'ex' must be before first 'munge'\n");
+					explain();
+					return -1;
+				}
+				sel.extended = true;
+				NEXT_ARG();
+			}
+
 			continue;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
@@ -463,7 +545,8 @@ int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 				return -1;
 			}
 			NEXT_ARG();
-			if (parse_munge(&argc, &argv, &sel.sel)) {
+
+			if (parse_munge(&argc, &argv, &sel)) {
 				fprintf(stderr, "Bad pedit construct (%s)\n",
 					*argv);
 				explain();
@@ -499,9 +582,18 @@ int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
-	addattr_l(n, MAX_MSG, TCA_PEDIT_PARMS, &sel,
-		  sizeof(sel.sel) +
-		  sel.sel.nkeys * sizeof(struct tc_pedit_key));
+	if (!sel.extended) {
+		addattr_l(n, MAX_MSG, TCA_PEDIT_PARMS, &sel,
+			  sizeof(sel.sel) +
+			  sel.sel.nkeys * sizeof(struct tc_pedit_key));
+	} else {
+		addattr_l(n, MAX_MSG, TCA_PEDIT_PARMS_EX, &sel,
+			  sizeof(sel.sel) +
+			  sel.sel.nkeys * sizeof(struct tc_pedit_key));
+
+		pedit_keys_ex_addattr(&sel, n);
+	}
+
 	tail->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail;
 
 	*argc_p = argc;
@@ -509,21 +601,74 @@ int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	return 0;
 }
 
+const char *pedit_htype_str[] = {
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK] = "",
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_ETH] = "eth",
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_IP4] = "ipv4",
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_IP6] = "ipv6",
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_TCP] = "tcp",
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_UDP] = "udp",
+};
+
+static void print_pedit_location(FILE *f,
+				 enum pedit_header_type htype, __u32 off)
+{
+	if (htype == TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK) {
+		fprintf(f, "%d", (unsigned int)off);
+		return;
+	}
+
+	if (htype < ARRAY_SIZE(pedit_htype_str))
+		fprintf(f, "%s", pedit_htype_str[htype]);
+	else
+		fprintf(f, "unknown(%d)", htype);
+
+	fprintf(f, "%c%d", (int)off  >= 0 ? '+' : '-', abs((int)off));
+}
+
 int print_pedit(struct action_util *au, FILE *f, struct rtattr *arg)
 {
 	struct tc_pedit_sel *sel;
 	struct rtattr *tb[TCA_PEDIT_MAX + 1];
+	struct m_pedit_key_ex *keys_ex = NULL;
 
 	if (arg == NULL)
 		return -1;
 
 	parse_rtattr_nested(tb, TCA_PEDIT_MAX, arg);
 
-	if (tb[TCA_PEDIT_PARMS] == NULL) {
+	if (!tb[TCA_PEDIT_PARMS] && !tb[TCA_PEDIT_PARMS_EX]) {
 		fprintf(f, "[NULL pedit parameters]");
 		return -1;
 	}
-	sel = RTA_DATA(tb[TCA_PEDIT_PARMS]);
+
+	if (tb[TCA_PEDIT_PARMS]) {
+		sel = RTA_DATA(tb[TCA_PEDIT_PARMS]);
+	} else {
+		int err;
+
+		sel = RTA_DATA(tb[TCA_PEDIT_PARMS_EX]);
+
+		if (!tb[TCA_PEDIT_KEYS_EX]) {
+			fprintf(f, "Netlink error\n");
+			return -1;
+		}
+
+		keys_ex = calloc(sel->nkeys, sizeof(*keys_ex));
+		if (!keys_ex) {
+			fprintf(f, "Out of memory\n");
+			return -1;
+		}
+
+		err = pedit_keys_ex_getattr(tb[TCA_PEDIT_KEYS_EX], keys_ex,
+					    sel->nkeys);
+		if (err) {
+			fprintf(f, "Netlink error\n");
+
+			free(keys_ex);
+			return -1;
+		}
+	}
 
 	fprintf(f, " pedit action %s keys %d\n ",
 		action_n2a(sel->action), sel->nkeys);
@@ -540,11 +685,25 @@ int print_pedit(struct action_util *au, FILE *f, struct rtattr *arg)
 	if (sel->nkeys) {
 		int i;
 		struct tc_pedit_key *key = sel->keys;
+		struct m_pedit_key_ex *key_ex = keys_ex;
 
 		for (i = 0; i < sel->nkeys; i++, key++) {
+			enum pedit_header_type htype =
+				TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK;
+
+			if (keys_ex) {
+				htype = key_ex->htype;
+
+				key_ex++;
+			}
+
 			fprintf(f, "\n\t key #%d", i);
-			fprintf(f, "  at %d: val %08x mask %08x",
-				(unsigned int)key->off,
+
+			fprintf(f, "  at ");
+
+			print_pedit_location(f, htype, key->off);
+
+			fprintf(f, ": val %08x mask %08x",
 				(unsigned int)ntohl(key->val),
 				(unsigned int)ntohl(key->mask));
 		}
@@ -554,6 +713,8 @@ int print_pedit(struct action_util *au, FILE *f, struct rtattr *arg)
 	}
 
 	fprintf(f, "\n ");
+
+	free(keys_ex);
 	return 0;
 }
 
diff --git a/tc/m_pedit.h b/tc/m_pedit.h
index 1698c954e999..e2897b0c9808 100644
--- a/tc/m_pedit.h
+++ b/tc/m_pedit.h
@@ -39,22 +39,47 @@
 
 #define PEDITKINDSIZ 16
 
+struct m_pedit_key {
+	__u32           mask;  /* AND */
+	__u32           val;   /*XOR */
+	__u32           off;  /*offset */
+	__u32           at;
+	__u32           offmask;
+	__u32           shift;
+
+	enum pedit_header_type htype;
+	enum pedit_cmd cmd;
+};
+
+struct m_pedit_key_ex {
+	enum pedit_header_type htype;
+	enum pedit_cmd cmd;
+};
+
+struct m_pedit_sel {
+	struct tc_pedit_sel sel;
+	struct tc_pedit_key keys[MAX_OFFS];
+	struct m_pedit_key_ex keys_ex[MAX_OFFS];
+	bool extended;
+};
+
 struct m_pedit_util
 {
 	struct m_pedit_util *next;
 	char    id[PEDITKINDSIZ];
-	int     (*parse_peopt)(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+	int     (*parse_peopt)(int *argc_p, char ***argv_p,
+			       struct m_pedit_sel *sel, struct m_pedit_key *tkey);
 };
 
-
-extern int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type,__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
-extern int pack_key(struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
-extern int pack_key32(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
-extern int pack_key16(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
-extern int pack_key8(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+extern int pack_key(struct m_pedit_sel *sel, struct m_pedit_key *tkey);
+extern int pack_key32(__u32 retain, struct m_pedit_sel *sel, struct m_pedit_key *tkey);
+extern int pack_key16(__u32 retain, struct m_pedit_sel *sel, struct m_pedit_key *tkey);
+extern int pack_key8(__u32 retain, struct m_pedit_sel *sel, struct m_pedit_key *tkey);
 extern int parse_val(int *argc_p, char ***argv_p, __u32 * val, int type);
-extern int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type,__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
-extern int parse_offset(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+extern int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
+		     struct m_pedit_sel *sel, struct m_pedit_key *tkey);
+extern int parse_offset(int *argc_p, char ***argv_p,
+			struct m_pedit_sel *sel, struct m_pedit_key *tkey);
 int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n);
 extern int print_pedit(struct action_util *au,FILE * f, struct rtattr *arg);
 extern int pedit_print_xstats(struct action_util *au, FILE *f, struct rtattr *xstats);
diff --git a/tc/p_icmp.c b/tc/p_icmp.c
index c2a6fcd69817..1c3a5d90006d 100644
--- a/tc/p_icmp.c
+++ b/tc/p_icmp.c
@@ -25,7 +25,8 @@
 
 
 static int
-parse_icmp(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+parse_icmp(int *argc_p, char ***argv_p,
+	   struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 {
 	int res = -1;
 #if 0
diff --git a/tc/p_ip.c b/tc/p_ip.c
index 535151e5d766..e56eb39317ba 100644
--- a/tc/p_ip.c
+++ b/tc/p_ip.c
@@ -25,7 +25,7 @@
 
 static int
 parse_ip(int *argc_p, char ***argv_p,
-	 struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+	 struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 {
 	int res = -1;
 	int argc = *argc_p;
@@ -34,6 +34,10 @@ parse_ip(int *argc_p, char ***argv_p,
 	if (argc < 2)
 		return -1;
 
+	tkey->htype = sel->extended ?
+		TCA_PEDIT_KEY_EX_HDR_TYPE_IP4 :
+		TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK;
+
 	if (strcmp(*argv, "src") == 0) {
 		NEXT_ARG();
 		tkey->off = 12;
@@ -107,6 +111,13 @@ parse_ip(int *argc_p, char ***argv_p,
 		res = parse_cmd(&argc, &argv, 1, TU32, 0x20, sel, tkey);
 		goto done;
 	}
+
+	if (sel->extended)
+		return -1; /* fields located outside IP header should be
+			    * addressed using the relevant header type in
+			    * extended pedit kABI
+			    */
+
 	if (strcmp(*argv, "dport") == 0) {
 		NEXT_ARG();
 		tkey->off = 22;
@@ -141,7 +152,7 @@ done:
 
 static int
 parse_ip6(int *argc_p, char ***argv_p,
-	  struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+	  struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 {
 	int res = -1;
 	return res;
diff --git a/tc/p_tcp.c b/tc/p_tcp.c
index 79f16c58cad6..53ee9842160b 100644
--- a/tc/p_tcp.c
+++ b/tc/p_tcp.c
@@ -24,7 +24,8 @@
 #include "m_pedit.h"
 
 static int
-parse_tcp(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+parse_tcp(int *argc_p, char ***argv_p,
+	  struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 {
 	int res = -1;
 	return res;
diff --git a/tc/p_udp.c b/tc/p_udp.c
index c056414e6eb3..3a86ba382391 100644
--- a/tc/p_udp.c
+++ b/tc/p_udp.c
@@ -24,7 +24,8 @@
 #include "m_pedit.h"
 
 static int
-parse_udp(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+parse_udp(int *argc_p, char ***argv_p,
+	  struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 {
 	int res = -1;
 	return res;
-- 
2.12.0
