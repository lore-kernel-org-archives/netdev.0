From: Shuya MAEDA <maeda-sxb@necst.nec.co.jp>
Subject: Re: [PKT_SCHED]: PSCHED_TADD() and PSCHED_TADD2() can result,tv_usec
 >= 1000000
Date: Wed, 21 Jun 2006 09:16:03 +0900
Message-ID: <44988FC3.5030300@necst.nec.co.jp>
References: <449637EE.4020608@necst.nec.co.jp> <20060619.235105.82052619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:14297 "EHLO
	tyo202.gate.nec.co.jp") by vger.kernel.org with ESMTP
	id S1751153AbWFUAQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 20:16:09 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060619.235105.82052619.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for the comment.
I made the patch that used the loop instead of the divide and modulus.
Are there any comments?

David Miller wrote:
> From: Shuya MAEDA <maeda-sxb@necst.nec.co.jp>
> Date: Mon, 19 Jun 2006 14:36:46 +0900
> 
>>  #define PSCHED_TADD2(tv, delta, tv_res) \
>>  ({ \
>> -          int __delta = (tv).tv_usec + (delta); \
>> -          (tv_res).tv_sec = (tv).tv_sec; \
>> -          if (__delta > USEC_PER_SEC) { (tv_res).tv_sec++; __delta -= USEC_PER_SEC; } \
>> -          (tv_res).tv_usec = __delta; \
>> +          int __delta = (delta); \
>> +          (tv_res) = (tv); \
>> +          if((delta) > USEC_PER_SEC) { \
>> +                (tv_res).tv_sec += (delta) / USEC_PER_SEC; \
>> +                __delta -= (delta) % USEC_PER_SEC; \
>> +          } \
>> +          (tv_res).tv_usec += __delta; \
>> +          if((tv_res).tv_usec >= USEC_PER_SEC) { \
>> +                (tv_res).tv_sec++; \
>> +                (tv_res).tv_usec -= USEC_PER_SEC; \
>> +          } \
>>  })
> 
> Divide and modulus can be extremely expensive on some systems, so
> let's try to avoid using them.
> 
> It is probably sufficient to adjust the passed in delta only once if
> it is >= USEC_PER_SEC, but if you feel that is an unsafe assumption
> then please use a simply loop like this:
> 
> 	while (__delta >= USEC_PER_SEC) {
> 		(tv_res).tv_sec++;
> 		__delta -= USEC_PER_SEC;
> 	}
> 
> And please provide a proper "Signed-off-by: " line in your next
> patch submission.
> 
> Thank you very much.

Signed-off-by: Shuya MAEDA <maeda-sxb@necst.nec.co.jp>

diff -Nur linux-2.6.17.orig/include/net/pkt_sched.h linux-2.6.17.mypatch/include/net/pkt_sched.h
--- linux-2.6.17.orig/include/net/pkt_sched.h   2006-06-18 10:49:35.000000000 +0900
+++ linux-2.6.17.mypatch/include/net/pkt_sched.h        2006-06-20 17:17:34.000000000 +0900
@@ -169,17 +169,23 @@

  #define PSCHED_TADD2(tv, delta, tv_res) \
  ({ \
-          int __delta = (tv).tv_usec + (delta); \
-          (tv_res).tv_sec = (tv).tv_sec; \
-          if (__delta > USEC_PER_SEC) { (tv_res).tv_sec++; __delta -= USEC_PER_SEC; } \
+          int __delta = (delta); \
+          (tv_res) = (tv); \
+          while(__delta >= USEC_PER_SEC){ \
+                (tv_res).tv_sec++; \
+                __delta -= USEC_PER_SEC; \
+          } \
            (tv_res).tv_usec = __delta; \
  })

  #define PSCHED_TADD(tv, delta) \
  ({ \
-          (tv).tv_usec += (delta); \
-          if ((tv).tv_usec > USEC_PER_SEC) { (tv).tv_sec++; \
-                (tv).tv_usec -= USEC_PER_SEC; } \
+          int __delta = (delta); \
+          while(__delta >= USEC_PER_SEC){ \
+                (tv).tv_sec++; \
+                __delta -= USEC_PER_SEC; \
+          } \
+          (tv).tv_usec = __delta; \
  })

  /* Set/check that time is in the "past perfect";

-- 
Shuya MAEDA
