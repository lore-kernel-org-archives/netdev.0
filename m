From: Ryousei Takano <takano-ryousei@aist.go.jp>
Subject: [RFC][PATCH 3/3] TC: PSPacer man page
Date: Wed, 21 Nov 2007 19:19:04 +0900 (JST)
Message-ID: <20071121.191904.80785634.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, t.kudoh@aist.go.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:62966 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759786AbXKUKTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 05:19:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch includes the man page of the PSPacer (Precise Software
Pacing) qdisc module.

Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
---
 man/man8/tc-psp.8 |  166 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 166 insertions(+), 0 deletions(-)
 create mode 100644 man/man8/tc-psp.8

diff --git a/man/man8/tc-psp.8 b/man/man8/tc-psp.8
new file mode 100644
index 0000000..a6e26bf
--- /dev/null
+++ b/man/man8/tc-psp.8
@@ -0,0 +1,166 @@
+.TH PSP 8 "13 October 2007" "iproute2" "Linux"
+.SH NAME
+PSP \- Precise Software Pacer
+.SH SYNOPSIS
+.B tc qdisc ... dev
+dev
+.B  ( parent
+classid 
+.B | root) [ handle 
+major: 
+.B ] psp [ default 
+minor-id
+.B ] [ rate
+rate
+.B ] 
+
+.B tc class ... dev
+dev
+.B parent 
+major:[minor]
+.B [ classid 
+major:minor
+.B ] psp rate
+rate
+.B ] [ mode 
+mode
+.B ] 
+
+.SH DESCRIPTION
+Precise Software Pacer (PSPacer) is a classful queuing discipline 
+which controls traffic with
+.BR tc (8)
+command.
+PSP achieves a precise pacing per class.
+
+.SH GAP PACKET
+The key to realizing precise pacing is to control the starting time of 
+the transmission of each packet.  We propose a simple yet accurate 
+mechanism to trigger the transmission of a packet.  That is, to insert 
+a gap packet between the real packets.  The gap packet produces a gap 
+between sequentially transmitted real packets.
+We employ a PAUSE packet as a gap packet.  A PAUSE packet is defined in 
+the IEEE 802.3x flow control.
+
+By changing the gap packet size, the starting time of 
+the next real packet transmission can be precisely controlled.
+For example, to control a half rate transmission, a gap packet is inserted 
+between every real packet where the gap packet size is the same as 
+that of the real packets.
+
+.SH BYTE CLOCK SCHEDULING
+Packet transmission is scheduled based on the inter-packet gap of each 
+class (i.e. target rate).
+If the network has multiple bottleneck links, it is necessary to 
+schedule the order of packet transmission and the packet interval.  
+
+PSPacer maintains a virtual clock which is counted by the total transmitted 
+byte instead of real time clock.  Each sub-class has its local clock 
+which is used to make decision whether to send a packet or not.
+If there is an idle time, a gap packet is inserted.
+
+.SH CLASSIFICATION
+Within one PSP instance, many classes may exist. Each of these classes
+contains its own qdisc.
+
+When enqueuing a packet, PSP starts at the root and uses various methods to 
+determine which class should be used to obtain the data to be enqueued. 
+
+In the standard configuration, this process is rather easy. 
+At each node we look for an instruction, and then go to the class the 
+instruction refers to. If the class found is a leaf-node (without 
+children), we enqueue the packet there. If it is not yet a leaf node, we do 
+the same thing over again starting from that node. 
+
+The following actions are performed in order at each node we visit, until 
+move to another node, or terminates the process.
+.TP
+(i)
+Consult filters attached to the class. If we are at a leaf node, we are done. 
+Otherwise, restart.
+.TP
+(ii)
+If none of the above returned with an instruction, send to the default class.
+.P
+./ This algorithm makes sure that a packet always ends up somewhere, even while
+./ you are busy building your configuration. 
+
+.SH QDISC
+The root of a PSP qdisc class tree has the following parameters:
+
+.TP 
+parent major:minor | root
+This mandatory parameter determines the place of the PSP instance, 
+either at the
+.B root
+of an interface or within an existing class.
+.TP
+handle major:
+Like all other qdiscs, the PSP can be assigned a handle. It should consist only
+of a major number, followed by a colon. Optional, but it is very useful 
+if classes will be generated within this qdisc.
+.TP 
+default minor-id
+Unclassified traffic is sent to the class with this minor-id.
+.TP
+rate rate
+Optional.  You can explicitly specify the maximum transmission rate.
+For example, if a 33MHz/32bit PCI bus is used to connect a Gigabit 
+Ethernet network interface, the bottleneck is the PCI bus, and the 
+system can not transmit packets at the rate of gigabit/sec. 
+
+.SH CLASSES
+Classes have a host of parameters to configure their operation.
+
+.TP 
+parent major:minor
+Specifies the place of this class within the hierarchy. If attached directly 
+to a qdisc and not to another class, minor can be omitted. Mandatory.
+.TP 
+classid major:minor
+Like qdiscs, classes can be named. The major number must be equal to the
+major number of the qdisc to which it belongs. Optional, but needed if this 
+class is going to have children.
+.TP 
+rate rate
+Maximum transmission rate this class including all its children are assigned. 
+Optional, but required if this class is set to mode 1 (static target rate).
+.TP
+mode mode
+Range from 0 to 1.  The mode 0 is without pacing.  The mode 1 is
+pacing based on static target rate estimation.
+Default is set to 0.
+
+.SH EXAMPLE
+The output bandwidth of eth0 regulates at 500Mbps:
+.in +5
+ # tc qdisc add dev eth0 root handle 1: psp default 1
+ # tc class add dev eth0 parent 1: classid 1:1 psp rate 500mbit
+ # tc qdisc add dev eth0 parent 1:1 handle 10: pfifo
+
+.SH TODO
+.TP
+o
+In the current version, the dynamic target rate estimation mode is disabled.
+.TP
+o
+TCP Segmentation Offloading (TSO) feature is not supported.
+You must disable TSO by ethtool:
+.in +5
+# /sbin/ethtool -K eth0 tso off
+
+.SH SOURCES
+.TP
+o
+http://www.gridmpi.org/gridtcp.jsp
+.TP
+o
+R.Takano, T.Kudoh, Y.Kodama, M.Matsuda, H.Tezuka, and Y.Ishikawa,
+"Design and Evaluation of Precise Software Pacing Mechanisms for 
+Fast Long-Distance Networks," PFLDnet05, 2005.
+
+.SH SEE ALSO
+.BR tc (8)
+
+.SH AUTHOR
+Ryousei Takano <takano-ryousei@aist.go.jp>.
-- 
1.5.3.4

