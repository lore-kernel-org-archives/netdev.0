From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] tc-sfq: update man page
Date: Tue, 24 Jan 2012 14:29:38 +0100
Message-ID: <1327411778.7231.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38671 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849Ab2AXN3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 08:29:42 -0500
Received: by wgbed3 with SMTP id ed3so4005675wgb.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 05:29:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add documentation about RED mode, and new parameters (flows, depth)
added in linux 3.3

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 man/man8/tc-sfq.8 |  127 +++++++++++++++++++++++++++++++++++++-------
 1 file changed, 108 insertions(+), 19 deletions(-)

diff --git a/man/man8/tc-sfq.8 b/man/man8/tc-sfq.8
index e177f56..5a651ff 100644
--- a/man/man8/tc-sfq.8
+++ b/man/man8/tc-sfq.8
@@ -1,17 +1,35 @@
-.TH TC 8 "8 December 2001" "iproute2" "Linux"
+.TH TC 8 "24 January 2012" "iproute2" "Linux"
 .SH NAME
 sfq \- Stochastic Fairness Queueing
 .SH SYNOPSIS
 .B tc qdisc ...
-.B divisor
+.B [ divisor
 hashtablesize
-.B limit
+.B ] [ limit
 packets
-.B perturb
+.B ] [ perturb
 seconds
-.B quantum
+.B ] [ quantum
 bytes
-
+.B ] [ flows
+number
+.B ] [ depth
+number
+.B ] [ headdrop
+.B ] [ redflowlimit
+bytes
+.B ] [ min
+bytes
+.B ] [ max
+bytes
+.B ] [ avpkt
+bytes
+.B ] [ burst
+packets
+.B ] [ probability
+P
+.B ] [ ecn
+.B ] [ harddrop ]
 .SH DESCRIPTION
 
 Stochastic Fairness Queueing is a classless queueing discipline available for
@@ -42,24 +60,28 @@ Source address
 Destination address
 .TP
 (iii)
-Source port
+Source and Destination port
 .P
 If these are available. SFQ knows about ipv4 and ipv6 and also UDP, TCP and ESP. 
 Packets with other protocols are hashed based on the 32bits representation of their 
-destination and the socket they belong to. A flow corresponds mostly to a TCP/IP 
-connection.
+destination and source. A flow corresponds mostly to a TCP/IP connection.
 
 Each of these buckets should represent a unique flow. Because multiple flows may
 get hashed to the same bucket, sfqs internal hashing algorithm may be perturbed at configurable 
 intervals so that the unfairness lasts only for a short while. Perturbation may 
-however cause some inadvertent packet reordering to occur.
+however cause some inadvertent packet reordering to occur. After linux-3.3, there is
+no packet reordering problem, but possible packet drops if rehashing hits one limit
+(number of flows or packets per flow)
 
 When dequeuing, each hashbucket with data is queried in a round robin fashion.
 
-The compile time maximum length of the SFQ is 128 packets, which can be spread over
+Before linux-3.3, the compile time maximum length of the SFQ is 128 packets, which can be spread over
 at most 128 buckets of 1024 available. In case of overflow, tail-drop is performed
 on the fullest bucket, thus maintaining fairness.
 
+After linux-3.3, maximum length of SFQ is 65535 packets, and divisor limit is 65536.
+In case of overflow, tail-drop is performed on the fullest bucket, unless headdrop was requested.
+
 .SH PARAMETERS
 .TP
 divisor
@@ -68,23 +90,81 @@ The specified divisor must be a power of two and cannot be larger than 65536.
 Default value: 1024.
 .TP 
 limit
-Upper limit of the SFQ. Can be used to reduce the default length of 128 packets.
+Upper limit of the SFQ. Can be used to reduce the default length of 127 packets.
+After linux-3.3, it can be raised.
+.TP
+depth
+Limit of packets per flow (after linux-3.3). Default to 127 and can be lowered.
 .TP
 perturb
 Interval in seconds for queue algorithm perturbation. Defaults to 0, which means that 
 no perturbation occurs. Do not set too low for each perturbation may cause some packet
