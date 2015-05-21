From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH v3 08/10] pktgen: add sample script
	pktgen_sample02_multiqueue.sh
Date: Thu, 21 May 2015 12:17:48 +0200
Message-ID: <20150521101744.15148.70171.stgit@ivy>
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
Received: from mx1.redhat.com ([209.132.183.28]:45072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755200AbbEUKSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 06:18:21 -0400
In-Reply-To: <20150521101501.15148.10609.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the pktgen samples script pktgen_sample02_multiqueue.sh that
demonstrates generating packets on multiqueue NICs.

Specifically notice the options "-t" that specifies how many
kernel threads to activate.  Also notice the flag QUEUE_MAP_CPU,
which cause the SKB TX queue to be mapped to the CPU running the
kernel thread.  For best scalability people are also encourage to
map NIC IRQ /proc/irq/*/smp_affinity to CPU number.

Usage example with "-t" 4 threads and help:
 ./pktgen_sample02_multiqueue.sh -i eth4 -m 00:1B:21:3C:9D:F8 -t 4

Usage: ./pktgen_sample02_multiqueue.sh [-vx] -i ethX
  -i : ($DEV)       output interface/device (required)
  -s : ($PKT_SIZE)  packet size
  -d : ($DEST_IP)   destination IP
  -m : ($DST_MAC)   destination MAC-addr
  -t : ($THREADS)   threads to start
  -c : ($SKB_CLONE) SKB clones send before alloc new SKB
  -b : ($BURST)     HW level bursting of SKBs
  -v : ($VERBOSE)   verbose
  -x : ($DEBUG)     debug

Removing pktgen.conf-2-1 and pktgen.conf-2-2 as these examples
should be covered now.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 Documentation/networking/pktgen.txt          |    2 -
 samples/pktgen/pktgen.conf-2-1               |   66 -----------------------
 samples/pktgen/pktgen.conf-2-2               |   73 -------------------------
 samples/pktgen/pktgen_sample02_multiqueue.sh |   75 ++++++++++++++++++++++++++
 4 files changed, 75 insertions(+), 141 deletions(-)
 delete mode 100755 samples/pktgen/pktgen.conf-2-1
 delete mode 100755 samples/pktgen/pktgen.conf-2-2
 create mode 100755 samples/pktgen/pktgen_sample02_multiqueue.sh

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index f2f1033..f4be85e 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -244,8 +244,6 @@ pktgen_sampleXX scripts and modify them to fit your own needs.
 The old scripts:
 
 pktgen.conf-1-2                  # 1 CPU 2 dev
-pktgen.conf-2-1                  # 2 CPU's 1 dev 
-pktgen.conf-2-2                  # 2 CPU's 2 dev
 pktgen.conf-1-1-rdos             # 1 CPU 1 dev w. route DoS 
 pktgen.conf-1-1-ip6              # 1 CPU 1 dev ipv6
 pktgen.conf-1-1-ip6-rdos         # 1 CPU 1 dev ipv6  w. route DoS
diff --git a/samples/pktgen/pktgen.conf-2-1 b/samples/pktgen/pktgen.conf-2-1
deleted file mode 100755
index e108e97..0000000
--- a/samples/pktgen/pktgen.conf-2-1
+++ /dev/null
@@ -1,66 +0,0 @@
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
-# Each CPU has its own thread. Two CPU example. We add eth1 to the first
-# and leave the second idle.
-
-PGDEV=/proc/net/pktgen/kpktgend_0
-  echo "Removing all devices"
- pgset "rem_device_all"
-  echo "Adding eth1"
- pgset "add_device eth1"
-
-# We need to remove old config since we dont use this thread. We can only
-# one NIC on one CPU due to affinity reasons.
-
-PGDEV=/proc/net/pktgen/kpktgend_1
-  echo "Removing all devices"
- pgset "rem_device_all"
-
-# device config
-# delay 0 means maximum speed.
-
-CLONE_SKB="clone_skb 1000000"
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
- pgset "dst 10.10.11.2"
- pgset "dst_mac  00:04:23:08:91:dc"
-
-
-# Time to run
-PGDEV=/proc/net/pktgen/pgctrl
-
- echo "Running... ctrl^C to stop"
- trap true INT
- pgset "start"
- echo "Done"
- cat /proc/net/pktgen/eth1
diff --git a/samples/pktgen/pktgen.conf-2-2 b/samples/pktgen/pktgen.conf-2-2
deleted file mode 100755
index acea155..0000000
--- a/samples/pktgen/pktgen.conf-2-2
+++ /dev/null
@@ -1,73 +0,0 @@
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
-# Each CPU has its own thread. Two CPU example. We add eth1, eth2 respectively.
-
-PGDEV=/proc/net/pktgen/kpktgend_0
-  echo "Removing all devices"
- pgset "rem_device_all"
-  echo "Adding eth1"
- pgset "add_device eth1"
-
-PGDEV=/proc/net/pktgen/kpktgend_1
-  echo "Removing all devices"
- pgset "rem_device_all"
-  echo "Adding eth2"
- pgset "add_device eth2"
-
-
-# device config
-# delay 0 means maximum speed.
-
-CLONE_SKB="clone_skb 1000000"
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
- pgset "dst 10.10.11.2"
- pgset "dst_mac  00:04:23:08:91:dc"
-
-PGDEV=/proc/net/pktgen/eth2
-  echo "Configuring $PGDEV"
- pgset "$COUNT"
- pgset "$CLONE_SKB"
- pgset "$PKT_SIZE"
- pgset "$DELAY"
- pgset "dst 192.168.2.2"
- pgset "dst_mac  00:04:23:08:91:de"
-
-# Time to run
-PGDEV=/proc/net/pktgen/pgctrl
-
- echo "Running... ctrl^C to stop"
- trap true INT
- pgset "start"
- echo "Done"
- cat /proc/net/pktgen/eth1 /proc/net/pktgen/eth2
diff --git a/samples/pktgen/pktgen_sample02_multiqueue.sh b/samples/pktgen/pktgen_sample02_multiqueue.sh
new file mode 100755
index 0000000..32467ae
--- /dev/null
+++ b/samples/pktgen/pktgen_sample02_multiqueue.sh
@@ -0,0 +1,75 @@
+#!/bin/bash
+#
+# Multiqueue: Using pktgen threads for sending on multiple CPUs
+#  * adding devices to kernel threads
+#  * notice the naming scheme for keeping device names unique
+#  * nameing scheme: dev@thread_number
+#  * flow variation via random UDP source port
+#
+basedir=`dirname $0`
+source ${basedir}/functions.sh
+root_check_run_with_sudo "$@"
+#
+# Required param: -i dev in $DEV
+source ${basedir}/parameters.sh
+
+# Base Config
+DELAY="0"        # Zero means max speed
+COUNT="100000"   # Zero means indefinitely
+[ -z "$CLONE_SKB" ] && CLONE_SKB="0"
+
+# Flow variation random source port between min and max
+UDP_MIN=9
+UDP_MAX=109
+
+# (example of setting default params in your script)
+[ -z "$DEST_IP" ] && DEST_IP="198.18.0.42"
+[ -z "$DST_MAC" ] && DST_MAC="90:e2:ba:ff:ff:ff"
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
+    # Notice config queue to map to cpu (mirrors smp_processor_id())
+    # It is beneficial to map IRQ /proc/irq/*/smp_affinity 1:1 to CPU number
+    pg_set $dev "flag QUEUE_MAP_CPU"
+
+    # Base config of dev
+    pg_set $dev "count $COUNT"
+    pg_set $dev "clone_skb $CLONE_SKB"
+    pg_set $dev "pkt_size $PKT_SIZE"
+    pg_set $dev "delay $DELAY"
+
+    # Flag example disabling timestamping
+    pg_set $dev "flag NO_TIMESTAMP"
+
+    # Destination
+    pg_set $dev "dst_mac $DST_MAC"
+    pg_set $dev "dst $DEST_IP"
+
+    # Setup random UDP port src range
+    pg_set $dev "flag UDPSRC_RND"
+    pg_set $dev "udp_src_min $UDP_MIN"
+    pg_set $dev "udp_src_max $UDP_MAX"
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
