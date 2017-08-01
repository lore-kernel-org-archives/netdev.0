From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [PATCH RFC,
 iproute2] tc/mirred: Extend the mirred/redirect action to accept
 additional traffic class parameter
Date: Mon, 31 Jul 2017 17:40:50 -0700
Message-ID: <150154805003.4819.12498976860683140342.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, sridhar.samudrala@intel.com,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, carolyn.wyborny@intel.com,
        jeffrey.t.kirsher@intel.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:21833 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751102AbdHAAlb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 20:41:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Mirred/redirect action is extended to accept a traffic
class on the device in addition to the device's ifindex.

Usage: mirred <DIRECTION> <ACTION> <dev DEVICENAME> <tc TC_INDEX>

Example:
# tc qdisc add dev eth0 ingress

# tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
  dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
  indev eth0 action mirred ingress redirect dev eth0 tc 1

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 tc/m_mirred.c |   26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/linux/tc_act/tc_mirred.h b/include/linux/tc_act/tc_mirred.h
index 3d7a2b3..9a3aa61 100644
--- a/include/linux/tc_act/tc_mirred.h
+++ b/include/linux/tc_act/tc_mirred.h
@@ -9,6 +9,9 @@
 #define TCA_EGRESS_MIRROR 2 /* mirror packet to EGRESS */
 #define TCA_INGRESS_REDIR 3  /* packet redirect to INGRESS*/
 #define TCA_INGRESS_MIRROR 4 /* mirror packet to INGRESS */
+
+#define MIRRED_F_TC_MAP		0x1
+#define MIRRED_TC_MAP_MAX	0x10
                                                                                 
 struct tc_mirred {
 	tc_gen;
@@ -21,6 +24,7 @@ enum {
 	TCA_MIRRED_TM,
 	TCA_MIRRED_PARMS,
 	TCA_MIRRED_PAD,
+	TCA_MIRRED_TC_MAP,
 	__TCA_MIRRED_MAX
 };
 #define TCA_MIRRED_MAX (__TCA_MIRRED_MAX - 1)
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index 2384bda..1a18c6b 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -29,12 +29,13 @@
 static void
 explain(void)
 {
-	fprintf(stderr, "Usage: mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME>\n");
+	fprintf(stderr, "Usage: mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME> [tc TCINDEX]\n");
 	fprintf(stderr, "where:\n");
 	fprintf(stderr, "\tDIRECTION := <ingress | egress>\n");
 	fprintf(stderr, "\tACTION := <mirror | redirect>\n");
 	fprintf(stderr, "\tINDEX  is the specific policy instance id\n");
 	fprintf(stderr, "\tDEVICENAME is the devicename\n");
+	fprintf(stderr, "\tTCINDEX is the traffic class index\n");
 
 }
 
@@ -72,6 +73,8 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
 	struct tc_mirred p = {};
 	struct rtattr *tail;
 	char d[16] = {};
+	__u32 flags = 0;
+	__u8 tc;
 
 	while (argc > 0) {
 
@@ -142,6 +145,18 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
 				argc--;
 				argv++;
 
+				if ((argc > 0) && (matches(*argv, "tc") == 0)) {
+					NEXT_ARG();
+					tc = atoi(*argv);
+					if (tc >= MIRRED_TC_MAP_MAX) {
+						fprintf(stderr, "Invalid TC index\n");
+						return -1;
+					}
+					flags |= MIRRED_F_TC_MAP;
+					ok++;
+					argc--;
+					argv++;
+				}
 				break;
 
 			}
@@ -193,6 +208,9 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
 	addattr_l(n, MAX_MSG, TCA_MIRRED_PARMS, &p, sizeof(p));
+	if (flags & MIRRED_F_TC_MAP)
+		addattr_l(n, MAX_MSG, TCA_MIRRED_TC_MAP,
+			  &tc, sizeof(tc));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 
 	*argc_p = argc;
@@ -248,6 +266,7 @@ print_mirred(struct action_util *au, FILE * f, struct rtattr *arg)
 	struct tc_mirred *p;
 	struct rtattr *tb[TCA_MIRRED_MAX + 1];
 	const char *dev;
+	__u8 *tc;
 
 	if (arg == NULL)
 		return -1;
@@ -273,6 +292,11 @@ print_mirred(struct action_util *au, FILE * f, struct rtattr *arg)
 	fprintf(f, "mirred (%s to device %s)", mirred_n2a(p->eaction), dev);
 	print_action_control(f, " ", p->action, "");
 
+	if (tb[TCA_MIRRED_TC_MAP]) {
+		tc = RTA_DATA(tb[TCA_MIRRED_TC_MAP]);
+		fprintf(f, " tc %d", *tc);
+	}
+
 	fprintf(f, "\n ");
 	fprintf(f, "\tindex %u ref %d bind %d", p->index, p->refcnt,
 		p->bindcnt);
