From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH V2] sch_red: fix red_calc_qavg_from_idle_time
Date: Wed, 30 Nov 2011 23:10:53 +0100
Message-ID: <1322691053.2602.24.camel@edumazet-laptop>
References: <1322688891.2602.15.camel@edumazet-laptop>
	 <1322689213.2602.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David =?ISO-8859-1?Q?T=E4ht?= <dave.taht@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51176 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab1K3WK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 17:10:59 -0500
Received: by eaak14 with SMTP id k14so1290799eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 14:10:58 -0800 (PST)
In-Reply-To: <1322689213.2602.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit a4a710c4a7490587 (pkt_sched: Change PSCHED_SHIFT from 10 to
6) it seems RED/GRED are broken.

red_calc_qavg_from_idle_time() computes a delay in us units, but this
delay is now 16 times bigger than real delay, so the final qavg result
smaller than expected.

Use standard kernel time services since there is no need to obfuscate
them.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/red.h |   15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/include/net/red.h b/include/net/red.h
index 3319f16..b72a3b8 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -116,7 +116,7 @@ struct red_parms {
 	u32		qR;		/* Cached random number */
 
 	unsigned long	qavg;		/* Average queue length: A scaled */
-	psched_time_t	qidlestart;	/* Start of current idle period */
+	ktime_t		qidlestart;	/* Start of current idle period */
 };
 
 static inline u32 red_rmask(u8 Plog)
@@ -148,17 +148,17 @@ static inline void red_set_parms(struct red_parms *p,
 
 static inline int red_is_idling(struct red_parms *p)
 {
-	return p->qidlestart != PSCHED_PASTPERFECT;
+	return p->qidlestart.tv64 != 0;
 }
 
 static inline void red_start_of_idle_period(struct red_parms *p)
 {
-	p->qidlestart = psched_get_time();
+	p->qidlestart = ktime_get();
 }
 
 static inline void red_end_of_idle_period(struct red_parms *p)
 {
-	p->qidlestart = PSCHED_PASTPERFECT;
+	p->qidlestart.tv64 = 0;
 }
 
 static inline void red_restart(struct red_parms *p)
@@ -170,13 +170,10 @@ static inline void red_restart(struct red_parms *p)
 
 static inline unsigned long red_calc_qavg_from_idle_time(struct red_parms *p)
 {
-	psched_time_t now;
-	long us_idle;
+	s64 delta = ktime_us_delta(ktime_get(), p->qidlestart);
+	long us_idle = min_t(s64, delta, p->Scell_max);
 	int  shift;
 
-	now = psched_get_time();
-	us_idle = psched_tdiff_bounded(now, p->qidlestart, p->Scell_max);
-
 	/*
 	 * The problem: ideally, average length queue recalcultion should
 	 * be done over constant clock intervals. This is too expensive, so
