From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Thu, 15 Dec 2016 22:17:44 +0100
Message-ID: <7861e8ca-69fe-30d1-3d79-27ee33a510d0@stressinduktion.org>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
 <707472e1-b385-836d-c4c6-791c1dcc0776@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02402C0@AcuExch.aculab.com>
 <0f3c3694-c00b-aae2-5b08-25bc64bf6372@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240437@AcuExch.aculab.com>
 <f6813084-6f46-0b22-e9c3-97b2e266f8f6@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240529@AcuExch.aculab.com>
 <924ef794-eae0-2a6b-508b-069718339edc@stressinduktion.org>
 <CAHmME9pTLFu3-4n6m_OMj5jVWGE-+yC-4CnkynD--H4Nt8_cpA@mail.gmail.com>
 <18d1e9d1-1e52-b9a6-de26-2f33859ec052@stressinduktion.org>
 <CAHmME9rDCb=2rojJba13Uew9V9qAbxv1qcJGHwEAKoahxyE9QA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
        Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9rDCb=2rojJba13Uew9V9qAbxv1qcJGHwEAKoahxyE9QA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.12.2016 21:43, Jason A. Donenfeld wrote:
> On Thu, Dec 15, 2016 at 9:31 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> ARM64 and x86-64 have memory operations that are not vector operations
>> that operate on 128 bit memory.
> 
> Fair enough. imull I guess.
> 
>> How do you know that the compiler for some architecture will not chose a
>> more optimized instruction to load a 64 bit memory value into two 32 bit
>> registers if you tell the compiler it is 8 byte aligned but it actually
>> isn't? I don't know the answer but telling the compiler some data is 8
>> byte aligned while it isn't really pretty much seems like a call for
>> trouble.
> 
> If a compiler is in the business of using special 64-bit instructions
> on 64-bit aligned data, then it is also the job of the compiler to
> align structs to 64-bits when passed __aligned(8), which is what we've
> done in this code. If the compiler were to hypothetically choose to
> ignore that and internally convert it to a __aligned(4), then it would
> only be able to do so with the knowledge that it will never use 64-bit
> aligned data instructions. But so far as I can tell, gcc always
> respects __aligned(8), which is why I use it in this patchset.
> 
> I think there might have been confusion here, because perhaps someone
> was hoping that since in6_addr is 128-bits, that the __aligned
> attribute would not be required and that the struct would just
> automatically be aligned to at least 8 bytes. But in fact, as I
> mentioned, in6_addr is actually composed of u32[4] and not u64[2], so
> it will only be aligned to 4 bytes, making the __aligned(8) necessary.
> 
> I think for the purposes of this patchset, this is a solved problem.
> There's the unaligned version of the function if you don't know about
> the data, and there's the aligned version if you're using
> __aligned(SIPHASH_ALIGNMENT) on your data. Plain and simple.

And I was exactly questioning this.

static unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
				    const struct in6_addr *daddr)
{
	net_get_random_once(&ip6_frags.rnd, sizeof(ip6_frags.rnd));
	return jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
			    (__force u32)id, ip6_frags.rnd);
}

This function had a hash DoS (and kind of still has), but it has been
mitigated by explicit checks, I hope.

So you start looking for all the pointers where ipv6 addresses could
come from and find some globally defined struct where I would need to
put the aligned(SIPHASH_ALIGNMENT) into to make this work on 32 bit
code? Otherwise just the unaligned version is safe on 32 bit code.

Who knows this? It isn't even obvious by looking at the header!

I would be interested if the compiler can actually constant-fold the
address of the stack allocation with an simple if () or some
__builtin_constant_p fiddeling, so we don't have this constant review
overhead to which function we pass which data. This would also make
this whole discussion mood.

Bye,
Hannes
