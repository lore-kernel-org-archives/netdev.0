From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH IPROUTE2] tc-codel: Add manpage
Date: Wed, 23 May 2012 21:33:54 -0700
Message-ID: <1337834034-27803-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48117 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727Ab2EXEbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 00:31:52 -0400
Received: by pbbrp8 with SMTP id rp8so10876685pbb.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 21:31:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the manpage for the CoDel (Controlled-Delay) AQM.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 man/man8/Makefile   |    2 +-
 man/man8/tc-codel.8 |  114 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 115 insertions(+), 1 deletions(-)
 create mode 100644 man/man8/tc-codel.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 6873a4b..6d6242e 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -3,7 +3,7 @@ TARGETS = ip-address.8 ip-link.8 ip-route.8
 MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc-bfifo.8 tc-cbq-details.8 tc-cbq.8 tc-drr.8 tc-htb.8 \
 	tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 tc-sfq.8 \
-	tc-tbf.8 tc.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
+	tc-tbf.8 tc.8 rtstat.8 ctstat.8 nstat.8 routef.8 tc-codel.8 \
 	tc-sfb.8 tc-netem.8 tc-choke.8 ip-tunnel.8 ip-rule.8 ip-ntable.8 \
 	ip-monitor.8 tc-stab.8 tc-hfsc.8 ip-xfrm.8 ip-netns.8 \
 	ip-neighbour.8 ip-mroute.8 ip-maddress.8 ip-addrlabel.8
diff --git a/man/man8/tc-codel.8 b/man/man8/tc-codel.8
new file mode 100644
index 0000000..605e498
--- /dev/null
+++ b/man/man8/tc-codel.8
@@ -0,0 +1,114 @@
+.TH CoDel 8 "23 May 2012" "iproute2" "Linux"
+.SH NAME
+CoDel \- Controlled-Delay Active Queue Management algorithm
+.SH SYNOPSIS
+.B tc qdisc ... codel
+[
+.B limit
+PACKETS ] [
+.B target
+TIME ] [
+.B interval
+TIME ] [
+.B ecn
+|
+.B noecn
+]
+
+.SH DESCRIPTION
+CoDel (pronounced "coddle") is an adaptive "no-knobs" active queue management
+algorithm (AQM) scheme that was developed to address the shortcomings of
+RED and its variants. It was developed with the following goals
+in mind:
+ o It should be parameterless.
+ o It should keep delays low while permitting bursts of traffic.
+ o It should control delay.
+ o It should adapt dynamically to changing link rates with no impact on
+utilization.
+ o It should be simple and efficient and should scale from simple to
+complex routers.
+
+.SH ALGORITHM
+CoDel comes with three major innovations. Instead of using queue size or queue
+average, it uses the local minimum queue as a measure of the standing/persistent queue.
+Second, it uses a single state-tracking variable of the minimum delay to see where it
+is relative to the standing queue delay. Third, instead of measuring queue size
+in bytes or packets, it is measured in packet-sojourn time in the queue.
+
+CoDel measures the minimum local queue delay (i.e. standing queue delay) and
+compares it to the value of the given acceptable queue delay
+.B target.
+As long as the minimum queue delay is less than
+.B target
+or the buffer contains fewer than MTU worth of bytes, packets are not dropped.
+Codel enters a dropping mode when the minimum queue delay has exceeded
+.B target
+for a time greater than
+.B interval.
+In this mode, packets are dropped at different drop times which is set by a
+control law. The control law ensures that the packet drops cause a linear change
+in the throughput. Once the minimum delay goes below
+.B target,
+packets are no longer dropped.
+
+Additional details can be found in the paper cited below.
+
+.SH PARAMETERS
+.SS limit
+hard limit on the real queue size. When this limit is reached, incoming packets
+are dropped. If the value is lowered, packets are dropped so that the new limit is
+met. Default is 1000 packets.
+
+.SS target
+is the acceptable minimum standing/persistent queue delay. This minimum delay
+is identified by tracking the local minimum queue delay that packets experience.
+Default and recommended value is 5ms.
+
+.SS interval
+is used to ensure that the measured minimum delay does not become too stale. The
+minimum delay must be experienced in the last epoch of length
+.B interval.
+It should be set on the order of the worst-case RTT through the bottleneck to
+give endpoints sufficient time to react.  Default value is 100ms.
+
+.SS ecn | noecn
+can be used to mark packets instead of dropping them.  If
+.B ecn
+has been enabled,
+.B noecn
+can be used to turn it off and vice-a-versa. By default,
+.B ecn
+is turned off.
+
+.SH EXAMPLES
+ # tc qdisc add dev eth0 root codel
+ # tc -s qdisc show
+   qdisc codel 801b: dev eth0 root refcnt 2 limit 1000p target 5.0ms
+interval 100.0ms
+    Sent 245801662 bytes 275853 pkt (dropped 0, overlimits 0 requeues 24)
+    backlog 0b 0p requeues 24
+     count 0 lastcount 0 ldelay 2us drop_next 0us
+     maxpacket 7306 ecn_mark 0 drop_overlimit 0
+
+ # tc qdisc add dev eth0 root codel limit 100 target 4ms interval 30ms ecn
+ # tc -s qdisc show
+   qdisc codel 801c: dev eth0 root refcnt 2 limit 100p target 4.0ms
+interval 30.0ms ecn
+    Sent 237573074 bytes 268561 pkt (dropped 0, overlimits 0 requeues 5)
+    backlog 0b 0p requeues 5
+     count 0 lastcount 0 ldelay 76us drop_next 0us
+     maxpacket 2962 ecn_mark 0 drop_overlimit 0
+
+
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-red (8)
+
+.SH SOURCES
+o   Kathleen Nicols and Van Jaconson, "Controlling Queue Delay", ACM Queue,
+http://queue.acm.org/detail.cfm?id=2209336
+
+.SH AUTHORS
+CoDel was implemented by Eric Dumazet and David Taht. This manpage was written
+by Vijay Subramanian. Please reports corrections to the Linux Networking
+mailing list <netdev@vger.kernel.org>.
-- 
1.7.0.4
