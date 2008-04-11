From: Glen Gray <glen.gray@lincor.com>
Subject: Re: r8169 driver fails to see IGMPv2 SAP announcements
Date: Fri, 11 Apr 2008 08:43:55 +0100
Message-ID: <857EF17F-C708-4656-A7AF-D64A63223854@lincor.com>
References: <OF47F0798E.811EA708-ON88257412.0070C381-88257412.00724DBB@us.ibm.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.station1.mxsweep.com ([212.147.136.149]:2708 "EHLO
	mail2.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758977AbYDKHoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 03:44:03 -0400
In-Reply-To: <OF47F0798E.811EA708-ON88257412.0070C381-88257412.00724DBB@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, further to this, I've managed to do some testing at last but I'm  
looking for further advice on how to debug this further.

I'm still sure this is tied to the igmp version as that's all that's  
different from what I can see. So if I know why the net device is  
getting setup as igmp v3 and not v2 then I might be closer to solving  
this. From looking at the code, it seems the igmp version is decided  
upon by looking for igmp packets. If version 1 or version 2 are seen  
in a particular time frame, then the version is set to v1 or v2  
depending on what was seen otherwise it's set to v3 by default. Is  
this correct ?

I've built the latest r8169 driver from Realtek on my current kernel  
and the latest Fedora 8 2.6.24.4 kernel rpm with some debugs in the  
rtl_set_rx_mode function. I can see that under both kernels, the  
mc_filter[0/1] elements are getting set to the same values, as is the  
rx_mode

I performed a somewhat crude test by doing the following

ethtool -S eth0; noting the multicast and broadcast counts
tcpdump -i eth0 ether multicast; dumping to a file for a period of time
ethtool -S eth0; got the new counts and worked out the differences and  
compared that to a wc -l of the tcpdump.

I ran that test a couple of times and in all cases there's a large  
difference between what tcpdump reports (in promiscuous mode) and what  
the net device stats are showing, namely that there's more packets  
reported by ethtool -S eth0 than I can see with tcpdump

Unfortunately, I can't do a similar test against the working Realtek  
driver on the older kernel as it doesn't support the ethtool -S  
command. And I can't compile the Realtek driver against the current  
2.6.24 kernel due to API changes.

A tcpdump on a working Realtek driver/older kernel shows the following  
packets (same device, same net/switch)
16:05:54.147532 IP exterity1.labs.lincor.com.sapv1 >  
239.255.255.255.sapv1: UDP, length 296
16:05:54.148298 IP exterity1.labs.lincor.com.sapv1 >  
239.255.255.255.sapv1: UDP, length 287
16:05:54.149046 IP exterity1.labs.lincor.com.sapv1 >  
239.255.255.255.sapv1: UDP, length 292
16:05:54.149776 IP exterity1.labs.lincor.com.sapv1 >  
239.255.255.255.sapv1: UDP, length 291
16:05:54.150490 IP exterity1.labs.lincor.com.sapv1 >  
239.255.255.255.sapv1: UDP, length 279

A working /proc/net/igmp
Idx	Device    : Count Querier	Group    Users Timer	Reporter
1	lo        :     0      V3
				010000E0     1 0:00000000		0
2	eth0      :     8      V2
				FF0000E0     1 0:00000000		1
				FFFFFFEF     2 0:00000000		1
				FFFFC3EF     1 0:00000000		1
				FE7F02E0     1 0:00000000		1
				010000E0     1 0:00000000		0

A working /proc/net/dev_mcast
2    eth0            12    0     333300027ffe
2    eth0            1     0     01005e0000ff
2    eth0            1     0     01005e7fffff
2    eth0            1     0     01005e43ffff
2    eth0            1     0     01005e027ffe
2    eth0            1     0     3333ff402cbe
2    eth0            1     0     333300000001
2    eth0            1     0     01005e000001


For a 2.6.24 kernel, tcpdump just doesn't have the SAP packets

Not working /proc/net/igmp
Idx	Device    : Count Querier	Group    Users Timer	Reporter
1	lo        :     0      V3
				010000E0     1 0:00000000		0
2	eth0      :     8      V3
				FF0000E0     1 0:00000000		0
				FFFFFFEF     2 0:00000000		0
				FFFFC3EF     1 0:00000000		0
				FE7F02E0     1 0:00000000		0
				010000E0     1 0:00000000		0

[root@webnote root]# cat /proc/net/dev_mcast
2    eth0            12    0     333300027ffe
2    eth0            1     0     01005e0000ff
2    eth0            1     0     01005e7fffff
2    eth0            1     0     01005e43ffff
2    eth0            1     0     01005e027ffe
2    eth0            1     0     3333ff402cbe
2    eth0            1     0     333300000001
2    eth0            1     0     01005e000001

Pointers on where to look next are most welcome.

Kind Regards,
--
Glen Gray <glen.gray@lincor.com>         Digital Depot, Thomas Street
Senior Software Engineer                            Dublin 8, Ireland
Lincor Solutions Ltd.                          Ph: +353 (0) 1 4893682

On 20 Mar 2008, at 20:48, David Stevens wrote:
> Hi, Glen,
>        From your detailed description, and particularly the fact
> that the problem seems to be tied to the driver & device, I think
> I'd recommend looking at the multicast address filter code in the
> driver. IGMP is not device dependent, so I doubt that is the
> source of the problem.
>        If you can reproduce the problem, then while it's
> happening:
>
> 1) catch the group memberships by saving /proc/net/igmp
> 2) catch the hardware group memberships by saving
>        /proc/net/dev_mcast
> [I expect from the symptoms that 1) is ok, 2) may or may not be...]
> and...
> 3) run tcpdump or wireshark in promiscuous mode
>        - if the device address filter is the problem, when you
>        put the device in promiscuous mode, everything will
>        start working again, until you exit tcpdump. You will
>        also see the packets you aren't receiving are being
>        sent, if that's the problem.
>
> I understand you probably can't directly reproduce it, and
> the visual artifacts you mentioned in that one test may or
> may not be the same issue as the other one.
>
> Another possibility that comes to mind is a memory leak,
> if the response problems are related to a low memory
> condition. So, that might be something else to look for.
> Compare memory usage with ordinary usage, check
> for log messages of allocation failures and check "netstat -s"
> output for any indication of drops.
>
> If you can set a program or script to monitor the system
> and detect when you hit the problem, then you could use
> that to trigger running a script that captures the data you
> need when it happens.
>
>                                        +-DLS
>

