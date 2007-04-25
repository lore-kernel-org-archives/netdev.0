From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Tue, 24 Apr 2007 18:39:20 -0700
Message-ID: <20070425013920.6031.30149.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com, davem@davemloft.net
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1895 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161828AbXDYBWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 21:22:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Modified tc so PRIO can now have a multiqueue parameter passed to it.  This
will turn on multiqueue behavior if a device has more than 1 queue.  Also,
running tc qdisc ls dev <dev> will display if multiqueue is on or off.

Signed-off-by: Peter P. Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/pkt_sched.h |    1 +
 tc/q_prio.c               |    9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d10f353..bab0b9e 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -99,6 +99,7 @@ struct tc_prio_qopt
 {
 	int	bands;			/* Number of bands */
 	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
+	unsigned short multiqueue;	/* 0 for no mq, 1 for mq */
 };
 
 /* TBF section */
diff --git a/tc/q_prio.c b/tc/q_prio.c
index d696e1b..55cb207 100644
--- a/tc/q_prio.c
+++ b/tc/q_prio.c
@@ -29,7 +29,7 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... prio bands NUMBER priomap P1 P2...\n");
+	fprintf(stderr, "Usage: ... prio [multiqueue] bands NUMBER priomap P1 P2...\n");
 }
 
 #define usage() return(-1)
@@ -39,7 +39,7 @@ static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 	int ok=0;
 	int pmap_mode = 0;
 	int idx = 0;
-	struct tc_prio_qopt opt={3,{ 1, 2, 2, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 }};
+	struct tc_prio_qopt opt={3,{ 1, 2, 2, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 },0};
 
 	while (argc > 0) {
 		if (strcmp(*argv, "bands") == 0) {
@@ -57,7 +57,9 @@ static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 				return -1;
 			}
 			pmap_mode = 1;
-		} else if (strcmp(*argv, "help") == 0) {
+		} else if (strcmp(*argv, "multiqueue") == 0)
+			opt.multiqueue = 1;
+		else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
 		} else {
@@ -105,6 +107,7 @@ int prio_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (RTA_PAYLOAD(opt)  < sizeof(*qopt))
 		return -1;
 	qopt = RTA_DATA(opt);
+	fprintf(f, "multiqueue %s  ", qopt->multiqueue ? "on" : "off");
 	fprintf(f, "bands %u priomap ", qopt->bands);
 	for (i=0; i<=TC_PRIO_MAX; i++)
 		fprintf(f, " %d", qopt->priomap[i]);

