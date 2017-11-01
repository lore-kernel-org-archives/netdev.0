From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/4] samples/pktgen: add script
 pktgen_sample06_numa_awared_queue_irq_affinity.sh
Date: Wed, 01 Nov 2017 11:41:14 +0100
Message-ID: <150953287429.29671.12765792138297156463.stgit@firesoul>
References: <150953283424.29671.6809291616813585256.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert@herjulf.se>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        robert.hu@intel.com, pabeni@redhat.com, kafai@fb.com,
        tariqt@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48982 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753474AbdKAKlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 06:41:16 -0400
In-Reply-To: <150953283424.29671.6809291616813585256.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Hoo <robert.hu@intel.com>

This script simply does:

* Detect $DEV's NUMA node belonging.

* Bind each thread (processor of NUMA locality) with each $DEV queue's
  irq affinity, 1:1 mapping.

* How many '-t' threads input determines how many queues will be utilized.

If '-f' designates first cpu id, then offset in the NUMA node's cpu list.

(Changes by Jesper: allow changing count from cmdline via '-n')

Signed-off-by: Robert Hoo <robert.hu@intel.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 ...tgen_sample06_numa_awared_queue_irq_affinity.sh |   97 ++++++++++++++++++++
 1 file changed, 97 insertions(+)
 create mode 100755 samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh

diff --git a/samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh b/samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh
new file mode 100755
index 000000000000..353adc17205e
--- /dev/null
+++ b/samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh
@@ -0,0 +1,97 @@
+#!/bin/bash
+#
+# Multiqueue: Using pktgen threads for sending on multiple CPUs
+#  * adding devices to kernel threads which are in the same NUMA node
+#  * bound devices queue's irq affinity to the threads, 1:1 mapping
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
+[ -z "$COUNT" ]     && COUNT="20000000"   # Zero means indefinitely
+[ -z "$CLONE_SKB" ] && CLONE_SKB="0"
+
+# Flow variation random source port between min and max
+UDP_MIN=9
+UDP_MAX=109
+
+node=`get_iface_node $DEV`
+irq_array=(`get_iface_irqs $DEV`)
+cpu_array=(`get_node_cpus $node`)
+
+[ $THREADS -gt ${#irq_array[*]} -o $THREADS -gt ${#cpu_array[*]}  ] && \
+	err 1 "Thread number $THREADS exceeds: min (${#irq_array[*]},${#cpu_array[*]})"
+
+# (example of setting default params in your script)
+if [ -z "$DEST_IP" ]; then
+    [ -z "$IP6" ] && DEST_IP="198.18.0.42" || DEST_IP="FD00::1"
+fi
+[ -z "$DST_MAC" ] && DST_MAC="90:e2:ba:ff:ff:ff"
+
+# General cleanup everything since last run
+pg_ctrl "reset"
+
+# Threads are specified with parameter -t value in $THREADS
+for ((i = 0; i < $THREADS; i++)); do
+    # The device name is extended with @name, using thread number to
+    # make then unique, but any name will do.
+    # Set the queue's irq affinity to this $thread (processor)
+    # if '-f' is designated, offset cpu id
+    thread=${cpu_array[$((i+F_THREAD))]}
+    dev=${DEV}@${thread}
+    echo $thread > /proc/irq/${irq_array[$i]}/smp_affinity_list
+    info "irq ${irq_array[$i]} is set affinity to `cat /proc/irq/${irq_array[$i]}/smp_affinity_list`"
+
+    # Add remove all other devices and add_device $dev to thread
+    pg_thread $thread "rem_device_all"
+    pg_thread $thread "add_device" $dev
+
+    # select queue and bind the queue and $dev in 1:1 relationship
+    queue_num=$i
+    info "queue number is $queue_num"
+    pg_set $dev "queue_map_min $queue_num"
+    pg_set $dev "queue_map_max $queue_num"
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
+    pg_set $dev "dst$IP6 $DEST_IP"
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
+for ((i = 0; i < $THREADS; i++)); do
+    thread=${cpu_array[$((i+F_THREAD))]}
+    dev=${DEV}@${thread}
+    echo "Device: $dev"
+    cat /proc/net/pktgen/$dev | grep -A2 "Result:"
+done
