From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 net-next] net: vrf: Documentation update
Date: Wed, 13 Jul 2016 06:19:37 -0600
Message-ID: <1468412377-9511-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36806 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbcGMMTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 08:19:52 -0400
Received: by mail-pa0-f48.google.com with SMTP id pp5so10776649pac.3
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 05:19:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update vrf documentation for changes made to 4.4 - 4.8 kernels
and iproute2 support for vrf keyword.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- comments from Frank Kellerman: extra whitespace in front of a neigh show
  command. Convert the brief link example to 'vrf red'.

 Documentation/networking/vrf.txt | 203 ++++++++++++++++++++-------------------
 1 file changed, 104 insertions(+), 99 deletions(-)

diff --git a/Documentation/networking/vrf.txt b/Documentation/networking/vrf.txt
index 5da679c573d2..755dab856392 100644
--- a/Documentation/networking/vrf.txt
+++ b/Documentation/networking/vrf.txt
@@ -15,9 +15,9 @@ the use of higher priority ip rules (Policy Based Routing, PBR) to take
 precedence over the VRF device rules directing specific traffic as desired.
 
 In addition, VRF devices allow VRFs to be nested within namespaces. For
-example network namespaces provide separation of network interfaces at L1
-(Layer 1 separation), VLANs on the interfaces within a namespace provide
-L2 separation and then VRF devices provide L3 separation.
+example network namespaces provide separation of network interfaces at the
+device layer, VLANs on the interfaces within a namespace provide L2 separation
+and then VRF devices provide L3 separation.
 
 Design
 ------
@@ -37,21 +37,22 @@ A VRF device is created with an associated route table. Network interfaces
                               +------+ +------+
 
 Packets received on an enslaved device and are switched to the VRF device
-using an rx_handler which gives the impression that packets flow through
-the VRF device. Similarly on egress routing rules are used to send packets
-to the VRF device driver before getting sent out the actual interface. This
-allows tcpdump on a VRF device to capture all packets into and out of the
-VRF as a whole.[1] Similarly, netfilter [2] and tc rules can be applied
-using the VRF device to specify rules that apply to the VRF domain as a whole.
+in the IPv4 and IPv6 processing stacks giving the impression that packets
+flow through the VRF device. Similarly on egress routing rules are used to
+send packets to the VRF device driver before getting sent out the actual
+interface. This allows tcpdump on a VRF device to capture all packets into
+and out of the VRF as a whole.[1] Similarly, netfilter[2] and tc rules can be
+applied using the VRF device to specify rules that apply to the VRF domain
+as a whole.
 
 [1] Packets in the forwarded state do not flow through the device, so those
     packets are not seen by tcpdump. Will revisit this limitation in a
     future release.
 
-[2] Iptables on ingress is limited to NF_INET_PRE_ROUTING only with skb->dev
-    set to real ingress device and egress is limited to NF_INET_POST_ROUTING.
-    Will revisit this limitation in a future release.
-
+[2] Iptables on ingress supports PREROUTING with skb->dev set to the real
+    ingress device and both INPUT and PREROUTING rules with skb->dev set to
+    the VRF device. For egress POSTROUTING and OUTPUT rules can be written
+    using either the VRF device or real egress device.
 
 Setup
 -----
@@ -59,23 +60,33 @@ Setup
    e.g, ip link add vrf-blue type vrf table 10
         ip link set dev vrf-blue up
 
-2. Rules are added that send lookups to the associated FIB table when the
-   iif or oif is the VRF device. e.g.,
+2. An l3mdev FIB rule directs lookups to the table associated with the device.
+   A single l3mdev rule is sufficient for all VRFs. The VRF device adds the
+   l3mdev rule for IPv4 and IPv6 when the first device is created with a
+   default preference of 1000. Users may delete the rule if desired and add
+   with a different priority or install per-VRF rules.
+
+   Prior to the v4.8 kernel iif and oif rules are needed for each VRF device:
        ip ru add oif vrf-blue table 10
        ip ru add iif vrf-blue table 10
 
