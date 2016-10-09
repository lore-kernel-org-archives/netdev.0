From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Accelerated receive flow steering (aRFS) for UDP
Date: Sun, 09 Oct 2016 15:33:22 -0700
Message-ID: <1476052402.28155.277.camel@edumazet-glaptop3.roam.corp.google.com>
References: <SN1PR07MB244706470867A923CF0FAF6589C60@SN1PR07MB2447.namprd07.prod.outlook.com>
         <1475883496.28155.270.camel@edumazet-glaptop3.roam.corp.google.com>
         <SN1PR07MB2447ED02140770F0B46967D589D90@SN1PR07MB2447.namprd07.prod.outlook.com>
         <1476033293.28155.273.camel@edumazet-glaptop3.roam.corp.google.com>
         <SN1PR07MB2447D70FD02730AFCEA410A089D80@SN1PR07MB2447.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "maorg@mellanox.com" <maorg@mellanox.com>,
        "tom@herbertland.com" <tom@herbertland.com>
To: "Chopra, Manish" <Manish.Chopra@cavium.com>,
        Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34267 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751437AbcJIWdd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 18:33:33 -0400
Received: by mail-pa0-f54.google.com with SMTP id rz1so43405572pab.1
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 15:33:24 -0700 (PDT)
In-Reply-To: <SN1PR07MB2447D70FD02730AFCEA410A089D80@SN1PR07MB2447.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-10-09 at 19:48 +0000, Chopra, Manish wrote:

> Hi Eric, I used "-n" as well with "-N" but still the problem doesn't
> go away.
> 
> This is what I have done -
> 
> Started "netserver" on local/test setup
> 
> #netserver
> Starting netserver with host 'IN(6)ADDR_ANY' port '12865' and family
> AF_UNSPEC
> 
> It starts listening on port "12865"
> 
> From remote setup, started multiple netperf using different ports for
> data sockets specified using "-P" with "-N" and "-n" options specified
> as well.
> netperf -H 192.168.200.40 -l 150 -t UDP_STREAM -T 8,8 -- -N -n -m 1400
> -P 6660,5550 &
> netperf -H 192.168.200.40 -l 150 -t UDP_STREAM -T 9,9 -- -N -n -m 1400
> -P 9990,9880 &
> netperf -H 192.168.200.40 -l 150 -t UDP_STREAM -T 10,10 -- -N -n -m
> 1400 -P 4455,4400 &
> netperf -H 192.168.200.40 -l 150 -t UDP_STREAM -T 11,11 -- -N -n -m
> 1400 -P 3300,7800 &
> netperf -H 192.168.200.40 -l 150 -t UDP_STREAM -T 12,12 -- -N -n -m
> 1400 -P 50512,44444 &
> netperf -H 192.168.200.40 -l 150 -t UDP_STREAM -T 13,13 -- -N -n -m
> 1400 -P 10512,45672 &
> netperf -H 192.168.200.40 -l 150 -t UDP_STREAM -T 14,14 -- -N -n -m
> 1400 -P 8888,56721 &
> netperf -H 192.168.200.40 -l 150 -t UDP_STREAM -T 15,15 -- -N -n -m
> 1400 -P 9300,8899 &
> 
> When on local/test receiving setup, I dump skb's IP header protocol
> field in .ndo_rx_flow_steer() handler - it is still always
> IPPROTO_TCP.
> Which has destined port 12865. But that handler never receives a SKB
> whose IP header protocol field is set to IPPROTO_UDP.
> 
> As suspected, I believe in receive flow, packets always go in the path
> where it never match any entry in global flow table in get_rps_cpu()
> function
> ,possibly due to packets don't get received from the flow of
> inet_recvmsg() which updates the global flow table ?
> 
> 3571                 /* First check into global flow table if there is
> a match */
> 3572                 ident = sock_flow_table->ents[hash &
> sock_flow_table->mask];
> 3573                 if ((ident ^ hash) & ~rps_cpu_mask)
> 3574                         goto try_rps;
> 
> Hence, it never call set_rps_cpu() which internally is supposed to
> call .ndo_rx_flow_steer() for the SKB's whose flows to be steered.
> 
> On another side, when I use "Iperf" for sending UDP stream, which I
> believe receives the packets from the intet_recvmsg() flow
> and I do see flows getting steered for UDP packets. [Actually seeing
> SKB's whose IP header protocol set to IPPROTO_UDP arriving
> in .ndo-rx_flow_steer()].
> 
> iperf -s -u
> iperf -u -c 192.168.200.40 -t 3000 -i 10 -P 8


OK, I am adding/CC Rick Jones, netperf author, since it seems a netperf
bug, not a kernel one.

I believe I already mentioned fact that "UDP_STREAM -- -N" was not doing
a connect() on the receiver side.


> 
> 
> 
