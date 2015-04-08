From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Wed, 8 Apr 2015 14:59:00 +0100
Message-ID: <21797.13348.524963.29127@mariner.uk.xensource.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	<1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<21796.6843.983774.271495@mariner.uk.xensource.com>
	<21796.7755.270785.292996@mariner.uk.xensource.com>
	<1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<1428448976.4720.15.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"Thadeu Lima de Souza Cascardo" <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:13305 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824AbbDHN7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 09:59:05 -0400
In-Reply-To: <21796.6843.983774.271495@mariner.uk.xensource.com>,
	<21796.7755.270785.292996@mariner.uk.xensource.com>,
	<1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>,
	<1428448976.4720.15.camel@prashant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks to Konrad, Michael and Prashant for your attention.


Prashant Sreedharan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen"):
> Ian, in your previous mail you indicated there are no drops or errors
> reported on eth0 (assuming this is the tg3 port), which is added to the
> bridge xenbr0 is this correct ?

Yes, that is correct.

> If so the rx drops on xenbr0 does not match with eth0.  please also
> provide "brctl show", "ethtool -i eth0"

root@bedbug:~# brctl show
bridge name     bridge id               STP enabled     interfaces
xenbr0          8000.00137214c051       no              eth0
root@bedbug:~# ethtool -i eth0
driver: tg3
version: 3.136
firmware-version: 5751-v3.44a
bus-info: 0000:03:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
root@bedbug:~#


Michael Chan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen"):
> On Tue, 2015-04-07 at 19:13 +0100, Ian Jackson wrote:
> > root@bedbug:~# ethtool -S xenbr0 | grep -v ': 0$'
> > no stats available
> > root@bedbug:~# 
> 
> Please provide ethtool -S on the tg3 device.

I did that in my previous email.  Let me recap:

Ian Jackson writes ("Re: tg3 NIC driver bug in 3.14.x under Xen"):
> Michael Chan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen"):
> > Please provide the output of "ethtool -S" which has a better breakdown
> > of the error counters.  Thanks.
> 
> root@bedbug:~# ethtool -S eth0 | grep -v ': 0$'
> NIC statistics:
>      rx_octets: 793954
>      rx_ucast_packets: 342
>      rx_mcast_packets: 197
>      rx_bcast_packets: 11049
>      tx_octets: 59093
>      tx_ucast_packets: 396
>      tx_mcast_packets: 8
>      tx_bcast_packets: 4
> root@bedbug:~# ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:13:72:14:c0:51  
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:16012 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:459 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:1090543 (1.0 MiB)  TX bytes:64575 (63.0 KiB)
>           Interrupt:17 
> 
> root@bedbug:~# 
> 
> And:
> 
> --- bedbug.cam.xci-test.com ping statistics ---
> 120 packets transmitted, 90 received, 25% packet loss, time 119354ms
> rtt min/avg/max/mdev = 0.294/0.459/0.844/0.073 ms
> 
> 
> Evidently on this particular kernel, the error counters are _not_
> increasing, contrary to what I said before.  I confess that I didn't
> keep a record of on which particular machine and kernel I observed the
> error count increasing.
> 
> If it would help I could try to check various other machines and/or
> other kernels to see if I can get one of them to display the error
> counter behaviour.


Ian Jackson writes ("Re: tg3 NIC driver bug in 3.14.x under Xen"):
> I just realised that I didn't check xenbr0 as well as eth0:
> 
> root@bedbug:~# ifconfig xenbr0
> xenbr0    Link encap:Ethernet  HWaddr 00:13:72:14:c0:51  
>           inet addr:10.80.249.102  Bcast:10.80.251.255
>           Mask:255.255.252.0
>           inet6 addr: fe80::213:72ff:fe14:c051/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:12296 errors:0 dropped:793 overruns:0 frame:0
>           TX packets:437 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0 
>           RX bytes:618757 (604.2 KiB)  TX bytes:49084 (47.9 KiB)
> 
> root@bedbug:~# ethtool -S xenbr0 | grep -v ': 0$'
> no stats available
> root@bedbug:~#
> 
> The value for "dropped" increases steadily.  This particular box is on
> a network with a lot of other stuff, so it will be constantly
> receiving broadcasts of various kinds even when I am not trying to
> address it directly.


Ian.
