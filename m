From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] tools: hv: Add a script for bonding synthetic and VF
 NICs
Date: Thu, 19 May 2016 10:23:38 -0700
Message-ID: <1463678618-26049-1-git-send-email-haiyangz@microsoft.com>
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

This example script creates bonding network devices based on synthetic NIC
(the virtual network adapter usually provided by Hyper-V) and the matching
VF NIC (SRIOV virtual function). So the synthetic NIC and VF NIC can
function as one network device, and fail over to the synthetic NIC if VF is
down.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 tools/hv/bondvf.sh |  132 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 132 insertions(+), 0 deletions(-)
 create mode 100755 tools/hv/bondvf.sh

diff --git a/tools/hv/bondvf.sh b/tools/hv/bondvf.sh
new file mode 100755
index 0000000..2758d60
--- /dev/null
+++ b/tools/hv/bondvf.sh
@@ -0,0 +1,132 @@
+#!/bin/bash
+
+# This example script creates bonding network devices based on synthetic NIC
+# (the virtual network adapter usually provided by Hyper-V) and the matching
+# VF NIC (SRIOV virtual function). So the synthetic NIC and VF NIC can
+# function as one network device, and fail over to the synthetic NIC if VF is
+# down.
+#
+# Usage:
+# - After configured vSwitch and vNIC with SRIOV, start Linux virtual
+#   machine (VM)
+# - Run this scripts on the VM. It will create configuration files in
+#   /etc/sysconfig/network-scripts/
+# - Reboot the VM, so that the bonding config are enabled.
+#
+# The config files are DHCP by default. You may edit them if you need to change
+# to Static IP or change other settings. The file name is, for example:
+#   /etc/sysconfig/network-scripts/ifcfg-bond0
+#
+# Each Distro is expected to implement this script in a distro specific
+# fashion.
+#
+# This example script is based on a RHEL environment.
+#
+# Here is an example of the bonding configuration file:
+#   DEVICE=bond0
+#   TYPE=Bond
+#   BOOTPROTO=dhcp
+#   ONBOOT=yes
+#   NM_CONTROLLED=no
+#   PEERDNS=yes
+#   IPV6INIT=yes
+#   BONDING_MASTER=yes
+#   BONDING_OPTS="mode=active-backup miimon=100 primary=eth1"
+#
+
+sysdir=/sys/class/net
+cfgdir=/etc/sysconfig/network-scripts
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
+function create_eth_cfg {
+	local fn=$cfgdir/ifcfg-$1
+
+	echo creating: $fn for $2
+
+	rm -f $fn
+	echo DEVICE=$1 >>$fn
+	echo TYPE=Ethernet >>$fn
+	echo BOOTPROTO=none >>$fn
+	echo ONBOOT=yes >>$fn
+	echo NM_CONTROLLED=no >>$fn
+	echo PEERDNS=yes >>$fn
+	echo IPV6INIT=yes >>$fn
+	echo MASTER=$2 >>$fn
+	echo SLAVE=yes >>$fn
+}
+
+function create_bond_cfg {
+	local fn=$cfgdir/ifcfg-$1
+
+	echo $'\nBond name:' $1
+	echo creating: $fn with primary slave: $2
+
+	rm -f $fn
+	echo DEVICE=$1 >>$fn
+	echo TYPE=Bond >>$fn
+	echo BOOTPROTO=dhcp >>$fn
+	echo ONBOOT=yes >>$fn
+	echo NM_CONTROLLED=no >>$fn
+	echo PEERDNS=yes >>$fn
+	echo IPV6INIT=yes >>$fn
+	echo BONDING_MASTER=yes >>$fn
+	echo BONDING_OPTS=\"mode=active-backup miimon=100 primary=$2\" >>$fn
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
+		create_bond_cfg $bondname $2
+	elif [ "$class_id2" = "$netvsc_cls" ]
+	then
+		create_bond_cfg $bondname $1
+	else
+		return 0
+	fi
+
+	create_eth_cfg $1 $bondname
+	create_eth_cfg $2 $bondname
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
+
-- 
1.7.4.1
