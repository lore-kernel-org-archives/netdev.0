From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 5/5] tc: man: add man page for drr scheduler
Date: Tue, 12 Jan 2010 21:45:26 +0100
Message-ID: <1263329126-19756-1-git-send-email-fw@strlen.de>
References: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Cc: shemminger@vyatta.com, Patrick McHardy <kaber@trash.net>,
	Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:54393 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751372Ab0ALUqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 15:46:11 -0500
In-Reply-To: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 man/man8/tc-drr.8 |   89 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/tc.8     |    1 +
 2 files changed, 90 insertions(+), 0 deletions(-)
 create mode 100644 man/man8/tc-drr.8

diff --git a/man/man8/tc-drr.8 b/man/man8/tc-drr.8
new file mode 100644
index 0000000..5fcb0eb
--- /dev/null
+++ b/man/man8/tc-drr.8
@@ -0,0 +1,89 @@
+.TH TC 8 "January 2010" "iproute2" "Linux"
+.SH NAME
+drr \- deficit round robin scheduler
+.SH SYNOPSIS
+.B tc qdisc ... add drr
+.B [ quantum
+bytes
+.B ]
+
+.SH DESCRIPTION
+
+The Deficit Round Robin Scheduler is a classful queuing discipline as
+a more flexible replacement for Stochastic Fairness Queuing.
+
+Unlike SFQ, there are no built-in queues \-\- you need to add classes
+and then set up filters to classify packets accordingly.
+This can be useful e.g. for using RED qdiscs with different settings for particular
+traffic. There is no default class \-\- if a packet cannot be classified,
+it is dropped.
+
+.SH ALGORITHM
+Each class is assigned a deficit counter, initialized to
+.B quantum.
+
+DRR maintains an (internal) ''active'' list of classes whose qdiscs are
+non-empty.  This list is used for dequeuing.  A packet is dequeued from
+the class at the head of the list if the packet size is smaller or equal
+to the deficit counter.  If the counter is too small, it is increased by
+.B quantum
+and the scheduler moves on to the next class in the active list.
+
+
+.SH PARAMETERS
+.TP
+quantum
+Amount of bytes a flow is allowed to dequeue before the scheduler moves to the next.
+Defaults to the MTU of the interface. The minimum value is 1.
+
+.SH EXAMPLE & USAGE
+
+To attach to device eth0, using the interface MTU as its quantum:
+.P
+# tc qdisc add dev eth0 handle 1 root drr
+.P
+Adding two classes:
+.P
+# tc class add dev eth0 parent 1: classid 1:1 drr
+# tc class add dev eth0 parent 1: classid 1:2 drr
+.P
+You also need to add at least one filter to classify packets.
+.P
+# tc filter add dev eth0 protocol .. classid 1:1
+.P
+
+Like SFQ, DRR is only useful when it owns the queue \-\- it is a pure scheduler and does
+not delay packets.  Attaching non-work-conserving qdiscs like tbf to it does not make
+sense \-\- other qdiscs in the active list will also become inactive until the dequeue
+operation succeeds.  Embed DRR within another qdisc like HTB or HFSC to ensure it owns the queue.
+.P
+You can mimic SFQ behavior by assigning packets to the attached classes using the
+hash filter:
+
+.B tc qdisc add dev .. drr
+.B for i in .. 1024;do
+.B   tc class add dev ..  classid $handle:$(print %x $i)
+.B   tc qdisc add dev .. fifo limit 16
+.B done
+.B tc filter add .. protocol ip .. $handle flow hash keys src,dst divisor 1024 perturb 10
+
+
+.SH SOURCE
+.TP
+o
+M. Shreedhar and George Varghese "Efficient Fair
+Queuing using Deficit Round Robin", Proc. SIGCOMM 95.
+
+.SH NOTES
+
+This implementation does not drop packets from the longest queue on overrun,
+as limits are handled by the individual child qdiscs.
+
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-htb (8),
+.BR tc-sfq (8)
+
+.SH AUTHOR
+sched_drr was written by Patrick McHardy.
+
diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 8c0880f..e17ce68 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -367,6 +367,7 @@ print rates in IEC units (ie. 1K = 1024).
 was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .SH SEE ALSO
 .BR tc-cbq (8),
+.BR tc-drr (8),
 .BR tc-htb (8),
 .BR tc-sfq (8),
 .BR tc-red (8),
-- 
1.6.4.4