-   Set the default route for the table (and hence default route for the VRF).
-   e.g, ip route add table 10 prohibit default
+3. Set the default route for the table (and hence default route for the VRF).
+       ip route add table 10 unreachable default
 
-3. Enslave L3 interfaces to a VRF device.
-   e.g,  ip link set dev eth1 master vrf-blue
+4. Enslave L3 interfaces to a VRF device.
+       ip link set dev eth1 master vrf-blue
 
    Local and connected routes for enslaved devices are automatically moved to
    the table associated with VRF device. Any additional routes depending on
-   the enslaved device will need to be reinserted following the enslavement.
+   the enslaved device are dropped and will need to be reinserted to the VRF
+   FIB table following the enslavement.
+
+   The IPv6 sysctl option keep_addr_on_down can be enabled to keep IPv6 global
+   addresses as VRF enslavement changes.
+       sysctl -w net.ipv6.conf.all.keep_addr_on_down=1
 
-4. Additional VRF routes are added to associated table.
-   e.g., ip route add table 10 ...
+5. Additional VRF routes are added to associated table.
+       ip route add table 10 ...
 
 
 Applications
@@ -87,39 +98,34 @@ Applications that are to work within a VRF need to bind their socket to the
 
 or to specify the output device using cmsg and IP_PKTINFO.
 
+TCP services running in the default VRF context (ie., not bound to any VRF
+device) can work across all VRF domains by enabling the tcp_l3mdev_accept
+sysctl option:
+    sysctl -w net.ipv4.tcp_l3mdev_accept=1
 
-Limitations
------------
-Index of original ingress interface is not available via cmsg. Will address
-soon.
+netfilter rules on the VRF device can be used to limit access to services
+running in the default VRF context as well.
+
+The default VRF does not have limited scope with respect to port bindings.
+That is, if a process does a wildcard bind to a port in the default VRF it
+owns the port across all VRF domains within the network namespace.
 
 ################################################################################
 
 Using iproute2 for VRFs
 =======================
-VRF devices do *not* have to start with 'vrf-'. That is a convention used here
-for emphasis of the device type, similar to use of 'br' in bridge names.
+iproute2 supports the vrf keyword as of v4.7. For backwards compatibility this
+section lists both commands where appropriate -- with the vrf keyword and the
+older form without it.
 
 1. Create a VRF
 
    To instantiate a VRF device and associate it with a table:
        $ ip link add dev NAME type vrf table ID
 
-   Remember to add the ip rules as well:
-       $ ip ru add oif NAME table 10
-       $ ip ru add iif NAME table 10
-       $ ip -6 ru add oif NAME table 10
-       $ ip -6 ru add iif NAME table 10
-
-   Without the rules route lookups are not directed to the table.
-
-   For example:
-   $ ip link add dev vrf-blue type vrf table 10
-   $ ip ru add pref 200 oif vrf-blue table 10
-   $ ip ru add pref 200 iif vrf-blue table 10
-   $ ip -6 ru add pref 200 oif vrf-blue table 10
-   $ ip -6 ru add pref 200 iif vrf-blue table 10
-
+   As of v4.8 the kernel supports the l3mdev FIB rule where a single rule
+   covers all VRFs. The l3mdev rule is created for IPv4 and IPv6 on first
+   device create.
 
 2. List VRFs
 
@@ -129,16 +135,16 @@ for emphasis of the device type, similar to use of 'br' in bridge names.
 
    For example:
    $ ip -d link show type vrf
-   11: vrf-mgmt: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
+   11: mgmt: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
        link/ether 72:b3:ba:91:e2:24 brd ff:ff:ff:ff:ff:ff promiscuity 0
        vrf table 1 addrgenmode eui64
