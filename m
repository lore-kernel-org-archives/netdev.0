From: David Howells <dhowells@redhat.com>
Subject: [PATCH] FRV: do_gettimeofday() should no longer use tickadj
Date: Tue, 05 Sep 2006 16:35:57 +0100
Message-ID: <6260.1157470557@warthog.cambridge.redhat.com>
References: <20060905132530.GD9173@stusta.de>  <20060901015818.42767813.akpm@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965138AbWIEPia@vger.kernel.org>
In-Reply-To: <20060905132530.GD9173@stusta.de> 
To: Adrian Bunk <bunk@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Stop do_gettimeofday() on FRV from using tickadj, and model it after ARM
instead.

This patch also provides a placeholder macro for getting hardware timer data to
be filled in when such is available.

Signed-Off-By: David Howells <dhowells@redhat.com>
---
warthog>diffstat -p1 frv-tickadj-2618rc5mm1.diff 
 arch/frv/kernel/time.c |   20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff -urp ../kernels/linux-2.6.18-rc5-mm1/arch/frv/kernel/time.c linux-2.6.18-rc5-mm1-frv/arch/frv/kernel/time.c
--- ../kernels/linux-2.6.18-rc5-mm1/arch/frv/kernel/time.c	2006-09-04 18:03:14.000000000 +0100
+++ linux-2.6.18-rc5-mm1-frv/arch/frv/kernel/time.c	2006-09-05 15:44:42.000000000 +0100
@@ -31,6 +31,9 @@
 
 #define TICK_SIZE (tick_nsec / 1000)
 
+/* H/W clock data if we can get it (in microseconds) */
+#define FRV_HW_CLOCK_DATA (0)
+
 unsigned long __nongprelbss __clkin_clock_speed_HZ;
 unsigned long __nongprelbss __ext_bus_clock_speed_HZ;
 unsigned long __nongprelbss __res_bus_clock_speed_HZ;
@@ -148,23 +151,10 @@ void do_gettimeofday(struct timeval *tv)
 {
 	unsigned long seq;
 	unsigned long usec, sec;
-	unsigned long max_ntp_tick;
 
 	do {
 		seq = read_seqbegin(&xtime_lock);
-
-		usec = 0;
-
-		/*
-		 * If time_adjust is negative then NTP is slowing the clock
-		 * so make sure not to go into next possible interval.
-		 * Better to lose some accuracy than have time go backwards..
-		 */
-		if (unlikely(time_adjust < 0)) {
-			max_ntp_tick = (USEC_PER_SEC / HZ) - tickadj;
-			usec = min(usec, max_ntp_tick);
-		}
-
+		usec = FRV_HW_CLOCK_DATA;
 		sec = xtime.tv_sec;
 		usec += (xtime.tv_nsec / 1000);
 	} while (read_seqretry(&xtime_lock, seq));
@@ -195,7 +185,7 @@ int do_settimeofday(struct timespec *tv)
 	 * wall time.  Discover what correction gettimeofday() would have
 	 * made, and then undo it!
 	 */
-	nsec -= 0 * NSEC_PER_USEC;
+	nsec -= FRV_HW_CLOCK_DATA * NSEC_PER_USEC;
 
 	wtm_sec  = wall_to_monotonic.tv_sec + (xtime.tv_sec - sec);
 	wtm_nsec = wall_to_monotonic.tv_nsec + (xtime.tv_nsec - nsec);
