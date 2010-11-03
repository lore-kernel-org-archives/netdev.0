From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] drivers/net/tile/: on-chip network drivers for the
 tile architecture
Date: Wed, 03 Nov 2010 21:31:40 +0100
Message-ID: <1288816300.2718.5.camel@edumazet-laptop>
References: <201011012107.oA1L7TGd031588@farm-0027.internal.tilera.com>
	 <20101103125959.3231daa1@s6510>  <4CD19DCF.1040709@tilera.com>
	 <1288806622.2511.187.camel@edumazet-laptop>  <4CD1BA71.3000806@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CD1BA71.3000806@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 03 novembre 2010 =C3=A0 15:39 -0400, Chris Metcalf a =C3=A9=
crit :

> I read it and internalized it long ago, and re-read it when I got Ste=
phen's
> original email.  I should have said that explicitly instead of a comm=
ent
> with a smiley -- email is a tricky communication medium sometimes.
>=20
> Several uses of "*(volatile int *)ptr" in that file are intended as
> performance hints.  A more obvious way to state this, for our compile=
r, is
> to say "prefetch_L1(ptr)".  This generates essentially the same code,=
 but
> avoids the red flag for "volatile" and also reads more clearly, so it=
's a
> good change.
>=20
> The other use is part of a very precise dance that involves detailed
> knowledge of the Tile memory subsystem micro-architecture.  This does=
n't
> really belong in the network device driver code, so I've moved it to
> <asm/cacheflush.h>, and cleaned it up, with detailed comments.  The u=
se
> here is that our network hardware's DMA engine can be used in a mode =
where
> it reads directly from memory, in which case you must ensure that any
> cached values have been flushed.
>=20

This kind of things really must be discussed before using it in a
network driver.

Because, an skb can be built by one CPU, queued on a qdisc queue, with
no particular "cached values have been flushed" ...

It then can be dequeued by another CPU, and given to the device.
What happens then ?

> /*
>  * Flush & invalidate a VA range that is homed remotely on a single c=
ore,
>  * waiting until the memory controller holds the flushed values.
>  */
> static inline void finv_buffer_remote(void *buffer, size_t size)
> {
> 	char *p;
> 	int i;
>=20
> 	/*
> 	 * Flush and invalidate the buffer out of the local L1/L2
> 	 * and request the home cache to flush and invalidate as well.
> 	 */
> 	__finv_buffer(buffer, size);
>=20
> 	/*
> 	 * Wait for the home cache to acknowledge that it has processed
> 	 * all the flush-and-invalidate requests.  This does not mean
> 	 * that the flushed data has reached the memory controller yet,
> 	 * but it does mean the home cache is processing the flushes.
> 	 */
> 	__insn_mf();
>=20
> 	/*
> 	 * Issue a load to the last cache line, which can't complete
> 	 * until all the previously-issued flushes to the same memory
> 	 * controller have also completed.  If we weren't striping
> 	 * memory, that one load would be sufficient, but since we may
> 	 * be, we also need to back up to the last load issued to
> 	 * another memory controller, which would be the point where
> 	 * we crossed an 8KB boundary (the granularity of striping
> 	 * across memory controllers).  Keep backing up and doing this
> 	 * until we are before the beginning of the buffer, or have
> 	 * hit all the controllers.
> 	 */
> 	for (i =3D 0, p =3D (char *)buffer + size - 1;
> 	     i < (1 << CHIP_LOG_NUM_MSHIMS()) && p >=3D (char *)buffer;
> 	     ++i) {
> 		const unsigned long STRIPE_WIDTH =3D 8192;
>=20
> 		/* Force a load instruction to issue. */
> 		*(volatile char *)p;
>=20
> 		/* Jump to end of previous stripe. */
> 		p -=3D STRIPE_WIDTH;
> 		p =3D (char *)((unsigned long)p | (STRIPE_WIDTH - 1));
> 	}
>=20
> 	/* Wait for the loads (and thus flushes) to have completed. */
> 	__insn_mf();
> }
>=20
