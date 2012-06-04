From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH IPROUTE2] tc-fq_codel: Add manpage
Date: Mon,  4 Jun 2012 15:55:57 -0700
Message-ID: <1338850557-5199-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:33676 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761140Ab2FDWwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 18:52:53 -0400
Received: by dady13 with SMTP id y13so6465240dad.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 15:52:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the manpage for the FQ_CoDel (Fair Queuing Controlled-Delay)
AQM.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 man/man8/Makefile      |    2 +-
 man/man8/tc-fq_codel.8 |  108 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 109 insertions(+), 1 deletions(-)
 create mode 100644 man/man8/tc-fq_codel.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 6d6242e..6793873 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -6,7 +6,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc-tbf.8 tc.8 rtstat.8 ctstat.8 nstat.8 routef.8 tc-codel.8 \
 	tc-sfb.8 tc-netem.8 tc-choke.8 ip-tunnel.8 ip-rule.8 ip-ntable.8 \
 	ip-monitor.8 tc-stab.8 tc-hfsc.8 ip-xfrm.8 ip-netns.8 \
-	ip-neighbour.8 ip-mroute.8 ip-maddress.8 ip-addrlabel.8
+	ip-neighbour.8 ip-mroute.8 ip-maddress.8 ip-addrlabel.8 tc-fq_codel.8
 
 
 all: $(TARGETS)
diff --git a/man/man8/tc-fq_codel.8 b/man/man8/tc-fq_codel.8
new file mode 100644
index 0000000..5c128af
--- /dev/null
+++ b/man/man8/tc-fq_codel.8
@@ -0,0 +1,108 @@
+.TH FQ_CoDel 8 "4 June 2012" "iproute2" "Linux"
+.SH NAME
+CoDel \- Fair Queuing (FQ) with Controlled Delay (CoDel)
+.SH SYNOPSIS
+.B tc qdisc ... fq_codel
+[
+.B limit
+PACKETS ] [
+.B flows
+NUMBER ] [
+.B target
+TIME ] [
+.B interval
+TIME ] [
+.B quantum
+BYTES ] [
+.B ecn
+|
+.B noecn
+]
+
+.SH DESCRIPTION
+FQ_Codel (Fair Queuing Controled Delay) is queuing discipline that combines Fair
+Queuing with the CoDel AQM scheme. FQ_Codel uses a stochastic model to classify
+incoming packets into different flows and is used to provide a fair share of the
+bandwidth to all the flows using the queue. Each such flow is managed by the
+CoDel queuing discipline. Reordering within a flow is avoided since Codel
+internally uses a FIFO queue.
+
+.SH PARAMETERS
+.SS limit
+has the same semantics as
+.B codel
+and is the hard limit on the real queue size.
+When this limit is reached, incoming packets are dropped. Default is 10240
+packets.
+
+.SS flows
+is the number of flows into which the incoming packets are classified. Due to
+the stochastic nature of hashing, multiple flows may end up being hashed into
+the same slot. Newer flows have priority over older ones. This parameter can be
+set only at load time since memory has to be allocated for the hash table.
+Default value is 1024.
+
+.SS target
+has the same semantics as
+.B codel
+and is the acceptable minimum
+standing/persistent queue delay. This minimum delay is identified by tracking
+the local minimum queue delay that packets experience.  Default value is 5ms.
+
+.SS interval
+has the same semantics as
+.B codel
+and is used to ensure that the measured minimum delay does not become too stale.
+The minimum delay must be experienced in the last epoch of length .B interval.
+It should be set on the order of the worst-case RTT through the bottleneck to
+give endpoints sufficient time to react.  Default value is 100ms.
+
+.SS quantum
+is the number of bytes used as 'deficit' in the fair queuing algorithm. Default
+is set to 1514 bytes which corresponds to the Ethernet MTU plus the hardware
+header length of 14 bytes.
+
+.SS ecn | noecn
+has the same semantics as
+.B codel
+and can be used to mark packets instead of dropping them.  If
+.B ecn
+has been enabled,
+.B noecn
+can be used to turn it off and vice-a-versa. Unlike
+.B codel, ecn
+is turned on by default.
+
+.SH EXAMPLES
+#tc qdisc add   dev eth0 root fq_codel
+.br
+#tc -s qdisc show
+.br
+qdisc fq_codel 8002: dev eth0 root refcnt 2 limit 10240p flows 1024 quantum 1514
+ target 5.0ms interval 100.0ms ecn
+   Sent 428514 bytes 2269 pkt (dropped 0, overlimits 0 requeues 0)
+   backlog 0b 0p requeues 0
+    maxpacket 256 drop_overlimit 0 new_flow_count 0 ecn_mark 0
+    new_flows_len 0 old_flows_len 0
+
+#tc qdisc add dev eth0 root fq_codel limit 2000 target 3ms interval 40ms noecn
+.br
+#tc -s qdisc show
+.br
+qdisc fq_codel 8003: dev eth0 root refcnt 2 limit 2000p flows 1024 quantum 1514
+target 3.0ms interval 40.0ms
+ Sent 2588985006 bytes 1783629 pkt (dropped 0, overlimits 0 requeues 34869)
+ backlog 0b 0p requeues 34869
+  maxpacket 65226 drop_overlimit 0 new_flow_count 73 ecn_mark 0
+  new_flows_len 1 old_flows_len 3
+
+
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-codel (8),
+.BR tc-red (8)
+
+.SH AUTHORS
+FQ_CoDel was implemented by Eric Dumazet. This manpage was written
+by Vijay Subramanian. Please report corrections to the Linux Networking
+mailing list <netdev@vger.kernel.org>.
-- 
1.7.0.4
