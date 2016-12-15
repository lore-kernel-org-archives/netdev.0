From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable function
Date: Thu, 15 Dec 2016 21:43:04 +0100
Message-ID: <CAHmME9rDCb=2rojJba13Uew9V9qAbxv1qcJGHwEAKoahxyE9QA@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
 <707472e1-b385-836d-c4c6-791c1dcc0776@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02402C0@AcuExch.aculab.com>
 <0f3c3694-c00b-aae2-5b08-25bc64bf6372@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240437@AcuExch.aculab.com>
 <f6813084-6f46-0b22-e9c3-97b2e266f8f6@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240529@AcuExch.aculab.com>
 <924ef794-eae0-2a6b-508b-069718339edc@stressinduktion.org>
 <CAHmME9pTLFu3-4n6m_OMj5jVWGE-+yC-4CnkynD--H4Nt8_cpA@mail.gmail.com> <18d1e9d1-1e52-b9a6-de26-2f33859ec052@stressinduktion.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>, Netdev <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, "Daniel J . Bernstein" <djb@cr.yp.to>,
	Linus Torvalds <torvalds@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <kernel-hardening-return-5597-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <18d1e9d1-1e52-b9a6-de26-2f33859ec052@stressinduktion.org>
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 9:31 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> ARM64 and x86-64 have memory operations that are not vector operations
> that operate on 128 bit memory.

Fair enough. imull I guess.

> How do you know that the compiler for some architecture will not chose a
> more optimized instruction to load a 64 bit memory value into two 32 bit
> registers if you tell the compiler it is 8 byte aligned but it actually
> isn't? I don't know the answer but telling the compiler some data is 8
> byte aligned while it isn't really pretty much seems like a call for
> trouble.

If a compiler is in the business of using special 64-bit instructions
on 64-bit aligned data, then it is also the job of the compiler to
align structs to 64-bits when passed __aligned(8), which is what we've
done in this code. If the compiler were to hypothetically choose to
ignore that and internally convert it to a __aligned(4), then it would
only be able to do so with the knowledge that it will never use 64-bit
aligned data instructions. But so far as I can tell, gcc always
respects __aligned(8), which is why I use it in this patchset.

I think there might have been confusion here, because perhaps someone
was hoping that since in6_addr is 128-bits, that the __aligned
attribute would not be required and that the struct would just
automatically be aligned to at least 8 bytes. But in fact, as I
mentioned, in6_addr is actually composed of u32[4] and not u64[2], so
it will only be aligned to 4 bytes, making the __aligned(8) necessary.

I think for the purposes of this patchset, this is a solved problem.
There's the unaligned version of the function if you don't know about
the data, and there's the aligned version if you're using
__aligned(SIPHASH_ALIGNMENT) on your data. Plain and simple.

Jason
