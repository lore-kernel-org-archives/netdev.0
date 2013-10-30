From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Wed, 30 Oct 2013 14:04:13 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73C7@saturn3.aculab.com>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com> <20131030110214.GA10220@localhost.localdomain> <52710B09.6090302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Ingo Molnar" <mingo@kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Doug Ledford" <dledford@redhat.com>,
	"Neil Horman" <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <52710B09.6090302@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

...
> and then I also wanted to try using both xmm and ymm registers and doing
> 64bit adds with 32bit numbers across multiple xmm/ymm registers as that
> should parallel nicely.  David, you mentioned you've tried this, how did
> your experiment turn out and what was your method?  I was planning on
> doing regular full size loads into one xmm/ymm register, then using
> pshufd/vshufd to move the data into two different registers, then
> summing into a fourth register, and possible running two of those
> pipelines in parallel.

It was a long time ago, and IIRC the code was just SSE so the
register length just wasn't going to give the required benefit.
I know I wrote the code, but I can't even remember whether I
actually got it working!
With the longer AVX words it might make enough difference.
Of course, this assumes that you have the fpu registers
available. If you have to do a fpu context switch it will
be a lot slower.

About the same time I did manage to an open coded copy
loop to run as fast as 'rep movs' - and without any unrolling
or any prefetch instructions.

Thinking about AVX you should be able to do (without looking up the
actual mnemonics):
	load
	add 32bit chunks to sum
	compare sum with read value (equiv of carry)
	add/subtract compare result (0 or ~0) to a carry-sum register
That is 4 instructions for 256 bits, so you can aim for 4 clocks.
You'd need to check the cpu book to see if any of those can
be scheduled at the same time (if not dependant).
(and also whether there is any result delay - don't think so.)

I'd try running two copies of the above - probably skewed so that
the memory accesses are separated, do the memory read for the
next iteration, and use the 3rd instruction unit for loop control.

	David
