From: Manuel Perez Ayala <mperaya@alcazaba.unex.es>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Thu, 12 May 2005 11:28:27 +0200
Message-ID: <20050512112827.7danjtr4kckg8swc@158.49.151.11>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
	<1115743966.8570.26.camel@rh4>
	<20050511080446.fnstrvtzq8gk8884@158.49.151.11>
	<1115825081.8570.93.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1115825081.8570.93.camel@rh4>
Content-Disposition: inline
Resent-Message-ID: <20050512113022.d1ujmnq88wccsk4s@158.49.151.11>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan <mchan@broadcom.com> wrote:

>
> This tells me that your cache line size is 32 bytes.
>
> Let's try some experiments and see what works and what doesn't. Please
> hardcode the following values in tp->dma_rwctrl before it is written to
> the register:
>

Net performance of the working driver:

Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

87380  16384  16384    10.00     415.08


Tryouts:

> 1. DMA read/write boundaries set to 256:
>
> tp->dma_rwctrl =3D 0x76ff2d0f;
>

tg3.c:v3.10 (September 14, 2004)
PCI: Enabling device 0001:10:13.0 (0014 -> 0016)
tg3: tg3_test_dma DMA read/write boundaries set to 256: 76FF2D0F
eth1: Tigon3 [partno(BCM95700A6) rev 7102 PHY(5401)] (PCI:33MHz:64-bit)
10/100/1000BaseT Ethernet 00:04:76:3b:51:ae
eth1: RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] Split[0] WireSpeed[0] TSOc=
ap[0]

--> DATA CORRUPTION

> 2. DMA read boundary 256, write boundary 32:
>
> tp->dma_rwctrl =3D 0x76ff150f;
>

tg3.c:v3.10 (September 14, 2004)
PCI: Enabling device 0001:10:13.0 (0014 -> 0016)
tg3: tg3_test_dma DMA read boundary 256, write boundary 32: 76FF150F
eth1: Tigon3 [partno(BCM95700A6) rev 7102 PHY(5401)] (PCI:33MHz:64-bit)
10/100/1000BaseT Ethernet 00:04:76:3b:51:ae
eth1: RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] Split[0] WireSpeed[0] TSOc=
ap[0]

--> DATA OK

Net Performance:

Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

87380  16384  16384    10.00     647.19

The net performance is grown over a 50% from the working driver default=20
setting.

> 3. DMA read boundary 32, write boundary 256
>
> tp->dma_rwctrl =3D 0x76ff2a0f;
>

tg3.c:v3.10 (September 14, 2004)
PCI: Enabling device 0001:10:13.0 (0014 -> 0016)
tg3: tg3_test_dma DMA read boundary 32, write boundary 256: 76FF2A0F
eth1: Tigon3 [partno(BCM95700A6) rev 7102 PHY(5401)] (PCI:33MHz:64-bit)
10/100/1000BaseT Ethernet 00:04:76:3b:51:ae
eth1: RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] Split[0] WireSpeed[0] TSOc=
ap[0]

--> DATA CORRUPTION

No net performance impact.

> 4. Let's also try without asserting all byte enables:
>
> tp->dma_rwctrl =3D 0x763f2d0f;
>

tg3.c:v3.10 (September 14, 2004)
PCI: Enabling device 0001:10:13.0 (0014 -> 0016)
tg3: tg3_test_dma without asserting all byte enables: 763F2D0F
eth1: Tigon3 [partno(BCM95700A6) rev 7102 PHY(5401)] (PCI:33MHz:64-bit)
10/100/1000BaseT Ethernet 00:04:76:3b:51:ae
eth1: RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] Split[0] WireSpeed[0] TSOc=
ap[0]

--> DATA CORRUPTION

Net performance like DMA read boundary 256, write boundary 32:, over 50%,=
 but
with data corruption.



I've only tried whith the working driver (2.6.8 with dma code from 2.6.7)=
. Do
you need I also try the original 2.6.8?

Before my initial report, I've tried the broadcom driver 8.1.55 with no=20
success
and the same kind of data corruption. Then I focused on the tg3 driver.

----------
Manuel Perez Ayala
mperaya@alcazaba.unex.es
Facultad de Biblioteconom=EDa y Documentaci=F3n
Universidad de Extremadura
