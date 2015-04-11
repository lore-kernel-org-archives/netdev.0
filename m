From: Prashant <prashant@broadcom.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Sat, 11 Apr 2015 01:01:52 -0700
Message-ID: <5528D4F0.6060203@broadcom.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>	<1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>	<21796.6843.983774.271495@mariner.uk.xensource.com>	<21796.7755.270785.292996@mariner.uk.xensource.com>	<1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>	<1428448976.4720.15.camel@prashant>	<21797.13348.524963.29127@mariner.uk.xensource.com>	<1428543798.4720.20.camel@prashant>	<21798.24161.922394.539733@mariner.uk.xensource.com>	<1428595851.4720.22.camel@prashant>	<21798.44949.156680.399387@mariner.uk.xensource.com>	<21798.46590.928152.666550@mariner.uk.xensource.com>	<1428602883.4720.31.camel@prashant> <21799.59138.666831.970946@mariner.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Ian Jackson <Ian.Jackson@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:24236 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbbDKIBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 04:01:54 -0400
In-Reply-To: <21799.59138.666831.970946@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/2015 8:06 AM, Ian Jackson wrote:
> (I switched to a different test box "elbling1" with the same symptoms:
> ~25% packet loss in ping under 64-bit Xen with 32-bit x86 Linux; 100%
> loss Linux x86 32-bit baremetal with `iommu=soft swiotlb=force'.  In
> each case I had disabled the bridge setup so was just using eth0.)
>
> Once again, tcpdumping eth0 with machine booted baremetal with the
> `iommu...' boot options shows corrupted packets on the receive path:
>
> Full transcript below.  The non-corrupted packets (ARP requests) in
> the tcpdump are outgoing: 172.16.144.31 is elbling1.
>
> I think the packets are being dropped by the non-tg3 part of the
> kernel due to their protocol field having been corrupted.

> Also:
>
> root@elbling1:~# ethtool -S eth0 | grep -v ': 0$'
> NIC statistics:
>       rx_octets: 352487
>       rx_ucast_packets: 250
>       rx_mcast_packets: 1165
>       rx_bcast_packets: 1806
>       tx_octets: 15848
>       tx_mcast_packets: 8
>       tx_bcast_packets: 237
> root@elbling1:~# ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr b0:83:fe:db:b6:69
>            inet addr:172.16.144.31  Bcast:172.16.147.255
>            Mask:255.255.252.0
>            inet6 addr: fe80::b283:feff:fedb:b669/64 Scope:Link
>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>            RX packets:3245 errors:0 dropped:223 overruns:0 frame:0
>            TX packets:245 errors:0 dropped:0 overruns:0 carrier:0
>            collisions:0 txqueuelen:1000
>            RX bytes:355364 (347.0 KiB)  TX bytes:15848 (15.4 KiB)
>            Interrupt:16
>
> root@elbling1:~#
>
Thanks for the detailed info, looking at the logs it appears sometimes 
the descriptor itself is corrupted(drop count going up due to error bits 
getting set in the descriptor) and some instances the RX data buffer is 
getting corrupted (as seen in the tcpdump).

I tried to reproduce the problem on 32 bit 3.14.34 stable kernel 
baremetal, with iommu=soft swiotlb=force but no luck, no drops or 
errors. I did not try with Xen 64 bit yet. Btw I need a pcie analyzer 
trace to confirm the problem. Is it feasible to capture at your end ?
