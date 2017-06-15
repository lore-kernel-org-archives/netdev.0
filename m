From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 2/2] pktgen: Specify the index of first thread
Date: Thu, 15 Jun 2017 19:07:22 +0300
Message-ID: <1497542842-13721-3-git-send-email-tariqt@mellanox.com>
References: <1497542842-13721-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60234 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751923AbdFOQHm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 12:07:42 -0400
In-Reply-To: <1497542842-13721-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use "-f <num>", to specify the index of the first
sender thread.
In default first thread is #0.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/pktgen/README.rst                            |  1 +
 samples/pktgen/parameters.sh                         | 20 ++++++++++++++------
 .../pktgen/pktgen_bench_xmit_mode_netif_receive.sh   |  4 ++--
 samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh  |  4 ++--
 samples/pktgen/pktgen_sample02_multiqueue.sh         |  4 ++--
 samples/pktgen/pktgen_sample03_burst_single_flow.sh  |  4 ++--
 samples/pktgen/pktgen_sample04_many_flows.sh         |  4 ++--
 samples/pktgen/pktgen_sample05_flow_per_thread.sh    |  4 ++--
 8 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/samples/pktgen/README.rst b/samples/pktgen/README.rst
index c018d67da1a1..ff8929da61c5 100644
--- a/samples/pktgen/README.rst
+++ b/samples/pktgen/README.rst
@@ -21,6 +21,7 @@ across the sample scripts.  Usage example is printed on errors::
   -d : ($DEST_IP)   destination IP
   -m : ($DST_MAC)   destination MAC-addr
   -t : ($THREADS)   threads to start
+  -f : ($F_THREAD)  index of first thread (zero indexed CPU number)
   -c : ($SKB_CLONE) SKB clones send before alloc new SKB
   -n : ($COUNT)     num messages to send per thread, 0 means indefinitely
   -b : ($BURST)     HW level bursting of SKBs
diff --git a/samples/pktgen/parameters.sh b/samples/pktgen/parameters.sh
index 036147594a20..3a6244d5f47a 100644
--- a/samples/pktgen/parameters.sh
+++ b/samples/pktgen/parameters.sh
@@ -10,6 +10,7 @@ function usage() {
     echo "  -d : (\$DEST_IP)   destination IP"
     echo "  -m : (\$DST_MAC)   destination MAC-addr"
     echo "  -t : (\$THREADS)   threads to start"
+    echo "  -f : (\$F_THREAD)  index of first thread (zero indexed CPU number)"
     echo "  -c : (\$SKB_CLONE) SKB clones send before alloc new SKB"
     echo "  -n : (\$COUNT)     num messages to send per thread, 0 means indefinitely"
     echo "  -b : (\$BURST)     HW level bursting of SKBs"
@@ -21,7 +22,7 @@ function usage() {
 
 ##  --- Parse command line arguments / parameters ---
 ## echo "Commandline options:"
-while getopts "s:i:d:m:t:c:n:b:vxh6" option; do
+while getopts "s:i:d:m:f:t:c:n:b:vxh6" option; do
     case $option in
         i) # interface
           export DEV=$OPTARG
@@ -39,11 +40,13 @@ while getopts "s:i:d:m:t:c:n:b:vxh6" option; do
           export DST_MAC=$OPTARG
 	  info "Destination MAC set to: DST_MAC=$DST_MAC"
           ;;
+        f)
+	  export F_THREAD=$OPTARG
+	  info "Index of first thread (zero indexed CPU number): $F_THREAD"
+          ;;
         t)
 	  export THREADS=$OPTARG
-          export CPU_THREADS=$OPTARG
-	  let "CPU_THREADS -= 1"
-	  info "Number of threads to start: $THREADS (0 to $CPU_THREADS)"
+	  info "Number of threads to start: $THREADS"
           ;;
         c)
 	  export CLONE_SKB=$OPTARG
@@ -82,12 +85,17 @@ if [ -z "$PKT_SIZE" ]; then
     info "Default packet size set to: set to: $PKT_SIZE bytes"
 fi
 
+if [ -z "$F_THREAD" ]; then
+    # First thread (F_THREAD) reference the zero indexed CPU number
+    export F_THREAD=0
+fi
+
 if [ -z "$THREADS" ]; then
-    # Zero CPU threads means one thread, because CPU numbers are zero indexed
-    export CPU_THREADS=0
     export THREADS=1
 fi
 
+export L_THREAD=$(( THREADS + F_THREAD - 1 ))
+
 if [ -z "$DEV" ]; then
     usage
     err 2 "Please specify output device"
diff --git a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
index d2694a12de61..e5bfe759a0fb 100755
--- a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
+++ b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
@@ -48,7 +48,7 @@ DELAY="0"        # Zero means max speed
 pg_ctrl "reset"
 
 # Threads are specified with parameter -t value in $THREADS
-for ((thread = 0; thread < $THREADS; thread++)); do
+for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
     # The device name is extended with @name, using thread number to
     # make then unique, but any name will do.
     dev=${DEV}@${thread}
@@ -81,7 +81,7 @@ pg_ctrl "start"
 echo "Done" >&2
 
 # Print results
