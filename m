From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH iproute2] PIE: Add man page
Date: Thu, 16 Jan 2014 19:39:52 -0800
Message-ID: <1389929992-23083-1-git-send-email-subramanian.vijay@gmail.com>
Cc: shemminger@vyatta.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	Vijay Subramanian <vijaynsu@cisco.com>,
	Dave Taht <dave.taht@bufferbloat.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:46790 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaAQDoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 22:44:19 -0500
Received: by mail-pd0-f179.google.com with SMTP id q10so1400864pdj.24
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 19:44:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mythili Prabhu <mysuryan@cisco.com>

This adds the manpage for  PIE: Proportional Integral controller Enhanced AQM
scheme.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
Signed-off-by: Vijay Subramanian <vijaynsu@cisco.com>
CC: Dave Taht <dave.taht@bufferbloat.net>
---
Targetted for net-next-3.13 branch 

 man/man8/Makefile |    2 +-
 man/man8/tc-pie.8 |  131 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 132 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/tc-pie.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index ff80c98..cef0912 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -2,7 +2,7 @@ TARGETS = ip-address.8 ip-link.8 ip-route.8
 
 MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc.8 tc-bfifo.8 tc-cbq.8 tc-cbq-details.8 tc-choke.8 tc-codel.8 \
-	tc-drr.8 tc-ematch.8 tc-fq_codel.8 tc-hfsc.8 tc-htb.8 \
+	tc-drr.8 tc-ematch.8 tc-fq_codel.8 tc-hfsc.8 tc-htb.8 tc-pie.8 \
 	tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 \
 	tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8 \
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
diff --git a/man/man8/tc-pie.8 b/man/man8/tc-pie.8
new file mode 100644
index 0000000..536c381
--- /dev/null
+++ b/man/man8/tc-pie.8
@@ -0,0 +1,131 @@
+.TH PIE 8 "16 January 2014" "iproute2" "Linux"
+.SH NAME
+PIE \- Proportional Integral controller-Enhanced AQM algorithm
+.SH SYNOPSIS
+.B tc qdisc ... pie
+[
+.B limit
+PACKETS ] [
+.B target
+TIME ] [
+.B tupdate
+TIME ] [
+.B alpha
+int ] [
+.B beta
+int ] [
+.B ecn
+|
+.B noecn
+] [
+.B bytemode
+|
+.B nobytemode
+]
+
+.SH DESCRIPTION
+Proportional Integral controller-Enhanced (PIE) is a control theoretic active
+queue management scheme. It is based on the proportional integral controller but
+aims to control delay. The main design goals are
+ o Low latency control
+ o High link utilization
+ o Simple implementation
+ o Guaranteed stability and fast responsiveness
+
+.SH ALGORITHM
+PIE is designed to control delay effectively. First, an average dequeue rate is
+estimated based on the standing queue. The rate is used to calculate the current
+delay. Then, on a periodic basis, the delay is used to calculate the dropping
+probabilty. Finally, on arrival, a packet is dropped (or marked) based on this
+probability.
+
+PIE makes adjustments to the probability based on the trend of the delay i.e.
+whether it is going up or down.The delay converges quickly to the target value
+specified.
+
+alpha and beta are statically chosen parameters chosen to control the drop probability
+growth and are determined through control theoretic approaches. alpha determines how
+the deviation between the current and target latency changes probability. beta exerts
+additional adjustments depending on the latency trend.
+
+The drop probabilty is used to mark packets in ecn mode. However, as in RED,
+beyond 10% packets are dropped based on this probability.  The bytemode is used
+to drop packets proportional to the packet size.
+
+Additional details can be found in the paper cited below.
+
+.SH PARAMETERS
+.SS limit
+limit on the queue size in packets. Incoming packets are dropped when this limit
+is reached. Default is 1000 packets.
+
+.SS target
+is the expected queue delay. The default target delay is 20ms.
+
+.SS tupdate
+is the frequency at which the system drop probability is calculated. The default is 30ms.
+
+.SS alpha
+.SS beta
+alpha and beta are parameters chosen to control the drop probability. These
+should be in the range between 0 and 32.
+
+.SS ecn | noecn
+is used to mark packets instead of dropping
+.B ecn
+to turn on ecn mode,
+.B noecn
+to turn off ecn mode. By default,
+.B ecn
+is turned off.
+
+.SS bytemode | nobytemode
+is used to scale drop probability proportional to packet size
+.B bytemode
+to turn on bytemode,
+.B nobytemode
+to turn off bytemode. By default,
+.B bytemode
+is turned off.
+
+.SH EXAMPLES
+ # tc qdisc add dev eth0 root pie
+ # tc -s qdisc show
+   qdisc pie 8034: dev eth0 root refcnt 2 limit 200p target 19000us tupdate 29000us alpha 2 beta 20
+   Sent 7443524 bytes 7204 pkt (dropped 900, overlimits 0 requeues 0)
+   backlog 38998b 37p requeues 0
+   prob 0.123384 delay 25000us avg_dq_rate 1464840
+   pkts_in 7241 overlimit 900 dropped 0 maxq 186 ecn_mark 0
+
+ # tc qdisc add dev eth0 root pie limit 100 target 20ms tupdate 30ms ecn
+ # tc -s qdisc show
+   qdisc pie 8036: dev eth0 root refcnt 2 limit 200p target 19000 tupdate 29000 alpha 2 beta 20 ecn
+   Sent 2491922 bytes 2507 pkt (dropped 214, overlimits 0 requeues 0)
+   backlog 33728b 32p requeues 0
+   prob 0.102262 delay 24000us avg_dq_rate 1464840
+   pkts_in 2468 overlimit 214 dropped 0 maxq 192 ecn_mark 71
+
+
+ # tc qdisc add dev eth0 root pie limit 100 target 50ms tupdate 30ms bytemode
+ # tc -s qdisc show
+   qdisc pie 8036: dev eth0 root refcnt 2 limit 200p target 19000 tupdate 29000 alpha 2 beta 20 ecn
+   Sent 2491922 bytes 2507 pkt (dropped 214, overlimits 0 requeues 0)
+   backlog 33728b 32p requeues 0
+   prob 0.102262 delay 24000us avg_dq_rate 1464840
+   pkts_in 2468 overlimit 214 dropped 0 maxq 192 ecn_mark 71
+
+
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-codel (8)
+.BR tc-red (8)
+
+.SH SOURCES
+ o IETF draft submission is at http://tools.ietf.org/html/draft-pan-tsvwg-pie-00
+ o IEEE  Conference on High Performance Switching and Routing 2013 : "PIE: A
+Lightweight Control Scheme to Address the Bufferbloat Problem"
+
+.SH AUTHORS
+PIE was implemented by Vijay Subramanian and Mythili Prabhu, also the authors of
+this man page. Please report bugs and corrections to the Linux networking
+development mailing list at <netdev@vger.kernel.org>.
-- 
1.7.9.5
