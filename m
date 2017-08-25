From: Robert Hoo <robert.hu@intel.com>
Subject: [PATCH] pktgen: add a new sample script for 40G and above link
 testing
Date: Fri, 25 Aug 2017 10:24:30 +0800
Message-ID: <1503127531-134546-1-git-send-email-robert.hu@intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Cc: Robert Ho <robert.hu@intel.com>
To: robert.hu@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7106 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754191AbdHYCY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 22:24:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Ho <robert.hu@intel.com>

It's hard to benchmark 40G+ network bandwidth using ordinary
tools like iperf, netperf. I then tried with pktgen multiqueue sample
scripts, but still cannot reach line rate.
I then derived this NUMA awared irq affinity sample script from
multi-queue sample one, successfully benchmarked 40G link. I think this can
also be useful for 100G reference, though I haven't got device to test.

This script simply does:
Detect $DEV's NUMA node belonging.
Bind each thread (processor from that NUMA node) with each $DEV queue's
irq affinity, 1:1 mapping.
How many '-t' threads input determines how many queues will be
utilized.

Tested with Intel XL710 NIC with Cisco 3172 switch.

It would be even slightly better if the irqbalance service is turned
off outside.

Referrences:
https://people.netfilter.org/hawk/presentations/LCA2015/net_stack_challenge=
s_100G_LCA2015.pdf
http://www.intel.cn/content/dam/www/public/us/en/documents/reference-guides=
/xl710-x710-performance-tuning-linux-guide.pdf

Signed-off-by: Robert Hoo <robert.hu@intel.com>
---
 ...tgen_sample06_numa_awared_queue_irq_affinity.sh | 132 +++++++++++++++++=
++++
 1 file changed, 132 insertions(+)
 create mode 100755 samples/pktgen/pktgen_sample06_numa_awared_queue_irq_af=
finity.sh

diff --git a/samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.=
sh b/samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh
new file mode 100755
index 0000000..f0ee25c
--- /dev/null
+++ b/samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh
@@ -0,0 +1,132 @@
+#!/bin/bash
+#
+# Multiqueue: Using pktgen threads for sending on multiple CPUs
+#  * adding devices to kernel threads which are in the same NUMA node
+#  * bound devices queue's irq affinity to the threads, 1:1 mapping
+#  * notice the naming scheme for keeping device names unique
+#  * nameing scheme: dev@thread_number
+#  * flow variation via random UDP source port
+#
+basedir=3D`dirname $0`
+source ${basedir}/functions.sh
+root_check_run_with_sudo "$@"
+#
+# Required param: -i dev in $DEV
+source ${basedir}/parameters.sh
+
+get_iface_node()
+{
+	echo `cat /sys/class/net/$1/device/numa_node`
+}
+
+get_iface_irqs()
+{
+	local IFACE=3D$1
+	local queues=3D"${IFACE}-.*TxRx"
+
+	irqs=3D$(grep "$queues" /proc/interrupts | cut -f1 -d:)
+	[ -z "$irqs" ] && irqs=3D$(grep $IFACE /proc/interrupts | cut -f1 -d:)
+	[ -z "$irqs" ] && irqs=3D$(for i in `ls -Ux /sys/class/net/$IFACE/device/=
msi_irqs` ;\
+		do grep "$i:.*TxRx" /proc/interrupts | grep -v fdir | cut -f 1 -d : ;\
+	    done)
+	[ -z "$irqs" ] && echo "Error: Could not find interrupts for $IFACE"
+
+	echo $irqs
+}
+
+get_node_cpus()
+{
+	local node=3D$1
+	local node_cpu_list
+	local node_cpu_range_list=3D`cut -f1- -d, --output-delimiter=3D" " \
+			/sys/devices/system/node/node$node/cpulist`
+
+	for cpu_range in $node_cpu_range_list
+	do
+		node_cpu_list=3D"$node_cpu_list "`seq -s " " ${cpu_range//-/ }`
+	done
+
+	echo $node_cpu_list
+}
+
+
+# Base Config
+DELAY=3D"0"        # Zero means max speed
+COUNT=3D"20000000"   # Zero means indefinitely
+[ -z "$CLONE_SKB" ] && CLONE_SKB=3D"0"
+
+# Flow variation random source port between min and max
+UDP_MIN=3D9
+UDP_MAX=3D109
+
+node=3D`get_iface_node $DEV`
+irq_array=3D(`get_iface_irqs $DEV`)
+cpu_array=3D(`get_node_cpus $node`)
+
+[ $THREADS -gt ${#irq_array[*]} -o $THREADS -gt ${#cpu_array[*]}  ] && \
+	err 1 "Thread number $THREADS exceeds: min (${#irq_array[*]},${#cpu_array=
[*]})"
+
+# (example of setting default params in your script)
+if [ -z "$DEST_IP" ]; then
+    [ -z "$IP6" ] && DEST_IP=3D"198.18.0.42" || DEST_IP=3D"FD00::1"
+fi
+[ -z "$DST_MAC" ] && DST_MAC=3D"90:e2:ba:ff:ff:ff"
+
+# General cleanup everything since last run
+pg_ctrl "reset"
+
+# Threads are specified with parameter -t value in $THREADS
+for ((i =3D 0; i < $THREADS; i++)); do
+    # The device name is extended with @name, using thread number to
+    # make then unique, but any name will do.
+    # Set the queue's irq affinity to this $thread (processor)
+    thread=3D${cpu_array[$i]}
+    dev=3D${DEV}@${thread}
+    echo $thread > /proc/irq/${irq_array[$i]}/smp_affinity_list
+    echo "irq ${irq_array[$i]} is set affinity to `cat /proc/irq/${irq_arr=
ay[$i]}/smp_affinity_list`"
+
+    # Add remove all other devices and add_device $dev to thread
+    pg_thread $thread "rem_device_all"
+    pg_thread $thread "add_device" $dev
+
+    # select queue and bind the queue and $dev in 1:1 relationship
+    queue_num=3D$i
+    echo "queue number is $queue_num"
+    pg_set $dev "queue_map_min $queue_num"
+    pg_set $dev "queue_map_max $queue_num"
+
+    # Notice config queue to map to cpu (mirrors smp_processor_id())
+    # It is beneficial to map IRQ /proc/irq/*/smp_affinity 1:1 to CPU numb=
er
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
+for ((i =3D 0; i < $THREADS; i++)); do
+    thread=3D${cpu_array[$i]}
+    dev=3D${DEV}@${thread}
+    echo "Device: $dev"
+    cat /proc/net/pktgen/$dev | grep -A2 "Result:"
+done
--=20
1.8.3.1
