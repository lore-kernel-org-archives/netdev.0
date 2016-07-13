From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/3] pktgen: add sample script
 pktgen_sample04_many_flows.sh
Date: Wed, 13 Jul 2016 22:06:04 +0200
Message-ID: <20160713200604.21875.31278.stgit@firesoul>
References: <20160713200525.21875.21960.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbcGMUGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 16:06:11 -0400
In-Reply-To: <20160713200525.21875.21960.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a pktgen sample script that demonstrates how to use pktgen
for simulating flows.  Script will generate a certain number of
concurrent flows ($FLOWS) and each flow will contain $FLOWLEN
packets, which will be send back-to-back, before switching to a
new flow, due to flag FLOW_SEQ.

This script obsoletes the old sample script 'pktgen.conf-1-1-flows',
which is removed.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/pktgen/pktgen.conf-1-1-flows         |   67 -------------------
 samples/pktgen/pktgen_sample04_many_flows.sh |   93 ++++++++++++++++++++++++++
 2 files changed, 93 insertions(+), 67 deletions(-)
 delete mode 100755 samples/pktgen/pktgen.conf-1-1-flows
 create mode 100755 samples/pktgen/pktgen_sample04_many_flows.sh

diff --git a/samples/pktgen/pktgen.conf-1-1-flows b/samples/pktgen/pktgen.conf-1-1-flows
deleted file mode 100755
index 081749c9707d..000000000000
--- a/samples/pktgen/pktgen.conf-1-1-flows
+++ /dev/null
@@ -1,67 +0,0 @@
-#!/bin/bash
-
-#modprobe pktgen
-
-
-function pgset() {
-    local result
-
-    echo $1 > $PGDEV
-
-    result=`cat $PGDEV | fgrep "Result: OK:"`
-    if [ "$result" = "" ]; then
-         cat $PGDEV | fgrep Result:
-    fi
-}
-
-# Config Start Here -----------------------------------------------------------
-
-
-# thread config
-# Each CPU has its own thread. One CPU example. We add eth1.
-
-PGDEV=/proc/net/pktgen/kpktgend_0
-  echo "Removing all devices"
- pgset "rem_device_all"
-  echo "Adding eth1"
- pgset "add_device eth1"
-
-
-# device config
-# delay 0
-# We need to do alloc for every skb since we cannot clone here.
-
-CLONE_SKB="clone_skb 0"
-# NIC adds 4 bytes CRC
-PKT_SIZE="pkt_size 60"
-
-# COUNT 0 means forever
-#COUNT="count 0"
-COUNT="count 10000000"
-DELAY="delay 0"
-
-PGDEV=/proc/net/pktgen/eth1
-  echo "Configuring $PGDEV"
- pgset "$COUNT"
- pgset "$CLONE_SKB"
- pgset "$PKT_SIZE"
- pgset "$DELAY"
- # Random address with in the min-max range
- pgset "flag IPDST_RND"
- pgset "dst_min 10.0.0.0"
- pgset "dst_max 10.255.255.255"
-
- # 8k Concurrent flows at 4 pkts
- pgset "flows 8192"
- pgset "flowlen 4"
-
- pgset "dst_mac  00:04:23:08:91:dc"
-
-# Time to run
-PGDEV=/proc/net/pktgen/pgctrl
-
- echo "Running... ctrl^C to stop"
- trap true INT
- pgset "start"
- echo "Done"
- cat /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen_sample04_many_flows.sh b/samples/pktgen/pktgen_sample04_many_flows.sh
new file mode 100755
index 000000000000..f60412e445bb
--- /dev/null
+++ b/samples/pktgen/pktgen_sample04_many_flows.sh
@@ -0,0 +1,93 @@
+#!/bin/bash
+#
+# Script example for many flows testing
+#
+# Number of simultaneous flows limited by variable $FLOWS
+# and number of packets per flow controlled by variable $FLOWLEN
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
+
+# NOTICE:  Script specific settings
+# =======
+# Limiting the number of concurrent flows ($FLOWS)
+# and also set how many packets each flow contains ($FLOWLEN)
+#
+[ -z "$FLOWS" ]     && FLOWS="8000"
+[ -z "$FLOWLEN" ]   && FLOWLEN="10"
+
+# Base Config
+DELAY="0"  # Zero means max speed
+COUNT="0"  # Zero means indefinitely
+
+if [[ -n "$BURST" ]]; then
+    err 1 "Bursting not supported for this mode"
+fi
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
+    # Randomize source IP-addresses
+    pg_set $dev "flag IPSRC_RND"
+    pg_set $dev "src_min 198.18.0.0"
+    pg_set $dev "src_max 198.19.255.255"
+
+    # Limit number of flows (max 65535)
+    pg_set $dev "flows $FLOWS"
+    #
+    # How many packets a flow will send, before flow "entry" is
+    # re-generated/setup.
+    pg_set $dev "flowlen $FLOWLEN"
+    #
+    # Flag FLOW_SEQ will cause $FLOWLEN packets from the same flow
+    # being send back-to-back, before next flow is selected
+    # incrementally.  This helps lookup caches, and is more realistic.
+    #
+    pg_set $dev "flag FLOW_SEQ"
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
