From: Bernhard Schmidt <berni@birkenwald.de>
Subject: vmxnet3 LROv6 performance issues
Date: Tue, 1 Mar 2016 13:08:35 +0000 (UTC)
Message-ID: <nb448j$tf4$1@ger.gmane.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:56824 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbcCANIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 08:08:49 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1aak2g-0000iC-Bb
	for netdev@vger.kernel.org; Tue, 01 Mar 2016 14:08:46 +0100
Received: from nat64.discard.me.uk ([90.155.46.46])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 14:08:46 +0100
Received: from berni by nat64.discard.me.uk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 14:08:46 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this started as a Debian bug
(http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=816377), but since
it's affecting SLES as well I'm hoping to get some help here.

Back in 2014 we migrated our VMware farm from old HP blade servers to
new ones

Old: HP BL490c Gen6, Flex10 something, BCM57711E
New: HP BL460c Gen8, HP FlexFabric 630FLB, BCM57840

The new network chipset apparently sports IPV6 LRO support in hardware.
Unfortunately that support was broken with in-tree vmxnet3 kernel
modules back then, TCPv6 connections were stalling all over the place.
Disabling LRO or using the vmxnet3 module provided by VMware fixed the
issue.

We are now seeing the issue again. Not as prominent as before, but still
affecting some workloads pretty badly (for example a simple iperf3
benchmark towards an affected VM).

client% iperf3 -c ping.lrz.de -t 30
Connecting to host ping.lrz.de, port 5201
[  4] local 2001:4ca0:0:f000:bf47:886b:a813:df4f port 60174 connected to 2001:4ca0:0:101::81bb:a11 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec   305 KBytes  2.50 Mbits/sec   34   8.37 KBytes       
[  4]   1.00-2.00   sec  0.00 Bytes  0.00 bits/sec   24   2.79 KBytes       
[  4]   2.00-3.00   sec   251 KBytes  2.06 Mbits/sec   75   2.79 KBytes       
[  4]   3.00-4.00   sec   251 KBytes  2.06 Mbits/sec  124   2.79 KBytes       
[  4]   4.00-5.00   sec  88.7 MBytes   744 Mbits/sec   24    332 KBytes       
[  4]   5.00-6.00   sec   111 MBytes   931 Mbits/sec    0    476 KBytes       
[  4]   6.00-7.00   sec   110 MBytes   921 Mbits/sec    0    478 KBytes       
[  4]   7.00-8.00   sec   110 MBytes   923 Mbits/sec    0    481 KBytes       
[  4]   8.00-9.00   sec   110 MBytes   921 Mbits/sec    0    502 KBytes       
[  4]   9.00-10.00  sec  19.8 MBytes   166 Mbits/sec   27   2.79 KBytes       
[  4]  10.00-11.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  11.00-12.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  12.00-13.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  13.00-14.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  14.00-15.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  15.00-16.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  16.00-17.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  17.00-18.00  sec  0.00 Bytes  0.00 bits/sec   16   2.79 KBytes       
[  4]  18.00-19.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  19.00-20.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  20.00-21.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  21.00-22.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  22.00-23.00  sec  0.00 Bytes  0.00 bits/sec   22   2.79 KBytes       
[  4]  23.00-24.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  24.00-25.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  25.00-26.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  26.00-27.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  27.00-28.00  sec  0.00 Bytes  0.00 bits/sec   16   2.79 KBytes       
[  4]  28.00-29.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
[  4]  29.00-30.00  sec  0.00 Bytes  0.00 bits/sec   20   2.79 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-30.00  sec   550 MBytes   154 Mbits/sec  702             sender
[  4]   0.00-30.00  sec   547 MBytes   153 Mbits/sec                  receiver

iperf Done.

server# ethtool -K eth0 lro off

client% iperf3 -c ping.lrz.de -t 30
Connecting to host ping.lrz.de, port 5201
[  4] local 2001:4ca0:0:f000:bf47:886b:a813:df4f port 60228 connected to 2001:4ca0:0:101::81bb:a11 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec   112 MBytes   942 Mbits/sec    0    477 KBytes       
[  4]   1.00-2.00   sec   110 MBytes   921 Mbits/sec    0    499 KBytes       
[  4]   2.00-3.00   sec   110 MBytes   924 Mbits/sec    0    499 KBytes       
[  4]   3.00-4.00   sec   109 MBytes   918 Mbits/sec    0    499 KBytes       
[  4]   4.00-5.00   sec   110 MBytes   919 Mbits/sec    0    523 KBytes       
[  4]   5.00-6.00   sec   110 MBytes   926 Mbits/sec    0    523 KBytes       
[  4]   6.00-7.00   sec   110 MBytes   919 Mbits/sec    0    547 KBytes       
[  4]   7.00-8.00   sec   110 MBytes   927 Mbits/sec    0    547 KBytes       
[  4]   8.00-9.00   sec   110 MBytes   924 Mbits/sec    0    629 KBytes       
[  4]   9.00-10.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  10.00-11.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  11.00-12.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  12.00-13.00  sec   109 MBytes   912 Mbits/sec    0    629 KBytes       
[  4]  13.00-14.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  14.00-15.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  15.00-16.00  sec   110 MBytes   922 Mbits/sec    0    629 KBytes       
[  4]  16.00-17.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  17.00-18.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  18.00-19.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  19.00-20.00  sec   110 MBytes   922 Mbits/sec    0    629 KBytes       
[  4]  20.00-21.00  sec   110 MBytes   922 Mbits/sec    0    629 KBytes       
[  4]  21.00-22.00  sec   109 MBytes   912 Mbits/sec    0    629 KBytes       
[  4]  22.00-23.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  23.00-24.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  24.00-25.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  25.00-26.00  sec   110 MBytes   922 Mbits/sec    0    629 KBytes       
[  4]  26.00-27.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  27.00-28.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  28.00-29.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
[  4]  29.00-30.00  sec   110 MBytes   923 Mbits/sec    0    629 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-30.00  sec  3.22 GBytes   922 Mbits/sec    0             sender
[  4]   0.00-30.00  sec  3.22 GBytes   922 Mbits/sec                  receiver

We see this in

Debian Jessie		3.16.7-ckt20-1+deb8u3	1.2.0.0-k
Debian Jessie+bpo	4.3.3-7~bpo8+1		1.4.2.0-k
SLES11SP4		3.0.101-68-default	1.4.2.0-k
SLES12SP1		3.12.53-60.30-default	1.4.2.0-k

We do _not_ see this issue when using the "official" vmxnet3 kernel
module from the VMware tools on SLES11SP4, which has the same version.
This was the only way to get LROv6 working back then as well.

SLES11SP4+VMW		3.0.101-68-default	1.4.2.0

Compiling our own vmxnet3 is not supported by VMware on Debian Jessie
and SLES12SP1 anymore, you are supposed to use the in-kernel driver.

The host runs ESXi 5.5.0 U3b (Build 3343343) with the latest firmware
and bnx2x driver supported by HP for VMware.

Disabling HW LRO on the host works as well (setting Net.Vmxnet3HwLRO=0)
as described in 
https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2055140
You need to migrate the machine off the host and back on to activate it.

I'm a bit unsure where to search here. It is definitely
hardware/firmware and/or ESXi related. OTOH the VMware-Tools vmxnet3
driver seems to do something very different from the in-kernel driver.

Best Regards,
Bernhard
