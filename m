From: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Subject: Re: Question about QOS
Date: Wed, 27 Apr 2005 09:44:48 +0200
Message-ID: <426F42F0.9020609@6wind.com>
References: <426E06F1.9000105@6wind.com> <20050426125955.GT577@postel.suug.ch> <426E56DC.7000108@6wind.com> <20050426191454.GU577@postel.suug.ch>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000304030909050602090302"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050426191454.GU577@postel.suug.ch>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000304030909050602090302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


>Yes I agree, it doesn't really matter what value we return and `bound'
>is most likely to be correct. I think we should also fix the unlikely
>but still possible case when tv1.tv_usec is slightly smaller than
>tv2.tv_usec. I know it is very unlikely but do_gettimeofday really
>is not that reliable and we have users which rely on a positive
>delta. Can you extend your patch to return abs(delta) for case 0
>in PSCHED_TDIFF_SAFE?
>-
>To unsubscribe from this list: send the line "unsubscribe linux-net" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  
>
You're right. Here is the new patch.

[SCHED] Fix range in PSCHED_TDIFF_SAFE to 0..bound

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>


--------------000304030909050602090302
Content-Type: text/plain;
 name="x.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.diff"

diff -Nru linux-2.6-a/include/net/pkt_sched.h linux-2.6-b/include/net/pkt_sched.h
--- linux-2.6-a/include/net/pkt_sched.h	2005-04-26 15:45:07.000000000 +0200
+++ linux-2.6-b/include/net/pkt_sched.h	2005-04-27 09:36:23.421634576 +0200
@@ -140,7 +140,7 @@
 	if (bound <= 1000000 || delta_sec > (0x7FFFFFFF/1000000)-1)
 		return bound;
 	delta = delta_sec * 1000000;
-	if (delta > bound)
+	if (delta > bound || delta < 0)
 		delta = bound;
 	return delta;
 }
@@ -156,7 +156,8 @@
 		   __delta += 1000000; \
 	   case 1: \
 		   __delta += 1000000; \
-	   case 0: ; \
+	   case 0: \
+		   __delta = abs(__delta); \
 	   } \
 	   __delta; \
 })

--------------000304030909050602090302--
