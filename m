From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: performance regression on HiperSockets depending on MTU size
Date: Mon, 26 Nov 2012 16:32:42 +0100
Message-ID: <20121126153242.GA61652@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:54156 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755126Ab2KZPct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 10:32:49 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Mon, 26 Nov 2012 15:32:46 -0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

since kernel 3.6 we see a massive performance regression on s390
HiperSockets devices.

HiperSockets differ from normal devices by the fact they support
large MTU sizes (up to 56K). Here are some iperf numbers to show
the problem depended on MTU size:

# ifconfig hsi0 mtu 1500
# iperf -c 10.42.49.2
------------------------------------------------------------
Client connecting to 10.42.49.2, TCP port 5001
TCP window size: 47.6 KByte (default)
------------------------------------------------------------
[  3] local 10.42.49.1 port 55855 connected with 10.42.49.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec    632 MBytes    530 Mbits/sec

# ifconfig hsi0 mtu 9000
# iperf -c 10.42.49.2
------------------------------------------------------------
Client connecting to 10.42.49.2, TCP port 5001
TCP window size: 97.0 KByte (default)
------------------------------------------------------------
[  3] local 10.42.49.1 port 55856 connected with 10.42.49.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  2.26 GBytes  1.94 Gbits/sec

# ifconfig hsi0 mtu 32000
# iperf -c 10.42.49.2
------------------------------------------------------------
Client connecting to 10.42.49.2, TCP port 5001
TCP window size:   322 KByte (default)
------------------------------------------------------------
[  3] local 10.42.49.1 port 55857 connected with 10.42.49.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.3 sec  3.12 MBytes  2.53 Mbits/sec

Prior the regression throughput grows with the MTU size but now it drops
to a few Mbits if the MTU is bigger then 15000. It is interesting to see
if 2 or more connections are running in parallel the regression is gone.

# ifconfig hsi0 mtu 32000
# iperf -c 10.42.49.2 -P2
------------------------------------------------------------
Client connecting to 10.42.49.2, TCP port 5001
TCP window size:   322 KByte (default)
------------------------------------------------------------
[  4] local 10.42.49.1 port 55869 connected with 10.42.49.2 port 5001
[  3] local 10.42.49.1 port 55868 connected with 10.42.49.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  2.19 GBytes  1.88 Gbits/sec
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  2.17 GBytes  1.87 Gbits/sec
[SUM]  0.0-10.0 sec  4.36 GBytes  3.75 Gbits/sec

I bisected the problem to following patch:

commit 46d3ceabd8d98ed0ad10f20c595ca784e34786c5
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed Jul 11 05:50:31 2012 +0000

    tcp: TCP Small Queues

    This introduce TSQ (TCP Small Queues)

    TSQ goal is to reduce number of TCP packets in xmit queues (qdisc &
    device queues), to reduce RTT and cwnd bias, part of the bufferbloat
    problem.

Changing sysctl net.ipv4.tcp_limit_output_bytes to a higher value
(e.g. 640000) seems to fix the problem.

How does MTU influence/effects TSQ?
Why is the problem gone if there are more connections?
Do you see any drawbacks by increasing net.ipv4.tcp_limit_output_bytes?
Finally is this expected behavior or is there a bug depending on the big
MTU? What can I do to check ... ?

Thx for your help

Frank
