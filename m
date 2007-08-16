From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] net/core/dst.c : Should'nt dst_run_gc() be more scalable and
 friendly ?
Date: Thu, 16 Aug 2007 14:09:13 +0200
Message-ID: <20070816140914.de24335c.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:35617 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752606AbXHPMJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 08:09:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all

When the periodic route cache flush is done, this machine suffers a lot and eventually triggers the "soft lockup" message.

dst_run_gc() is doing a scan of a possibly huge list of dst_entries, eventually freeing some (less than 1%) of them, but holding the dst_lock spinlock for the whole scan.

Then it rearms a timer to redo the full thing 1/10 s later. The slowdown can last one minute or so.
No need to say that machine is not really usable in the meantime.

I already looked at the code and I am testing a patch (included in this mail) where I limit the number of entries that can be scanned at each dst_run_gc() call, and not holding dst_lock during the scan. But then I dont know how to address the dst_dev_event() problem, since we must be able to dst_ifdown() all entries attached to one dev.

I am wondering how to really solve the problem. Could a workqueue be used here instead of a timer ?


Aug 16 06:21:37 SRV1 kernel: BUG: soft lockup detected on CPU#0!
Aug 16 06:21:37 SRV1 kernel: 
Aug 16 06:21:37 SRV1 kernel: Call Trace:
Aug 16 06:21:37 SRV1 kernel:  <IRQ>  [<ffffffff802286f0>] wake_up_process+0x10/0x20
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff80251e09>] softlockup_tick+0xe9/0x110
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803cd380>] dst_run_gc+0x0/0x140
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff802376f3>] run_local_timers+0x13/0x20
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff802379c7>] update_process_times+0x57/0x90
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff80216034>] smp_local_timer_interrupt+0x34/0x60
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff802165cc>] smp_apic_timer_interrupt+0x5c/0x80
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff8020a816>] apic_timer_interrupt+0x66/0x70
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803cd3d3>] dst_run_gc+0x53/0x140
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803cd3c6>] dst_run_gc+0x46/0x140
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff80237148>] run_timer_softirq+0x148/0x1c0
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff8023340c>] __do_softirq+0x6c/0xe0
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff8020ad6c>] call_softirq+0x1c/0x30
Aug 16 06:21:37 SRV1 kernel:  <EOI>  [<ffffffff8020cb34>] do_softirq+0x34/0x90
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff802331cf>] local_bh_enable_ip+0x3f/0x60
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff80422913>] _spin_unlock_bh+0x13/0x20
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803dfde8>] rt_garbage_collect+0x1d8/0x320
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803cd4dd>] dst_alloc+0x1d/0xa0
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803e1433>] __ip_route_output_key+0x573/0x800
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803c02e2>] sock_common_recvmsg+0x32/0x50
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803e16dc>] ip_route_output_flow+0x1c/0x60
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff80400160>] tcp_v4_connect+0x150/0x610
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803ebf07>] inet_bind_bucket_create+0x17/0x60
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff8040cd16>] inet_stream_connect+0xa6/0x2c0
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff80422981>] _spin_lock_bh+0x11/0x30
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803c0bdf>] lock_sock_nested+0xcf/0xe0
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff80422981>] _spin_lock_bh+0x11/0x30
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803be551>] sys_connect+0x71/0xa0
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803eee3f>] tcp_setsockopt+0x1f/0x30
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803c030f>] sock_common_setsockopt+0xf/0x20
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff803be4bd>] sys_setsockopt+0x9d/0xc0
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff8028881e>] sys_ioctl+0x5e/0x80
Aug 16 06:21:37 SRV1 kernel:  [<ffffffff80209c4e>] system_call+0x7e/0x83

Prelimary patch :

--- linux-2.6.22/net/core/dst.c
+++ linux-2.6.22-ed/net/core/dst.c
@@ -28,6 +28,9 @@
  * 4) All operations modify state, so a spinlock is used.
  */
 static struct dst_entry 	*dst_garbage_list;
+static struct dst_entry     *dst_garbage_wrk;
+static struct dst_entry     *dst_garbage_inuse;
+static int dst_gc_running;
 #if RT_CACHE_DEBUG >= 2
 static atomic_t			 dst_total = ATOMIC_INIT(0);
 #endif
