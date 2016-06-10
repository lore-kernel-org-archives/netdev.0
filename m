From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,
 v2] tools: hv: Add a script to help bonding synthetic and VF NICs
Date: Fri, 10 Jun 2016 14:23:12 -0700
Message-ID: <1465593792-31672-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, haiyangz@microsoft.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

This script helps to create bonding network devices based on synthetic NIC
(the virtual network adapter usually provided by Hyper-V) and the matching
VF NIC (SRIOV virtual function). So the synthetic NIC and VF NIC can
function as one network device, and fail over to the synthetic NIC if VF is
down.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
v2: Make it to be distro neutral.
---
 tools/hv/bondvf.sh |   79 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 79 insertions(+), 0 deletions(-)
 create mode 100755 tools/hv/bondvf.sh

diff --git a/tools/hv/bondvf.sh b/tools/hv/bondvf.sh
new file mode 100755
index 0000000..ec7abf1
--- /dev/null
+++ b/tools/hv/bondvf.sh
@@ -0,0 +1,79 @@
+#!/bin/bash
+
+# The script helps creating bonding network devices based on synthetic NIC
+# (the virtual network adapter usually provided by Hyper-V) and the matching
+# VF NIC (SRIOV virtual function). So the synthetic NIC and VF NIC can
+# function as one network device, and fail over to the synthetic NIC if VF is
+# down.
+#
+# Usage:
+# - After configured vSwitch and vNIC with SRIOV, start Linux virtual
+#   machine (VM)
+# - Run this script on the VM. It will list the NIC pairs which should be
+#   bonded together. Also indicates which one should be the primary slave.
+# - User may create bonding NIC configurations based on the Distro manual.
+#   The bonding mode shoudl be "active-backup".
+#   Then, reboot the VM, so that the bonding config are enabled.
+#
+
+sysdir=/sys/class/net
+netvsc_cls={f8615163-df3e-46c5-913f-f2d2f965ed0e}
+bondcnt=0
+
+# Get a list of ethernet names
+list_eth=(`cd $sysdir && ls -d */ | cut -d/ -f1 | grep -v bond`)
+eth_cnt=${#list_eth[@]}
+
+echo List of net devices:
+
+# Get the MAC addresses
+for (( i=0; i < $eth_cnt; i++ ))
+do
+	list_mac[$i]=`cat $sysdir/${list_eth[$i]}/address`
+	echo ${list_eth[$i]}, ${list_mac[$i]}
+done
+
+# Find NIC with matching MAC
+for (( i=0; i < $eth_cnt-1; i++ ))
+do
+	for (( j=i+1; j < $eth_cnt; j++ ))
+	do
+		if [ "${list_mac[$i]}" = "${list_mac[$j]}" ]
+		then
+			list_match[$i]=${list_eth[$j]}
+			break
+		fi
+	done
+done
+
+function create_bond_cfg {
+	echo $'\nBond name:' $1
+	echo should include primary slave: $2, secondary slave: $3
+}
+
+function create_bond {
+	local bondname=bond$bondcnt
+
+	local class_id1=`cat $sysdir/$1/device/class_id 2>/dev/null`
+	local class_id2=`cat $sysdir/$2/device/class_id 2>/dev/null`
+
+	if [ "$class_id1" = "$netvsc_cls" ]
+	then
+		create_bond_cfg $bondname $2 $1
+	elif [ "$class_id2" = "$netvsc_cls" ]
+	then
+		create_bond_cfg $bondname $1 $2
+	else
+		return 0
+	fi
+
+	let bondcnt=bondcnt+1
+}
+
+for (( i=0; i < $eth_cnt-1; i++ ))
+do
+        if [ -n "${list_match[$i]}" ]
+        then
+		create_bond ${list_eth[$i]} ${list_match[$i]}
+        fi
+done
-- 
1.7.4.1
