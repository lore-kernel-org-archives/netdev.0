From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Sun, 29 Nov 2015 14:21:35 +0100
Message-ID: <CAPv3WKc4zSmjtw_FeePCVCaq_aUubbCw_ggtxgxs0-7LwL7fHQ@mail.gmail.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<5655FF36.20202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Yair Mahalalel <myair@marvell.com>,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Evan Wang <xswang@marvell.com>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Tomasz Nowicki <tn@semihalf.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>, nitroshift@yahoo.com,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5655FF36.20202@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

>
> Looking at your patches, it was not entirely clear to me how the buffer
> manager on these Marvell SoCs work, but other networking products have
> something similar, like Broadcom's Cable Modem SoCs (BCM33xx) FPM, and
> maybe Freescale's FMAN/DPAA seems to do something similar.
>
> Does the buffer manager allocation work by giving you a reference/token
> to a buffer as opposed to its address? If that is the case, it would be
> good to design support for such hardware in a way that it can be used by
> more drivers.

It does not operate on a reference/token but buffer pointers (physical
adresses). It's a ring and you cannot control which buffer will be
taken at given moment.

>
> Eric Dumazet suggested a while ago to me that you could get abstract
> such allocation using hardware-assisted buffer allocation by either
> introducing a new mm zone (instead of ZONE_NORMAL/DMA/HIGHMEM etc.), or
> using a different NUMA node id, such that SKB allocation and freeing
> helpers could deal with the specifics, and your networking stack and
> driver would be mostly unaware of the buffer manager underlying
> implementation. The purpose would be to get a 'struct page' reference to
> your buffer pool allocation object, so it becomes mostly transparent to
> other areas of the kernel, and you could further specialize everything
> that needs to be based on this node id or zone.

As this buffer manager is pretty tightly coupled with NIC (please see
below) and the solution is very platform specific, I'm not sure if it
wouldn't be an overdesign, to provide such generic, paralel to DMA
mechanism.

>
> Finally, these hardware-assisted allocation schemes typically work very
> well when there is a forwarding/routing workload involved, because you
> can easily steal packets and SKBs from the network stack, but that does
> not necessarily play nicely with host-terminated/initiated traffic which
> wants to have good feedback on what's happening at the NIC level
> (queueing, buffering, etc.).

Sure, I can imagine developing some applications that are developed on
top of the proposed patches, but I'm not sure if such things like
cutting network stack in half should be a part of original support.

>
>>
>> Known issues:
>> - problems with obtaining all mapped buffers from internal SRAM, when
>> destroying the buffer pointer pool
>> - problems with unmapping chunk of SRAM during driver removal
>> Above do not have an impact on the operation, as they are called during
>> driver removal or in error path.
>
> Humm, what is the reason for using the on-chip SRAM here, is it because
> that's the only storage location the Buffer Manager can allocate from,
> or is it because it is presumably faster or with constant access times
> than DRAM? Would be nice to explain a bit more in details how the buffer
> manager works and its interfacing with the network controllers.

Each pool of pointers is a ring maintained in DRAM (called buffer
pointers' pool external). SRAM (called buffer pointers' pool internal
memory, BPPI) ensures smaller latency, but is also the only way to
allocate/fetch buffer pointers from DRAM ring. Transfers between those
two memories are controlled by buffer manager itself.

In the beginning the external pool has to be filled with desired
amount of pointers. NIC (controlled by mvneta driver) has to be
informed, which pools it can use for longer and shorter packets, their
size and also SRAM physical address has to be written to one of NETA
registers. Moreover, in order to be able to provide direct access
between NETA and buffer manager SRAM, special, Marvell-specific
settings have to be configured (so called opening of MBUS window).

After enabling ingress, incoming packet is automatically placed in
next-to-be-used buffer from buffer manager resources and the
controller updates NIC's descriptor contents with pool's number and
buffer addresses. Once the packet is processed, a new buffer has to be
allocated and it's address written to SRAM - this way the pool of
pointers gets refilled.

>
> Can I use the buffer manager with other peripherals as well? Like if I
> wanted to do zero-copy or hardware-assisted memcpy DMA, would that be a
> suitable scheme?

Other peripherals cannot access SRAM directly - only DMA-based access
to DRAM. If one would like to access buffers using SRAM from other
drivers, it has to be done by read/write operations performed by CPU.
Moreover I see a limitation, which is a lack of control over the
current buffer index.

Best regards,
Marcin
