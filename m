From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: Patch "[PKT_SCHED]: PSCHED_TADD() and PSCHED_TADD2() can result,tv_usec
 >= 1000000" seems wrong
Date: Wed, 19 Jul 2006 14:47:34 +0200
Message-ID: <44BE29E6.1060602@yahoo.fr>
References: <44B7A76C.4010703@yahoo.fr> <44BDE3F7.4000507@necst.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060908080301010507000802"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sophia.inria.fr ([138.96.64.20]:38529 "EHLO sophia.inria.fr")
	by vger.kernel.org with ESMTP id S964814AbWGSMsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 08:48:17 -0400
To: Shuya MAEDA <maeda-sxb@necst.nec.co.jp>
In-Reply-To: <44BDE3F7.4000507@necst.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060908080301010507000802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Shuya MAEDA wrote :
> "while (__delta > USEC_PER_SEC){ ... }", but I think it should be
> "while (__delta >= USEC_PER_SEC){ ... }". Is it right?

I agree, good catch :-)

Thanks.

-- 
Guillaume


--------------060908080301010507000802
Content-Type: text/x-patch;
 name="fix_psched_tadd.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix_psched_tadd.diff"

In PSCHED_TADD and PSCHED_TADD2, if delta is less than tv.tv_usec (so, less
than USEC_PER_SEC too) then tv_res will be smaller than tv. The
affectation "(tv_res).tv_usec = __delta;" is wrong.
The fix is to revert to the original code before
4ee303dfeac6451b402e3d8512723d3a0f861857 and change the 'if' in 'while'.

[Shuya MAEDA: "while (__delta >= USEC_PER_SEC){ ... }" instead of
"while (__delta > USEC_PER_SEC){ ... }"]

Signed-off-by: Guillaume Chazarain <guichaz@yahoo.fr>
---

 pkt_sched.h |   18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
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
+	   while (__delta >= USEC_PER_SEC) { (tv_res).tv_sec++; __delta -= USEC_PER_SEC; } \
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
+	   while ((tv).tv_usec >= USEC_PER_SEC) { (tv).tv_sec++; \
+		 (tv).tv_usec -= USEC_PER_SEC; } \
 })
 
 /* Set/check that time is in the "past perfect";

--------------060908080301010507000802--
