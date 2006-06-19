From: Shuya MAEDA <maeda-sxb@necst.nec.co.jp>
Subject: [PATCH] [PKT_SCHED]: PSCHED_TADD() and PSCHED_TADD2() can result,tv_usec
 >= 1000000
Date: Mon, 19 Jun 2006 16:05:05 +0900
Message-ID: <44964CA1.8020505@necst.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:32203 "EHLO
	tyo202.gate.nec.co.jp") by vger.kernel.org with ESMTP
	id S932206AbWFSHFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 03:05:07 -0400
Received: from mailgate3.nec.co.jp (mailgate54.nec.co.jp [10.7.69.193])
	by tyo202.gate.nec.co.jp (8.13.7/8.13.4) with ESMTP id k5J756pf001395
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 16:05:06 +0900 (JST)
Received: (from root@localhost) by mailgate3.nec.co.jp (8.11.7/3.7W-MAILGATE-NEC)
	id k5J756C04436 for netdev@vger.kernel.org; Mon, 19 Jun 2006 16:05:06 +0900 (JST)
Received: from togyo.jp.nec.com (togyo.jp.nec.com [10.26.220.4]) by mailsv3.nec.co.jp (8.11.7/3.7W-MAILSV4-NEC) with ESMTP
	id k5J755G13555 for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 16:05:05 +0900 (JST)
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found two problems in PSCHED_TADD() and PSCHED_TADD2().

1) These function increment tv_sec if tv_usec > 1000000.
   But I think it should "if tv_usec >= 1000000".

2) tv_usec became 1200000 or more when I used CBQ and
   experimented it. It is not correct to exceed 1000000
   because tv_usec is micro seconds.
   To fix 2), I think that it should do "delta / 1000000",
   add the quotient to tv_sec, and add the remainder to
   tv_usec.

In both cases, because time when the transmission is restarted
reaches an illegal value, it is not possible to communicate at
the set rate.

To fix these problem I create following patch.
Are there any comments?

[Experiment]
  * kernel: linux-2.6.15.5
  * CBQ settings
   ----------------------------------------------------------
   tc qdisc add dev $IF root handle 1:0 cbq bandwidth 100Mbit \
	avpkt 1000 mpu 64 ewma 5 cell 8
   tc class add dev $IF parent 1:0 classid 1:10 cbq rate 32Kbit \
	prio 1 ewma 5 cell 8 avpkt 138 mpu 64 bandwidth 100Mbit \
	minburst 25 maxburst 50 bounded isolated
   tc filter add dev $IF parent 1:0 protocol ip prio 16 u32 match \
	ip dport 4952 0xffff flowid 1:10
   -----------------------------------------------------------
  * Traffic
    dst port 4952: 138byte per 20msec.

[Result]
  * In cbq_ovl_classic():
    cl->undertime = { tv_sec = 1150368540, tv_usec = 1208301 }
                                           ~~~~~~~~~~~~~~~~~~
    q->now        = { tv_sec = 1150368539, tv_usec = 878917 }
    delay         = 1329384
    cl->avgidle   = -14781
    cl->offtime   = 1295394

[Patch]
diff -Nur linux-2.6.17-rc6.orig/include/net/pkt_sched.h linux-2.6.17-rc6.mypatch/include/net/pkt_sched.h
--- linux-2.6.17-rc6.orig/include/net/pkt_sched.h       2006-06-06 09:57:02.000000000 +0900
+++ linux-2.6.17-rc6.mypatch/include/net/pkt_sched.h    2006-06-16 11:29:08.000000000 +0900
@@ -169,17 +169,31 @@

 #define PSCHED_TADD2(tv, delta, tv_res) \
 ({ \
-          int __delta = (tv).tv_usec + (delta); \
-          (tv_res).tv_sec = (tv).tv_sec; \
-          if (__delta > USEC_PER_SEC) { (tv_res).tv_sec++; __delta -= USEC_PER_SEC; } \
-          (tv_res).tv_usec = __delta; \
+          int __delta = (delta); \
+          (tv_res) = (tv); \
+          if((delta) > USEC_PER_SEC) { \
+                (tv_res).tv_sec += (delta) / USEC_PER_SEC; \
+                __delta -= (delta) % USEC_PER_SEC; \
+          } \
+          (tv_res).tv_usec += __delta; \
+          if((tv_res).tv_usec >= USEC_PER_SEC) { \
+                (tv_res).tv_sec++; \
+                (tv_res).tv_usec -= USEC_PER_SEC; \
+          } \
 })

 #define PSCHED_TADD(tv, delta) \
 ({ \
-          (tv).tv_usec += (delta); \
-          if ((tv).tv_usec > USEC_PER_SEC) { (tv).tv_sec++; \
-                (tv).tv_usec -= USEC_PER_SEC; } \
+          int __delta = (delta); \
+          if((delta) > USEC_PER_SEC) { \
+                (tv).tv_sec += (delta) / USEC_PER_SEC; \
+                __delta -= (delta) % USEC_PER_SEC; \
+          } \
+          (tv).tv_usec += __delta; \
+          if((tv).tv_usec >= USEC_PER_SEC) { \
+                (tv).tv_sec++; \
+                (tv).tv_usec -= USEC_PER_SEC; \
+          } \
 })

 /* Set/check that time is in the "past perfect";
-- 
Shuya Maeda
