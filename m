From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Thu, 9 Apr 2015 18:25:18 +0100
Message-ID: <21798.46590.928152.666550@mariner.uk.xensource.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	<1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<21796.6843.983774.271495@mariner.uk.xensource.com>
	<21796.7755.270785.292996@mariner.uk.xensource.com>
	<1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<1428448976.4720.15.camel@prashant>
	<21797.13348.524963.29127@mariner.uk.xensource.com>
	<1428543798.4720.20.camel@prashant>
	<21798.24161.922394.539733@mariner.uk.xensource.com>
	<1428595851.4720.22.camel@prashant>
	<21798.44949.156680.399387@mariner.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:2718 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799AbbDIRZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 13:25:24 -0400
In-Reply-To: <21798.44949.156680.399387@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian Jackson writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> Prashant Sreedharan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> > yes please do
> 
> I will do so.

I did this test:
 - Linux 3.14.21
 - baremetal
 - `iommu=soft swiotlb=force' as suggested by Konrad
 - no bridge
 - manually added arp entries on both ends
   between target box and a server on same network

The results are:

On the test box, `ping 10.80.248.135' and `ping -s 500 10.80.248.135'
generate apparently-good ICMP echo requests which the server replies
to, but they don't seem to be received.

I ran
  tcpdump -pvvs500 -lnieth0 \! ether dst cc:cc:cc:cc:cc:cc and \! \
  ether dst 00:00:00:00:00:00 and \! ether dst 00:00:cc:cc:cc:cc and \
  \! ether dst 00:00:00:00:cc:cc and \! ether dst cc:cc:00:00:00:00
on the test box while pinging it from the server (-s500 and the
default).  No relevant packets matched the tcpdump filter.

However, as time goes by more and more packets with apparently random
data in their address fields start turning up so I have to keep adding
more mac addresses to be filtered out.

root@bedbug:~# ethtool -S eth0 | grep -v ': 0$'
NIC statistics:
     rx_octets: 8196868
     rx_ucast_packets: 633
     rx_mcast_packets: 1
     rx_bcast_packets: 123789
     tx_octets: 42854
     tx_ucast_packets: 9
     tx_mcast_packets: 8
     tx_bcast_packets: 603
root@bedbug:~# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:13:72:14:c0:51  
          inet addr:10.80.249.102  Bcast:10.80.251.255
          Mask:255.255.252.0
          inet6 addr: fe80::213:72ff:fe14:c051/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:124774 errors:0 dropped:88921 overruns:0 frame:0
          TX packets:620 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:8222158 (7.8 MiB)  TX bytes:42854 (41.8 KiB)
          Interrupt:17 

root@bedbug:~#

It appears therefore that packets are being corrupted on the receive
path, and the kernel then drops them (as misaddressed).

I also tried under Xen (rather than with baremetal and Konrad's
iommu/swiotlb kernel options), but that seems to be a less effective
repro.  Under Xen, without the bridge, I got ~6-8% packet loss,
compared to ~25-30% with the bridge.  I didn't investigate that
configuration in detail.

Thanks,
Ian.
