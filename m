From: Bernhard Thaler <bernhard.thaler@wvnet.at>
Subject: [PATCH] bridge: relax BR_GROUPFWD_RESTRICTED to forward LLDP frames
Date: Mon, 30 Mar 2015 00:06:02 +0200
Message-ID: <1427666762-23683-1-git-send-email-bernhard.thaler@wvnet.at>
References: <1427063051-1236-1-git-send-email-bernhard.thaler@wvnet.at>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Bernhard Thaler <bernhard.thaler@wvnet.at>
To: stephen@networkplumber.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost2.wvnet.at ([62.212.174.131]:1078 "EHLO
	mx-out.wvnet.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752667AbbC2WG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 18:06:58 -0400
Received: from smtp.wvnet.at (localhost [127.0.0.1])
	by mx-out.wvnet.at (Postfix) with ESMTP id A53E5436A91
	for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 00:06:57 +0200 (CEST)
In-Reply-To: <1427063051-1236-1-git-send-email-bernhard.thaler@wvnet.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BR_GROUPFWD_RESTRICTED bitmask restricts users from setting values to
/sys/class/net/brX/bridge/group_fwd_mask that allow forwarding of
some IEEE 802.1D Table 7-10 Reserved addresses:

	(MAC Control) 802.3		01-80-C2-00-00-01
	(Link Aggregation) 802.3	01-80-C2-00-00-02
	802.1AB LLDP			01-80-C2-00-00-0E

Relax BR_GROUPFWD_RESTRICTED to at least forward LLDP frames and document
group_fwd_mask.

e.g.
   echo 16384 > /sys/class/net/brX/bridge/group_fwd_mask
allows to forward LLDP frames.

Tested on a simple bridge setup with two interfaces. Setting group_fwd_mask
as described above lets crafted LLDP frames traverse bridge.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
---
v1
* this version only removes LLDP restriction from BR_GROUPFWD_RESTRICTED
* adds documentation of /sys/class/net/brX/bridge/group_fwd_mask

(v0)
* initial version "bridge: remove BR_GROUPFWD_RESTRICTED for arbitrary
                   forwarding of reserved addresses"

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
index b46fa0c..ef8ef3f 100644
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
