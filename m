From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 0/4 v3] net: Implement fast TX queue selection
Date: Sun, 18 Oct 2009 18:37:27 +0530
Message-ID: <20091018130727.3960.32107.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:56469 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167AbZJRNH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 09:07:29 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9ID7UAt028389
	for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 18:37:30 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9ID7UCG2625586
	for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 18:37:30 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9ID7TpL005170
	for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 00:07:30 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Notes:
    1.  Eric suggested:
	- To use u16 for txq#, but I am using an "int" for now as that
	  avoids one unnecessary subtraction during tx.
	- An improvement of caching the txq at connection establishment
	  time (TBD later) so as to use rxq# = txq#.
	- Drivers can call sk_tx_queue_set() to set the txq if they are
	  going to call skb_tx_hash() internally.
    2. v3 patch stress tested with 1000 netperfs, reboot's, etc.

Changelog [from v2]
--------------------
	1. Changed names of functions setting, getting and returning the
	   txq#; and added a new one to reset the txq#.
	2. Free sk doesn't need to reset txq#.

Changelog [from v1]
--------------------
	1. Changed IPv6 code to call __sk_dst_reset() directly.
	2. Removed the patch re-arranging ("encapsulating") __sk_dst_reset()

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
