From: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
Subject: Re: Fwd: Linux stack performance drop (TCP and UDP) in 3.10 kernel in
 routed scenario
Date: Wed, 4 Jun 2014 19:23:55 +0530
Message-ID: <CAJMXqXaqXG03e+OHr0aMh9x_N4BzBVWTkQLKgNVvq-QmDaX5Ng@mail.gmail.com>
References: <CAJMXqXZQ_S27LCZNJDjcQ9jy2qyJ0UT2nk+wdZOTQep+5rQZhQ@mail.gmail.com>
	<CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
	<1401885281.3645.245.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.ne
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f182.google.com ([209.85.128.182]:49820 "EHLO
	mail-ve0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbaFDNx4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 09:53:56 -0400
Received: by mail-ve0-f182.google.com with SMTP id sa20so8859872veb.13
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 06:53:55 -0700 (PDT)
In-Reply-To: <1401885281.3645.245.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

             Thanks for your inputs. Please find my comments inline.

On Wed, Jun 4, 2014 at 6:04 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Wed, 2014-06-04 at 14:34 +0530, Suprasad Mutalik Desai wrote:
>> Hi,
>>
>>
>>     Currently i am working on 3.10.12 kernel and it seems the Linux
>> stack performance (TCP and UDP) has degraded drastically as compared
>> to 2.6 kernel.
>>
>> Results :
>>
>> Linux 2.6.32
>> ---------------------
>> TCP traffic using iperf
>>     - Upstream : 140 Mbps
>>     - Downstream : 148 Mbps
>>
>> UDP traffic using iperf
>>     - Upstream : 200 Mbps
>>     - Downstream : 245 Mbps
>>
>> Linux 3.10.12
>> --------------------
>> TCP traffic using iperf
>>     - Upstream : 101 Mbps
>>     - Downstream : 106 Mbps
>>
>> UDP traffic using iperf
>>     - Upstream : 140 Mbps
>>     - Downstream : 170 Mbps
>>
>> Analysis:
>> ---------------
>> 1.   As per profiling data on Linux-3.10.12 it seems,
>>              -   fib_table_lookup and ip_route_input_noref is being
>> called most of the times and thus causing the degradation in
>> performance.
>>
>>     8.77    csum_partial 0x80009A20 1404
>
> Main problem here is lack of checksums. What kind of NIC is used ?

I missed out explaining my setup in the previous mail, We use an
embedded router platform running at 600Mhz CPU speed. The NICs don't
have Checksum offload function (as you pointed out), but what I am
trying to analyze is relative performance drop on our router in 3.10
kernel vs 2.6.32/3.4 kernels. For this test, I am sending TCP traffic
using iperf from LAN Ethernet port to WAN Ethernet port, with routing
done by Linux kernel.

>
>>     4.53    ipt_do_table 0x80365C34 1352
>>     3.45    eth_xmit 0x870D0C88 5460
>>     3.41    fib_table_lookup 0x8035240C 856    <----------
>>     3.38    __netif_receive_skb_core 0x802B5C00 2276
>>     3.07    dma_device_write 0x80013BD4 752
>>     2.94    nf_iterate 0x802EA380 256
>>     2.69    ip_route_input_noref 0x8030CE14 2520    <--------------
>>     2.24    ip_forward 0x8031108C 1040
>>     2.04    tcp_packet 0x802F45BC 3956
>>     1.93    nf_conntrack_in 0x802EEAF4 2284
>>
>> 2.    Based on the above observation, when searched,  it seems Routi=
ng
>> cache code has been removed from Linux-3.6 kernel and thus every
>> packet has to go through ip_route_input_noref to find the destinatio=
n.
>>
>> 3.    Related to this, a patch from David Miller adds "ipv4: Early T=
CP
>> socket demux" which caches the "dst per socket" and maintains
>> tcp_hashinfo and uses early_demux(skb) (TCP --> tcp_v4_early_demux a=
nd
>> UDP --> NULL i.e not defined) to get the "dst" of that skb and thus
>> avoids ip_route_input_noref being called everytime.
>>           -  But this still doesn=E2=80=99t handle routing scenarios=
 (LAN <-->  WAN).
>>
>> 4.    A patch for UDP early demux has been added in Linux 3.13 and
>> certain bugfixes has gone in Linux-3.14 .
>>
>> 5.    As we are based on 3.10 thus no UDP early_demux support . This
>> means we have to backport the UDP early demux patch to 3.10 kernel .
>
> Nope : This will be of no use on a router. It even will slow down the
> router.
>

So i gather, early_demux code is applicable to the traffic which is
either originating or terminating on the device basically Host
scenario and it is not relevant in routed scenarios.

>>
>>
>> Issue :
>> -----------
>>
>> 1.    The implementation of "Early TCP socket demux" doesn't address
>> the routing scenario (LAN <---> WAN) . This means TCP and UDP routin=
g
>> performance will be less in 3.10 kernel and also in 3.14 kernel as
>> every packet has to go through route lookup.
>>
>>
>> Is there an alternative to get back the Linux stack performance of 2=
=2E6
>> or 3.4 kernel where we have the route cache ?
>>
>> I guess plain routing scenario was NOT thought through while removin=
g
>> the routing cache code.
>
> This is the opposite. Route cache was easily targeted by DDOS attacks=
=2E
>
> This was a nightmare.
>
>
>
I understood from you that the old route cache mechanism had DoS
vulnerabilities, so the new mechanism is implemented. What I am trying
to figure out is whether that will cause the kind of throughput drop
that I am seeing ?

TCP performance
            - Upstream : 140 Mbps(Linux 2.6.32) --> 101Mbps (Linux 3.10=
=2E12)
            - Downstream : 148 Mbps(Linux 2.6.32) --> 106Mbps (Linux 3.=
10.12)

Thanks and Regards,
Suprasad.
