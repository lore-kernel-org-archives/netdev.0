From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/5] netem: use better types for time values
Date: Wed, 21 Mar 2007 10:42:33 -0700
Message-ID: <20070321174422.564418149@linux-foundation.org>
References: <20070321174231.890361963@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46920 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846AbXCUR6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 13:58:49 -0400
Content-Disposition: inline; filename=netem-typefix.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The random number generator always generates 32 bit values.
The time values are limited by psched_tdiff_t

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/sched/sch_netem.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

--- net-2.6.22.orig/net/sched/sch_netem.c
+++ net-2.6.22/net/sched/sch_netem.c
@@ -56,19 +56,20 @@ struct netem_sched_data {
 	struct Qdisc	*qdisc;
 	struct qdisc_watchdog watchdog;
 
-	u32 latency;
+	psched_tdiff_t latency;
+	psched_tdiff_t jitter;
+
 	u32 loss;
 	u32 limit;
 	u32 counter;
 	u32 gap;
-	u32 jitter;
 	u32 duplicate;
 	u32 reorder;
 	u32 corrupt;
 
 	struct crndstate {
-		unsigned long last;
-		unsigned long rho;
+		u32 last;
+		u32 rho;
 	} delay_cor, loss_cor, dup_cor, reorder_cor, corrupt_cor;
 
 	struct disttable {
@@ -95,7 +96,7 @@ static void init_crandom(struct crndstat
  * Next number depends on last value.
  * rho is scaled to avoid floating point.
  */
-static unsigned long get_crandom(struct crndstate *state)
+static u32 get_crandom(struct crndstate *state)
 {
 	u64 value, rho;
 	unsigned long answer;
@@ -114,11 +115,13 @@ static unsigned long get_crandom(struct 
  * std deviation sigma.  Uses table lookup to approximate the desired
  * distribution, and a uniformly-distributed pseudo-random source.
  */
-static long tabledist(unsigned long mu, long sigma,
-		      struct crndstate *state, const struct disttable *dist)
-{
-	long t, x;
-	unsigned long rnd;
+static psched_tdiff_t tabledist(psched_tdiff_t mu, psched_tdiff_t sigma,
+				struct crndstate *state,
+				const struct disttable *dist)
+{
+	psched_tdiff_t x;
+	long t;
+	u32 rnd;
 
 	if (sigma == 0)
 		return mu;

-- 

