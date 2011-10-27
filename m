From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 4/5] perf: add perf script to monitor efficiency increase in FCLONE_SCRATCH api
Date: Thu, 27 Oct 2011 15:53:40 -0400
Message-ID: <1319745221-30880-5-git-send-email-nhorman@tuxdriver.com>
References: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Cc: root <root@updev.think-freely.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38411 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520Ab1J0Tyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 15:54:37 -0400
In-Reply-To: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: root <root@updev.think-freely.org>

Since the FCLONE_SCRATCH mehanism is opportunistic, gathering internally
fragmented memory when available, its beneficial to know how efficiently its
working, so that tuning can be implemented to optimize it.  This patch adds a
perf script to export data collected via the previously added tracepoints.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 .../scripts/python/bin/net-fscratch-stats-record   |    4 +
 .../scripts/python/bin/net-fscratch-stats-report   |    4 +
 tools/perf/scripts/python/net-fscratch.py          |  198 ++++++++++++++++++++
 3 files changed, 206 insertions(+), 0 deletions(-)
 create mode 100644 tools/perf/scripts/python/bin/net-fscratch-stats-record
 create mode 100644 tools/perf/scripts/python/bin/net-fscratch-stats-report
 create mode 100644 tools/perf/scripts/python/net-fscratch.py

