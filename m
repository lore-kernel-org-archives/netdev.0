From: Rick Jones <rick.jones2@hp.com>
Subject: Re: error(s) in 2.6.23-rc5 bonding.txt ?
Date: Fri, 28 Sep 2007 14:31:01 -0700
Message-ID: <46FD7295.50602@hp.com>
References: <46E1CA81.6050808@hp.com> <32121.1189207861@death>	<46E1E2EE.7080202@hp.com> <3360.1189213298@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:58489 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802AbXI1VbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 17:31:23 -0400
In-Reply-To: <3360.1189213298@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Well, I managed to concoct an updated test, this time with 1G's going into a 
10G.  A 2.6.23-rc8 kernel on the system with four, dual-port 82546GB's, 
connected to an HP ProCurve 3500 series switch with a 10G link to a system 
running 2.6.18-8.el5 (I was having difficulty getting cxgb3 going on my 
kernel.org kernels - firmware mismatches - so I booted RHEL5 there).

I put all four 1G interfaces into a balance_rr (mode=0) bond and started running 
just a single netperf TCP_STREAM test.

On the bonding side:

hpcpc103:~/net-2.6.24/Documentation/networking# netstat -s -t | grep retran
     19050 segments retransmited
     9349 fast retransmits
     9698 forward retransmits
hpcpc103:~/net-2.6.24/Documentation/networking# ifconfig bond0 | grep pack
           RX packets:50708119 errors:0 dropped:0 overruns:0 frame:0
           TX packets:58801285 errors:0 dropped:0 overruns:0 carrier:0
hpcpc103:~/net-2.6.24/Documentation/networking# netperf -H 192.168.5.106
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.5.106 
(192.168.5.106) port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  87380  16384  16384    10.01    1267.99
hpcpc103:~/net-2.6.24/Documentation/networking# netstat -s -t | grep retran
     20268 segments retransmited
     9974 fast retransmits
     10291 forward retransmits
hpcpc103:~/net-2.6.24/Documentation/networking# ifconfig bond0 | grep pack
           RX packets:51636421 errors:0 dropped:0 overruns:0 frame:0
           TX packets:59899089 errors:0 dropped:0 overruns:0 carrier:0

on the recieving side:

[root@hpcpc106 ~]# ifconfig eth5 | grep pack
           RX packets:58802455 errors:0 dropped:0 overruns:0 frame:0
           TX packets:50205304 errors:0 dropped:0 overruns:0 carrier:0
[root@hpcpc106 ~]# ifconfig eth5 | grep pack
           RX packets:59900267 errors:0 dropped:0 overruns:0 frame:0
           TX packets:51124138 errors:0 dropped:0 overruns:0 carrier:0

So, there were  20268 - 19050  or 1218 retransmissions during the test.  The 
sending side reported sending 59899089 - 58801285 or 1097804 packets, and the 
receiver reported receiving 59900267 - 58802455 or 1097812 packets.

Unless the switch was only occasionally duplicating segments or something, it 
looks like all the retransmissions were the result of duplicate ACKs from packet 
reordering.

For grins I varied the "reordering" sysctl and got:

# netstat -s -t | grep retran; for i in 3 4 5 6 7 8 9 10 20 30; do sysctl -w 
net.ipv4.tcp_reordering=$i; netperf -H 192.168.5.106 -P 0 -B "reorder $i"; 
netstat -s -t | grep retran; done
     13735 segments retransmited
     6581 fast retransmits
     7151 forward retransmits
net.ipv4.tcp_reordering = 3
  87380  16384  16384    10.01    1294.51   reorder 3
     15127 segments retransmited
     7330 fast retransmits
     7794 forward retransmits
net.ipv4.tcp_reordering = 4
  87380  16384  16384    10.01    1304.22   reorder 4
     16103 segments retransmited
     7807 fast retransmits
     8293 forward retransmits
net.ipv4.tcp_reordering = 5
  87380  16384  16384    10.01    1330.88   reorder 5
     16763 segments retransmited
     8155 fast retransmits
     8605 forward retransmits
net.ipv4.tcp_reordering = 6
  87380  16384  16384    10.01    1350.50   reorder 6
     17134 segments retransmited
     8356 fast retransmits
     8775 forward retransmits
net.ipv4.tcp_reordering = 7
  87380  16384  16384    10.01    1353.00   reorder 7
     17492 segments retransmited
     8553 fast retransmits
     8936 forward retransmits
