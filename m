From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Accelerated receive flow steering (aRFS) for UDP
Date: Sun, 09 Oct 2016 10:14:53 -0700
Message-ID: <1476033293.28155.273.camel@edumazet-glaptop3.roam.corp.google.com>
References: <SN1PR07MB244706470867A923CF0FAF6589C60@SN1PR07MB2447.namprd07.prod.outlook.com>
         <1475883496.28155.270.camel@edumazet-glaptop3.roam.corp.google.com>
         <SN1PR07MB2447ED02140770F0B46967D589D90@SN1PR07MB2447.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "maorg@mellanox.com" <maorg@mellanox.com>,
        "tom@herbertland.com" <tom@herbertland.com>
To: "Chopra, Manish" <Manish.Chopra@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34941 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751609AbcJIRO4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 13:14:56 -0400
Received: by mail-pf0-f169.google.com with SMTP id 128so25148469pfz.2
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 10:14:55 -0700 (PDT)
In-Reply-To: <SN1PR07MB2447ED02140770F0B46967D589D90@SN1PR07MB2447.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-10-08 at 12:25 +0000, Chopra, Manish wrote:
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > Sent: Saturday, October 08, 2016 5:08 AM
> > To: Chopra, Manish <Manish.Chopra@cavium.com>
> > Cc: netdev@vger.kernel.org; maorg@mellanox.com; tom@herbertland.com
> > Subject: Re: Accelerated receive flow steering (aRFS) for UDP
> > 
> > On Fri, 2016-10-07 at 22:55 +0000, Chopra, Manish wrote:
> > > Hello Folks,
> > >
> > > I am experimenting aRFS with our NIC devices, and for that I have
> > > kernel 4.8.x installed with below config.
> > >
> > > CONFIG_RPS=y
> > > CONFIG_RFS_ACCEL=y
> > >
> > > # cat /proc/cpuinfo  | grep processor
> > > processor       : 0
> > > processor       : 1
> > > processor       : 2
> > > processor       : 3
> > > processor       : 4
> > > processor       : 5
> > > processor       : 6
> > > processor       : 7
> > > processor       : 8
> > > processor       : 9
> > > processor       : 10
> > > processor       : 11
> > > processor       : 12
> > > processor       : 13
> > > processor       : 14
> > > processor       : 15
> > >
> > > I configured rps_sock_flow_entries  and our NIC rx queues with below
> > > values
> > >
> > > echo 32768 > /proc/sys/net/core/rps_sock_flow_entries
> > > echo 4096 > /sys/class/net/p4p1/queues/rx-0/rps_flow_cnt
> > > echo 4096 > /sys/class/net/p4p1/queues/rx-1/rps_flow_cnt
> > > echo 4096 > /sys/class/net/p4p1/queues/rx-2/rps_flow_cnt
> > > echo 4096 > /sys/class/net/p4p1/queues/rx-3/rps_flow_cnt
> > > echo 4096 > /sys/class/net/p4p1/queues/rx-4/rps_flow_cnt
> > > echo 4096 > /sys/class/net/p4p1/queues/rx-5/rps_flow_cnt
> > > echo 4096 > /sys/class/net/p4p1/queues/rx-6/rps_flow_cnt
> > > echo 4096 > /sys/class/net/p4p1/queues/rx-7/rps_flow_cnt
> > >
> > > echo ffff > /sys/class/net/p4p1/queues/rx-0/rps_cpus
> > > echo ffff > /sys/class/net/p4p1/queues/rx-1/rps_cpus
> > > echo ffff > /sys/class/net/p4p1/queues/rx-2/rps_cpus
> > > echo ffff > /sys/class/net/p4p1/queues/rx-3/rps_cpus
> > > echo ffff > /sys/class/net/p4p1/queues/rx-4/rps_cpus
> > > echo ffff > /sys/class/net/p4p1/queues/rx-5/rps_cpus
> > > echo ffff > /sys/class/net/p4p1/queues/rx-6/rps_cpus
> > > echo ffff > /sys/class/net/p4p1/queues/rx-7/rps_cpus
> > >
> > > Below is IRQ affinity configuration for NIC irqs used.
> > >
> > > # cat /proc/irq/67/smp_affinity_list
> > > 8
> > > # cat /proc/irq/68/smp_affinity_list
> > > 9
> > > # cat /proc/irq/69/smp_affinity_list
> > > 10
> > > # cat /proc/irq/70/smp_affinity_list
> > > 11
> > > # cat /proc/irq/71/smp_affinity_list
> > > 12
> > > # cat /proc/irq/72/smp_affinity_list
> > > 13
> > > # cat /proc/irq/73/smp_affinity_list
> > > 14
> > > # cat /proc/irq/74/smp_affinity_list
> > > 15
> > >
> > > Driver has required feature NETIF_F_NTUPLE set, ndo_rx_flow_steer()
> > > registered and I am running UDP multiple connections stream using
> > > netperf to the host where I am experimenting aRFS.
> > >
> > > # netperf -V
> > > Netperf version 2.7.0
> > >
> > > netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 8,8 -- -m 1470 -P
> > > 5001,48512 &
> > > netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 9,9 -- -m 1470 -P
> > > 5001,37990 &
> > > netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 10,10 -- -m 1470 -P
> > > 5001,40302 &
> > > netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 11,11 -- -m 1470 -P
> > > 5001,39071 &
> > > netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 12,12 -- -m 1470 -P
> > > 5001,58994 &
> > > netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 13,13 -- -m 1470 -P
> > > 5001,59884 &
> > > netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 14,14 -- -m 1470 -P
> > > 5001,40282 &
> > > netperf -H 192.168.200.40 -t UDP_STREAM -l 150 -T 15,15 -- -m 1470 -P
> > > 5001,56042 &
> > >
> > > I see that our registered callback for ndo_rx_flow_steer() "NEVER"
> > > gets invoked for UDP packets, with TCP_STREAM I do see it gets
> > > invoked.
> > > But while running UDP_STREAM I see it gets invoked for some of TCP
> > > packets as netperf also uses TCP managed connections while running
> > > UDP_STREAM.
> > >
> > > My initial investigation suspects that while running UDP_STREAM with
> > > netperf, rps_sock_flow_table doesn't get updated, as packets never
> > > reach to the flow of inet_recvmsg()
> > > where it gets updated using sock_rps_record_flow(). Which might be the
> > > reason it never invokes NIC's flow steering handler ?
> > >
> > > Please note that when I run UDP stream using "iperf" - I do see that
> > > our registered callback function for flow steering gets invoked for
> > > "UDP" packets.
> > > I am not sure if I am missing something in configuration or something
> > > else which is I am unware of  ?
> > >
> > > I appreciate any help for this.
> > 
> > Make sure you use connected UDP flows
> > 
> > 
> > netperf -t UDP_STREAM ... -- -N -n
> > 
> > Otherwise, one UDP socket can be involved in millions of 4-tuples (aka
> > flows)
> > 
> > 
> 
> Hi Eric, I tried with it but it doesn't help with the said issue. I still don't see that our registered handler for flow steering (ndo_rx_flow_steer()) is getting
> invoked for UDP packets [ip->protocol = IPPROTO_UDP] .All it gets invoked for TCP packets only [ip->protocol = IPPROTO_TCP]
> 
> netperf -H $1 -t UDP_STREAM -l 150 -T 8,8 -- -N -m 1470 -P 5001,48512 &
> netperf -H $1 -t UDP_STREAM -l 150 -T 9,9 -- -N -m 1470 -P 5001,37990 &
> netperf -H $1 -t UDP_STREAM -l 150 -T 10,10 -- -N -m 1470 -P 5001,40302 &
> netperf -H $1 -t UDP_STREAM -l 150 -T 11,11 -- -N -m 1470 -P 5001,39071 &
> netperf -H $1 -t UDP_STREAM -l 150 -T 12,12 -- -N -m 1470 -P 5001,58994 &
> netperf -H $1 -t UDP_STREAM -l 150 -T 13,13 -- -N -m 1470 -P 5001,59884 &
> netperf -H $1 -t UDP_STREAM -l 150 -T 14,14 -- -N -m 1470 -P 5001,40282 &
> netperf -H $1 -t UDP_STREAM -l 150 -T 15,15 -- -N -m 1470 -P 5001,56042 &
> 
> Thanks !!

Please carefully read what I wrote, and carefully read netperf
documentation.

When you add -n option to netperf, it _will_ use connected UDP sockets
and your problem will vanish.

You added '-N' only, which is useless for UDP_STREAM.

It might help for UDP_RR, but not UDP_STREAM.
