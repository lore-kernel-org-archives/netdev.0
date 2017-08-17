From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [RFC,
 iproute2 PATCH v2] tc/mirred: Extend the mirred/redirect action to
 accept additional traffic class parameter
Date: Thu, 17 Aug 2017 03:39:38 -0700
Message-ID: <150296637888.17366.17085150347312326898.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: amritha.nambiar@intel.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32836 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751843AbdHQKka (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 06:40:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Mirred/redirect action is extended to accept a traffic
class on the device in addition to the device's ifindex.

Usage: mirred <DIRECTION> <ACTION> <dev DEVICENAME> <tclass TC_INDEX>

Example:
# tc qdisc add dev eth0 ingress

# tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
  dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
  skip_sw action mirred ingress redirect dev eth0 tclass 1

v2: Renamed the parameter 'tc' to 'tclass'. Replaced atoi with
strtoul and used NEXT_ARG() construct.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 include/linux/tc_act/tc_mirred.h |    3 +++
 tc/m_mirred.c                    |   35 +++++++++++++++++++++++++++++++----
 2 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/include/linux/tc_act/tc_mirred.h b/include/linux/tc_act/tc_mirred.h
index 3d7a2b3..ea06a47 100644
--- a/include/linux/tc_act/tc_mirred.h
+++ b/include/linux/tc_act/tc_mirred.h
@@ -9,6 +9,8 @@
 #define TCA_EGRESS_MIRROR 2 /* mirror packet to EGRESS */
 #define TCA_INGRESS_REDIR 3  /* packet redirect to INGRESS*/
 #define TCA_INGRESS_MIRROR 4 /* mirror packet to INGRESS */
+
+#define MIRRED_F_TCLASS	0x1
                                                                                 
 struct tc_mirred {
 	tc_gen;
@@ -21,6 +23,7 @@ enum {
 	TCA_MIRRED_TM,
 	TCA_MIRRED_PARMS,
 	TCA_MIRRED_PAD,
+	TCA_MIRRED_TCLASS,
 	__TCA_MIRRED_MAX
 };
 #define TCA_MIRRED_MAX (__TCA_MIRRED_MAX - 1)
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index 2384bda..1cb477a 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -29,12 +29,13 @@
 static void
 explain(void)
 {
-	fprintf(stderr, "Usage: mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME>\n");
+	fprintf(stderr, "Usage: mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME> [tclass TCINDEX]\n");
 	fprintf(stderr, "where:\n");
 	fprintf(stderr, "\tDIRECTION := <ingress | egress>\n");
 	fprintf(stderr, "\tACTION := <mirror | redirect>\n");
 	fprintf(stderr, "\tINDEX  is the specific policy instance id\n");
 	fprintf(stderr, "\tDEVICENAME is the devicename\n");
+	fprintf(stderr, "\tTCINDEX is the traffic class index\n");
 
 }
 
@@ -72,6 +73,9 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
 	struct tc_mirred p = {};
 	struct rtattr *tail;
 	char d[16] = {};
+	__u32 flags = 0;
+	char *end;
+	__u8 tc;
 
 	while (argc > 0) {
 
@@ -139,9 +143,23 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
 					duparg("dev", *argv);
 
 				strncpy(d, *argv, sizeof(d)-1);
-				argc--;
-				argv++;
-
+				NEXT_ARG_FWD();
+
+				if (argc > 0 && matches(*argv, "tclass") == 0) {
+					NEXT_ARG();
+					tc = strtoul(*argv, &end, 0);
+					if (*end) {
+						fprintf(stderr, "Illegal TC index\n");
+						return -1;
+					}
+					if (tc >= TC_QOPT_MAX_QUEUE) {
+						fprintf(stderr, "TC index exceeds max range\n");
+						return -1;
+					}
+					flags |= MIRRED_F_TCLASS;
+					ok++;
+					NEXT_ARG_FWD();
+				}
 				break;
 
 			}
@@ -193,6 +211,9 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
 	addattr_l(n, MAX_MSG, TCA_MIRRED_PARMS, &p, sizeof(p));
+	if (flags & MIRRED_F_TCLASS)
+		addattr_l(n, MAX_MSG, TCA_MIRRED_TCLASS,
+			  &tc, sizeof(tc));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 
 	*argc_p = argc;
@@ -248,6 +269,7 @@ print_mirred(struct action_util *au, FILE * f, struct rtattr *arg)
 	struct tc_mirred *p;
 	struct rtattr *tb[TCA_MIRRED_MAX + 1];
 	const char *dev;
+	__u8 *tc;
 
 	if (arg == NULL)
 		return -1;
@@ -273,6 +295,11 @@ print_mirred(struct action_util *au, FILE * f, struct rtattr *arg)
 	fprintf(f, "mirred (%s to device %s)", mirred_n2a(p->eaction), dev);
 	print_action_control(f, " ", p->action, "");
 
+	if (tb[TCA_MIRRED_TCLASS]) {
+		tc = RTA_DATA(tb[TCA_MIRRED_TCLASS]);
+		fprintf(f, " tclass %u", *tc);
+	}
+
 	fprintf(f, "\n ");
 	fprintf(f, "\tindex %u ref %d bind %d", p->index, p->refcnt,
 		p->bindcnt);