-reordering. Advised value: 10
+reordering or losses. Advised value: 60
 This value has no effect when external flow classification is used.
+Its better to increase divisor value to lower risk of hash collisions.
 .TP 
 quantum
 Amount of bytes a flow is allowed to dequeue during a round of the round robin process.
 Defaults to the MTU of the interface which is also the advised value and the minimum value.
-
+.TP
+flows
+After linux-3.3, it is possible to change the default limit of flows.
+Default value is 127
+.TP
+headdrop
+Default SFQ behavior is to perform tail-drop of packets from a flow.
+You can ask a headdrop instead, as this is known to provide a better feedback for TCP flows.
+.TP
+redflowlimit
+Configure the optional RED module on top of each SFQ flow.
+Random Early Detection principle is to perform packet marks or drops in a probabilistic way.
+(man tc-red for details about RED)
+.nf
+redflowlimit configures the hard limit on the real (not average) queue size per SFQ flow in bytes.
+.fi
+.TP
+min
+Average queue size at which marking becomes a possibility. Defaults to
+.B max
+/3
+.TP
+max
+At this average queue size, the marking probability is maximal. Defaults to
+.B redflowlimit
+/4
+.TP
+probability
+Maximum  probability  for  marking, specified as a floating point number from 0.0 to 1.0. Default value is 0.02
+.TP
+avpkt
+Specified in bytes. Used with burst to determine the time constant for average queue size calculations. Default value is 1000
+.TP
+burst
+Used for determining how fast the average queue size is influenced by the real queue size.
+.nf
+Default value is : 
+.B (2 * min + max) / (3 * avpkt)
+.fi
+.TP
+ecn
+RED can either 'mark' or 'drop'. Explicit Congestion
+Notification allows RED to notify remote hosts that their rate exceeds the
+amount of bandwidth available. Non-ECN capable hosts can only be notified by
+dropping a packet.  If this parameter is specified, packets which indicate
+that their hosts honor ECN will only be marked and not dropped, unless the
+queue size hits
+.B depth
+packets.
+.TP
+harddrop
+If average flow queue size is above
+.B max
+bytes, this parameter forces a drop instead of ecn marking.
 .SH EXAMPLE & USAGE
 
 To attach to device ppp0:
 .P
-# tc qdisc add dev ppp0 root sfq perturb 10
+# tc qdisc add dev ppp0 root sfq
 .P
 Please note that SFQ, like all non-shaping (work-conserving) qdiscs, is only useful 
 if it owns the queue.
@@ -104,9 +184,15 @@ It is possible to use external classifiers with sfq, for example to hash traffic
 on source/destination ip addresses:
 .P
 # tc filter add ... flow hash keys src,dst perturb 30 divisor 1024
+.P
 Note that the given divisor should match the one used by sfq. If you have
 changed the sfq default of 1024, use the same value for the flow hash filter, too.
 
+.P
+Example of sfq with optional RED mode :
+.P
+# tc qdisc add dev eth0 parent 1:1 handle 10: sfq limit 3000 flows 512 divisor 16384 
+  redflowlimit 100000 min 8000 max 60000 probability 0.20 ecn headdrop
 
 .SH SOURCE
 .TP 
@@ -126,10 +212,13 @@ M. Shreedhar and George Varghese "Efficient Fair
 Queuing using Deficit Round Robin", Proc. SIGCOMM 95.
 
 .SH SEE ALSO
-.BR tc (8)
+.BR tc (8),
+.BR tc-red (8)
 
-.SH AUTHOR
-Alexey N. Kuznetsov, <kuznet@ms2.inr.ac.ru>. This manpage maintained by
-bert hubert <ahu@ds9a.nl>
+.SH AUTHORS
+Alexey N. Kuznetsov, <kuznet@ms2.inr.ac.ru>,
+Eric Dumazet <eric.dumazet@gmail.com>.
+.P
+This manpage maintained by bert hubert <ahu@ds9a.nl>
 
 
