From: Bill Fink <billfink@mindspring.com>
Subject: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Sun, 6 May 2007 20:37:36 -0400
Message-ID: <20070506203736.648c09d9.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Linux Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:51857 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752960AbXEGAhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2007 20:37:42 -0400
Received: from [68.55.21.22] (helo=gwiz.sci.gsfc.nasa.gov)
	by elasmtp-curtail.atl.sa.earthlink.net with asmtp (Exim 4.34)
	id 1HkrET-000813-EI
	for netdev@vger.kernel.org; Sun, 06 May 2007 20:37:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The initial TCP slow start on 2.6.20.7 cubic (and to a lesser
extent bic) seems to be way too slow.  With an ~80 ms RTT, this
is what cubic delivers (thirty second test with one second interval
reporting and specifying a socket buffer size of 60 MB):

[root@lang2 ~]# netstat -s | grep -i retrans
    0 segments retransmited

[root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_congestion_control
cubic

[root@lang2 ~]# nuttcp -T30 -i1 -w60m 192.168.89.15
    6.8188 MB /   1.00 sec =   57.0365 Mbps
   16.2097 MB /   1.00 sec =  135.9824 Mbps
   25.4553 MB /   1.00 sec =  213.5420 Mbps
   35.5127 MB /   1.00 sec =  297.9119 Mbps
   43.0066 MB /   1.00 sec =  360.7770 Mbps
   50.3210 MB /   1.00 sec =  422.1370 Mbps
   59.0796 MB /   1.00 sec =  495.6124 Mbps
   69.1284 MB /   1.00 sec =  579.9098 Mbps
   76.6479 MB /   1.00 sec =  642.9130 Mbps
   90.6189 MB /   1.00 sec =  760.2835 Mbps
  109.4348 MB /   1.00 sec =  918.0361 Mbps
  128.3105 MB /   1.00 sec = 1076.3813 Mbps
  150.4932 MB /   1.00 sec = 1262.4686 Mbps
  175.9229 MB /   1.00 sec = 1475.7965 Mbps
  205.9412 MB /   1.00 sec = 1727.6150 Mbps
  240.8130 MB /   1.00 sec = 2020.1504 Mbps
  282.1790 MB /   1.00 sec = 2367.1644 Mbps
  318.1841 MB /   1.00 sec = 2669.1349 Mbps
  372.6814 MB /   1.00 sec = 3126.1687 Mbps
  440.8411 MB /   1.00 sec = 3698.5200 Mbps
  524.8633 MB /   1.00 sec = 4403.0220 Mbps
  614.3542 MB /   1.00 sec = 5153.7367 Mbps
  718.9917 MB /   1.00 sec = 6031.5386 Mbps
  829.0474 MB /   1.00 sec = 6954.6438 Mbps
  867.3289 MB /   1.00 sec = 7275.9510 Mbps
  865.7759 MB /   1.00 sec = 7262.9813 Mbps
  864.4795 MB /   1.00 sec = 7251.7071 Mbps
  864.5425 MB /   1.00 sec = 7252.8519 Mbps
  867.3372 MB /   1.00 sec = 7246.9232 Mbps

10773.6875 MB /  30.00 sec = 3012.3936 Mbps 38 %TX 25 %RX

[root@lang2 ~]# netstat -s | grep -i retrans
    0 segments retransmited

It takes 25 seconds for cubic TCP to reach its maximal rate.
Note that there were no TCP retransmissions (no congestion
experienced).

Now with bic (only 20 second test this time):

[root@lang2 ~]# echo bic > /proc/sys/net/ipv4/tcp_congestion_control
[root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_congestion_control
bic

[root@lang2 ~]# nuttcp -T20 -i1 -w60m 192.168.89.15
    9.9548 MB /   1.00 sec =   83.1497 Mbps
   47.2021 MB /   1.00 sec =  395.9762 Mbps
   92.4304 MB /   1.00 sec =  775.3889 Mbps
  134.3774 MB /   1.00 sec = 1127.2758 Mbps
  194.3286 MB /   1.00 sec = 1630.1987 Mbps
  280.0598 MB /   1.00 sec = 2349.3613 Mbps
  404.3201 MB /   1.00 sec = 3391.8250 Mbps
  559.1594 MB /   1.00 sec = 4690.6677 Mbps
  792.7100 MB /   1.00 sec = 6650.0257 Mbps
  857.2241 MB /   1.00 sec = 7190.6942 Mbps
  852.6912 MB /   1.00 sec = 7153.3283 Mbps
  852.6968 MB /   1.00 sec = 7153.2538 Mbps
  851.3162 MB /   1.00 sec = 7141.7575 Mbps
  851.4927 MB /   1.00 sec = 7143.0240 Mbps
  850.8782 MB /   1.00 sec = 7137.8762 Mbps
  852.7119 MB /   1.00 sec = 7153.2949 Mbps
  852.3879 MB /   1.00 sec = 7150.2982 Mbps
  850.2163 MB /   1.00 sec = 7132.5165 Mbps
  849.8340 MB /   1.00 sec = 7129.0026 Mbps

11882.7500 MB /  20.00 sec = 4984.0068 Mbps 67 %TX 41 %RX

[root@lang2 ~]# netstat -s | grep -i retrans
    0 segments retransmited

bic does better but still takes 10 seconds to achieve its maximal
rate.

Surprisingly venerable reno does the best (only a 10 second test):

[root@lang2 ~]# echo reno > /proc/sys/net/ipv4/tcp_congestion_control
[root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_congestion_control
reno

[root@lang2 ~]# nuttcp -T10 -i1 -w60m 192.168.89.15
   69.9829 MB /   1.01 sec =  583.5822 Mbps
  844.3870 MB /   1.00 sec = 7083.2808 Mbps
  862.7568 MB /   1.00 sec = 7237.7342 Mbps
  859.5725 MB /   1.00 sec = 7210.8981 Mbps
  860.1365 MB /   1.00 sec = 7215.4487 Mbps
  865.3940 MB /   1.00 sec = 7259.8434 Mbps
  863.9678 MB /   1.00 sec = 7247.4942 Mbps
  864.7493 MB /   1.00 sec = 7254.4634 Mbps
  864.6660 MB /   1.00 sec = 7253.5183 Mbps

 7816.9375 MB /  10.00 sec = 6554.4883 Mbps 90 %TX 53 %RX

[root@lang2 ~]# netstat -s | grep -i retrans
    0 segments retransmited

reno achieves its maximal rate in about 2 seconds.  This is what I
would expect from the exponential increase during TCP's initial
slow start.  To achieve 10 Gbps on an 80 ms RTT with 9000 byte
jumbo frame packets would require:

	[root@lang2 ~]# bc -l
	scale=10
	10^10*0.080/9000/8
	11111.1111111111

So 11111 packets would have to be in flight during one RTT.
It should take log2(11111)+1 round trips to achieve 10 Gbps
(note bc's l() function is logE);

	[root@lang2 ~]# bc -l
	scale=10
	l(11111)/l(2)+1
	14.4397010470

And 15 round trips at 80 ms each gives a total time of:

	[root@lang2 ~]# bc -l
	scale=10
	15*0.080
	1.200

So if there is no packet loss (which there wasn't), it should only
take about 1.2 seconds to achieve 10 Gbps.  Only TCP reno is in
this ballpark range.

Now it's quite possible there's something basic I don't understand,
such as some /proc/sys/net/ipv4/tcp_* or /sys/module/tcp_*/parameters/*
parameter I've overlooked, in which case feel free to just refer me
to any suitable documentation.

I also checked the Changelog for 2.6.20.{8,9,10,11} to see if there
might be any relevant recent bug fixes, but the only thing that seemed
even remotely related was the 2.6.20.11 bug fix for the tcp_mem setting.
Although this did affect me, I manually adjusted the tcp_mem settings
before running these tests.

[root@lang2 ~]# cat /proc/sys/net/ipv4/tcp_mem                                  393216  524288  786432

The test setup was:

        +-------+                 +-------+                 +-------+
        |       |eth2         eth2|       |eth3         eth2|       |
        | lang2 |-----10-GigE-----| lang1 |-----10-GigE-----| lang3 |
        |       |                 |       |                 |       |
        +-------+                 +-------+                 +-------+
        192.168.88.14    192.168.88.13/192.168.89.13    192.168.89.15

All three systems are dual 2.8 GHz AMD Opteron Processor 254 systems
with 4 GB memory and all running the 2.6.20.7 kernel.  All the NICs
are Myricom PCI-E 10-GigE NICs.

The 80 ms delay was introduced by applying netem to lang1's eth3
interface:

[root@lang1 ~]# tc qdisc add dev eth3 root netem delay 80ms limit 20000
[root@lang1 ~]# tc qdisc show
qdisc pfifo_fast 0: dev eth2 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc netem 8022: dev eth3 limit 20000 delay 80.0ms reorder 100%

Experimentation determined that netem running on lang1 could handle
about 8-8.5 Gbps without dropping packets.

8.5 Gbps UDP test:

[root@lang2 ~]# nuttcp -u -Ri8.5g -w20m 192.168.89.15
10136.4844 MB /  10.01 sec = 8497.8205 Mbps 100 %TX 56 %RX 0 / 1297470 drop/pkt 0.00 %loss

Increasing the rate to 9 Gbps would give some loss:

[root@lang2 ~]# nuttcp -u -Ri9g -w20m 192.168.89.15
10219.1719 MB /  10.01 sec = 8560.2455 Mbps 100 %TX 58 %RX 65500 / 1373554 drop/pkt 4.77 %loss

Based on this, the specification of a 60 MB TCP socket buffer size was
used during the TCP tests to avoid overstressing the lang1 netem delay
emulator (to avoid dropping any packets).

Simple ping through the lang1 netem delay emulator:

[root@lang2 ~]# ping -c 5 192.168.89.15
PING 192.168.89.15 (192.168.89.15) 56(84) bytes of data.
64 bytes from 192.168.89.15: icmp_seq=1 ttl=63 time=80.4 ms
64 bytes from 192.168.89.15: icmp_seq=2 ttl=63 time=82.1 ms
64 bytes from 192.168.89.15: icmp_seq=3 ttl=63 time=82.1 ms
64 bytes from 192.168.89.15: icmp_seq=4 ttl=63 time=82.1 ms
64 bytes from 192.168.89.15: icmp_seq=5 ttl=63 time=82.1 ms

--- 192.168.89.15 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4014ms
rtt min/avg/max/mdev = 80.453/81.804/82.173/0.722 ms

And a bidirectional traceroute (using the "nuttcp -xt" option):

[root@lang2 ~]# nuttcp -xt 192.168.89.15
traceroute to 192.168.89.15 (192.168.89.15), 30 hops max, 40 byte packets
 1  192.168.88.13 (192.168.88.13)  0.141 ms   0.125 ms   0.125 ms
 2  192.168.89.15 (192.168.89.15)  82.112 ms   82.039 ms   82.541 ms

traceroute to 192.168.88.14 (192.168.88.14), 30 hops max, 40 byte packets
 1  192.168.89.13 (192.168.89.13)  81.101 ms   83.001 ms   82.999 ms
 2  192.168.88.14 (192.168.88.14)  83.005 ms   82.985 ms   82.978 ms

So is this a real bug in cubic (and bic), or do I just not understand
something basic.

						-Bill
