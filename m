From: Andreas Sundstrom <sunkan@zappa.cx>
Subject: ~60k interrupts/sec for 1Gb/s iperf with r8169
Date: Mon, 18 Jan 2010 12:37:07 +0100
Message-ID: <4B5447E3.5090405@zappa.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alva.zappa.cx ([213.88.132.89]:55890 "EHLO alva.zappa.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932104Ab0ARMKm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2010 07:10:42 -0500
Received: from matrix.zappa.cx ([2001:16d8:ff9b:2:211:9ff:fe8a:f658])
	by alva.zappa.cx with esmtp (Exim 4.69)
	(envelope-from <sunkan@zappa.cx>)
	id 1NWpuv-00037Y-UL
	for netdev@vger.kernel.org; Mon, 18 Jan 2010 12:37:10 +0100
Received: from [10.8.0.6] (openvpn6.zappa.cx [10.8.0.6] (may be forged))
	(authenticated bits=0)
	by matrix.zappa.cx (8.14.3/8.14.3/Debian-5) with ESMTP id o0IBb8jj014264
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 12:37:09 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, first of all I want to let you know that I'm not a coder, and
very much not a kernel hacker.

But I have seen a (strange for me) behavior.

Let me explain what I have seen and what I have tried to narrow
down the problem.

The "problem" is that I see that when transferring large amounts
of data many IRQs are being generated. This could be expected
behavior, and then you would not need to care much about my report
but I think that something is wrong.

Because the card is default set to have "rx checksumming" enabled
but if I re-enable it the IRQs for the same transfer goes down to
~9000 interrupts/sec. Which seems to be more like normal rate when
comparing to other NICs (eg. e1000).

I guess that there is some smart function in the NIC to not generate
interrupts all the time when it is delivering packets at a high rate?


Here is the relevant dmesg output for my NIC. It's an integrated
NIC on my ASUS M2A-VM HDMI mb.

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:02:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
r8169 0000:02:00.0: setting latency timer to 64
r8169 0000:02:00.0: irq 26 for MSI/MSI-X
eth0: RTL8168b/8111b at 0xffffc90010944000, 00:1f:c6:b3:ff:eb, XID 18000000 IRQ 26
r8169: eth0: chipset (mac_version = 12).

I added the output of the mac_version when I was troubleshooting.


This is after a fresh start:

sunkan@sunkan:~$ sudo ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: off
scatter-gather: off
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off
large receive offload: off
sunkan@sunkan:~$

Note that rx-checksumming is on..
Then I run the iperf and look at the vmstat output like so:

sunkan@sunkan:~$ iperf -c host2
------------------------------------------------------------
Client connecting to host2, TCP port 5001
TCP window size: 16.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.20.1 port 52496 connected with 192.168.20.30 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.10 GBytes    942 Mbits/sec

sunkan@sunkan:~$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0      0 817308 205932 2144676    0    0     8     9   78   76  2  2 96  0
 0  0      0 817300 205932 2144676    0    0     0     0  716  913  1  0 98  0
 0  0      0 817424 205932 2144676    0    0     0     0  684  928  1  0 99  0
 0  0      0 817432 205932 2144676    0    0     0     0  764 1021  1  0 98  0
 3  0      0 816888 205940 2144672    0    0     0    16 4437 1234  1  1 97  0
 0  0      0 814632 205940 2144784    0    0   108    20 58918 2159  2 12 85  0
 0  0      0 814476 205940 2144784    0    0     0     0 59634 1787  1 13 86  0
 0  0      0 814436 205940 2144784    0    0     0     0 59496 1843  2 12 86  0
 2  0      0 814676 205940 2144784    0    0     0     0 59657 1745  1 12 87  0
 1  0      0 814756 205940 2144784    0    0     0     0 59790 1808  1 13 86  0
 0  0      0 814540 205948 2144784    0    0     0    16 59564 1797  1 12 87  0
 0  0      0 814540 205948 2144784    0    0     0     0 60349 3695  1 14 84  0
 0  0      0 814476 205948 2144784    0    0     0     0 59649 1699  1 12 87  0
 1  0      0 814580 205948 2144784    0    0     0     0 59449 1664  1 12 87  0
 1  0      0 816988 205948 2144784    0    0     0     0 54518 1635  1 11 88  0
 0  0      0 817236 205948 2144784    0    0     0     0  790 1056  2  1 98  0
 1  0      0 817236 205948 2144784    0    0     0     0  714  975  1  0 99  0
^C

Note that "in" is ~60k

If I then re-enable rx-checksumming like so:
sunkan@sunkan:~$ sudo ethtool -K eth0 rx on

And run the test again:
sunkan@sunkan:~$ iperf -c host2
------------------------------------------------------------
Client connecting to host2, TCP port 5001
TCP window size: 16.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.20.1 port 56916 connected with 192.168.20.30 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.10 GBytes    942 Mbits/sec
sunkan@sunkan:~$


sunkan@sunkan:~$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 2  0      0 816788 206124 2145004    0    0     0     0  742  982  1  0 98  0
 0  0      0 816676 206124 2145004    0    0     0     0  727  984  1  0 98  0
 1  0      0 816788 206128 2145004    0    0     0    28  689  915  1  0 99  0
 0  0      0 816788 206128 2145004    0    0     0     0  798 1080  2  0 98  0
 0  0      0 816788 206128 2145004    0    0     0     8  767 1008  1  1 98  0
 0  0      0 816788 206128 2145004    0    0     0     0  681  952  1  0 99  0
 3  0      0 816788 206128 2145004    0    0     0     0  952 1235  4  1 95  0
 0  0      0 816804 206128 2145008    0    0     0     0 2595 3978 12  3 86  0
 0  0      0 816788 206128 2145036    0    0     0     0  860 1131  2  0 98  0
 2  0      0 814572 206136 2145032    0    0     0    48 5413 2179  2  5 93  0
 0  0      0 814388 206144 2145032    0    0     0    40 7587 2219  2 17 81  1
 2  0      0 814676 206144 2145036    0    0     0     0 10459 3345  6 13 81  0
 1  0      0 814396 206144 2145036    0    0     0     0 9396 2283  2 12 86  0
 0  0      0 814108 206144 2145036    0    0     0     0 9424 1852  1 10 89  0
 2  0      0 814516 206144 2145036    0    0     0     0 9150 1934  2 10 88  0
 0  0      0 814548 206144 2145036    0    0     0     0 8984 1986  2 12 86  0
 1  0      0 814092 206144 2145036    0    0     0     0 9425 2053  1 12 88  0
 0  0      0 814476 206144 2145036    0    0     0     0 8195 2090  1 15 84  0
 0  0      0 814508 206144 2145036    0    0     0     0 8759 2034  1 12 87  0
 0  0      0 816744 206144 2145036    0    0     0     0 4813 1435  1  5 94  0
 0  0      0 816800 206144 2145036    0    0     0     0  771 1049  1  0 98  0
^C

Here you can se in the latter part that "in" is registering ~9000
interrupts/sec. This seems more "normal" to me (comparing to other NICs)


Originally I was playing with jumbo frames and stumbled upon this at that
time, I have issues with jumbo frames too but I will write another email
about that.

What I noticed was that changing the mtu made the interrupts go back to
the state it was when the machine was freshly booted.

sunkan@sunkan:~$ sudo ip link set eth0 mtu 1501
sunkan@sunkan:~$ sudo ip link set eth0 mtu 1500
sunkan@sunkan:~$ iperf -c host2
------------------------------------------------------------
Client connecting to host2, TCP port 5001
TCP window size: 16.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.20.1 port 34021 connected with 192.168.20.30 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.10 GBytes    942 Mbits/sec
sunkan@sunkan:~$
sunkan@sunkan:~$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0      0 815740 206616 2145072    0    0     8     9   83   78  2  2 96  0
 0  0      0 815732 206616 2145072    0    0     0     0  718  935  2  1 98  0
 0  0      0 815732 206616 2145072    0    0     0     0  638  888  1  0 98  0
 0  0      0 815732 206616 2145072    0    0     0     0  803 1108  1  0 99  0
 3  0      0 813144 206616 2145072    0    0     0     0 40334 2159  1  7 91  0
 1  0      0 813072 206620 2145072    0    0     0    16 59725 1901  1 13 86  0
 1  0      0 813152 206620 2145072    0    0     0    56 59505 1844  2 12 86  0
 2  0      0 813000 206620 2145072    0    0     0     0 59871 1848  1 12 86  0
 0  0      0 813000 206620 2145072    0    0     0     0 59169 1773  1 11 88  0
 3  0      0 812748 206620 2145072    0    0     0     0 59157 1848  3 11 86  0
 1  0      0 812804 206628 2145072    0    0     0    16 59805 3600  1 12 87  0
 2  0      0 812764 206632 2145068    0    0     0    20 59740 1734  1 12 86  1
 1  0      0 812660 206632 2145072    0    0     0     0 59694 1836  1 13 86  0
 2  0      0 812660 206632 2145072    0    0     0     0 59521 1901  1 13 86  0
 0  0      0 815380 206632 2145072    0    0     0     0 19719 1250  1  4 94  0
 0  0      0 815412 206632 2145072    0    0     0     0  731  984  1  0 98  0
 0  0      0 815412 206632 2145072    0    0     0     0  675  928  1  0 98  0
 0  0      0 815412 206640 2145064    0    0     0    16  739 1004  1  0 98  0
^C
sunkan@sunkan:~$

~60k interrupts/sec again..

So looking in the rtl8169_change_mtu function I noticed that the NIC
is being brought down and up again for a brief period.
I looked in the rtl8169_set_rx_csum function for something that could
be "fixing" the IRQ issue, and it seems it's this command.
"RTL_W16(CPlusCmd, tp->cp_cmd);"

Now, I have really no clue what that actually does. But I tried
to add it in change_mtu function to see how it changed the behaviour.
Adding it after "rtl_hw_start(dev);" has the effect that a change
in mtu also fixen the interrupts (like re-enabling rx-checksumming)

        //RTL_W16(CPlusCmd, tp->cp_cmd); // This does not work

        rtl_hw_start(dev);

        RTL_W16(CPlusCmd, tp->cp_cmd); // This works

        rtl8169_request_timer(dev);

So then I went to the rtl_hw_start function and added it in a few places
there to see where it would have effect. And now I narrowed it down to
"tp->hw_start(dev);". If I add it after that it is generating ~9000
interrupts/sec during iperf tests even after a fresh boot.

I tried to go further but since I don't really know what I'm doing I
thought that it might be better to report my findings and see if someone
can help with finding a proper solution.
Or maybe an explanation of the behavior if it's expected.


Long email so I'll stop here, let me know if I can provide more info.

P.S. I'm currently not subscribed so please CC me on any posts regarding
this.

/Andreas Sundstrom
