From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [PATCH] pktgen divides by zero on short runs
Date: Thu, 4 Sep 2003 23:27:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904232713.7dd4e99f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Fri, 5 Sep 2003 01:40:27 -0400 (EDT)
From: Najati Imam <najati@netlab.uky.edu>
To: linux-kernel@vger.kernel.org
Subject: [PATCH] pktgen divides by zero on short runs


On very short runs when computing the packets per second the time that is
used can be zero. For small packets this can happen with as many as 100,
maybe more, packets. The patch below checks the denominator before
dividing and if it is zero puts a notice in the results output that
explains why pbs, bps and mbps are all zero, like so

Result: OK: 10(c10+d0) usec, 1 (64byte,0frags) 0pps 0Mb/sec (0bps) \
  (Time too short to measure) errors: 0

Hope this hasn't already been addressed (it was present in 2.6.0-test4,
which is what I generated the patch from), also this is my first
submission, so if I did it all wrong, I will accept the appropriate
punishment.

Najati Imam




diff -urN linux-2.6.0-test4/net/core/pktgen.c linux-2.6.0-test4-nri/net/core/pktgen.c
--- linux-2.6.0-test4/net/core/pktgen.c 2003-08-22 19:57:49.000000000 -0400
+++ linux-2.6.0-test4-nri/net/core/pktgen.c     2003-09-05 01:15:20.000000000 -0400
@@ -50,6 +50,9 @@
  * Fix refcount off by one if first packet fails, potential null deref, 
  * memleak 030710- KJP
  *
+ * Check for potential div by zero in the event of a really short send time
+ * 030905 NRI 
+ *
  * See Documentation/networking/pktgen.txt for how to use this.
  */
 
@@ -720,9 +723,10 @@
 
        {
                char *p = info->result;
-               __u64 pps = (__u32)(info->sofar * 1000) / ((__u32)(total) / 1000);
+               __u32 tt = ((__u32)(total) / 1000);
+               __u64 pps = (tt) ? (__u32)(info->sofar * 1000) / ((__u32)(total) / 1000) : 0;
                __u64 bps = pps * 8 * (info->pkt_size + 4); /* take 32bit ethernet CRC into account */
-               p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags) %llupps %lluMb/sec (%llubps)  errors: %llu",
+               p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags) %llupps %lluMb/sec (%llubps) %s errors: %llu",
                             (unsigned long long) total,
                             (unsigned long long) (total - idle),
                             (unsigned long long) idle,
@@ -732,6 +736,7 @@
                             (unsigned long long) pps,
                             (unsigned long long) (bps / (u64) 1024 / (u64) 1024),
                             (unsigned long long) bps,
+                            (tt) ? "" : "(Time too short to measure)",
                             (unsigned long long) info->errors
                             );
        }


