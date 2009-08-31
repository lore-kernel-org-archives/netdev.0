From: Christoph Lameter <cl@linux-foundation.org>
Subject: UDP is bypassing qdisc statistics ....
Date: Mon, 31 Aug 2009 17:46:55 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908311632170.1507@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@linux-foundation.org, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:55187 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753415AbZHaRrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 13:47:32 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E286F82C6BE
	for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 13:49:02 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id I-gj6dLPKgJ5 for <netdev@vger.kernel.org>;
	Mon, 31 Aug 2009 13:48:53 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A727B82C6B7
	for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 13:48:53 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is with 2.6.31-rc7. If I send icmp then its correctly registered as a
packet by the qdisc layer:

#tc -s qdisc show
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 10491 bytes 72 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

#ping yy
PING yy (10.2.36.120) 56(84) bytes of data.
64 bytes from yy (10.2.36.120): icmp_seq=1 ttl=64 time=0.933 ms
64 bytes from yy (10.2.36.120): icmp_seq=2 ttl=64 time=0.122 ms
64 bytes from yy (10.2.36.120): icmp_seq=3 ttl=64 time=0.119 ms
^C
--- yy ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 0.119/0.391/0.933/0.383 ms

#tc -s qdisc show
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 10839 bytes 75 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0


Now I overrun the transmitter with udp multicast traffic:

#./mcast -n1 -r400000
Receiver: Listening to control channel 239.0.192.1
Receiver: Subscribing to 0 MC addresses 239.0.192-254.2-254 offset 0
origin 10.2.36.120
Sender: Sending 400000 msgs/ch/sec on 1 channels. Probe interval=0.001-1 sec.
^C
Unsubscribing from multicast groups
Done.

#tc -s qdisc show
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 13359 bytes 101 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0


The mcast invocation send over 3 million packets(!) but they are not
accounted for in the qdisc. 500k of those were lost. Also not counted.
The 26 packets receives are likely only covering the ssh session using
TCP.

Receiver log:

yy#./mcast
Receiver: Listening to control channel 239.0.192.1
Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0 origin 10.2.36.121

TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us StdDv
 3110416 531472  25555 531472  307958     0.0  151.45 1648.21 1875.68 499.92
Unsubscribing from 1 multicast addresses origin 10.2.36.121.

What is wrong here? Is UDP bypassing the qdisc layer?

Tried UDP unicast with similar effects.
