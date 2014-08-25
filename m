From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] nstat: 64bit support on 32bit arches
Date: Mon, 25 Aug 2014 07:27:54 -0700
Message-ID: <1408976874.5604.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:37545 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932492AbaHYO17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:27:59 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so19702513pdj.8
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 07:27:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

SNMP counters can be provided as 64bit numbers.
nstat needs to cope with this even if running in 32bit mode.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 misc/nstat.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/misc/nstat.c b/misc/nstat.c
index d3f8621..e54b3ae 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -77,7 +77,6 @@ struct nstat_ent
 	struct nstat_ent *next;
 	char		 *id;
 	unsigned long long val;
-	unsigned long	   ival;
 	double		   rate;
 };
 
@@ -143,7 +142,6 @@ static void load_good_table(FILE *fp)
 		if ((n = malloc(sizeof(*n))) == NULL)
 			abort();
 		n->id = strdup(idbuf);
-		n->ival = (unsigned long)val;
 		n->val = val;
 		n->rate = rate;
 		n->next = db;
@@ -206,9 +204,8 @@ static void load_ugly_table(FILE *fp)
 			if (!p)
 				abort();
 			*p = 0;
-			if (sscanf(p+1, "%lu", &n->ival) != 1)
+			if (sscanf(p+1, "%llu", &n->val) != 1)
 				abort();
-			n->val = n->ival;
 			/* Trick to skip "dummy" trailing ICMP MIB in 2.4 */
 			if (strcmp(idbuf, "IcmpOutAddrMaskReps") == 0)
 				idbuf[5] = 0;
@@ -365,10 +362,10 @@ static void update_db(int interval)
 		for (h1 = h; h1; h1 = h1->next) {
 			if (strcmp(h1->id, n->id) == 0) {
 				double sample;
-				unsigned long incr = h1->ival - n->ival;
-				n->val += incr;
-				n->ival = h1->ival;
-				sample = (double)(incr*1000)/interval;
+				unsigned long long incr = h1->val - n->val;
+
+				n->val = h1->val;
+				sample = (double)incr * 1000.0 / interval;
 				if (interval >= scan_interval) {
 					n->rate += W*(sample-n->rate);
 				} else if (interval >= 1000) {