-   12: vrf-red: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
+   12: red: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
        link/ether b6:6f:6e:f6:da:73 brd ff:ff:ff:ff:ff:ff promiscuity 0
        vrf table 10 addrgenmode eui64
-   13: vrf-blue: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
+   13: blue: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
        link/ether 36:62:e8:7d:bb:8c brd ff:ff:ff:ff:ff:ff promiscuity 0
        vrf table 66 addrgenmode eui64
-   14: vrf-green: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
+   14: green: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
        link/ether e6:28:b8:63:70:bb brd ff:ff:ff:ff:ff:ff promiscuity 0
        vrf table 81 addrgenmode eui64
 
@@ -146,43 +152,44 @@ for emphasis of the device type, similar to use of 'br' in bridge names.
    Or in brief output:
 
    $ ip -br link show type vrf
-   vrf-mgmt         UP             72:b3:ba:91:e2:24 <NOARP,MASTER,UP,LOWER_UP>
-   vrf-red          UP             b6:6f:6e:f6:da:73 <NOARP,MASTER,UP,LOWER_UP>
-   vrf-blue         UP             36:62:e8:7d:bb:8c <NOARP,MASTER,UP,LOWER_UP>
-   vrf-green        UP             e6:28:b8:63:70:bb <NOARP,MASTER,UP,LOWER_UP>
+   mgmt         UP             72:b3:ba:91:e2:24 <NOARP,MASTER,UP,LOWER_UP>
+   red          UP             b6:6f:6e:f6:da:73 <NOARP,MASTER,UP,LOWER_UP>
+   blue         UP             36:62:e8:7d:bb:8c <NOARP,MASTER,UP,LOWER_UP>
+   green        UP             e6:28:b8:63:70:bb <NOARP,MASTER,UP,LOWER_UP>
 
 
 3. Assign a Network Interface to a VRF
 
    Network interfaces are assigned to a VRF by enslaving the netdevice to a
    VRF device:
-       $ ip link set dev NAME master VRF-NAME
+       $ ip link set dev NAME master NAME
 
    On enslavement connected and local routes are automatically moved to the
    table associated with the VRF device.
 
    For example:
-   $ ip link set dev eth0 master vrf-mgmt
+   $ ip link set dev eth0 master mgmt
 
 
 4. Show Devices Assigned to a VRF
 
    To show devices that have been assigned to a specific VRF add the master
    option to the ip command:
-       $ ip link show master VRF-NAME
+       $ ip link show vrf NAME
+       $ ip link show master NAME
 
    For example:
-   $ ip link show master vrf-red
-   3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master vrf-red state UP mode DEFAULT group default qlen 1000
+   $ ip link show vrf red
+   3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master red state UP mode DEFAULT group default qlen 1000
        link/ether 02:00:00:00:02:02 brd ff:ff:ff:ff:ff:ff
-   4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master vrf-red state UP mode DEFAULT group default qlen 1000
+   4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master red state UP mode DEFAULT group default qlen 1000
        link/ether 02:00:00:00:02:03 brd ff:ff:ff:ff:ff:ff
-   7: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master vrf-red state DOWN mode DEFAULT group default qlen 1000
+   7: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master red state DOWN mode DEFAULT group default qlen 1000
        link/ether 02:00:00:00:02:06 brd ff:ff:ff:ff:ff:ff
 
 
    Or using the brief output:
-   $ ip -br link show master vrf-red
+   $ ip -br link show vrf red
    eth1             UP             02:00:00:00:02:02 <BROADCAST,MULTICAST,UP,LOWER_UP>
    eth2             UP             02:00:00:00:02:03 <BROADCAST,MULTICAST,UP,LOWER_UP>
    eth5             DOWN           02:00:00:00:02:06 <BROADCAST,MULTICAST>
@@ -192,26 +199,28 @@ for emphasis of the device type, similar to use of 'br' in bridge names.
 
    To list neighbor entries associated with devices enslaved to a VRF device
    add the master option to the ip command:
