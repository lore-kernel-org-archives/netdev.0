From: Florian Westphal <fw@strlen.de>
Subject: [PATCH][iproute2] tc: man: update sfq man page
Date: Mon,  1 Aug 2011 23:23:37 +0200
Message-ID: <1312233817-1586-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:44687 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752466Ab1HAVYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 17:24:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document 'divisor' option and mention that external classifiers can be used.
---
 man/man8/tc-sfq.8 |   31 ++++++++++++++++++++++++++++---
 1 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/man/man8/tc-sfq.8 b/man/man8/tc-sfq.8
index 8f2b433..e177f56 100644
--- a/man/man8/tc-sfq.8
+++ b/man/man8/tc-sfq.8
@@ -2,7 +2,12 @@
 .SH NAME
 sfq \- Stochastic Fairness Queueing
 .SH SYNOPSIS
-.B tc qdisc ... perturb
+.B tc qdisc ...
+.B divisor
+hashtablesize
+.B limit
+packets
+.B perturb
 seconds
 .B quantum
 bytes
@@ -22,7 +27,13 @@ This may in fact have some effect in mitigating a Denial of Service attempt.
 
 SFQ is work-conserving and therefore always delivers a packet if it has one available.
 .SH ALGORITHM
-On enqueueing, each packet is assigned to a hash bucket, based on
+On enqueueing, each packet is assigned to a hash bucket, based on the packets hash value.
+This hash value is either obtained from an external flow classifier (use
+.B
+tc filter
+to set them), or a default internal classifier if no external classifier has been configured.
+
+When the internal classifier is used, sfq uses
 .TP
 (i)
 Source address
@@ -39,7 +50,7 @@ destination and the socket they belong to. A flow corresponds mostly to a TCP/IP
 connection.
 
 Each of these buckets should represent a unique flow. Because multiple flows may
-get hashed to the same bucket, the hashing algorithm is perturbed at configurable 
+get hashed to the same bucket, sfqs internal hashing algorithm may be perturbed at configurable 
 intervals so that the unfairness lasts only for a short while. Perturbation may 
 however cause some inadvertent packet reordering to occur.
 
@@ -50,6 +61,11 @@ at most 128 buckets of 1024 available. In case of overflow, tail-drop is perform
 on the fullest bucket, thus maintaining fairness.
 
 .SH PARAMETERS
+.TP
+divisor
+Can be used to set a different hash table size, available from kernel 2.6.39 onwards.
+The specified divisor must be a power of two and cannot be larger than 65536.
+Default value: 1024.
 .TP 
 limit
 Upper limit of the SFQ. Can be used to reduce the default length of 128 packets.
@@ -58,6 +74,7 @@ perturb
 Interval in seconds for queue algorithm perturbation. Defaults to 0, which means that 
 no perturbation occurs. Do not set too low for each perturbation may cause some packet
 reordering. Advised value: 10
+This value has no effect when external flow classification is used.
 .TP 
 quantum
 Amount of bytes a flow is allowed to dequeue during a round of the round robin process.
@@ -83,6 +100,14 @@ available for scheduling.
 .P
 Embed SFQ in a classful qdisc to make sure it owns the queue.
 
+It is possible to use external classifiers with sfq, for example to hash traffic based only
+on source/destination ip addresses:
+.P
+# tc filter add ... flow hash keys src,dst perturb 30 divisor 1024
+Note that the given divisor should match the one used by sfq. If you have
+changed the sfq default of 1024, use the same value for the flow hash filter, too.
+
+
 .SH SOURCE
 .TP 
 o
-- 
1.7.3.4

