From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: OFT - reserving CPU's for networking
Date: Fri, 30 Apr 2010 14:15:34 -0400
Message-ID: <4BDB1E46.6050106@athenacr.com>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>	 <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi>	 <1272118252.8918.13.camel@bigi> <1272290584.19143.43.camel@edumazet-laptop>	 <1272293707.19143.51.camel@edumazet-laptop>	 <20100429174056.GA8044@gargoyle.fritz.box>	 <1272563772.2222.301.camel@edumazet-laptop>	 <20100429111047.031eeff9@nehalam>	 <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain> <1272571339.2209.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Peter Zijlstra <peterz@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:10178 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759179Ab0D3SPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:15:45 -0400
In-Reply-To: <1272571339.2209.76.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le jeudi 29 avril 2010 =C3=A0 21:19 +0200, Thomas Gleixner a =C3=A9cr=
it :
>=20
>> Say thanks to Intel/AMD for providing us timers which stop in lower
>> c-states.
>>
>> Not much we can do about the broadcast lock when several cores are
>> going idle and we need to setup a global timer to work around the
>> lapic timer stops in C2/C3 issue.
>>
>> Simply the C-state timer broadcasting does not scale. And it was nev=
er
>> meant to scale. It's a workaround for laptops to have functional NOH=
Z.
>>
>> There are several ways to work around that on larger machines:
>>
>>  - Restrict c-states
>>  - Disable NOHZ and highres timers
>>  - idle=3Dpoll is definitely the worst of all possible solutions
>>
>>> I keep getting asked about taking some core's away from clock and s=
cheduler
>>> to be reserved just for network processing. Seeing this kind of stu=
ff
>>> makes me wonder if maybe that isn't a half bad idea.
>> This comes up every few month and we pointed out several times what
>> needs to be done to make this work w/o these weird hacks which put a
>> core offline and then start some magic undebugable binary blob on it=
=2E
>> We have not seen anyone working on this, but the "set cores aside an=
d
>> let them do X" idea seems to stick in peoples heads.
>>
>> Seriously, that's not a solution. It's going to be some hacked up
>> nightmare which is completely unmaintainable.
>>
>> Aside of that I seriously doubt that you can do networking w/o time
>> and timers.
>>
>=20
> Thanks a lot !
>=20
> booting with processor.max_cstate=3D1 solves the problem
>=20
> (I already had a CONFIG_NO_HZ=3Dno conf, but highres timer enabled)
>=20
> Even with _carefuly_ chosen crazy configuration (receiving a packet o=
n a
> cpu, then transfert it to another cpu, with a full 16x16 matrix
> involved), generating 700.000 IPI per second on the machine seems fin=
e
> now.

=46YI you can also restrict c=3Dstates at runtime with PM QoS:
Documentation/power/pm_qos_interface.txt

On my machine, /sys/devices/system/cpu/cpu0/cpuidle/state2/latency
is 205usec, so configuring a PM QoS request for <=3D 205usec latency
should prevent it being entered:

#!/usr/bin/python
import os;
import struct;
import signal;

latency_rec_usec =3D 100
f =3D os.open("/dev/cpu_dma_latency", os.O_WRONLY);
os.write(f, struct.pack("=3Di", latency_rec_usec));
signal.pause();
