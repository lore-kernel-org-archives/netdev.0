From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH] drivers/net/tile/: on-chip network drivers for the tile
 architecture
Date: Wed, 3 Nov 2010 15:39:29 -0400
Message-ID: <4CD1BA71.3000806@tilera.com>
References: <201011012107.oA1L7TGd031588@farm-0027.internal.tilera.com>	 <20101103125959.3231daa1@s6510>  <4CD19DCF.1040709@tilera.com> <1288806622.2511.187.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([72.1.168.231]:30950 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798Ab0KCTjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 15:39:33 -0400
In-Reply-To: <1288806622.2511.187.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/2010 1:50 PM, Eric Dumazet wrote:
> Le mercredi 03 novembre 2010 =C3=A0 13:37 -0400, Chris Metcalf a =C3=A9=
crit :
>> Stephen, thanks for your feedback!
>>
>> On 11/3/2010 12:59 PM, Stephen Hemminger wrote:
>>> 1. MUST not use volatile, see volatile-considered-harmful.txt
>> The "harmful" use of volatile is in trying to fake out SMP.  Believe=
 me,
>> with a 64-core architecture, we know our SMP guidelines. :-)  Our us=
e here
>> is simply to force the compiler to issue a load, for the side-effect=
 of
>> populating the TLB, for example.
>>
>> However, your response does suggest that simply the syntactic use of
>> "volatile" will cause a red flag for readers.  I'll move this to an =
inline
>> function in a header with a comment explaining what it's for, and us=
e the
>> function instead.
> Please read Documentation/volatile-considered-harmful.txt

I read it and internalized it long ago, and re-read it when I got Steph=
en's
original email.  I should have said that explicitly instead of a commen=
t
with a smiley -- email is a tricky communication medium sometimes.

Several uses of "*(volatile int *)ptr" in that file are intended as
performance hints.  A more obvious way to state this, for our compiler,=
 is
to say "prefetch_L1(ptr)".  This generates essentially the same code, b=
ut
avoids the red flag for "volatile" and also reads more clearly, so it's=
 a
good change.

The other use is part of a very precise dance that involves detailed
knowledge of the Tile memory subsystem micro-architecture.  This doesn'=
t
really belong in the network device driver code, so I've moved it to
<asm/cacheflush.h>, and cleaned it up, with detailed comments.  The use
here is that our network hardware's DMA engine can be used in a mode wh=
ere
it reads directly from memory, in which case you must ensure that any
cached values have been flushed.

/*
 * Flush & invalidate a VA range that is homed remotely on a single cor=
e,
 * waiting until the memory controller holds the flushed values.
 */
static inline void finv_buffer_remote(void *buffer, size_t size)
{
	char *p;
	int i;

	/*
	 * Flush and invalidate the buffer out of the local L1/L2
	 * and request the home cache to flush and invalidate as well.
	 */
	__finv_buffer(buffer, size);

	/*
	 * Wait for the home cache to acknowledge that it has processed
	 * all the flush-and-invalidate requests.  This does not mean
	 * that the flushed data has reached the memory controller yet,
	 * but it does mean the home cache is processing the flushes.
	 */
	__insn_mf();

	/*
	 * Issue a load to the last cache line, which can't complete
	 * until all the previously-issued flushes to the same memory
	 * controller have also completed.  If we weren't striping
	 * memory, that one load would be sufficient, but since we may
	 * be, we also need to back up to the last load issued to
	 * another memory controller, which would be the point where
	 * we crossed an 8KB boundary (the granularity of striping
	 * across memory controllers).  Keep backing up and doing this
	 * until we are before the beginning of the buffer, or have
	 * hit all the controllers.
	 */
	for (i =3D 0, p =3D (char *)buffer + size - 1;
	     i < (1 << CHIP_LOG_NUM_MSHIMS()) && p >=3D (char *)buffer;
	     ++i) {
		const unsigned long STRIPE_WIDTH =3D 8192;

		/* Force a load instruction to issue. */
		*(volatile char *)p;

		/* Jump to end of previous stripe. */
		p -=3D STRIPE_WIDTH;
		p =3D (char *)((unsigned long)p | (STRIPE_WIDTH - 1));
	}

	/* Wait for the loads (and thus flushes) to have completed. */
	__insn_mf();
}


> Then if there is a problem, we can make change to the documentation, =
but
> volatile use in new code is _strictly_ forbidden.
>
> ACCESS_ONCE() is your friend, we might document it in
> Documentation/volatile-considered-harmful.txt

Good idea, but neither of the use cases at issue here benefit from ACCE=
SS_ONCE.

Thanks for your feedback!

--=20
Chris Metcalf, Tilera Corp.
http://www.tilera.com

