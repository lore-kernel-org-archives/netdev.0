From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 07/10] pktgen: add sample script
	pktgen_sample01_simple.sh
Date: Tue, 19 May 2015 23:36:18 +0200
Message-ID: <20150519213618.9070.35078.stgit@ivy>
References: <20150519213326.9070.18264.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751391AbbESVgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 17:36:23 -0400
In-Reply-To: <20150519213326.9070.18264.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the first basic pktgen samples script pktgen_sample01_simple.sh,
which demonstrates the a simple use of the helper functions.
Removing pktgen.conf-1-1 as that example should be covered now.

The naming scheme pktgen_sampleNN, where NN is a number, should encourage
reading the samples in a specific order.

Script cause pktgen sending with a single thread and single interface,
and introduce flow variation via random UDP source port.

Usage example and help:
 ./pktgen_sample01_simple.sh -i eth4 -m 00:1B:21:3C:9D:F8 -d 192.168.8.2

Usage: ./pktgen_sample01_simple.sh [-vx] -i ethX
  -i : ($DEV)       output interface/device (required)
  -s : ($PKT_SIZE)  packet size
  -d : ($DEST_IP)   destination IP
  -m : ($DST_MAC)   destination MAC-addr
  -c : ($SKB_CLONE) SKB clones send before alloc new SKB
  -v : ($VERBOSE)   verbose
  -x : ($DEBUG)     debug

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 Documentation/networking/pktgen.txt      |   29 ++++++++++--
 samples/pktgen/pktgen.conf-1-1           |   59 -------------------------
 samples/pktgen/pktgen_sample01_simple.sh |   71 ++++++++++++++++++++++++++++++
 3 files changed, 94 insertions(+), 65 deletions(-)
 delete mode 100755 samples/pktgen/pktgen.conf-1-1
 create mode 100755 samples/pktgen/pktgen_sample01_simple.sh

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index e7ae8b2..f2f1033 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -219,10 +219,30 @@ Examples:
 Sample scripts
 ==============
 
-A collection of small tutorial scripts for pktgen is in the
-samples/pktgen directory:
+A collection of tutorial scripts and helpers for pktgen is in the
+samples/pktgen directory. The helper parameters.sh file support easy
+and consistant parameter parsing across the sample scripts.
+
+Usage example and help:
+ ./pktgen_sample01_simple.sh -i eth4 -m 00:1B:21:3C:9D:F8 -d 192.168.8.2
+
+Usage: ./pktgen_sample01_simple.sh [-vx] -i ethX
+  -i : ($DEV)       output interface/device (required)
+  -s : ($PKT_SIZE)  packet size
+  -d : ($DEST_IP)   destination IP
+  -m : ($DST_MAC)   destination MAC-addr
+  -t : ($THREADS)   threads to start
+  -c : ($SKB_CLONE) SKB clones send before alloc new SKB
+  -b : ($BURST)     HW level bursting of SKBs
+  -v : ($VERBOSE)   verbose
+  -x : ($DEBUG)     debug
+
+The global variables being set are also listed.  E.g. the required
+interface/device parameter "-i" sets variable $DEV.  Copy the
+pktgen_sampleXX scripts and modify them to fit your own needs.
+
+The old scripts:
 
-pktgen.conf-1-1                  # 1 CPU 1 dev 
 pktgen.conf-1-2                  # 1 CPU 2 dev
 pktgen.conf-2-1                  # 2 CPU's 1 dev 
 pktgen.conf-2-2                  # 2 CPU's 2 dev
@@ -231,9 +251,6 @@ pktgen.conf-1-1-ip6              # 1 CPU 1 dev ipv6
 pktgen.conf-1-1-ip6-rdos         # 1 CPU 1 dev ipv6  w. route DoS
 pktgen.conf-1-1-flows            # 1 CPU 1 dev multiple flows.
 
-Run in shell: ./pktgen.conf-X-Y
-This does all the setup including sending.
-
 
 Interrupt affinity
 ===================
diff --git a/samples/pktgen/pktgen.conf-1-1 b/samples/pktgen/pktgen.conf-1-1
deleted file mode 100755
index f91daad..0000000
--- a/samples/pktgen/pktgen.conf-1-1
+++ /dev/null
@@ -1,59 +0,0 @@
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
diff --git a/samples/pktgen/pktgen_sample01_simple.sh b/samples/pktgen/pktgen_sample01_simple.sh
new file mode 100755
index 0000000..8c9d318
--- /dev/null
+++ b/samples/pktgen/pktgen_sample01_simple.sh
@@ -0,0 +1,71 @@
+#!/bin/bash
+#
+# Simple example:
+#  * pktgen sending with single thread and single interface
+#  * flow variation via random UDP source port
+#
+basedir=`dirname $0`
+source ${basedir}/functions.sh
+root_check_run_with_sudo "$@"
+
+# Parameter parsing via include
+# - go look in parameters.sh to see which setting are avail
+# - required param is the interface "-i" stored in $DEV
+source ${basedir}/parameters.sh
+#
+# Set some default params, if they didn't get set
+[ -z "$DEST_IP" ] && DEST_IP="198.18.0.42"
+[ -z "$CLONE_SKB" ] && CLONE_SKB="0"
+# Example enforce param "-m" for dst_mac
+[ -z "$DST_MAC" ] && usage && err 2 "Must specify -m dst_mac"
+
+# Base Config
+DELAY="0"        # Zero means max speed
+COUNT="100000"   # Zero means indefinitely
+
+# Flow variation random source port between min and max
+UDP_MIN=9
+UDP_MAX=109
+
+# General cleanup everything since last run
+# (especially important if other threads were configured by other scripts)
+pg_ctrl "reset"
+
+# Add remove all other devices and add_device $DEV to thread 0
+thread=0
+pg_thread $thread "rem_device_all"
+pg_thread $thread "add_device" $DEV
+
+# How many packets to send (zero means indefinitely)
+pg_set $DEV "count $COUNT"
+
+# Reduce alloc cost by sending same SKB many times
+# - this obviously affects the randomness within the packet
+pg_set $DEV "clone_skb $CLONE_SKB"
+
+# Set packet size
+pg_set $DEV "pkt_size $PKT_SIZE"
+
+# Delay between packets (zero means max speed)
+pg_set $DEV "delay $DELAY"
+
+# Flag example disabling timestamping
+pg_set $DEV "flag NO_TIMESTAMP"
+
+# Destination
+pg_set $DEV "dst_mac $DST_MAC"
+pg_set $DEV "dst $DEST_IP"
+
+# Setup random UDP port src range
+pg_set $DEV "flag UDPSRC_RND"
+pg_set $DEV "udp_src_min $UDP_MIN"
+pg_set $DEV "udp_src_max $UDP_MAX"
+
+# start_run
+echo "Running... ctrl^C to stop" >&2
+pg_ctrl "start"
+echo "Done" >&2
+
+# Print results
+echo "Result device: $DEV"
+cat /proc/net/pktgen/$DEV
