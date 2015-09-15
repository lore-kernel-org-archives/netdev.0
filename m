From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: Add documentation for VRF device
Date: Tue, 15 Sep 2015 10:50:14 -0600
Message-ID: <1442335814-47505-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33818 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbbIOQuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 12:50:20 -0400
Received: by padhy16 with SMTP id hy16so181417209pad.1
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 09:50:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 Documentation/networking/vrf.txt | 96 ++++++++++++++++++++++++++++++++++++++++
 MAINTAINERS                      |  1 +
 2 files changed, 97 insertions(+)
 create mode 100644 Documentation/networking/vrf.txt

diff --git a/Documentation/networking/vrf.txt b/Documentation/networking/vrf.txt
new file mode 100644
index 000000000000..031ef4a63485
--- /dev/null
+++ b/Documentation/networking/vrf.txt
@@ -0,0 +1,96 @@
+Virtual Routing and Forwarding (VRF)
+====================================
+The VRF device combined with ip rules provides the ability to create virtual
+routing and forwarding domains (aka VRFs, VRF-lite to be specific) in the
+Linux network stack. One use case is the multi-tenancy problem where each
+tenant has their own unique routing tables and in the very least need
+different default gateways.
+
+Processes can be "VRF aware" by binding a socket to the VRF device. Packets
+through the socket then use the routing table associated with the VRF
+device. An important feature of the VRF device implementation is that it
+impacts only Layer 3 and above so L2 tools (e.g., LLDP) are not affected
+(ie., they do not need to be run in each VRF). The design also allows
+the use of higher priority ip rules (Policy Based Routing, PBR) to take
+precedence over the VRF device rules directing specific traffic as desired.
+
+In addition, VRF devices allow VRFs to be nested within namespaces. For
+example network namespaces provide separation of network interfaces at L1
+(Layer 1 separation), VLANs on the interfaces within a namespace provide
+L2 separation and then VRF devices provide L3 separation.
+
+Design
+------
+A VRF device is created with an associated route table. Network interfaces
+are then enslaved to a VRF device:
+
+         +-----------------------------+
+         |           vrf-blue          |  ===> route table 10
+         +-----------------------------+
+            |        |            |
+         +------+ +------+     +-------------+
+         | eth1 | | eth2 | ... |    bond1    |
+         +------+ +------+     +-------------+
+                                  |       |
+                              +------+ +------+
+                              | eth8 | | eth9 |
+                              +------+ +------+
+
+Packets received on an enslaved device and are switched to the VRF device
+using an rx_handler which gives the impression that packets flow through
+the VRF device. Similarly on egress routing rules are used to send packets
+to the VRF device driver before getting sent out the actual interface. This
+allows tcpdump on a VRF device to capture all packets into and out of the
+VRF as a whole.[1] Similiarly, netfilter [2] and tc rules can be applied
+using the VRF device to specify rules that apply to the VRF domain as a whole.
+
+[1] Packets in the forwarded state do not flow through the device, so those
+    packets are not seen by tcpdump. Will revisit this limitation in a
+    future release.
+
+[2] Iptables on ingress is limited to NF_INET_PRE_ROUTING only with skb->dev
+    set to real ingress device and egress is limited to NF_INET_POST_ROUTING.
+    Will revisit this limitation in a future release.
+
+
+Setup
+-----
+1. VRF device is created with an association to a FIB table.
+   e.g, ip link add vrf-blue type vrf table 10
+        ip link set dev vrf-blue up
+
+2. Rules are added that send lookups to the associated FIB table when the
+   iif or oif is the VRF device. e.g.,
+       ip ru add oif vrf-blue table 10
+       ip ru add iif vrf-blue table 10
+
+   Set the default route for the table (and hence default route for the VRF).
+   e.g, ip route add table 10 prohibit default
+
+3. Enslave L3 interfaces to a VRF device.
+   e.g,  ip link set dev eth1 master vrf-blue
+
+   Local and connected routes for enslaved devices are automatically moved to
+   the table associated with VRF device. Any additional routes depending on
+   the enslaved device will need to be reinserted following the enslavement.
+
+4. Additional VRF routes are added to associated table.
+   e.g., ip route add table 10 ...
+
+
+Applications
+------------
+Applications that are to work within a VRF need to bind their socket to the
+VRF device:
+
+    setsockopt(sd, SOL_SOCKET, SO_BINDTODEVICE, dev, strlen(dev)+1);
+
+or to specify the output device using cmsg and IP_PKTINFO.
+
+
+Limitations
+-----------
+VRF device currently only works for IPv4. Support for IPv6 is under development.
+
+Index of original ingress interface is not available via cmsg. Will address
+soon.
diff --git a/MAINTAINERS b/MAINTAINERS
index 310da4295c70..d4d9d4f6d271 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11243,6 +11243,7 @@ L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/vrf.c
 F:	include/net/vrf.h
+F:	Documentation/networking/vrf.txt
 
 VT1211 HARDWARE MONITOR DRIVER
 M:	Juerg Haefliger <juergh@gmail.com>
-- 
2.3.2 (Apple Git-55)
