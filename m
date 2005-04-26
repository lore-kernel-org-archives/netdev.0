From: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Subject: Re: Question about QOS
Date: Tue, 26 Apr 2005 16:57:32 +0200
Message-ID: <426E56DC.7000108@6wind.com>
References: <426E06F1.9000105@6wind.com> <20050426125955.GT577@postel.suug.ch>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040304080005040803070804"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050426125955.GT577@postel.suug.ch>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040304080005040803070804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Thomas Graf wrote:

>* Nicolas DICHTEL <426E06F1.9000105@6wind.com> 2005-04-26 11:16
>  
>
>>I set CONFIG_NET_SCH_CLK_GETTIMEOFDAY in my kernel. The macro 
>>PSCHED_TDIFF_SAFE calculates
>>the difference between two timestamps and uses the function 
>>psched_tod_diff() to do this.
>>If the clock is readjusted (due to ntp for example), this function can 
>>return a negative number
>>(if bound > 1000000) and then the flow is blocked by the kernel. Am I 
>>right ?
>>    
>>
>
>do_gettimeofday takes care of ntp adjustments so we _should_ be safe,
>however, it might be wise to enforce a range of 0..bound instead of
>INT_MIN..bound because qdiscs like red are relying on this. Assuming
>we have a delta of -4 seconds and return -4e6 red will horribly
>crash when acccessing the array with idle_time>>cell_log.
>
>  
>
You can have the same kind of problem with a ingress filter. I propose the
following patch to fix the range to 0..bound

[SCHED] Fix range in psched_tod_diff() to 0..bound

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>


--------------040304080005040803070804
Content-Type: text/plain;
 name="x.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.diff"

diff -Nru linux-2.6-a/include/net/pkt_sched.h linux-2.6-b/include/net/pkt_sched.h
--- linux-2.6-a/include/net/pkt_sched.h	2005-04-26 15:45:07.074124664 +0200
+++ linux-2.6-b/include/net/pkt_sched.h	2005-04-26 15:47:26.215971888 +0200
@@ -140,7 +140,7 @@
 	if (bound <= 1000000 || delta_sec > (0x7FFFFFFF/1000000)-1)
 		return bound;
 	delta = delta_sec * 1000000;
-	if (delta > bound)
+	if (delta > bound || delta < 0)
 		delta = bound;
 	return delta;
 }

--------------040304080005040803070804--