diff --git a/tools/perf/scripts/python/bin/net-fscratch-stats-record b/tools/perf/scripts/python/bin/net-fscratch-stats-record
new file mode 100644
index 0000000..7aae593
--- /dev/null
+++ b/tools/perf/scripts/python/bin/net-fscratch-stats-record
@@ -0,0 +1,4 @@
+#!/bin/bash
+perf record 	-e skb:skb_make_fclone_scratch -e skb:alloc_fscratch_skb \
+		-e napi:napi_schedule -e napi:napi_complete \
+		-e napi:napi_poll -e net:netif_receive_skb $@
diff --git a/tools/perf/scripts/python/bin/net-fscratch-stats-report b/tools/perf/scripts/python/bin/net-fscratch-stats-report
new file mode 100644
index 0000000..85bb867
--- /dev/null
+++ b/tools/perf/scripts/python/bin/net-fscratch-stats-report
@@ -0,0 +1,4 @@
+#!/bin/bash
+# description: display a process of packet and processing time
+
+perf script -s "$PERF_EXEC_PATH"/scripts/python/net-fscratch.py $@
diff --git a/tools/perf/scripts/python/net-fscratch.py b/tools/perf/scripts/python/net-fscratch.py
new file mode 100644
index 0000000..f9ae5c9
--- /dev/null
+++ b/tools/perf/scripts/python/net-fscratch.py
@@ -0,0 +1,198 @@
+# Display a process of packets and processed time.
+# It helps us to investigate networking or network device.
+#
+# options
+# tx: show only tx chart
+# rx: show only rx chart
+# dev=: show only thing related to specified device
+# debug: work with debug mode. It shows buffer status.
+
+import os
+import sys
+
+sys.path.append(os.environ['PERF_EXEC_PATH'] + \
+	'/scripts/python/Perf-Trace-Util/lib/Perf/Trace')
+
+from perf_trace_context import *
+from Core import *
+from Util import *
+
+parent_skbs = {}
+
+total_parents=0
+total_children_avail=0
+total_children_used=0
+total_orphans=0
+
+IDX_FC_COUNT=0
+IDX_FC_KIDS=1
+
+STATE_START_TIMING=0
+STATE_TIMING=1
+STATE_COLLECT_TIMING=2
+STATE_RESET=3
+
+cpu_cycle_stats = {}
+cpu_total_stats = {}
+
+class cpuCycleStats():
+	def __init__(self):
+		self.start_rx_time = 0
+		self.end_rx_time = 0
+		self.state = STATE_RESET
+		self.total_rx_frames = 0
+
+class cpuTotalStats():
+	def __init__(self):
+		self.total_frames = 0
+		self.total_napi_time = 0
+		self.napi_sc_cycles = 0
+
+def gather_fclone_use_stats(stat):
+	global total_parents
+	global total_children_avail
+	global total_children_used
+
+	total_parents = total_parents+1
+	total_children_avail = total_children_avail + stat[IDX_FC_COUNT]
+	total_children_used = total_children_used + stat[IDX_FC_KIDS]
+
+# called from perf, when it finds a correspoinding event
+def skb__skb_make_fclone_scratch(event_name, context, common_cpu,
+ common_secs, common_nsecs, common_pid, common_comm,
+ skb, name, fccount):
+	global parent_skbs
+
+	if (skb in parent_skbs.keys()):
+		gather_fclone_use_stats(parent_skbs[skb])
+		parent_skbs[skb] = None
+
+	parent_skbs[skb] = [fccount, 0]
+
+def skb__alloc_fscratch_skb(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	parent, child):
+	global parent_skbs
+	global total_orphans
+
+	if (child == 0):
+		#We didn't have an fscratch_child to allocate
+		return
+
+	try:
+		parent_skbs[parent][IDX_FC_KIDS] += 1
+	except:
+		total_orphans += 1
+
+def napi__napi_schedule(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	napi, dev_name):
+	global cpu_cycle_stats
+
+	if (common_cpu in cpu_cycle_stats.keys()):
+		return;
+
+	cpu_cycle_stats[common_cpu] = cpuCycleStats()
+	cpu_cycle_stats[common_cpu].state = STATE_START_TIMING
+	return
+
+def napi__napi_complete(event_name, context, common_cpu,
+	common_secs, common_nsecs, common_pid, common_comm,
+	napi, dev_name):
+	global cpu_cycle_stats
+	global cpu_total_stats
+
+
+	if (common_cpu not in cpu_cycle_stats.keys()):
+		return
+
+	if (cpu_cycle_stats[common_cpu].state == STATE_TIMING):
+		cpu_cycle_stats[common_cpu].state = STATE_COLLECT_TIMING
+
+
+def napi__napi_poll(event_name, context, common_cpu,
+        common_secs, common_nsecs, common_pid, common_comm,
+        napi, dev_name):
+	global cpu_cycle_stats
+	global cpu_total_stats
+
+	if (common_cpu not in cpu_cycle_stats.keys()):
+		return
+
+
+	if (common_cpu not in cpu_total_stats.keys()):
+		cpu_total_stats[common_cpu] = cpuTotalStats()
+
+	state = cpu_cycle_stats[common_cpu].state
+
+	if (state == STATE_COLLECT_TIMING):
+		cpu_total_stats[common_cpu].napi_sc_cycles += 1
+
+	if (cpu_cycle_stats[common_cpu].end_rx_time == cpu_cycle_stats[common_cpu].start_rx_time):
+		cpu_cycle_stats[common_cpu].end_rx_time = common_nsecs
+
+	if ((state == STATE_COLLECT_TIMING) or (state == STATE_TIMING)):
+		if (cpu_cycle_stats[common_cpu].end_rx_time > cpu_cycle_stats[common_cpu].start_rx_time):
+			napi_time = cpu_cycle_stats[common_cpu].end_rx_time - cpu_cycle_stats[common_cpu].start_rx_time
+		else:
+			napi_time = cpu_cycle_stats[common_cpu].start_rx_time - cpu_cycle_stats[common_cpu].end_rx_time
+
+		if (napi_time == 0):
+			cpu_cycle_stats[common_cpu].total_rx_frames = 0
+
+		cpu_total_stats[common_cpu].total_frames += cpu_cycle_stats[common_cpu].total_rx_frames
+		cpu_total_stats[common_cpu].total_napi_time += napi_time
+		cpu_cycle_stats[common_cpu] = cpuCycleStats()
+		cpu_cycle_stats[common_cpu].state = STATE_START_TIMING
+
+
+def net__netif_receive_skb(event_name, context, common_cpu,
+        common_secs, common_nsecs, common_pid, common_comm,
+        skbaddr, len, name):
+	global cpu_cycle_stats
+
+	if (common_cpu not in cpu_cycle_stats.keys()):
+		return
+
+	if (cpu_cycle_stats[common_cpu].state == STATE_START_TIMING):
+		cpu_cycle_stats[common_cpu].state = STATE_TIMING
+		cpu_cycle_stats[common_cpu].start_rx_time = common_nsecs
+
+
+	if (cpu_cycle_stats[common_cpu].state == STATE_TIMING):
+		cpu_cycle_stats[common_cpu].total_rx_frames += 1
+		cpu_cycle_stats[common_cpu].end_rx_time = common_nsecs
+
+
+def trace_end():
+	global parent_skbs
+	global total_parents
+        global total_children_avail
+        global total_children_used
+	global total_orphans
+	global cpu_total_stats
+
+	for i in parent_skbs.keys():
+		gather_fclone_use_stats(parent_skbs[i])
+	try:
+		avg_offer_skb = str(total_children_avail / total_parents)
+		avg_used_skb = str(total_children_used / total_parents)
+	except:
+		avg_offer_skb = str(0)
+		avg_used_skb = str(0)
+
+	print "Performance report:"
+	print "Skbs marked as having scratch space available: " + str(total_parents)
+	print "Total fclone_scratch skb children available: " + str(total_children_avail)
+	print "Total fclone_scratch skb children used: " + str(total_children_used)
+	print "Total orphans: " + str(total_orphans)
+	print "Average number of scratch skbs available: " + avg_offer_skb
+	print "Average number of scratch skbs used: " + avg_used_skb
+	for i in cpu_total_stats.keys():
+		tframe = cpu_total_stats[i].total_frames
+		ttime = cpu_total_stats[i].total_napi_time
+		try:
+			print "CPU " + str(i) + " avg napi latency " + str(ttime/tframe) + " nsec/frame (" + str(ttime) + " " + str(tframe) + ")"
+		except:
+			print "CPU " + str(i) + " avg napi latency 0 usec/frame (" + str(ttime) + " " + str(tframe) + ")"
+		print "CPU " + str(i) + " napi sched/complete cycles: " + str(cpu_total_stats[i].napi_sc_cycles)
-- 
1.7.6.4
