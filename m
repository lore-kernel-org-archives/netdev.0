From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH v3 10/10] pktgen: add benchmark script
	pktgen_bench_xmit_mode_netif_receive.sh
Date: Thu, 21 May 2015 12:18:29 +0200
Message-ID: <20150521101822.15148.6918.stgit@ivy>
References: <20150521101501.15148.10609.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397AbbEUKTC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 06:19:02 -0400
In-Reply-To: <20150521101501.15148.10609.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This script pktgen_bench_xmit_mode_netif_receive.sh is a benchmark
script, which can be used for benchmarking part of the network stack.
This can be used for performance improving or catching regression in
that area.

The script is developed for benchmarking ingress qdisc path, original
idea by Alexei Starovoitov.  This script don't really need any
hardware.  This is achieved via the recently introduced stack inject
feature "xmit_mode netif_receive". See commit 62f64aed622b6 ("pktgen:
introduce xmit_mode '<start_xmit|netif_receive>'").

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 .../pktgen/pktgen_bench_xmit_mode_netif_receive.sh |   86 ++++++++++++++++++++
 1 files changed, 86 insertions(+), 0 deletions(-)
 create mode 100755 samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh

diff --git a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
new file mode 100755
index 0000000..cb15903
--- /dev/null
+++ b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
@@ -0,0 +1,86 @@
+#!/bin/bash
+#
+# Benchmark script:
+#  - developed for benchmarking ingress qdisc path
+#
+# Script for injecting packets into RX path of the stack with pktgen
+# "xmit_mode netif_receive".  With an invalid dst_mac this will only
+# measure the ingress code path as packets gets dropped in ip_rcv().
+#
+# This script don't really need any hardware.  It benchmarks software
+# RX path just after NIC driver level.  With bursting is also
+# "removes" the SKB alloc/free overhead.
+#
+# Setup scenarios for measuring ingress qdisc (with invalid dst_mac):
+# ------------------------------------------------------------------
+# (1) no ingress (uses static_key_false(&ingress_needed))
+#
+# (2) ingress on other dev (change ingress_needed and calls
+#     handle_ing() but exit early)
+#
+#  config:  tc qdisc add dev $SOMEDEV handle ffff: ingress
+#
+# (3) ingress on this dev, handle_ing() -> tc_classify()
+#
+#  config:  tc qdisc add dev $DEV handle ffff: ingress
+#
+# (4) ingress on this dev + drop at u32 classifier/action.
+#
+basedir=`dirname $0`
+source ${basedir}/functions.sh
+root_check_run_with_sudo "$@"
+
+# Parameter parsing via include
+source ${basedir}/parameters.sh
+# Using invalid DST_MAC will cause the packets to get dropped in
+# ip_rcv() which is part of the test
+[ -z "$DEST_IP" ] && DEST_IP="198.18.0.42"
+[ -z "$DST_MAC" ] && DST_MAC="90:e2:ba:ff:ff:ff"
+[ -z "$BURST" ] && BURST=1024
+
+# Base Config
+DELAY="0"        # Zero means max speed
+COUNT="10000000" # Zero means indefinitely
+
+# General cleanup everything since last run
+pg_ctrl "reset"
+
+# Threads are specified with parameter -t value in $THREADS
+for ((thread = 0; thread < $THREADS; thread++)); do
+    # The device name is extended with @name, using thread number to
+    # make then unique, but any name will do.
+    dev=${DEV}@${thread}
+
+    # Add remove all other devices and add_device $dev to thread
+    pg_thread $thread "rem_device_all"
+    pg_thread $thread "add_device" $dev
+
+    # Base config of dev
+    pg_set $dev "flag QUEUE_MAP_CPU"
+    pg_set $dev "count $COUNT"
+    pg_set $dev "pkt_size $PKT_SIZE"
+    pg_set $dev "delay $DELAY"
+    pg_set $dev "flag NO_TIMESTAMP"
+
+    # Destination
+    pg_set $dev "dst_mac $DST_MAC"
+    pg_set $dev "dst $DEST_IP"
+
+    # Inject packet into RX path of stack
+    pg_set $dev "xmit_mode netif_receive"
+
+    # Burst allow us to avoid measuring SKB alloc/free overhead
+    pg_set $dev "burst $BURST"
+done
+
+# start_run
+echo "Running... ctrl^C to stop" >&2
+pg_ctrl "start"
+echo "Done" >&2
+
+# Print results
+for ((thread = 0; thread < $THREADS; thread++)); do
+    dev=${DEV}@${thread}
+    echo "Device: $dev"
+    cat /proc/net/pktgen/$dev | grep -A2 "Result:"
+done