-for ((thread = 0; thread < $THREADS; thread++)); do
+for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
     dev=${DEV}@${thread}
     echo "Device: $dev"
     cat /proc/net/pktgen/$dev | grep -A2 "Result:"
diff --git a/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh b/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
index 43604c2db726..1ad878e95539 100755
--- a/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
+++ b/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
@@ -31,7 +31,7 @@ DELAY="0"        # Zero means max speed
 pg_ctrl "reset"
 
 # Threads are specified with parameter -t value in $THREADS
-for ((thread = 0; thread < $THREADS; thread++)); do
+for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
     # The device name is extended with @name, using thread number to
     # make then unique, but any name will do.
     dev=${DEV}@${thread}
@@ -61,7 +61,7 @@ pg_ctrl "start"
 echo "Done" >&2
 
 # Print results
-for ((thread = 0; thread < $THREADS; thread++)); do
+for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
     dev=${DEV}@${thread}
     echo "Device: $dev"
     cat /proc/net/pktgen/$dev | grep -A2 "Result:"
diff --git a/samples/pktgen/pktgen_sample02_multiqueue.sh b/samples/pktgen/pktgen_sample02_multiqueue.sh
index 164194d1c79b..cbdd3e2bceff 100755
--- a/samples/pktgen/pktgen_sample02_multiqueue.sh
+++ b/samples/pktgen/pktgen_sample02_multiqueue.sh
@@ -33,7 +33,7 @@ fi
 pg_ctrl "reset"
 
 # Threads are specified with parameter -t value in $THREADS
-for ((thread = 0; thread < $THREADS; thread++)); do
+for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
     # The device name is extended with @name, using thread number to
     # make then unique, but any name will do.
     dev=${DEV}@${thread}
@@ -71,7 +71,7 @@ pg_ctrl "start"
 echo "Done" >&2
 
 # Print results
-for ((thread = 0; thread < $THREADS; thread++)); do
+for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
     dev=${DEV}@${thread}
     echo "Device: $dev"
     cat /proc/net/pktgen/$dev | grep -A2 "Result:"
diff --git a/samples/pktgen/pktgen_sample03_burst_single_flow.sh b/samples/pktgen/pktgen_sample03_burst_single_flow.sh
index e03dd4cd05ce..8d26e0ca683d 100755
--- a/samples/pktgen/pktgen_sample03_burst_single_flow.sh
+++ b/samples/pktgen/pktgen_sample03_burst_single_flow.sh
@@ -40,7 +40,7 @@ DELAY="0"  # Zero means max speed
 pg_ctrl "reset"
 
 # Threads are specified with parameter -t value in $THREADS
-for ((thread = 0; thread < $THREADS; thread++)); do
+for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
     dev=${DEV}@${thread}
 
     # Add remove all other devices and add_device $dev to thread
@@ -71,7 +71,7 @@ done
 # Run if user hits control-c
 function control_c() {
     # Print results
-    for ((thread = 0; thread < $THREADS; thread++)); do
+    for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
 	dev=${DEV}@${thread}
 	echo "Device: $dev"
 	cat /proc/net/pktgen/$dev | grep -A2 "Result:"
diff --git a/samples/pktgen/pktgen_sample04_many_flows.sh b/samples/pktgen/pktgen_sample04_many_flows.sh
index 0fc72d2bcd31..497fb7520464 100755
--- a/samples/pktgen/pktgen_sample04_many_flows.sh
+++ b/samples/pktgen/pktgen_sample04_many_flows.sh
@@ -36,7 +36,7 @@ fi
 pg_ctrl "reset"
 
 # Threads are specified with parameter -t value in $THREADS
-for ((thread = 0; thread < $THREADS; thread++)); do
+for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
     dev=${DEV}@${thread}
 
     # Add remove all other devices and add_device $dev to thread
@@ -78,7 +78,7 @@ done
 # Run if user hits control-c
 function print_result() {
     # Print results
-    for ((thread = 0; thread < $THREADS; thread++)); do
+    for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
 	dev=${DEV}@${thread}
 	echo "Device: $dev"
 	cat /proc/net/pktgen/$dev | grep -A2 "Result:"
diff --git a/samples/pktgen/pktgen_sample05_flow_per_thread.sh b/samples/pktgen/pktgen_sample05_flow_per_thread.sh
index f4fb79409fd0..ac9cfd6b2c0a 100755
--- a/samples/pktgen/pktgen_sample05_flow_per_thread.sh
+++ b/samples/pktgen/pktgen_sample05_flow_per_thread.sh
@@ -30,7 +30,7 @@ DELAY="0"  # Zero means max speed
 pg_ctrl "reset"
 
 # Threads are specified with parameter -t value in $THREADS
-for ((thread = 0; thread < $THREADS; thread++)); do
+for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
     dev=${DEV}@${thread}
 
     # Add remove all other devices and add_device $dev to thread
@@ -66,7 +66,7 @@ done
 # Run if user hits control-c
 function print_result() {
     # Print results
-    for ((thread = 0; thread < $THREADS; thread++)); do
+    for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
 	dev=${DEV}@${thread}
 	echo "Device: $dev"
 	cat /proc/net/pktgen/$dev | grep -A2 "Result:"
-- 
1.8.3.1
