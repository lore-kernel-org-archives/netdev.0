From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/3] pktgen: add sample script
 pktgen_sample05_flow_per_thread.sh
Date: Wed, 13 Jul 2016 22:06:10 +0200
Message-ID: <20160713200609.21875.32584.stgit@firesoul>
References: <20160713200525.21875.21960.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281AbcGMUGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 16:06:11 -0400
In-Reply-To: <20160713200525.21875.21960.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pktgen sample script is useful for scalability testing a
receiver.  The script will simply generate one flow per
thread (option -t N) using the thread number as part of the
source IP-address.

The single flow sample (pktgen_sample03_burst_single_flow.sh)
have become quite popular, but it is important that developers
also make sure to benchmark scalability of multiple receive
queues.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/pktgen/pktgen_sample05_flow_per_thread.sh |   81 +++++++++++++++++++++
 1 file changed, 81 insertions(+)
 create mode 100755 samples/pktgen/pktgen_sample05_flow_per_thread.sh

diff --git a/samples/pktgen/pktgen_sample05_flow_per_thread.sh b/samples/pktgen/pktgen_sample05_flow_per_thread.sh
new file mode 100755
index 000000000000..32ad818e2829
--- /dev/null
+++ b/samples/pktgen/pktgen_sample05_flow_per_thread.sh
@@ -0,0 +1,81 @@
+#!/bin/bash
+#
+# Script will generate one flow per thread (-t N)
+#  - Same destination IP
+#  - Fake source IPs for each flow (fixed based on thread number)
+#
+# Useful for scale testing on receiver, to see whether silo'ing flows
+# works and scales.  For optimal scalability (on receiver) each
+# separate-flow should not access shared variables/data. This script
+# helps magnify any of these scaling issues by overloading the receiver.
+#
+basedir=`dirname $0`
+source ${basedir}/functions.sh
+root_check_run_with_sudo "$@"
+
+# Parameter parsing via include
+source ${basedir}/parameters.sh
+# Set some default params, if they didn't get set
+[ -z "$DEST_IP" ]   && DEST_IP="198.18.0.42"
+[ -z "$DST_MAC" ]   && DST_MAC="90:e2:ba:ff:ff:ff"
+[ -z "$CLONE_SKB" ] && CLONE_SKB="0"
+[ -z "$BURST" ]     && BURST=32
+
+
+# Base Config
+DELAY="0"  # Zero means max speed
+COUNT="0"  # Zero means indefinitely
+
+# General cleanup everything since last run
+pg_ctrl "reset"
+
+# Threads are specified with parameter -t value in $THREADS
+for ((thread = 0; thread < $THREADS; thread++)); do
+    dev=${DEV}@${thread}
+
+    # Add remove all other devices and add_device $dev to thread
+    pg_thread $thread "rem_device_all"
+    pg_thread $thread "add_device" $dev
+
+    # Base config
+    pg_set $dev "flag QUEUE_MAP_CPU"
+    pg_set $dev "count $COUNT"
+    pg_set $dev "clone_skb $CLONE_SKB"
+    pg_set $dev "pkt_size $PKT_SIZE"
+    pg_set $dev "delay $DELAY"
+    pg_set $dev "flag NO_TIMESTAMP"
+
+    # Single destination
+    pg_set $dev "dst_mac $DST_MAC"
+    pg_set $dev "dst $DEST_IP"
+
+    # Setup source IP-addresses based on thread number
+    pg_set $dev "src_min 198.18.$((thread+1)).1"
+    pg_set $dev "src_max 198.18.$((thread+1)).1"
+
+    # Setup burst, for easy testing -b 0 disable bursting
+    # (internally in pktgen default and minimum burst=1)
+    if [[ ${BURST} -ne 0 ]]; then
+	pg_set $dev "burst $BURST"
+    else
+	info "$dev: Not using burst"
+    fi
+
+done
+
+# Run if user hits control-c
+function print_result() {
+    # Print results
+    for ((thread = 0; thread < $THREADS; thread++)); do
+	dev=${DEV}@${thread}
+	echo "Device: $dev"
+	cat /proc/net/pktgen/$dev | grep -A2 "Result:"
+    done
+}
+# trap keyboard interrupt (Ctrl-C)
+trap true SIGINT
+
+echo "Running... ctrl^C to stop" >&2
+pg_ctrl "start"
+
+print_result
