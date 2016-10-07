From: "Chopra, Manish" <Manish.Chopra@cavium.com>
Subject: Accelerated receive flow steering (aRFS) for UDP
Date: Fri, 7 Oct 2016 22:55:52 +0000
Message-ID: <SN1PR07MB244706470867A923CF0FAF6589C60@SN1PR07MB2447.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "maorg@mellanox.com" <maorg@mellanox.com>,
        "tom@herbertland.com" <tom@herbertland.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0045.outbound.protection.outlook.com ([104.47.38.45]:29328
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751968AbcJGX3i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 19:29:38 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Folks,

I am experimenting aRFS with our NIC devices, and for that I have kernel 4.=
8.x installed with below config.

CONFIG_RPS=3Dy
CONFIG_RFS_ACCEL=3Dy

# cat /proc/cpuinfo  | grep processor
processor       : 0
processor       : 1
processor       : 2
processor       : 3
processor       : 4
processor       : 5
processor       : 6
processor       : 7
processor       : 8
processor       : 9
processor       : 10
processor       : 11
processor       : 12
processor       : 13
processor       : 14
processor       : 15

I configured rps_sock_flow_entries  and our NIC rx queues with below values

echo 32768 > /proc/sys/net/core/rps_sock_flow_entries
echo 4096 > /sys/class/net/p4p1/queues/rx-0/rps_flow_cnt
echo 4096 > /sys/class/net/p4p1/queues/rx-1/rps_flow_cnt
echo 4096 > /sys/class/net/p4p1/queues/rx-2/rps_flow_cnt
echo 4096 > /sys/class/net/p4p1/queues/rx-3/rps_flow_cnt
echo 4096 > /sys/class/net/p4p1/queues/rx-4/rps_flow_cnt
echo 4096 > /sys/class/net/p4p1/queues/rx-5/rps_flow_cnt
echo 4096 > /sys/class/net/p4p1/queues/rx-6/rps_flow_cnt
echo 4096 > /sys/class/net/p4p1/queues/rx-7/rps_flow_cnt

echo ffff > /sys/class/net/p4p1/queues/rx-0/rps_cpus
echo ffff > /sys/class/net/p4p1/queues/rx-1/rps_cpus
echo ffff > /sys/class/net/p4p1/queues/rx-2/rps_cpus
echo ffff > /sys/class/net/p4p1/queues/rx-3/rps_cpus
echo ffff > /sys/class/net/p4p1/queues/rx-4/rps_cpus
echo ffff > /sys/class/net/p4p1/queues/rx-5/rps_cpus
echo ffff > /sys/class/net/p4p1/queues/rx-6/rps_cpus
echo ffff > /sys/class/net/p4p1/queues/rx-7/rps_cpus

Below is IRQ affinity configuration for NIC irqs used.=20

# cat /proc/irq/67/smp_affinity_list
8
# cat /proc/irq/68/smp_affinity_list
9
# cat /proc/irq/69/smp_affinity_list
10
# cat /proc/irq/70/smp_affinity_list
11
# cat /proc/irq/71/smp_affinity_list
12
# cat /proc/irq/72/smp_affinity_list
13
# cat /proc/irq/73/smp_affinity_list
14
# cat /proc/irq/74/smp_affinity_list
15

Driver has required feature NETIF_F_NTUPLE set, ndo_rx_flow_steer() registe=
red and I am running UDP multiple connections stream using netperf to the h=
ost where I am experimenting aRFS.=20

# netperf -V
Netperf version 2.7.0

netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 8,8 -- -m 1470 -P 5001,48=
512 &
netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 9,9 -- -m 1470 -P 5001,37=
990 &
netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 10,10 -- -m 1470 -P 5001,=
40302 &
netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 11,11 -- -m 1470 -P 5001,=
39071 &
netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 12,12 -- -m 1470 -P 5001,=
58994 &
netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 13,13 -- -m 1470 -P 5001,=
59884 &
netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 14,14 -- -m 1470 -P 5001,=
40282 &
netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 15,15 -- -m 1470 -P 5001,=
56042 &

I see that our registered callback for ndo_rx_flow_steer() "NEVER" gets inv=
oked for UDP packets, with TCP_STREAM I do see it gets invoked.
But while running UDP_STREAM I see it gets invoked for some of TCP packets =
as netperf also uses TCP managed connections while running  UDP_STREAM.

My initial investigation suspects that while running UDP_STREAM with netper=
f, rps_sock_flow_table doesn't get updated, as packets never reach to the f=
low of inet_recvmsg()
where it gets updated using sock_rps_record_flow(). Which might be the reas=
on it never invokes NIC's flow steering handler ?

Please note that when I run UDP stream using "iperf" - I do see that our re=
gistered callback function for flow steering gets invoked for "UDP" packets=
.
I am not sure if I am missing something in configuration or something else =
which is I am unware of  ?=20

I appreciate any help for this.

Thanks and Regards,
Manish Chopra
