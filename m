From: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Subject: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc -d class show dev <device_name> ' command
Date: Sat, 12 Dec 2015 14:09:39 +0300
Message-ID: <5917221449918579@web5j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jbrouer <jbrouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward10j.cmail.yandex.net ([5.255.227.111]:48122 "EHLO
	forward10j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752753AbbLLLQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 06:16:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I noticed a quite an old change which I have a few questions about so maybe somebody could help me out. There are a few lines of code in tc/q_htb.c which were committed originally back in 2004 and have not changed since related to MPU (Minimum Packet Unit). I asked Stephen - this is probably the code that pre-dated git so I am not sure exactly who to ask:

commit a166d246d84e7d0ba784e210515708006e16a366
Author: osdl.net!shemminger <osdl.net!shemminger>
Date:   Fri Jul 30 20:26:15 2004 +0000

    mpu support

@@ -243,10 +264,16 @@ static int htb_print_opt(struct qdisc_util *qu,
FILE *f, struct rtattr *opt)
            fprintf(f, "ceil %s ", sprint_rate(hopt->ceil.rate, b1));
            cbuffer =
((double)hopt->ceil.rate*tc_core_tick2usec(hopt->cbuffer))/1000000;
            if (show_details) {
-               fprintf(f, "burst %s/%u mpu %s ", sprint_size(buffer, b1),
-                       1<<hopt->rate.cell_log,
sprint_size(hopt->rate.mpu, b2));
-               fprintf(f, "cburst %s/%u mpu %s ", sprint_size(cbuffer, b1),
-                       1<<hopt->ceil.cell_log,
sprint_size(hopt->ceil.mpu, b2));
+               fprintf(f, "burst %s/%u mpu %s overhead %s ",
+                       sprint_size(buffer, b1),
+                       1<<hopt->rate.cell_log,
+                       sprint_size(hopt->rate.mpu&0xFF, b2),
+                       sprint_size((hopt->rate.mpu>>8)&0xFF, b3));
+               fprintf(f, "cburst %s/%u mpu %s overhead %s ",
+                       sprint_size(cbuffer, b1),
+                       1<<hopt->ceil.cell_log,
+                       sprint_size(hopt->ceil.mpu&0xFF, b2),
+                       sprint_size((hopt->ceil.mpu>>8)&0xFF, b3));

I noticed that there is a separate configurable value called 'overhead' in q_htb.c now which does not have anything to do with 'overhead = hopt->rate.mpu>>8)&0xFF' that is being printed out in the above lines:

static void explain(void)
{
    ...
        " overhead per-packet size overhead used in rate computations\n"
    ...

In the code fragment from the commit (for some reason I don't understand) 'rate.mpu' is sliced into two parts called 'mpu' and 'overhead'. So, basically, to retrieve the original MPU value from the output of `tc -d class show dev <device_name>` I need to do the following: real_mpu = mpu + overhead<<8.

I also have a hard time understanding whether it is possible to have a condition where rate.mpu and ceil.mpu have different values - the outputs I have seen always showed the same values for both and I do not see anything in the code that sets them to different values (if so, maybe the duplicate output should be removed).

As a reference, here is a link for a line in tc/q_tbf.c for the same functionality (show_details) that does not have anything like that for the MPU value:
https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/tree/tc/q_tbf.c#n279

|fprintf(f, "burst %s/%u mpu %s ", sprint_size(buffer, b1),|



Please take a look at my patch if you have time for it as this would simplify testing in the project I work on and make the output of the command less ambiguous for other people who may use HTB.

Thank you,
Dmitrii Shcherbakov

>From 26c62f17e1d6ebca9f236000806a63363ab70640 Mon Sep 17 00:00:00 2001
From: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Date: Sat, 12 Dec 2015 02:04:09 +0300
Subject: [PATCH] tc/q_htb.c: Fix the MPU value output in 'tc -d class show dev
 <device_name> ' command

This patch removes slicing of 'rate.mpu' into two parts called 'mpu' and 'overhead' alleviating the need to perform calculations to get the original MPU value after it is configured as follows: real_mpu = mpu + overhead<<8.

Signed-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
---
 tc/q_htb.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/tc/q_htb.c b/tc/q_htb.c
index 7075a4c..f810329 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -274,7 +274,6 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
 	SPRINT_BUF(b3);
-	SPRINT_BUF(b4);
 
 	if (opt == NULL)
 		return 0;
@@ -311,18 +310,16 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		cbuffer = tc_calc_xmitsize(ceil64, hopt->cbuffer);
 		linklayer = (hopt->rate.linklayer & TC_LINKLAYER_MASK);
 		if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
-			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b4));
+			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b3));
 		if (show_details) {
-			fprintf(f, "burst %s/%u mpu %s overhead %s ",
+			fprintf(f, "burst %s/%u mpu %s ",
 				sprint_size(buffer, b1),
 				1<<hopt->rate.cell_log,
-				sprint_size(hopt->rate.mpu&0xFF, b2),
-				sprint_size((hopt->rate.mpu>>8)&0xFF, b3));
-			fprintf(f, "cburst %s/%u mpu %s overhead %s ",
+				sprint_size(hopt->rate.mpu, b2));
+			fprintf(f, "cburst %s/%u mpu %s ",
 				sprint_size(cbuffer, b1),
 				1<<hopt->ceil.cell_log,
-				sprint_size(hopt->ceil.mpu&0xFF, b2),
-				sprint_size((hopt->ceil.mpu>>8)&0xFF, b3));
+				sprint_size(hopt->ceil.mpu, b2));
 			fprintf(f, "level %d ", (int)hopt->level);
 		} else {
 			fprintf(f, "burst %s ", sprint_size(buffer, b1));
-- 
2.5.0
