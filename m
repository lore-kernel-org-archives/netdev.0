From: Christoph Lameter <cl@linux.com>
Subject: udp ping pong measurements from 2.6.22 to .30 with various cpu
 affinities
Date: Wed, 22 Apr 2009 16:16:58 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904221604480.18138@qirst.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:60242 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbZDVUZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 16:25:27 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 774C182C8AA
	for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 16:35:55 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id W9l1SIgX2qpc for <netdev@vger.kernel.org>;
	Wed, 22 Apr 2009 16:35:55 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E573882C8AC
	for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 16:35:48 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are the results of udp ping pong tests. Tests were done with between
two machines. The first box was running a 2.6.22 kernel with the nic IRQ
and udpping pinned to processor 4.

The second box ran the various kernel versions. NIC irq pinned to cpu 4.
Then the pinning of udpping (see gentwo.org/ll) was varied

1. Pinned to the same processor (cpu4)
2. Pinned to a processor that shares the L2 cache (cpu5)
3. Pinned to a processor not sharing L2 (cpu6)

Results follow (a nice diagram is available from
http://gentwo.org/results/udpping-tests-2.pdf

Observations:
- Pinning to the same cpu yields almost 8 usecs vs. another cpu sharing
  the same L2.
- Strangely the cpu not sharing the l2 is better than a cpu with the same
  L2.
- Regression with cpu on the same cpu as the interrupt is about 1.5 usecs
- Improvement with cpu on the same l2 cache is improved.
- Regression of 1 usec if cpu is not sharing l2.

Hmmm... This could all be a scheduling problem. If the processes are not
placed where the IRQ occurs then there will be a significant disadvantage.

Still about 1.5 usec lost on the best case though between 2.6.22 and
2.6.30-rc2.


eth0 & udpping CPU4
Kernel		Test 1	Test 2	Test 3	Test 4	Average
2.6.22		83.49	83.05	83.43	83.19	83.290
2.6.23		83.34	82.99	83.23	83.1	83.165
2.6.24		82.93	82.78	82.82	82.96	82.873
2.6.25		84.59	84.22	84.31	84.54	84.415
2.6.26		84.61	84.38	84.43	84.44	84.465
2.6.27		84.81	84.56	84.61	84.68	84.665
2.6.28		84.71	84.51	84.54	84.72	84.620
2.6.29		84.89	84.73	84.72	84.77	84.778
2.6.30-rc2	84.72	84.66	84.7	84.76	84.710

eth0 CPU4 udpping CPU5
Kernel		Test 1	Test 2	Test 3	Test 4	Average
2.6.22		91.55	91.66	91.41	91.8	91.605
2.6.23		92.18	92.05	92.14	92.22	92.148
2.6.24		91.19	91.45	91.44	91.16	91.310
2.6.25		92.5	92.53	92.47	92.59	92.523
2.6.26		91.83	92.22	91.07	91.95	91.768
2.6.27		90.46	90.6	90.33	90.4	90.448
2.6.28		91.77	92.29	92.04	92.14	92.060
2.6.29		89.61	89.88	89.47	89.56	89.630
2.6.30-rc2	90.61	91.8	91.57	92.1	91.520

eth0 CPU4 udpping CPU6
Kernel		Test 1	Test 2	Test 3	Test 4	Average
2.6.22		89.8	89.88	90.14	89.83	89.913
2.6.23		90.1	90.17	90.4	90.37	90.260
2.6.24		89.34	89.52	89.34	89.21	89.353
2.6.25		91.19	91.31	91.06	91.58	91.285
2.6.26		91.56	91.64	91.67	91.61	91.620
2.6.27		90.1	90.6	89.97	91.13	90.450
2.6.28		91.81	91.99	91.83	91.87	91.875
2.6.29		89.79	89.63	89.67	89.74	89.708
2.6.30-rc2	91.07	91.01	90.9	90.93	90.978

