From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCH] iproute2: macvlan: add "source" mode
Date: Sun, 25 Sep 2016 20:52:00 +0200
Message-ID: <1474829520-1302-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev@fami-braun.de>,
        projekt-wlan@fem.tu-ilmenau.de, steweg@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:42934 "EHLO
        mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755902AbcIYS6H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 14:58:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjusting iproute2 utility to support new macvlan link type mode called
"source".

Example of commands that can be applied:
  ip link add link eth0 name macvlan0 type macvlan mode source
  ip link set link dev macvlan0 type macvlan macaddr add 00:11:11:11:11:11
  ip link set link dev macvlan0 type macvlan macaddr del 00:11:11:11:11:11
  ip link set link dev macvlan0 type macvlan macaddr flush
  ip -details link show dev macvlan0

Based on previous work of Stefan Gula <steweg@gmail.com>

Signed-off-by: Michael Braun <michael-dev@fami-braun.de>

Cc: steweg@gmail.com
---
 include/linux/if_link.h |  2 ++
 man/man8/ip-link.8.in   | 57 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 1feb708..ec5e64e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -401,6 +401,8 @@ enum macvlan_macaddr_mode {
 };
 
 #define MACVLAN_FLAG_NOPROMISC	1
+#define MACVLAN_FLAG_UNICAST	2
+#define MACVLAN_FLAG_UNICAST_ALL	4
 
 /* VRF section */
 enum {
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ffc4160..1ad3cfe 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -138,6 +138,9 @@ ip-link \- network device configuration
 .IR NAME " ]"
 .br
 .RB "[ " addrgenmode " { " eui64 " | " none " | " stable_secret " | " random " } ]"
+.br
+.B macaddr " |"
+.IR "COMMAND MACADDR |"
 
 
 .ti -8
@@ -228,8 +231,46 @@ Link types:
 - IP over Infiniband device
 .sp
 .B macvlan
+.I MODE
 - Virtual interface base on link layer address (MAC)
 .sp
+Modes:
+.in +8
+.B private
+- The device never communicates with any other device on the same upper_dev.
+This even includes frames coming back from a reflective relay, where supported
+by the adjacent bridge.
+.sp
+.B vepa
+- we assume that the adjacent bridge returns all frames where both source and
+destination are local to the macvlan port, i.e. the bridge is set up as a
+reflective relay. Broadcast frames coming in from the upper_dev get flooded to
+all macvlan interfaces in VEPA mode. We never deliver any frames locally.
+.sp
+.B bridge
+- behave as simple bridge between different macvlan interfaces on the same
+port. Frames from one interface to another one get delivered directly and are
+not sent out externally. Broadcast frames get flooded to all other bridge
+ports and to the external interface, but when they come back from a reflective
+relay, we don't deliver them again. Since we know all the MAC addresses, the
+macvlan bridge mode does not require learning or STP like the bridge module
+does.
+.sp
+.B passthru
+- allows takeover of the underlying device and passing it to a guest using
+virtio with macvtap backend. Only one macvlan device is allowed in passthru
+mode and it inherits the mac address from the underlying device and sets it in
+promiscuous mode to receive and forward all the packets.
+.sp
+.B source
+- allows one to set a list of allowed mac address, which is used to match
+against source mac address from received frames on underlying interface. This
+allows creating mac based VLAN associations, instead of standard port or tag
+based. The feature is useful to deploy 802.1x mac based behavior,
+where drivers of underlying interfaces doesn't allows that.
+.sp
+.in -8
+.sp
 .B macvtap
 - Virtual interface based on link layer address (MAC) and TAP.
 .sp
@@ -1074,6 +1115,22 @@ specifies the type of the device.
 
 .SS ip link set - change device attributes
 
+.TP
+.BI macaddr " COMMAND MACADDR"
+add or removes MACADDR from allowed list for source mode macvlan type link
+Commands:
+.in +8
+.B add
+- add MACADDR to allowed list
+.sp
+.B del
+- remove MACADDR from allowed list
+.sp
+.B flush
+- flush whole allowed list
+.sp
+.in -8
+
 .PP
 .B Warning:
 If multiple parameter changes are requested,
-- 
2.1.4
