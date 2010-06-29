From: Alexander Clouter <alex@digriz.org.uk>
Subject: Re: [iproute2] iproute2:  Allow 'ip addr flush' to loop more than 10 times.
Date: Tue, 29 Jun 2010 16:48:51 +0100
Message-ID: <38hpf7-map.ln1@chipmunk.wormnet.eu>
References: <1277790959-28075-1-git-send-email-greearb@candelatech.com> <50mof7-b9p.ln1@chipmunk.wormnet.eu> <4C2A0B82.7020701@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:60107 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756458Ab0F2Pti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 11:49:38 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OTd43-0001qQ-Au
	for netdev@vger.kernel.org; Tue, 29 Jun 2010 17:49:35 +0200
Received: from chipmunk.wormnet.eu ([195.195.131.226])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 17:49:35 +0200
Received: from alex by chipmunk.wormnet.eu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 17:49:35 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> wrote:
>
>>> This is useful for getting rid of large numbers of IP
>>> addresses in scripts.
>>>
>> Maybe I am missing a trick, but what is wrong with putting this triv=
ial
>> logic into the script:
>>
>> ip addr show ${DEV} | awk '/inet6? / { print $2 }' | xargs -I{} ip a=
ddr del '{}' dev ${DEV}
>=20
> This isn't going to be fast if you have thousands of addresses.
>
Obviously not like-for-like but:
----
maru:/home/alex# cat /proc/cpuinfo
Processor       : Feroceon 88FR131 rev 1 (v5l)
BogoMIPS        : 1192.75
=46eatures        : swp half thumb fastmult edsp
CPU implementer : 0x56
CPU architecture: 5TE
CPU variant     : 0x2
CPU part        : 0x131
CPU revision    : 1

Hardware        : Marvell SheevaPlug Reference Board
Revision        : 0000
Serial          : 0000000000000000

maru:/home/alex# ip route show realm filthpit | wc
   8464   76176  533812

maru:/home/alex# time ip route list realm filthpit | xargs -I{} sh -c '=
ip route del {}'

real    1m7.590s
user    0m0.650s
sys     0m3.010s
----

>> You can probably speed things up with '-P' too, '-P 2' gives me a hu=
ge
>> huge speed up for the work I do with 'ip route'.
>=20
> Where are you using the -P at?  It's not a supported option of 'ip'
> as far as I can tell.
>
xargs, it works well on SMP systems, on my SheevaPlug you do not get=20
much gain.
=20
>> Why the need to cram more functionality and options into iproute whe=
n
>> it is something that can be pushed into the wrapper script?
>=20
> Speed and ease of use.
>=20
Annoying 'ip addr show dev dummy0' craps out after 54 assignments in=20
it's output (bug?), however ifconfig works so:
----
truffle:/home/ac56# cat /proc/cpuinfo=20
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 15
model           : 4
model name      : Intel(R) Xeon(TM) CPU 2.80GHz
stepping        : 3
cpu MHz         : 2793.177
cache size      : 2048 KB
physical id     : 0
siblings        : 2
core id         : 0
cpu cores       : 1
apicid          : 0
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 5
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge =
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe sysc=
all nx lm constant_tsc pebs bts pni monitor ds_cpl cid cx16 xtpr
bogomips        : 5591.21
clflush size    : 64
cache_alignment : 128
address sizes   : 36 bits physical, 48 bits virtual
power management:

[snipped other real and two ht cpus]

truffle:/home/ac56# time for I in $(seq 1 4085); do ip -6 addr add fe80=
::$(printf "%x" ${I})/64 dev dummy0; done

real    0m17.013s
user    0m4.004s
sys     0m11.417s
truffle:/home/ac56# ifconfig dummy0 | awk '/inet6? / { print $3 }' | wc
   4085    4085   52835
truffle:/home/ac56# time ifconfig dummy0 | awk '/inet6? / { print $3 }'=
 | xargs -I{} ip addr del {} dev dummy0

real    0m5.897s
user    0m1.272s
sys     0m4.456s

# no idea why but, only 24 entries, re-running the above cleans up=20
# properly in 4ms
truffle:/home/ac56# ifconfig dummy0 | awk '/inet6? / { print $3 }' | wc=
=20
     24      24     310

# from the top again (but for '-P2' action):
truffle:/home/ac56# time ifconfig dummy0 | awk '/inet6? / { print $3 }'=
 | xargs -I{} -P2 ip addr del {} dev dummy0

real    0m4.013s
user    0m1.268s
sys     0m5.072s

truffle:/home/ac56# ifconfig dummy0 | awk '/inet6? / { print $3 }' | wc
     40      40     516
----

Apart from the cleanup glitches in both cases, things are rather fast=20
already?  Probably worth focusing at the 'ip (route|addr) add' slowness=
?

Bah, just my =A30.02.

Cheers

[1] and anything more than 4085 for the sequence gives 'RTNETLINK=20
	answers: Cannot allocate memory'

--=20
Alexander Clouter
=2Esigmonster says: Someone is speaking well of you.