@@ -42,26 +45,42 @@
 
 static void dst_run_gc(unsigned long dummy)
 {
-	int    delayed = 0;
-	int    work_performed;
-	struct dst_entry * dst, **dstp;
-
-	if (!spin_trylock(&dst_lock)) {
-		mod_timer(&dst_gc_timer, jiffies + HZ/10);
-		return;
-	}
-
+	int    quota = 1000;
+	int    work_performed = 0;
+	struct dst_entry *dst, *next;
+	struct dst_entry *first = NULL, *last = NULL;
+#if RT_CACHE_DEBUG >= 2
+	unsigned long t0 = jiffies;
+#endif
+	spin_lock(&dst_lock);
+	if (dst_gc_running)
+		goto out;
 	del_timer(&dst_gc_timer);
-	dstp = &dst_garbage_list;
-	work_performed = 0;
-	while ((dst = *dstp) != NULL) {
-		if (atomic_read(&dst->__refcnt)) {
-			dstp = &dst->next;
-			delayed++;
+	if (!dst_garbage_wrk) {
+		dst_garbage_wrk = dst_garbage_list;
+		dst_garbage_list = dst_garbage_inuse;
+		dst_garbage_inuse = NULL;
+	}
+	/*
+	 * before releasing dst_lock, tell others we are currently running
+	 * so they wont start timer or mess dst_garbage_wrk
+	 */
+	dst_gc_running = 1;
+	next = dst_garbage_wrk;
+	spin_unlock(&dst_lock);
+
+	while ((dst = next) != NULL) {
+		next = dst->next;
+		if (likely(atomic_read(&dst->__refcnt))) {
+			if (unlikely(last == NULL))
+				last = dst;
+			dst->next = first;
+			first = dst;
+			if (--quota == 0)
+				break;
 			continue;
 		}
-		*dstp = dst->next;
-		work_performed = 1;
+		work_performed++;
 
 		dst = dst_destroy(dst);
 		if (dst) {
@@ -77,16 +96,26 @@
 				continue;
 
 			___dst_free(dst);
-			dst->next = *dstp;
-			*dstp = dst;
-			dstp = &dst->next;
+			dst->next = next;
+			next = dst;
 		}
 	}
-	if (!dst_garbage_list) {
+	dst_garbage_wrk = next;
+
+	spin_lock(&dst_lock);
+	dst_gc_running = 0;
+	if (last != NULL) {
+		last->next = dst_garbage_inuse;
+		dst_garbage_inuse = first;
+	}
+	/*
+	 * If all lists are empty, no need to rearm a timer
+	 */
+	if (!dst_garbage_list && !dst_garbage_wrk && !dst_garbage_inuse) {
 		dst_gc_timer_inc = DST_GC_MAX;
 		goto out;
 	}
-	if (!work_performed) {
+	if (!work_performed && !dst_garbage_wrk) {
 		if ((dst_gc_timer_expires += dst_gc_timer_inc) > DST_GC_MAX)
 			dst_gc_timer_expires = DST_GC_MAX;
 		dst_gc_timer_inc += DST_GC_INC;
@@ -95,8 +124,12 @@
 		dst_gc_timer_expires = DST_GC_MIN;
 	}
 #if RT_CACHE_DEBUG >= 2
-	printk("dst_total: %d/%d %ld\n",
-	       atomic_read(&dst_total), delayed,  dst_gc_timer_expires);
+	if (net_msg_warn)
+		printk(KERN_DEBUG "dst_run_gc: "
+		"dst_total=%d quota=%d perf=%d expires=%ld elapsed=%lu\n",
+		atomic_read(&dst_total),
+		quota,  work_performed,
+		dst_gc_timer_expires, jiffies - t0);
 #endif
 	/* if the next desired timer is more than 4 seconds in the future
 	 * then round the timer to whole seconds
@@ -157,7 +190,7 @@
 	___dst_free(dst);
 	dst->next = dst_garbage_list;
 	dst_garbage_list = dst;
-	if (dst_gc_timer_inc > DST_GC_INC) {
+	if (dst_gc_timer_inc > DST_GC_INC && !dst_gc_running) {
 		dst_gc_timer_inc = DST_GC_INC;
 		dst_gc_timer_expires = DST_GC_MIN;
 		mod_timer(&dst_gc_timer, jiffies + dst_gc_timer_expires);
