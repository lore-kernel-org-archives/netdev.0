From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/4] samples/pktgen: Add some helper functions
Date: Wed, 01 Nov 2017 11:41:09 +0100
Message-ID: <150953286920.29671.11277440445060911896.stgit@firesoul>
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
Received: from mx1.redhat.com ([209.132.183.28]:59172 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752071AbdKAKlM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 06:41:12 -0400
In-Reply-To: <150953283424.29671.6809291616813585256.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Hoo <robert.hu@intel.com>

1. given a device, get its NUMA belongings
2. given a device, get its queues' irq numbers.
3. given a NUMA node, get its cpu id list.

Signed-off-by: Robert Hoo <robert.hu@intel.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/pktgen/functions.sh |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/samples/pktgen/functions.sh b/samples/pktgen/functions.sh
index 205e4cde4601..f8bb3cd0f4ce 100644
--- a/samples/pktgen/functions.sh
+++ b/samples/pktgen/functions.sh
@@ -119,3 +119,46 @@ function root_check_run_with_sudo() {
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
