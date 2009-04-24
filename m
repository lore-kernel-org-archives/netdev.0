From: Christoph Lameter <cl@linux.com>
Subject: udp ping pong with various process bindings (and correct cpu
 mappings)
Date: Fri, 24 Apr 2009 16:10:35 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904241554100.29995@qirst.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	bhutchiings@solarflare.com, mchan@broadcom.com,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:43185 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbZDXUTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 16:19:19 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D2B8D82C29B
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 16:30:01 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id csj8YGjmkALM for <netdev@vger.kernel.org>;
	Fri, 24 Apr 2009 16:30:01 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id ACCA882C2B0
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2009 16:29:54 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are the results of a 40 byte udpping (http://gentwo.org/ll) run on
kernel from 2.6.22 to 2.6.30-rc3 on a Dell 1950 dual quad core 3.3Ghz.
One system fixed 2.6.22 kernel version on the other are varied.

Nice graph at http://gentwo.org/results/udpping-results.pdf

Summary:
- Loss of ~1.5usec on fastest path (same cpu) since 2.6.22
- Different cpu same core looses 2-3 usecs vs. same cpu
- Different cpu different core looses ~ 8 usecs vs same cpu
- Maximum is usual if threads are on different sockets but sometimes
  the same socket different core is worse (2.6.26/2.6.27).
- Up to 9 usecs variance in a basic network operation just because
  of process placement.

Same CPU
Kernel		Test 1	Test 2	Test 3	Test 4	Average
2.6.22		83.03	82.9	82.89	82.92	82.94
2.6.23		83.35	82.81	82.83	82.86	82.96
2.6.24		82.66	82.56	82.64	82.73	82.65
2.6.25		84.28	84.29	84.37	84.3	84.31
2.6.26		84.72	84.38	84.41	84.68	84.55
2.6.27		84.56	84.44	84.41	84.58	84.5
2.6.28		84.7	84.43	84.47	84.48	84.52
2.6.29		84.91	84.67	84.69	84.75	84.76
2.6.30-rc2	84.94	84.72	84.69	84.93	84.82
2.6.30-rc3	84.88	84.7	84.73	84.89	84.8

Same core, different processor (l2 is shared)
Kernel		Test 1	Test 2	Test 3	Test 4	Average
2.6.22		84.6	84.71	84.52	84.53	84.59
2.6.23		84.59	84.5	84.33	84.34	84.44
2.6.24		84.28	84.3	84.38	84.28	84.31
2.6.25		86.12	85.8	86.2	86.04	86.04
2.6.26		86.61	86.46	86.49	86.7	86.57
2.6.27		87	87.01	87	86.95	86.99
2.6.28		86.53	86.44	86.26	86.24	86.37
2.6.29		85.88	85.94	86.1	85.69	85.9
2.6.30-rc2	86.03	85.93	85.99	86.06	86
2.6.30-rc3	85.73	85.88	85.67	85.94	85.81

Same Socket, different core (l2 not shared)
Kernel		Test 1	Test 2	Test 3	Test 4	Average
2.6.22		90.08	89.72	90	89.9	89.93
2.6.23		89.72	90.1	89.99	89.86	89.92
2.6.24		89.18	89.28	89.25	89.22	89.23
2.6.25		90.83	90.78	90.87	90.61	90.77
2.6.26		90.51	91.25	91.8	91.69	91.31
2.6.27		91.98	91.93	91.97	91.91	91.95
2.6.28		91.72	91.7	91.84	91.75	91.75
2.6.29		89.85	89.85	90.14	89.9	89.94
2.6.30-rc2	90.78	90.8	90.87	90.73	90.8
2.6.30-rc3	90.84	90.94	91.05	90.84	90.92

Different Socket
Kernel		Test 1	Test 2	Test 3	Test 4	Average
2.6.22		91.64	91.65	91.61	91.68	91.645
2.6.23		91.9	91.84	91.92	91.83	91.873
2.6.24		91.33	91.24	91.42	91.38	91.343
2.6.25		92.39	92.04	92.3	92.23	92.240
2.6.26		90.64	90.57	90.6	90.08	90.473
2.6.27		91.14	91.26	90.9	91.09	91.098
2.6.28		92.3	91.92	92.3	92.23	92.188
2.6.29		90.57	89.83	89.9	90.41	90.178
2.6.30-rc2	90.59	90.97	90.27	91.69	90.880
2.6.30-rc3	92.08	91.32	91.21	92.06	91.668

