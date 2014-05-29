From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH iproute2 v4] fq: allow options of fair queue set to ~0U
Date: Thu, 29 May 2014 12:04:34 +0800
Message-ID: <5386B1D2.3030804@huawei.com>
References: <1399868319-2184-1-git-send-email-yangyingliang@huawei.com>	<1399874336.7973.17.camel@edumazet-glaptop2.roam.corp.google.com>	<5370713F.7040701@huawei.com>	<1399908225.7973.25.camel@edumazet-glaptop2.roam.corp.google.com>	<53718221.6040909@huawei.com>	<53719DA4.1010300@huawei.com> <20140528170957.19b50c12@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:16249 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173AbaE2EEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 00:04:51 -0400
In-Reply-To: <20140528170957.19b50c12@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>

Some options of fair queue cannot be (~0U). It leads to maxrate
cannot be reset to unlimited because it cannot be (~0U). Allow
the options being ~0U.

Tested by the following command:
 # tc qdisc add dev eth4 root handle 1: fq limit 2000 flow_limit 200 maxrate 100mbit quantum 2000 initial_quantum 1600
 # tc -s -d qdisc show
qdisc fq 1: dev eth4 root refcnt 2 limit 2000p flow_limit 200p buckets 1024 quantum 2000 initial_quantum 1600 maxrate 100Mbit 
 Sent 1492 bytes 10 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  1 flows (0 inactive, 0 throttled)
  0 gc, 0 highprio, 0 throttled

 # tc qdisc change dev eth4 root handle 1: fq limit 4294967295 flow_limit 4294967295 maxrate 34359738360 quantum 4294967295 initial_quantum 4294967295
 # tc -s -d qdisc show
qdisc fq 1: dev eth4 root refcnt 2 limit 4294967295p flow_limit 4294967295p buckets 1024 quantum 4294967295 initial_quantum 4294967295 
 Sent 38372 bytes 216 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  2 flows (1 inactive, 0 throttled)
  0 gc, 2 highprio, 7 throttled

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

---
Change note:

 v3 -> v4: Change boolean flags from 'int' to 'bool'.
---
 tc/q_fq.c | 37 +++++++++++++++++++++++++------------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/tc/q_fq.c b/tc/q_fq.c
index c1f658e..e7288c2 100644
--- a/tc/q_fq.c
+++ b/tc/q_fq.c
@@ -44,6 +44,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
+#include <stdbool.h>
 
 #include "utils.h"
 #include "tc_util.h"
@@ -71,13 +72,19 @@ static unsigned int ilog2(unsigned int val)
 static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			struct nlmsghdr *n)
 {
-	unsigned int plimit = ~0U;
-	unsigned int flow_plimit = ~0U;
-	unsigned int quantum = ~0U;
-	unsigned int initial_quantum = ~0U;
+	unsigned int plimit;
+	unsigned int flow_plimit;
+	unsigned int quantum;
+	unsigned int initial_quantum;
 	unsigned int buckets = 0;
-	unsigned int maxrate = ~0U;
-	unsigned int defrate = ~0U;
+	unsigned int maxrate;
+	unsigned int defrate;
+	bool set_plimit = false;
+	bool set_flow_plimit = false;
+	bool set_quantum = false;
+	bool set_initial_quantum = false;
+	bool set_maxrate = false;
+	bool set_defrate = false;
 	int pacing = -1;
 	struct rtattr *tail;
 
@@ -88,12 +95,14 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				fprintf(stderr, "Illegal \"limit\"\n");
 				return -1;
 			}
+			set_plimit = true;
 		} else if (strcmp(*argv, "flow_limit") == 0) {
 			NEXT_ARG();
 			if (get_unsigned(&flow_plimit, *argv, 0)) {
 				fprintf(stderr, "Illegal \"flow_limit\"\n");
 				return -1;
 			}
+			set_flow_plimit = true;
 		} else if (strcmp(*argv, "buckets") == 0) {
 			NEXT_ARG();
 			if (get_unsigned(&buckets, *argv, 0)) {
@@ -106,24 +115,28 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				fprintf(stderr, "Illegal \"maxrate\"\n");
 				return -1;
 			}
+			set_maxrate = true;
 		} else if (strcmp(*argv, "defrate") == 0) {
 			NEXT_ARG();
 			if (get_rate(&defrate, *argv)) {
 				fprintf(stderr, "Illegal \"defrate\"\n");
 				return -1;
 			}
+			set_defrate = true;
 		} else if (strcmp(*argv, "quantum") == 0) {
 			NEXT_ARG();
 			if (get_unsigned(&quantum, *argv, 0)) {
 				fprintf(stderr, "Illegal \"quantum\"\n");
 				return -1;
 			}
+			set_quantum = true;
 		} else if (strcmp(*argv, "initial_quantum") == 0) {
 			NEXT_ARG();
 			if (get_unsigned(&initial_quantum, *argv, 0)) {
 				fprintf(stderr, "Illegal \"initial_quantum\"\n");
 				return -1;
 			}
+			set_initial_quantum = true;
 		} else if (strcmp(*argv, "pacing") == 0) {
 			pacing = 1;
 		} else if (strcmp(*argv, "nopacing") == 0) {
@@ -147,24 +160,24 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		addattr_l(n, 1024, TCA_FQ_BUCKETS_LOG,
 			  &log, sizeof(log));
 	}
-	if (plimit != ~0U)
+	if (set_plimit)
 		addattr_l(n, 1024, TCA_FQ_PLIMIT,
 			  &plimit, sizeof(plimit));
-	if (flow_plimit != ~0U)
+	if (set_flow_plimit)
 		addattr_l(n, 1024, TCA_FQ_FLOW_PLIMIT,
 			  &flow_plimit, sizeof(flow_plimit));
-	if (quantum != ~0U)
+	if (set_quantum)
 		addattr_l(n, 1024, TCA_FQ_QUANTUM, &quantum, sizeof(quantum));
-	if (initial_quantum != ~0U)
+	if (set_initial_quantum)
 		addattr_l(n, 1024, TCA_FQ_INITIAL_QUANTUM,
 			  &initial_quantum, sizeof(initial_quantum));
 	if (pacing != -1)
 		addattr_l(n, 1024, TCA_FQ_RATE_ENABLE,
 			  &pacing, sizeof(pacing));
-	if (maxrate != ~0U)
+	if (set_maxrate)
 		addattr_l(n, 1024, TCA_FQ_FLOW_MAX_RATE,
 			  &maxrate, sizeof(maxrate));
-	if (defrate != ~0U)
+	if (set_defrate)
 		addattr_l(n, 1024, TCA_FQ_FLOW_DEFAULT_RATE,
 			  &defrate, sizeof(defrate));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