-       $ ip [-6] neigh show master VRF-NAME
+       $ ip [-6] neigh show vrf NAME
+       $ ip [-6] neigh show master NAME
 
    For example:
-   $  ip neigh show master vrf-red
+   $  ip neigh show vrf red
    10.2.1.254 dev eth1 lladdr a6:d9:c7:4f:06:23 REACHABLE
    10.2.2.254 dev eth2 lladdr 5e:54:01:6a:ee:80 REACHABLE
 
-    $ ip -6 neigh show master vrf-red
-    2002:1::64 dev eth1 lladdr a6:d9:c7:4f:06:23 REACHABLE
+   $ ip -6 neigh show vrf red
+   2002:1::64 dev eth1 lladdr a6:d9:c7:4f:06:23 REACHABLE
 
 
 6. Show Addresses for a VRF
 
    To show addresses for interfaces associated with a VRF add the master
    option to the ip command:
-       $ ip addr show master VRF-NAME
+       $ ip addr show vrf NAME
+       $ ip addr show master NAME
 
    For example:
-   $ ip addr show master vrf-red
-   3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master vrf-red state UP group default qlen 1000
+   $ ip addr show vrf red
+   3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master red state UP group default qlen 1000
        link/ether 02:00:00:00:02:02 brd ff:ff:ff:ff:ff:ff
        inet 10.2.1.2/24 brd 10.2.1.255 scope global eth1
           valid_lft forever preferred_lft forever
@@ -219,7 +228,7 @@ for emphasis of the device type, similar to use of 'br' in bridge names.
           valid_lft forever preferred_lft forever
        inet6 fe80::ff:fe00:202/64 scope link
           valid_lft forever preferred_lft forever
-   4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master vrf-red state UP group default qlen 1000
+   4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master red state UP group default qlen 1000
        link/ether 02:00:00:00:02:03 brd ff:ff:ff:ff:ff:ff
        inet 10.2.2.2/24 brd 10.2.2.255 scope global eth2
           valid_lft forever preferred_lft forever
@@ -227,11 +236,11 @@ for emphasis of the device type, similar to use of 'br' in bridge names.
           valid_lft forever preferred_lft forever
        inet6 fe80::ff:fe00:203/64 scope link
           valid_lft forever preferred_lft forever
-   7: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master vrf-red state DOWN group default qlen 1000
+   7: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master red state DOWN group default qlen 1000
        link/ether 02:00:00:00:02:06 brd ff:ff:ff:ff:ff:ff
 
    Or in brief format:
-   $ ip -br addr show master vrf-red
+   $ ip -br addr show vrf red
    eth1             UP             10.2.1.2/24 2002:1::2/120 fe80::ff:fe00:202/64
    eth2             UP             10.2.2.2/24 2002:2::2/120 fe80::ff:fe00:203/64
    eth5             DOWN
@@ -241,10 +250,11 @@ for emphasis of the device type, similar to use of 'br' in bridge names.
 
    To show routes for a VRF use the ip command to display the table associated
    with the VRF device:
+       $ ip [-6] route show vrf NAME
        $ ip [-6] route show table ID
 
    For example:
-   $ ip route show table vrf-red
+   $ ip route show vrf red
    prohibit default
    broadcast 10.2.1.0 dev eth1  proto kernel  scope link  src 10.2.1.2
    10.2.1.0/24 dev eth1  proto kernel  scope link  src 10.2.1.2
@@ -255,7 +265,7 @@ for emphasis of the device type, similar to use of 'br' in bridge names.
    local 10.2.2.2 dev eth2  proto kernel  scope host  src 10.2.2.2
    broadcast 10.2.2.255 dev eth2  proto kernel  scope link  src 10.2.2.2
 
-   $ ip -6 route show table vrf-red
+   $ ip -6 route show vrf red
    local 2002:1:: dev lo  proto none  metric 0  pref medium
    local 2002:1::2 dev lo  proto none  metric 0  pref medium
    2002:1::/120 dev eth1  proto kernel  metric 256  pref medium