net.ipv4.tcp_reordering = 8
  87380  16384  16384    10.01    1358.00   reorder 8
     17649 segments retransmited
     8625 fast retransmits
     9021 forward retransmits
net.ipv4.tcp_reordering = 9
  87380  16384  16384    10.01    1415.89   reorder 9
     17736 segments retransmited
     8666 fast retransmits
     9067 forward retransmits
net.ipv4.tcp_reordering = 10
  87380  16384  16384    10.01    1412.36   reorder 10
     17773 segments retransmited
     8684 fast retransmits
     9086 forward retransmits
net.ipv4.tcp_reordering = 20
  87380  16384  16384    10.01    1403.47   reorder 20
     17773 segments retransmited
     8684 fast retransmits
     9086 forward retransmits
net.ipv4.tcp_reordering = 30
  87380  16384  16384    10.01    1325.41   reorder 30
     17773 segments retransmited
     8684 fast retransmits
     9086 forward retransmits

IE fast retrans from reordering until the reorder limit was reasonably well 
above the number of links in the aggregate.

As for how things got reordered, knuth knows exactly why.  But it didn't need 
more than one connection, and that connection didn't have to vary the size of 
what it was passing to send(). Netperf was not making send calls which were an 
integral multiple of the MSS, which means that from time to time a short segment 
would be queued to an interface in the bond. Also, two of the dual-port NICs 
were on 66 MHz  PCI-X busses, and the other two were on 133MHz PCI-X busses 
(four busses in all) so the DMA times will have differed.


And as if this mail wasn't already long enough, here is some tcptrace summary 
for the netperf data connection with reorder at 3:

================================
TCP connection 2:
         host c:        192.168.5.103:52264
         host d:        192.168.5.106:33940
         complete conn: yes
         first packet:  Fri Sep 28 14:06:43.271692 2007
         last packet:   Fri Sep 28 14:06:53.277018 2007
         elapsed time:  0:00:10.005326
         total packets: 1556191
         filename:      trace
    c->d:                              d->c:
      total packets:        699400           total packets:        856791
      ack pkts sent:        699399           ack pkts sent:        856791
      pure acks sent:            2           pure acks sent:       856789
      sack pkts sent:            0           sack pkts sent:       352480
      dsack pkts sent:           0           dsack pkts sent:         948
      max sack blks/ack:         0           max sack blks/ack:         3
      unique bytes sent: 1180423912           unique bytes sent:         0
      actual data pkts:     699397           actual data pkts:          0
      actual data bytes: 1180581744           actual data bytes:         0
      rexmt data pkts:         106           rexmt data pkts:           0
      rexmt data bytes:     157832           rexmt data bytes:          0
      zwnd probe pkts:           0           zwnd probe pkts:           0
      zwnd probe bytes:          0           zwnd probe bytes:          0
      outoforder pkts:      202461           outoforder pkts:           0
      pushed data pkts:       6057           pushed data pkts:          0
      SYN/FIN pkts sent:       1/1           SYN/FIN pkts sent:       1/1
      req 1323 ws/ts:          Y/Y           req 1323 ws/ts:          Y/Y
      adv wind scale:            7           adv wind scale:            9
      req sack:                  Y           req sack:                  Y
      sacks sent:                0           sacks sent:           352480
      urgent data pkts:          0 pkts      urgent data pkts:          0 pkts
      urgent data bytes:         0 bytes     urgent data bytes:         0 bytes
      mss requested:          1460 bytes     mss requested:          1460 bytes
      max segm size:          8688 bytes     max segm size:             0 bytes
      min segm size:             8 bytes     min segm size:             0 bytes
      avg segm size:          1687 bytes     avg segm size:             0 bytes
      max win adv:            5888 bytes     max win adv:          968704 bytes
      min win adv:            5888 bytes     min win adv:            8704 bytes
      zero win adv:              0 times     zero win adv:              0 times
      avg win adv:            5888 bytes     avg win adv:          798088 bytes
      initial window:         2896 bytes     initial window:            0 bytes
      initial window:            2 pkts      initial window:            0 pkts
      ttl stream length: 1577454360 bytes     ttl stream length:         0 bytes
      missed data:       397030448 bytes     missed data:               0 bytes
      truncated data:    1159600134 bytes     truncated data:            0 bytes
      truncated packets:    699383 pkts      truncated packets:         0 pkts
      data xmit time:       10.005 secs      data xmit time:        0.000 secs
      idletime max:            7.5 ms        idletime max:            7.4 ms
      throughput:        117979555 Bps       throughput:                0 Bps

This was taken at the receiving 10G NIC.

rick jones
