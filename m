From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH v3 09/10] pktgen: add sample script
	pktgen_sample03_burst_single_flow.sh
Date: Thu, 21 May 2015 12:18:12 +0200
Message-ID: <20150521101759.15148.60960.stgit@ivy>
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
Received: from mx1.redhat.com ([209.132.183.28]:53385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754356AbbEUKSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 06:18:20 -0400
In-Reply-To: <20150521101501.15148.10609.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the pktgen samples script pktgen_sample03_burst_single_flow.sh
that demonstrates how to acheive maximum performance.

If correctly tuned[1] single CPU 10Gbit/s wirespeed small pkts is
possible[2] which is 14.88Mpps.  The trick is to take advantage of the
"burst" feature introduced in commit 38b2cf2982dc73 ("net: pktgen:
packet bursting via skb->xmit_more").

[1] http://netoptimizer.blogspot.dk/2014/06/pktgen-for-network-overload-testing.html
[2] http://netoptimizer.blogspot.dk/2014/10/unlocked-10gbps-tx-wirespeed-smallest.html

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
v2: use arithmetic compare when disabling burst
 - proposed by Cong Wang <cwang@twopensource.com>


 .../pktgen/pktgen_sample03_burst_single_flow.sh    |   82 ++++++++++++++++++++
 1 files changed, 82 insertions(+), 0 deletions(-)
 create mode 100755 samples/pktgen/pktgen_sample03_burst_single_flow.sh

diff --git a/samples/pktgen/pktgen_sample03_burst_single_flow.sh b/samples/pktgen/pktgen_sample03_burst_single_flow.sh
new file mode 100755
index 0000000..775f5d0
--- /dev/null
+++ b/samples/pktgen/pktgen_sample03_burst_single_flow.sh
@@ -0,0 +1,82 @@
+#!/bin/bash
+#
+# Script for max single flow performance
+#  - If correctly tuned[1], single CPU 10G wirespeed small pkts is possible[2]
+#
+# Using pktgen "burst" option (use -b $N)
+#  - To boost max performance
+#  - Avail since: kernel v3.18
+#   * commit 38b2cf2982dc73 ("net: pktgen: packet bursting via skb->xmit_more")
+#  - This avoids writing the HW tailptr on every driver xmit
+#  - The performance boost is impressive, see commit and blog [2]
+#
+# Notice: On purpose generates a single (UDP) flow towards target,
+#   reason behind this is to only overload/activate a single CPU on
+#   target host.  And no randomness for pktgen also makes it faster.
+#
+# Tuning see:
+#  [1] http://netoptimizer.blogspot.dk/2014/06/pktgen-for-network-overload-testing.html
+#  [2] http://netoptimizer.blogspot.dk/2014/10/unlocked-10gbps-tx-wirespeed-smallest.html
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
+[ -z "$BURST" ]     && BURST=32
+[ -z "$CLONE_SKB" ] && CLONE_SKB="100000"
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
+    # Destination
+    pg_set $dev "dst_mac $DST_MAC"
+    pg_set $dev "dst $DEST_IP"
+
+    # Setup burst, for easy testing -b 0 disable bursting
+    # (internally in pktgen default and minimum burst=1)
+    if [[ ${BURST} -ne 0 ]]; then
+	pg_set $dev "burst $BURST"
+    else
+	info "$dev: Not using burst"
+    fi
+done
+
+# Run if user hits control-c
+function control_c() {
+    # Print results
+    for ((thread = 0; thread < $THREADS; thread++)); do
+	dev=${DEV}@${thread}
+	echo "Device: $dev"
+	cat /proc/net/pktgen/$dev | grep -A2 "Result:"
+    done
+}
+# trap keyboard interrupt (Ctrl-C)
+trap control_c SIGINT
+
+echo "Running... ctrl^C to stop" >&2
+pg_ctrl "start"
