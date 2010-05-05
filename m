From: dormando <dormando@rydia.net>
Subject: 3 packet TCP window limit?
Date: Wed, 5 May 2010 02:10:49 -0700 (PDT)
Message-ID: <alpine.LNX.2.00.1005050210230.8544@d>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([216.218.163.68]:35393 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755064Ab0EEJQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 05:16:31 -0400
Received: from [192.168.0.12] (c-24-7-50-3.hsd1.ca.comcast.net [24.7.50.3])
	by mail.rydia.net (Postfix) with ESMTPA id D02573D1DF6
	for <netdev@vger.kernel.org>; Wed,  5 May 2010 02:10:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

Noticed in Linux that no matter what sysctl variable I twiddle, or what
TCP congestion algorithm is running, TCP will wait for remote acks after
sending the first 3 packets. After that it's normal.

Apologies, it's hard ot describe:

Linux server listening.

Remote -> SYN
(RTT wait)
Linux -> SYN/ACK
Remote -> ACK
Remote -> Packet (small HTTP request)
(RTT wait)
Linux -> Packet (x 3)
Remote -> (returning acks per packet)
(RTT wait)
Linux -> More packets (up to window size)

If the request response fits in 3 packets or less, that third RTT wait
never happens. The remote client gets all its data, and sends back all the
FIN/ACK packets for closing the connection.

What's bizarre is that this 3 packet/4 packet barrier is regardless of how
much data there is to send. I can cause the extra RTT to flip on or off by
sending exactly +/- 1 byte to cause an extra packet.

Holding the connection open and repeating the request any number of times
runs just fine, after the initial request.

You can pretty easily see this by:
tc qdisc add dev eth0 root netem delay 100ms
... then fetching a 3k file, then 4k file from an http server running
linux. Well. at least I can see this easily. I tried on a half dozen boxes
(2.6.11 through 2.6.32).

I'm trying to track down where in the code this is, or why my sysctl
tuning isn't affecting it. I can't discern its purpose. The lag it causes
is pretty awful for far away clients; adding 300ms of latency will make a
small request take a full second, instead of 600ms.

I'm slugging through the code but any insight would be greatly
appreciated!

-Dormando

