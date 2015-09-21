From: Florian Westphal <fw@strlen.de>
Subject: [PATCH iproute] man: tc: add man page for fq pacer
Date: Mon, 21 Sep 2015 19:24:50 +0200
Message-ID: <1442856290-16752-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50096 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756546AbbIURZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 13:25:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Partially based on kernel Kconfig help text, code comments and
git commit messages from Eric Dumazet.

Joint work with Phil Sutter.

Signed-off-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Note, this doesn't document 'refill_delay' option proposed in
 https://patchwork.ozlabs.org/patch/516301/ .  Eric seemed
 to prefer to not mention this option.

 man/man8/Makefile |  1 +
 man/man8/tc-fq.8  | 92 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/tc.8     |  1 +
 3 files changed, 94 insertions(+)
 create mode 100644 man/man8/tc-fq.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 3df9961..d0e1b1e 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -2,6 +2,7 @@ TARGETS = ip-address.8 ip-link.8 ip-route.8
 
 MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	tc.8 tc-bfifo.8 tc-bpf.8 tc-cbq.8 tc-cbq-details.8 tc-choke.8 tc-codel.8 \
+	tc-fq.8 \
 	tc-drr.8 tc-ematch.8 tc-fq_codel.8 tc-hfsc.8 tc-htb.8 tc-pie.8 \
 	tc-mqprio.8 tc-netem.8 tc-pfifo.8 tc-pfifo_fast.8 tc-prio.8 tc-red.8 \
 	tc-sfb.8 tc-sfq.8 tc-stab.8 tc-tbf.8 \
diff --git a/man/man8/tc-fq.8 b/man/man8/tc-fq.8
new file mode 100644
index 0000000..993beb6
--- /dev/null
+++ b/man/man8/tc-fq.8
@@ -0,0 +1,92 @@
+.TH FQ 8 "10 Sept 2015" "iproute2" "Linux"
+.SH NAME
+Fair Queuing (FQ) \- Traffic Pacing
+.SH SYNOPSIS
+.B tc qdisc ... fq
+[
+.B limit
+PACKETS ] [
+.B flow_limit
+PACKETS ] [
+.B quantum
+BYTES ] [
+.B initial_quantum
+BYTES ] [
+.B maxrate
+RATE ] [
+.B buckets
+NUMBER ]  [
+.B pacing
+|
+.B nopacing
+]
+
+.SH DESCRIPTION
+FQ (Fair Queue) is a classless packet scheduler meant to be mostly
+used for locally generated traffic.  It is designed to achieve per flow pacing.
+FQ does flow separation, and is able to respect pacing requirements set by TCP stack.
+All packets belonging to a socket are considered as a 'flow'.
+For non local packets (router workload), packet rxhash is used as fallback.
+
+An application can specify a maximum pacing rate using the
+.B SO_MAX_PACING_RATE
+setsockopt call.  This packet scheduler adds delay between packets to
+respect rate limitation set by TCP stack.
+
+Dequeueing happens in a round-robin fashion.
+A special FIFO queue is reserved for high priority packets (
+.B TC_PRIO_CONTROL
+priority), such packets are always dequeued first.
+
+FQ is non-work-conserving.
+
+TCP pacing is good for flows having idle times, as the congestion
+window permits TCP stack to queue a possibly large number of packets.
+This removes the 'slow start after idle' choice, badly hitting
+large BDP flows and applications delivering chunks of data such as video streams.
+
+.SH PARAMETERS
+.SS limit
+Hard limit on the real queue size. When this limit is reached, new packets
+are dropped. If the value is lowered, packets are dropped so that the new limit is
+met. Default is 10000 packets.
+.SS flow_limit
+Hard limit on the maximum number of packets queued per flow.
+Default value is 100.
+.SS quantum
+The credit per dequeue RR round, i.e. the amount of bytes a flow is allowed to
+dequeue at once. A larger value means a longer time period before the next flow
+will be served.
+Default is 2 * interface MTU bytes.
+.SS initial_quantum
+The initial sending rate credit, i.e. the amount of bytes a new flow is allowed
+to dequeue initially.
+This is specifically meant to allow using IW10 without added delay.
+Default is 10 * interface MTU, i.e. 15140 for 'standard' ethernet.
+.SS maxrate
+Maximum sending rate of a flow.  Default is unlimited.
+Application specific setting via
+.B SO_MAX_PACING_RATE
+is ignored only if it is larger than this value.
+.SS buckets
+The size of the hash table used for flow lookups. Each bucket is assigned a
+red-black tree for efficient collision sorting.
+Default: 1024.
+.SS [no]pacing
+Enable or disable flow pacing. Default is enabled.
+.SH EXAMPLES
+#tc qdisc add dev eth0 root fq
+.br
+#tc -s -d qdisc
+.br
+qdisc fq 8003: dev eth0 root refcnt 2 limit 10000p flow_limit 100p buckets 1024 quantum 3028 initial_quantum 15140
+ Sent 503727981 bytes 1146972 pkt (dropped 0, overlimits 0 requeues 54452)
+ backlog 0b 0p requeues 54452
+  1289 flows (1289 inactive, 0 throttled)
+  0 gc, 31 highprio, 27411 throttled
+.br
+.SH SEE ALSO
+.BR tc (8),
+.BR socket (7)
+.SH AUTHORS
+FQ was written by Eric Dumazet.
diff --git a/man/man8/tc.8 b/man/man8/tc.8
index feafa05..d35e053 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -564,6 +564,7 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .BR tc-codel (8),
 .BR tc-drr (8),
 .BR tc-ematch (8),
+.BR tc-fq (8),
 .BR tc-fq_codel (8),
 .BR tc-hfsc (7),
 .BR tc-hfsc (8),
-- 
2.0.5
