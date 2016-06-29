From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 2/2] net: samples: pktgen mode samples/tests for
 qdisc layer
Date: Wed, 29 Jun 2016 13:03:26 -0700
Message-ID: <20160629200326.16491.11589.stgit@john-Precision-Tower-5810>
References: <20160629200306.16491.65359.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34782 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbcF2UDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 16:03:39 -0400
Received: by mail-pf0-f194.google.com with SMTP id 66so5283929pfy.1
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 13:03:39 -0700 (PDT)
In-Reply-To: <20160629200306.16491.65359.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds samples for pktgen to use with new mode to inject pkts into
the qdisc layer. This also doubles as nice test cases to test any
patches against qdisc layer.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 .../pktgen/pktgen_bench_xmit_mode_queue_xmit.sh    |   70 ++++++++++++++++++++
 1 file changed, 70 insertions(+)
 create mode 100755 samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh

diff --git a/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh b/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
new file mode 100755
index 0000000..eee06cc
--- /dev/null
+++ b/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
@@ -0,0 +1,70 @@
+#!/bin/bash
+#
+# Benchmark script:
+#  - developed for benchmarking egress qdisc path, derived from
+#    ingress benchmark script.
+#
+# Script for injecting packets into egress qdisc path of the stack
+# with pktgen "xmit_mode queue_xmit".
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
+
+# Burst greater than 1 are invalid but allow users to specify it and
+# get an error instead of silently ignoring it.
+[ -z "$BURST" ] && BURST=1
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
+    pg_set $dev "xmit_mode queue_xmit"
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
