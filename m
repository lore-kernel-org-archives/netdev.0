From: Davide Gerhard <rainbow@irh.it>
Subject: troubles with congestion (tbf vs htb)
Date: Fri, 9 Mar 2012 22:50:37 +0100
Message-ID: <20120309215037.GI2539@paperino>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.irh.it ([109.74.199.9]:34592 "EHLO server.irh.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030181Ab2CIV7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2012 16:59:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I am a master's student from the university of Trento, I have been doing a
project, for the course of advanced networking (In a group of 2), focused
on the TCP congestion control. I used tc with htb to simulate a link with
10mbit/s using a 100mbit/s real ethernet lan. Here is the code I used:

tc qdisc add dev $INTF root handle 1: netem $DELAY $LOSS $DUPLICATE
  $CORRUPT $REORDENING
tc qdisc add dev $INTF parent 1:1 handle 10: htb default 1 r2q 10
tc class add dev $INTF parent 10: classid 0:1 htb rate ${BANDW}kbit ceil
  ${BANDW}kbit

and here is the topology

client -->|    |--> server with iperf -s
          |    |
          |    |
          +    +
           eth0
    CONGESTION machine

The congestion machine have the following configurations:
- kernel 3.0
- echo 1 > /proc/sys/net/ipv4/ip_forward
- echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
- echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
- echo 1 > /proc/sys/net/ipv4/ip_no_pmtu_disc
- echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects

The client captures the window size and ssthresh with tcp_flow_spy but we do
not see any changes in the ssthresh and the window size is too large
compared to the bandwidth*latency product (see attachment). In a normal scenario,
this would be acceptable (I guess), but in order to obtain some relevant
results for our work, we need to avoid this "buffer" and to activate
the ssthresh. I have already tried to change backlog but this does
not change anything. I have also tried to use tbf with the following command:

tc qdisc add dev $INTF parent 1:1 handle 10: ftb rate ${BANDW}kbit burst 10kb
  latency 1.2ms minburst 1540

In this case, the congestion works correctly as we expect, but if we use
netem I have to recalculate again all the needed values (correct?). Are there
any other solutions?

Best regards.
/davide

P.S Here follows the sysctl parameters used in the client:
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_dsack=1

-- 
"The abdomen, the chest, and the brain will forever be shut from the intrusion 
of the wise and humane surgeon." - Sir John Eric Ericksen, British surgeon, 
appointed Surgeon-Extraordinary to Queen Victoria 1873
