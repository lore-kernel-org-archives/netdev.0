From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: next build: 235 warnings 3 failures (next/next-20151117)
Date: Wed, 18 Nov 2015 15:21:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBD57A5@AcuExch.aculab.com>
References: <564a9961.878b420a.331b8.fffffd62@mx.google.com>
 <6370082.rfihnaNWhf@wuerfel> <20151117171236.GJ30101@arm.com>
 <3723928.99NZh1TC6E@wuerfel> <20151118101427.GC22731@arm.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBD53BB@AcuExch.aculab.com>
 <20151118122804.GD1588@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Arnd Bergmann <arnd@arndb.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	"kernel-build-reports@lists.linaro.org"
	<kernel-build-reports@lists.linaro.org>,
	"olof@lixom.net" <olof@lixom.net>,
	David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: 'Will Deacon' <will.deacon@arm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20151118122804.GD1588@arm.com>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Will Deacon
> Sent: 18 November 2015 12:28
> On Wed, Nov 18, 2015 at 12:11:25PM +0000, David Laight wrote:
> > From: Will Deacon
> > > Sent: 18 November 2015 10:14
> > > On Tue, Nov 17, 2015 at 08:17:17PM +0100, Arnd Bergmann wrote:
> > > > On Tuesday 17 November 2015 17:12:37 Will Deacon wrote:
> > > > > On Tue, Nov 17, 2015 at 06:03:40PM +0100, Arnd Bergmann wrote:
> > > > > > On Tuesday 17 November 2015 16:44:53 Will Deacon wrote:
> > > > > > > > 8<----
> > > > > > > > Subject: ARM64: make smp_load_acquire() work with const arguments
> > > > > > > >
> > > > > > > > smp_load_acquire() uses typeof() to declare a local variable for temporarily
> > > > > > > > storing the output of the memory access. This fails when the argument is
> > > > > > > > constant, because the assembler complains about using a constant register
> > > > > > > > as output:
> > > > > > > >
> > > > > > > >  arch/arm64/include/asm/barrier.h:71:3: error: read-only variable '___p1'
> > > > > > > >  used as 'asm' output
> > > > > > >
> > > > > > > Do you know the usage in the kernel causing this warning?
> > > > > >
> > > > > > A newly introduced function in include/net/sock.h:
> > > > > >
> > > > > > static inline int sk_state_load(const struct sock *sk)
> > > > > > {
> > > > > >         return smp_load_acquire(&sk->sk_state);
> > > > > > }
> > > > >
> > > > > Hmm, maybe we could play a similar trick to READ_ONCE by declaring an
> > > > > anonymous union and writing through the non-const member?
> > > >
> > > > Yes, I think that would work, if you think we need to care about the
> > > > case where we read into a structure.
> > > >
> > > > Can you come up with a patch for that?
> > >
> > > Done:
> > >
> > >   http://lists.infradead.org/pipermail/linux-arm-kernel/2015-November/386094.html
> >
> > That patch forces a memory write-read and returns uninitialised stack
> > for short reads.
> 
> Really? The disassembly looks fine to me. Do you have a concrete example
> of where you think it goes wrong, please?
> 
> > Who knows what happens on big-endian systems.
> 
> The same thing as READ_ONCE? I'll test it there to make sure, but I
> don't see a problem.

Ah, god, it is absolutely horrid. But probably right :-(

Do all the lda variants zero extend to 64 bits ?
If so maybe you could use a single 64 bit variable for the result of the read
and then cast it to typeof(*p) to get the required sign extension for
small integer types.

	David
