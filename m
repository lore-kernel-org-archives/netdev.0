From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Tue, 30 Nov 2010 10:34:59 +0100
Message-ID: <1291109699.2904.11.camel@edumazet-laptop>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rui <wirelesser@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60925 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab0K3JfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 04:35:03 -0500
Received: by bwz15 with SMTP id 15so4818844bwz.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 01:35:01 -0800 (PST)
In-Reply-To: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 17:22 +0800, Rui a =C3=A9crit :
> hi
>=20
> I did a test with an intel X520 10Gnic, HP DL380 G6,  to see how the
> bpf filter will impact the performance.
>=20
> kernel .2.6.32 SLES11+SP1, original ixgbe driver
>=20

Could you try latest net-next-2.6, we optimized bpf a bit lately

commit 93aaae2e01e57483256b7da05c9a7ebd65ad4686
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Fri Nov 19 09:49:59 2010 -0800

    filter: optimize sk_run_filter
   =20


> step 0:
> launch 4 tcpdump processes,each applied a filter to filter out some
> GTP-U packets. seen with 'tcpdump -d', the bpf code has about 100
> lines.
>=20
> #!/bin/sh
> PCAP_FRAMES=3D32000 ./tcpdump_MMAP -i eth4 'udp dst port 2152 and (
> (((ether[48:1]&0x07)>0) and
> (((ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1]+ether[70:1]+ether[=
71:1]+ether[72:1]+ether[73:1])&0x03)=3D=3D0))
> or (((ether[48:1]&0x07)=3D=3D0) and
> (((ether[62:1]+ether[63:1]+ether[64:1]+ether[65:1]+ether[66:1]+ether[=
67:1]+ether[68:1]+ether[69:1])&0x03)=3D=3D0))
> ) ' -w /dev/null -s 4096 2>f1.log &
> PCAP_FRAMES=3D32000 ./tcpdump_MMAP -i eth4 'udp dst port 2152 and (
> (((ether[48:1]&0x07)>0) and
> (((ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1]+ether[70:1]+ether[=
71:1]+ether[72:1]+ether[73:1])&0x03)=3D=3D1))
> or (((ether[48:1]&0x07)=3D=3D0) and
> (((ether[62:1]+ether[63:1]+ether[64:1]+ether[65:1]+ether[66:1]+ether[=
67:1]+ether[68:1]+ether[69:1])&0x03)=3D=3D1))
> ) ' -w /dev/null -s 4096 2>f2.log &
> PCAP_FRAMES=3D32000 ./tcpdump_MMAP -i eth4 'udp dst port 2152 and (
> (((ether[48:1]&0x07)>0) and
> (((ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1]+ether[70:1]+ether[=
71:1]+ether[72:1]+ether[73:1])&0x03)=3D=3D2))
> or (((ether[48:1]&0x07)=3D=3D0) and
> (((ether[62:1]+ether[63:1]+ether[64:1]+ether[65:1]+ether[66:1]+ether[=
67:1]+ether[68:1]+ether[69:1])&0x03)=3D=3D2))
> ) ' -w /dev/null -s 4096 2>f3.log &
> PCAP_FRAMES=3D32000 ./tcpdump_MMAP -i eth4 'udp dst port 2152 and (
> (((ether[48:1]&0x07)>0) and
> (((ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1]+ether[70:1]+ether[=
71:1]+ether[72:1]+ether[73:1])&0x03)=3D=3D3))
> or (((ether[48:1]&0x07)=3D=3D0) and
> (((ether[62:1]+ether[63:1]+ether[64:1]+ether[65:1]+ether[66:1]+ether[=
67:1]+ether[68:1]+ether[69:1])&0x03)=3D=3D3))
> ) ' -w /dev/null -s 4096 2>f4.log &
>=20
>=20

Hmm, do you receive trafic on several queues of your card ?

Do you have 4 cpus running ?

grep eth /proc/interrupts


> step1:
> use stress test equipment to generate traffic >1.2Gbps
>=20
>=20
> step2:
> type 'ifconfig eth4'
> saw many packets dropped
>=20
> step3:
> type 'sar -n DEV 1', the incoming throughput limited at 800Mbps
>=20
>=20
> my questions:
>=20
> Q1. the bpf filter is run one by one? will only one filter be execute=
d
> for one sock? (so that the tcpdump corresponding kernel part will run
> filter in parallel?)
>=20

bpf filter is run on behalf of the softirq processing.

> Q2. performance is bad? any idea to improve it?
>=20

multiqueue card : split each IRQ on a separate cpu.

If not multiqueue card : use RPS on a recent kernel to split the load o=
n
several cpus.

Use a filter against the queue, instead of doing a hash code yourself i=
n
the bpf. (code added in commit d19742fb (linux-2.6.33)

(you need to tweak libpcap to use SKF_AD_QUEUE instruction)

commit d19742fb1c68e6db83b76e06dea5a374c99e104f
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Tue Oct 20 01:06:22 2009 -0700

    filter: Add SKF_AD_QUEUE instruction
   =20
    It can help being able to filter packets on their queue_mapping.
   =20
    If filter performance is not good, we could add a "numqueue" field
    in struct packet_type, so that netif_nit_deliver() and other functi=
ons
    can directly ignore packets with not expected queue number.
   =20
    Lets experiment this simple filter extension first.





