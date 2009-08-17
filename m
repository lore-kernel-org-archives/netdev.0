From: Christoph Lameter <cl@linux-foundation.org>
Subject: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 17 Aug 2009 16:01:16 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <dada1@cosmosbay.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:56399 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752086AbZHQUBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 16:01:31 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 07D3082C851
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 16:01:37 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8ihuDVx4JAYC for <netdev@vger.kernel.org>;
	Mon, 17 Aug 2009 16:01:32 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6F6B182C85D
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 16:01:21 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If I use a large send queue

(echo 2000000 >/proc/sys/net/core/wmem_default)

then lots of packet loss results if I try to send more packets than
the bandwidth of the wire (300 bytes the maximum rate is 341k pps). With a
size of 2M for the output buffer the TX ring is overrun.

But this loss is nowhere seen in any counter increments:

Receiver: Listening to control channel 239.0.192.1
Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0
origin 10.2.36.111

TotalMsg   Lost SeqErr Msg/Sec   Min/us  Avg/us  Max/us StdDev  Kbytes Idle  Samples
 3118667 532979  25341  308774 1734.96 1784.72 1904.04   44.11     0.0   0       10
 3415674 585146  27642  341569 1788.90 1858.40 1905.43   34.32 102470.4    0       10
 3449840 591012  27844  341568 1941.12 1987.45 2040.16   32.73 102470.4    0        9
 3449819 591093  27993  341567 2024.34 2036.00 2044.24    6.48 102470.0    0        5
 3415693 585268  27633  341568 2010.57 2017.84 2025.10    7.27 102470.4    0        2

ifconfig
eth0      Link encap:Ethernet  HWaddr 00:21:9b:8f:a1:40
          inet addr:10.2.36.110  Bcast:10.2.36.255  Mask:255.255.255.0
          inet6 addr: fe80::221:9bff:fe8f:a140/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:174716487 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1379 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:60451720777 (56.3 GiB)  TX bytes:225841 (220.5 KiB)
          Interrupt:36 Memory:d6000000-d6012800


If I then reduce the queue size to 20k

(echo 20000 >/proc/sys/net/core/wmem_default)

the loss does either not occur or I see corresponding loss in the switch
stats:

clameter@rd-strategy3:~$ bin/mcast
Receiver: Listening to control channel 239.0.192.1
Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0
origin 10.2.36.111

TotalMsg   Lost SeqErr Msg/Sec   Min/us  Avg/us  Max/us StdDev  Kbytes
Idle  Samples
 3126997      0      0  309598  109.57  191.69  404.73   79.55     0.0    0       10
 3449790      5      5  341566  238.60  324.98  407.74   57.31 102469.6    0        9
 3449843     94     94  341569  412.31  412.32  412.33    0.01 102470.4    0        2
 3449859     76     76  341569  379.78  399.74  419.65   16.28 102470.6    0        3
 3415644     92     92  341569  408.63  414.63  417.93    4.25 102470.5    0        3
 3413885      3      3  341386   93.53  145.58  207.28   36.85 102415.8    0       10
 3449832      0      0  341568  207.06  282.44  348.13   45.80 102470.4    0       10


The TX ring is not overrun in that case since the queue size reduces the
maximum objects in flight to below 255 (TX ring size of broadcom). So the
application is throttled.


It seems that Linux does not report the UDP packet loss above that is due
to overrunning the TX ring? Why is that?



