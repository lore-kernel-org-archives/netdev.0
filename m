From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) packet scheduler -- use get_jiffies_64
Date: Tue, 29 Jun 2004 14:00:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629140021.367695ff@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The packet scheduler simulates 64 bit jiffies on 32 bit platforms by running
a timer keeping a mark and and offset.  Since there is no locking and this is
racy and doesn't handle jiffie wrap real well.

We can use get_jiffies_64 on 2.6 do get what is needed.
The downside is the overhead of a function call, and a cache miss in get_jiffies_64.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2004-06-29 11:33:37 -07:00
+++ b/include/net/pkt_sched.h	2004-06-29 11:33:37 -07:00
@@ -231,20 +231,7 @@
 #define PSCHED_JSCALE 10
 #endif
 
-#if BITS_PER_LONG <= 32
-
-#define PSCHED_WATCHER unsigned long
-
-extern PSCHED_WATCHER psched_time_mark;
-
-#define PSCHED_GET_TIME(stamp) ((stamp) = psched_time_base + (((unsigned long)(jiffies-psched_time_mark))<<PSCHED_JSCALE))
-
-#else
-
-#define PSCHED_GET_TIME(stamp) ((stamp) = (jiffies<<PSCHED_JSCALE))
-
-#endif
-
+#define PSCHED_GET_TIME(stamp) ((stamp) = (get_jiffies_64()<<PSCHED_JSCALE))
 #define PSCHED_US2JIFFIE(delay) (((delay)+(1<<PSCHED_JSCALE)-1)>>PSCHED_JSCALE)
 #define PSCHED_JIFFIE2US(delay) ((delay)<<PSCHED_JSCALE)
 
