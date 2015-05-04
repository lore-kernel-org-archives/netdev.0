From: Bernhard Thaler <bernhard.thaler@wvnet.at>
Subject: [PATCHv2] bridge: change BR_GROUPFWD_RESTRICTED to allow forwarding of LLDP frames
Date: Mon,  4 May 2015 22:47:13 +0200
Message-ID: <1430772433-16384-1-git-send-email-bernhard.thaler@wvnet.at>
References: <20150401155001.40d58a37@urahara>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Bernhard Thaler <bernhard.thaler@wvnet.at>
To: stephen@networkplumber.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-out.wvnet.at ([62.212.170.135]:29421 "EHLO mx-out.wvnet.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580AbbEDWAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 18:00:03 -0400
Received: from smtp.wvnet.at (localhost [127.0.0.1])
	by mx-out.wvnet.at (Postfix) with ESMTP id 3AF26B078DD
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 23:51:18 +0200 (CEST)
In-Reply-To: <20150401155001.40d58a37@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BR_GROUPFWD_RESTRICTED bitmask restricts users from setting values to
/sys/class/net/brX/bridge/group_fwd_mask that allow forwarding of
some IEEE 802.1D Table 7-10 Reserved addresses:

	(MAC Control) 802.3		01-80-C2-00-00-01
	(Link Aggregation) 802.3	01-80-C2-00-00-02
	802.1AB LLDP			01-80-C2-00-00-0E

Change BR_GROUPFWD_RESTRICTED to allow to forward LLDP frames and document
group_fwd_mask.

e.g.
   echo 16384 > /sys/class/net/brX/bridge/group_fwd_mask
allows to forward LLDP frames.

This may be needed for bridge setups used for network troubleshooting or
any other scenario where forwarding of LLDP frames is desired (e.g. bridge
connecting a virtual machine to real switch transmitting LLDP frames that
virtual machine needs to receive).

Tested on a simple bridge setup with two interfaces and host transmitting
LLDP frames on one side of this bridge (used lldpd). Setting group_fwd_mask
as described above lets LLDP frames traverse bridge.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
---
v2
- rebased to current net-next
- subject line changed to make clear that it will not be default
  but allows to forward LLDP after setting flag value 
- added reference to test with lldpd generated LLDP packets
  (instead of hand-crafting LLDP packets)

v1
- bridge: relax BR_GROUPFWD_RESTRICTED to forward LLDP frames

 Documentation/ABI/testing/sysfs-class-net |   19 +++++++++++++++++++
 net/bridge/br_private.h                   |    4 ++--
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net b/Documentation/ABI/testing/sysfs-class-net
index 5ecfd72..668604f 100644
--- a/Documentation/ABI/testing/sysfs-class-net
+++ b/Documentation/ABI/testing/sysfs-class-net
@@ -39,6 +39,25 @@ Description:
 		Format is a string, e.g: 00:11:22:33:44:55 for an Ethernet MAC
 		address.
 
+What:		/sys/class/net/<bridge iface>/bridge/group_fwd_mask
+Date:		January 2012
+KernelVersion:	3.2
+Contact:	netdev@vger.kernel.org
+Description:
+		Bitmask to allow forwarding of link local frames with address
+		01-80-C2-00-00-0X on a bridge device. Only values that set bits
+		not matching BR_GROUPFWD_RESTRICTED in net/bridge/br_private.h
+		allowed.
+		Default value 0 does not forward any link local frames.
+
+		Restricted bits:
+		0: 01-80-C2-00-00-00 Bridge Group Address used for STP
+		1: 01-80-C2-00-00-01 (MAC Control) 802.3 used for MAC PAUSE
+		2: 01-80-C2-00-00-02 (Link Aggregation) 802.3ad
+
+		Any values not setting these bits can be used. Take special
+		care when forwarding control frames e.g. 802.1X-PAE or LLDP.
+
 What:		/sys/class/net/<iface>/broadcast
 Date:		April 2005
 KernelVersion:	2.6.12
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3362c29..1f36fa7 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -33,8 +33,8 @@
 
 /* Control of forwarding link local multicast */
 #define BR_GROUPFWD_DEFAULT	0
-/* Don't allow forwarding control protocols like STP and LLDP */
-#define BR_GROUPFWD_RESTRICTED	0x4007u
+/* Don't allow forwarding of control protocols like STP, MAC PAUSE and LACP */
+#define BR_GROUPFWD_RESTRICTED	0x0007u
 /* The Nearest Customer Bridge Group Address, 01-80-C2-00-00-[00,0B,0C,0D,0F] */
 #define BR_GROUPFWD_8021AD	0xB801u
 
-- 
1.7.10.4
