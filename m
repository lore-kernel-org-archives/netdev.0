From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen
Date: Tue, 7 Apr 2015 19:25:48 +0100
Message-ID: <21796.8492.157477.661131@mariner.uk.xensource.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	<20150407153707.GA28129@l.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Xen maintainers:
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>, ; Recently touched tg3:
	Prashant Sreedharan <prashant@broadcom.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>, ;
	"Linux tg3 maintainers": Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, ;
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:10892 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000AbbDGTP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 15:15:26 -0400
In-Reply-To: <20150407153707.GA28129@l.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Konrad Rzeszutek Wilk writes ("Re: tg3 NIC driver bug in 3.14.x under Xen"):
> On Tue, Apr 07, 2015 at 04:12:14PM +0100, Ian Jackson wrote:
> > The symptom is a very high level of packet loss: around 25-30% (as
> > seen in `ping').  There don't seem to be any untoward-looking kernel
> > messages.  The lost packets get added to the `errors' counter shown in
> > ifconfig.  I don't know whether the problem is with the transmit path,
> > or receive path, or both.
...
> Do you see this if you run on baremetal with 'iommu=soft swiotlb=force'?
> (same kernel). 

When I tried this the network became entirely nonfunctional, as far as
ping (or anything else) was concerned.  (The host has a statically
configured IPv4 address, so DHCP is not at issue.)

On the serial console I collected this information:

root@bedbug:~# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:13:72:14:c0:51  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:29142 errors:0 dropped:0 overruns:0 frame:0
          TX packets:247 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1983230 (1.8 MiB)  TX bytes:15976 (15.6 KiB)
          Interrupt:17 

root@bedbug:~# ifconfig xenbr0
xenbr0    Link encap:Ethernet  HWaddr 00:13:72:14:c0:51  
          inet addr:10.80.249.102  Bcast:10.80.251.255
          Mask:255.255.252.0
          inet6 addr: fe80::213:72ff:fe14:c051/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:248 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:10728 (10.4 KiB)

root@bedbug:~# ethtool -S eth0 | grep -v ': 0$'
NIC statistics:
     rx_octets: 2040884
     rx_ucast_packets: 470
     rx_mcast_packets: 611
     rx_bcast_packets: 28874
     tx_octets: 16232
     tx_mcast_packets: 8
     tx_bcast_packets: 243
root@bedbug:~#

I did
  tcpdump -vvs500 -lnieth0
and got output looking like this:

19:20:51.344115 cc:cc:cc:cc:cc:cc > cc:cc:cc:cc:cc:cc, ethertype
Unknown (0xcccc), length 60: 
        0x0000:  cccc cccc cccc cccc cccc cccc cccc cccc
        ................
        0x0010:  cccc cccc cccc cccc cccc cccc cccc cccc
        ................
        0x0020:  cccc cccc cccc cccc cccc cccc cccc
        ..............
19:20:51.354142 cc:cc:cc:cc:cc:cc > cc:cc:cc:cc:cc:cc, ethertype
Unknown (0xcccc), length 60: 
        0x0000:  cccc cccc cccc cccc cccc cccc cccc cccc
        ................
        0x0010:  cccc cccc cccc cccc cccc cccc cccc cccc
        ................
        0x0020:  cccc cccc cccc cccc cccc cccc cccc
        ..............
19:20:51.364199 00:00:00:00:00:00 > 00:00:00:00:00:00 Null
Information, send seq 0, rcv seq 0, Flags [Command], length 46


Thanks,
Ian.
