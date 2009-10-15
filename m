From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [PATCH 0/5] net: Implement fast TX queue selection
Date: Thu, 15 Oct 2009 11:26:02 +0530
Message-ID: <20091015055602.30145.65852.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:33855 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbZJOF5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 01:57:09 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp01.au.ibm.com (8.14.3/8.13.1) with ESMTP id n9F5svv1024794
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:54:57 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9F5uMHU471540
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:56:22 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9F5uLFb006918
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:56:22 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Multiqueue cards on routers/firewalls set skb->queue_mapping on
input which helps in faster xmit. Implement fast queue selection
for locally generated packets also, by saving the txq# for
connected sockets (in dev_pick_tx) and use it in subsequent
iterations. Locally generated packets for a connection will xmit
on the same txq, but routing & firewall loads should not be
affected by this patch. Tests shows the distribution across txq's
for 1-4 netperf sessions is similar to existing code.


                   Testing & results:
                   ------------------

1. Cycles/Iter (C/I) used by dev_pick_tx:
         (B -> Billion,   M -> Million)
   |--------------|------------------------|------------------------|
   |              |          ORG           |          NEW           |
   |  Test        |--------|---------|-----|--------|---------|-----|
   |              | Cycles |  Iters  | C/I | Cycles | Iters   | C/I |
   |--------------|--------|---------|-----|--------|---------|-----|
   | [TCP_STREAM, | 3.98 B | 12.47 M | 320 | 1.95 B | 12.92 M | 152 |
   |  UDP_STREAM, |        |         |     |        |         |     |         
   |  TCP_RR,     |        |         |     |        |         |     |        
   |  UDP_RR]     |        |         |     |        |         |     |        
   |--------------|--------|---------|-----|--------|---------|-----|        
   | [TCP_STREAM, | 8.92 B | 29.66 M | 300 | 3.82 B | 38.88 M | 98  |        
   |  TCP_RR,     |        |         |     |        |         |     |         
   |  UDP_RR]     |        |         |     |        |         |     |         
   |--------------|--------|---------|-----|--------|---------|-----|

2. Stress test (over 48 hours) : 1000 netperfs running combination
   of TCP_STREAM/RR, UDP_STREAM/RR (v4/6, NODELAY/~NODELAY for all
   tests), with some ssh sessions, reboots, modprobe -r driver, etc.

3. Performance test (10 hours): Single 10 hour netperf run of
   TCP_STREAM/RR, TCP_STREAM + NO_DELAY and UDP_RR. Results show an
   improvement in both performance and cpu utilization.

Tested on a 4-processor AMD Opteron 2.8 GHz system with 1GB memory,
10G Chelsio card. Each BW number is the sum of 3 iterations of
individual tests using 512, 16K, 64K & 128K I/O sizes, in Mb/s:

------------------------  TCP Tests  -----------------------
#procs  Org BW     New BW (%)     Org SD     New SD (%)
------------------------------------------------------------
1       77777.7    81011.0 (4.15)    42.3     40.2 (-5.11)
4       91599.2    91878.8 (.30)    955.9    919.3 (-3.83)
6       89533.3    91792.2 (2.52)  2262.0   2143.0 (-5.25)
8       87507.5    89161.9 (1.89)  4363.4   4073.6 (-6.64)
10      85152.4    85607.8 (.53)   6890.4   6851.2 (-.56)
------------------------------------------------------------

------------------------- TCP NO_DELAY Tests ---------------
#procs  Org BW     New BW (%)      Org SD      New SD (%)
------------------------------------------------------------
1       57001.9    57888.0 (1.55)     67.7      70.2 (3.75)
4       69555.1    69957.4 (.57)     823.0     834.3 (1.36)
6       71359.3    71918.7 (.78)    1740.8    1724.5 (-.93)
8       72577.6    72496.1 (-.11)   2955.4    2937.7 (-.59)
10      70829.6    71444.2 (.86)    4826.1    4673.4 (-3.16)
------------------------------------------------------------

----------------------- Request Response Tests --------------------
#procs  Org TPS     New TPS (%)      Org SD    New SD (%)
(1-10)
-------------------------------------------------------------------
TCP     1019245.9   1042626.4 (2.29) 16352.9   16459.8 (.65)
UDP     934598.64   942956.9  (.89)  11607.3   11593.2 (-.12)
-------------------------------------------------------------------

Thanks,

- KK

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
