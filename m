From: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
Subject: Fwd: Linux stack performance drop (TCP and UDP) in 3.10 kernel in
 routed scenario
Date: Wed, 4 Jun 2014 14:34:10 +0530
Message-ID: <CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
References: <CAJMXqXZQ_S27LCZNJDjcQ9jy2qyJ0UT2nk+wdZOTQep+5rQZhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, davem@davemloft.ne
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:54082 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbaFDJEL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 05:04:11 -0400
Received: by mail-vc0-f180.google.com with SMTP id hq11so6131176vcb.25
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 02:04:10 -0700 (PDT)
In-Reply-To: <CAJMXqXZQ_S27LCZNJDjcQ9jy2qyJ0UT2nk+wdZOTQep+5rQZhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


    Currently i am working on 3.10.12 kernel and it seems the Linux
stack performance (TCP and UDP) has degraded drastically as compared
to 2.6 kernel.

Results :

Linux 2.6.32
---------------------
TCP traffic using iperf
    - Upstream : 140 Mbps
    - Downstream : 148 Mbps

UDP traffic using iperf
    - Upstream : 200 Mbps
    - Downstream : 245 Mbps

Linux 3.10.12
--------------------
TCP traffic using iperf
    - Upstream : 101 Mbps
    - Downstream : 106 Mbps

UDP traffic using iperf
    - Upstream : 140 Mbps
    - Downstream : 170 Mbps

Analysis:
---------------
1.   As per profiling data on Linux-3.10.12 it seems,
             -   fib_table_lookup and ip_route_input_noref is being
called most of the times and thus causing the degradation in
performance.

    8.77    csum_partial 0x80009A20 1404
    4.53    ipt_do_table 0x80365C34 1352
    3.45    eth_xmit 0x870D0C88 5460
    3.41    fib_table_lookup 0x8035240C 856    <----------
    3.38    __netif_receive_skb_core 0x802B5C00 2276
    3.07    dma_device_write 0x80013BD4 752
    2.94    nf_iterate 0x802EA380 256
    2.69    ip_route_input_noref 0x8030CE14 2520    <--------------
    2.24    ip_forward 0x8031108C 1040
    2.04    tcp_packet 0x802F45BC 3956
    1.93    nf_conntrack_in 0x802EEAF4 2284

2.    Based on the above observation, when searched,  it seems Routing
cache code has been removed from Linux-3.6 kernel and thus every
packet has to go through ip_route_input_noref to find the destination.

3.    Related to this, a patch from David Miller adds "ipv4: Early TCP
socket demux" which caches the "dst per socket" and maintains
tcp_hashinfo and uses early_demux(skb) (TCP --> tcp_v4_early_demux and
UDP --> NULL i.e not defined) to get the "dst" of that skb and thus
avoids ip_route_input_noref being called everytime.
          -  But this still doesn=E2=80=99t handle routing scenarios (L=
AN <-->  WAN).

4.    A patch for UDP early demux has been added in Linux 3.13 and
certain bugfixes has gone in Linux-3.14 .

5.    As we are based on 3.10 thus no UDP early_demux support . This
means we have to backport the UDP early demux patch to 3.10 kernel .


Issue :
-----------

1.    The implementation of "Early TCP socket demux" doesn't address
the routing scenario (LAN <---> WAN) . This means TCP and UDP routing
performance will be less in 3.10 kernel and also in 3.14 kernel as
every packet has to go through route lookup.


Is there an alternative to get back the Linux stack performance of 2.6
or 3.4 kernel where we have the route cache ?

I guess plain routing scenario was NOT thought through while removing
the routing cache code.

Please guide .


Thanks and Regards,
Suprasad.
