From: Barry G <mr.scada@gmail.com>
Subject: No traffic flow with Marvell 88E6095F using DSA
Date: Fri, 10 Jun 2011 09:52:08 -0700
Message-ID: <BANLkTi=SLBskJu1BuXJzocabpwi8tURwDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:65491 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324Ab1FJQwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 12:52:10 -0400
Received: by bwz15 with SMTP id 15so2337716bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 09:52:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

We are trying to bring up a board with two Marvell 88E6095F chips and
one 88E6185 chip using the Distributed Switch Architecture (DSA)
facilities in the kernel.

We have a rough driver working, but we can't get traffic to flow in
or out of the Marvell chips.

To simplify the system, I am trying to bring up only the chip
attached to the CPU (88E6095F).  I have a dsa_chip_data with
static struct dsa_chip_data switches[] = {
   {
      .sw_addr = 0x9,
      .port_names = {
         "eth%d", //0
         "eth%d", //1
         "eth%d", //2
         "eth%d", //3
         "eth%d", //4
         "eth%d", //5
         "eth%d", //6
         "eth%d", //7
         NULL,   //8
         NULL,   //9
         "cpu",   //10
      },
   }
};

port 8 and 9 are DSA interfaces to other chips.

The host CPU is an Freescale 8308 hooked up to TSEC1.
We are using the mdio bus from the processor to drive
the mdio on the Marells.

Using this configuration with the driver shell I posted
previously the system boots and I see:
Distributed Switch Architecture driver version 0.1
eth0[0]: detected a Marvell 88E6095/88E6095F switch
dsa slave smi: probed

All good.  If I run ip link show I get:
# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:30:a7:aa:aa:02 brd ff:ff:ff:ff:ff:ff
5: teql0: <NOARP> mtu 1500 qdisc noop qlen 100
    link/void
6: tunl0: <NOARP> mtu 1480 qdisc noop
    link/ipip 0.0.0.0 brd 0.0.0.0
7: eth2@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
8: eth3@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
9: eth4@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
10: eth5@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
11: eth6@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
12: eth7@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
13: eth8@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff
14: eth9@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
    link/ether 00:30:a7:aa:aa:01 brd ff:ff:ff:ff:ff:ff

This is after running "ip link set dev eth0 up" and "ip link set dev eth9 up"

Eth9 is hooked up to a cable.  Removing the cable results in the
"eth9: link down" message and plugging it back in gives the "eth9:
link up, 100 Mb/s, half duplex, flow control disabled".

So it looks like everything is stellar, but we can't get traffic
to leave the device.  I configure eth9 with an address (192.168.1.50/24)
and I try to ping 192.168.1.25 I get the following with tcpdump on eth9:
20:23:11.682628 arp who-has 192.168.1.25 tell 192.168.1.50 (repeats)

And on eth0 I see:
20:23:54.692701 00:30:a7:aa:aa:01 (oui Unknown) > Broadcast, ethertype
Unknown (0x4038), length 46:
        0x0000:  0000 0806 0001 0800 0604 0001 0030 a7aa  .............0..
        0x0010:  aa01 c0a8 0132 0000 0000 0000 c0a8 0119  .....2..........


However if I hook up to the port with wireshark I see nothing leaving
the port.  Likewise if I attempt to ping into the device from 192.168.1.25
I see nothing coming in on the tcpdump for eth0 or eth9.

Linux seems happy:
# ./sbin/mii-tool -v eth9
eth9: no autonegotiation, 100baseTx-HD, link ok
  product info: vendor 00:50:43, model 8 rev 5
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  link partner: 100baseTx-HD

# ethtool -S eth9
NIC statistics:
     tx_packets: 1534
     tx_bytes: 64428
     rx_packets: 0
     rx_bytes: 0
     in_good_octets: 151080
     in_bad_octets: 0
     in_unicast: 0
     in_broadcasts: 2035
     in_multicasts: 78
     in_pause: 0
     in_undersize: 0
     in_fragments: 0
     in_oversize: 0
     in_jabber: 0
     in_rx_error: 0
     in_fcs_error: 0
     out_octets: 0
     out_unicast: 0
     out_broadcasts: 0
     out_multicasts: 0
     out_pause: 0
     excessive: 0
     collisions: 0
     deferred: 0
     single: 0
     multiple: 0
     out_fcs_error: 0
     late: 0
     hist_64bytes: 2045
     hist_65_127bytes: 9
     hist_128_255bytes: 16
     hist_256_511bytes: 43
     hist_512_1023bytes: 0
     hist_1024_max_bytes: 0
#

# cat /proc/net/dev
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed
multicast|bytes    packets errs drop fifo colls carrier compressed
    lo:  194432    1736    0    0    0     0          0         0
194432    1736    0    0    0     0       0          0
 bond0:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
  eth0:       0       0    0    0    0     0          0         0
77326    1681    6    0    6     0       0          0
  eth1:  531776    5611    0  349    0     0          0         0
814765    3305    0    0    0     0       0          0
 teql0:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
 tunl0:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
  eth2:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
  eth3:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
  eth4:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
  eth5:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
  eth6:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
  eth7:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
  eth8:       0       0    0    0    0     0          0         0
  0       0    0    0    0     0       0          0
  eth9:       0       0    0    0    0     0          0         0
70602    1681    0    0    0     0       0          0

This problem looks really similar to the thread at:
http://kerneltrap.org/mailarchive/linux-netdev/2009/3/7/5116114/thread
but I have the patch Gary presents already in the tree :-(

I am running 2.6.39-rc4+.

Any help or guidance would be appreciated!  How can I
best approach debugging this issue?

Thanks,

Barry
