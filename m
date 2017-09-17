From: Robert Hoo <robert.hu@linux.intel.com>
Subject: [pktgen script v2 1/2] Add some helper functions
Date: Sun, 17 Sep 2017 20:36:37 +0800
Message-ID: <1505651798-106642-2-git-send-email-robert.hu@linux.intel.com>
References: <1505651798-106642-1-git-send-email-robert.hu@linux.intel.com>
Cc: netdev@vger.kernel.org, robert.hu@intel.com
To: brouer@redhat.com, davem@davemloft.net, tariqt@mellanox.com,
        kyle.leet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:56558 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750885AbdIQMgs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 17 Sep 2017 08:36:48 -0400
In-Reply-To: <1505651798-106642-1-git-send-email-robert.hu@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Hoo <robert.hu@intel.com>

1. given a device, get its NUMA belongings
2. given a device, get its queues' irq numbers.
3. given a NUMA node, get its cpu id list.

Signed-off-by: Robert Hoo <robert.hu@intel.com>
---
 pktgen/functions.sh | 44 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/pktgen/functions.sh b/pktgen/functions.sh
index 205e4cd..09dfe7a 100644
--- a/pktgen/functions.sh
+++ b/pktgen/functions.sh
@@ -119,3 +119,47 @@ function root_check_run_with_sudo() {
 	err 4 "cannot perform sudo run of $0"
     fi
 }
+
+# Exact input device's NUMA node info
+function get_iface_node()
+{
+    local node=$(</sys/class/net/$1/device/numa_node)
+    if [[ $node == -1 ]]; then
+        echo 0
+    else
+        echo $node
+    fi
+}
+
+# Given an Dev/iface, get its queues' irq numbers
+function get_iface_irqs()
+{
+	local IFACE=$1
+	local queues="${IFACE}-.*TxRx"
+
+	irqs=$(grep "$queues" /proc/interrupts | cut -f1 -d:)
+	[ -z "$irqs" ] && irqs=$(grep $IFACE /proc/interrupts | cut -f1 -d:)
+	[ -z "$irqs" ] && irqs=$(for i in `ls -Ux /sys/class/net/$IFACE/device/msi_irqs` ;\
+	    do grep "$i:.*TxRx" /proc/interrupts | grep -v fdir | cut -f 1 -d : ;\
+	    done)
+	[ -z "$irqs" ] && err 3 "Could not find interrupts for $IFACE"
+
+	echo $irqs
+}
+
+# Given a NUMA node, return cpu ids belonging to it.
+function get_node_cpus()
+{
+	local node=$1
+	local node_cpu_list
+	local node_cpu_range_list=`cut -f1- -d, --output-delimiter=" " \
+	                  /sys/devices/system/node/node$node/cpulist`
+
+	for cpu_range in $node_cpu_range_list
+	do
+	    node_cpu_list="$node_cpu_list "`seq -s " " ${cpu_range//-/ }`
+	done
+
+	echo $node_cpu_list
+}
+
-- 
1.8.3.1
