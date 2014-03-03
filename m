From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] iproute2: add man page for mqprio
Date: Mon, 03 Mar 2014 09:38:20 -0800
Message-ID: <20140303173818.21044.37528.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neerav.Parikh@intel.com,
	nhorman@tuxdriver.com
To: stephen@networkplumber.org, or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:64802 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149AbaCCRin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 12:38:43 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so2792973oag.0
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 09:38:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 man/man8/Makefile    |    2 -
 man/man8/tc-mqprio.8 |  112 ++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/tc.8        |    1 
 3 files changed, 114 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/tc-mqprio.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index cef0912..e998928 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -3,7 +3,7 @@ TARGETS = ip-address.8 ip-link.8 ip-route.8
 MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc.8 tc-bfifo.8 tc-cbq.8 tc-cbq-details.8 tc-choke.8 tc-codel.8 \
 	tc-drr.8 tc-ematch.8 tc-fq_codel.8 tc-hfsc.8 tc-htb.8 tc-pie.8 \
-	tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 \
+	tc-mqprio.8 tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 \
 	tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8 \
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
 	ip-addrlabel.8 ip-l2tp.8 \
diff --git a/man/man8/tc-mqprio.8 b/man/man8/tc-mqprio.8
new file mode 100644
index 0000000..43f1b25
--- /dev/null
+++ b/man/man8/tc-mqprio.8
@@ -0,0 +1,112 @@
+.TH MQPRIO 8 "24 Sept 2013" "iproute2" "Linux"
+.SH NAME
+MQPRIO \- Multiqueue Priority Qdisc (Offloaded Hardware QOS)
+.SH SYNOPSIS
+.B tc qdisc ... dev
+dev
+.B  ( parent
+classid 
+.B | root) [ handle 
+major: 
+.B ] mqprio [ numtc 
+tcs
+.B ] [ map
+P0 P1 P2... 
+.B ] [ queues 
+count1@offset1 count2@offset2 ...
+.B ] [ hw
+1|0
+.B ]
+
+.SH DESCRIPTION
+The MQPRIO qdisc is a simple queuing discipline that allows mapping
+traffic flows to hardware queue ranges using priorities and a configurable
+priority to traffic class mapping. A traffic class in this context is
+a set of contiguous qdisc classes which map 1:1 to a set of hardware
+exposed queues.
+
+By default the qdisc allocates a pfifo qdisc (packet limited first in, first
+out queue) per TX queue exposed by the lower layer device. Other queuing
+disciplines may be added subsequently. Packets are enqueued using the
+.B map
+parameter and hashed across the indicated queues in the
+.B offset
+and
+.B count.
+By default these parameters are configured by the hardware
+driver to match the hardware QOS structures.
+
+Enabled hardware can provide hardware QOS with the ability to steer
+traffic flows to designated traffic classes provided by this qdisc.
+Configuring the hardware based QOS mechanism is outside the scope of
+this qdisc. Tools such as
+.B lldpad
+and
+.B ethtool
+exist to provide this functionality. Also further qdiscs may be added
+to the classes of MQPRIO to create more complex configurations.
+
+.SH ALGORITHM
+On creation with 'tc qdisc add', eight traffic classes are created mapping
+priorities 0..7 to traffic classes 0..7 and priorities greater than 7 to
+traffic class 0. This requires base driver support and the creation will
+fail on devices that do not support hardware QOS schemes.
+
+These defaults can be overridden using the qdisc parameters. Providing
+the 'hw 0' flag allows software to run without hardware coordination.
+
+If hardware coordination is being used and arguments are provided that
+the hardware can not support then an error is returned. For many users
+hardware defaults should work reasonably well.
+
+As one specific example numerous Ethernet cards support the 802.1Q
+link strict priority transmission selection algorithm (TSA). MQPRIO
+enabled hardware in conjunction with the classification methods below
+can provide hardware offloaded support for this TSA.
+
+.SH CLASSIFICATION
+Multiple methods are available to set the SKB priority which MQPRIO
+uses to select which traffic class to enqueue the packet.
+.TP
+From user space
+A process with sufficient privileges can encode the destination class
+directly with SO_PRIORITY, see
+.BR socket(7).
+.TP 
+with iptables/nftables 
+An iptables/nftables rule can be created to match traffic flows and
+set the priority.
+.BR iptables(8)
+.TP
+with net_prio cgroups
+The net_prio cgroup can be used to set the priority of all sockets
+belong to an application. See kernel and cgroup documentation for details.
+
+.SH QDISC PARAMETERS
+.TP
+num_tc
+Number of traffic classes to use upto 16 classes supported. 
+
+.TP 
+map
+The priority to traffic class map. Maps priorities 0..15 to a specified
+traffic class.
+
+.TP
+queues
+Provide count and offset of queue range for each traffic class. In the
+format,
+.B count@offset.
+Queue ranges for each traffic classes cannot overlap and must be a
+contiguous range of queues.
+
+.TP
+hw
+Set to
+.B 1
+to use hardware QOS defaults. Set to
+.B 0
+to override hardware defaults with user specified values.
+
+.SH AUTHORS
+John Fastabend, <john.r.fastabend@intel.com>
diff --git a/man/man8/tc.8 b/man/man8/tc.8
index e0acfeb..8d794de 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -454,6 +454,7 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .BR tc-hfsc (7),
 .BR tc-hfsc (8),
 .BR tc-htb (8),
+.BR tc-mqprio (8),
 .BR tc-pfifo (8),
 .BR tc-pfifo_fast (8),
 .BR tc-red (8),
