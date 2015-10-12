From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: Documentation update, ip commands
Date: Mon, 12 Oct 2015 13:54:38 -0700
Message-ID: <1444683278-31731-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33790 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbbJLUyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 16:54:46 -0400
Received: by pabrc13 with SMTP id rc13so28041238pab.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 13:54:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ip commands with examples for creating VRF devics, enslaving interfaces
and dumping VRF-focused data (address, neighbors, routes).

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 Documentation/networking/vrf.txt | 301 ++++++++++++++++++++++++++++++++++++++-
 1 file changed, 299 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/vrf.txt b/Documentation/networking/vrf.txt
index 031ef4a63485..d52aa10cfe91 100644
--- a/Documentation/networking/vrf.txt
+++ b/Documentation/networking/vrf.txt
@@ -90,7 +90,304 @@ or to specify the output device using cmsg and IP_PKTINFO.
 
 Limitations
 -----------
-VRF device currently only works for IPv4. Support for IPv6 is under development.
-
 Index of original ingress interface is not available via cmsg. Will address
 soon.
+
+################################################################################
+
+Using iproute2 for VRFs
+=======================
+VRF devices do *not* have to start with 'vrf-'. That is a convention used here
+for emphasis of the device type, similar to use of 'br' in bridge names.
+
+1. Create a VRF
+
+   To instantiate a VRF device and associate it with a table:
+       $ ip link add dev NAME type vrf table ID
+
+   Remember to add the ip rules as well:
+       $ ip ru add oif NAME table 10
+       $ ip ru add iif NAME table 10
+       $ ip -6 ru add oif NAME table 10
+       $ ip -6 ru add iif NAME table 10
+
+   Without the rules route lookups are not directed to the table.
+
+   For example:
+   $ ip link add dev vrf-blue type vrf table 10
+   $ ip ru add pref 200 oif vrf-blue table 10
+   $ ip ru add pref 200 iif vrf-blue table 10
+   $ ip -6 ru add pref 200 oif vrf-blue table 10
+   $ ip -6 ru add pref 200 iif vrf-blue table 10
+
+
+2. List VRFs
+
+   To list VRFs that have been created:
+       $ ip [-d] link show type vrf
+         NOTE: The -d option is needed to show the table id
+
+   For example:
+   $ ip -d link show type vrf
+   11: vrf-mgmt: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
+       link/ether 72:b3:ba:91:e2:24 brd ff:ff:ff:ff:ff:ff promiscuity 0
+       vrf table 1 addrgenmode eui64
+   12: vrf-red: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
+       link/ether b6:6f:6e:f6:da:73 brd ff:ff:ff:ff:ff:ff promiscuity 0
+       vrf table 10 addrgenmode eui64
+   13: vrf-blue: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
+       link/ether 36:62:e8:7d:bb:8c brd ff:ff:ff:ff:ff:ff promiscuity 0
+       vrf table 66 addrgenmode eui64
+   14: vrf-green: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
+       link/ether e6:28:b8:63:70:bb brd ff:ff:ff:ff:ff:ff promiscuity 0
+       vrf table 81 addrgenmode eui64
+
+
+   Or in brief output:
+
+   $ ip -br link show type vrf
+   vrf-mgmt         UP             72:b3:ba:91:e2:24 <NOARP,MASTER,UP,LOWER_UP>
+   vrf-red          UP             b6:6f:6e:f6:da:73 <NOARP,MASTER,UP,LOWER_UP>
+   vrf-blue         UP             36:62:e8:7d:bb:8c <NOARP,MASTER,UP,LOWER_UP>
+   vrf-green        UP             e6:28:b8:63:70:bb <NOARP,MASTER,UP,LOWER_UP>
+
+
+3. Assign a Network Interface to a VRF
+
+   Network interfaces are assigned to a VRF by enslaving the netdevice to a
+   VRF device:
+       $ ip link set dev NAME master VRF-NAME
+
+   On enslavement connected and local routes are automatically moved to the
+   table associated with the VRF device.
+
+   For example:
+   $ ip link set dev eth0 master vrf-mgmt
+
+
+4. Show Devices Assigned to a VRF
+
+   To show devices that have been assigned to a specific VRF add the master
+   option to the ip command:
+       $ ip link show master VRF-NAME
+
+   For example:
+   $ ip link show master vrf-red
+   3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master vrf-red state UP mode DEFAULT group default qlen 1000
+       link/ether 02:00:00:00:02:02 brd ff:ff:ff:ff:ff:ff
+   4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master vrf-red state UP mode DEFAULT group default qlen 1000
+       link/ether 02:00:00:00:02:03 brd ff:ff:ff:ff:ff:ff
+   7: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master vrf-red state DOWN mode DEFAULT group default qlen 1000
+       link/ether 02:00:00:00:02:06 brd ff:ff:ff:ff:ff:ff
+
+
+   Or using the brief output:
+   $ ip -br link show master vrf-red
+   eth1             UP             02:00:00:00:02:02 <BROADCAST,MULTICAST,UP,LOWER_UP>
+   eth2             UP             02:00:00:00:02:03 <BROADCAST,MULTICAST,UP,LOWER_UP>
+   eth5             DOWN           02:00:00:00:02:06 <BROADCAST,MULTICAST>
+
+
+5. Show Neighbor Entries for a VRF
+
+   To list neighbor entries associated with devices enslaved to a VRF device
+   add the master option to the ip command:
+       $ ip [-6] neigh show master VRF-NAME
+
+   For example:
+   $  ip neigh show master vrf-red
+   10.2.1.254 dev eth1 lladdr a6:d9:c7:4f:06:23 REACHABLE
+   10.2.2.254 dev eth2 lladdr 5e:54:01:6a:ee:80 REACHABLE
+
+    $ ip -6 neigh show master vrf-red
+    2002:1::64 dev eth1 lladdr a6:d9:c7:4f:06:23 REACHABLE
+
+
+6. Show Addresses for a VRF
+
+   To show addresses for interfaces associated with a VRF add the master
+   option to the ip command:
+       $ ip addr show master VRF-NAME
+
+   For example:
+   $ ip addr show master vrf-red
+   3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master vrf-red state UP group default qlen 1000
+       link/ether 02:00:00:00:02:02 brd ff:ff:ff:ff:ff:ff
+       inet 10.2.1.2/24 brd 10.2.1.255 scope global eth1
+          valid_lft forever preferred_lft forever
+       inet6 2002:1::2/120 scope global
+          valid_lft forever preferred_lft forever
+       inet6 fe80::ff:fe00:202/64 scope link
+          valid_lft forever preferred_lft forever
+   4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master vrf-red state UP group default qlen 1000
+       link/ether 02:00:00:00:02:03 brd ff:ff:ff:ff:ff:ff
+       inet 10.2.2.2/24 brd 10.2.2.255 scope global eth2
+          valid_lft forever preferred_lft forever
+       inet6 2002:2::2/120 scope global
+          valid_lft forever preferred_lft forever
+       inet6 fe80::ff:fe00:203/64 scope link
+          valid_lft forever preferred_lft forever
+   7: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master vrf-red state DOWN group default qlen 1000
+       link/ether 02:00:00:00:02:06 brd ff:ff:ff:ff:ff:ff
+
+   Or in brief format:
+   $ ip -br addr show master vrf-red
+   eth1             UP             10.2.1.2/24 2002:1::2/120 fe80::ff:fe00:202/64
+   eth2             UP             10.2.2.2/24 2002:2::2/120 fe80::ff:fe00:203/64
+   eth5             DOWN
+
+
+7. Show Routes for a VRF
+
+   To show routes for a VRF use the ip command to display the table associated
+   with the VRF device:
+       $ ip [-6] route show table ID
+
+   For example:
+   $ ip route show table vrf-red
+   prohibit default
+   broadcast 10.2.1.0 dev eth1  proto kernel  scope link  src 10.2.1.2
+   10.2.1.0/24 dev eth1  proto kernel  scope link  src 10.2.1.2
+   local 10.2.1.2 dev eth1  proto kernel  scope host  src 10.2.1.2
+   broadcast 10.2.1.255 dev eth1  proto kernel  scope link  src 10.2.1.2
+   broadcast 10.2.2.0 dev eth2  proto kernel  scope link  src 10.2.2.2
+   10.2.2.0/24 dev eth2  proto kernel  scope link  src 10.2.2.2
+   local 10.2.2.2 dev eth2  proto kernel  scope host  src 10.2.2.2
+   broadcast 10.2.2.255 dev eth2  proto kernel  scope link  src 10.2.2.2
+
+   $ ip -6 route show table vrf-red
+   local 2002:1:: dev lo  proto none  metric 0  pref medium
+   local 2002:1::2 dev lo  proto none  metric 0  pref medium
+   2002:1::/120 dev eth1  proto kernel  metric 256  pref medium
+   local 2002:2:: dev lo  proto none  metric 0  pref medium
+   local 2002:2::2 dev lo  proto none  metric 0  pref medium
+   2002:2::/120 dev eth2  proto kernel  metric 256  pref medium
+   local fe80:: dev lo  proto none  metric 0  pref medium
+   local fe80:: dev lo  proto none  metric 0  pref medium
+   local fe80::ff:fe00:202 dev lo  proto none  metric 0  pref medium
+   local fe80::ff:fe00:203 dev lo  proto none  metric 0  pref medium
+   fe80::/64 dev eth1  proto kernel  metric 256  pref medium
+   fe80::/64 dev eth2  proto kernel  metric 256  pref medium
+   ff00::/8 dev vrf-red  metric 256  pref medium
+   ff00::/8 dev eth1  metric 256  pref medium
+   ff00::/8 dev eth2  metric 256  pref medium
+
+
+8. Route Lookup for a VRF
+
+   A test route lookup can be done for a VRF by adding the oif option to ip:
+       $ ip [-6] route get oif VRF-NAME ADDRESS
+
+   For example:
+   $ ip route get 10.2.1.40 oif vrf-red
+   10.2.1.40 dev eth1  table vrf-red  src 10.2.1.2
+       cache
+
+   $ ip -6 route get 2002:1::32 oif vrf-red
+   2002:1::32 from :: dev eth1  table vrf-red  proto kernel  src 2002:1::2  metric 256  pref medium
+
+
+9. Removing Network Interface from a VRF
+
+   Network interfaces are removed from a VRF by breaking the enslavement to
+   the VRF device:
+       $ ip link set dev NAME nomaster
+
+   Connected routes are moved back to the default table and local entries are
+   moved to the local table.
+
+   For example:
+   $ ip link set dev eth0 nomaster
+
+--------------------------------------------------------------------------------
+
+Commands used in this example:
+
+cat >> /etc/iproute2/rt_tables <<EOF
+1  vrf-mgmt
+10 vrf-red
+66 vrf-blue
+81 vrf-green
+EOF
+
+function vrf_create
+{
+    VRF=$1
+    TBID=$2
+    # create VRF device
+    ip link add vrf-${VRF} type vrf table ${TBID}
+
+    # add rules that direct lookups to vrf table
+    ip ru add pref 200 oif vrf-${VRF} table ${TBID}
+    ip ru add pref 200 iif vrf-${VRF} table ${TBID}
+    ip -6 ru add pref 200 oif vrf-${VRF} table ${TBID}
+    ip -6 ru add pref 200 iif vrf-${VRF} table ${TBID}
+
+    if [ "${VRF}" != "mgmt" ]; then
+        ip route add table ${TBID} prohibit default
+    fi
+    ip link set dev vrf-${VRF} up
+    ip link set dev vrf-${VRF} state up
+}
+
+vrf_create mgmt 1
+ip link set dev eth0 master vrf-mgmt
+
+vrf_create red 10
+ip link set dev eth1 master vrf-red
+ip link set dev eth2 master vrf-red
+ip link set dev eth5 master vrf-red
+
+vrf_create blue 66
+ip link set dev eth3 master vrf-blue
+
+vrf_create green 81
+ip link set dev eth4 master vrf-green
+
+
+Interface addresses from /etc/network/interfaces:
+auto eth0
+iface eth0 inet static
+      address 10.0.0.2
+      netmask 255.255.255.0
+      gateway 10.0.0.254
+
+iface eth0 inet6 static
+      address 2000:1::2
+      netmask 120
+
+auto eth1
+iface eth1 inet static
+      address 10.2.1.2
+      netmask 255.255.255.0
+
+iface eth1 inet6 static
+      address 2002:1::2
+      netmask 120
+
+auto eth2
+iface eth2 inet static
+      address 10.2.2.2
+      netmask 255.255.255.0
+
+iface eth2 inet6 static
+      address 2002:2::2
+      netmask 120
+
+auto eth3
+iface eth3 inet static
+      address 10.2.3.2
+      netmask 255.255.255.0
+
+iface eth3 inet6 static
+      address 2002:3::2
+      netmask 120
+
+auto eth4
+iface eth4 inet static
+      address 10.2.4.2
+      netmask 255.255.255.0
+
+iface eth4 inet6 static
+      address 2002:4::2
+      netmask 120
-- 
1.9.1