@@ -268,23 +278,24 @@ for emphasis of the device type, similar to use of 'br' in bridge names.
    local fe80::ff:fe00:203 dev lo  proto none  metric 0  pref medium
    fe80::/64 dev eth1  proto kernel  metric 256  pref medium
    fe80::/64 dev eth2  proto kernel  metric 256  pref medium
-   ff00::/8 dev vrf-red  metric 256  pref medium
+   ff00::/8 dev red  metric 256  pref medium
    ff00::/8 dev eth1  metric 256  pref medium
    ff00::/8 dev eth2  metric 256  pref medium
 
 
 8. Route Lookup for a VRF
 
-   A test route lookup can be done for a VRF by adding the oif option to ip:
-       $ ip [-6] route get oif VRF-NAME ADDRESS
+   A test route lookup can be done for a VRF:
+       $ ip [-6] route get vrf NAME ADDRESS
+       $ ip [-6] route get oif NAME ADDRESS
 
    For example:
-   $ ip route get 10.2.1.40 oif vrf-red
-   10.2.1.40 dev eth1  table vrf-red  src 10.2.1.2
+   $ ip route get 10.2.1.40 vrf red
+   10.2.1.40 dev eth1  table red  src 10.2.1.2
        cache
 
-   $ ip -6 route get 2002:1::32 oif vrf-red
-   2002:1::32 from :: dev eth1  table vrf-red  proto kernel  src 2002:1::2  metric 256  pref medium
+   $ ip -6 route get 2002:1::32 vrf red
+   2002:1::32 from :: dev eth1  table red  proto kernel  src 2002:1::2  metric 256  pref medium
 
 
 9. Removing Network Interface from a VRF
@@ -303,46 +314,40 @@ for emphasis of the device type, similar to use of 'br' in bridge names.
 
 Commands used in this example:
 
-cat >> /etc/iproute2/rt_tables <<EOF
-1  vrf-mgmt
-10 vrf-red
-66 vrf-blue
-81 vrf-green
+cat >> /etc/iproute2/rt_tables.d/vrf.conf <<EOF
+1  mgmt
+10 red
+66 blue
+81 green
 EOF
 
 function vrf_create
 {
     VRF=$1
     TBID=$2
-    # create VRF device
-    ip link add vrf-${VRF} type vrf table ${TBID}
 
-    # add rules that direct lookups to vrf table
-    ip ru add pref 200 oif vrf-${VRF} table ${TBID}
-    ip ru add pref 200 iif vrf-${VRF} table ${TBID}
-    ip -6 ru add pref 200 oif vrf-${VRF} table ${TBID}
-    ip -6 ru add pref 200 iif vrf-${VRF} table ${TBID}
+    # create VRF device
+    ip link add ${VRF} type vrf table ${TBID}
 
     if [ "${VRF}" != "mgmt" ]; then
-        ip route add table ${TBID} prohibit default
+        ip route add table ${TBID} unreachable default
     fi
-    ip link set dev vrf-${VRF} up
-    ip link set dev vrf-${VRF} state up
+    ip link set dev ${VRF} up
 }
 
 vrf_create mgmt 1
-ip link set dev eth0 master vrf-mgmt
+ip link set dev eth0 master mgmt
 
 vrf_create red 10
-ip link set dev eth1 master vrf-red
-ip link set dev eth2 master vrf-red
-ip link set dev eth5 master vrf-red
+ip link set dev eth1 master red
+ip link set dev eth2 master red
+ip link set dev eth5 master red
 
 vrf_create blue 66
-ip link set dev eth3 master vrf-blue
+ip link set dev eth3 master blue
 
 vrf_create green 81
-ip link set dev eth4 master vrf-green
+ip link set dev eth4 master green
 
 
 Interface addresses from /etc/network/interfaces:
-- 
2.7.4 (Apple Git-66)
