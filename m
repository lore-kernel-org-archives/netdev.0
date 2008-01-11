From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Fri, 11 Jan 2008 10:48:07 -0800
Message-ID: <4787B9E7.6040001@hp.com>
References: <1199981839.8931.35.camel@cafe>	<36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com>	<1200068444.9349.20.camel@cafe>  <47879DE4.8080603@cosmosbay.com> <1200075581.9349.33.camel@cafe>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:30346 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbYAKSsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 13:48:10 -0500
In-Reply-To: <1200075581.9349.33.camel@cafe>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno Leitao wrote:
> On Fri, 2008-01-11 at 17:48 +0100, Eric Dumazet wrote:
>=20
>>Breno Leitao a =E9crit :
>>
>>>Take a look at the interrupt table this time:=20
>>>
>>>io-dolphins:~/leitao # cat /proc/interrupts  | grep eth[1]*[67]
>>>277:         15    1362450         13         14         13         =
14         15         18   XICS      Level     eth6
>>>278:         12         13    1348681         19         13         =
15         10         11   XICS      Level     eth7
>>>323:         11         18         17    1348426         18         =
11         11         13   XICS      Level     eth16
>>>324:         12         16         11         19    1402709         =
13         14         11   XICS      Level     eth17
>>>
>>>
>>> =20
>>
>>If your machine has 8 cpus, then your vmstat output shows a bottlenec=
k :)
>>
>>(100/8 =3D 12.5), so I guess one of your CPU is full
>=20
>=20
> Well, if I run top while running the test, I see this load distribute=
d
> among the CPUs, mainly those that had a NIC IRC bonded. Take a look:
>=20
> Tasks: 133 total,   2 running, 130 sleeping,   0 stopped,   1 zombie
> Cpu0  :  0.3%us, 19.5%sy,  0.0%ni, 73.5%id,  0.0%wa,  0.0%hi,  0.0%si=
,  6.6%st
> Cpu1  :  0.0%us,  0.0%sy,  0.0%ni, 75.1%id,  0.0%wa,  0.7%hi, 24.3%si=
,  0.0%st
> Cpu2  :  0.0%us,  0.0%sy,  0.0%ni, 73.1%id,  0.0%wa,  0.7%hi, 26.2%si=
,  0.0%st
> Cpu3  :  0.0%us,  0.0%sy,  0.0%ni, 76.1%id,  0.0%wa,  0.7%hi, 23.3%si=
,  0.0%st
> Cpu4  :  0.0%us,  0.3%sy,  0.0%ni, 70.4%id,  0.7%wa,  0.3%hi, 28.2%si=
,  0.0%st
> Cpu5  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu6  :  0.0%us,  0.0%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.3%si=
,  0.0%st
> Cpu7  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st

If you have IRQ's bound to CPUs 1-4, and have four netperfs running,=20
given that the stack ostensibly tries to have applications run on the=20
same CPUs, what is running on CPU0?

Is it related to:

>   The 2 interface test that I showed in my first email, was run in tw=
o
> different NIC. Also, I am running netperf with the following command
> "netperf -H <hostname> -T 0,8" while netserver is running without any
> argument at all. Also, running vmstat in parallel shows that there is=
 no
> bottleneck in the CPU. Take a look:=20

Unless you have a morbid curiousity :) there isn't much point in bindin=
g=20
all the netperf's to CPU 0 when the interrupts for the NICs servicing=20
their connections are on CPUs 1-4.  I also assume then that the=20
system(s) on which netserver is running have > 8 CPUs in them? (There=20
are multiple destination systems yes?)

Does anything change if you explicitly bind each netperf to the CPU on=20
which the interrups for its connection are processed?  Or for that=20
matter if you remove the -T command entirely

Does UDP_STREAM show different performance than TCP_STREAM (I'm=20
ass-u-me-ing based on the above we are looking at the netperf side of a=
=20
TCP_STREAM test above, please correct if otherwise).

Are the CPUs above single-core CPUs or multi-core CPUs, and if=20
multi-core are caches shared?  How are CPUs numbered if multi-core on=20
that system?  Is there any hardware threading involved?  I'm wondering=20
if there may be some wrinkles in the system that might lead to reported=
=20
CPU utilization being low even if a chip is otherwise saturated.  Might=
=20
need some HW counters to check that...

Can you describe the I/O subsystem more completely?  I understand that=20
you are using at most two ports of a pair of quad-port cards at any one=
=20
time, but am still curious to know if those two cards are on separate=20
busses, or if they share any bus/link on the way to memory.

rick jones
