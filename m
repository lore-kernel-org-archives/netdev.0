From: Eduardo Otubo <otubo@redhat.com>
Subject: [PATCH] hv_set_ifconfig.sh double check before setting ip
Date: Tue,  8 Aug 2017 15:53:45 +0200
Message-ID: <20170808135345.17027-1-otubo@redhat.com>
Cc: linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        "K . Y . Srinivasan" <kys@microsoft.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the behavior of the hv_set_ifconfig script when setting
the interface ip. Sometimes the interface has already been configured by
network daemon, in this case hv_set_ifconfig causes "RTNETLINK: file
exists error"; in order to avoid this error this patch makes sure double
checks the interface before trying anything.

Signed-off-by: Eduardo Otubo <otubo@redhat.com>
---
 tools/hv/hv_set_ifconfig.sh | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/tools/hv/hv_set_ifconfig.sh b/tools/hv/hv_set_ifconfig.sh
index 735aafd64a3f..ba5e4aa4efe2 100755
--- a/tools/hv/hv_set_ifconfig.sh
+++ b/tools/hv/hv_set_ifconfig.sh
@@ -46,19 +46,26 @@
 # is expected to return the configuration that is set via the SET
 # call.
 #
+interface=$(echo $1 | awk -F - '{ print $2 }')
 
+current_ip=$(ip addr show $interface|grep "inet ");
+config_file_ip=$(grep IPADDR $1|cut -d"=" -f2);
 
+current_ipv6=$(ip addr show $interface|grep "inet6 ");
+config_file_ipv6=$(grep IPV6ADDR $1|cut -d"=" -f2);
+config_file_ipv6_netmask=$(grep IPV6NETMASK $1|cut -d"=" -f2);
+config_file_ipv6=${config_file_ipv6}/${config_file_ipv6_netmask};
 
-echo "IPV6INIT=yes" >> $1
-echo "NM_CONTROLLED=no" >> $1
-echo "PEERDNS=yes" >> $1
-echo "ONBOOT=yes" >> $1
-
-
-cp $1 /etc/sysconfig/network-scripts/
-
+# only set the IP if it's not configured yet
+if [[ $(test "${current_ip#*$config_file_ip}") == "$config_file_ip" \
+    || $(test "${current_ipv6#*$config_file_ipv6}") == "$current_ipv6" ]]; then
+    echo "IPV6INIT=yes" >> $1
+    echo "NM_CONTROLLED=no" >> $1
+    echo "PEERDNS=yes" >> $1
+    echo "ONBOOT=yes" >> $1
 
-interface=$(echo $1 | awk -F - '{ print $2 }')
+    cp $1 /etc/sysconfig/network-scripts/
 
-/sbin/ifdown $interface 2>/dev/null
-/sbin/ifup $interface 2>/dev/null
+    /sbin/ifdown $interface 2>/dev/null
+    /sbin/ifup $interface 2>/dev/null
+fi
-- 
2.13.4
