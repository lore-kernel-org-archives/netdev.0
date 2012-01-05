From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Thu, 05 Jan 2012 10:49:36 +0100
Message-ID: <1325756976.2415.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
	 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
	 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
	 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F0382BB.5060601@hp.com>
	 <CAL8zT=iSP+GncMEJ38eaCZ85P-tBDMUjUeaFr-x3j_rksUaK2A@mail.gmail.com>
	 <1325756410.2415.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:53024 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751161Ab2AEJtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 04:49:40 -0500
Received: by lahd3 with SMTP id d3so99464lah.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 01:49:39 -0800 (PST)
In-Reply-To: <1325756410.2415.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 10:40 +0100, Eric Dumazet a =C3=A9crit =
:

> Could you test UDP_STREAM as well ?
>=20
> $ netperf -H 192.168.0.1 -l 10 -t UDP_STREAM
> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.0.1 (192.168.0.1) port 0 AF_INET
> Socket  Message  Elapsed      Messages               =20
> Size    Size     Time         Okay Errors   Throughput
> bytes   bytes    secs            #      #   10^6bits/sec
>=20
> 1000000   65507   10.00       13398      0     702.12
> 110592           10.00       13398            702.12
>=20

Ah, I had a special BQL setup, this explains I didnt reach line rate.

After doing :

$ echo max >/sys/class/net/eth3/queues/tx-0/byte_queue_limits/limit_max

I get line rate :

$ grep . /sys/class/net/eth3/queues/tx-0/byte_queue_limits/*
/sys/class/net/eth3/queues/tx-0/byte_queue_limits/hold_time:1000
/sys/class/net/eth3/queues/tx-0/byte_queue_limits/inflight:154294
/sys/class/net/eth3/queues/tx-0/byte_queue_limits/limit:152852
/sys/class/net/eth3/queues/tx-0/byte_queue_limits/limit_max:1879048192
/sys/class/net/eth3/queues/tx-0/byte_queue_limits/limit_min:0


perf record netperf -H 192.168.0.1 -l 10 -t UDP_STREAM -- -m 1400
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.0.1 (192.168.0.1) port 0 AF_INET
Socket  Message  Elapsed      Messages               =20
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

1000000    1400   10.00      853120      0     955.49
110592           10.00      852799            955.13

[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.155 MB perf.data (~6779 samples) ]

$ perf report --stdio
# =3D=3D=3D=3D=3D=3D=3D=3D
# captured on: Thu Jan  5 10:45:29 2012
# hostname : svivoipvnx001
# os release : 3.2.0-rc7-15182-g3b9b886-dirty
# perf version : 3.2.rc7.272.ga1b347.dirty
# arch : i686
# nrcpus online : 8
# nrcpus avail : 8
# cpudesc : Intel(R) Xeon(R) CPU E5450 @ 3.00GHz
# cpuid : GenuineIntel,6,23,6
# total memory : 4147856 kB
# cmdline : /usr/bin/perf record netperf -H 192.168.0.1 -l 10 -t UDP_ST=
REAM -- -m 1400=20
# event : name =3D cycles, type =3D 0, config =3D 0x0, config1 =3D 0x0,=
 config2 =3D 0x0, excl_usr =3D 0, excl_kern =3D 0, id =3D { 65, 66
# HEADER_CPU_TOPOLOGY info available, use -I to display
# =3D=3D=3D=3D=3D=3D=3D=3D
#
# Events: 3K cycles
#
# Overhead  Command      Shared Object                                S=
ymbol
# ........  .......  .................  ...............................=
=2E....
#
    54.87%  netperf  [kernel.kallsyms]  [k] __copy_from_user_ll
     5.93%  netperf  [kernel.kallsyms]  [k] __ip_make_skb
     5.00%  netperf  [kernel.kallsyms]  [k] __ip_append_data.clone.64
     2.23%  netperf  [kernel.kallsyms]  [k] __alloc_skb
     2.06%  netperf  [kernel.kallsyms]  [k] sysenter_past_esp
     1.94%  netperf  [ip_tables]        [k] ipt_do_table
     1.78%  netperf  [kernel.kallsyms]  [k] udp_sendmsg
     1.58%  netperf  [kernel.kallsyms]  [k] __ip_route_output_key
     1.48%  netperf  [kernel.kallsyms]  [k] sock_alloc_send_pskb
     1.10%  netperf  [kernel.kallsyms]  [k] udp_send_skb
     1.07%  netperf  [kernel.kallsyms]  [k] ip_finish_output
     1.04%  netperf  [kernel.kallsyms]  [k] __kmalloc_track_caller
     1.03%  netperf  [kernel.kallsyms]  [k] memcpy
     0.97%  netperf  [kernel.kallsyms]  [k] local_bh_enable
     0.88%  netperf  [kernel.kallsyms]  [k] __slab_alloc.clone.58
     0.88%  netperf  [kernel.kallsyms]  [k] __ip_local_out
     0.82%  netperf  [unknown]          [.] 0xffffe424
     0.80%  netperf  [kernel.kallsyms]  [k] kmem_cache_alloc
     0.73%  netperf  [kernel.kallsyms]  [k] nf_iterate
     0.71%  netperf  [kernel.kallsyms]  [k] pfifo_fast_enqueue
     0.70%  netperf  [kernel.kallsyms]  [k] _raw_spin_lock
     0.69%  netperf  [kernel.kallsyms]  [k] _copy_from_user
     0.58%  netperf  [kernel.kallsyms]  [k] dev_queue_xmit
     0.54%  netperf  [kernel.kallsyms]  [k] ipv4_mtu
     0.50%  netperf  [kernel.kallsyms]  [k] ipv4_validate_peer
     0.46%  netperf  [kernel.kallsyms]  [k] ksize
     0.46%  netperf  [kernel.kallsyms]  [k] sys_sendto
     0.44%  netperf  [kernel.kallsyms]  [k] nf_hook_slow
     0.39%  netperf  netperf            [.] send_udp_stream
     0.38%  netperf  [kernel.kallsyms]  [k] sock_sendmsg
