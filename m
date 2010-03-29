From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network performance - iperf
Date: Mon, 29 Mar 2010 22:07:38 +0200
Message-ID: <1269893258.1958.61.camel@edumazet-laptop>
References: <4BB09021.6020202@petalogix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	John Linn <John.Linn@xilinx.com>,
	"Steven J. Magnani" <steve@digidescorp.com>,
	Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org
To: michal.simek@petalogix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BB09021.6020202@petalogix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 29 mars 2010 =C3=A0 13:33 +0200, Michal Simek a =C3=A9crit :
> Hi All,
>=20
> I am doing several network benchmarks on Microblaze cpu with MMU.
> I am seeing one issue which is weird and I would like know where the=20
> problem is.
> I am using the same hw design and the same Linux kernel. I have done=20
> only change in memory size (in DTS).
>=20
> 32MB: 18.3Mb/s
> 64MB: 15.2Mb/s
> 128MB: 10.6Mb/s
> 256MB: 3.8Mb/s
>=20
> There is huge difference between systems with 32MB and 256MB ram.
>=20
> I am running iperf TCP tests with these commands.
> On x86: iperf -c 192.168.0.105 -i 5 -t 50
> On microblaze: iperf -s
>=20
> I look at pte misses which are the same on all configurations which=20
> means that the number of do_page_fault exceptions is the same on all=20
> configurations.
> I added some hooks to low level kernel code to be able to see number =
of=20
> tlb misses. There is big differences between number of misses on syst=
em=20
> with 256MB and 32MB. I measured two kernel settings. First column is=20
> kernel with asm optimized memcpy/memmove function and the second is=20
> without optimization. (Kernel with asm optimized lib functions is 30%=
=20
> faster than system without optimization)
>=20
> 32MB: 12703	13641
> 64MB: 1021750	655644
> 128MB: 1031644	531879
> 256MB: 1011322	430027
>=20
> Most of them are data tlb misses. Microblaze MMU doesn't use any LRU=20
> mechanism to find TLB victim that's why we there is naive TLB=20
> replacement strategy based on incrementing counter. We using 2 tlbs f=
or=20
> kernel itself which are not updated that's why we can use "only" 62 T=
LBs=20
> from 64.
>=20

This probably has nothing to do with tcp stack, but trashing tlb on som=
e
pathological cases (you have 62 entries, thats good for working size up
to 248 Kbytes, all included (program stack, program static & dynamic
data), given microblaze 4Kbytes page size.

You could try :

echo "4096 8192 32768" >/proc/sys/net/ipv4/tcp_rmem

to reduce memory footprint of iperf (or use iperf parameters)

Of course, I suppose kernel memory is 32 MB max, if you use only two
tlbs (16 Mbytes each) for kernel...
