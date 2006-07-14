From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Patch "[PKT_SCHED]: PSCHED_TADD() and PSCHED_TADD2() can result,tv_usec
 >= 1000000" seems wrong
Date: Fri, 14 Jul 2006 16:17:16 +0200
Message-ID: <44B7A76C.4010703@yahoo.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020204080601010805040703"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g19.free.fr ([212.27.42.36]:48019 "EHLO smtp6-g19.free.fr")
	by vger.kernel.org with ESMTP id S1161107AbWGNOQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 10:16:17 -0400
To: Shuya MAEDA <maeda-sxb@necst.nec.co.jp>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020204080601010805040703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

This patch:
http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=4ee303dfeac6451b402e3d8512723d3a0f861857

looks wrong.

In PSCHED_TADD2, if delta is less than tv.tv_usec (so, less than 
USEC_PER_SEC too) then tv_res will be before tv. The
affectation (tv_res).tv_usec = __delta; is wrong. The same applies to 
PSCHED_TADD.

I think the correct fix is simply to restore the original code and 
change the 'if' in a 'while'.

So here are two patches for the two possible solutions :

o Reverting the commit and applying from_before_patch_to_correct.diff

o Applying from_tip_to_correct.diff


Thanks.


-- 
Guillaume


--------------020204080601010805040703
Content-Type: text/x-patch;
 name="from_before_patch_to_correct.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="from_before_patch_to_correct.diff"

--- a/include/net/pkt_sched.h.before	2006-07-14 15:58:53.000000000 +0200
+++ b/include/net/pkt_sched.h	2006-07-14 15:59:10.000000000 +0200
@@ -171,14 +171,14 @@
 ({ \
 	   int __delta = (tv).tv_usec + (delta); \
 	   (tv_res).tv_sec = (tv).tv_sec; \
-	   if (__delta > USEC_PER_SEC) { (tv_res).tv_sec++; __delta -= USEC_PER_SEC; } \
+	   while (__delta > USEC_PER_SEC) { (tv_res).tv_sec++; __delta -= USEC_PER_SEC; } \
 	   (tv_res).tv_usec = __delta; \
 })
 
 #define PSCHED_TADD(tv, delta) \
 ({ \
 	   (tv).tv_usec += (delta); \
-	   if ((tv).tv_usec > USEC_PER_SEC) { (tv).tv_sec++; \
+	   while ((tv).tv_usec > USEC_PER_SEC) { (tv).tv_sec++; \
 		 (tv).tv_usec -= USEC_PER_SEC; } \
 })

--  
Signed-off-by: Guillaume Chazarain <guichaz@yahoo.fr>

--------------020204080601010805040703
Content-Type: text/x-patch;
 name="from_tip_to_correct.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="from_tip_to_correct.diff"

diff -r 672dc37bf355 include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	Fri Jul 14 06:57:04 2006 +0700
+++ b/include/net/pkt_sched.h	Fri Jul 14 15:58:04 2006 +0200
@@ -169,23 +169,17 @@ psched_tod_diff(int delta_sec, int bound
 
 #define PSCHED_TADD2(tv, delta, tv_res) \
 ({ \
-	   int __delta = (delta); \
-	   (tv_res) = (tv); \
-	   while(__delta >= USEC_PER_SEC){ \
-		 (tv_res).tv_sec++; \
-		 __delta -= USEC_PER_SEC; \
-	   } \
+	   int __delta = (tv).tv_usec + (delta); \
+	   (tv_res).tv_sec = (tv).tv_sec; \
+	   while (__delta > USEC_PER_SEC) { (tv_res).tv_sec++; __delta -= USEC_PER_SEC; } \
 	   (tv_res).tv_usec = __delta; \
 })
 
 #define PSCHED_TADD(tv, delta) \
 ({ \
-	   int __delta = (delta); \
-	   while(__delta >= USEC_PER_SEC){ \
-		 (tv).tv_sec++; \
-		 __delta -= USEC_PER_SEC; \
-	   } \
-	   (tv).tv_usec = __delta; \
+	   (tv).tv_usec += (delta); \
+	   while ((tv).tv_usec > USEC_PER_SEC) { (tv).tv_sec++; \
+		 (tv).tv_usec -= USEC_PER_SEC; } \
 })
 
 /* Set/check that time is in the "past perfect";

-- 
Signed-off-by: Guillaume Chazarain <guichaz@yahoo.fr>


--------------020204080601010805040703--
